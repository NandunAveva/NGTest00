USE [ACME_AmplaExtras]
GO
/****** Object:  StoredProcedure [dbo].[RP_ShiftBalanceSummary]    Script Date: 13/05/2020 4:59:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Administrator>
-- Create date: <1/1/2020>
-- Description: <This stored procedure returns opening and closing balance of stockyard for a shift>
-- Description: <To get opening balance for a shift we use the first balance value from Balance Over Time view> 
-- Description: <To get closing balance for a shift we use the first balance value from Balance Over Time view of the next shift> 
-- Description: <It is important to use sample period and not start and end time so if there is balance change at the shift start Ampla will calcuate the balance and return it> 
-- =============================================
CREATE PROCEDURE [dbo].[RP_ShiftBalanceSummary] 	

@Location NVARCHAR(250),
@SamplePeriodOpening NVARCHAR(250),
@SamplePeriodClosing NVARCHAR(250)	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Balances TABLE
	(
		[Sample_Period] DATETIME,
		[Location] NVARCHAR(250),
		[Location Identifier] NVARCHAR(250),
		[Material] NVARCHAR(250),
		[Balance] float
	)
	
	DECLARE @Summary TABLE
	(
		[Location] NVARCHAR(250),
		[Location Identifier] NVARCHAR(250),
		[Material] NVARCHAR(250),
		[OpeningBalance] float,
		[ClosingBalance] float
	)

	INSERT INTO @Balances 
	EXEC   [dbo].[GetDataByLocationV200806]
              @module = 'Inventory',
              @location = @Location,
              @samplePeriod = @SamplePeriodOpening,
			  @viewName = N'Balance Over time',
			  @fields = 'Sample Period,Location,Location Identifier,Material Identifier,Balance',       
              @inclusiveDataRange = 0,           
              @resolveIdentifiers = 1,
              @pivotResults = 1						

	INSERT INTO @Summary ([Location],[Location Identifier],[Material],[OpeningBalance])
	SELECT DISTINCT * FROM
		(SELECT [Location],
		[Location Identifier],
		[Material],
		FIRST_VALUE(Balance) OVER (PARTITION BY [Location],[Material],[Location Identifier] ORDER BY [Sample_Period] ASC) AS OpeningBalance
		FROM @Balances) b

	DELETE FROM @Balances

	INSERT INTO @Balances 
	EXEC   [dbo].[GetDataByLocationV200806]
              @module = 'Inventory',
              @location = @Location,
              @samplePeriod = @SamplePeriodClosing,
			  @viewName = N'Balance Over time',
			  @fields = 'Sample Period,Location,Location Identifier,Material Identifier,Balance',       
              @inclusiveDataRange = 0,           
              @resolveIdentifiers = 1,
              @pivotResults = 1	
	

	UPDATE @Summary SET s.ClosingBalance = c.ClosingBalance
	FROM
	@Summary s
	INNER JOIN 
	(SELECT DISTINCT * FROM  
		(SELECT [Location],
				[Location Identifier],
				[Material],
				FIRST_VALUE(Balance) OVER (PARTITION BY [Location],[Material],[Location Identifier] ORDER BY [Sample_Period] ASC) AS ClosingBalance
		FROM @Balances) b
	) c
	ON c.[Location]=s.[Location] AND c.Material = s.Material

	SELECT * FROM @Summary
	WHERE [Location] like '%StockYard%'
END
