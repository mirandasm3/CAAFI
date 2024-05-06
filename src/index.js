import app from './app.js'
import {getConnection} from "./db/connection.js"


getConnection()
app.listen(3000)

console.log("Servidor iniciado")