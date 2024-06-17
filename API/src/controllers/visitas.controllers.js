import {getConnection} from '../db/connection.js'
import sql from 'mssql'

export const addVisita = async(req, res)=>{
    try {
        const pool = await getConnection();
        
        const result = await pool.request()
            .input('matricula', sql.VarChar, req.body.matricula)
            .input('horaLlegada', sql.DateTime, req.body.horaLlegada)
            .input('sala', sql.VarChar, req.body.sala)
            .input('fecha', sql.DateTime, req.body.fecha)
            .execute('spi_AddVisita');

        if (result.recordset && result.recordset.length > 0) {
            return res.status(200).json({ message: result.recordset[0].message });
        } else {
            return res.status(500).json({ message: "Error al registrar la visita" });
        }
    } catch (error) {
        console.log(error)
        if (error.originalError && error.originalError.info) {
            
            const errorMessage = error.originalError.info.message;
            if (errorMessage.includes('Persona no encontrada')) {
                return res.status(404).json({ message: "Persona no encontrada" });
            }
        }

        return res.status(500).json({ message: "Error en el servidor" });
    }
}

export const addSalida = async(req, res)=>{
    try {
        const pool = await getConnection();
        
        const result = await pool.request()
            .input('matricula', sql.VarChar, req.body.matricula)
            .input('horaSalida', sql.DateTime, req.body.horaSalida)
            .input('fecha', sql.DateTime, req.body.fecha)
            .execute('spa_AddSalida');

        if (result.recordset && result.recordset.length > 0) {
            return res.status(200).json({ message: result.recordset[0].message });
        } else {
            return res.status(500).json({ message: "Error al registrar la salida" });
        }
    } catch (error) {

        if (error.originalError && error.originalError.info) {
            const errorMessage = error.originalError.info.message;
            if (errorMessage.includes('Persona no encontrada')) {
                return res.status(404).json({ message: "Persona no encontrada" });
            } else if (errorMessage.includes('Error al registrar salida')) {
                return res.status(404).json({ message: "Error al registrar la salida" });
            }
        }

        return res.status(500).json({ message: "Error en el servidor" });
    }

}