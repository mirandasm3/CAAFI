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

router.get('/alumnos/:matricula', getAlumno)

router.post('/alumnos', addAlumno)


router.put('/alumnos/:matricula', updateAlumno)

router.delete('/alumnos/:matricula', deleteAlumno)

export default router