import {getConnection} from '../db/connection.js'
import sql from 'mssql'
import jwt from 'jsonwebtoken'

export const addBitacora = async(req, res)=>{
    const pool = await getConnection()
    const result = await pool.request()
    .input('nombre', sql.VarChar,req.body.nombre)
    .input('horaInicio', sql.DateTime,req.body.horaInicio)
    .input('horaFin', sql.DateTime,req.body.horaFin)
    .input('sesion', sql.VarChar,req.body.sesion)
    .input('aprendizaje', sql.VarChar,req.body.aprendizaje)
    .input('asesoria', sql.Int,req.body.asesoria)
    .input('duda', sql.VarChar,req.body.duda)
    .input('evaluacion', sql.VarChar,req.body.evaluacion)
    .input('grupoFacultad', sql.VarChar,req.body.grupoFacultad)
    .input('habilidadArea', sql.VarChar,req.body.habilidadArea)
    .input('material', sql.VarChar,req.body.material)
    .input('observacion', sql.VarChar,req.body.observacion)
    .query('INSERT INTO Bitacora (nombre, horaInicio, horaFin, sesion, aprendizaje, asesoria, duda, evaluacion, grupoFacultad, habilidadArea, material, observacion, estado) VALUES ' 
    + '(@nombre, @horaInicio, @horaFin, @sesion, @aprendizaje, @asesoria, @duda, @evaluacion, @grupoFacultad, @habilidadArea, @material, @observacion, "2")')


    if(result.rowsAffected === 0){
        return res.status(400).json({message:"Error al registrar"})
    }

    return res.status(200).json({message:"Registro exitoso"})
}

export const getBitacora = async(req, res)=>{
    const pool = await getConnection()
    
    var periodoEscolar = req.body.idPeriodoEscolar

    if(periodoEscolar === undefined){
        const result = await pool.request()
        .input('idPersona', sql.Int, req.body.idPersona)
        .query('SELECT b.idBitacora, v.fecha, b.horaInicio,b.horaFin,b.estado FROM Persona p JOIN Visita v ON p.idPersona = v.idPersona '+
        'JOIN visita_bitacora vb ON v.idVisita = vb.idVisita '+
        'JOIN Bitacora b ON vb.idBitacora = b.idBitacora '+
        'WHERE p.idPersona = @idPersona and b.estado = 1')

        return res.status(200).json(result.recordset)
    }else{
        const result = await pool.request()
        .input('idPeriodoEscolar', sql.Int, req.body.idPeriodoEscolar)
        .query('SELECT b.IdBitacora,p.matricula, p.nombre, p.apellidos, v.fecha, p.tipo FROM persona p JOIN visita v ON p.idPersona = v.idPersona'
        +' JOIN visita_bitacora vb ON v.idVisita = vb.idVisita JOIN bitacora b ON vb.idBitacora = b.idBitacora'
        +' JOIN visita_periodoescolar vp ON v.idVisita = vp.idVisita JOIN periodoEscolar pe ON vp.idPeriodoEscolar = pe.idPeriodoEscolar'
        +' WHERE pe.idPeriodoEscolar = @idPeriodoEscolar')
        return res.status(200).json(result.recordset)

    }

}

export const getBitacoraDetails = async(req, res)=>{
    const pool = await getConnection()
        const result = await pool.request()
        .input('idBitacora', sql.Int, req.body.idBitacora)
        .query('SELECT * FROM bitacora where idBitacora = @idBitacora')

    return res.status(200).json(result.recordset[0])
}

export const firmaBitacora = async(req, res)=>{
    const pool = await getConnection()

    const secretKey = 'CAAFIUV2024'
    const now = new Date();
    const fecha = `${now.getFullYear()}-${now.getMonth() + 1}-${now.getDate()}`;
    const hora = `${now.getHours()}:${now.getMinutes()}:${now.getSeconds()}`;
    const idPersonal = req.body.idPersonal
    const payload = { idPersonal, fecha , hora };
    const token = jwt.sign(payload, secretKey)

    const result = await pool.request()
    .input('firma', sql.VarChar, token)
    .input('idPersonal', sql.Int,idPersonal)
    .input('idBitacora', sql.Int, req.body.idBitacora)
    .query('UPDATE bitacora SET firmaElectronica=@firma, estado = "1", idPersonal = @idPersonal where idBitacora = @idBitacora')
}

export const deleteBitacora = async(req, res)=>{
    const pool = await getConnection()
    const result = await pool.request()
    .input('id', sql.Int, req.body.idBitacora)
    .query('DELETE FROM bitacora where idBitacora = @id')

    if(result.rowsAffected === 0){
        return res.status(404).json('No se pudo eliminar la bitácora')
    }

    return res.json('Bitacora eliminada')
}