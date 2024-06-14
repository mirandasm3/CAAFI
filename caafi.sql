USE [CAAFI]
GO

ALTER DATABASE [CAAFI] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [CAAFI].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [CAAFI] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [CAAFI] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [CAAFI] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [CAAFI] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [CAAFI] SET ARITHABORT OFF 
GO
ALTER DATABASE [CAAFI] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [CAAFI] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [CAAFI] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [CAAFI] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [CAAFI] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [CAAFI] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [CAAFI] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [CAAFI] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [CAAFI] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [CAAFI] SET  DISABLE_BROKER 
GO
ALTER DATABASE [CAAFI] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [CAAFI] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [CAAFI] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [CAAFI] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [CAAFI] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [CAAFI] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [CAAFI] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [CAAFI] SET RECOVERY FULL 
GO
ALTER DATABASE [CAAFI] SET  MULTI_USER 
GO
ALTER DATABASE [CAAFI] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [CAAFI] SET DB_CHAINING OFF 
GO
ALTER DATABASE [CAAFI] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [CAAFI] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [CAAFI] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'CAAFI', N'ON'
GO
USE [CAAFI]
GO
/****** Object:  UserDefinedFunction [dbo].[arrayToTable]    Script Date: 10/06/2024 12:34:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[arrayToTable] (
	@ArrayData VARCHAR (MAX) ,
	@Delimiter VARCHAR (1)
)
RETURNS @ArrayTable TABLE
(
	idkey INT IDENTITY (0,7) ,
	value VARCHAR (255)
)
AS
	BEGIN
		DECLARE @EndIndex INT 
		DECLARE @StartIndex INT
		DECLARE @CurVal VARCHAR (255)
		SET @StartIndex = 1
		IF(@ArrayData IS NOT NULL)
		BEGIN
			SET @ArrayData = @ArrayData + @Delimiter
			SET @EndIndex = CHARINDEX (@Delimiter, @ArrayData, @StartIndex)
			WHILE (@EndIndex > 0)
				BEGIN
				SET @CurVal = SUBSTRING (@ArrayData, @StartIndex, (@EndIndex - @StartIndex) )
				INSERT INTO @ArrayTable (value) VALUES (@CurVal)
				SET @StartIndex = @EndIndex+1
				SET @EndIndex = CHARINDEX (@delimiter, @ArrayData, @StartIndex)
				END
		END	
	RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_contarAlumnosIdiomas]    Script Date: 10/06/2024 12:34:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_contarAlumnosIdiomas] (@idPeriodoEscolar INT)
RETURNS @Resultados TABLE (
    AlumnosActivos INT,
    IdiomasEstudiados INT
)
AS
BEGIN
    -- Insertar los resultados en la tabla de retorno usando subconsultas
    INSERT INTO @Resultados (AlumnosActivos, IdiomasEstudiados)
    SELECT 
        (SELECT COUNT(DISTINCT p.idPersona)
         FROM Persona p
         JOIN Comprobante c ON p.idPersona = c.idPersona
         JOIN periodoEscolar pe ON c.idPeriodoEscolar = pe.idPeriodoEscolar
         WHERE pe.idPeriodoEscolar = @idPeriodoEscolar
           AND p.tipo IN ('alumno', 'delex')) AS AlumnosActivos,
           
        (SELECT COUNT(DISTINCT pi.idIdioma)
         FROM Persona p
         JOIN Comprobante c ON p.idPersona = c.idPersona
         JOIN periodoEscolar pe ON c.idPeriodoEscolar = pe.idPeriodoEscolar
         JOIN persona_idioma pi ON p.idPersona = pi.idPersona
         WHERE pe.idPeriodoEscolar = @idPeriodoEscolar
           AND p.tipo IN ('alumno', 'delex')) AS IdiomasEstudiados;

    RETURN;
END;
GO
/****** Object:  Table [dbo].[alumno]    Script Date: 10/06/2024 12:34:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[alumno](
	[idAlumno] [int] IDENTITY(1,1) NOT NULL,
	[facultad] [varchar](60) NULL,
	[programaEducativo] [varchar](60) NULL,
	[semestreSeccion] [varchar](20) NULL,
	[IdPersona] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[idAlumno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[bitacora]    Script Date: 10/06/2024 12:34:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bitacora](
	[IdBitacora] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](50) NULL,
	[horaInicio] [datetime] NULL,
	[horaFin] [datetime] NULL,
	[sesion] [varchar](20) NULL,
	[aprendizaje] [varchar](400) NULL,
	[asesoria] [int] NULL,
	[duda] [varchar](400) NULL,
	[evaluacion] [varchar](400) NULL,
	[grupoFacultad] [varchar](50) NULL,
	[habilidadArea] [varchar](50) NULL,
	[material] [varchar](50) NULL,
	[observacion] [varchar](50) NULL,
	[firmaElectronica] [varchar](400) NULL,
	[estado] [int] NULL,
	[IdPersonal] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdBitacora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[comprobante]    Script Date: 10/06/2024 12:34:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[comprobante](
	[IdComprobante] [int] IDENTITY(1,1) NOT NULL,
	[comprobante1] [varbinary](8000) NULL,
	[comprobante2] [varbinary](8000) NULL,
	[IdPeriodoEscolar] [int] NULL,
	[IdPersona] [int] NULL,
	[inscripcion] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[IdComprobante] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[delex]    Script Date: 10/06/2024 12:34:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[delex](
	[idDelex] [int] IDENTITY(1,1) NOT NULL,
	[nivel] [int] NULL,
	[IdPersona] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[idDelex] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[idioma]    Script Date: 10/06/2024 12:34:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[idioma](
	[IdIdioma] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[IdIdioma] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[periodoEscolar]    Script Date: 10/06/2024 12:34:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[periodoEscolar](
	[IdPeriodoEscolar] [int] IDENTITY(1,1) NOT NULL,
	[fechaInicio] [datetime] NULL,
	[fechaFin] [datetime] NULL,
	[identificador] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[IdPeriodoEscolar] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[persona]    Script Date: 10/06/2024 12:34:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[persona](
	[idPersona] [int] IDENTITY(1,1) NOT NULL,
	[matricula] [varchar](10) NOT NULL,
	[nombre] [varchar](60) NOT NULL,
	[apellidos] [varchar](60) NOT NULL,
	[password] [varchar](60) NULL,
	[tipo] [varchar](15) NOT NULL,
	[status] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[idPersona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[persona_idioma]    Script Date: 10/06/2024 12:34:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[persona_idioma](
	[idPersonaIdioma] [int] IDENTITY(1,1) NOT NULL,
	[idPersona] [int] NULL,
	[idIdioma] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[idPersonaIdioma] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[personalCaafi]    Script Date: 10/06/2024 12:34:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[personalCaafi](
	[idPersonal] [int] IDENTITY(1,1) NOT NULL,
	[idPuesto] [int] NULL,
	[idPersona] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[idPersonal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[puesto]    Script Date: 10/06/2024 12:34:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[puesto](
	[IdPuesto] [int] IDENTITY(1,1) NOT NULL,
	[tipo] [int] NULL,
	[nombre] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[IdPuesto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[reporte]    Script Date: 10/06/2024 12:34:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[reporte](
	[IdReporte] [int] IDENTITY(1,1) NOT NULL,
	[generado] [varbinary](8000) NULL,
	[IdPeriodoEscolar] [int] NULL,
	[tipo] [varchar](20) NULL,
	[idReporteTipo] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdReporte] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[reporte_tipo]    Script Date: 10/06/2024 12:34:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[reporte_tipo](
	[idReporteTipo] [int] IDENTITY(1,1) NOT NULL,
	[tipo] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[idReporteTipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[visita]    Script Date: 10/06/2024 12:34:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[visita](
	[IdVisita] [int] IDENTITY(1,1) NOT NULL,
	[horaLlegada] [datetime] NULL,
	[horaSalida] [datetime] NULL,
	[sala] [varchar](50) NULL,
	[fecha] [datetime] NULL,
	[IdPersona] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdVisita] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[visita_bitacora]    Script Date: 10/06/2024 12:34:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[visita_bitacora](
	[idVisitaBitacora] [int] IDENTITY(1,1) NOT NULL,
	[IdVisita] [int] NULL,
	[IdBitacora] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[idVisitaBitacora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[visita_periodoEscolar]    Script Date: 10/06/2024 12:34:17 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[visita_periodoEscolar](
	[IdVisitaPeriodo] [int] IDENTITY(1,1) NOT NULL,
	[IdVisita] [int] NULL,
	[IdPeriodoEscolar] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdVisitaPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[alumno]  WITH CHECK ADD FOREIGN KEY([IdPersona])
REFERENCES [dbo].[persona] ([idPersona])
GO
ALTER TABLE [dbo].[bitacora]  WITH CHECK ADD FOREIGN KEY([IdPersonal])
REFERENCES [dbo].[personalCaafi] ([idPersonal])
GO
ALTER TABLE [dbo].[comprobante]  WITH CHECK ADD FOREIGN KEY([IdPeriodoEscolar])
REFERENCES [dbo].[periodoEscolar] ([IdPeriodoEscolar])
GO
ALTER TABLE [dbo].[comprobante]  WITH CHECK ADD FOREIGN KEY([IdPersona])
REFERENCES [dbo].[persona] ([idPersona])
GO
ALTER TABLE [dbo].[delex]  WITH CHECK ADD FOREIGN KEY([IdPersona])
REFERENCES [dbo].[persona] ([idPersona])
GO
ALTER TABLE [dbo].[persona_idioma]  WITH CHECK ADD FOREIGN KEY([idIdioma])
REFERENCES [dbo].[idioma] ([IdIdioma])
GO
ALTER TABLE [dbo].[persona_idioma]  WITH CHECK ADD FOREIGN KEY([idPersona])
REFERENCES [dbo].[persona] ([idPersona])
GO
ALTER TABLE [dbo].[personalCaafi]  WITH CHECK ADD FOREIGN KEY([idPuesto])
REFERENCES [dbo].[puesto] ([IdPuesto])
GO
ALTER TABLE [dbo].[personalCaafi]  WITH CHECK ADD  CONSTRAINT [FK_personalCaafi_persona] FOREIGN KEY([idPersona])
REFERENCES [dbo].[persona] ([idPersona])
GO
ALTER TABLE [dbo].[personalCaafi] CHECK CONSTRAINT [FK_personalCaafi_persona]
GO
ALTER TABLE [dbo].[reporte]  WITH CHECK ADD FOREIGN KEY([IdPeriodoEscolar])
REFERENCES [dbo].[periodoEscolar] ([IdPeriodoEscolar])
GO
ALTER TABLE [dbo].[reporte]  WITH CHECK ADD  CONSTRAINT [FK_reporte_reportetipo] FOREIGN KEY([idReporteTipo])
REFERENCES [dbo].[reporte_tipo] ([idReporteTipo])
GO
ALTER TABLE [dbo].[reporte] CHECK CONSTRAINT [FK_reporte_reportetipo]
GO
ALTER TABLE [dbo].[visita]  WITH CHECK ADD FOREIGN KEY([IdPersona])
REFERENCES [dbo].[persona] ([idPersona])
GO
ALTER TABLE [dbo].[visita_bitacora]  WITH CHECK ADD FOREIGN KEY([IdBitacora])
REFERENCES [dbo].[bitacora] ([IdBitacora])
GO
ALTER TABLE [dbo].[visita_bitacora]  WITH CHECK ADD FOREIGN KEY([IdVisita])
REFERENCES [dbo].[visita] ([IdVisita])
GO
ALTER TABLE [dbo].[visita_periodoEscolar]  WITH CHECK ADD FOREIGN KEY([IdPeriodoEscolar])
REFERENCES [dbo].[periodoEscolar] ([IdPeriodoEscolar])
GO
ALTER TABLE [dbo].[visita_periodoEscolar]  WITH CHECK ADD FOREIGN KEY([IdVisita])
REFERENCES [dbo].[visita] ([IdVisita])
GO
USE [master]
GO
ALTER DATABASE [CAAFI] SET  READ_WRITE 
GO