import { Router } from 'express'
import multer from 'multer'

import { acceptInscripcion, getInscripcion, requestInscripcion } from '../controllers/inscripcion.controllers.js'

const router = Router()

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

router.get('/inscripcion',getInscripcion)
router.post('/inscripcion', upload.any(), requestInscripcion)
router.post('/inscripcion/accept', acceptInscripcion)

export default router