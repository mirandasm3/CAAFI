USE [master]
GO
/****** Object:  Database [CAAFI]    Script Date: 15/06/2024 08:17:56 p. m. ******/
CREATE DATABASE [CAAFI]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'CAAFI', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\CAAFI.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'CAAFI_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\CAAFI_log.ldf' , SIZE = 4224KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
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
ALTER DATABASE [CAAFI] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [CAAFI] SET QUERY_STORE = OFF
GO
USE [CAAFI]
GO
/****** Object:  User [dbrwCaafi]    Script Date: 15/06/2024 08:17:56 p. m. ******/
CREATE USER [dbrwCaafi] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [dbrwCaafi]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [dbrwCaafi]
GO
/****** Object:  UserDefinedFunction [dbo].[arrayToTable]    Script Date: 15/06/2024 08:17:57 p. m. ******/
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
/****** Object:  UserDefinedFunction [dbo].[fn_contarAlumnosIdiomas]    Script Date: 15/06/2024 08:17:57 p. m. ******/
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
/****** Object:  Table [dbo].[alumno]    Script Date: 15/06/2024 08:17:57 p. m. ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[bitacora]    Script Date: 15/06/2024 08:17:57 p. m. ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[comprobante]    Script Date: 15/06/2024 08:17:57 p. m. ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[delex]    Script Date: 15/06/2024 08:17:57 p. m. ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[idioma]    Script Date: 15/06/2024 08:17:57 p. m. ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[periodoEscolar]    Script Date: 15/06/2024 08:17:57 p. m. ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[persona]    Script Date: 15/06/2024 08:17:57 p. m. ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[persona_idioma]    Script Date: 15/06/2024 08:17:57 p. m. ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[personalCaafi]    Script Date: 15/06/2024 08:17:57 p. m. ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[puesto]    Script Date: 15/06/2024 08:17:57 p. m. ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[visita]    Script Date: 15/06/2024 08:17:57 p. m. ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[visita_bitacora]    Script Date: 15/06/2024 08:17:57 p. m. ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[visita_periodoEscolar]    Script Date: 15/06/2024 08:17:57 p. m. ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
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
/****** Object:  StoredProcedure [dbo].[spa_AcceptInscripcion]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_AcceptInscripcion]
    @idPersona INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la persona existe
    IF EXISTS (SELECT 1 FROM persona WHERE idPersona = @idPersona)
    BEGIN
        -- Actualizar el estado de la persona
        UPDATE persona
        SET status = 'aprobado'
        WHERE idPersona = @idPersona;

        -- Verificar si la actualización fue exitosa
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Error al aprobar', 16, 1);
        END
    END
    ELSE
    BEGIN
        RAISERROR('Persona no encontrada', 16, 1);
    END
END
GO
/****** Object:  StoredProcedure [dbo].[spa_AddSalida]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_AddSalida]
    @matricula VARCHAR(10),
    @horaSalida DATETIME,
    @fecha DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idPersona INT;

    -- Obtener el ID de la persona usando la matrícula proporcionada
    SELECT @idPersona = idPersona FROM persona WHERE matricula = @matricula;

    -- Verificar si se encontró la persona
    IF @idPersona IS NULL
    BEGIN
        RAISERROR('Persona no encontrada', 16, 1);
        RETURN;
    END;

    -- Actualizar la hora de salida en la tabla visita
    UPDATE visita
    SET horaSalida = @horaSalida
    WHERE idPersona = @idPersona AND fecha = @fecha;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Error al registrar salida', 16, 1);
        RETURN;
    END;

    SELECT 'Salida registrada' AS message;
END
GO
/****** Object:  StoredProcedure [dbo].[spa_FirmaBitacora]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_FirmaBitacora]
    @idBitacora INT,
    @firma VARCHAR(400),
    @idPersonal INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la bitácora existe
    IF NOT EXISTS (SELECT 1 FROM bitacora WHERE idBitacora = @idBitacora)
    BEGIN
        RAISERROR ('Bitacora no existe', 16, 1);
        RETURN;
    END

    -- Actualizar la firma electrónica
    UPDATE bitacora
    SET firmaElectronica = @firma, estado = '1', idPersonal = @idPersonal
    WHERE idBitacora = @idBitacora;
END
GO
/****** Object:  StoredProcedure [dbo].[spa_UpdatePersona]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_UpdatePersona]
    @matricula VARCHAR(10),
    @nombre VARCHAR(60),
    @apellidos VARCHAR(60),
    @password VARCHAR(60) = NULL,
    @tipo VARCHAR(15),
    @facultad VARCHAR(60) = NULL,
    @programaEducativo VARCHAR(60) = NULL,
    @semestre VARCHAR(20) = NULL,
    @nivel INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idPersona INT;

    -- Verificar si la matrícula existe y obtener el ID de la persona
    SELECT @idPersona = idPersona FROM persona WHERE matricula = @matricula;

    -- Si no se encuentra la matrícula, devolver un error
    IF @idPersona IS NULL
    BEGIN
        RAISERROR ('Persona no encontrada', 16, 1);
        RETURN;
    END

    -- Actualizar la tabla persona
    IF @nombre IS NOT NULL
    BEGIN
        UPDATE persona SET nombre = @nombre WHERE idPersona = @idPersona;
    END

    IF @apellidos IS NOT NULL
    BEGIN
        UPDATE persona SET apellidos = @apellidos WHERE idPersona = @idPersona;
    END

    IF @password IS NOT NULL
    BEGIN
        UPDATE persona SET password = @password WHERE idPersona = @idPersona;
    END

    -- Actualizar la tabla correspondiente dependiendo del tipo, si es especificado
    IF LOWER(@tipo) = 'alumno'
    BEGIN
        IF @facultad IS NOT NULL
        BEGIN
            UPDATE alumno SET facultad = @facultad WHERE idPersona = @idPersona;
        END

        IF @programaEducativo IS NOT NULL
        BEGIN
            UPDATE alumno SET programaEducativo = @programaEducativo WHERE idPersona = @idPersona;
        END

        IF @semestre IS NOT NULL
        BEGIN
            UPDATE alumno SET semestreSeccion = @semestre WHERE IdPersona = @idPersona;
        END
    END
    ELSE IF LOWER(@tipo) = 'delex'
    BEGIN
        IF @nivel IS NOT NULL
        BEGIN
            UPDATE delex SET nivel = @nivel WHERE IdPersona = @idPersona;
        END
    END
END
GO
/****** Object:  StoredProcedure [dbo].[spa_UpdatePersonal]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_UpdatePersonal]
    @matricula VARCHAR(10),
    @nombre VARCHAR(60) = NULL,
    @apellidos VARCHAR(60) = NULL,
    @password VARCHAR(60) = NULL,
    @puesto INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idPersona INT;

    -- Obtener el ID de la persona
    SELECT @idPersona = idPersona FROM persona WHERE matricula = @matricula;

    -- Actualizar la tabla persona
    IF @nombre IS NOT NULL
        UPDATE persona SET nombre = @nombre WHERE idPersona = @idPersona;
    IF @apellidos IS NOT NULL
        UPDATE persona SET apellidos = @apellidos WHERE idPersona = @idPersona;
    IF @password IS NOT NULL
        UPDATE persona SET password = @password WHERE idPersona = @idPersona;

    -- Actualizar la tabla personalCaafi
    IF @puesto IS NOT NULL
        UPDATE personalCaafi SET idPuesto = @puesto WHERE idPersona = @idPersona;

    -- Verificar si se realizó la modificación correctamente
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Error al modificar', 16, 1);
    END
END
GO
/****** Object:  StoredProcedure [dbo].[spe_DeleteBitacora]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spe_DeleteBitacora]
    @idBitacora INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la bitácora existe y eliminarla
    IF EXISTS (SELECT 1 FROM bitacora WHERE IdBitacora = @idBitacora)
    BEGIN
        DELETE FROM bitacora WHERE IdBitacora = @idBitacora;
    END
    ELSE
    BEGIN
        RAISERROR ('Bitacora no existe', 16, 1);
    END
END
GO
/****** Object:  StoredProcedure [dbo].[spe_DeletePersona]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spe_DeletePersona]
    @idPersona INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @tipo VARCHAR(10);

    -- Verificar si la matrícula existe y obtener el ID y tipo de la persona
    SELECT @tipo = tipo 
    FROM persona 
    WHERE idPersona = @idPersona;

    -- Si no se encuentra la matrícula, devolver un error
    IF @idPersona IS NULL
    BEGIN
        RAISERROR ('Persona no encontrada', 16, 1);
        RETURN;
    END

    -- Eliminar el registro en la tabla correspondiente dependiendo del tipo
    IF LOWER(@tipo) = 'alumno'
    BEGIN
        DELETE FROM alumno WHERE IdPersona = @idPersona;
    END
    ELSE IF LOWER(@tipo) = 'delex'
    BEGIN
        DELETE FROM delex WHERE IdPersona = @idPersona;
    END

	DELETE FROM comprobante WHERE IdPersona = @idPersona;

    -- Eliminar el registro de la tabla persona
    DELETE FROM persona WHERE idPersona = @idPersona;
END
GO
/****** Object:  StoredProcedure [dbo].[spe_DeletePersonal]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spe_DeletePersonal]
    @matricula VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idPersona INT;

    -- Obtener el ID de la persona
    SELECT @idPersona = idPersona FROM persona WHERE matricula = @matricula;

    -- Verificar si la persona existe
    IF @idPersona IS NULL
    BEGIN
        RAISERROR('Persona no encontrada', 16, 1);
        RETURN;
    END;

    -- Eliminar el registro de la tabla personalCaafi
    DELETE FROM personalCaafi WHERE idPersona = @idPersona;

    -- Eliminar el registro de la tabla persona
    DELETE FROM persona WHERE idPersona = @idPersona;

    -- Verificar si se realizó la eliminación correctamente
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Error al eliminar', 16, 1);
        RETURN;
    END;

    SELECT 'Personal eliminado' AS message;
END
GO
/****** Object:  StoredProcedure [dbo].[spi_AddAlumno]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spi_AddAlumno]
    @matricula VARCHAR(10),
    @nombre VARCHAR(60),
    @apellidos VARCHAR(60),
    @password VARCHAR(60),
    @tipo VARCHAR(15),
    @facultad VARCHAR(60) = NULL,
    @programaEducativo VARCHAR(60) = NULL,
    @semestre VARCHAR(20) = NULL,
    @nivel INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Insertar en la tabla persona y obtener el ID generado
    DECLARE @id INT;
    INSERT INTO persona (matricula, nombre, apellidos, password, tipo, status)
    VALUES (@matricula, @nombre, @apellidos, @password, @tipo, 'aprobado');

    SET @id = SCOPE_IDENTITY();

    -- Verificar el tipo y realizar la inserción correspondiente
    IF LOWER(@tipo) = 'alumno'
    BEGIN
        INSERT INTO alumno (facultad, programaEducativo, semestreSeccion, IdPersona)
        VALUES (@facultad, @programaEducativo, @semestre, @id);
    END
    ELSE IF LOWER(@tipo) = 'delex'
    BEGIN
        INSERT INTO delex (nivel, IdPersona)
        VALUES (@nivel, @id);
    END
END
GO
/****** Object:  StoredProcedure [dbo].[spi_AddBitacora]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spi_AddBitacora]
    @nombre VARCHAR(50),
    @horaInicio DATETIME,
    @horaFin DATETIME,
    @sesion VARCHAR(20),
    @aprendizaje VARCHAR(400),
    @asesoria INT,
    @duda VARCHAR(400),
    @evaluacion VARCHAR(400),
    @grupoFacultad VARCHAR(50),
    @habilidadArea VARCHAR(50),
    @material VARCHAR(50),
    @observacion VARCHAR(50)
AS
BEGIN
    INSERT INTO Bitacora (nombre, horaInicio, horaFin, sesion, aprendizaje, asesoria, duda, evaluacion, grupoFacultad, habilidadArea, material, observacion, estado)
    VALUES (@nombre, @horaInicio, @horaFin, @sesion, @aprendizaje, @asesoria, @duda, @evaluacion, @grupoFacultad, @habilidadArea, @material, @observacion, '2')
END

GO
/****** Object:  StoredProcedure [dbo].[spi_AddPersonal]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spi_AddPersonal]
    @matricula VARCHAR(10),
    @nombre VARCHAR(60),
    @apellidos VARCHAR(60),
    @password VARCHAR(60),
    @puesto INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idPersona INT;

    -- Insertar en la tabla persona y obtener el ID generado
    INSERT INTO persona (matricula, nombre, apellidos, password, tipo)
    VALUES (@matricula, @nombre, @apellidos, @password, 'personalCaafi');

    SET @idPersona = SCOPE_IDENTITY();

    -- Insertar en la tabla personalCaafi
    INSERT INTO personalCaafi (idPuesto, idPersona)
    VALUES (@puesto, @idPersona);

    -- Verificar si se realizó el registro correctamente
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Error al registrar', 16, 1);
    END
END
GO
/****** Object:  StoredProcedure [dbo].[spi_AddVisita]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spi_AddVisita]
    @matricula VARCHAR(10),
    @horaLlegada DATETIME,
    @sala VARCHAR(50),
    @fecha DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idPersona INT;

    -- Obtener el ID de la persona usando la matrícula proporcionada
    SELECT @idPersona = idPersona FROM persona WHERE matricula = @matricula;

    -- Verificar si se encontró la persona
    IF @idPersona IS NULL
    BEGIN
        RAISERROR('Persona no encontrada', 16, 1);
        RETURN;
    END;

    -- Insertar la visita
    INSERT INTO visita (horaLlegada, sala, fecha, IdPersona)
    VALUES (@horaLlegada, @sala, @fecha, @idPersona);

    SELECT 'Visita registrada' AS message;
END
GO
/****** Object:  StoredProcedure [dbo].[spi_RequestInscripcion]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spi_RequestInscripcion]
    @matricula VARCHAR(10),
    @nombre VARCHAR(60),
    @apellidos VARCHAR(60),
    @password VARCHAR(60),
    @tipo VARCHAR(15),
    @facultad VARCHAR(60) = NULL,
    @programaEducativo VARCHAR(60) = NULL,
    @semestre VARCHAR(20) = NULL,
    @nivel INT = NULL,
    @idIdioma INT,
    @comprobante1 VARBINARY(8000),
    @comprobante2 VARBINARY(8000),
    @IdPeriodoEscolar INT,
    @inscripcion VARCHAR(10),
	@status VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idPersona INT;

    -- Insertar en la tabla persona
    INSERT INTO persona (matricula, nombre, apellidos, password, tipo, status)
    VALUES (@matricula, @nombre, @apellidos, @password, @tipo, @status);

    SELECT @idPersona = SCOPE_IDENTITY();

    -- Insertar en la tabla alumno o delex según el tipo
    IF @tipo = 'alumno'
    BEGIN
        INSERT INTO alumno (facultad, programaEducativo, semestreSeccion, idPersona)
        VALUES (@facultad, @programaEducativo, @semestre, @idPersona);
    END
    ELSE IF @tipo = 'delex'
    BEGIN
        INSERT INTO delex (nivel, idPersona)
        VALUES (@nivel, @idPersona);
    END

    -- Insertar en la tabla persona_idioma
    INSERT INTO persona_idioma (idPersona, idIdioma)
    SELECT @idPersona, VALUE
    FROM dbo.arrayToTable(@idIdioma, ',');

    -- Insertar en la tabla comprobante
    INSERT INTO comprobante (comprobante1, comprobante2, IdPeriodoEscolar, IdPersona, inscripcion)
    VALUES (@comprobante1, @comprobante2, @IdPeriodoEscolar, @idPersona, @inscripcion);

    -- Verificar si el último insert fue exitoso
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Error al registrar', 16, 1);
    END
END
GO
/****** Object:  StoredProcedure [dbo].[sps_AddReportes]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sps_AddReportes]
    @TipoReporte NVARCHAR(50),
    @FechaMax DATETIME = NULL,
    @FechaMin DATETIME = NULL,
    @IdPeriodoEscolar INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @TipoReporte = 'Visitas'
    BEGIN
        SELECT COUNT(*) AS Visitas FROM visita WHERE fecha >= @FechaMin AND fecha < DATEADD(DAY, 1, @FechaMax);
    END
    ELSE IF @TipoReporte = 'Inscripciones'
    BEGIN
        SELECT COUNT(DISTINCT p.idPersona) AS TotalInscritos FROM Persona p JOIN Comprobante c ON p.idPersona = c.idPersona
        JOIN periodoEscolar pe ON c.idPeriodoEscolar = pe.idPeriodoEscolar WHERE pe.idPeriodoEscolar = @IdPeriodoEscolar;
    END
    ELSE IF @TipoReporte = 'Salas'
    BEGIN
        SELECT COUNT(DISTINCT sala) AS SalasUtilizadas FROM visita WHERE fecha >= @FechaMin AND fecha < DATEADD(DAY, 1, @FechaMax);
    END
    ELSE IF @TipoReporte = 'Alumnos'
    BEGIN
        SELECT * FROM dbo.fn_contarAlumnosIdiomas(@IdPeriodoEscolar);
    END
END
GO
/****** Object:  StoredProcedure [dbo].[sps_GetAlumno]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sps_GetAlumno]
    @matricula VARCHAR(10)
AS
BEGIN
    DECLARE @tipo VARCHAR(15);

    -- Verificar si la matrícula existe y obtener el tipo de persona
    SELECT @tipo = tipo FROM persona WHERE matricula = @matricula;

    -- Si no se encuentra la matrícula, devolver un mensaje de error
    IF @tipo IS NULL
    BEGIN
        RAISERROR ('Persona no encontrada', 16, 1);
        RETURN;
    END

    -- Devolver información dependiendo del tipo de persona
    IF LOWER(@tipo) = 'alumno'
    BEGIN
        SELECT * 
        FROM persona P 
        INNER JOIN alumno A ON P.idPersona = A.idPersona 
        WHERE P.matricula = @matricula;
    END
    ELSE IF LOWER(@tipo) = 'delex'
    BEGIN
        SELECT * 
        FROM persona P 
        INNER JOIN delex D ON P.idPersona = D.idPersona 
        WHERE P.matricula = @matricula;
    END
END
GO
/****** Object:  StoredProcedure [dbo].[sps_GetAlumnos]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sps_GetAlumnos]
AS
BEGIN
	SELECT *
	FROM persona P
	INNER JOIN alumno A ON P.idPersona = A.idPersona
END
GO
/****** Object:  StoredProcedure [dbo].[sps_GetBitacora]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sps_GetBitacora]
    @idPeriodoEscolar INT = NULL,
    @idPersona INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @idPeriodoEscolar IS NULL
    BEGIN
        -- Consulta por persona
        SELECT b.idBitacora, v.fecha, b.horaInicio, b.horaFin, b.estado 
        FROM Persona p 
        JOIN Visita v ON p.idPersona = v.idPersona 
        JOIN visita_bitacora vb ON v.idVisita = vb.idVisita 
        JOIN Bitacora b ON vb.idBitacora = b.idBitacora 
        WHERE p.idPersona = @idPersona AND b.estado = 1;
    END
    ELSE
    BEGIN
        -- Consulta por periodo escolar
        SELECT b.IdBitacora, p.matricula, p.nombre, p.apellidos, v.fecha, p.tipo 
        FROM persona p 
        JOIN visita v ON p.idPersona = v.idPersona
        JOIN visita_bitacora vb ON v.idVisita = vb.idVisita 
        JOIN bitacora b ON vb.idBitacora = b.idBitacora 
        JOIN visita_periodoescolar vp ON v.idVisita = vp.idVisita 
        JOIN periodoEscolar pe ON vp.idPeriodoEscolar = pe.idPeriodoEscolar 
        WHERE pe.idPeriodoEscolar = @idPeriodoEscolar;
    END
END
GO
/****** Object:  StoredProcedure [dbo].[sps_GetBitacoraDetails]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sps_GetBitacoraDetails]
    @idBitacora INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si la bitácora existe
    IF NOT EXISTS (SELECT 1 FROM bitacora WHERE idBitacora = @idBitacora)
    BEGIN
        RAISERROR ('Bitacora no existe', 16, 1);
        RETURN;
    END

    -- Obtener los detalles de la bitácora
    SELECT * FROM bitacora WHERE idBitacora = @idBitacora;
END
GO
/****** Object:  StoredProcedure [dbo].[sps_GetDelex]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sps_GetDelex]
AS
BEGIN
	SELECT *
	FROM persona P
	INNER JOIN delex A ON P.idPersona = A.idPersona
END
GO
/****** Object:  StoredProcedure [dbo].[sps_GetIdiomas]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sps_GetIdiomas]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT nombre FROM idioma;
END
GO
/****** Object:  StoredProcedure [dbo].[sps_GetPeriodoEscolar]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sps_GetPeriodoEscolar]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT identificador FROM periodoEscolar;
END
GO
/****** Object:  StoredProcedure [dbo].[sps_GetPersonal]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sps_GetPersonal]
    @matricula VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM persona P
    INNER JOIN personalCaafi PS ON P.idPersona = PS.idPersona
    WHERE P.matricula = @matricula;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Persona no encontrada', 16, 1);
    END
END
GO
/****** Object:  StoredProcedure [dbo].[sps_GetPersonales]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sps_GetPersonales]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM persona P
    INNER JOIN personalCaafi PS ON P.idPersona = PS.idPersona;
END
GO
/****** Object:  StoredProcedure [dbo].[sps_GetPuesto]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sps_GetPuesto]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT nombre FROM puesto;
END
GO
/****** Object:  StoredProcedure [dbo].[sps_GetReporte]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sps_GetReporte]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT tipo FROM reporte;
END
GO
/****** Object:  StoredProcedure [dbo].[sps_GetReportes]    Script Date: 15/06/2024 08:17:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sps_GetReportes]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT r.tipo, pe.idPeriodoEscolar 
    FROM Reporte r 
    JOIN periodoEscolar pe ON r.idPeriodoEscolar = pe.idPeriodoEscolar;
END
GO
USE [master]
GO
ALTER DATABASE [CAAFI] SET  READ_WRITE 
GO
