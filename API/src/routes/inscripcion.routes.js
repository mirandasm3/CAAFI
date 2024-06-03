import { Router } from 'express'

import { acceptInscripcion, requestInscripcion } from '../controllers/inscripcion.controllers.js'

const router = Router()

router.post('/inscripcion', requestInscripcion)
router.post('/inscripcion/accept', acceptInscripcion)

export default router