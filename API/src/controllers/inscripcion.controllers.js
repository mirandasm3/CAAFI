import {getConnection} from '../db/connection.js'
import sql from 'mssql'

export const requestInscripcion = async(req, res)=>{
    const pool = await getConnection()
    const result = await pool.request()
    .input('matricula', sql.VarChar, req.body.matricula)
    .input('nombre', sql.VarChar, req.body.nombre)
    .input('apellidos', sql.VarChar, req.body.apellidos)
    .input('password', sql.VarChar, req.body.password)
    .input('tipo', sql.VarChar, req.body.tipo)
    .query("INSERT INTO persona VALUES (@matricula,@nombre,@apellidos,@password,@tipo,'pendiente'); SELECT SCOPE_IDENTITY() AS id")
    console.log(result)
    var tipo = req.body.tipo

    if(tipo == 'alumno'){
        const result2 = await pool.request()
        .input('facultad', sql.VarChar, req.body.facultad)
        .input('programaEducativo', sql.VarChar, req.body.programaEducativo)
        .input('semestre', sql.VarChar, req.body.semestre)
        .input('id', sql.Int, result.recordset[0].id)
        .query("INSERT INTO alumno VALUES (@facultad,@programaEducativo,@semestre,@id)")
    }else
    if(tipo == 'delex'){
        const result3 = await pool.request()
        .input('nivel', sql.VarChar, req.body.nivel)
        .input('id', sql.Int, result.recordset[0].id)
        .query("INSERT INTO delex VALUES (@nivel,@id)")
    }

    
}