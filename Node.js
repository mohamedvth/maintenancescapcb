const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Create MySQL connection
const db = mysql.createConnection({
  host: 'localhost',
  user: 'db_user',
  password: 'secure_password',
  database: 'scapcb_db'
});

db.connect((err) => {
  if (err) throw err;
  console.log('Connected to database');
});

// Get all interventions
app.get('/api/interventions', (req, res) => {
  const sql = 'SELECT * FROM interventions ORDER BY start_datetime DESC';
  db.query(sql, (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: 'Database error' });
    }
    res.json(results);
  });
});

// Add new intervention
app.post('/api/interventions', (req, res) => {
  const { user, matricule, interventionType, maintenanceType, description, start, end, equipment, status } = req.body;
  
  const sql = `INSERT INTO interventions 
               (user, matricule, intervention_type, maintenance_type, description, start_datetime, end_datetime, equipment, status) 
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`;
               
  db.query(sql, [
    user, 
    matricule, 
    interventionType, 
    maintenanceType, 
    description, 
    start, 
    end, 
    JSON.stringify(equipment), 
    status
  ], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: 'Database error' });
    }
    res.json({ id: result.insertId, ...req.body });
  });
});

// Delete an intervention
app.delete('/api/interventions/:id', (req, res) => {
  const sql = 'DELETE FROM interventions WHERE id = ?';
  db.query(sql, [req.params.id], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: 'Database error' });
    }
    res.json({ message: 'Intervention deleted' });
  });
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});