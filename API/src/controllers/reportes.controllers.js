import {getConnection} from '../db/connection.js'
import sql from 'mssql'

export const addReportes = async(req, res) =>{
    try {
        const pool = await getConnection();

        const result = await pool.request()
            .input('tipoReporte', sql.NVarChar(50), req.body.tipoReporte)
            .input('fechaMax', sql.DateTime, req.body.fechaMax)
            .input('fechaMin', sql.DateTime, req.body.fechaMin)
            .input('idPeriodoEscolar', sql.Int, req.body.idPeriodoEscolar)
            .execute('sps_AddReportes');

        if (result.recordset && result.recordset.length > 0) {
            return res.status(200).json(result.recordset[0]);
        } else {
            return res.status(404).json({ message: "No se encontraron datos para el reporte solicitado" });
        }
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: "Error en el servidor" });
    }
}

export const getReportes = async(req, res)=>{
    const pool = await getConnection()
    const result = await pool.request().query('SELECT r.tipoReporte, pe.idPeriodoEscolar FROM Reporte r JOIN periodoEscolar pe ON r.idPeriodoEscolar = pe.idPeriodoEscolar')

    return res.status(200).json(result.recordset)

}