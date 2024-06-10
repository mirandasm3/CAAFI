import {getConnection} from '../db/connection.js'

export const getPuesto = async(req, res) =>{
    const pool = await getConnection()

    const result = await pool.request().query('SELECT nombre FROM puesto')

    if(result.rowsAffected[0] === 0){
        return res.status(404).json({message: "No existen puestos registrados"})
    }

    return res.json(result.recordset)
}

export const getIdiomas = async(req, res) =>{
    const pool = await getConnection()

    const result = await pool.request().query('SELECT nombre FROM idioma')

    if(result.rowsAffected[0] === 0){
        return res.status(404).json({message: "No existen idiomas registrados"})
    }

    return res.json(result.recordset)
}

export const getReporte = async(req, res) =>{
    const pool = await getConnection()

    const result = await pool.request().query('SELECT tipo FROM reporte')

    if(result.rowsAffected[0] === 0){
        return res.status(404).json({message: "No existen tipos de reportes registrados"})
    }

    return res.json(result.recordset)
}

export const getPeriodoEscolar = async(req, res) =>{
    const pool = await getConnection()

    const result = await pool.request().query('SELECT identificador FROM periodoEscolar ')

    if(result.rowsAffected[0] === 0){
        return res.status(404).json({message: "No existen periodos registrados"})
    }

    return res.json(result.recordset)
}