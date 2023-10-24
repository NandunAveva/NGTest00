USE [ACME_AmplaExtras]
GO
/****** Object:  StoredProcedure [dbo].[RP_DowntimeSummary]    Script Date: 1/04/2022 12:03:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Administrator>
-- Create date: <1/1/2022>
-- Description: <This stored procedure gets the downtime records and aggregates them for Downtime Summary report> 
-- =============================================
CREATE PROCEDURE [dbo].[RP_DowntimeSummary]

@Location NVARCHAR(250),
@SamplePeriod NVARCHAR(250),
@startDateLocalTime  NVARCHAR(250),
@endDateLocalTime  NVARCHAR(250)	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Downtimes TABLE
	(
		[Location] NVARCHAR(250),
		[Cause_Location] NVARCHAR(250),
		[Cause_Location_ID] NVARCHAR(250),
		[Effective_Duration_Clipped] INT
	)
	INSERT INTO @Downtimes
	EXEC   [dbo].[GetDataByLocationV200806]
              @module = 'Downtime',
              @location = @Location,
              @samplePeriod = @SamplePeriod,
			  @startDateLocalTime = @StartDateLocalTime,
			  @endDateLocalTime = @EndDateLocalTime,
			  @viewName = N'Standard View',
			  @fields = 'Location,Cause Location,Equipment Id (Cause Location),Eff. Duration (Clipped)',
			  @filters = 'Record Type={Slow Running or Real Downtime}, Deleted={False}',         
              @inclusiveDataRange = 0,           
              @resolveIdentifiers = 1,
              @pivotResults = 1						

	SELECT 
	[Location] ,
	[Cause_Location] ,
	[Cause_Location_ID] ,
	SUM([Effective_Duration_Clipped])/60 AS Duration,
	COUNT([Effective_Duration_Clipped]) AS Occurance
	FROM @Downtimes
	GROUP BY [Location] ,[Cause_Location],[Cause_Location_ID] 
END
