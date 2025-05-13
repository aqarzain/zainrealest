const express = require('express');
const cors = require('cors');
const app = express();
require('dotenv').config();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
    res.send('أهلاً من عقار زين - API جاهز!');
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, ()
