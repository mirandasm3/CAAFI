import { Router } from 'express'

import { addBitacora, deleteBitacora, firmaBitacora, getBitacora, getBitacoraDetails,
      }
      from '../controllers/bitacoras.controllers.js'

const router = Router()

router.get('/bitacora', getBitacora)
router.get('/bitacora/detalles', getBitacoraDetails)
router.post('/bitacora', addBitacora)
router.put('/bitacora', firmaBitacora)
router.delete('/bitacora', deleteBitacora)

export default router