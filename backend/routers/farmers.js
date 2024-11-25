const express = require('express');
const router = express.Router();

const fs = require('fs');
const { Client } = require('pg');
const client = new Client({
    host: 'localhost',
    port: 5432,
    user: 'postgres',
    password: 'Alibek2003%',
    database: 'farm-data',
  });

client.connect()
    .then(() => console.log('Connected to PostgreSQL'))
    .catch(err => console.error('Connection error', err.stack));

    router.get('/', async (req, res) => {
        try {
            const result = await client.query('SELECT * FROM farmer');
            res.json(result.rows);
        } catch (err) {
            console.error(err);
            res.status(500).send('Error fetching farmers');
        }
    });
    
    router.get('/user/:id', async (req, res) => {
        const userId = req.params.id;
    
        try {
            const farmerResult = await client.query(
                'SELECT name, email, phone_number FROM farmer WHERE farmerid = $1', 
                [userId]
            );
            const farmResult = await client.query(
                'SELECT crop_types, location FROM farm WHERE farmerid = $1', 
                [userId]
            );
    
            if (farmerResult.rows.length === 0 || farmResult.rows.length === 0) {
                return res.status(404).json({ error: 'Farmer or farm not found' });
            }
    
            res.json({
                ...farmerResult.rows[0],
                ...farmResult.rows[0]
            });
        } catch (err) {
            console.error('Error fetching personal info:', err);
            res.status(500).json({ error: 'Error fetching personal info' });
        }
    });
    
    
    
    
    router.post('/', async (req, res) => {
        const { userLogin, password, name, email, phone_number, gov_id } = req.body;
    
        try {
            const userResult = await client.query(
                'INSERT INTO Users (userLogin, password, userType) VALUES ($1, $2, $3) RETURNING userId',
                [userLogin, password, 'Farmer']
            );
    
            const userId = userResult.rows[0].userId;
    
            const farmerResult = await client.query(
                'INSERT INTO farmer (userId, email, name, phone_number, gov_id) VALUES ($1, $2, $3, $4, $5) RETURNING *',
                [userId, email, name, phone_number, gov_id]
            );
    
            res.status(201).json(farmerResult.rows[0]);
        } catch (err) {
            console.error(err);
            res.status(500).send('Error! Farmer was not added.');
        }
    });
    
    router.put('/:id', async (req, res) => {
        const farmerId = req.params.id;
        const { name, email, phone_number, gov_id, farmName, location } = req.body;
    
        try {
            const farmerUpdateResult = await client.query(
                'UPDATE farmer SET name = $1, email = $2, phone_number = $3 WHERE farmerid = $4 RETURNING *',
                [name, email, phone_number, farmerId]
            );
    
            if (farmerUpdateResult.rowCount === 0) {
                return res.status(404).json({ error: 'Farmer not found' });
            }
    
            
            res.json({ success: true, message: 'Farmer and farm details updated successfully' });
        } catch (err) {
            console.error('Error updating farmer or farm details:', err);
            res.status(500).json({ error: 'Error updating farmer or farm details' });
        }
    });
    
    
    router.put('/farm/:id', async (req, res) => {
        const farmid = req.params.id;
        const { crop_types, location } = req.body;
    
        try {
            const result = await client.query(
                'UPDATE farm SET crop_types = $1, location = $2 WHERE farmid = $3 RETURNING *',
                [crop_types, location, farmid]
            );
            if (result.rowCount === 0) {
                return res.status(404).json({ error: 'Farm not found' });
            }
    
            res.json({ success: true, message: 'Farm details updated successfully', data: result.rows[0] });
        } catch (err) {
            console.error('Error updating farm details:', err);
            res.status(500).json({ error: 'Error updating farm details' });
        }
    });
    
    
    router.delete('/:id', async (req, res) => {
        const id = req.params.id;
    
        try {
            await client.query('DELETE FROM farm WHERE farmerId = $1', [id]);
    
            const result = await client.query('DELETE FROM farmer WHERE farmerId = $1 RETURNING *', [id]);
    
            if (result.rowCount === 0) {
                res.status(404).send('Farmer not found');
            } else {
                res.status(200).json(result.rows[0]);
            }
        } catch (err) {
            console.error(err);
            res.status(500).send('Error deleting farmer and farm');
        }
    });
    
    module.exports = router;
    