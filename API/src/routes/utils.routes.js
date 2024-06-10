import { Router } from 'express'
import { getIdiomas, getPeriodoEscolar, getPuesto, getReporte } from '../controllers/utils.controllers.js'

const router = Router()

router.get('/utils/puesto', getPuesto)
router.get('/utils/idioma', getIdiomas)
router.get('/utils/reporte', getReporte)
router.get('/utils/periodo', getPeriodoEscolar)

export default router