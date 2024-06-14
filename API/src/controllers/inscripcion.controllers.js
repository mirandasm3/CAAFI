import {getConnection} from '../db/connection.js'
import bcrypt from 'bcryptjs'
import sql from 'mssql'

export const requestInscripcion = async(req, res)=>{
    try {
        const salt = await bcrypt.genSalt(10);
        const passCifrada = await bcrypt.hash(req.body.password, salt);
        const pool = await getConnection();

        //const comprobante1bf = Buffer.from(req.body.comprobante1);
        //const comprobante2bf = Buffer.from(req.body.comprobante1);


        const result = await pool.request()
            .input('matricula', sql.VarChar, req.body.matricula)
            .input('nombre', sql.VarChar, req.body.nombre)
            .input('apellidos', sql.VarChar, req.body.apellidos)
            .input('password', sql.VarChar, passCifrada)
            .input('tipo', sql.VarChar, req.body.tipo)
            .input('facultad', sql.VarChar, req.body.facultad || null)
            .input('programaEducativo', sql.VarChar, req.body.programaEducativo || null)
            .input('semestre', sql.VarChar, req.body.semestreSeccion || null)
            .input('nivel', sql.VarChar, req.body.nivel || null)
            .input('idIdioma', sql.Int, req.body.idIdioma)
            .input('comprobante1', sql.VarBinary, req.body.comprobante1)
            .input('comprobante2', sql.VarBinary, req.body.comprobante2)
            .input('IdPeriodoEscolar', sql.Int, req.body.IdPeriodoEscolar)
            .input('inscripcion', sql.VarChar, req.body.inscripcion)
            .execute('spi_RequestInscripcion');

        return res.status(200).json({ message: "Inscripción solicitada" });
    } catch (error) {
        console.log(error)
        if (error.originalError && error.originalError.info && error.originalError.info.message.includes('Error al registrar')) {
            return res.status(404).json({ message: "Error al registrar" });
        }

        return res.status(500).json({ message: "Error en el servidor" });
    }
}

export const acceptInscripcion = async(req, res)=>{
    try {
        const pool = await getConnection();

        const result = await pool.request()
            .input('matricula', sql.VarChar, req.body.matricula)
            .execute('spa_AcceptInscripcion');

        return res.status(200).json({ message: "Inscripción aprobada" });
    } catch (error) {
        if (error.originalError && error.originalError.info) {
            const errorMessage = error.originalError.info.message;
            if (errorMessage.includes('Persona no encontrada')) {
                return res.status(404).json({ message: "Persona no encontrada" });
            } else if (errorMessage.includes('Error al aprobar')) {
                return res.status(402).json({ message: "Error al aprobar" });
            }
        }

        return res.status(500).json({ message: "Error en el servidor" });
    }
}

export const getInscripcion = async(req, res)=>{
    try {
        const pool = await getConnection();

        const result = await pool.request()
            .query("SELECT * FROM persona P INNER JOIN comprobante C ON P.idPersona = C.IdPersona WHERE status = 'pendiente' ");

            return res.json(result.recordset)
    } catch (error) {

        return res.status(500).json({ message: "Error en el servidor" });
    }
}