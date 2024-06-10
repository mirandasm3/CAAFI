import {getConnection} from '../db/connection.js'
import sql from 'mssql'

export const getAlumnos = async (req, res)=>{
    const pool = await getConnection()

    var result = await pool.request().query('SELECT * FROM persona P INNER JOIN alumno A ON P.idPersona = A.idPersona')

    if(result.rowsAffected[0] === 0){
        return res.status(404).json({message: "No existen alumnos registrados"})
    }

    return res.json(result.recordset)
}

export const getAlumno = async(req,res)=>{

    const pool = await getConnection()
    const result = await pool.request().input('matricula', sql.VarChar,req.body.matricula)
    .query("SELECT tipo FROM persona  WHERE matricula = @matricula")
    console.log(req.body)
    console.log(result)
    var tipo = result.recordset[0].tipo
    console.log(tipo.toLowerCase())
    if(result.rowsAffected[0] === 0){
        return res.status(404).json({message: "Persona no encontrada"})
    }
    if(tipo.toLowerCase() === 'alumno'){
        const result2 = await pool.request().input('matricula', sql.VarChar,req.body.matricula)
            .query("SELECT * FROM persona P INNER JOIN alumno A ON P.idPersona = A.idPersona WHERE matricula = @matricula")
        return res.json(result2.recordset[0])
    }else
    if(tipo.toLowerCase() === 'delex'){
        const result2 = await pool.request().input('matricula', sql.VarChar,req.body.matricula)
            .query("SELECT * FROM persona P INNER JOIN delex D ON P.idPersona = D.idPersona WHERE matricula = @matricula")
        return res.json(result2.recordset[0])
    }

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

    var tipo = req.body.tipo

    if(tipo.toLowerCase() == 'alumno'){
        const result2 = await pool.request()
        .input('facultad', sql.VarChar, req.body.facultad)
        .input('programaEducativo', sql.VarChar, req.body.programaEducativo)
        .input('semestre', sql.VarChar, req.body.semestre)
        .input('id', sql.Int, result.recordset[0].id)
        .query("INSERT INTO alumno VALUES (@facultad,@programaEducativo,@semestre,@id)")
    }else
    if(tipo.toLowerCase() == 'delex'){
        const result2 = await pool.request()
        .input('nivel', sql.VarChar, req.body.nivel)
        .input('id', sql.Int, result.recordset[0].id)
        .query("INSERT INTO delex VALUES (@nivel,@id)")
    }

    return res.json({message: "Alumno registrado"})
}

export const updateAlumno = async(req, res)=>{
    const pool = await getConnection()
    const result = await pool.request().input('matricula', sql.VarChar,req.body.matricula)
    .query("SELECT idPersona FROM PERSONA WHERE matricula = @matricula")
    var id = result.recordset[0].id

    if(result.rowsAffected[0] === 0){
        return res.status(404).json({message: "Persona no encontrada"})
    }else{
        const result2 = await pool.request()
            .input('matricula', sql.VarChar, req.body.matricula)
            .input('nombre', sql.VarChar, req.body.nombre)
            .input('apellidos', sql.VarChar, req.body.apellidos)
            .input('password', sql.VarChar, req.body.password)
            .input('tipo', sql.VarChar, req.body.tipo)
            .input('id',sql.Int,id)
            .query("UPDATE persona SET matricula = @matricula, nombre = @nombre,"
                +"apellidos = @apellidos, password = @password, tipo = @tipo where idPersona = @id ")
        var tipo = req.body.tipo
        if(tipo.toLowerCase() == 'alumno'){
            const result2 = await pool.request()
            .input('facultad', sql.VarChar, req.body.facultad)
            .input('programaEducativo', sql.VarChar, req.body.programaEducativo)
            .input('semestre', sql.VarChar, req.body.semestre)
            .input('id', sql.Int, id)
            .query("UPDATE alumno SET facultad=@facultad, programaEducativo = @programaEducativo, semestre = @semestre WHERE idPersona = @id)")
        }else
        if(tipo.toLowerCase() == 'delex'){
            const result2 = await pool.request()
            .input('nivel', sql.VarChar, req.body.nivel)
            .input('id', sql.Int, id)
            .query("UPDATE delex SET nivel = @nivel WHERE idPersona = @id)")
        }
        }
    return res.json({message: "Alumno modificado"})
}

export const deleteAlumno = async(req, res)=>{
    const pool = await getConnection()
    const result = await pool.request().input('matricula', sql.VarChar,req.body.matricula)
    .query("SELECT idPersona,tipo FROM PERSONA WHERE matricula = @matricula")

    var tipo = result.recordsets[0].tipo

    if(result.rowsAffected[0] === 0){
        return res.status(404).json({message: "Persona no encontrada"})
    }else{
        if(tipo.toLowerCase() == 'alumno'){
            const result2 = await pool.request().input('idPersona', sql.Int,result.recordset[0].idPersona)
                .query("DELETE FROM alumno WHERE idPersona = @idPersona")
        }else
        if(tipo.toLowerCase() == 'delex'){
            const result2 = await pool.request().input('idPersona', sql.Int,result.recordset[0].idPersona)
                .query("DELETE FROM delex WHERE idPersona = @idPersona")
        }

        if(result2.rowsAffected[0] == 1){
            const result2 = await pool.request().input('idPersona', sql.Int,result.recordset[0].idPersona)
            .query("DELETE FROM persona WHERE idPersona = @idPersona")
        }
    }

    return res.json({message: "Alumno eliminado"})
}

