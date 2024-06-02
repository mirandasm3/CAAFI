import {getConnection} from '../db/connection.js'
import sql from 'mssql'

export const getAlumnos = async (req, res)=>{
    const pool = await getConnection()

    const result = await pool.request().query('SELECT * FROM persona P INNER JOIN alumno A ON P.idPersona = A.idPersona')

    if(result.rowsAffected[0] === 0){
        return res.status(404).json({message: "No existen alumnos registrados"})
    }

    return res.json(result.recordset[0])
}

export const getAlumno = async(req,res)=>{
    console.log(req.params)

    const pool = await getConnection()
    const result = await pool.request().input('matricula', sql.VarChar,req.params.matricula)
    .query("SELECT * FROM persona P INNER JOIN alumno A ON P.idPersona = A.idPersona WHERE matricula = @matricula")

    if(result.rowsAffected[0] === 0){
        return res.status(404).json({message: "Persona no encontrada"})
    }

    return res.json(result.recordset[0])
}

export const addAlumno = async(req, res)=>{
    console.log(req.body)

    const pool = await getConnection()
    const result = await pool.request()
    .input('matricula', sql.VarChar, req.body.matricula)
    .input('nombre', sql.VarChar, req.body.nombre)
    .input('apellidos', sql.VarChar, req.body.apellidos)
    .input('password', sql.VarChar, req.body.password)
    .input('tipo', sql.VarChar, req.body.tipo)
    .query("INSERT INTO persona VALUES (@matricula,@nombre,@apellidos,@password, @tipo); SELECT SCOPE_IDENTITY() AS id")
    console.log(result)

    const result2 = await pool.request()
    .input('facultad', sql.VarChar, req.body.facultad)
    .input('programaEducativo', sql.VarChar, req.body.programaEducativo)
    .input('semestre', sql.VarChar, req.body.semestre)
    .input('id', sql.Int, result.recordset[0].id)
    .query("INSERT INTO alumno VALUES (@facultad,@programaEducativo,@semestre,@id)")

    res.json({id: result.recordset[0].id,matricula:req.body.matricula,
         nombre:req.body.nombre,
          apellidos:req.body.apellidos,
           password:req.body.password,
            tipo:req.body.tipo})
}

export const updateAlumno = async(req, res)=>{
    const pool = await getConnection()
    const result = await pool.request()
    .input('matricula', sql.VarChar, req.body.matricula)
    .input('nombre', sql.VarChar, req.body.nombre)
    .input('apellidos', sql.VarChar, req.body.apellidos)
    .input('password', sql.VarChar, req.body.password)
    .input('tipo', sql.VarChar, req.body.tipo)
    .query("UPDATE persona SET matricula = @matricula, nombre = @nombre,"
        +"apellidos = @apellidos, password = @password, tipo = @tipo ")
    console.log(result)

    res.send("Modificando persona")
}

export const deleteAlumno = async(req, res)=>{
    const pool = await getConnection()
    const result = await pool.request().input('matricula', sql.VarChar,req.params.matricula)
    .query("SELECT idPersona FROM PERSONA WHERE matricula = @matricula")


    if(result.rowsAffected[0] === 0){
        return res.status(404).json({message: "Persona no encontrada"})
    }else{
        const result2 = await pool.request().input('idPersona', sql.Int,result.recordset[0].idPersona)
        .query("DELETE FROM ALUMNO WHERE idPersona = @idPersona")

        if(result2.rowsAffected[0] == 1){
            const result2 = await pool.request().input('idPersona', sql.Int,result.recordset[0].idPersona)
            .query("DELETE FROM persona WHERE idPersona = @idPersona")
        }
    }

    return res.json({message: "Alumno eliminado"})
}

