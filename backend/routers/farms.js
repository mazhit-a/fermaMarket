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
        const result = await client.query('SELECT * FROM farm');
        res.json(result.rows);
    } catch (err) {
        console.log(err);
        res.send('Error');
    }
})

router.get('/locations', async (req, res) => {
    try {
        const result = await client.query('SELECT farmid, location FROM farm WHERE farmid IS NOT NULL AND location IS NOT NULL');
        console.log(result.rows);
        res.json(result.rows);
    } catch (err) {
        console.log(err);
        res.send('Error');
    }
})

router.get('/:id', async (req, res) => {
    const id = req.params.id;
    try {
        const result = await client.query('SELECT * FROM farm WHERE farmId = $1', [id]);
        res.json(result.rows);
    } catch (err){
        console.log(err);
        res.status(500).send('Error');
    }
})

router.post('/', async(req, res) => {
    const {farmid, farmerid, crop_types, equipment, location, seeds, name} = req.body;
    try {
        const result = await client.query('INSERT INTO farm (farmid, farmerid, crop_types, equipment, location, seeds, name) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *', 
            [farmid, farmerid, crop_types, equipment, location, seeds, name]
        );
        res.status(201).json(result.rows[0]);
    } catch(err) {
        console.log(err);
        res.status(500).send('Error! Product was not added.')
    }
})

router.delete('/:id', async(req, res) => {
    const id = req.params.id;
    try {
        const result = await client.query('DELETE FROM farm WHERE farmid = $1', [id]);
        if (result.rowCount == 0) {
            res.status(404).send('Farm not found');
        } else {
            res.status(200).json(result.rows[0]);
        }
    } catch (err) {
        console.send(err);
        res.status(500).send('Error! Farm has not been deleted.')
    }
})

router.put('/:id', async(req, res) => {
    const id = req.params.id;
    const {farmerid, crop_types, equipment, location, seeds, name} = req.body;
    try {
        const result = await client.query('UPDATE farm SET farmerid = $1, crop_types = $2, equipment = $3, location = $4, seeds = $5, name = $6 WHERE farmid = $7', [farmerid, crop_types, equipment, location, seeds, name, id]);
        if (result.rowCount == 0) {
            res.status(404).send('Farm not found!');
        } else {
            res.status(200).send('Info updated');
        }
    } catch (err) {
        console.send(err);
        res.status(200).send('Error updating the farm!');
    }
})


module.exports = router;