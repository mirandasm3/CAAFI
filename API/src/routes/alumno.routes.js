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

router.post('/alumno', addAlumno)


router.put('/alumno', updateAlumno)

router.delete('/alumno', deleteAlumno)

export default router