import { Router } from 'express'

import { addPersonal, 
    deletePersonal, 
    getPersonal, 
    getPersonales, 
    updatePersonal } 
    from '../controllers/personal.controllers.js'

const router = Router()

router.get('/personales', getPersonales)

router.get('/personal', getPersonal)

router.post('/personal', addPersonal)

router.put('/personal', updatePersonal)

router.delete('/personal', deletePersonal)

export default router