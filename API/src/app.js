import express from 'express'
import jwt from 'jsonwebtoken';
import sql from 'mssql'
import bcrypt from 'bcryptjs';
import cors from 'cors';
import alumnoRoutes from './routes/alumno.routes.js'
import personalRoutes from './routes/personal.routes.js'
import inscripcionRoutes from './routes/inscripcion.routes.js'
import visitasRoutes from './routes/visitas.routes.js'
import utilsRoutes from './routes/utils.routes.js'
import bitacorasRoutes from './routes/bitacoras.routes.js'
import reportesRoutes from './routes/reportes.routes.js'
import { getConnection } from './db/connection.js';

const app = express()
app.use(express.json())

app.post('/login', async (req, res) => {
    const { matricula, password } = req.body;

    try {
      const pool = await getConnection();

      /*if(matricula.length === 5){
        var result = await pool.request()
        .input('matricula', sql.VarChar, matricula)
        .query('SELECT * FROM persona P INNER JOIN PersonalCaafi PC ON P.idPersona = PC.idPersona WHERE matricula = @matricula');
      }else{*/
        var result = await pool.request()
        .input('matricula', sql.VarChar, matricula)
        .query('SELECT * FROM persona WHERE matricula = @matricula');
  
      
      
      if (result.rowsAffected[0] === 0) {
        return res.status(401).json({ message: 'Usuario no existente' });
      }
  
      const user = result.recordset[0];
      var usertipo = user.tipo
      console.log(usertipo)
      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch) {
        return res.status(401).json({ message: 'Contraseña incorrecta' });
      }
  
      const token = jwt.sign({ id: user.id }, 'secret_key', { expiresIn: '1h' });
      res.status(200).json({ token, usertipo});
  
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Internal server error' });
    }
  });
  
  // Middleware para verificar el token
  const verifyToken = (req, res, next) => {
    const token = req.headers['authorization'];
  
    if (!token) {
      return res.status(403).json({ message: 'No token provided' });
    }
  
    jwt.verify(token, 'secret_key', (err, decoded) => {
      if (err) {
        return res.status(500).json({ message: 'Failed to authenticate token' });
      }
  
      req.userId = decoded.id;
      next();
    });
  };

const corsOptions = {
    
};

app.use(cors(corsOptions));
app.use(alumnoRoutes)
app.use(personalRoutes)
app.use(inscripcionRoutes)
app.use(visitasRoutes)
app.use(utilsRoutes)
app.use(reportesRoutes)
app.use(bitacorasRoutes)
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  next();
});

export default app

