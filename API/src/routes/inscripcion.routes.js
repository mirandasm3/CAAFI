import { Router } from 'express'

import { acceptInscripcion, getInscripcion, requestInscripcion } from '../controllers/inscripcion.controllers.js'

const router = Router()

router.get('/inscripcion',getInscripcion)
router.post('/inscripcion', requestInscripcion)
router.post('/inscripcion/accept', acceptInscripcion)

export default router