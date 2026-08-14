USE [master]
GO
/****** Object:  Database [EmrSimulator]    Script Date: 14-Aug-26 6:02:49 PM ******/
CREATE DATABASE [EmrSimulator]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'EmrSimulator', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\EmrSimulator.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'EmrSimulator_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\EmrSimulator_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [EmrSimulator].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [EmrSimulator] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [EmrSimulator] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [EmrSimulator] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [EmrSimulator] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [EmrSimulator] SET ARITHABORT OFF 
GO
ALTER DATABASE [EmrSimulator] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [EmrSimulator] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [EmrSimulator] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [EmrSimulator] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [EmrSimulator] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [EmrSimulator] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [EmrSimulator] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [EmrSimulator] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [EmrSimulator] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [EmrSimulator] SET  DISABLE_BROKER 
GO
ALTER DATABASE [EmrSimulator] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [EmrSimulator] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [EmrSimulator] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [EmrSimulator] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [EmrSimulator] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [EmrSimulator] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [EmrSimulator] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [EmrSimulator] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [EmrSimulator] SET  MULTI_USER 
GO
ALTER DATABASE [EmrSimulator] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [EmrSimulator] SET DB_CHAINING OFF 
GO
ALTER DATABASE [EmrSimulator] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [EmrSimulator] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [EmrSimulator] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [EmrSimulator] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [EmrSimulator] SET QUERY_STORE = ON
GO
ALTER DATABASE [EmrSimulator] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [EmrSimulator]
GO
/****** Object:  Table [dbo].[BradenAssessment]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BradenAssessment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LabId] [int] NOT NULL,
	[PatientId] [int] NOT NULL,
	[DateOfAssessment] [date] NOT NULL,
	[NurseInitials] [nvarchar](10) NOT NULL,
	[Sensory] [int] NOT NULL,
	[Moisture] [int] NOT NULL,
	[Activity] [int] NOT NULL,
	[Mobility] [int] NOT NULL,
	[Nutrition] [int] NOT NULL,
	[Friction] [int] NOT NULL,
	[TotalScore] [int] NOT NULL,
	[RiskKey] [nvarchar](50) NOT NULL,
	[Shift] [nvarchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FallRiskAssessments]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FallRiskAssessments](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LabId] [int] NOT NULL,
	[PatientId] [int] NOT NULL,
	[RecentFallsScore] [int] NOT NULL,
	[MedicationsScore] [int] NOT NULL,
	[PsychologicalScore] [int] NOT NULL,
	[CognitiveScore] [int] NOT NULL,
	[TotalScore] [int] NOT NULL,
	[RiskLevel] [nvarchar](20) NOT NULL,
	[AssessedAt] [datetime2](0) NOT NULL,
	[Assessor] [nvarchar](100) NULL,
	[Notes] [nvarchar](max) NULL,
	[AutoCondChange] [bit] NULL,
	[AutoDizziness] [bit] NULL,
	[AutoAnaesthetic] [bit] NULL,
	[InterventionNotes] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FluidBalanceChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FluidBalanceChart](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LabId] [int] NULL,
	[PatientId] [int] NULL,
	[ChartDate] [date] NOT NULL,
	[ChartTime] [time](7) NULL,
	[PreviousDayBalance] [int] NULL,
	[TotalIntake] [int] NOT NULL,
	[TotalOutput] [int] NOT NULL,
	[Balance] [int] NOT NULL,
	[TotalBalance] [int] NOT NULL,
	[ClinicalNotes] [nvarchar](max) NULL,
	[SignatureData] [nvarchar](max) NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[UpdatedDateTime] [datetime] NULL,
 CONSTRAINT [PK_FluidBalanceChart] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FluidBalanceChartEntry]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FluidBalanceChartEntry](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FluidBalanceChartId] [int] NOT NULL,
	[EntryTime] [varchar](4) NOT NULL,
	[EntryType] [nvarchar](10) NOT NULL,
	[Category] [nvarchar](50) NOT NULL,
	[AmountMl] [int] NOT NULL,
	[CreatedDateTime] [datetime] NOT NULL,
	[EntryDate] [date] NOT NULL,
	[Initials] [nvarchar](10) NULL,
 CONSTRAINT [PK_FluidBalanceChartEntry] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FoodIntakeHeader]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FoodIntakeHeader](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LabId] [int] NOT NULL,
	[PatientId] [int] NOT NULL,
	[DayText] [nvarchar](10) NULL,
	[IntakeDate] [date] NOT NULL,
	[Shift1Signature] [nvarchar](40) NULL,
	[Shift1Designation] [nvarchar](40) NULL,
	[Shift2Signature] [nvarchar](40) NULL,
	[Shift2Designation] [nvarchar](40) NULL,
	[Shift3Signature] [nvarchar](40) NULL,
	[Shift3Designation] [nvarchar](40) NULL,
	[BreakfastComment] [nvarchar](200) NULL,
	[MorningTeaComment] [nvarchar](200) NULL,
	[LunchComment] [nvarchar](200) NULL,
	[AfternoonTeaComment] [nvarchar](200) NULL,
	[DinnerComment] [nvarchar](200) NULL,
	[SupperComment] [nvarchar](200) NULL,
 CONSTRAINT [PK__FoodInta__3214EC07CAE3F4BB] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FoodIntakeItem]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FoodIntakeItem](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[HeaderId] [int] NOT NULL,
	[Meal] [nvarchar](30) NOT NULL,
	[Label] [nvarchar](50) NOT NULL,
	[Notes] [nvarchar](200) NULL,
	[Amount] [nvarchar](10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IvFluidAdministration]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IvFluidAdministration](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LabId] [int] NULL,
	[PatientId] [int] NULL,
	[IvFluidChartId] [int] NULL,
	[StartDate] [date] NULL,
	[StartTime] [varchar](50) NULL,
	[EndDate] [date] NULL,
	[EndTime] [varchar](50) NULL,
	[VolGiven] [varchar](50) NULL,
	[PharmacistReview] [varchar](200) NULL,
	[NurseSign] [varchar](50) NULL,
	[CoSign] [varchar](50) NULL,
 CONSTRAINT [PK_IvFluidAdministration] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IvFluidChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IvFluidChart](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LabId] [int] NULL,
	[PatientId] [int] NULL,
	[Date] [date] NULL,
	[FlaskVol] [varchar](50) NULL,
	[Strength] [varchar](50) NULL,
	[Rate] [varchar](50) NULL,
	[Dose] [varchar](50) NULL,
	[OfficerSign] [varchar](50) NULL,
 CONSTRAINT [PK_IvFluidChart] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Lab]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lab](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LabName] [varchar](50) NULL,
	[Active] [bit] NULL,
	[LabLogin] [varchar](10) NULL,
	[LabPassword] [varchar](10) NULL,
 CONSTRAINT [PK_Lab] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Medication]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Medication](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LabId] [int] NULL,
	[Name] [varchar](50) NULL,
 CONSTRAINT [PK_Medication] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MedicationPrnAdministration]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedicationPrnAdministration](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LabId] [int] NULL,
	[PatientId] [int] NULL,
	[PatientMedicationChartId] [int] NULL,
	[DoseDate] [date] NULL,
	[DoseTime] [varchar](50) NULL,
	[Route] [varchar](50) NULL,
	[StudentSign] [varchar](50) NULL,
	[Reason] [varchar](200) NULL,
	[CoSign] [varchar](50) NULL,
	[Dose] [varchar](50) NULL,
 CONSTRAINT [PK_MedicationAdministration] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MedicationPrnChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedicationPrnChart](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LabId] [int] NULL,
	[PatientId] [int] NULL,
	[MedicationId] [int] NULL,
	[Dose] [varchar](50) NULL,
	[DoseFrequency] [varchar](50) NULL,
	[DoseDate] [date] NULL,
	[DoseTime] [varchar](50) NULL,
	[Indication] [varchar](50) NULL,
	[Route] [varchar](50) NULL,
	[Pharmacy] [varchar](50) NULL,
	[Prescriber] [varchar](50) NULL,
	[PrescriberSign] [varchar](50) NULL,
 CONSTRAINT [PK_PatientMedicationChart] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MedicationRegularAdministration]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedicationRegularAdministration](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LabId] [int] NULL,
	[PatientId] [int] NULL,
	[PatientMedicationChartId] [int] NULL,
	[DoseDate] [date] NULL,
	[DoseTime] [varchar](50) NULL,
	[Route] [varchar](50) NULL,
	[StudentSign] [varchar](50) NULL,
	[Reason] [varchar](200) NULL,
	[CoSign] [varchar](50) NULL,
	[Dose] [varchar](50) NULL,
 CONSTRAINT [PK_MedicationRegularAdministration] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MedicationRegularChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedicationRegularChart](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LabId] [int] NULL,
	[PatientId] [int] NULL,
	[MedicationId] [int] NULL,
	[Dose] [varchar](50) NULL,
	[DoseFrequency] [varchar](50) NULL,
	[DoseDate] [date] NULL,
	[DoseTime] [varchar](50) NULL,
	[Indication] [varchar](50) NULL,
	[Route] [varchar](50) NULL,
	[Pharmacy] [varchar](50) NULL,
	[Prescriber] [varchar](50) NULL,
	[PrescriberSign] [varchar](50) NULL,
 CONSTRAINT [PK_MedicationRegularChart] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Module]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Module](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UnitId] [int] NOT NULL,
	[ModuleName] [varchar](150) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[SortOrder] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[CreatedBySupervisorId] [int] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_Module] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NeurologicalAdministration]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NeurologicalAdministration](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LabId] [int] NULL,
	[PatientId] [int] NULL,
	[NeurologicalChartId] [int] NULL,
	[StartDate] [date] NULL,
	[StartTime] [varchar](50) NULL,
	[EndDate] [date] NULL,
	[EndTime] [varchar](50) NULL,
	[PharmacistReview] [varchar](200) NULL,
	[NurseSign] [varchar](50) NULL,
	[CoSign] [varchar](50) NULL,
 CONSTRAINT [PK_NeurologicalAdministration] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NeurologicalChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NeurologicalChart](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LabId] [int] NULL,
	[PatientId] [int] NULL,
	[Date] [date] NULL,
	[Time] [time](7) NULL,
	[EyesOpenScore] [int] NULL,
	[VerbalResponseScore] [varchar](1) NULL,
	[MotorResponseScore] [int] NULL,
	[TotalComaScale] [int] NULL,
	[EndotrachealTube] [bit] NULL,
	[RightPupilSize] [int] NULL,
	[RightPupilReaction] [varchar](50) NULL,
	[LeftPupilSize] [int] NULL,
	[LeftPupilReaction] [varchar](50) NULL,
	[RightArmResponse] [varchar](50) NULL,
	[RightLegResponse] [varchar](50) NULL,
	[LeftArmResponse] [varchar](50) NULL,
	[LeftLegResponse] [varchar](50) NULL,
	[OfficerSign] [varchar](50) NULL,
 CONSTRAINT [PK_NeurologicalChart] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NeurologicalObservationOptions]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NeurologicalObservationOptions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[category] [varchar](50) NOT NULL,
	[value] [varchar](50) NOT NULL,
	[description] [varchar](255) NULL,
 CONSTRAINT [PK_NeurologicalObservationOptions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Patient]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Patient](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[DateOfBirth] [datetime] NULL,
	[Gender] [varchar](10) NULL,
	[Address] [nvarchar](200) NULL,
	[AdmitDate] [datetime] NULL,
	[Weight] [varchar](10) NULL,
	[Height] [varchar](10) NULL,
	[Age] [varchar](10) NULL,
	[Allergy] [varchar](200) NULL,
	[Intolerance] [varchar](200) NULL,
	[Alerts] [varchar](200) NULL,
	[LabId] [int] NULL,
	[UriNumber] [varchar](50) NULL,
	[Alert] [int] NULL,
	[ModuleId] [int] NULL,
	[SourceModuleId] [int] NULL,
	[LoadedIntoLabAt] [datetime] NULL,
 CONSTRAINT [PK_Patient] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PatientAdds]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PatientAdds](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PatientId] [int] NOT NULL,
	[EnteredDate] [date] NOT NULL,
	[EnteredTime] [varchar](20) NOT NULL,
	[RespiratoryRate] [varchar](20) NULL,
	[HeartRate] [varchar](20) NULL,
	[Temperature] [varchar](20) NULL,
	[Consciousness] [varchar](50) NULL,
	[OxygenSaturation] [varchar](20) NULL,
	[OxygenFlow] [varchar](20) NULL,
	[BloodPressure] [varchar](20) NULL,
	[LabId] [int] NULL,
	[RespiratoryRateValue] [int] NULL,
	[OxygenSaturationValue] [int] NULL,
	[BloodPressureValue] [int] NULL,
	[HeartRateValue] [int] NULL,
	[TemperatureValue] [int] NULL,
	[RespiratoryAlert] [int] NULL,
	[OxygenSaturationAlert] [int] NULL,
	[BloodPressureAlert] [int] NULL,
	[HeartRateAlert] [int] NULL,
	[ConsciousnessAlert] [int] NULL,
	[TotalScore] [int] NULL,
	[BloodPressureDiastolicValue] [int] NULL,
	[BloodPressureDiastolic] [varchar](20) NULL,
	[ModeOfDelivery] [varchar](50) NULL,
 CONSTRAINT [PK_ADDS] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Policies]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Policies](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LabId] [int] NOT NULL,
	[FileName] [nvarchar](255) NOT NULL,
	[DisplayName] [nvarchar](255) NOT NULL,
	[FileSizeString] [nvarchar](50) NOT NULL,
	[FileData] [varbinary](max) NOT NULL,
	[UploadedDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProgressNotes]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProgressNotes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LabId] [int] NULL,
	[Notes] [text] NULL,
	[Sign] [varchar](50) NULL,
	[NotesDate] [datetime] NULL,
	[PatientId] [int] NULL,
	[NotesFrom] [varchar](10) NULL,
 CONSTRAINT [PK_PatientProgressNotes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RiskmanIncident]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RiskmanIncident](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LabId] [int] NOT NULL,
	[PatientId] [int] NOT NULL,
	[IncidentDate] [date] NULL,
	[IncidentTime] [nvarchar](50) NULL,
	[URINumber] [nvarchar](50) NULL,
	[Campus] [nvarchar](50) NULL,
	[WardLocationType] [nvarchar](100) NULL,
	[PersonName] [nvarchar](100) NULL,
	[DateOfBirth] [date] NULL,
	[Sex] [nvarchar](40) NULL,
	[IndigenousStatus] [nvarchar](120) NULL,
	[BriefSummary] [nvarchar](200) NULL,
	[Details] [nvarchar](max) NULL,
	[EventType] [nvarchar](60) NULL,
	[EventSubType] [nvarchar](200) NULL,
	[IsClinicalIncident] [bit] NULL,
	[ClinicalHarmLevel] [nvarchar](20) NULL,
	[HarmDuration] [nvarchar](20) NULL,
	[RequiredCareLevelClinical] [nvarchar](40) NULL,
	[EmergencyResponseType] [nvarchar](40) NULL,
	[EmergencyResponseOutcome] [nvarchar](80) NULL,
	[ContributingAdditionalDetail] [nvarchar](max) NULL,
	[ReporterIsAffectedStaff] [bit] NULL,
	[OhsTypeOfInjury] [nvarchar](80) NULL,
	[OhsTypeOfInjuryOther] [nvarchar](120) NULL,
	[OhsBodyPartAffected] [nvarchar](80) NULL,
	[OhsBodyPartOther] [nvarchar](120) NULL,
	[OhsLevelOfHarmSustained] [nvarchar](40) NULL,
	[OhsRequiredLevelOfCare] [nvarchar](80) NULL,
	[OhsActionsRequired] [nvarchar](max) NULL,
	[nextOfKinNotifiedDate] [date] NULL,
	[nextOfKinNotifiedTime] [nvarchar](50) NULL,
	[SignedBy] [nvarchar](100) NULL,
	[SignedDate] [date] NULL,
	[Apse] [bit] NULL,
 CONSTRAINT [PK__RiskmanI__3214EC07AA12A9B5] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RiskmanIncidentContributingFactor]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RiskmanIncidentContributingFactor](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IncidentId] [int] NOT NULL,
	[FactorCode] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Supervisor]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Supervisor](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](50) NULL,
	[UserLogin] [varchar](10) NULL,
	[UserPassword] [varchar](10) NULL,
	[LabId] [int] NULL,
 CONSTRAINT [PK_Supervisor] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Unit]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Unit](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[YearLevelId] [int] NOT NULL,
	[UnitCode] [varchar](20) NULL,
	[UnitName] [varchar](100) NOT NULL,
	[SortOrder] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Unit] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[YearLevel]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[YearLevel](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[YearLevelName] [varchar](50) NOT NULL,
	[SortOrder] [int] NOT NULL,
	[Active] [bit] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_YearLevel] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_Module_UnitId]    Script Date: 14-Aug-26 6:02:50 PM ******/
CREATE NONCLUSTERED INDEX [IX_Module_UnitId] ON [dbo].[Module]
(
	[UnitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Patient_ModuleId]    Script Date: 14-Aug-26 6:02:50 PM ******/
CREATE NONCLUSTERED INDEX [IX_Patient_ModuleId] ON [dbo].[Patient]
(
	[ModuleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Patient_SourceModuleId_LabId]    Script Date: 14-Aug-26 6:02:50 PM ******/
CREATE NONCLUSTERED INDEX [IX_Patient_SourceModuleId_LabId] ON [dbo].[Patient]
(
	[SourceModuleId] ASC,
	[LabId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Unit_YearLevelId]    Script Date: 14-Aug-26 6:02:50 PM ******/
CREATE NONCLUSTERED INDEX [IX_Unit_YearLevelId] ON [dbo].[Unit]
(
	[YearLevelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FallRiskAssessments] ADD  DEFAULT (sysutcdatetime()) FOR [AssessedAt]
GO
ALTER TABLE [dbo].[FluidBalanceChart] ADD  DEFAULT ((0)) FOR [PreviousDayBalance]
GO
ALTER TABLE [dbo].[FluidBalanceChart] ADD  DEFAULT ((0)) FOR [TotalIntake]
GO
ALTER TABLE [dbo].[FluidBalanceChart] ADD  DEFAULT ((0)) FOR [TotalOutput]
GO
ALTER TABLE [dbo].[FluidBalanceChart] ADD  DEFAULT ((0)) FOR [Balance]
GO
ALTER TABLE [dbo].[FluidBalanceChart] ADD  DEFAULT ((0)) FOR [TotalBalance]
GO
ALTER TABLE [dbo].[FluidBalanceChart] ADD  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [dbo].[FluidBalanceChartEntry] ADD  DEFAULT (getdate()) FOR [CreatedDateTime]
GO
ALTER TABLE [dbo].[FluidBalanceChartEntry] ADD  DEFAULT (CONVERT([date],getdate())) FOR [EntryDate]
GO
ALTER TABLE [dbo].[Module] ADD  CONSTRAINT [DF_Module_SortOrder]  DEFAULT ((0)) FOR [SortOrder]
GO
ALTER TABLE [dbo].[Module] ADD  CONSTRAINT [DF_Module_Active]  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [dbo].[Module] ADD  CONSTRAINT [DF_Module_Created]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Unit] ADD  CONSTRAINT [DF_Unit_SortOrder]  DEFAULT ((0)) FOR [SortOrder]
GO
ALTER TABLE [dbo].[Unit] ADD  CONSTRAINT [DF_Unit_Active]  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [dbo].[Unit] ADD  CONSTRAINT [DF_Unit_Created]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[YearLevel] ADD  CONSTRAINT [DF_YearLevel_SortOrder]  DEFAULT ((0)) FOR [SortOrder]
GO
ALTER TABLE [dbo].[YearLevel] ADD  CONSTRAINT [DF_YearLevel_Active]  DEFAULT ((1)) FOR [Active]
GO
ALTER TABLE [dbo].[YearLevel] ADD  CONSTRAINT [DF_YearLevel_Created]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[FluidBalanceChartEntry]  WITH CHECK ADD  CONSTRAINT [FK_FluidBalanceChartEntry_FluidBalanceChart] FOREIGN KEY([FluidBalanceChartId])
REFERENCES [dbo].[FluidBalanceChart] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FluidBalanceChartEntry] CHECK CONSTRAINT [FK_FluidBalanceChartEntry_FluidBalanceChart]
GO
ALTER TABLE [dbo].[FoodIntakeItem]  WITH CHECK ADD  CONSTRAINT [FK__FoodIntak__Heade__62AFA012] FOREIGN KEY([HeaderId])
REFERENCES [dbo].[FoodIntakeHeader] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FoodIntakeItem] CHECK CONSTRAINT [FK__FoodIntak__Heade__62AFA012]
GO
ALTER TABLE [dbo].[Module]  WITH CHECK ADD  CONSTRAINT [FK_Module_Unit] FOREIGN KEY([UnitId])
REFERENCES [dbo].[Unit] ([Id])
GO
ALTER TABLE [dbo].[Module] CHECK CONSTRAINT [FK_Module_Unit]
GO
ALTER TABLE [dbo].[Patient]  WITH NOCHECK ADD  CONSTRAINT [FK_Patient_Module] FOREIGN KEY([ModuleId])
REFERENCES [dbo].[Module] ([Id])
GO
ALTER TABLE [dbo].[Patient] CHECK CONSTRAINT [FK_Patient_Module]
GO
ALTER TABLE [dbo].[RiskmanIncidentContributingFactor]  WITH CHECK ADD  CONSTRAINT [FK_RICF_RiskmanIncident] FOREIGN KEY([IncidentId])
REFERENCES [dbo].[RiskmanIncident] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RiskmanIncidentContributingFactor] CHECK CONSTRAINT [FK_RICF_RiskmanIncident]
GO
ALTER TABLE [dbo].[Unit]  WITH CHECK ADD  CONSTRAINT [FK_Unit_YearLevel] FOREIGN KEY([YearLevelId])
REFERENCES [dbo].[YearLevel] ([Id])
GO
ALTER TABLE [dbo].[Unit] CHECK CONSTRAINT [FK_Unit_YearLevel]
GO
/****** Object:  StoredProcedure [dbo].[ClearLabData]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ClearLabData]
    @LabId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare a table variable to store the results
    DECLARE @DeletedRowsSummary TABLE (
		TableName NVARCHAR(100),
        RowsDeleted INT
		);

    DECLARE @RowsDeleted INT;

    -- Delete from IvFluidChart
    DELETE FROM [dbo].[IvFluidChart]
    WHERE LabId = @LabId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedRowsSummary (TableName, RowsDeleted) VALUES ('Iv Fluid Chart', @RowsDeleted);

    -- Delete from MedicationPrnChart
    DELETE FROM [dbo].[MedicationPrnChart]
    WHERE LabId = @LabId
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedRowsSummary (TableName, RowsDeleted) VALUES ('PRN Medication Chart', @RowsDeleted);

    -- Delete from MedicationRegularChart
    DELETE FROM [dbo].[MedicationRegularChart]
    WHERE LabId = @LabId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedRowsSummary (TableName, RowsDeleted) VALUES ('Regular Medication Chart', @RowsDeleted);

    -- Delete from PatientAdds
    DELETE FROM [dbo].[PatientAdds]
    WHERE LabId = @LabId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedRowsSummary (TableName, RowsDeleted) VALUES ('Student Patient Adds', @RowsDeleted);

    -- Delete from IvFluidAdministration
    DELETE FROM [dbo].[IvFluidAdministration]
    WHERE LabId = @LabId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedRowsSummary (TableName, RowsDeleted) VALUES ('Student Iv Fluid', @RowsDeleted);

    -- Delete from MedicationPrnAdministration
    DELETE FROM [dbo].[MedicationPrnAdministration]
    WHERE LabId = @LabId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedRowsSummary (TableName, RowsDeleted) VALUES ('Student PRN Medication', @RowsDeleted);

    -- Delete from MedicationRegularAdministration
    DELETE FROM [dbo].[MedicationRegularAdministration]
    WHERE LabId = @LabId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedRowsSummary (TableName, RowsDeleted) VALUES ('Student Regular Medication', @RowsDeleted);

    -- Delete from ProgressNotes
    DELETE FROM [dbo].[ProgressNotes]
    WHERE LabId = @LabId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedRowsSummary (TableName, RowsDeleted) VALUES ('Student Progress Notes', @RowsDeleted);

	UPDATE Patient SET Alert = 0 WHERE LabId = @LabId

    -- Return the summary table
    SELECT * FROM @DeletedRowsSummary;
END;

GO
/****** Object:  StoredProcedure [dbo].[ClearPatientData]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ClearPatientData]

	@LabId INT,
    @PatientId INT
AS
BEGIN
    SET NOCOUNT ON;

	SET NOCOUNT ON;

    DECLARE @DeletedTables TABLE (
		TableName NVARCHAR(100), 
		RowsDeleted INT
		);

    -- Delete from IvFluidAdministration and track rows affected
    DECLARE @RowsDeleted INT;

    DELETE FROM [dbo].[FallRiskAssessments]
	WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student Fall Risk Assessments', @RowsDeleted);

    DELETE FROM [dbo].[BradenAssessment]
	WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student Braden Assessment', @RowsDeleted);

    DELETE FROM [dbo].[NeurologicalAdministration]
	WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student Neurological Administration', @RowsDeleted);

    DELETE FROM [dbo].[FoodIntakeHeader]
	WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student Food Intake', @RowsDeleted);

    DELETE FROM [dbo].[IvFluidAdministration]
	WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student Iv Fluid', @RowsDeleted);

    -- Delete from MedicationPrnAdministration and track rows affected
    DELETE FROM [dbo].[MedicationPrnAdministration]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student PRN Medication', @RowsDeleted);

    -- Delete from MedicationRegularAdministration and track rows affected
    DELETE FROM [dbo].[MedicationRegularAdministration]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student Regular Medication', @RowsDeleted);

    -- Delete from PatientAdds and track rows affected
    DELETE FROM [dbo].[PatientAdds]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId;
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student Patient Adds', @RowsDeleted);

	-- Delete from Patient Progress Notes and track rows affected
    DELETE FROM [dbo].[ProgressNotes]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @PatientId
	AND NotesFrom = 'student'
    SET @RowsDeleted = @@ROWCOUNT;
    INSERT INTO @DeletedTables (TableName, RowsDeleted) VALUES ('Student Progress Notes', @RowsDeleted);

	UPDATE Patient SET Alert = 0 WHERE Id = @PatientId

    -- Return the list of deleted tables and number of rows deleted
    SELECT * FROM @DeletedTables;
END
GO
/****** Object:  StoredProcedure [dbo].[ClearPatientDataSelective]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ClearPatientDataSelective]

    @LabId          INT,
    @PatientId      INT,
    @FallRisk       BIT = 0,
    @Braden         BIT = 0,
    @Neuro          BIT = 0,
    @FoodIntake     BIT = 0,
    @IvFluid        BIT = 0,
    @Prn            BIT = 0,
    @Regular        BIT = 0,
    @PatientAdds    BIT = 0,
    @ProgressNotes  BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DeletedTables TABLE (TableName NVARCHAR(100), RowsDeleted INT);
    DECLARE @RowsDeleted INT;

    IF @FallRisk = 1
    BEGIN
        DELETE FROM [dbo].[FallRiskAssessments] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId;
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student Fall Risk Assessments', @RowsDeleted);
    END

    IF @Braden = 1
    BEGIN
        DELETE FROM [dbo].[BradenAssessment] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId;
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student Braden Assessment', @RowsDeleted);
    END

    IF @Neuro = 1
    BEGIN
        DELETE FROM [dbo].[NeurologicalAdministration] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId;
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student Neurological Administration', @RowsDeleted);
    END

    IF @FoodIntake = 1
    BEGIN
        DELETE FROM [dbo].[FoodIntakeHeader] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId;
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student Food Intake', @RowsDeleted);
    END

    IF @IvFluid = 1
    BEGIN
        DELETE FROM [dbo].[IvFluidAdministration] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId;
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student Iv Fluid', @RowsDeleted);
    END

    IF @Prn = 1
    BEGIN
        DELETE FROM [dbo].[MedicationPrnAdministration] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId;
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student PRN Medication', @RowsDeleted);
    END

    IF @Regular = 1
    BEGIN
        DELETE FROM [dbo].[MedicationRegularAdministration] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId;
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student Regular Medication', @RowsDeleted);
    END

    IF @PatientAdds = 1
    BEGIN
        DELETE FROM [dbo].[PatientAdds] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId;
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student Patient Adds', @RowsDeleted);
    END

    IF @ProgressNotes = 1
    BEGIN
        DELETE FROM [dbo].[ProgressNotes] WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId AND NotesFrom = 'student';
        SET @RowsDeleted = @@ROWCOUNT;
        INSERT INTO @DeletedTables VALUES ('Student Progress Notes', @RowsDeleted);
    END

    -- Only reset the alert flag on a complete clear (all 9 selected)
    IF (@FallRisk = 1 AND @Braden = 1 AND @Neuro = 1 AND @FoodIntake = 1 AND @IvFluid = 1
        AND @Prn = 1 AND @Regular = 1 AND @PatientAdds = 1 AND @ProgressNotes = 1)
    BEGIN
        UPDATE Patient SET Alert = 0 WHERE Id = @PatientId;
    END

    SELECT * FROM @DeletedTables;
END
GO
/****** Object:  StoredProcedure [dbo].[CopyModule]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CopyModule]
    @SourceModuleId        INT,
    @NewModuleName         VARCHAR(150),
    @TargetUnitId          INT = 0,          -- 0 = same unit as the source
    @Description           NVARCHAR(500) = NULL,
    @CreatedBySupervisorId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Module] WHERE [Id] = @SourceModuleId)
    BEGIN
        RAISERROR('Source module %d does not exist.', 16, 1, @SourceModuleId);
        RETURN;
    END

    DECLARE @NewModuleId INT;
    DECLARE @UnitId      INT;
    DECLARE @SrcDesc     NVARCHAR(500);

    /* Module-owned rows are not tied to any campus. LabId 0 is the marker:
       dbo.Lab.Id is IDENTITY(1,1) so 0 can never match a real lab, and unlike
       NULL it is accepted by BradenAssessment, FallRiskAssessments,
       FoodIntakeHeader and RiskmanIncident, whose LabId columns are NOT NULL. */
    DECLARE @ModuleLabId INT = 0;

    SELECT @UnitId  = CASE WHEN @TargetUnitId = 0 THEN [UnitId] ELSE @TargetUnitId END,
           @SrcDesc = [Description]
    FROM   [dbo].[Module] WHERE [Id] = @SourceModuleId;

    /* old -> new key maps */
    DECLARE @MapPatient  TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapFbc      TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapFood     TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapIvChart  TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapRegChart TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapPrnChart TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapNeuro    TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapRiskman  TABLE (OldId INT PRIMARY KEY, NewId INT);

    BEGIN TRAN;

    /* --- 1. the module row ------------------------------------------------ */
    INSERT INTO [dbo].[Module]
        ([UnitId], [ModuleName], [Description], [SortOrder], [CreatedBySupervisorId])
    SELECT @UnitId, @NewModuleName, ISNULL(@Description, @SrcDesc), [SortOrder], @CreatedBySupervisorId
    FROM   [dbo].[Module] WHERE [Id] = @SourceModuleId;

    SET @NewModuleId = CAST(SCOPE_IDENTITY() AS INT);

    /* --- 2. patients ------------------------------------------------------ */
    SELECT * INTO #SrcPatient
    FROM [dbo].[Patient] WHERE [ModuleId] = @SourceModuleId;

    MERGE INTO [dbo].[Patient] AS tgt
    USING #SrcPatient AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([FirstName], [LastName], [DateOfBirth], [Gender], [Address], [AdmitDate],
                [Weight], [Height], [Age], [Allergy], [Intolerance], [Alerts],
                [LabId], [UriNumber], [Alert], [ModuleId])
        VALUES (src.[FirstName], src.[LastName], src.[DateOfBirth], src.[Gender], src.[Address], src.[AdmitDate],
                src.[Weight], src.[Height], src.[Age], src.[Allergy], src.[Intolerance], src.[Alerts],
                @ModuleLabId, src.[UriNumber], src.[Alert], @NewModuleId)
    OUTPUT src.[Id], inserted.[Id] INTO @MapPatient (OldId, NewId);

    /* --- 3. patient-level charts with no children ------------------------- */
    INSERT INTO [dbo].[BradenAssessment]
        ([LabId], [PatientId], [DateOfAssessment], [NurseInitials], [Sensory], [Moisture],
         [Activity], [Mobility], [Nutrition], [Friction], [TotalScore], [RiskKey], [Shift])
    SELECT @ModuleLabId, mp.NewId, s.[DateOfAssessment], s.[NurseInitials], s.[Sensory], s.[Moisture],
           s.[Activity], s.[Mobility], s.[Nutrition], s.[Friction], s.[TotalScore], s.[RiskKey], s.[Shift]
    FROM [dbo].[BradenAssessment] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    INSERT INTO [dbo].[FallRiskAssessments]
        ([LabId], [PatientId], [RecentFallsScore], [MedicationsScore], [PsychologicalScore],
         [CognitiveScore], [TotalScore], [RiskLevel], [AssessedAt], [Assessor], [Notes],
         [AutoCondChange], [AutoDizziness], [AutoAnaesthetic], [InterventionNotes])
    SELECT @ModuleLabId, mp.NewId, s.[RecentFallsScore], s.[MedicationsScore], s.[PsychologicalScore],
           s.[CognitiveScore], s.[TotalScore], s.[RiskLevel], s.[AssessedAt], s.[Assessor], s.[Notes],
           s.[AutoCondChange], s.[AutoDizziness], s.[AutoAnaesthetic], s.[InterventionNotes]
    FROM [dbo].[FallRiskAssessments] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    INSERT INTO [dbo].[PatientAdds]
        ([PatientId], [EnteredDate], [EnteredTime], [RespiratoryRate], [HeartRate], [Temperature],
         [Consciousness], [OxygenSaturation], [OxygenFlow], [ModeOfDelivery], [BloodPressure], [LabId],
         [RespiratoryRateValue], [OxygenSaturationValue], [BloodPressureValue], [HeartRateValue],
         [TemperatureValue], [RespiratoryAlert], [OxygenSaturationAlert], [BloodPressureAlert],
         [HeartRateAlert], [ConsciousnessAlert], [TotalScore], [BloodPressureDiastolicValue],
         [BloodPressureDiastolic])
    SELECT mp.NewId, s.[EnteredDate], s.[EnteredTime], s.[RespiratoryRate], s.[HeartRate], s.[Temperature],
           s.[Consciousness], s.[OxygenSaturation], s.[OxygenFlow], s.[ModeOfDelivery], s.[BloodPressure], @ModuleLabId,
           s.[RespiratoryRateValue], s.[OxygenSaturationValue], s.[BloodPressureValue], s.[HeartRateValue],
           s.[TemperatureValue], s.[RespiratoryAlert], s.[OxygenSaturationAlert], s.[BloodPressureAlert],
           s.[HeartRateAlert], s.[ConsciousnessAlert], s.[TotalScore], s.[BloodPressureDiastolicValue],
           s.[BloodPressureDiastolic]
    FROM [dbo].[PatientAdds] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    INSERT INTO [dbo].[ProgressNotes]
        ([LabId], [Notes], [Sign], [NotesDate], [PatientId], [NotesFrom])
    SELECT @ModuleLabId, s.[Notes], s.[Sign], s.[NotesDate], mp.NewId, s.[NotesFrom]
    FROM [dbo].[ProgressNotes] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    /* --- 4. fluid balance chart + entries --------------------------------- */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcFbc
    FROM [dbo].[FluidBalanceChart] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[FluidBalanceChart] AS tgt
    USING #SrcFbc AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [ChartDate], [ChartTime], [PreviousDayBalance],
                [TotalIntake], [TotalOutput], [Balance], [TotalBalance], [ClinicalNotes],
                [SignatureData], [CreatedDateTime], [UpdatedDateTime])
        VALUES (@ModuleLabId, src.NewPatientId, src.[ChartDate], src.[ChartTime], src.[PreviousDayBalance],
                src.[TotalIntake], src.[TotalOutput], src.[Balance], src.[TotalBalance], src.[ClinicalNotes],
                src.[SignatureData], src.[CreatedDateTime], src.[UpdatedDateTime])
    OUTPUT src.[Id], inserted.[Id] INTO @MapFbc (OldId, NewId);

    INSERT INTO [dbo].[FluidBalanceChartEntry]
        ([FluidBalanceChartId], [EntryTime], [EntryType], [Category], [AmountMl],
         [CreatedDateTime], [EntryDate], [Initials])
    SELECT mf.NewId, s.[EntryTime], s.[EntryType], s.[Category], s.[AmountMl],
           s.[CreatedDateTime], s.[EntryDate], s.[Initials]
    FROM [dbo].[FluidBalanceChartEntry] s
    INNER JOIN @MapFbc mf ON mf.OldId = s.[FluidBalanceChartId];

    /* --- 5. food intake header + items ------------------------------------ */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcFood
    FROM [dbo].[FoodIntakeHeader] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[FoodIntakeHeader] AS tgt
    USING #SrcFood AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [DayText], [IntakeDate],
                [Shift1Signature], [Shift1Designation], [Shift2Signature], [Shift2Designation],
                [Shift3Signature], [Shift3Designation], [BreakfastComment], [MorningTeaComment],
                [LunchComment], [AfternoonTeaComment], [DinnerComment], [SupperComment])
        VALUES (@ModuleLabId, src.NewPatientId, src.[DayText], src.[IntakeDate],
                src.[Shift1Signature], src.[Shift1Designation], src.[Shift2Signature], src.[Shift2Designation],
                src.[Shift3Signature], src.[Shift3Designation], src.[BreakfastComment], src.[MorningTeaComment],
                src.[LunchComment], src.[AfternoonTeaComment], src.[DinnerComment], src.[SupperComment])
    OUTPUT src.[Id], inserted.[Id] INTO @MapFood (OldId, NewId);

    INSERT INTO [dbo].[FoodIntakeItem] ([HeaderId], [Meal], [Label], [Notes], [Amount])
    SELECT mh.NewId, s.[Meal], s.[Label], s.[Notes], s.[Amount]
    FROM [dbo].[FoodIntakeItem] s
    INNER JOIN @MapFood mh ON mh.OldId = s.[HeaderId];

    /* --- 6. IV fluid chart + administrations ------------------------------ */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcIvChart
    FROM [dbo].[IvFluidChart] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[IvFluidChart] AS tgt
    USING #SrcIvChart AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [Date], [FlaskVol], [Strength], [Rate], [Dose], [OfficerSign])
        VALUES (@ModuleLabId, src.NewPatientId, src.[Date], src.[FlaskVol], src.[Strength], src.[Rate], src.[Dose], src.[OfficerSign])
    OUTPUT src.[Id], inserted.[Id] INTO @MapIvChart (OldId, NewId);

    INSERT INTO [dbo].[IvFluidAdministration]
        ([LabId], [PatientId], [IvFluidChartId], [StartDate], [StartTime], [EndDate], [EndTime],
         [VolGiven], [PharmacistReview], [NurseSign], [CoSign])
    SELECT @ModuleLabId, mp.NewId, mc.NewId, s.[StartDate], s.[StartTime], s.[EndDate], s.[EndTime],
           s.[VolGiven], s.[PharmacistReview], s.[NurseSign], s.[CoSign]
    FROM [dbo].[IvFluidAdministration] s
    INNER JOIN @MapIvChart mc ON mc.OldId = s.[IvFluidChartId]
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    /* --- 7. regular medication chart + administrations -------------------- */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcRegChart
    FROM [dbo].[MedicationRegularChart] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[MedicationRegularChart] AS tgt
    USING #SrcRegChart AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [MedicationId], [Dose], [DoseFrequency], [DoseDate], [DoseTime],
                [Indication], [Route], [Pharmacy], [Prescriber], [PrescriberSign])
        VALUES (@ModuleLabId, src.NewPatientId, src.[MedicationId], src.[Dose], src.[DoseFrequency], src.[DoseDate], src.[DoseTime],
                src.[Indication], src.[Route], src.[Pharmacy], src.[Prescriber], src.[PrescriberSign])
    OUTPUT src.[Id], inserted.[Id] INTO @MapRegChart (OldId, NewId);

    INSERT INTO [dbo].[MedicationRegularAdministration]
        ([LabId], [PatientId], [PatientMedicationChartId], [DoseDate], [DoseTime], [Route],
         [StudentSign], [Reason], [CoSign], [Dose])
    SELECT @ModuleLabId, mp.NewId, mc.NewId, s.[DoseDate], s.[DoseTime], s.[Route],
           s.[StudentSign], s.[Reason], s.[CoSign], s.[Dose]
    FROM [dbo].[MedicationRegularAdministration] s
    INNER JOIN @MapRegChart mc ON mc.OldId = s.[PatientMedicationChartId]
    INNER JOIN @MapPatient  mp ON mp.OldId = s.[PatientId];

    /* --- 8. PRN medication chart + administrations ------------------------ */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcPrnChart
    FROM [dbo].[MedicationPrnChart] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[MedicationPrnChart] AS tgt
    USING #SrcPrnChart AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [MedicationId], [Dose], [DoseFrequency], [DoseDate], [DoseTime],
                [Indication], [Route], [Pharmacy], [Prescriber], [PrescriberSign])
        VALUES (@ModuleLabId, src.NewPatientId, src.[MedicationId], src.[Dose], src.[DoseFrequency], src.[DoseDate], src.[DoseTime],
                src.[Indication], src.[Route], src.[Pharmacy], src.[Prescriber], src.[PrescriberSign])
    OUTPUT src.[Id], inserted.[Id] INTO @MapPrnChart (OldId, NewId);

    INSERT INTO [dbo].[MedicationPrnAdministration]
        ([LabId], [PatientId], [PatientMedicationChartId], [DoseDate], [DoseTime], [Route],
         [StudentSign], [Reason], [CoSign], [Dose])
    SELECT @ModuleLabId, mp.NewId, mc.NewId, s.[DoseDate], s.[DoseTime], s.[Route],
           s.[StudentSign], s.[Reason], s.[CoSign], s.[Dose]
    FROM [dbo].[MedicationPrnAdministration] s
    INNER JOIN @MapPrnChart mc ON mc.OldId = s.[PatientMedicationChartId]
    INNER JOIN @MapPatient  mp ON mp.OldId = s.[PatientId];

    /* --- 9. neurological chart + administrations -------------------------- */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcNeuro
    FROM [dbo].[NeurologicalChart] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[NeurologicalChart] AS tgt
    USING #SrcNeuro AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [Date], [Time], [EyesOpenScore], [VerbalResponseScore],
                [MotorResponseScore], [TotalComaScale], [EndotrachealTube], [RightPupilSize],
                [RightPupilReaction], [LeftPupilSize], [LeftPupilReaction], [RightArmResponse],
                [RightLegResponse], [LeftArmResponse], [LeftLegResponse], [OfficerSign])
        VALUES (@ModuleLabId, src.NewPatientId, src.[Date], src.[Time], src.[EyesOpenScore], src.[VerbalResponseScore],
                src.[MotorResponseScore], src.[TotalComaScale], src.[EndotrachealTube], src.[RightPupilSize],
                src.[RightPupilReaction], src.[LeftPupilSize], src.[LeftPupilReaction], src.[RightArmResponse],
                src.[RightLegResponse], src.[LeftArmResponse], src.[LeftLegResponse], src.[OfficerSign])
    OUTPUT src.[Id], inserted.[Id] INTO @MapNeuro (OldId, NewId);

    INSERT INTO [dbo].[NeurologicalAdministration]
        ([LabId], [PatientId], [NeurologicalChartId], [StartDate], [StartTime], [EndDate], [EndTime],
         [PharmacistReview], [NurseSign], [CoSign])
    SELECT @ModuleLabId, mp.NewId, mc.NewId, s.[StartDate], s.[StartTime], s.[EndDate], s.[EndTime],
           s.[PharmacistReview], s.[NurseSign], s.[CoSign]
    FROM [dbo].[NeurologicalAdministration] s
    INNER JOIN @MapNeuro   mc ON mc.OldId = s.[NeurologicalChartId]
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    /* --- 10. riskman incident + contributing factors ---------------------- */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcRiskman
    FROM [dbo].[RiskmanIncident] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[RiskmanIncident] AS tgt
    USING #SrcRiskman AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [IncidentDate], [IncidentTime], [URINumber], [Campus],
                [WardLocationType], [PersonName], [DateOfBirth], [Sex], [IndigenousStatus],
                [BriefSummary], [Details], [EventType], [EventSubType], [IsClinicalIncident],
                [ClinicalHarmLevel], [HarmDuration], [RequiredCareLevelClinical],
                [EmergencyResponseType], [EmergencyResponseOutcome], [ContributingAdditionalDetail],
                [ReporterIsAffectedStaff], [OhsTypeOfInjury], [OhsTypeOfInjuryOther],
                [OhsBodyPartAffected], [OhsBodyPartOther], [OhsLevelOfHarmSustained],
                [OhsRequiredLevelOfCare], [OhsActionsRequired], [nextOfKinNotifiedDate],
                [nextOfKinNotifiedTime], [SignedBy], [SignedDate], [Apse])
        VALUES (@ModuleLabId, src.NewPatientId, src.[IncidentDate], src.[IncidentTime], src.[URINumber], src.[Campus],
                src.[WardLocationType], src.[PersonName], src.[DateOfBirth], src.[Sex], src.[IndigenousStatus],
                src.[BriefSummary], src.[Details], src.[EventType], src.[EventSubType], src.[IsClinicalIncident],
                src.[ClinicalHarmLevel], src.[HarmDuration], src.[RequiredCareLevelClinical],
                src.[EmergencyResponseType], src.[EmergencyResponseOutcome], src.[ContributingAdditionalDetail],
                src.[ReporterIsAffectedStaff], src.[OhsTypeOfInjury], src.[OhsTypeOfInjuryOther],
                src.[OhsBodyPartAffected], src.[OhsBodyPartOther], src.[OhsLevelOfHarmSustained],
                src.[OhsRequiredLevelOfCare], src.[OhsActionsRequired], src.[nextOfKinNotifiedDate],
                src.[nextOfKinNotifiedTime], src.[SignedBy], src.[SignedDate], src.[Apse])
    OUTPUT src.[Id], inserted.[Id] INTO @MapRiskman (OldId, NewId);

    INSERT INTO [dbo].[RiskmanIncidentContributingFactor] ([IncidentId], [FactorCode])
    SELECT mr.NewId, s.[FactorCode]
    FROM [dbo].[RiskmanIncidentContributingFactor] s
    INNER JOIN @MapRiskman mr ON mr.OldId = s.[IncidentId];

    COMMIT TRAN;

    SELECT @NewModuleId AS Id;
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteBradenAssessment]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteBradenAssessment]
  @Id INT
AS
BEGIN
  SET NOCOUNT ON;

  DELETE FROM dbo.BradenAssessment WHERE Id = @Id;

  SELECT CAST(@@ROWCOUNT AS INT) AS RowsAffected;
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteFluidBalanceChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ═══════════════════════════════════════════════════════════════════════════
-- 4.  DeleteFluidBalanceChart
--     Deletes a chart header (CASCADE removes child entries automatically).
--     Returns RowsAffected + ResultMessage for consistency with other SPs.
-- ═══════════════════════════════════════════════════════════════════════════
CREATE   PROCEDURE [dbo].[DeleteFluidBalanceChart]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [dbo].[FluidBalanceChart] WHERE Id = @Id;

    SELECT
        CAST(@@ROWCOUNT AS INT)  AS RowsAffected,
        CASE WHEN @@ROWCOUNT > 0
             THEN 'Fluid Balance Chart deleted successfully.'
             ELSE 'Record not found.'
        END                      AS ResultMessage;
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteFluidBalanceChartEntry]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ═══════════════════════════════════════════════════════════════════════════
-- 7.  DeleteFluidBalanceChartEntry
--     Deletes a single entry and recalculates totals on the parent chart.
-- ═══════════════════════════════════════════════════════════════════════════
CREATE   PROCEDURE [dbo].[DeleteFluidBalanceChartEntry]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ChartId INT;
    SELECT @ChartId = FluidBalanceChartId FROM [dbo].[FluidBalanceChartEntry] WHERE Id = @Id;

    DELETE FROM [dbo].[FluidBalanceChartEntry] WHERE Id = @Id;

    -- Recalculate totals
    IF @ChartId IS NOT NULL
    BEGIN
        UPDATE c
        SET
            TotalIntake  = (SELECT ISNULL(SUM(AmountMl), 0)
                            FROM [dbo].[FluidBalanceChartEntry]
                            WHERE FluidBalanceChartId = @ChartId AND EntryType = 'Intake'),
            TotalOutput  = (SELECT ISNULL(SUM(AmountMl), 0)
                            FROM [dbo].[FluidBalanceChartEntry]
                            WHERE FluidBalanceChartId = @ChartId AND EntryType = 'Output'),
            Balance      = (SELECT ISNULL(SUM(CASE WHEN EntryType = 'Intake' THEN AmountMl ELSE -AmountMl END), 0)
                            FROM [dbo].[FluidBalanceChartEntry]
                            WHERE FluidBalanceChartId = @ChartId),
            TotalBalance = c.PreviousDayBalance +
                           (SELECT ISNULL(SUM(CASE WHEN EntryType = 'Intake' THEN AmountMl ELSE -AmountMl END), 0)
                            FROM [dbo].[FluidBalanceChartEntry]
                            WHERE FluidBalanceChartId = @ChartId),
            UpdatedDateTime = GETDATE()
        FROM [dbo].[FluidBalanceChart] c
        WHERE c.Id = @ChartId;
    END

    SELECT CAST(@@ROWCOUNT AS INT);
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteFoodIntake]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[DeleteFoodIntake]
  @Id INT
AS
BEGIN
  SET NOCOUNT ON;

  -- Items will delete automatically via FK ON DELETE CASCADE
  DELETE FROM dbo.FoodIntakeHeader WHERE Id = @Id;

  SELECT CAST(@@ROWCOUNT AS INT) AS RowsAffected;
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteIvFluidAdministration]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteIvFluidAdministration]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [dbo].[IvFluidAdministration]
    WHERE Id = @Id;

    -- Optionally, return the number of rows affected
    SELECT @@ROWCOUNT AS RowsAffected;
END

GO
/****** Object:  StoredProcedure [dbo].[DeleteIvFluidChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteIvFluidChart]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

	IF NOT EXISTS(SELECT 1 FROM IvFluidChart WHERE Id = @Id)
    BEGIN
        SELECT 0 AS RowsAffected, 'Member Order does not exist' AS ResultMessage;
    END
    ELSE
    BEGIN
        IF EXISTS(SELECT 1 FROM IvFluidAdministration WHERE IvFluidChartId = @Id)
        BEGIN
            SELECT 0 AS RowsAffected, 'Member Order is being used in student Iv Fluid chart' AS ResultMessage;
        END
        ELSE
        BEGIN
            DELETE FROM IvFluidChart WHERE Id = @Id;

            SELECT @@ROWCOUNT AS RowsAffected, 'Member Order deleted successfully' AS ResultMessage;
        END
    END
END

GO
/****** Object:  StoredProcedure [dbo].[DeleteMedication]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteMedication]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS(SELECT 1 FROM Medication WHERE Id = @Id)
    BEGIN
        SELECT 0 AS RowsAffected, 'Medication does not exist' AS ResultMessage;
    END
    ELSE
    BEGIN
        IF EXISTS(SELECT 1 FROM MedicationPrnChart WHERE MedicationId = @Id)
            OR EXISTS(SELECT 1 FROM MedicationRegularChart WHERE MedicationId = @Id)
        BEGIN
            SELECT 0 AS RowsAffected, 'Medication is being used in PRN or Regular Medication chart' AS ResultMessage;
        END
        ELSE
        BEGIN
            DELETE FROM Medication WHERE Id = @Id;

            SELECT @@ROWCOUNT AS RowsAffected, 'Medication deleted successfully' AS ResultMessage;
        END
    END
END

GO
/****** Object:  StoredProcedure [dbo].[DeleteMedicationPrnAdministration]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteMedicationPrnAdministration]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [dbo].[MedicationPrnAdministration]
    WHERE Id = @Id;

    -- Optionally, return the number of rows affected
    SELECT @@ROWCOUNT AS RowsAffected;
END

GO
/****** Object:  StoredProcedure [dbo].[DeleteMedicationPrnChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteMedicationPrnChart]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

	IF NOT EXISTS(SELECT 1 FROM MedicationPrnChart WHERE Id = @Id)
    BEGIN
        SELECT 0 AS RowsAffected, 'Medication Prn does not exist' AS ResultMessage;
    END
    ELSE
    BEGIN
        IF EXISTS(SELECT 1 FROM MedicationPrnAdministration WHERE PatientMedicationChartId = @Id)
        BEGIN
            SELECT 0 AS RowsAffected, 'Medication Prn is being used in student medication prn chart' AS ResultMessage;
        END
        ELSE
        BEGIN
            DELETE FROM MedicationPrnChart WHERE Id = @Id;

            SELECT @@ROWCOUNT AS RowsAffected, 'Medication Prn deleted successfully' AS ResultMessage;
        END
    END

END

GO
/****** Object:  StoredProcedure [dbo].[DeleteMedicationRegularAdministration]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteMedicationRegularAdministration]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [dbo].[MedicationRegularAdministration]
    WHERE Id = @Id;

    -- Optionally, return the number of rows affected
    SELECT @@ROWCOUNT AS RowsAffected;
END

GO
/****** Object:  StoredProcedure [dbo].[DeleteMedicationRegularChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteMedicationRegularChart]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

	IF NOT EXISTS(SELECT 1 FROM MedicationRegularChart WHERE Id = @Id)
    BEGIN
        SELECT 0 AS RowsAffected, 'Medication Regular does not exist' AS ResultMessage;
    END
    ELSE
    BEGIN
        IF EXISTS(SELECT 1 FROM MedicationRegularAdministration WHERE PatientMedicationChartId = @Id)
        BEGIN
            SELECT 0 AS RowsAffected, 'Medication Regular is being used in student medication Regular chart' AS ResultMessage;
        END
        ELSE
        BEGIN
            DELETE FROM MedicationRegularChart WHERE Id = @Id;

            SELECT @@ROWCOUNT AS RowsAffected, 'Medication Regular deleted successfully' AS ResultMessage;
        END
    END

END

GO
/****** Object:  StoredProcedure [dbo].[DeleteModule]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteModule]
    @ModuleId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Deleted TABLE (TableName NVARCHAR(100), RowsDeleted INT);
    DECLARE @Patients TABLE (PatientId INT PRIMARY KEY);

    INSERT INTO @Patients (PatientId)
    SELECT [Id] FROM [dbo].[Patient] WHERE [ModuleId] = @ModuleId;

    BEGIN TRAN;

        /* --- child rows first ------------------------------------------- */
        DELETE e FROM [dbo].[FluidBalanceChartEntry] e
        INNER JOIN [dbo].[FluidBalanceChart] c ON c.[Id] = e.[FluidBalanceChartId]
        WHERE c.[PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('FluidBalanceChartEntry', @@ROWCOUNT);

        DELETE i FROM [dbo].[FoodIntakeItem] i
        INNER JOIN [dbo].[FoodIntakeHeader] h ON h.[Id] = i.[HeaderId]
        WHERE h.[PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('FoodIntakeItem', @@ROWCOUNT);

        DELETE f FROM [dbo].[RiskmanIncidentContributingFactor] f
        INNER JOIN [dbo].[RiskmanIncident] r ON r.[Id] = f.[IncidentId]
        WHERE r.[PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('RiskmanIncidentContributingFactor', @@ROWCOUNT);

        DELETE FROM [dbo].[IvFluidAdministration]           WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('IvFluidAdministration', @@ROWCOUNT);

        DELETE FROM [dbo].[MedicationRegularAdministration] WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('MedicationRegularAdministration', @@ROWCOUNT);

        DELETE FROM [dbo].[MedicationPrnAdministration]     WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('MedicationPrnAdministration', @@ROWCOUNT);

        DELETE FROM [dbo].[NeurologicalAdministration]      WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('NeurologicalAdministration', @@ROWCOUNT);

        /* --- parent chart rows ------------------------------------------ */
        DELETE FROM [dbo].[FluidBalanceChart]      WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('FluidBalanceChart', @@ROWCOUNT);

        DELETE FROM [dbo].[FoodIntakeHeader]       WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('FoodIntakeHeader', @@ROWCOUNT);

        DELETE FROM [dbo].[IvFluidChart]           WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('IvFluidChart', @@ROWCOUNT);

        DELETE FROM [dbo].[MedicationRegularChart] WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('MedicationRegularChart', @@ROWCOUNT);

        DELETE FROM [dbo].[MedicationPrnChart]     WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('MedicationPrnChart', @@ROWCOUNT);

        DELETE FROM [dbo].[NeurologicalChart]      WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('NeurologicalChart', @@ROWCOUNT);

        DELETE FROM [dbo].[RiskmanIncident]        WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('RiskmanIncident', @@ROWCOUNT);

        DELETE FROM [dbo].[BradenAssessment]       WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('BradenAssessment', @@ROWCOUNT);

        DELETE FROM [dbo].[FallRiskAssessments]    WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('FallRiskAssessments', @@ROWCOUNT);

        DELETE FROM [dbo].[PatientAdds]            WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('PatientAdds', @@ROWCOUNT);

        DELETE FROM [dbo].[ProgressNotes]          WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('ProgressNotes', @@ROWCOUNT);

        /* --- patients, then the module itself --------------------------- */
        DELETE FROM [dbo].[Patient] WHERE [ModuleId] = @ModuleId;
        INSERT INTO @Deleted VALUES ('Patient', @@ROWCOUNT);

        DELETE FROM [dbo].[Module]  WHERE [Id] = @ModuleId;
        INSERT INTO @Deleted VALUES ('Module', @@ROWCOUNT);

    COMMIT TRAN;

    SELECT TableName, RowsDeleted FROM @Deleted WHERE RowsDeleted > 0;
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteNeurologicalAdministration]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteNeurologicalAdministration]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [dbo].[NeurologicalAdministration]
    WHERE Id = @Id;

    -- Optionally, return the number of rows affected
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteNeurologicalChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteNeurologicalChart]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

	IF NOT EXISTS(SELECT 1 FROM NeurologicalChart WHERE Id = @Id)
    BEGIN
        SELECT 0 AS RowsAffected, 'Neurological Record does not exist' AS ResultMessage;
    END
    ELSE
    BEGIN
        IF EXISTS(SELECT 1 FROM NeurologicalAdministration WHERE NeurologicalChartId = @Id)
        BEGIN
            SELECT 0 AS RowsAffected, 'Neurological Record is being used in student Neurological chart' AS ResultMessage;
        END
        ELSE
        BEGIN
            DELETE FROM NeurologicalChart WHERE Id = @Id;

            SELECT @@ROWCOUNT AS RowsAffected, 'Neurological Record deleted successfully' AS ResultMessage;
        END
    END
END
GO
/****** Object:  StoredProcedure [dbo].[DeletePatient]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeletePatient]

    @Id INT,
	@LabId INT
AS
BEGIN

-- Delete from IvFluidAdministration and track rows affected
	DELETE FROM [dbo].[IvFluidChart]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
	AND PatientId = @Id;

    DELETE FROM [dbo].[IvFluidAdministration]
	WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @Id;

	DELETE FROM [dbo].[MedicationPrnChart]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
	AND PatientId = @Id;

    DELETE FROM [dbo].[MedicationPrnAdministration]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @Id;

	DELETE FROM [dbo].[MedicationRegularChart]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
	AND PatientId = @Id;

    -- Delete from MedicationRegularAdministration and track rows affected
    DELETE FROM [dbo].[MedicationRegularAdministration]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @Id;

    -- Delete from PatientAdds and track rows affected
    DELETE FROM [dbo].[PatientAdds]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @Id;

	-- Delete from Patient Progress Notes and track rows affected
    DELETE FROM [dbo].[ProgressNotes]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND PatientId = @Id
	AND NotesFrom = 'student'

    DELETE FROM Patient
    WHERE [Id] = @Id
	AND (ISNULL(@LabId, 0) = 0 OR LabId = @LabId);

	-- Optionally, return the number of rows affected
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO
/****** Object:  StoredProcedure [dbo].[DeletePatientAdds]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeletePatientAdds]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @PatientID INT = 0
	DECLARE @RowsAffected INT = 0

	SELECT @PatientID = PAtientId FROM PatientAdds WHERE Id = @Id

    DELETE FROM [dbo].[PatientAdds]
    WHERE Id = @Id;
    
	-- Optionally, return the number of rows affected
    SET @RowsAffected = @@ROWCOUNT

	IF NOT EXISTS (SELECT 1 FROM PatientAdds WHERE (RespiratoryAlert = 1 OR OxygenSaturationAlert = 1 OR BloodPressureAlert = 1 OR HeartRateAlert = 1 OR ConsciousnessAlert = 1) AND PatientId = @PatientID)
	BEGIN
		UPDATE Patient SET Alert = 0 WHERE Id = @PatientId
	END

	SELECT @RowsAffected AS RowsAffected
END

GO
/****** Object:  StoredProcedure [dbo].[DeleteProgressNote]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DeleteProgressNote]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Delete the record with the provided Id
    DELETE FROM ProgressNotes
    WHERE Id = @Id;

    -- Return the number of rows affected
    SELECT @@ROWCOUNT AS RowsAffected;
END



GO
/****** Object:  StoredProcedure [dbo].[DeleteRiskmanIncident]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[DeleteRiskmanIncident]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.RiskmanIncident WHERE Id = @Id;

    SELECT CAST(@@ROWCOUNT AS INT) AS RowsAffected;  -- your UI expects a number > 0
END
GO
/****** Object:  StoredProcedure [dbo].[GetBradenAssessmentById]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetBradenAssessmentById]

  @LabId INT,
  @Id INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
      Id, LabId, PatientId, DateOfAssessment, NurseInitials,
      Sensory, Moisture, Activity, Mobility, Nutrition, Friction,
      TotalScore, RiskKey, Shift
  FROM dbo.BradenAssessment
  WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND Id    = @Id;
END
GO
/****** Object:  StoredProcedure [dbo].[GetBradenAssessments]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetBradenAssessments]

  @LabId INT,
  @PatientId INT = NULL
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
      Id,
      LabId,
      PatientId,
      DateOfAssessment,
      Shift,
      NurseInitials,
      TotalScore,
      RiskKey
  FROM dbo.BradenAssessment
  WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND (@PatientId IS NULL OR PatientId = @PatientId)
  ORDER BY DateOfAssessment DESC, Id DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[GetFluidBalanceChartById]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetFluidBalanceChartById]

    @Id    INT,
    @LabId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, LabId, PatientId, ChartDate, ChartTime,
           PreviousDayBalance, TotalIntake, TotalOutput,
           Balance, TotalBalance, ClinicalNotes,
           SignatureData, CreatedDateTime, UpdatedDateTime
    FROM [dbo].[FluidBalanceChart]
    WHERE Id = @Id AND (ISNULL(@LabId, 0) = 0 OR LabId = @LabId);
    SELECT e.Id, e.FluidBalanceChartId, e.EntryDate, e.EntryTime,
           e.EntryType, e.Category, e.AmountMl, e.Initials, e.CreatedDateTime
    FROM [dbo].[FluidBalanceChartEntry] e
    WHERE e.FluidBalanceChartId = @Id
    ORDER BY e.EntryDate, e.EntryTime;
END
GO
/****** Object:  StoredProcedure [dbo].[GetFluidBalanceChartEntries]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GetFluidBalanceChartEntries]
    @FluidBalanceChartId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, FluidBalanceChartId, EntryDate, EntryTime,
           EntryType, Category, AmountMl, Initials, CreatedDateTime
    FROM [dbo].[FluidBalanceChartEntry]
    WHERE FluidBalanceChartId = @FluidBalanceChartId
    ORDER BY EntryDate, EntryTime;
END
GO
/****** Object:  StoredProcedure [dbo].[GetFluidBalanceCharts]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetFluidBalanceCharts]

    @LabId     INT,
    @PatientId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.Id, c.LabId, c.PatientId, c.ChartDate, c.ChartTime,
        c.PreviousDayBalance, c.TotalIntake, c.TotalOutput,
        c.Balance, c.TotalBalance, c.ClinicalNotes,
        c.SignatureData, c.CreatedDateTime, c.UpdatedDateTime,
        ISNULL(
            (SELECT MIN(e.EntryDate) FROM [dbo].[FluidBalanceChartEntry] e
             WHERE e.FluidBalanceChartId = c.Id),
            c.ChartDate
        ) AS EarliestEntryDate,
        ISNULL(
            (SELECT MAX(e.EntryDate) FROM [dbo].[FluidBalanceChartEntry] e
             WHERE e.FluidBalanceChartId = c.Id),
            c.ChartDate
        ) AS LatestEntryDate,
        ISNULL(
            STUFF((
                SELECT DISTINCT ', ' + e.Initials
                FROM [dbo].[FluidBalanceChartEntry] e
                WHERE e.FluidBalanceChartId = c.Id
                  AND e.Initials IS NOT NULL
                  AND LTRIM(RTRIM(e.Initials)) <> ''
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 2, ''),
            ''
        ) AS CompletedBy
    FROM [dbo].[FluidBalanceChart] c
    WHERE (ISNULL(@LabId, 0) = 0 OR c.LabId = @LabId) AND c.PatientId = @PatientId
    ORDER BY EarliestEntryDate DESC, c.CreatedDateTime DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[GetFoodIntakeById]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetFoodIntakeById]

  @LabId INT,
  @Id    INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT TOP (1)
    h.Id, h.LabId, h.PatientId, h.DayText, h.IntakeDate,
    h.Shift1Signature, h.Shift1Designation,
    h.Shift2Signature, h.Shift2Designation,
	h.Shift3Signature, h.Shift3Designation,
    h.BreakfastComment, h.MorningTeaComment,
    h.LunchComment, h.AfternoonTeaComment, h.DinnerComment, h.SupperComment
  FROM dbo.FoodIntakeHeader h
  WHERE (ISNULL(@LabId, 0) = 0 OR h.LabId = @LabId) AND h.Id = @Id;

  SELECT
    i.Id, i.Meal, i.Label, i.Notes, i.Amount
  FROM dbo.FoodIntakeItem i
  WHERE i.HeaderId = @Id
  ORDER BY CASE i.Meal
             WHEN 'Breakfast'     THEN 1
             WHEN 'Morning tea'   THEN 2
             WHEN 'Lunch'         THEN 3
             WHEN 'Afternoon tea' THEN 4
             WHEN 'Dinner'        THEN 5
             WHEN 'Supper'        THEN 6
             ELSE 99
           END,
           i.Id;
END
GO
/****** Object:  StoredProcedure [dbo].[GetFoodIntakeHeaders]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetFoodIntakeHeaders]
  @LabId INT,
  @PatientId INT = NULL
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    h.Id,
    h.LabId,
    h.PatientId,
    h.DayText,
    h.IntakeDate,
    -- Meals recorded as a quick summary: "Breakfast, Morning tea, Lunch"
    (
      SELECT STRING_AGG(m.Meal, N', ')
      FROM (
        SELECT DISTINCT i.Meal
        FROM dbo.FoodIntakeItem i
        WHERE i.HeaderId = h.Id
      ) AS m
    ) AS MealsRecordedSummary
  FROM dbo.FoodIntakeHeader h
  WHERE h.LabId = @LabId
    AND (@PatientId IS NULL OR h.PatientId = @PatientId)
  ORDER BY h.IntakeDate DESC, h.Id DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[GetIvFluidAdministration]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetIvFluidAdministration]

    @LabId INT,
    @PatientId INT,
    @IvFluidChartId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Id,
        LabId,
        PatientId,
        IvFluidChartId,
        StartDate,
        StartTime,
        EndDate,
        EndTime,
        VolGiven,
        PharmacistReview,
        NurseSign,
		CoSign
    FROM [dbo].[IvFluidAdministration]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) 
      AND PatientId = @PatientId
      AND IvFluidChartId = @IvFluidChartId;
END
GO
/****** Object:  StoredProcedure [dbo].[GetIvFluidChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetIvFluidChart]
    @Id INT = 0,
    @LabId INT = 0,
    @PatientId INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Id,
        LabId,
        PatientId,
        [Date],
        FlaskVol,
        Strength,
        Rate,
        Dose,
        OfficerSign
    FROM [dbo].[IvFluidChart]
    WHERE (@LabId = 0 OR LabId = @LabId) 
      AND (@PatientId = 0 OR PatientId = @PatientId)
      AND (@Id = 0 OR Id = @Id);
END

GO
/****** Object:  StoredProcedure [dbo].[GetLab]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetLab] 
	-- Add the parameters for the stored procedure here
	@Id INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM Lab
	WHERE Id = @Id
END

GO
/****** Object:  StoredProcedure [dbo].[GetLabModuleLoads]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetLabModuleLoads]
    @LabId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  p.[SourceModuleId]  AS ModuleId,
            p.[Id]              AS PatientId,
            p.[FirstName],
            p.[LastName],
            p.[LoadedIntoLabAt],
            m.[ModuleName]
    FROM    [dbo].[Patient] p
    LEFT JOIN [dbo].[Module] m ON m.[Id] = p.[SourceModuleId]
    WHERE   p.[LabId] = @LabId
      AND   p.[SourceModuleId] IS NOT NULL;
END
GO
/****** Object:  StoredProcedure [dbo].[GetLabs]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetLabs]
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  [Id],
            [LabName],
            ISNULL([Active], 0) AS Active
    FROM    [dbo].[Lab]
    WHERE   (@IncludeInactive = 1 OR ISNULL([Active], 0) = 1)
    ORDER BY [LabName];
END
GO
/****** Object:  StoredProcedure [dbo].[GetLatestFluidBalanceTotalBalance]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[GetLatestFluidBalanceTotalBalance]
    @LabId      INT,
    @PatientId  INT,
    @BeforeDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- The previous calendar day
    DECLARE @PrevDay DATE = DATEADD(DAY, -1, ISNULL(@BeforeDate, CAST(GETDATE() AS DATE)));

    -- Sum TotalBalance for all charts that have at least one entry on exactly @PrevDay
    -- If no entries exist for that day, returns 0
    SELECT ISNULL(SUM(c.TotalBalance), 0) AS TotalBalance
    FROM [dbo].[FluidBalanceChart] c
    WHERE c.LabId     = @LabId
      AND c.PatientId = @PatientId
      AND EXISTS (
          SELECT 1
          FROM [dbo].[FluidBalanceChartEntry] e
          WHERE e.FluidBalanceChartId = c.Id
            AND e.EntryDate = @PrevDay
      );
END
GO
/****** Object:  StoredProcedure [dbo].[GetMedication]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetMedication]
 
	-- Add the parameters for the stored procedure here
	@LabId INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM Medication
	WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) 
END
GO
/****** Object:  StoredProcedure [dbo].[GetMedicationPrnAdministration]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetMedicationPrnAdministration]

    @LabId INT,
    @PatientId INT,
    @PatientMedicationChartId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        *
    FROM [dbo].[MedicationPrnAdministration]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) 
      AND PatientId = @PatientId
      AND PatientMedicationChartId = @PatientMedicationChartId;
END
GO
/****** Object:  StoredProcedure [dbo].[GetMedicationPrnChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetMedicationPrnChart]
 
	-- Add the parameters for the stored procedure here
	@Id INT = 0,
	@LabId INT = 0,
	@PatientId INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Id, 
		(SELECT Name FROM Medication M WHERE M.Id = C.MedicationId AND (ISNULL(@LabId, 0) = 0 OR M.LabId = @LabId)) AS MedicationName, *
		
	FROM MedicationPrnChart C 
	WHERE (@LabId = 0 OR LabId = @LabId) 
      AND (@PatientId = 0 OR PatientId = @PatientId)
      AND (@Id = 0 OR Id = @Id);
END
GO
/****** Object:  StoredProcedure [dbo].[GetMedicationRegularAdministration]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetMedicationRegularAdministration]

    @LabId INT,
    @PatientId INT,
    @PatientMedicationChartId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        *
    FROM [dbo].[MedicationRegularAdministration]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) 
      AND PatientId = @PatientId
      AND PatientMedicationChartId = @PatientMedicationChartId;
END
GO
/****** Object:  StoredProcedure [dbo].[GetMedicationRegularChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetMedicationRegularChart]
 
	-- Add the parameters for the stored procedure here
	@Id INT = 0,
	@LabId INT = 0,
	@PatientId INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Id, 
		(SELECT Name FROM Medication M WHERE M.Id = C.MedicationId AND (ISNULL(@LabId, 0) = 0 OR M.LabId = @LabId)) AS MedicationName, *
		
	FROM MedicationRegularChart C 
	WHERE (@LabId = 0 OR LabId = @LabId) 
      AND (@PatientId = 0 OR PatientId = @PatientId)
      AND (@Id = 0 OR Id = @Id);
END
GO
/****** Object:  StoredProcedure [dbo].[GetModuleById]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetModuleById]
    @ModuleId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT  m.[Id], m.[UnitId], u.[UnitCode], u.[UnitName],
            u.[YearLevelId], y.[YearLevelName],
            m.[ModuleName], m.[Description], m.[SortOrder], m.[Active],
            m.[CreatedBySupervisorId], m.[CreatedDate], m.[UpdatedDate],
            (SELECT COUNT(*) FROM [dbo].[Patient] p WHERE p.[ModuleId] = m.[Id]) AS PatientCount
    FROM    [dbo].[Module] m
    INNER JOIN [dbo].[Unit]      u ON u.[Id] = m.[UnitId]
    INNER JOIN [dbo].[YearLevel] y ON y.[Id] = u.[YearLevelId]
    WHERE   m.[Id] = @ModuleId;
END
GO
/****** Object:  StoredProcedure [dbo].[GetModules]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetModules]
    @YearLevelId     INT = 0,
    @UnitId          INT = 0,
    @SearchTerm      VARCHAR(150) = NULL,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    /* The global repository view. Deliberately NOT filtered by LabId or
       Supervisor - every campus login sees every module. */
    SELECT  m.[Id], m.[UnitId], u.[UnitCode], u.[UnitName],
            u.[YearLevelId], y.[YearLevelName],
            m.[ModuleName], m.[Description], m.[SortOrder], m.[Active],
            m.[CreatedBySupervisorId], m.[CreatedDate], m.[UpdatedDate],
            (SELECT COUNT(*) FROM [dbo].[Patient] p WHERE p.[ModuleId] = m.[Id]) AS PatientCount
    FROM    [dbo].[Module] m
    INNER JOIN [dbo].[Unit]      u ON u.[Id] = m.[UnitId]
    INNER JOIN [dbo].[YearLevel] y ON y.[Id] = u.[YearLevelId]
    WHERE   (@UnitId      = 0 OR m.[UnitId]      = @UnitId)
      AND   (@YearLevelId = 0 OR u.[YearLevelId] = @YearLevelId)
      AND   (@IncludeInactive = 1 OR m.[Active] = 1)
      AND   (@SearchTerm IS NULL OR @SearchTerm = ''
             OR m.[ModuleName] LIKE '%' + @SearchTerm + '%'
             OR u.[UnitName]   LIKE '%' + @SearchTerm + '%'
             OR y.[YearLevelName] LIKE '%' + @SearchTerm + '%')
    ORDER BY y.[SortOrder], u.[SortOrder], m.[SortOrder], m.[ModuleName];
END
GO
/****** Object:  StoredProcedure [dbo].[GetNeurologicalAdministration]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetNeurologicalAdministration]

    @LabId INT,
    @PatientId INT,
    @NeurologicalChartId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Id,
        LabId,
        PatientId,
        NeurologicalChartId,
        StartDate,
        StartTime,
        EndDate,
        EndTime,
        PharmacistReview,
        NurseSign,
		CoSign
    FROM [dbo].[NeurologicalAdministration]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) 
      AND PatientId = @PatientId
      AND NeurologicalChartId = @NeurologicalChartId;
END
GO
/****** Object:  StoredProcedure [dbo].[GetNeurologicalChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  StoredProcedure [dbo].[GetNeurologicalChart]   ******/
 
CREATE PROCEDURE [dbo].[GetNeurologicalChart]
    @Id INT = 0,
    @LabId INT = 0,
    @PatientId INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Id,
        LabId,
        PatientId,
        [Date],
		[Time],
		EyesOpenScore,
		VerbalResponseScore,  -- Supports 'T' for intubated
		MotorResponseScore,
		TotalComaScale,
		EndotrachealTube,
		RightPupilSize,
		RightPupilReaction,
		LeftPupilSize,
		LeftPupilReaction,
		RightArmResponse,
		RightLegResponse,
		LeftArmResponse,
		LeftLegResponse,
		OfficerSign
        
    FROM [dbo].[NeurologicalChart]
    WHERE (@LabId = 0 OR LabId = @LabId) 
      AND (@PatientId = 0 OR PatientId = @PatientId)
      AND (@Id = 0 OR Id = @Id);
END
GO
/****** Object:  StoredProcedure [dbo].[GetPatient]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetPatient] 
    @Id INT = 0,
    @LabId INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Select results based on the combination of parameters
    SELECT * 
    FROM Patient
    WHERE (@Id = 0 OR Id = @Id)
      AND (@LabId = 0 OR LabId = @LabId);
END

GO
/****** Object:  StoredProcedure [dbo].[GetPatientAdds]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetPatientAdds]
    @LabId INT = 0,
    @PatientId INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [dbo].[PatientAdds]
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
      AND PatientId = @PatientId
    ORDER BY EnteredDate DESC, EnteredTime DESC, Id DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[GetPatientFallRisks]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetPatientFallRisks]
  @LabId int,
  @PatientId int
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    LabId, PatientId,
    RecentFallsScore, MedicationsScore, PsychologicalScore, CognitiveScore,
    TotalScore, RiskLevel, AssessedAt, Assessor, Notes,
    AutoCondChange, AutoDizziness, AutoAnaesthetic, InterventionNotes
  FROM dbo.FallRiskAssessments
  WHERE LabId = @LabId AND PatientId = @PatientId
  ORDER BY AssessedAt DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[GetPatientForEdit]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ---------------------------------------------------------------------------
-- Edit Patient: read one patient for the edit modal
-- ---------------------------------------------------------------------------
CREATE   PROCEDURE [dbo].[GetPatientForEdit]
    @PatientId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1
        Id, FirstName, LastName, DateOfBirth, Gender,
        Address, Allergy, Intolerance, Weight, Height, Age
    FROM dbo.Patient
    WHERE Id = @PatientId;
END
GO
/****** Object:  StoredProcedure [dbo].[GetPatientsByModule]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetPatientsByModule]
    @ModuleId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM [dbo].[Patient]
    WHERE [ModuleId] = @ModuleId
    ORDER BY [LastName], [FirstName];
END
GO
/****** Object:  StoredProcedure [dbo].[GetPoliciesByLab]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ---------------------------------------------------------------------------
-- Policies: list by lab with optional search term ('' = no filter)
-- ---------------------------------------------------------------------------
CREATE   PROCEDURE [dbo].[GetPoliciesByLab]
    @LabId  INT,
    @Search NVARCHAR(255) = ''
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, LabId, FileName, DisplayName, FileSizeString, UploadedDate
    FROM dbo.Policies
    WHERE LabId = @LabId
      AND (
            @Search = ''
            OR DisplayName LIKE '%' + @Search + '%'
            OR FileName    LIKE '%' + @Search + '%'
          )
    ORDER BY UploadedDate DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[GetPolicyById]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ---------------------------------------------------------------------------
-- Policies: get one (incl. FileData) for download
-- ---------------------------------------------------------------------------
CREATE   PROCEDURE [dbo].[GetPolicyById]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, LabId, FileName, DisplayName, FileSizeString, FileData, UploadedDate
    FROM dbo.Policies
    WHERE Id = @Id;
END
GO
/****** Object:  StoredProcedure [dbo].[GetProgressNoteById]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetProgressNoteById]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id, LabId, Notes, Sign, NotesDate, PatientId, NotesFrom
    FROM ProgressNotes
    WHERE Id = @Id;
END
GO
/****** Object:  StoredProcedure [dbo].[GetProgressNotes]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetProgressNotes]
    @LabId INT = NULL,
    @PatientId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id, LabId, Notes, Sign, NotesDate, PatientId, NotesFrom
    FROM ProgressNotes
    WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
      AND PatientId = @PatientId
    ORDER BY CASE WHEN NotesDate IS NULL THEN 1 ELSE 0 END,
             NotesDate DESC,
             Id DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[GetRiskmanIncident]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetRiskmanIncident]

  @LabId INT,
  @PatientId INT = NULL
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
      Id, LabId, PatientId, IncidentDate, IncidentTime, URINumber,
      Campus, WardLocationType, PersonName,
      DateOfBirth, Sex, IndigenousStatus, BriefSummary, Details, EventType, EventSubType
  FROM dbo.RiskmanIncident
  WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    AND (@PatientId IS NULL OR PatientId = @PatientId)
  ORDER BY IncidentDate DESC, Id DESC;
END
GO
/****** Object:  StoredProcedure [dbo].[GetRiskmanIncidentById]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetRiskmanIncidentById]

    @LabId INT,
    @Id    INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        i.Id, i.LabId, i.PatientId, i.IncidentDate, i.IncidentTime, i.URINumber,
        i.Campus, i.WardLocationType, i.PersonName, i.DateOfBirth, i.Sex, i.IndigenousStatus,
        i.BriefSummary, i.Details, i.EventType, i.EventSubType,
        i.IsClinicalIncident, i.Apse, i.ClinicalHarmLevel, i.HarmDuration, i.RequiredCareLevelClinical,
        i.EmergencyResponseType, i.EmergencyResponseOutcome,
        i.ContributingAdditionalDetail,
        i.ReporterIsAffectedStaff, i.OhsTypeOfInjury, i.OhsTypeOfInjuryOther, i.OhsBodyPartAffected, i.OhsBodyPartOther,
        i.OhsLevelOfHarmSustained, i.OhsRequiredLevelOfCare, i.OhsActionsRequired,
		i.NextOfKinNotifiedDate, i.NextOfKinNotifiedTime, 
        i.SignedBy, i.SignedDate,
        -- aggregated factors for the repo to split into List<string>
        (SELECT STRING_AGG(LTRIM(RTRIM(cf.FactorCode)), ',')
           FROM dbo.RiskmanIncidentContributingFactor cf
          WHERE cf.IncidentId = i.Id) AS FactorsCsv
    FROM dbo.RiskmanIncident i
    WHERE (ISNULL(@LabId, 0) = 0 OR i.LabId = @LabId)
      AND i.Id    = @Id;
END
GO
/****** Object:  StoredProcedure [dbo].[GetUnits]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetUnits]
    @YearLevelId     INT = 0,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT  u.[Id], u.[YearLevelId], y.[YearLevelName], u.[UnitCode], u.[UnitName],
            u.[SortOrder], u.[Active], u.[CreatedDate],
            (SELECT COUNT(*) FROM [dbo].[Module] m WHERE m.[UnitId] = u.[Id]) AS ModuleCount
    FROM    [dbo].[Unit] u
    INNER JOIN [dbo].[YearLevel] y ON y.[Id] = u.[YearLevelId]
    WHERE   (@YearLevelId = 0 OR u.[YearLevelId] = @YearLevelId)
      AND   (@IncludeInactive = 1 OR u.[Active] = 1)
    ORDER BY y.[SortOrder], u.[SortOrder], u.[UnitName];
END
GO
/****** Object:  StoredProcedure [dbo].[GetYearLevels]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetYearLevels]
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT  y.[Id], y.[YearLevelName], y.[SortOrder], y.[Active], y.[CreatedDate],
            (SELECT COUNT(*) FROM [dbo].[Unit] u WHERE u.[YearLevelId] = y.[Id]) AS UnitCount
    FROM    [dbo].[YearLevel] y
    WHERE   (@IncludeInactive = 1 OR y.[Active] = 1)
    ORDER BY y.[SortOrder], y.[YearLevelName];
END
GO
/****** Object:  StoredProcedure [dbo].[InsertBradenAssessment]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertBradenAssessment]

  @LabId INT,
  @PatientId INT,
  @DateOfAssessment DATE,
  @NurseInitials NVARCHAR(10),
  @Sensory INT,
  @Moisture INT,
  @Activity INT,
  @Mobility INT,
  @Nutrition INT,
  @Friction INT,
  @TotalScore INT,
  @RiskKey NVARCHAR(50),
  @Shift NVARCHAR(20) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  -- ✅ Guard: block any second “initial” row for this LabId+PatientId
  -- UPDLOCK+HOLDLOCK prevents race conditions under concurrency
  IF EXISTS (
      SELECT 1
      FROM dbo.BradenAssessment WITH (UPDLOCK, HOLDLOCK)
      WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId
  )
  BEGIN
    SELECT CAST(-1 AS INT);
    RETURN;
  END

  INSERT INTO dbo.BradenAssessment
  (
    LabId, PatientId, DateOfAssessment, NurseInitials,
    Sensory, Moisture, Activity, Mobility, Nutrition, Friction,
    TotalScore, RiskKey, Shift
  )
  VALUES
  (
    @LabId, @PatientId, @DateOfAssessment, @NurseInitials,
    @Sensory, @Moisture, @Activity, @Mobility, @Nutrition, @Friction,
    @TotalScore, @RiskKey, @Shift
  );

  SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO
/****** Object:  StoredProcedure [dbo].[InsertBradenAssessmentFollowUp]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertBradenAssessmentFollowUp]

  @LabId INT,
  @PatientId INT,
  @DateOfAssessment DATE,
  @NurseInitials NVARCHAR(10),
  @Sensory INT,
  @Moisture INT,
  @Activity INT,
  @Mobility INT,
  @Nutrition INT,
  @Friction INT,
  @TotalScore INT,
  @RiskKey NVARCHAR(50),
  @Shift NVARCHAR(20) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  -- ✅ Guard: must already have an initial assessment
  IF NOT EXISTS (
      SELECT 1
      FROM dbo.BradenAssessment
      WHERE (ISNULL(@LabId, 0) = 0 OR LabId = @LabId) AND PatientId = @PatientId
  )
  BEGIN
    SELECT CAST(-1 AS INT);  -- signal: no initial exists
    RETURN;
  END

  INSERT INTO dbo.BradenAssessment
  (
    LabId, PatientId, DateOfAssessment, NurseInitials,
    Sensory, Moisture, Activity, Mobility, Nutrition, Friction,
    TotalScore, RiskKey, Shift
  )
  VALUES
  (
    @LabId, @PatientId, @DateOfAssessment, @NurseInitials,
    @Sensory, @Moisture, @Activity, @Mobility, @Nutrition, @Friction,
    @TotalScore, @RiskKey, @Shift
  );

  SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO
/****** Object:  StoredProcedure [dbo].[InsertFluidBalanceChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[InsertFluidBalanceChart]
    @LabId              INT,
    @PatientId          INT,
    @ChartDate          DATE,
    @ChartTime          VARCHAR(5)       = NULL,
    @PreviousDayBalance INT              = 0,
    @TotalIntake        INT              = 0,
    @TotalOutput        INT              = 0,
    @Balance            INT              = 0,
    @TotalBalance       INT              = 0,
    @ClinicalNotes      NVARCHAR(MAX)    = NULL,
    @SignatureData      NVARCHAR(MAX)    = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[FluidBalanceChart]
        (LabId, PatientId, ChartDate, ChartTime,
         PreviousDayBalance, TotalIntake, TotalOutput,
         Balance, TotalBalance,
         ClinicalNotes, SignatureData,
         CreatedDateTime)
    VALUES
        (@LabId, @PatientId, @ChartDate, @ChartTime,
         @PreviousDayBalance, @TotalIntake, @TotalOutput,
         @Balance, @TotalBalance,
         @ClinicalNotes, @SignatureData,
         GETDATE());
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO
/****** Object:  StoredProcedure [dbo].[InsertFluidBalanceChartEntry]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[InsertFluidBalanceChartEntry]
    @FluidBalanceChartId INT,
    @EntryDate           DATE,
    @EntryTime           VARCHAR(4),
    @EntryType           NVARCHAR(10),
    @Category            NVARCHAR(50),
    @AmountMl            INT,
    @Initials            NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[FluidBalanceChartEntry]
        (FluidBalanceChartId, EntryDate, EntryTime, EntryType, Category, AmountMl, Initials, CreatedDateTime)
    VALUES
        (@FluidBalanceChartId, @EntryDate, @EntryTime, @EntryType, @Category, @AmountMl, @Initials, GETDATE());
    DECLARE @NewId INT = CAST(SCOPE_IDENTITY() AS INT);
    UPDATE c SET
        TotalIntake  = (SELECT ISNULL(SUM(AmountMl),0) FROM [dbo].[FluidBalanceChartEntry]
                        WHERE FluidBalanceChartId = @FluidBalanceChartId AND EntryType = 'Intake'),
        TotalOutput  = (SELECT ISNULL(SUM(AmountMl),0) FROM [dbo].[FluidBalanceChartEntry]
                        WHERE FluidBalanceChartId = @FluidBalanceChartId AND EntryType = 'Output'),
        Balance      = (SELECT ISNULL(SUM(CASE WHEN EntryType = 'Intake' THEN AmountMl ELSE -AmountMl END),0)
                        FROM [dbo].[FluidBalanceChartEntry] WHERE FluidBalanceChartId = @FluidBalanceChartId),
        TotalBalance = c.PreviousDayBalance +
                       (SELECT ISNULL(SUM(CASE WHEN EntryType = 'Intake' THEN AmountMl ELSE -AmountMl END),0)
                        FROM [dbo].[FluidBalanceChartEntry] WHERE FluidBalanceChartId = @FluidBalanceChartId),
        UpdatedDateTime = GETDATE()
    FROM [dbo].[FluidBalanceChart] c WHERE c.Id = @FluidBalanceChartId;
    SELECT @NewId;
END
GO
/****** Object:  StoredProcedure [dbo].[InsertFoodIntake]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertFoodIntake]
  @LabId               INT,
  @PatientId           INT,
  @DayText             NVARCHAR(10) = NULL,
  @IntakeDate          DATE,
  @Shift1Signature     NVARCHAR(40) = NULL,
  @Shift1Designation   NVARCHAR(40) = NULL,
  @Shift2Signature     NVARCHAR(40) = NULL,
  @Shift2Designation   NVARCHAR(40) = NULL,
  @Shift3Signature     NVARCHAR(40) = NULL,
  @Shift3Designation   NVARCHAR(40) = NULL,
  @BreakfastComment    NVARCHAR(200) = NULL,
  @MorningTeaComment   NVARCHAR(200) = NULL,
  @LunchComment        NVARCHAR(200) = NULL,
  @AfternoonTeaComment NVARCHAR(200) = NULL,
  @DinnerComment       NVARCHAR(200) = NULL,
  @SupperComment       NVARCHAR(200) = NULL,
  @ItemsJson           NVARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @NewHeaderId INT;

  INSERT INTO dbo.FoodIntakeHeader
  (
    LabId, PatientId, DayText, IntakeDate,
    Shift1Signature, Shift1Designation, Shift2Signature, Shift2Designation, Shift3Signature, Shift3Designation,
    BreakfastComment, MorningTeaComment,
    LunchComment, AfternoonTeaComment, DinnerComment, SupperComment
  )
  VALUES
  (
    @LabId, @PatientId, @DayText, @IntakeDate,
    @Shift1Signature, @Shift1Designation, @Shift2Signature, @Shift2Designation, @Shift3Signature, @Shift3Designation,
    @BreakfastComment, @MorningTeaComment,
    @LunchComment, @AfternoonTeaComment, @DinnerComment, @SupperComment
  );

  SET @NewHeaderId = SCOPE_IDENTITY();

  INSERT INTO dbo.FoodIntakeItem (HeaderId, Meal, Label, Notes, Amount)
  SELECT
    @NewHeaderId, j.Meal, j.Label, j.Notes, j.Amount
  FROM OPENJSON(@ItemsJson)
  WITH
  (
    Meal   NVARCHAR(30)  '$.Meal',
    Label  NVARCHAR(50)  '$.Label',
    Notes  NVARCHAR(200) '$.Notes',
    Amount NVARCHAR(10)  '$.Amount'
  ) AS j;

  SELECT CAST(@NewHeaderId AS INT);
END
GO
/****** Object:  StoredProcedure [dbo].[InsertIvFluidAdministration]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertIvFluidAdministration]
    @LabId INT,
    @PatientId INT,
    @IvFluidChartId INT,
    @StartDate DATE,
    @StartTime VARCHAR(50) = NULL,
    @EndDate DATE,
    @EndTime VARCHAR(50) = NULL,
    @VolGiven VARCHAR(50) = NULL,
    @PharmacistReview VARCHAR(200) = NULL,
    @NurseSign VARCHAR(50) = NULL,
	@CoSign VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[IvFluidAdministration]
    (
        LabId,
        PatientId,
        IvFluidChartId,
        StartDate,
        StartTime,
        EndDate,
        EndTime,
        VolGiven,
        PharmacistReview,
        NurseSign,
		CoSign
    )
    VALUES
    (
        @LabId,
        @PatientId,
        @IvFluidChartId,
        @StartDate,
        @StartTime,
        @EndDate,
        @EndTime,
        @VolGiven,
        @PharmacistReview,
        @NurseSign,
		@CoSign
    );

    -- Optionally return the newly inserted Id
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END

GO
/****** Object:  StoredProcedure [dbo].[InsertIvFluidChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertIvFluidChart]
    @LabId INT,
    @PatientId INT,
    @Date DATE,
    @FlaskVol VARCHAR(50) = NULL,
    @Strength VARCHAR(50) = NULL,
    @Rate VARCHAR(50) = NULL,
    @Dose VARCHAR(50) = NULL,
    @OfficerSign VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[IvFluidChart]
    (
        LabId,
        PatientId,
        [Date],
        FlaskVol,
        Strength,
        Rate,
        Dose,
        OfficerSign
    )
    VALUES
    (
        @LabId,
        @PatientId,
        @Date,
        @FlaskVol,
        @Strength,
        @Rate,
        @Dose,
        @OfficerSign
    );

    -- Optionally return the newly inserted Id
     SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END

GO
/****** Object:  StoredProcedure [dbo].[InsertMedication]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertMedication]
    @LabId INT,
    @Name VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[Medication]
    (
        LabId,
        Name
    )
    VALUES
    (
        @LabId,
        @Name
    );

    -- Optionally return the ID of the newly inserted record
   SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END

GO
/****** Object:  StoredProcedure [dbo].[InsertMedicationPrnAdministration]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertMedicationPrnAdministration]
    @LabId INT,
    @PatientId INT,
    @PatientMedicationChartId INT,
    @DoseDate DATE,
    @DoseTime VARCHAR(50) = NULL,
	@Dose VARCHAR(50) = NULL,
    @Route VARCHAR(50) = NULL,
    @StudentSign VARCHAR(50) = NULL,
	@Reason VARCHAR(200) = NULL,
	@CoSign VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[MedicationPrnAdministration]
    (
        LabId,
        PatientId,
        PatientMedicationChartId,
        DoseDate,
        DoseTime,
		Dose,
        Route,
        StudentSign,
		Reason,
		CoSign
    )
    VALUES
    (
        @LabId,
        @PatientId,
        @PatientMedicationChartId,
        @DoseDate,
        @DoseTime,
		@Dose,
        @Route,
        @StudentSign,
		@Reason,
		@CoSign
    );

    -- Optionally return the newly inserted Id
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END

GO
/****** Object:  StoredProcedure [dbo].[InsertMedicationPrnChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertMedicationPrnChart]
    @LabId INT,
    @PatientId INT,
    @MedicationId INT,
    @Dose VARCHAR(50) = NULL,
    @DoseFrequency VARCHAR(50) = NULL,
    @DoseDate DATE,
    @DoseTime VARCHAR(50) = NULL,
    @Indication VARCHAR(50) = NULL,
    @Route VARCHAR(50) = NULL,
    @Pharmacy VARCHAR(50) = NULL,
    @Prescriber VARCHAR(50) = NULL,
    @PrescriberSign VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[MedicationPrnChart]
    (
        LabId,
        PatientId,
        MedicationId,
        Dose,
        DoseFrequency,
        DoseDate,
        DoseTime,
        Indication,
        Route,
        Pharmacy,
        Prescriber,
        PrescriberSign
    )
    VALUES
    (
        @LabId,
        @PatientId,
        @MedicationId,
        @Dose,
        @DoseFrequency,
        @DoseDate,
        @DoseTime,
        @Indication,
        @Route,
        @Pharmacy,
        @Prescriber,
        @PrescriberSign
    );

    -- Optionally return the ID of the newly inserted record
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END

GO
/****** Object:  StoredProcedure [dbo].[InsertMedicationRegularAdministration]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertMedicationRegularAdministration]
    @LabId INT,
    @PatientId INT,
    @PatientMedicationChartId INT,
    @DoseDate DATE,
    @DoseTime VARCHAR(50) = NULL,
	@Dose VARCHAR(50) = NULL,
    @Route VARCHAR(50) = NULL,
    @StudentSign VARCHAR(50) = NULL,
	@Reason VARCHAR(200) = NULL,
	@CoSign VARCHAR(50) = NULL,
	@EnteredBy VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[MedicationRegularAdministration]
    (
        LabId,
        PatientId,
        PatientMedicationChartId,
        DoseDate,
        DoseTime,
		Dose,
        Route,
        StudentSign,
		Reason,
		CoSign
    )
    VALUES
    (
        @LabId,
        @PatientId,
        @PatientMedicationChartId,
        @DoseDate,
        @DoseTime,
		@Dose,
        @Route,
        @StudentSign,
		@Reason,
		@CoSign
    );

    -- Optionally return the newly inserted Id
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END

GO
/****** Object:  StoredProcedure [dbo].[InsertMedicationRegularChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertMedicationRegularChart]
    @LabId INT,
    @PatientId INT,
    @MedicationId INT,
    @Dose VARCHAR(50) = NULL,
    @DoseFrequency VARCHAR(50) = NULL,
    @DoseDate DATE,
    @DoseTime VARCHAR(50) = NULL,
    @Indication VARCHAR(50) = NULL,
    @Route VARCHAR(50) = NULL,
    @Pharmacy VARCHAR(50) = NULL,
    @Prescriber VARCHAR(50) = NULL,
    @PrescriberSign VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[MedicationRegularChart]
    (
        LabId,
        PatientId,
        MedicationId,
        Dose,
        DoseFrequency,
        DoseDate,
        DoseTime,
        Indication,
        Route,
        Pharmacy,
        Prescriber,
        PrescriberSign
    )
    VALUES
    (
        @LabId,
        @PatientId,
        @MedicationId,
        @Dose,
        @DoseFrequency,
        @DoseDate,
        @DoseTime,
        @Indication,
        @Route,
        @Pharmacy,
        @Prescriber,
        @PrescriberSign
    );

    -- Optionally return the ID of the newly inserted record
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END

GO
/****** Object:  StoredProcedure [dbo].[InsertModule]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertModule]
    @UnitId                INT,
    @ModuleName            VARCHAR(150),
    @Description           NVARCHAR(500) = NULL,
    @CreatedBySupervisorId INT = NULL,
    @SortOrder             INT = 0,
    @CreateBlankPatient    BIT = 1,
    @PatientCount          INT = 5
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Unit] WHERE [Id] = @UnitId)
    BEGIN
        RAISERROR('Unit %d does not exist.', 16, 1, @UnitId);
        RETURN;
    END

    DECLARE @NewModuleId INT;
    DECLARE @i INT = 1;

    BEGIN TRAN;

        INSERT INTO [dbo].[Module]
            ([UnitId], [ModuleName], [Description], [SortOrder], [CreatedBySupervisorId])
        VALUES
            (@UnitId, @ModuleName, @Description, @SortOrder, @CreatedBySupervisorId);

        SET @NewModuleId = CAST(SCOPE_IDENTITY() AS INT);

        IF @CreateBlankPatient = 1
        BEGIN
            /* LabId 0 = global repository, not tied to any campus. See the
               note in CopyModule for why 0 rather than NULL.

               Numbered so an academic can tell the five apart before filling
               them in; the names are overwritten as soon as they do. */
            WHILE @i <= @PatientCount
            BEGIN
                INSERT INTO [dbo].[Patient]
                    ([FirstName], [LastName], [LabId], [ModuleId], [AdmitDate])
                VALUES
                    ('Patient', CAST(@i AS VARCHAR(10)), 0, @NewModuleId, GETDATE());

                SET @i = @i + 1;
            END
        END

    COMMIT TRAN;

    SELECT @NewModuleId AS Id;
END
GO
/****** Object:  StoredProcedure [dbo].[InsertNeurologicalAdministration]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertNeurologicalAdministration]
    @LabId INT,
    @PatientId INT,
    @NeurologicalChartId INT,
    @StartDate DATE,
    @StartTime VARCHAR(50) = NULL,
    @EndDate DATE,
    @EndTime VARCHAR(50) = NULL,
    @PharmacistReview VARCHAR(200) = NULL,
    @NurseSign VARCHAR(50) = NULL,
	@CoSign VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[NeurologicalAdministration]
    (
        LabId,
        PatientId,
        NeurologicalChartId,
        StartDate,
        StartTime,
        EndDate,
        EndTime,
        PharmacistReview,
        NurseSign,
		CoSign
    )
    VALUES
    (
        @LabId,
        @PatientId,
        @NeurologicalChartId,
        @StartDate,
        @StartTime,
        @EndDate,
        @EndTime,
        @PharmacistReview,
        @NurseSign,
		@CoSign
    );

    -- Optionally return the newly inserted Id
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END
GO
/****** Object:  StoredProcedure [dbo].[InsertNeurologicalChart]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertNeurologicalChart]
    @LabId INT,
    @PatientId INT,
	@Date DATE,
    @Time TIME,
    @EyesOpenScore INT NULL,
    @VerbalResponseScore VARCHAR(1) = NULL,  -- Supports 'T' for intubated
    @MotorResponseScore INT NULL,
    @TotalComaScale INT NULL,
    @EndotrachealTube BIT NULL,
    @RightPupilSize INT NULL,
    @RightPupilReaction VARCHAR(50) = NULL,
    @LeftPupilSize INT NULL,
    @LeftPupilReaction VARCHAR(50) = NULL,
    @RightArmResponse VARCHAR(50) = NULL,
    @RightLegResponse VARCHAR(50) = NULL,
    @LeftArmResponse VARCHAR(50) = NULL,
    @LeftLegResponse VARCHAR(50) = NULL,
	@OfficerSign VARCHAR(50) = NULL
   
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[NeurologicalChart]
    (
        LabId,   
		PatientId,
		[Date],
		[Time],
		EyesOpenScore,
		VerbalResponseScore,  -- Supports 'T' for intubated
		MotorResponseScore,
		TotalComaScale,
		EndotrachealTube,
		RightPupilSize,
		RightPupilReaction,
		LeftPupilSize,
		LeftPupilReaction,
		RightArmResponse,
		RightLegResponse,
		LeftArmResponse,
		LeftLegResponse,
		OfficerSign

    )
    VALUES
    (
		@LabId,
		@PatientId,
		@Date,
		@Time,
		@EyesOpenScore,
		@VerbalResponseScore,  -- Supports 'T' for intubated
		@MotorResponseScore,
		@TotalComaScale,
		@EndotrachealTube,
		@RightPupilSize,
		@RightPupilReaction,
		@LeftPupilSize,
		@LeftPupilReaction,
		@RightArmResponse,
		@RightLegResponse,
		@LeftArmResponse,
		@LeftLegResponse,
		@OfficerSign
    );
	    -- Optionally return the newly inserted Id
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END
GO
/****** Object:  StoredProcedure [dbo].[InsertPatient]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertPatient]
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @DateOfBirth DATETIME,
    @Gender VARCHAR(10),
    @Address NVARCHAR(200),
    @AdmitDate DATETIME,
    @Weight VARCHAR(10),
    @Height VARCHAR(10),
    @Age VARCHAR(10),
    @Allergy VARCHAR(200),
    @Intolerance VARCHAR(200),
    @LabId INT,
    @UriNumber VARCHAR(50)
AS
BEGIN
    INSERT INTO Patient (
        [FirstName],
        [LastName],
        [DateOfBirth],
        [Gender],
        [Address],
        [AdmitDate],
        [Weight],
        [Height],
        [Age],
        [Allergy],
        [Intolerance],
        [LabId],
        [UriNumber]
    ) VALUES (
        @FirstName,
        @LastName,
        @DateOfBirth,
        @Gender,
        @Address,
        @AdmitDate,
        @Weight,
        @Height,
        @Age,
        @Allergy,
        @Intolerance,
        @LabId,
        @UriNumber
    );

	-- Optionally return the newly inserted Id
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END

GO
/****** Object:  StoredProcedure [dbo].[InsertPatientAdds]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertPatientAdds]
    @PatientId INT,
    @LabId INT,
    @EnteredDate DATE,
    @EnteredTime VARCHAR(20),
    @RespiratoryRate VARCHAR(20) = NULL,
    @HeartRate VARCHAR(20) = NULL,
    @Temperature VARCHAR(20) = NULL,
    @Consciousness VARCHAR(50) = NULL,
    @OxygenSaturation VARCHAR(20) = NULL,
    @OxygenFlow VARCHAR(20) = NULL,
    @ModeOfDelivery VARCHAR(50) = NULL,
    @BloodPressure VARCHAR(20) = NULL,
    @BloodPressureDiastolic VARCHAR(20) = NULL,

    @RespiratoryRateValue INT = NULL,
    @OxygenSaturationValue INT = NULL,
    @BloodPressureValue INT = NULL,
    @BloodPressureDiastolicValue INT = NULL,
    @HeartRateValue INT = NULL,
    @TemperatureValue INT = NULL,

    @RespiratoryAlert INT = NULL,
    @OxygenSaturationAlert INT = NULL,
    @BloodPressureAlert INT = NULL,
    @HeartRateAlert INT = NULL,
    @ConsciousnessAlert INT = NULL,
    @TotalScore INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF (@RespiratoryAlert = 1 OR @OxygenSaturationAlert = 1 OR @BloodPressureAlert = 1 OR @HeartRateAlert = 1 OR @ConsciousnessAlert = 1)
    BEGIN
        UPDATE Patient SET Alert = 1
        WHERE Id = @PatientId AND (ISNULL(@LabId, 0) = 0 OR LabId = @LabId)
    END

    INSERT INTO PatientAdds
        (PatientId, LabId, EnteredDate, EnteredTime, RespiratoryRate, HeartRate, Temperature, Consciousness,
         OxygenSaturation, OxygenFlow, ModeOfDelivery, BloodPressure, BloodPressureDiastolic,
         RespiratoryRateValue, OxygenSaturationValue, BloodPressureValue, BloodPressureDiastolicValue,
         HeartRateValue, TemperatureValue,
         RespiratoryAlert, OxygenSaturationAlert, BloodPressureAlert, HeartRateAlert, ConsciousnessAlert, TotalScore)
    VALUES
        (@PatientId, @LabId, @EnteredDate, @EnteredTime, @RespiratoryRate, @HeartRate, @Temperature, @Consciousness,
         @OxygenSaturation, @OxygenFlow, @ModeOfDelivery, @BloodPressure, @BloodPressureDiastolic,
         @RespiratoryRateValue, @OxygenSaturationValue, @BloodPressureValue, @BloodPressureDiastolicValue,
         @HeartRateValue, @TemperatureValue,
         @RespiratoryAlert, @OxygenSaturationAlert, @BloodPressureAlert, @HeartRateAlert, @ConsciousnessAlert, @TotalScore);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END
GO
/****** Object:  StoredProcedure [dbo].[InsertPatientFallRisk]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[InsertPatientFallRisk]
  @LabId int,
  @PatientId int,
  @RecentFallsScore int,
  @MedicationsScore int,
  @PsychologicalScore int,
  @CognitiveScore int,
  @TotalScore int,
  @RiskLevel nvarchar(20) = NULL,
  @AssessedAt datetime2,
  @Assessor nvarchar(128) = NULL,
  @Notes nvarchar(max) = NULL,
  @AutoCondChange bit = NULL,
  @AutoDizziness bit = NULL,
  @AutoAnaesthetic bit = NULL,
  @InterventionNotes nvarchar(max) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO dbo.FallRiskAssessments (
    LabId, PatientId, RecentFallsScore, MedicationsScore, PsychologicalScore, CognitiveScore,
    TotalScore, RiskLevel, AssessedAt, Assessor, Notes,
    AutoCondChange, AutoDizziness, AutoAnaesthetic, InterventionNotes
  )
  VALUES (
    @LabId, @PatientId, @RecentFallsScore, @MedicationsScore, @PsychologicalScore, @CognitiveScore,
    @TotalScore, @RiskLevel, @AssessedAt, @Assessor, @Notes,
    @AutoCondChange, @AutoDizziness, @AutoAnaesthetic, @InterventionNotes
  );

  SELECT SCOPE_IDENTITY();
END
GO
/****** Object:  StoredProcedure [dbo].[InsertPolicy]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ---------------------------------------------------------------------------
-- Policies: insert an uploaded document
-- ---------------------------------------------------------------------------
CREATE   PROCEDURE [dbo].[InsertPolicy]
    @LabId          INT,
    @FileName       NVARCHAR(255),
    @DisplayName    NVARCHAR(255),
    @FileSizeString NVARCHAR(50),
    @FileData       VARBINARY(MAX),
    @UploadedDate   DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Policies (LabId, FileName, DisplayName, FileSizeString, FileData, UploadedDate)
    VALUES (@LabId, @FileName, @DisplayName, @FileSizeString, @FileData, @UploadedDate);
END
GO
/****** Object:  StoredProcedure [dbo].[InsertProgressNote]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[InsertProgressNote]
    @LabId INT = NULL,
    @Notes TEXT = NULL,
    @Sign VARCHAR(50) = NULL,
    @NotesDate DATETIME = NULL,
    @PatientId INT = NULL,
	@NotesFrom VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ProgressNotes (LabId, Notes, Sign, NotesDate, PatientId, NotesFrom)
    VALUES (@LabId, @Notes, @Sign, @NotesDate, @PatientId, @NotesFrom);

    -- Return the Id of the newly inserted record
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END


GO
/****** Object:  StoredProcedure [dbo].[InsertRiskmanIncident]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[InsertRiskmanIncident]
    @LabId INT,
    @PatientId INT,
    @IncidentDate DATE = NULL,
    @IncidentTime VARCHAR(50) = NULL,
    @URINumber NVARCHAR(50) = NULL,
    @Campus NVARCHAR(50) = NULL,
    @WardLocationType NVARCHAR(100) = NULL,
    @PersonName NVARCHAR(100) = NULL,
    @DateOfBirth DATE = NULL,
    @Sex NVARCHAR(40) = NULL,
    @IndigenousStatus NVARCHAR(120) = NULL,
    @BriefSummary NVARCHAR(200) = NULL,
    @Details NVARCHAR(MAX) = NULL,
    @EventType NVARCHAR(60) = NULL,
    @EventSubType NVARCHAR(200) = NULL,

    -- #4 Clinical Incident (Apse is now BIT)
    @IsClinicalIncident            BIT            = NULL,
    @Apse                          BIT            = NULL,
    @ClinicalHarmLevel             NVARCHAR(20)   = NULL,
    @HarmDuration                  NVARCHAR(20)   = NULL,
    @RequiredCareLevelClinical     NVARCHAR(40)   = NULL,

    -- #5 Emergency Response
    @EmergencyResponseType         NVARCHAR(40)   = NULL,
    @EmergencyResponseOutcome      NVARCHAR(80)   = NULL,

    -- #6 Contributing Factors
    @ContributingAdditionalDetail  NVARCHAR(MAX)  = NULL,
    @ContributingFactorsCsv        NVARCHAR(MAX)  = NULL,

    -- #7 OHS
    @ReporterIsAffectedStaff       BIT            = NULL,
    @OhsTypeOfInjury               NVARCHAR(80)   = NULL,
    @OhsTypeOfInjuryOther          NVARCHAR(120)  = NULL,
    @OhsBodyPartAffected           NVARCHAR(80)   = NULL,
    @OhsBodyPartOther              NVARCHAR(120)  = NULL,
    @OhsLevelOfHarmSustained       NVARCHAR(40)   = NULL,
    @OhsRequiredLevelOfCare        NVARCHAR(80)   = NULL,
    @OhsActionsRequired            NVARCHAR(MAX)  = NULL,

    @NextOfKinNotifiedDate DATE = NULL,
    @NextOfKinNotifiedTime VARCHAR(50) = NULL,

    -- Sign Off
    @SignedBy                      NVARCHAR(100)  = NULL,
    @SignedDate                    DATE           = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO dbo.RiskmanIncident
        (
            LabId, PatientId, IncidentDate, IncidentTime, URINumber,
            Campus, WardLocationType, PersonName, DateOfBirth, Sex, IndigenousStatus,
            BriefSummary, Details, EventType, EventSubType,
            IsClinicalIncident, Apse, ClinicalHarmLevel, HarmDuration, RequiredCareLevelClinical,
            EmergencyResponseType, EmergencyResponseOutcome,
            ContributingAdditionalDetail,
            ReporterIsAffectedStaff, OhsTypeOfInjury, OhsTypeOfInjuryOther, OhsBodyPartAffected, OhsBodyPartOther,
            OhsLevelOfHarmSustained, OhsRequiredLevelOfCare, OhsActionsRequired,
			NextOfKinNotifiedDate, NextOfKinNotifiedTime,
            SignedBy, SignedDate
        )
        VALUES
        (
            @LabId, @PatientId, @IncidentDate, @IncidentTime, @URINumber,
            @Campus, @WardLocationType, @PersonName, @DateOfBirth, @Sex, @IndigenousStatus,
            @BriefSummary, @Details, @EventType, @EventSubType,
            @IsClinicalIncident, @Apse, @ClinicalHarmLevel, @HarmDuration, @RequiredCareLevelClinical,
            @EmergencyResponseType, @EmergencyResponseOutcome,
            @ContributingAdditionalDetail,
            @ReporterIsAffectedStaff, @OhsTypeOfInjury, @OhsTypeOfInjuryOther, @OhsBodyPartAffected, @OhsBodyPartOther,
            @OhsLevelOfHarmSustained, @OhsRequiredLevelOfCare, @OhsActionsRequired,
			@NextOfKinNotifiedDate, @NextOfKinNotifiedTime,
            @SignedBy, @SignedDate
        );

        DECLARE @NewId INT = CAST(SCOPE_IDENTITY() AS INT);

        IF (@ContributingFactorsCsv IS NOT NULL AND LTRIM(RTRIM(@ContributingFactorsCsv)) <> '')
        BEGIN
            INSERT INTO dbo.RiskmanIncidentContributingFactor(IncidentId, FactorCode)
            SELECT @NewId, LTRIM(RTRIM(value))
            FROM STRING_SPLIT(@ContributingFactorsCsv, ',');
        END

        COMMIT;
        SELECT @NewId AS Id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[InsertUnit]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertUnit]
    @YearLevelId INT,
    @UnitCode    VARCHAR(20) = NULL,
    @UnitName    VARCHAR(100),
    @SortOrder   INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[Unit] ([YearLevelId], [UnitCode], [UnitName], [SortOrder])
    VALUES (@YearLevelId, @UnitCode, @UnitName, @SortOrder);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END
GO
/****** Object:  StoredProcedure [dbo].[InsertYearLevel]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertYearLevel]
    @YearLevelName VARCHAR(50),
    @SortOrder     INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[YearLevel] ([YearLevelName], [SortOrder])
    VALUES (@YearLevelName, @SortOrder);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END
GO
/****** Object:  StoredProcedure [dbo].[LoadModuleIntoLab]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[LoadModuleIntoLab]
    @ModuleId INT,
    @LabId    INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Module] WHERE [Id] = @ModuleId)
    BEGIN
        RAISERROR('Module %d does not exist.', 16, 1, @ModuleId);
        RETURN;
    END

    /* Guard against loading into the module scope itself. LabId 0 is the marker
       for module-owned rows, so a copy taken with LabId 0 would be
       indistinguishable from the master and would corrupt the repository. */
    IF ISNULL(@LabId, 0) = 0
    BEGIN
        RAISERROR('A module must be loaded into a real lab. LabId 0 is reserved for the repository itself.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Patient] WHERE [ModuleId] = @ModuleId)
    BEGIN
        RAISERROR('Module %d has no patient to load. Populate it first.', 16, 1, @ModuleId);
        RETURN;
    END

    DECLARE @Deleted  TABLE (TableName NVARCHAR(100), RowsDeleted INT);
    DECLARE @Patients TABLE (PatientId INT PRIMARY KEY);

    /* old -> new key maps */
    DECLARE @MapPatient  TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapFbc      TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapFood     TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapIvChart  TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapRegChart TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapPrnChart TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapNeuro    TABLE (OldId INT PRIMARY KEY, NewId INT);
    DECLARE @MapRiskman  TABLE (OldId INT PRIMARY KEY, NewId INT);

    /* The previous copy of THIS module in THIS lab, and nothing else. Ordinary
       campus patients have SourceModuleId NULL and are never matched. */
    INSERT INTO @Patients (PatientId)
    SELECT [Id] FROM [dbo].[Patient]
    WHERE [SourceModuleId] = @ModuleId AND [LabId] = @LabId;

    DECLARE @ReplacedPatientCount INT = (SELECT COUNT(*) FROM @Patients);

    BEGIN TRAN;

        /* --- 1. remove the previous copy, if there is one ------------------ */
/* --- child rows first ------------------------------------------- */
        DELETE e FROM [dbo].[FluidBalanceChartEntry] e
        INNER JOIN [dbo].[FluidBalanceChart] c ON c.[Id] = e.[FluidBalanceChartId]
        WHERE c.[PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('FluidBalanceChartEntry', @@ROWCOUNT);

        DELETE i FROM [dbo].[FoodIntakeItem] i
        INNER JOIN [dbo].[FoodIntakeHeader] h ON h.[Id] = i.[HeaderId]
        WHERE h.[PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('FoodIntakeItem', @@ROWCOUNT);

        DELETE f FROM [dbo].[RiskmanIncidentContributingFactor] f
        INNER JOIN [dbo].[RiskmanIncident] r ON r.[Id] = f.[IncidentId]
        WHERE r.[PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('RiskmanIncidentContributingFactor', @@ROWCOUNT);

        DELETE FROM [dbo].[IvFluidAdministration]           WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('IvFluidAdministration', @@ROWCOUNT);

        DELETE FROM [dbo].[MedicationRegularAdministration] WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('MedicationRegularAdministration', @@ROWCOUNT);

        DELETE FROM [dbo].[MedicationPrnAdministration]     WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('MedicationPrnAdministration', @@ROWCOUNT);

        DELETE FROM [dbo].[NeurologicalAdministration]      WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('NeurologicalAdministration', @@ROWCOUNT);

        /* --- parent chart rows ------------------------------------------ */
        DELETE FROM [dbo].[FluidBalanceChart]      WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('FluidBalanceChart', @@ROWCOUNT);

        DELETE FROM [dbo].[FoodIntakeHeader]       WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('FoodIntakeHeader', @@ROWCOUNT);

        DELETE FROM [dbo].[IvFluidChart]           WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('IvFluidChart', @@ROWCOUNT);

        DELETE FROM [dbo].[MedicationRegularChart] WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('MedicationRegularChart', @@ROWCOUNT);

        DELETE FROM [dbo].[MedicationPrnChart]     WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('MedicationPrnChart', @@ROWCOUNT);

        DELETE FROM [dbo].[NeurologicalChart]      WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('NeurologicalChart', @@ROWCOUNT);

        DELETE FROM [dbo].[RiskmanIncident]        WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('RiskmanIncident', @@ROWCOUNT);

        DELETE FROM [dbo].[BradenAssessment]       WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('BradenAssessment', @@ROWCOUNT);

        DELETE FROM [dbo].[FallRiskAssessments]    WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('FallRiskAssessments', @@ROWCOUNT);

        DELETE FROM [dbo].[PatientAdds]            WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('PatientAdds', @@ROWCOUNT);

        DELETE FROM [dbo].[ProgressNotes]          WHERE [PatientId] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('ProgressNotes', @@ROWCOUNT);

        DELETE FROM [dbo].[Patient]
        WHERE [Id] IN (SELECT PatientId FROM @Patients);
        INSERT INTO @Deleted VALUES ('Patient', @@ROWCOUNT);

        /* --- 2. the patient ------------------------------------------------ */
        SELECT * INTO #SrcPatient
        FROM [dbo].[Patient] WHERE [ModuleId] = @ModuleId;

        MERGE INTO [dbo].[Patient] AS tgt
        USING #SrcPatient AS src
           ON 1 = 0
        WHEN NOT MATCHED THEN
            INSERT ([FirstName], [LastName], [DateOfBirth], [Gender], [Address], [AdmitDate],
                    [Weight], [Height], [Age], [Allergy], [Intolerance], [Alerts],
                    [LabId], [UriNumber], [Alert], [ModuleId], [SourceModuleId], [LoadedIntoLabAt])
            VALUES (src.[FirstName], src.[LastName], src.[DateOfBirth], src.[Gender], src.[Address], src.[AdmitDate],
                    src.[Weight], src.[Height], src.[Age], src.[Allergy], src.[Intolerance], src.[Alerts],
                    @LabId, src.[UriNumber], src.[Alert], NULL, @ModuleId, GETDATE())
        OUTPUT src.[Id], inserted.[Id] INTO @MapPatient (OldId, NewId);

        /* --- 3. the charts, generated from the CopyModule in Sprint3_06 ------ */
    INSERT INTO [dbo].[BradenAssessment]
        ([LabId], [PatientId], [DateOfAssessment], [NurseInitials], [Sensory], [Moisture],
         [Activity], [Mobility], [Nutrition], [Friction], [TotalScore], [RiskKey], [Shift])
    SELECT @LabId, mp.NewId, s.[DateOfAssessment], s.[NurseInitials], s.[Sensory], s.[Moisture],
           s.[Activity], s.[Mobility], s.[Nutrition], s.[Friction], s.[TotalScore], s.[RiskKey], s.[Shift]
    FROM [dbo].[BradenAssessment] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    INSERT INTO [dbo].[FallRiskAssessments]
        ([LabId], [PatientId], [RecentFallsScore], [MedicationsScore], [PsychologicalScore],
         [CognitiveScore], [TotalScore], [RiskLevel], [AssessedAt], [Assessor], [Notes],
         [AutoCondChange], [AutoDizziness], [AutoAnaesthetic], [InterventionNotes])
    SELECT @LabId, mp.NewId, s.[RecentFallsScore], s.[MedicationsScore], s.[PsychologicalScore],
           s.[CognitiveScore], s.[TotalScore], s.[RiskLevel], s.[AssessedAt], s.[Assessor], s.[Notes],
           s.[AutoCondChange], s.[AutoDizziness], s.[AutoAnaesthetic], s.[InterventionNotes]
    FROM [dbo].[FallRiskAssessments] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    INSERT INTO [dbo].[PatientAdds]
        ([PatientId], [EnteredDate], [EnteredTime], [RespiratoryRate], [HeartRate], [Temperature],
         [Consciousness], [OxygenSaturation], [OxygenFlow], [ModeOfDelivery], [BloodPressure], [LabId],
         [RespiratoryRateValue], [OxygenSaturationValue], [BloodPressureValue], [HeartRateValue],
         [TemperatureValue], [RespiratoryAlert], [OxygenSaturationAlert], [BloodPressureAlert],
         [HeartRateAlert], [ConsciousnessAlert], [TotalScore], [BloodPressureDiastolicValue],
         [BloodPressureDiastolic])
    SELECT mp.NewId, s.[EnteredDate], s.[EnteredTime], s.[RespiratoryRate], s.[HeartRate], s.[Temperature],
           s.[Consciousness], s.[OxygenSaturation], s.[OxygenFlow], s.[ModeOfDelivery], s.[BloodPressure], @LabId,
           s.[RespiratoryRateValue], s.[OxygenSaturationValue], s.[BloodPressureValue], s.[HeartRateValue],
           s.[TemperatureValue], s.[RespiratoryAlert], s.[OxygenSaturationAlert], s.[BloodPressureAlert],
           s.[HeartRateAlert], s.[ConsciousnessAlert], s.[TotalScore], s.[BloodPressureDiastolicValue],
           s.[BloodPressureDiastolic]
    FROM [dbo].[PatientAdds] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    INSERT INTO [dbo].[ProgressNotes]
        ([LabId], [Notes], [Sign], [NotesDate], [PatientId], [NotesFrom])
    SELECT @LabId, s.[Notes], s.[Sign], s.[NotesDate], mp.NewId, s.[NotesFrom]
    FROM [dbo].[ProgressNotes] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    /* --- 4. fluid balance chart + entries --------------------------------- */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcFbc
    FROM [dbo].[FluidBalanceChart] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[FluidBalanceChart] AS tgt
    USING #SrcFbc AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [ChartDate], [ChartTime], [PreviousDayBalance],
                [TotalIntake], [TotalOutput], [Balance], [TotalBalance], [ClinicalNotes],
                [SignatureData], [CreatedDateTime], [UpdatedDateTime])
        VALUES (@LabId, src.NewPatientId, src.[ChartDate], src.[ChartTime], src.[PreviousDayBalance],
                src.[TotalIntake], src.[TotalOutput], src.[Balance], src.[TotalBalance], src.[ClinicalNotes],
                src.[SignatureData], src.[CreatedDateTime], src.[UpdatedDateTime])
    OUTPUT src.[Id], inserted.[Id] INTO @MapFbc (OldId, NewId);

    INSERT INTO [dbo].[FluidBalanceChartEntry]
        ([FluidBalanceChartId], [EntryTime], [EntryType], [Category], [AmountMl],
         [CreatedDateTime], [EntryDate], [Initials])
    SELECT mf.NewId, s.[EntryTime], s.[EntryType], s.[Category], s.[AmountMl],
           s.[CreatedDateTime], s.[EntryDate], s.[Initials]
    FROM [dbo].[FluidBalanceChartEntry] s
    INNER JOIN @MapFbc mf ON mf.OldId = s.[FluidBalanceChartId];

    /* --- 5. food intake header + items ------------------------------------ */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcFood
    FROM [dbo].[FoodIntakeHeader] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[FoodIntakeHeader] AS tgt
    USING #SrcFood AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [DayText], [IntakeDate],
                [Shift1Signature], [Shift1Designation], [Shift2Signature], [Shift2Designation],
                [Shift3Signature], [Shift3Designation], [BreakfastComment], [MorningTeaComment],
                [LunchComment], [AfternoonTeaComment], [DinnerComment], [SupperComment])
        VALUES (@LabId, src.NewPatientId, src.[DayText], src.[IntakeDate],
                src.[Shift1Signature], src.[Shift1Designation], src.[Shift2Signature], src.[Shift2Designation],
                src.[Shift3Signature], src.[Shift3Designation], src.[BreakfastComment], src.[MorningTeaComment],
                src.[LunchComment], src.[AfternoonTeaComment], src.[DinnerComment], src.[SupperComment])
    OUTPUT src.[Id], inserted.[Id] INTO @MapFood (OldId, NewId);

    INSERT INTO [dbo].[FoodIntakeItem] ([HeaderId], [Meal], [Label], [Notes], [Amount])
    SELECT mh.NewId, s.[Meal], s.[Label], s.[Notes], s.[Amount]
    FROM [dbo].[FoodIntakeItem] s
    INNER JOIN @MapFood mh ON mh.OldId = s.[HeaderId];

    /* --- 6. IV fluid chart + administrations ------------------------------ */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcIvChart
    FROM [dbo].[IvFluidChart] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[IvFluidChart] AS tgt
    USING #SrcIvChart AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [Date], [FlaskVol], [Strength], [Rate], [Dose], [OfficerSign])
        VALUES (@LabId, src.NewPatientId, src.[Date], src.[FlaskVol], src.[Strength], src.[Rate], src.[Dose], src.[OfficerSign])
    OUTPUT src.[Id], inserted.[Id] INTO @MapIvChart (OldId, NewId);

    INSERT INTO [dbo].[IvFluidAdministration]
        ([LabId], [PatientId], [IvFluidChartId], [StartDate], [StartTime], [EndDate], [EndTime],
         [VolGiven], [PharmacistReview], [NurseSign], [CoSign])
    SELECT @LabId, mp.NewId, mc.NewId, s.[StartDate], s.[StartTime], s.[EndDate], s.[EndTime],
           s.[VolGiven], s.[PharmacistReview], s.[NurseSign], s.[CoSign]
    FROM [dbo].[IvFluidAdministration] s
    INNER JOIN @MapIvChart mc ON mc.OldId = s.[IvFluidChartId]
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    /* --- 7. regular medication chart + administrations -------------------- */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcRegChart
    FROM [dbo].[MedicationRegularChart] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[MedicationRegularChart] AS tgt
    USING #SrcRegChart AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [MedicationId], [Dose], [DoseFrequency], [DoseDate], [DoseTime],
                [Indication], [Route], [Pharmacy], [Prescriber], [PrescriberSign])
        VALUES (@LabId, src.NewPatientId, src.[MedicationId], src.[Dose], src.[DoseFrequency], src.[DoseDate], src.[DoseTime],
                src.[Indication], src.[Route], src.[Pharmacy], src.[Prescriber], src.[PrescriberSign])
    OUTPUT src.[Id], inserted.[Id] INTO @MapRegChart (OldId, NewId);

    INSERT INTO [dbo].[MedicationRegularAdministration]
        ([LabId], [PatientId], [PatientMedicationChartId], [DoseDate], [DoseTime], [Route],
         [StudentSign], [Reason], [CoSign], [Dose])
    SELECT @LabId, mp.NewId, mc.NewId, s.[DoseDate], s.[DoseTime], s.[Route],
           s.[StudentSign], s.[Reason], s.[CoSign], s.[Dose]
    FROM [dbo].[MedicationRegularAdministration] s
    INNER JOIN @MapRegChart mc ON mc.OldId = s.[PatientMedicationChartId]
    INNER JOIN @MapPatient  mp ON mp.OldId = s.[PatientId];

    /* --- 8. PRN medication chart + administrations ------------------------ */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcPrnChart
    FROM [dbo].[MedicationPrnChart] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[MedicationPrnChart] AS tgt
    USING #SrcPrnChart AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [MedicationId], [Dose], [DoseFrequency], [DoseDate], [DoseTime],
                [Indication], [Route], [Pharmacy], [Prescriber], [PrescriberSign])
        VALUES (@LabId, src.NewPatientId, src.[MedicationId], src.[Dose], src.[DoseFrequency], src.[DoseDate], src.[DoseTime],
                src.[Indication], src.[Route], src.[Pharmacy], src.[Prescriber], src.[PrescriberSign])
    OUTPUT src.[Id], inserted.[Id] INTO @MapPrnChart (OldId, NewId);

    INSERT INTO [dbo].[MedicationPrnAdministration]
        ([LabId], [PatientId], [PatientMedicationChartId], [DoseDate], [DoseTime], [Route],
         [StudentSign], [Reason], [CoSign], [Dose])
    SELECT @LabId, mp.NewId, mc.NewId, s.[DoseDate], s.[DoseTime], s.[Route],
           s.[StudentSign], s.[Reason], s.[CoSign], s.[Dose]
    FROM [dbo].[MedicationPrnAdministration] s
    INNER JOIN @MapPrnChart mc ON mc.OldId = s.[PatientMedicationChartId]
    INNER JOIN @MapPatient  mp ON mp.OldId = s.[PatientId];

    /* --- 9. neurological chart + administrations -------------------------- */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcNeuro
    FROM [dbo].[NeurologicalChart] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[NeurologicalChart] AS tgt
    USING #SrcNeuro AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [Date], [Time], [EyesOpenScore], [VerbalResponseScore],
                [MotorResponseScore], [TotalComaScale], [EndotrachealTube], [RightPupilSize],
                [RightPupilReaction], [LeftPupilSize], [LeftPupilReaction], [RightArmResponse],
                [RightLegResponse], [LeftArmResponse], [LeftLegResponse], [OfficerSign])
        VALUES (@LabId, src.NewPatientId, src.[Date], src.[Time], src.[EyesOpenScore], src.[VerbalResponseScore],
                src.[MotorResponseScore], src.[TotalComaScale], src.[EndotrachealTube], src.[RightPupilSize],
                src.[RightPupilReaction], src.[LeftPupilSize], src.[LeftPupilReaction], src.[RightArmResponse],
                src.[RightLegResponse], src.[LeftArmResponse], src.[LeftLegResponse], src.[OfficerSign])
    OUTPUT src.[Id], inserted.[Id] INTO @MapNeuro (OldId, NewId);

    INSERT INTO [dbo].[NeurologicalAdministration]
        ([LabId], [PatientId], [NeurologicalChartId], [StartDate], [StartTime], [EndDate], [EndTime],
         [PharmacistReview], [NurseSign], [CoSign])
    SELECT @LabId, mp.NewId, mc.NewId, s.[StartDate], s.[StartTime], s.[EndDate], s.[EndTime],
           s.[PharmacistReview], s.[NurseSign], s.[CoSign]
    FROM [dbo].[NeurologicalAdministration] s
    INNER JOIN @MapNeuro   mc ON mc.OldId = s.[NeurologicalChartId]
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    /* --- 10. riskman incident + contributing factors ---------------------- */
    SELECT s.*, mp.NewId AS NewPatientId
    INTO #SrcRiskman
    FROM [dbo].[RiskmanIncident] s
    INNER JOIN @MapPatient mp ON mp.OldId = s.[PatientId];

    MERGE INTO [dbo].[RiskmanIncident] AS tgt
    USING #SrcRiskman AS src
       ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT ([LabId], [PatientId], [IncidentDate], [IncidentTime], [URINumber], [Campus],
                [WardLocationType], [PersonName], [DateOfBirth], [Sex], [IndigenousStatus],
                [BriefSummary], [Details], [EventType], [EventSubType], [IsClinicalIncident],
                [ClinicalHarmLevel], [HarmDuration], [RequiredCareLevelClinical],
                [EmergencyResponseType], [EmergencyResponseOutcome], [ContributingAdditionalDetail],
                [ReporterIsAffectedStaff], [OhsTypeOfInjury], [OhsTypeOfInjuryOther],
                [OhsBodyPartAffected], [OhsBodyPartOther], [OhsLevelOfHarmSustained],
                [OhsRequiredLevelOfCare], [OhsActionsRequired], [nextOfKinNotifiedDate],
                [nextOfKinNotifiedTime], [SignedBy], [SignedDate], [Apse])
        VALUES (@LabId, src.NewPatientId, src.[IncidentDate], src.[IncidentTime], src.[URINumber], src.[Campus],
                src.[WardLocationType], src.[PersonName], src.[DateOfBirth], src.[Sex], src.[IndigenousStatus],
                src.[BriefSummary], src.[Details], src.[EventType], src.[EventSubType], src.[IsClinicalIncident],
                src.[ClinicalHarmLevel], src.[HarmDuration], src.[RequiredCareLevelClinical],
                src.[EmergencyResponseType], src.[EmergencyResponseOutcome], src.[ContributingAdditionalDetail],
                src.[ReporterIsAffectedStaff], src.[OhsTypeOfInjury], src.[OhsTypeOfInjuryOther],
                src.[OhsBodyPartAffected], src.[OhsBodyPartOther], src.[OhsLevelOfHarmSustained],
                src.[OhsRequiredLevelOfCare], src.[OhsActionsRequired], src.[nextOfKinNotifiedDate],
                src.[nextOfKinNotifiedTime], src.[SignedBy], src.[SignedDate], src.[Apse])
    OUTPUT src.[Id], inserted.[Id] INTO @MapRiskman (OldId, NewId);

    INSERT INTO [dbo].[RiskmanIncidentContributingFactor] ([IncidentId], [FactorCode])
    SELECT mr.NewId, s.[FactorCode]
    FROM [dbo].[RiskmanIncidentContributingFactor] s
    INNER JOIN @MapRiskman mr ON mr.OldId = s.[IncidentId];
    COMMIT TRAN;

    SELECT
        (SELECT TOP 1 NewId FROM @MapPatient)        AS PatientId,
        @ModuleId                                    AS ModuleId,
        @LabId                                       AS LabId,
        @ReplacedPatientCount                        AS ReplacedExistingCopy,
        (SELECT ISNULL(SUM(RowsDeleted), 0) FROM @Deleted) AS RowsRemoved;
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateFoodIntake]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateFoodIntake]

  @Id                 INT,
  @LabId              INT,
  @PatientId          INT,
  @DayText            NVARCHAR(10) = NULL,
  @IntakeDate         DATE,
  @Shift1Signature    NVARCHAR(40) = NULL,
  @Shift1Designation  NVARCHAR(40) = NULL,
  @Shift2Signature    NVARCHAR(40) = NULL,
  @Shift2Designation  NVARCHAR(40) = NULL,
  @Shift3Signature    NVARCHAR(40) = NULL,
  @Shift3Designation  NVARCHAR(40) = NULL,
  @BreakfastComment    NVARCHAR(200) = NULL,
  @MorningTeaComment   NVARCHAR(200) = NULL,
  @LunchComment        NVARCHAR(200) = NULL,
  @AfternoonTeaComment NVARCHAR(200) = NULL,
  @DinnerComment       NVARCHAR(200) = NULL,
  @SupperComment       NVARCHAR(200) = NULL,
  @ItemsJson          NVARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (
    SELECT 1 FROM dbo.FoodIntakeHeader
    WHERE Id=@Id AND (ISNULL(@LabId, 0) = 0 OR LabId=@LabId) AND PatientId=@PatientId
  )
  BEGIN
    SELECT CAST(0 AS INT); RETURN;
  END

  UPDATE dbo.FoodIntakeHeader
  SET DayText            = @DayText,
      IntakeDate         = @IntakeDate,
      Shift1Signature    = @Shift1Signature,
      Shift1Designation  = @Shift1Designation,
      Shift2Signature    = @Shift2Signature,
      Shift2Designation  = @Shift2Designation,
      Shift3Signature    = @Shift3Signature,
      Shift3Designation  = @Shift3Designation,
      BreakfastComment    = @BreakfastComment,
      MorningTeaComment   = @MorningTeaComment,
      LunchComment        = @LunchComment,
      AfternoonTeaComment = @AfternoonTeaComment,
      DinnerComment       = @DinnerComment,
      SupperComment       = @SupperComment
  WHERE Id=@Id;

  DELETE FROM dbo.FoodIntakeItem WHERE HeaderId=@Id;

  INSERT INTO dbo.FoodIntakeItem (HeaderId, Meal, Label, Notes, Amount)
  SELECT
    @Id, j.Meal, j.Label, j.Notes, j.Amount
  FROM OPENJSON(@ItemsJson)
  WITH (
    Meal   NVARCHAR(30)  '$.Meal',
    Label  NVARCHAR(50)  '$.Label',
    Notes  NVARCHAR(200) '$.Notes',
    Amount NVARCHAR(10)  '$.Amount'
  ) AS j;

  SELECT CAST(1 AS INT);
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateModule]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateModule]
    @Id          INT,
    @ModuleName  VARCHAR(150),
    @Description NVARCHAR(500) = NULL,
    @UnitId      INT = 0,
    @SortOrder   INT = 0,
    @Active      BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [dbo].[Module]
       SET [ModuleName]  = @ModuleName,
           [Description] = @Description,
           [UnitId]      = CASE WHEN @UnitId = 0 THEN [UnitId] ELSE @UnitId END,
           [SortOrder]   = @SortOrder,
           [Active]      = @Active,
           [UpdatedDate] = GETDATE()
     WHERE [Id] = @Id;
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO
/****** Object:  StoredProcedure [dbo].[UpdatePatient]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdatePatient]
    @Id INT,
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @DateOfBirth DATETIME,
    @Gender VARCHAR(10),
    @Address NVARCHAR(200),
    @AdmitDate DATETIME,
    @Weight VARCHAR(10),
    @Height VARCHAR(10),
    @Age VARCHAR(10),
    @Allergy VARCHAR(200),
    @Intolerance VARCHAR(200),
    @LabId INT,
    @UriNumber VARCHAR(50)
AS
BEGIN
    UPDATE Patient
    SET 
        [FirstName] = @FirstName,
        [LastName] = @LastName,
        [DateOfBirth] = @DateOfBirth,
        [Gender] = @Gender,
        [Address] = @Address,
        [AdmitDate] = @AdmitDate,
        [Weight] = @Weight,
        [Height] = @Height,
        [Age] = @Age,
        [Allergy] = @Allergy,
        [Intolerance] = @Intolerance,
        [LabId] = @LabId,
        [UriNumber] = @UriNumber
    WHERE 
        [Id] = @Id;

		-- Check if any rows were affected
    IF @@ROWCOUNT = 0
    BEGIN
        -- Optionally return an error or handle no rows affected
        RAISERROR('No record found with the given Id.', 16, 1);
    END
END

GO
/****** Object:  StoredProcedure [dbo].[UpdatePatientAdds]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdatePatientAdds]
    @Id INT = 0,
    @PatientId INT,
    @LabId INT,
    @RespiratoryRate VARCHAR(20) = NULL,
    @HeartRate VARCHAR(20) = NULL,
    @Temperature VARCHAR(20) = NULL,
    @Consciousness VARCHAR(50) = NULL,
    @OxygenSaturation VARCHAR(20) = NULL,
    @OxygenFlow VARCHAR(20) = NULL,
    @ModeOfDelivery VARCHAR(50) = NULL,
    @BloodPressure VARCHAR(20) = NULL,
    @BloodPressureDiastolic VARCHAR(20) = NULL,

    @RespiratoryRateValue INT = NULL,
    @OxygenSaturationValue INT = NULL,
    @BloodPressureValue INT = NULL,
    @BloodPressureDiastolicValue INT = NULL,
    @HeartRateValue INT = NULL,
    @TemperatureValue INT = NULL,

    @RespiratoryAlert INT = NULL,
    @OxygenSaturationAlert INT = NULL,
    @BloodPressureAlert INT = NULL,
    @HeartRateAlert INT = NULL,
    @ConsciousnessAlert INT = NULL,
    @TotalScore INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[PatientAdds]
    SET
        PatientId                   = @PatientId,
        LabId                       = @LabId,
        RespiratoryRate             = @RespiratoryRate,
        HeartRate                   = @HeartRate,
        Temperature                 = @Temperature,
        Consciousness               = @Consciousness,
        OxygenSaturation            = @OxygenSaturation,
        OxygenFlow                  = @OxygenFlow,
        ModeOfDelivery              = @ModeOfDelivery,
        BloodPressure               = @BloodPressure,
        BloodPressureDiastolic      = @BloodPressureDiastolic,

        /* these eleven were accepted and then discarded */
        RespiratoryRateValue        = @RespiratoryRateValue,
        OxygenSaturationValue       = @OxygenSaturationValue,
        BloodPressureValue          = @BloodPressureValue,
        BloodPressureDiastolicValue = @BloodPressureDiastolicValue,
        HeartRateValue              = @HeartRateValue,
        TemperatureValue            = @TemperatureValue,
        RespiratoryAlert            = @RespiratoryAlert,
        OxygenSaturationAlert       = @OxygenSaturationAlert,
        BloodPressureAlert          = @BloodPressureAlert,
        HeartRateAlert              = @HeartRateAlert,

        ConsciousnessAlert          = @ConsciousnessAlert,
        TotalScore                  = @TotalScore
    WHERE Id = @Id;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No record found with the given Id.', 16, 1);
    END
END
GO
/****** Object:  StoredProcedure [dbo].[UpdatePatientFromList]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ---------------------------------------------------------------------------
-- Edit Patient: update from the list modal.
-- Blank string / NULL DOB = keep the existing value (partial update).
-- ---------------------------------------------------------------------------
CREATE   PROCEDURE [dbo].[UpdatePatientFromList]
    @PatientId   INT,
    @FirstName   VARCHAR(50),
    @LastName    VARCHAR(50),
    @DOB         DATETIME = NULL,
    @Gender      VARCHAR(10),
    @Address     NVARCHAR(200),
    @Allergies   VARCHAR(200),
    @Intolerance VARCHAR(200),
    @Weight      VARCHAR(10),
    @Height      VARCHAR(10),
    @Age         VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Patient SET
        FirstName   = CASE WHEN @FirstName   = '' THEN FirstName   ELSE @FirstName   END,
        LastName    = CASE WHEN @LastName    = '' THEN LastName    ELSE @LastName    END,
        DateOfBirth = CASE WHEN @DOB IS NULL      THEN DateOfBirth ELSE @DOB         END,
        Gender      = CASE WHEN @Gender      = '' THEN Gender      ELSE @Gender      END,
        Address     = CASE WHEN @Address     = '' THEN Address     ELSE @Address     END,
        Allergy     = CASE WHEN @Allergies   = '' THEN Allergy     ELSE @Allergies   END,
        Intolerance = CASE WHEN @Intolerance = '' THEN Intolerance ELSE @Intolerance END,
        Weight      = CASE WHEN @Weight      = '' THEN Weight      ELSE @Weight      END,
        Height      = CASE WHEN @Height      = '' THEN Height      ELSE @Height      END,
        Age         = CASE WHEN @Age         = '' THEN Age         ELSE @Age         END
    WHERE Id = @PatientId;
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateProgressNote]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateProgressNote]
    @Id INT,
    @LabId INT = NULL,
    @Notes VARCHAR(MAX) = NULL,
    @Sign VARCHAR(50) = NULL,
    @NotesDate DATETIME = NULL,
    @PatientId INT = NULL,
    @NotesFrom VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ProgressNotes
    SET
        LabId = @LabId,
        Notes = @Notes,
        Sign = @Sign,
        NotesDate = @NotesDate,
        PatientId = @PatientId,
        NotesFrom = @NotesFrom
    WHERE Id = @Id;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No record found with the given Id.', 16, 1);
    END
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateUnit]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateUnit]
    @Id          INT,
    @YearLevelId INT,
    @UnitCode    VARCHAR(20) = NULL,
    @UnitName    VARCHAR(100),
    @SortOrder   INT = 0,
    @Active      BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [dbo].[Unit]
       SET [YearLevelId] = @YearLevelId,
           [UnitCode]    = @UnitCode,
           [UnitName]    = @UnitName,
           [SortOrder]   = @SortOrder,
           [Active]      = @Active
     WHERE [Id] = @Id;
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateYearLevel]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateYearLevel]
    @Id            INT,
    @YearLevelName VARCHAR(50),
    @SortOrder     INT = 0,
    @Active        BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [dbo].[YearLevel]
       SET [YearLevelName] = @YearLevelName,
           [SortOrder]     = @SortOrder,
           [Active]        = @Active
     WHERE [Id] = @Id;
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO
/****** Object:  StoredProcedure [dbo].[ValidateLabLogin]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ValidateLabLogin] 
	@Login VARCHAR(50),
    @Password VARCHAR(255),
    @LabID INT OUTPUT,
	@LabName VARCHAR(50) OUTPUT,
    @ResultMessage VARCHAR(50) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

	 -- Declare variables to hold results
    DECLARE @Id INT, @IsActive BIT, @LabIdName VARCHAR(50);

	SET @Id = 0
	SET @IsActive = 0
	SET @LabID = 0
	SET @LabName = ''
	SET @ResultMessage = 'Valid'
   

   -- Check if login credentials are correct
    SELECT @Id = Id, @IsActive = Active, @LabIdName = LabName
    FROM [dbo].[Lab]
    WHERE LabLogin = @Login AND LabPassword = @Password;

    -- If the lab login is not valid, return "Invalid login attempt"
	IF (@Id IS NULL OR @Id = 0)
    BEGIN
        SELECT @LabID = @Id, @LabName = '', @ResultMessage = 'Invalid login attempt'
		Return
    END

	-- If no active lab is found, return "Lab Not Active"
	IF (@IsActive = 0)
	BEGIN
		SELECT @LabID = @Id, @LabName = @LabIdName, @ResultMessage = 'Lab Not Active'
		Return
	END

	-- Successful
	SELECT @LabID = @Id, @LabName = @LabIdName, @ResultMessage = @ResultMessage
    
END

GO
/****** Object:  StoredProcedure [dbo].[ValidateSupervisorLogin]    Script Date: 14-Aug-26 6:02:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ValidateSupervisorLogin] 
	@UserLogin VARCHAR(50),
    @UserPassword VARCHAR(255),
    @SupervisorId INT OUTPUT,
	@UserName VARCHAR(50) OUTPUT,
	@LabId INT OUTPUT,
	@LabName VARCHAR(50) OUTPUT,
    @ResultMessage NVARCHAR(50) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

	-- Declare variables to hold results
    DECLARE @Id INT, @IsActive BIT, @LabIdName VARCHAR(50);

	SET @Id = 0
	SET @IsActive = 0
	SET @LabID = 0
	SET @LabName = ''

	 -- Check the login credentials against the database
    IF EXISTS (SELECT 1 FROM Supervisor WHERE UserLogin = @UserLogin AND UserPassword = @UserPassword)
    BEGIN

		SELECT @LabId = LabId, @SupervisorId = Id, @UserName = UserName, @LabName = @LabIdName, @ResultMessage = 'Valid' FROM Supervisor WHERE UserLogin = @UserLogin AND UserPassword = @UserPassword

		IF (@LabId IS NULL OR @LabId = 0)
		BEGIN
			SELECT @LabID = 0, @LabName = '', @SupervisorId = 0, @UserName = '', @ResultMessage = 'Supervisor has no lab assigned'
			Return
		END
		ELSE
		BEGIN 
			-- Check for lab
			SELECT @IsActive = Active, @LabIdName = LabName
			FROM [dbo].[Lab]
			WHERE Id = @LabId

			-- If no active lab is found, return "Lab Not Active"
			IF (@IsActive = 0)
			BEGIN
				SELECT @LabID = 0, @LabName = '', @SupervisorId = 0, @UserName = '', @ResultMessage = 'Lab Not Active'
				Return
			END
		END

		SELECT @LabId = @LabId, @SupervisorId = @SupervisorId, @UserName = @UserName, @LabName = @LabIdName, @ResultMessage = 'Valid'
		Return
    END
    ELSE
    BEGIN
		SELECT @LabID = @Id, @LabName = '', @SupervisorId = 0, @UserName = '', @ResultMessage = 'Invalid login attempt'
    END
    
END

GO
USE [master]
GO
ALTER DATABASE [EmrSimulator] SET  READ_WRITE 
GO
