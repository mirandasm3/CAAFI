import {getConnection} from '../db/connection.js'
import bcrypt from 'bcryptjs'
import sql from 'mssql'

const getFileFromRequest = (req, name) => {
    let file = null;
    for(let i = 0; i < req.files.length; i++){
        if(req.files[i].fieldname === name){
            file = req.files[i];
            break;
        }
    }
    return file;
};

export const requestInscripcion = async(req, res)=>{
    try {
        const body = JSON.parse(req.body.requestData);
        
        const salt = await bcrypt.genSalt(10);
        const passCifrada = await bcrypt.hash(body.password, salt);
        const pool = await getConnection();

        const result = await pool.request()
            .input('matricula', sql.VarChar, body.matricula)
            .input('nombre', sql.VarChar, body.nombre)
            .input('apellidos', sql.VarChar, body.apellidos)
            .input('password', sql.VarChar, passCifrada)
            .input('tipo', sql.VarChar, body.tipo)
            .input('facultad', sql.VarChar, body.facultad || null)
            .input('programaEducativo', sql.VarChar, body.programaEducativo || null)
            .input('semestre', sql.VarChar, body.semestreSeccion || null)
            .input('nivel', sql.VarChar, body.nivel || null)
            .input('idIdioma', sql.Int, body.idIdioma)
            .input('comprobante1', sql.VarBinary, getFileFromRequest(req, "comprobante1").buffer)
            .input('comprobante2', sql.VarBinary, getFileFromRequest(req, "comprobante2")?.buffer)
            .input('IdPeriodoEscolar', sql.Int, body.IdPeriodoEscolar)
            .input('inscripcion', sql.VarChar, body.inscripcion)
            .input('status', sql.VarChar, body.status)
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
            .input('idPersona', sql.Int, req.body.idPersona)
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