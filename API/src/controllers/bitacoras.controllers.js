import {getConnection} from '../db/connection.js'
import sql from 'mssql'
import jwt from 'jsonwebtoken'

export const addBitacora = async(req, res)=>{
    try {
        const pool = await getConnection();

        const result = await pool.request()
            .input('nombre', sql.VarChar, req.body.nombre)
            .input('horaInicio', sql.DateTime, req.body.horaInicio)
            .input('horaFin', sql.DateTime, req.body.horaFin)
            .input('sesion', sql.VarChar, req.body.sesion)
            .input('aprendizaje', sql.VarChar, req.body.aprendizaje)
            .input('asesoria', sql.Int, req.body.asesoria)
            .input('duda', sql.VarChar, req.body.duda)
            .input('evaluacion', sql.VarChar, req.body.evaluacion)
            .input('grupoFacultad', sql.VarChar, req.body.grupoFacultad)
            .input('habilidadArea', sql.VarChar, req.body.habilidadArea)
            .input('material', sql.VarChar, req.body.material)
            .input('observacion', sql.VarChar, req.body.observacion)
            .input('idAlumno', sql.Int, req.body.idAlumno)
            .execute('spi_AddBitacora');

        if(result.rowsAffected[0] === 0){
            return res.status(400).json({message: "Error al registrar"});
        }

        return res.status(200).json({message: "Registro exitoso"});
    }catch(error){
        console.log(error)
        return res.status(500).json({message: "Error en el servidor"});
    }
}

export const getBitacoras = async(req, res)=>{
    try {
        const pool = await getConnection();

        const result = await pool.request()
            .query('SELECT * FROM bitacora')

        return res.status(200).json(result.recordset);
    } catch (error) {
        return res.status(500).json({ message: "Error en el servidor" });
    }

}

export const getBitacora = async(req, res)=>{
    try {
        const pool = await getConnection();
        const { idPersona } = req.params;

        const result = await pool.request()
            .input('idPersona', sql.Int, idPersona)
            .query('SELECT * FROM bitacora WHERE idAlumno = @idPersona')

        return res.status(200).json(result.recordset);
    } catch (error) {
        return res.status(500).json({ message: "Error en el servidor" });
    }

}

export const getBitacoraDetails = async(req, res)=>{
    try {
        const pool = await getConnection();
        const result = await pool.request()
            .input('idBitacora', sql.Int, req.body.idBitacora)
            .execute('sps_GetBitacoraDetails');

        if (result.recordset.length === 0) {
            return res.status(404).json({ message: "Bitácora no existe" });
        }

        return res.status(200).json(result.recordset[0]);
    } catch (error) {

        if (error.originalError && error.originalError.info && error.originalError.info.message.includes('Bitacora no existe')) {
            return res.status(404).json({ message: "La bitácora no existe" });
        }

        return res.status(500).json({ message: "Error en el servidor" });
    }
}

export const firmaBitacora = async(req, res)=>{
    try {
        const pool = await getConnection();

        const secretKey = 'CAAFIUV2024';
        const now = new Date();
        const fecha = `${now.getFullYear()}-${now.getMonth() + 1}-${now.getDate()}`;
        const hora = `${now.getHours()}:${now.getMinutes()}:${now.getSeconds()}`;
        const idPersonal = req.body.idPersonal;
        const payload = { idPersonal, fecha, hora };
        const token = jwt.sign(payload, secretKey);

        const result = await pool.request()
            .input('firma', sql.VarChar, token)
            .input('idPersonal', sql.Int, idPersonal)
            .input('idBitacora', sql.Int, req.body.idBitacora)
            .execute('spa_FirmaBitacora');

        return res.status(200).json({ message: "Firma electrónica actualizada" });
    } catch (error) {
        if (error.originalError && error.originalError.info && error.originalError.info.message.includes('Bitacora no existe')) {
            return res.status(404).json({ message: "La bitácora no existe" });
        }

        return res.status(500).json({ message: "Error en el servidor" });
    }
}

export const deleteBitacora = async(req, res)=>{
    try {
        const pool = await getConnection();
        const result = await pool.request()
            .input('idBitacora', sql.Int, req.body.idBitacora)
            .execute('spe_DeleteBitacora');

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json('No se pudo eliminar la bitácora');
        }

        return res.json({message:'Bitacora eliminada'});
    } catch (error) {

        if (error.originalError && error.originalError.info && error.originalError.info.message.includes('Bitacora no existe')) {
            return res.status(404).json({ message: "Bitácora no existe" });
        }

        return res.status(500).json({ message: "Error en el servidor" });
    }
}