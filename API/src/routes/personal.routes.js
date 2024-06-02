import { Router } from 'express'

import { addPersonal, 
    deletePersonal, 
    getPersonal, 
    getPersonales, 
    updatePersonal } 
    from '../controllers/personal.controllers.js'

const router = Router()

router.get('/personal', getPersonales)

router.get('/personal/:noPersonal', getPersonal)

router.post('/personal', addPersonal)

router.put('/personal/:noPersonal', updatePersonal)

router.delete('/personal/:noPersonal', deletePersonal)

export default router