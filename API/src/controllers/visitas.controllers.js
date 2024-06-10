import {getConnection} from '../db/connection.js'
import sql from 'mssql'

export const addVisita = async(req, res)=>{
    const pool = await getConnection()
    const result = await pool.request()
    .input('matricula', sql.VarChar,req.body.matricula)
    .query("SELECT * FROM persona  WHERE matricula = @matricula")
    console.log(req.body.matricula)
    console.log(result.recordset[0].idPersona)
    if(result.rowsAffected[0] === 0){
        return res.status(404).json({message: "Persona no encontrada"})
    }

    const result2 = await pool.request()
    .input('horaLlegada', sql.DateTime,req.body.horaLlegada)
    .input('sala', sql.VarChar,req.body.sala)
    .input('fecha', sql.DateTime,req.body.fecha)
    .input('idPersona', sql.Int,result.recordset[0].idPersona)
    .query("INSERT INTO visita(horaLlegada, sala, fecha, IdPersona) VALUES(@horaLlegada, @sala,@fecha,@idPersona)")

    return res.status(200).json({message:"Visita registrada"})
}

export const addSalida = async(req, res)=>{
    const pool = await getConnection()
    const result = await pool.request()
    .input('matricula', sql.VarChar,req.body.matricula)
    .query("SELECT * FROM persona  WHERE matricula = @matricula")
    console.log(req.body)
    console.log(result)
    if(result.rowsAffected[0] === 0){
        return res.status(404).json({message: "Persona no encontrada"})
    }


    const result2 = await pool.request()
    .input('idPersona', sql.Int, result.recordset[0].idPersona)
    .input('horaSalida', sql.DateTime, req.body.horaSalida)
    .input('fecha',sql.DateTime, req.body.fecha)
    .query("UPDATE visita SET horaSalida = @horaSalida WHERE idPersona = @idPersona AND fecha = @fecha")
    console.log()
    if(result2.rowsAffected[0] === 0){
        return res.status(404).json({message: "Error al registrar visita"})
    }
    if(result2.rowsAffected[0] === 1){
        return res.status(200).json({message: "Salida registrada"})
    }

}