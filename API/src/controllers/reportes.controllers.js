import {getConnection} from '../db/connection.js'
import sql from 'mssql'

export const addReportes = async(req, res) =>{
    const pool = await getConnection()

    var tipoReporte = req.body.tipoReporte
    console.log(tipoReporte)
    if(tipoReporte === 'Visitas'){
        const result = await pool.request()
        .input('fechaMax', sql.DateTime, req.body.fechaMax)
        .input('fechaMin', sql.DateTime, req.body.fechaMin)
        .query('SELECT COUNT(*) AS Visitas FROM visita WHERE fecha >= @fechaMin and fecha < dateadd(day, 1, @fechaMax) ')

        return res.status(200).json(result.recordset[0])
    }else
    if(tipoReporte === 'Inscripciones'){
        const result = await pool.request()
        .input('idPeriodoEscolar', sql.Int, req.body.idPeriodoEscolar)
        .query('SELECT COUNT(DISTINCT p.idPersona) AS TotalInscritos FROM Persona p JOIN Comprobante c ON p.idPersona = c.idPersona'
        +' JOIN periodoEscolar pe ON c.idPeriodoEscolar = pe.idPeriodoEscolar WHERE pe.idPeriodoEscolar = 1;')
        return res.status(200).json(result.recordset[0])
    }else
    if(tipoReporte === 'Salas'){
        const result = await pool.request()
        .input('fechaMax', sql.DateTime, req.body.fechaMax)
        .input('fechaMin', sql.DateTime, req.body.fechaMin)        
        .query('SELECT COUNT(DISTINCT sala) AS SalasUtilizadas FROM visita WHERE fecha >= @fechaMin and fecha < dateadd(day, 1, @fechaMax) ')

        return res.status(200).json(result.recordset[0])
    }else
    if(tipoReporte === 'Alumnos'){
        const result = await pool.request()
        .input('idPeriodoEscolar', sql.Int, req.body.idPeriodoEscolar)
        .query('SELECT * FROM dbo.fn_contarAlumnosIdiomas(@idPeriodoEscolar)')

        return res.status(200).json(result.recordset[0])
    }
}

export const getReportes = async(req, res)=>{
    const pool = await getConnection()
    const result = await pool.request().query('SELECT r.tipoReporte, pe.idPeriodoEscolar FROM Reporte r JOIN periodoEscolar pe ON r.idPeriodoEscolar = pe.idPeriodoEscolar')

    return res.status(200).json(result.recordset)

}