import {getConnection} from '../db/connection.js'
import sql from 'mssql'

export const requestInscripcion = async(req, res)=>{
    const pool = await getConnection()
    const result = await pool.request()
    .input('matricula', sql.VarChar, req.body.matricula)
    .input('nombre', sql.VarChar, req.body.nombre)
    .input('apellidos', sql.VarChar, req.body.apellidos)
    .input('password', sql.VarChar, req.body.password)
    .input('tipo', sql.VarChar, req.body.tipo)
    .query("INSERT INTO persona VALUES (@matricula,@nombre,@apellidos,@password,@tipo,'pendiente'); SELECT SCOPE_IDENTITY() AS id")
    console.log(result)
    var tipo = req.body.tipo

    if(tipo == 'alumno'){
        const result2 = await pool.request()
        .input('facultad', sql.VarChar, req.body.facultad)
        .input('programaEducativo', sql.VarChar, req.body.programaEducativo)
        .input('semestre', sql.VarChar, req.body.semestreSeccion)
        .input('id', sql.Int, result.recordset[0].id)
        .query("INSERT INTO alumno VALUES (@facultad,@programaEducativo,@semestre,@id)")
    }else
    if(tipo == 'delex'){
        const result2 = await pool.request()
        .input('nivel', sql.VarChar, req.body.nivel)
        .input('id', sql.Int, result.recordset[0].id)
        .query("INSERT INTO delex VALUES (@nivel,@id)")
    }

    //Query agregar idiomas
    var idioma = req.body.idIdioma
    const result3 = await pool.request()
    .input('idAlumno', sql.Int, result.recordset[0].id)
    .input('idIdioma', sql.VarChar, idioma.toString())
    .query("INSERT INTO persona_idioma(idPersona, idIdioma) SELECT @idAlumno AS idPersona, VALUE AS idIdioma FROM dbo.arrayToTable(@idIdioma,',')")

    const result4 = await pool.request()
    .input('comprobante1', sql.VarBinary, req.body.comprobante1)
    .input('comprobante2', sql.VarBinary, req.body.comprobante1)
    .input('IdPeriodoEscolar', sql.Int, req.body.IdPeriodoEscolar)
    .input('IdPersona', sql.Int, result.recordset[0].id)
    .input('inscripcion', sql.VarChar, req.body.inscripcion)
    .query("INSERT INTO comprobante(comprobante1, comprobante2, IdPeriodoEscolar, IdPersona, inscripcion) VALUES(@comprobante1, @comprobante2, @IdPeriodoEscolar, @idPersona, @inscripcion)")

    if(result4.rowsAffected === 0){
        return res.status(404).json({message:"Error al registrar"})
    }

    return res.status(200).json({message: "Inscripción solicitada"}) 
}

export const acceptInscripcion = async(req, res)=>{
    const pool = await getConnection()
    const result = await pool.request()
    .input('matricula',sql.VarChar,req.body.matricula)
    .query("SELECT * FROM persona WHERE matricula = @matricula")

    if(result.rowsAffected === 0){
        return res.status(404).json({message: "Persona no encontrada"})
    }else{
        var result2 = await pool.request()
            .input('matricula',sql.VarChar,req.body.matricula)
            .query("UPDATE persona SET status = 'aprobado' WHERE matricula = @matricula")
    }

    if(result2.rowsAffected === 0){
        return res.status(402).json({message: "Error al aprobar"})
    }else{
        return res.status(200).json({message: "Inscripción aprobada"})
    }
}