import { Router } from 'express'
import { 
    getAlumnos, 
    getAlumno, 
    addAlumno, 
    updateAlumno, 
    deleteAlumno, 
} from '../controllers/alumno.controllers.js'

const router = Router()

router.get('/alumnos', getAlumnos)

router.get('/alumno', getAlumno)

router.post('/alumnos', addAlumno)


router.put('/alumnos', updateAlumno)

router.delete('/alumnos', deleteAlumno)

export default router