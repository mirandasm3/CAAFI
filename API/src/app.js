import express from 'express'
import jwt from 'jsonwebtoken';
import sql from 'mssql'
import bcrypt from 'bcryptjs';
import alumnoRoutes from './routes/alumno.routes.js'
import personalRoutes from './routes/personal.routes.js'
import inscripcionRoutes from './routes/inscripcion.routes.js'
import { getConnection } from './db/connection.js';

const app = express()
app.use(express.json())

app.post('/login', async (req, res) => {
    const { matricula, password } = req.body;
  
    try {
      const pool = await getConnection();
      const result = await pool.request()
        .input('matricula', sql.VarChar, matricula)
        .query('SELECT * FROM persona WHERE matricula = @matricula');
  
      if (result.rowsAffected[0] === 0) {
        return res.status(401).json({ message: 'Usuario no existente' });
      }
  
      const user = result.recordset[0];
  
      const isPasswordValid = password == user.password;
      if (!isPasswordValid) {
        return res.status(401).json({ message: 'Contraseña incorrecta' });
      }
  
      const token = jwt.sign({ id: user.id }, 'secret_key', { expiresIn: '1h' });
      res.json({ token });
  
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

app.use(verifyToken,alumnoRoutes)
app.use(verifyToken,personalRoutes)
app.use(verifyToken,inscripcionRoutes)

export default app

