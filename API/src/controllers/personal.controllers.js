import {getConnection} from '../db/connection.js'
import sql from 'mssql'

export const getPersonales = async (req, res)=>{
    const pool = await getConnection()

    const result = await pool.request().query('SELECT * FROM persona P INNER JOIN personalCaafi PS ON P.idPersona = PS.idPersona')

    if(result.rowsAffected[0] === 0){
        return res.status(404).json({message: "No existe personal registrado"})
    }

    return res.json(result.recordset[0])
}

export const getPersonal = async(req,res)=>{
    console.log(req.params)

    const pool = await getConnection()
    //Por problemas con la base de datos en la tabla persona, matricula también se cuenta como noPersonal
    const result = await pool.request().input('matricula', sql.VarChar,req.params.matricula)
    .query("SELECT * FROM persona P INNER JOIN personalCaafi PS ON P.idPersona = PS.idPersona WHERE matricula = @matricula")

    if(result.rowsAffected[0] === 0){
        return res.status(404).json({message: "Persona no encontrada"})
    }

    return res.json(result.recordset[0])
}

export const addPersonal = async(req, res)=>{
    const salt = await bcrypt.genSalt(10);
    var passCifrada =await bcrypt.hash(req.body.password, salt) 

    const pool = await getConnection()
    const result = await pool.request()
    .input('matricula', sql.VarChar, req.body.matricula)
    .input('nombre', sql.VarChar, req.body.nombre)
    .input('apellidos', sql.VarChar, req.body.apellidos)
    .input('password', sql.VarChar, passCifrada)
    //.input('tipo', sql.VarChar, req.body.tipo)
    .query("INSERT INTO persona VALUES (@matricula,@nombre,@apellidos,@password,'personalCaafi'); SELECT SCOPE_IDENTITY() AS id")
    console.log(result)

    const result2 = await pool.request()
    .input('puesto', sql.Int, req.body.puesto)
    .input('id', sql.Int, result.recordset[0].id)
    .query("INSERT INTO personalCaafi VALUES (@puesto,@id)")

    if(result2.rowsAffected[0] === 0){
        return res.status(404).json({message: "Error al registrar"})
    }
    return res.status(200).json({message: "Personal registrado"})
}

export const updatePersonal = async(req, res)=>{
    const pool = await getConnection()
    const result = await pool.request().input('matricula', sql.VarChar,req.body.matricula)
    .query("SELECT idPersona FROM PERSONA WHERE matricula = @matricula")
    var id = result.recordset[0].id

    if(result.rowsAffected[0] === 0){
        return res.status(404).json({message: "Persona no encontrada"})
    }else{
        var result2 = await pool.request()
            .input('matricula', sql.VarChar, req.body.matricula)
            .input('nombre', sql.VarChar, req.body.nombre)
            .input('apellidos', sql.VarChar, req.body.apellidos)
            .input('password', sql.VarChar, req.body.password)
            .input('tipo', sql.VarChar, req.body.tipo)
            .input('id',sql.Int,id)
            .query("UPDATE persona SET matricula = @matricula, nombre = @nombre,"
                +"apellidos = @apellidos, password = @password, tipo = @tipo where idPersona = @id ")
    }
    if(result2.rowsAffected[0] === 0){
        return res.status(404).json({message: "Error al modificar"})
    }else{
        var result3 = await pool.request()
            .input('puesto', sql.Int, req.body.puesto)
            .input('id', sql.Int, id)
            .query("UPDATE personalCaafi SET idPuesto=@puesto WHERE idPersona = @id)")
    }
    if(result3.rowsAffected === 0){
        return res.status(404).json({message: "Error al modificar"})
    }else{
        return res.status(200).json({message: "Personal modificado"})
    }
}

export const deletePersonal = async(req, res)=>{
    const pool = await getConnection()
    const result = await pool.request().input('matricula', sql.VarChar,req.body.matricula)
    .query("SELECT idPersona FROM PERSONA WHERE matricula = @matricula")


    if(result.rowsAffected[0] === 0){
        return res.status(404).json({message: "Persona no encontrada"})
    }else{
        const result2 = await pool.request().input('idPersona', sql.Int,result.recordset[0].idPersona)
        .query("DELETE FROM personalCaafi WHERE idPersona = @idPersona")

        if(result2.rowsAffected[0] == 1){
            const result2 = await pool.request().input('idPersona', sql.Int,result.recordset[0].idPersona)
            .query("DELETE FROM persona WHERE idPersona = @idPersona")
        }
    }

    return res.json({message: "Personal eliminado"})
}