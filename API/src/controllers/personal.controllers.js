import {getConnection} from '../db/connection.js'
import bcrypt from 'bcryptjs'
import sql from 'mssql'

export const getPersonales = async (req, res)=>{
    try {
        const pool = await getConnection();

        const result = await pool.request()
            .execute('sps_GetPersonales');

        if (result.recordset.length === 0) {
            return res.status(404).json({ message: "No existe personal registrado" });
        }

        return res.json(result.recordset);
    } catch (error) {
        return res.status(500).json({ message: "Error en el servidor" });
    }
}

export const getPersonal = async(req,res)=>{
    try {
        const pool = await getConnection(); 
        const result = await pool.request()
            .input('matricula', sql.VarChar, req.body.matricula)
            .execute('sps_GetPersonal');

        return res.json(result.recordset[0]);
    } catch (error) {
        
        if (error.originalError && error.originalError.info && error.originalError.info.message === 'Persona no encontrada') {
            return res.status(404).json({ message: "Persona no encontrada" });
        }

        return res.status(500).json({ message: "Error en el servidor" });
    }
}

export const addPersonal = async(req, res)=>{
    try {
        console.log(req.body)
        const salt = await bcrypt.genSalt(10);
        const passCifrada = await bcrypt.hash(req.body.password, salt);

        const pool = await getConnection();

        const result = await pool.request()
            .input('matricula', sql.VarChar, req.body.matricula)
            .input('nombre', sql.VarChar, req.body.nombre)
            .input('apellidos', sql.VarChar, req.body.apellidos)
            .input('password', sql.VarChar, passCifrada)
            .input('puesto', sql.Int, req.body.puesto)
            .execute('spi_AddPersonal');

        return res.status(200).json({ message: "Personal registrado" });
    } catch (error) {

        if (error.originalError && error.originalError.info) {
            const errorMessage = error.originalError.info.message;
            if (errorMessage.includes('Error al registrar')) {
                return res.status(404).json({ message: "Error al registrar" });
            }
        }

        console.log(error)

        return res.status(500).json({ message: "Error en el servidor" });
    }
}

export const updatePersonal = async(req, res)=>{
    try {
        const pool = await getConnection();

        const result = await pool.request()
            .input('matricula', sql.VarChar, req.body.matricula)
            .input('nombre', sql.VarChar, req.body.nombre)
            .input('apellidos', sql.VarChar, req.body.apellidos)
            .input('password', sql.VarChar, req.body.password)
            .input('puesto', sql.Int, req.body.puesto)
            .execute('spa_UpdatePersonal');

        return res.status(200).json({ message: "Personal modificado" });
    } catch (error) {
        console.error(error);

        if (error.originalError && error.originalError.info) {
            const errorMessage = error.originalError.info.message;
            if (errorMessage.includes('Error al modificar')) {
                return res.status(404).json({ message: "Error al modificar" });
            }
        }

        return res.status(500).json({ message: "Error en el servidor" });
    }
}

export const deletePersonal = async(req, res)=>{
    try {
        const pool = await getConnection();
        
        const result = await pool.request()
            .input('matricula', sql.VarChar, req.body.matricula)
            .execute('spe_DeletePersonal');

        if (result.recordset && result.recordset.length > 0) {
            return res.status(200).json({ message: result.recordset[0].message });
        } else {
            return res.status(500).json({ message: "Error al eliminar el personal" });
        }
    } catch (error) {
        console.error(error);

        if (error.originalError && error.originalError.info) {
            const errorMessage = error.originalError.info.message;
            if (errorMessage.includes('Persona no encontrada')) {
                return res.status(404).json({ message: "Persona no encontrada" });
            } else if (errorMessage.includes('Error al eliminar')) {
                return res.status(500).json({ message: "Error al eliminar el personal" });
            }
        }

        return res.status(500).json({ message: "Error en el servidor" });
    }
}