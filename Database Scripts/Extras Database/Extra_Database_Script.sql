USE [master]
GO
/****** Object:  Database [ACME_AmplaExtras]    Script Date: 13/05/2020 5:01:24 PM ******/
CREATE DATABASE [ACME_AmplaExtras]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'ACME_AmplaExtras', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\ACME_AmplaExtras.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'ACME_AmplaExtras_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\ACME_AmplaExtras_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [ACME_AmplaExtras] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ACME_AmplaExtras].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ACME_AmplaExtras] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET ARITHABORT OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ACME_AmplaExtras] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ACME_AmplaExtras] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET  DISABLE_BROKER 
GO
ALTER DATABASE [ACME_AmplaExtras] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET TRUSTWORTHY ON 
GO
ALTER DATABASE [ACME_AmplaExtras] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ACME_AmplaExtras] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET RECOVERY FULL 
GO
ALTER DATABASE [ACME_AmplaExtras] SET  MULTI_USER 
GO
ALTER DATABASE [ACME_AmplaExtras] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ACME_AmplaExtras] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ACME_AmplaExtras] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ACME_AmplaExtras] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [ACME_AmplaExtras] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'ACME_AmplaExtras', N'ON'
GO
ALTER DATABASE [ACME_AmplaExtras] SET QUERY_STORE = OFF
GO
USE [ACME_AmplaExtras]
GO

/****** Object:  UserDefinedFunction [dbo].[GetSampleId]    Script Date: 13/05/2020 5:01:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Administrator>
-- Create date: <1/1/2020>
-- Description:	<This function generates Quality sampleIds for day and night shifts based on the time to be used as Lots in Material Quality>
-- =============================================
CREATE FUNCTION [dbo].[GetSampleId] (@date DATETIME) RETURNS NVARCHAR(20)
AS
BEGIN
DECLARE @time AS TIME

DECLARE @sample AS NVARCHAR(20)

SET @date = GETDATE()
SET @time = CAST( @date AS TIME)

IF @time <= '6:00:00'
	SET @sample = CONVERT(varchar, DATEADD(DAY,-1,@date), 112) + '-NS'
ELSE
   IF @time <= '18:00:00'
     SET @sample = CONVERT(varchar, @date, 112) + '-DS'
   ELSE 
     SET @sample = CONVERT(varchar, @date, 112) + '-NS'

   RETURN @sample
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetSamplePeriod]    Script Date: 13/05/2020 5:01:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Administrator>
-- Create date: <1/1/2020>
-- Description:	<This function generates Quality sample period for day and night shifts based on the time>
-- =============================================
CREATE FUNCTION [dbo].[GetSamplePeriod] (@date DATETIME) RETURNS DATETIME
AS
BEGIN
DECLARE @time AS TIME

DECLARE @sample AS NVARCHAR(20)

SET @time = CAST( @date AS TIME)

IF @time <= '6:00:00'
	SET @date = DATEADD(SECOND,1, DATEADD(HOUR, 18 , CAST(CAST(DATEADD(DAY,-1,@date) AS DATE) AS DATETIME)))
ELSE
   IF @time <= '18:00:00'
      SET @date = DATEADD(SECOND,1, DATEADD(HOUR, 6, CAST(CAST(@date AS DATE) AS DATETIME)))
   ELSE 
     SET @date = DATEADD(SECOND,1,DATEADD(HOUR, 18, CAST(CAST(@date AS DATE) AS DATETIME)))
--	 IF @time <= '6:00:00'
--	SET @date = DATEADD(HOUR, 6 , CAST(CAST(@date AS DATE) AS DATETIME))
--ELSE
--   IF @time <= '18:00:00'
--      SET @date = DATEADD(HOUR, 18, CAST(CAST(@date AS DATE) AS DATETIME))
--   ELSE 
--     SET @date = DATEADD(HOUR, 6 , CAST(CAST(DATEADD(DAY,+1,@date) AS DATE) AS DATETIME))

   RETURN @date
END
GO
/****** Object:  Table [dbo].[GeoSystem]    Script Date: 13/05/2020 5:01:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GeoSystem](
	[ID] [int] NOT NULL,
	[BlastBlock] [nvarchar](50) NOT NULL,
	[Region] [nvarchar](50) NULL,
	[Pit] [int] NULL,
	[Strip] [int] NULL,
	[Bench] [int] NULL,
	[Blast] [nvarchar](50) NOT NULL,
	[Flinch] [int] NULL,
	[Material] [nvarchar](50) NULL,
	[Quantity] [int] NULL,
	[Ash] [float] NULL,
	[Moisture] [int] NULL,
 CONSTRAINT [PK_GeoSystem] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InitialMovements]    Script Date: 13/05/2020 5:01:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InitialMovements](
	[ID] [int] NOT NULL,
	[SourceEquipment] [nvarchar](100) NOT NULL,
	[DestinationEquipment] [nvarchar](100) NOT NULL,
	[SourceMaterial] [nvarchar](100) NOT NULL,
	[DestinationMaterial] [nvarchar](100) NOT NULL,
	[SourceLot] [nvarchar](100) NOT NULL,
	[DestinationLot] [nvarchar](100) NOT NULL,
	[SourceLotGroup] [nvarchar](100) NOT NULL,
	[DestinationLotGroup] [nvarchar](100) NOT NULL,
	[SourceQuantity] [float] NOT NULL,
	[DestinationQuantity] [float] NOT NULL,
	[Ash] [float] NULL,
	[Moisture] [float] NULL,
	[MaterialQulaityLocation] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_GInitialMovements] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[GeoSystem] ([ID], [BlastBlock], [Region], [Pit], [Strip], [Bench], [Blast], [Flinch], [Material], [Quantity], [Ash], [Moisture]) VALUES (1, N'D201_432_010_432_W_1', N'D', 2, 1, 432, N'D201_432_010', 432, N'Waste', 1000000, 79, 5)
INSERT [dbo].[GeoSystem] ([ID], [BlastBlock], [Region], [Pit], [Strip], [Bench], [Blast], [Flinch], [Material], [Quantity], [Ash], [Moisture]) VALUES (2, N'D201_432_010_436_W_1', N'D', 2, 1, 432, N'D201_432_010', 436, N'Waste', 1000000, 77, 5)
INSERT [dbo].[GeoSystem] ([ID], [BlastBlock], [Region], [Pit], [Strip], [Bench], [Blast], [Flinch], [Material], [Quantity], [Ash], [Moisture]) VALUES (3, N'D201_432_010_440_W_1', N'D', 2, 1, 432, N'D201_432_010', 440, N'Waste', 1000000, 82, 5)
INSERT [dbo].[GeoSystem] ([ID], [BlastBlock], [Region], [Pit], [Strip], [Bench], [Blast], [Flinch], [Material], [Quantity], [Ash], [Moisture]) VALUES (4, N'D201_432_011_432_W_1', N'D', 2, 1, 432, N'D201_432_011', 432, N'Waste', 1000000, 79, 4)
INSERT [dbo].[GeoSystem] ([ID], [BlastBlock], [Region], [Pit], [Strip], [Bench], [Blast], [Flinch], [Material], [Quantity], [Ash], [Moisture]) VALUES (5, N'D201_432_011_432_W_3', N'D', 2, 1, 432, N'D201_432_011', 432, N'Waste', 1000000, 69, 4)
INSERT [dbo].[GeoSystem] ([ID], [BlastBlock], [Region], [Pit], [Strip], [Bench], [Blast], [Flinch], [Material], [Quantity], [Ash], [Moisture]) VALUES (6, N'D201_432_011_436_W_1', N'D', 2, 1, 432, N'D201_432_011', 436, N'Waste', 1000000, 74, 4)
INSERT [dbo].[GeoSystem] ([ID], [BlastBlock], [Region], [Pit], [Strip], [Bench], [Blast], [Flinch], [Material], [Quantity], [Ash], [Moisture]) VALUES (7, N'D201_432_011_440_W_1', N'D', 2, 1, 432, N'D201_432_011', 440, N'Waste', 1000000, 80, 4)
INSERT [dbo].[GeoSystem] ([ID], [BlastBlock], [Region], [Pit], [Strip], [Bench], [Blast], [Flinch], [Material], [Quantity], [Ash], [Moisture]) VALUES (8, N'D201_432_028_432_C_1', N'D', 2, 1, 432, N'D201_432_028', 432, N'Raw Coal', 1000000, 41.52, 10)
INSERT [dbo].[GeoSystem] ([ID], [BlastBlock], [Region], [Pit], [Strip], [Bench], [Blast], [Flinch], [Material], [Quantity], [Ash], [Moisture]) VALUES (9, N'D201_432_028_432_C_2', N'D', 2, 1, 432, N'D201_432_028', 432, N'Raw Coal', 1000000, 35.58, 6)
INSERT [dbo].[GeoSystem] ([ID], [BlastBlock], [Region], [Pit], [Strip], [Bench], [Blast], [Flinch], [Material], [Quantity], [Ash], [Moisture]) VALUES (10, N'D201_432_028_432_C_3', N'D', 2, 1, 432, N'D201_432_028', 432, N'Raw Coal', 1000000, 39.39, 5)
INSERT [dbo].[InitialMovements] ([ID], [SourceEquipment], [DestinationEquipment], [SourceMaterial], [DestinationMaterial], [SourceLot], [DestinationLot], [SourceLotGroup], [DestinationLotGroup], [SourceQuantity], [DestinationQuantity], [Ash], [Moisture], [MaterialQulaityLocation]) VALUES (1, N'ACME.Rocky Mine.Input', N'ACME.Rocky Mine.Mining.ROM.ROM Stockyard', N'Material Model.Raw Coal', N'Material Model.Raw Coal', N'ROM-Initial', N'ROM-Initial', N'R1', N'R1', 10000, 10000, 40, 5, N'ACME.Rocky Mine.NominalMQ')
INSERT [dbo].[InitialMovements] ([ID], [SourceEquipment], [DestinationEquipment], [SourceMaterial], [DestinationMaterial], [SourceLot], [DestinationLot], [SourceLotGroup], [DestinationLotGroup], [SourceQuantity], [DestinationQuantity], [Ash], [Moisture], [MaterialQulaityLocation]) VALUES (2, N'ACME.Rocky Mine.Input', N'ACME.Rocky Mine.Mining.ROM.Crushed Stockyard', N'Material Model.Crushed Coal', N'Material Model.Crushed Coal', N'Crushed-Initial', N'Crushed-Initial', N'1', N'1', 10000, 10000, 40, 5, N'ACME.Rocky Mine.Mining.ROM.Crushed Stockyard.MQ')
INSERT [dbo].[InitialMovements] ([ID], [SourceEquipment], [DestinationEquipment], [SourceMaterial], [DestinationMaterial], [SourceLot], [DestinationLot], [SourceLotGroup], [DestinationLotGroup], [SourceQuantity], [DestinationQuantity], [Ash], [Moisture], [MaterialQulaityLocation]) VALUES (3, N'ACME.Rocky Mine.Input', N'ACME.Rocky Mine.Train Loadout.Product Stockyard', N'Material Model.Product.THUW', N'Material Model.Product.THUW', N'THUW-Initial', N'THUW-Initial', N'THUW', N'THUW', 10000, 10000, 10, 5, N'ACME.Rocky Mine.Train Loadout.Product Stockyard.MQ')
INSERT [dbo].[InitialMovements] ([ID], [SourceEquipment], [DestinationEquipment], [SourceMaterial], [DestinationMaterial], [SourceLot], [DestinationLot], [SourceLotGroup], [DestinationLotGroup], [SourceQuantity], [DestinationQuantity], [Ash], [Moisture], [MaterialQulaityLocation]) VALUES (4, N'ACME.Rocky Mine.Input', N'ACME.Rocky Mine.Train Loadout.Product Stockyard', N'Material Model.Product.THWS', N'Material Model.Product.THWS', N'THWS-Initial', N'THWS-Initial', N'THWS', N'THWS', 10000, 10000, 9, 5, N'ACME.Rocky Mine.Train Loadout.Product Stockyard.MQ')

/****** Object:  StoredProcedure [dbo].[GetBlastBlocks]    Script Date: 13/05/2020 5:01:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Administrator>
-- Create date: <1/1/2020>
-- Description:	<This query gets data from GeoSystem to feed Ampla Input movements, Nominal block qualities and metadata>
-- Description: <As the template project is not connected to any system, the sample data are saved into a table in the Extra database> 
-- Description: <For simplicity in this template GeoSystem data is only imported once into Ampla but in real projects this is not the case and data must be imported as they become available> 
-- =============================================
CREATE PROCEDURE [dbo].[GetBlastBlocks] 	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

------------------------------------------------
-- Gets all records of GeoSystem table
------------------------------------------------
	SELECT 
	*
	FROM GeoSystem 	

END
GO
/****** Object:  StoredProcedure [dbo].[GetFleetMovements]    Script Date: 13/05/2020 5:01:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Administrator>
-- Create date: <1/1/2020>
-- Description:	<This query gets the material moved by trucks from FMS System. Since the template project is not connected to a real system, this SP simulates some movements>
-- Description: <This is a very simple approach and does not cover changes on truck movements> 
-- =============================================
CREATE PROCEDURE [dbo].[GetFleetMovements] 	
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
	
SET NOCOUNT ON;

DECLARE @time AS DATETIME

SET @time = DATEADD(HOUR, -1,GETDATE())
	

DECLARE @first AS INT = 1
DECLARE @lastC AS INT = 10
DECLARE @lastW AS INT = 40

DECLARE @fms TABLE
(
 SamplePeriod				DATETIME,
 BlastBlock					NVARCHAR(100),
 Fleet						VARCHAR(100),
 Material					NVARCHAR(100),
 SourceLocation				NVARCHAR(100),
 SourceStockpile			NVARCHAR(100),
 DestinationLocation		NVARCHAR(100),
 DestinationStockpile		NVARCHAR(100),
 Quantity					FLOAT
)
----------------------------------------------
-- Simulate FMS movements
----------------------------------------------

WHILE(@first <= @lastC)
BEGIN
	INSERT INTO @fms 
	SELECT TOP 1
	@time,
	BlastBlock,
	'Truck'+ CAST(@first AS VARCHAR(10)),
	'Material Model.Raw Coal',
	'ACME.Rocky Mine.Mining.InPit',
	Blast,
	'ACME.Rocky Mine.Mining.ROM.ROM Stockyard',
	'R1',
	 320
	FROM GeoSystem
	WHERE BlastBlock LIKE '%_C_%'
	ORDER BY newid() 
   
    SET @first += 1
	SET @time = DATEADD(MINUTE, 1, @time)
END

SET @first = 1
SET @time = DATEADD(HOUR, -1,GETDATE())

WHILE(@first <= @lastW)
BEGIN
	INSERT INTO @fms 
	SELECT TOP 1
	@time,
	BlastBlock,
	'Truck'+ CAST(@first+20 AS VARCHAR(10)),
	'Material Model.Waste',
	'ACME.Rocky Mine.Mining.InPit',
	Blast,
	'ACME.Rocky Mine.Waste Dump.Waste',
	'Waste',
	 200
	FROM GeoSystem
	WHERE BlastBlock LIKE '%_W_%'
	ORDER BY newid() 
   
    SET @first += 1
	SET @time = DATEADD(MINUTE, 1, @time)
END
-------------------------------------------------------
-- Although FMS has all the truck movements, it is not recomended to create a separte Inventory movement for each track movement
-- Usually you can group truck movements based on the lot, material, source and destination for Inventory movements
-- Query FMS table to group records for Inventory movements
-------------------------------------------------------
SELECT  
 DATEADD(HOUR, -1,GETDATE()) AS		SamplePeriod,
 BlastBlock,
 Material,
 SourceLocation,
 SourceStockpile,
 DestinationLocation,
 DestinationStockpile,
 SUM(Quantity) AS Quantity
FROM @fms
GROUP BY BlastBlock,Material,SourceLocation,SourceStockpile,DestinationLocation,DestinationStockpile

-------------------------------------------------------
-- Although FMS has all the truck movements, it is not recomended to create a separte Inventory movement for each track movement
-- Usually you can group truck movements based on the lot, material, source and destination for Inventory movements
-- Query FMS table to group records for Inventory movements
-------------------------------------------------------
SELECT  
 DATEADD(HOUR, -1,GETDATE()) AS		SamplePeriod,
 BlastBlock,
 Material,
 SourceLocation,
 SourceStockpile,
 DestinationLocation,
 DestinationStockpile,
 SUM(Quantity) AS Quantity
FROM @fms
GROUP BY BlastBlock,Material,SourceLocation,SourceStockpile,DestinationLocation,DestinationStockpile

END
GO
/****** Object:  StoredProcedure [dbo].[GetInitialMovements]    Script Date: 13/05/2020 5:01:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Administrator>
-- Create date: <1/1/2020>
-- Description:	<This query gets data from InitialMovements table to create initial balances in different work centers>
-- Description: <These movements are usually created manually in Ampla Production Analyst using add-hoc movements, but in this template project we are simulating them for simplicity> 
-- =============================================
CREATE PROCEDURE [dbo].[GetInitialMovements] 	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

------------------------------------------------
-- Gets all records of InitialMovements table
------------------------------------------------
	SELECT 
	*
	FROM InitialMovements 

	

END
GO
/****** Object:  StoredProcedure [dbo].[GetLabResultForCrusher]    Script Date: 13/05/2020 5:01:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Administrator>
-- Create date: <1/1/2020>
-- Description:	<This stored procedure submits random numbers as plant feed quality samples into Material Quality reporting point of ACME project using Ampla Plant to Business (P2B)>
--				<For Demo purpose we assume quality samples are taken during the shift and the result will be ready during the shift, Ampla checks LIMS for the result every hour and imports it if ready>
--				<This code is just simulate data every time it is executed for demo purpose. In a real project the stored procedure needs to query LIMS database and will have pareameters to get the result for the requested period>
-- =============================================
CREATE PROCEDURE [dbo].[GetLabResultForCrusher] 	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
	[dbo].[GetSamplePeriod] (GETDATE())									AS SampleDateTime,
	'Crushed-' + [dbo].[GetSampleId] (GETDATE())						AS [Sample ID],
	'Material Model.Crushed Coal'										AS Material,						
	RAND()*(25.8 - 15.8)+ 15.8											AS [Ash],				--Random number between 15.8 and 15.8
	RAND()*(9.1 - 6.5)+ 6.5												AS [Moisture]			--Random number between 6.5 and 9.1


END
GO
/****** Object:  StoredProcedure [dbo].[GetLabResultForProductSP]    Script Date: 13/05/2020 5:01:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Administrator>
-- Create date: <1/1/2020>
-- Description:	<This stored procedure submits random numbers as product quality samples into Product Material Quality reporting point of ACME project using Ampla Plant to Business (P2B)>
--				<For Demo purpose we assume quality samples are taken during the shift and the result will be ready during the shift, Ampla checks LIMS for the result every hour and imports it if ready>
--				<This code is just simulate data every time it is executed for demo purpose. In a real project the stored procedure needs to query LIMS database and will have pareameters to get the result for the requested period>
-- =============================================
CREATE PROCEDURE [dbo].[GetLabResultForProductSP] 	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
	[dbo].[GetSamplePeriod] (GETDATE())									AS SampleDateTime,
	'THUW-' + [dbo].[GetSampleId] (GETDATE())		 					AS [Sample ID],
	'Material Model.Product.THUW'										AS Material,						
	RAND()*(9.7 - 8.1) + 8.1											AS [Ash],					--Random number between 9.7 and 8.1
	RAND()*(12.3 - 9.6) + 9.6											AS [Sulphur],				--Random number between 9.6 and 12.3 
	RAND()*(22.9 - 21.3) + 21.3											AS [Volatile matter],		--Random number between 21.3 and 22.9
	RAND()*(13.1 - 9.8) + 9.8											AS [Moisture]				--Random number between 9.8 and 13.1

	UNION ALL
	SELECT 
	[dbo].[GetSamplePeriod] (GETDATE())									AS SampleDateTime,
	'THWS-' + [dbo].[GetSampleId] (GETDATE())							AS [Sample ID],
	'Material Model.Product.THWS'										AS Material,	
	RAND()*(12.9 - 10.1) + 10.1											AS [Ash],					--Random number between 12.9 and 10.1
	RAND()*(23.2 - 21.9) + 21.9											AS [Sulphur],				--Random number between 21.9 and 23.2 
	RAND()*(23.3 - 21.1) + 21.1											AS [Volatile matter],		--Random number between 21.1 and 23.3 
	RAND()*(13.2 - 9.9) + 9.9											AS [Moisture]				--Random number between 9.9 and 13.2

END
GO
/****** Object:  StoredProcedure [dbo].[GetLabResultForWaste]    Script Date: 13/05/2020 5:01:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Administrator>
-- Create date: <1/1/2020>
-- Description:	<This stored procedure submits random numbers as Waste quality samples into Waste Material Quality reporting point of ACME project using Ampla Plant to Business (P2B)>
--				<For Demo purpose we assume quality samples are taken during the shift and the result will be ready during the shift, Ampla checks LIMS for the result every hour and imports it if ready>
--				<This code is just simulate data every time it is executed for demo purpose. In a real project the stored procedure needs to query LIMS database and will have pareameters to get the result for the requested period>
-- =============================================
CREATE PROCEDURE [dbo].[GetLabResultForWaste] 	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
	[dbo].[GetSamplePeriod] (GETDATE())						AS SampleDateTime,
	'Waste-' + [dbo].[GetSampleId] (GETDATE()) 				AS [Sample ID],
	'Material Model.Waste'									AS Material,						
	RAND()*(80 - 59) + 59									AS [Ash],						--Random number between 59 and 80
	RAND()*(20 - 10) + 10									AS [Moisture]					--Random number between 20 and 10

END
GO
USE [master]
GO
ALTER DATABASE [ACME_AmplaExtras] SET  READ_WRITE 
GO
