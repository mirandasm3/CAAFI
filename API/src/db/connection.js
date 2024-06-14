import sql from 'mssql'

const dbSettings = {
    user: "dboCaafi",
    password: "4l31W3YwX3IvBPJ",
    server:"localhost",
    database: "CAAFI",
    options: {
        encrypt: false,
        trustServerCertificate: true,
    }

}

export const getConnection = async() => {
    try{
        const pool = await sql.connect(dbSettings)
        return pool
    }catch(error){
        console.log(error)
    }
}

