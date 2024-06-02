import express from 'express'
import alumnoRoutes from './routes/alumno.routes.js'
import personalRoutes from './routes/personal.routes.js'
import inscripcionRoutes from './routes/inscripcion.routes.js'

const app = express()
app.use(express.json())

app.use(alumnoRoutes)
app.use(personalRoutes)

export default app

