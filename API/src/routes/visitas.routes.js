import { Router } from 'express'
import { addSalida,
     addVisita } from '../controllers/visitas.controllers.js'


const router = Router()

router.post('/visitas', addVisita)
router.post('/salidas', addSalida)

export default router