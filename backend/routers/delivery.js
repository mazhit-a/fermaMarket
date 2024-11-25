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
        const result = await client.query('SELECT * FROM delivery');
        res.json(result.rows);
    } catch (err) {
        console.log(err);
        res.send('Error');
    }
})

router.get('/:id', async (req, res) => {
    const id = req.params.id;
    try {
        const result = await client.query('SELECT * FROM delivery WHERE deliveryId = $1', [id]);
        res.json(result.rows);
    } catch (err){
        console.log(err);
        res.status(500).send('Error');
    }
})

router.post('/', async(req, res) => {
    const {deliveryid, date, method, tracking_number, address, status, cost} = req.body;
    try {
        const result = await client.query('INSERT INTO delivery (deliveryid, date, method, tracking_number, address, status, cost) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *', 
            [deliveryid, date, method, tracking_number, address, status, cost]
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
        const result = await client.query('DELETE FROM delivery WHERE deliveryid = $1', [id]);
        if (result.rowCount == 0) {
            res.status(404).send('Delivery info not found');
        } else {
            res.status(200).json(result.rows[0]);
        }
    } catch (err) {
        console.send(err);
        res.status(500).send('Error! Delivery info has not been deleted.')
    }
})

router.put('/:id', async(req, res) => {
    const id = req.params.id;
    const {date, method, tracking_number, address, status, cost} = req.body;
    try {
        const result = await client.query('UPDATE delivery SET date = $1, method = $2, tracking_number = $3, address = $4, status = $5, cost = $6 WHERE deliveryid = $7', [date, method, tracking_number, address, status, cost, id]);
        if (result.rowCount == 0) {
            res.status(404).send('Delivery info not found!');
        } else {
            res.status(200).send('Info updated');
        }
    } catch (err) {
        console.send(err);
        res.status(200).send('Error updating the delivery!');
    }
})


module.exports = router;