import { Router } from 'express'

import { getReportes, 
    addReportes } 
    from '../controllers/reportes.controllers.js'

const router = Router()

router.get('/reporte', getReportes)

router.post('/reporte', addReportes)

export default router