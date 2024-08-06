import {getConnection} from '../db/connection.js'
import sql from 'mssql'
import bcrypt from 'bcryptjs'

export const getAlumnos = async (req, res)=>{
    const pool = await getConnection()

    const resultAlumnos = await pool.request().execute('sps_GetAlumnos');

    const resultDelex = await pool.request().execute('sps_GetDelex');

    if(resultAlumnos.rowsAffected[0] === 0 && resultDelex.rowsAffected[0] === 0){
        return res.status(404).json({message: "No existen alumnos/delex registrados"})
    }

    const result = [...resultAlumnos.recordset , ...resultDelex.recordset]

    return res.json(result)
}

export const getAlumno = async(req,res)=>{

    try{
        const pool = await getConnection()
        const result = await pool.request()
                .input('matricula', sql.VarChar, req.body.matricula)
                .execute('sps_GetAlumno');
    
            // Mandar mensaje por si no se encuentra la persona
            if (result.recordsets.length === 0 || result.recordsets[0].length === 0) {
                return res.status(404).json({ message: "Persona no encontrada" })
            }
    
            return res.json(result.recordsets[0][0])
    }catch(error){
        if (error.originalError && error.originalError.info && error.originalError.info.message.includes('Persona no encontrada')) {
            return res.status(404).json({ message: "Persona no encontrada" });
        }
        return res.status(500).json({ message: "Error en el servidor" });
    }
    

}

export const addAlumno = async(req, res)=>{
    try {
        // Generar contraseña cifrada
        const salt = await bcrypt.genSalt(10);
        const passCifrada = await bcrypt.hash(req.body.password, salt);
        const pool = await getConnection();

        // Llamar al procedimiento almacenado
        const result = await pool.request()
            .input('matricula', sql.VarChar, req.body.matricula)
            .input('nombre', sql.VarChar, req.body.nombre)
            .input('apellidos', sql.VarChar, req.body.apellidos)
            .input('password', sql.VarChar, passCifrada)
            .input('tipo', sql.VarChar, req.body.tipo)
            .input('facultad', sql.VarChar, req.body.facultad || null)
            .input('programaEducativo', sql.VarChar, req.body.programaEducativo || null)
            .input('semestre', sql.VarChar, req.body.semestre || null)
            .input('nivel', sql.VarChar, req.body.nivel || null)
            .execute('spi_AddAlumno');

        return res.json({ message: "Alumno registrado" });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: "Error en el servidor" });
    }


}

export const updateAlumno = async(req, res)=>{
    try{
        const salt = await bcrypt.genSalt(10);
        const passCifrada = await bcrypt.hash(req.body.password, salt);
        const pool = await getConnection()
        const result = await pool.request()
            .input('matricula', sql.VarChar, req.body.matricula)
            .input('nombre', sql.VarChar, req.body.nombre)
            .input('apellidos', sql.VarChar, req.body.apellidos)
            .input('password', sql.VarChar, passCifrada || null)
            .input('tipo', sql.VarChar, req.body.tipo)
            .input('facultad', sql.VarChar, req.body.facultad || null)
            .input('programaEducativo', sql.VarChar, req.body.programaEducativo || null)
            .input('semestre', sql.VarChar, req.body.semestre || null)
            .input('nivel', sql.VarChar, req.body.nivel || null)
            .execute('spa_UpdatePersona');

        return res.json({message: "Alumno modificado"})
    }catch(error){
        console.log(error)
        if (error.originalError && error.originalError.info && error.originalError.info.message.includes('Persona no encontrada')) {
            return res.status(404).json({ message: "Persona no encontrada" });
        }
        return res.status(500).json({ message: "Error en el servidor" });
    }
    
}

export const deleteAlumno = async(req, res)=>{
    try{
        const pool = await getConnection()
        const result = await pool.request()
        .input('idPersona', sql.Int, req.body.idPersona)
        .execute('spe_DeletePersona');
        return res.json({ message: "Alumno eliminado" });
    }catch(error){
        if (error.originalError && error.originalError.info && error.originalError.info.message.includes('Persona no encontrada')) {
            return res.status(404).json({ message: "Persona no encontrada" });
        }
        return res.status(500).json({ message: "Error en el servidor" });
    }
    
}

