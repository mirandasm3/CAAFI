import { Router } from 'express'

import { requestInscripcion } from '../controllers/inscripcion.controllers.js'

const router = Router()

router.post('/inscripcion', requestInscripcion)

export default router