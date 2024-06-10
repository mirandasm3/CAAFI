import {getConnection} from '../db/connection.js'
import sql from 'mssql'

export const getReportes = async(req, res) =>{
    const pool = await getConnection()

    var tipoReporte = req.body.tipoReporte
    if(tipoReporte === 'Visitas'){
        const result = await pool.request()
        .input('fechaMax', sql.DateTime, req.body.fechaMax)
        .input('fechaMin', sql.DateTime, req.body.fechaMin)
        .query('SELECT COUNT(*) AS Visitas FROM visita WHERE fecha >= @fechaMin and fecha < dateadd(day, 1, @fechaMax) ')

        return res.status(200).json(result.recordset[0])
    }else
    if(tipoReporte === 'Inscripciones'){
        const result = await pool.request()
        .input('fechaMax', sql.DateTime, req.body.fechaMax)
        .input('fechaMin', sql.DateTime, req.body.fechaMin)
        .query('SELECT COUNT(*) AS Visitas FROM visita WHERE fecha >= @fechaMin and fecha < dateadd(day, 1, @fechaMax) ')

        return res.status(200).json(result.recordset[0])
    }else
    if(tipoReporte === 'Salas'){
        const result = await pool.request()
        .input('periodoEscolar', sql.VarChar, req.body.periodoEscolar)
        .query('SELECT COUNT(DISTINCT salas) AS SalasUtilizadas FROM visita WHERE fecha >= @fechaMin and fecha < dateadd(day, 1, @fechaMax) ')

        return res.status(200).json(result.recordset[0])
    }else
    if(tipoReporte === 'Alumnos'){
        const result = await pool.request()
        .input('fechaMax', sql.DateTime, req.body.fechaMax)
        .input('fechaMin', sql.DateTime, req.body.fechaMin)
        .query('SELECT COUNT(*) AS Visitas FROM visita WHERE fecha >= @fechaMin and fecha < dateadd(day, 1, @fechaMax) ')

        return res.status(200).json(result.recordset[0])
    }
}

export const addReportes = async(req, res)=>{
    const pool = await getConnection()
    //const result = await pool.request().query('SELECT * FROM reportes')


}