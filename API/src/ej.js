import multer from 'multer';
import express from 'express';
import cors from 'cors';
const app = express();

// set up the storage for uploaded files
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/')
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname)
  }
});

//Create the multer middleware
const upload = multer({ storage: storage });

app.use(express.json())
app.use(express.urlencoded({ extended: true }));
app.use(cors());


app.post('/inscripcion', upload.any(), (req, res) => {
  const file = req.body.comprobante1;
  console.log(req);
  //Do something with the file
  res.send('File uploaded');
});

app.listen(3001, () => {
  console.log('Server started');
});
