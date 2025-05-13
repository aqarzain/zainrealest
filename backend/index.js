// backend/index.js

const express = require('express'); const cors = require('cors'); const dotenv = require('dotenv'); const db = require('./config/db'); const propertyRoutes = require('./routes/propertyRoutes'); const userRoutes = require('./routes/userRoutes');

// Load environment variables dotenv.config();

const app = express(); const port = process.env.PORT || 5000;

// Middleware app.use(cors()); app.use(express.json());

// Routes app.use('/api/properties', propertyRoutes); app.use('/api/users', userRoutes);

// Default route app.get('/', (req, res) => { res.send('Aqar Zain Backend is running'); });

// Start server app.listen(port, () => { console.log(Server is running on port ${port}); });


