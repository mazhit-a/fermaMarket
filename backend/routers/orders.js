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
        const result = await client.query('SELECT * FROM ord');
        res.json(result.rows);
    } catch (err) {
        console.log(err);
        res.send('Error');
    }
})

router.get('/:id', async (req, res) => {
    const id = req.params.id;
    try {
        const result = await client.query('SELECT * FROM ord WHERE orderid = $1', [id]);
        res.json(result.rows);
    } catch (err){
        console.log(err);
        res.status(500).send('Error');
    }
})

router.post('/', async(req, res) => {
    const {orderid, productid, buyerid, deliveryid, status, total_price, quantity, time, date} = req.body;
    try {
        const result = await client.query('INSERT INTO ord (orderid, productid, buyerid, deliveryid, status, total_price, quantity, time, date) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *', 
            [orderid, productid, buyerid, deliveryid, status, total_price, quantity, time, date]
        );
        res.status(201).json(result.rows[0]);
    } catch(err) {
        console.log(err);
        res.status(500).send('Error! Order was not added.')
    }
})

router.delete('/:id', async(req, res) => {
    const id = req.params.id;
    try {
        const result = await client.query('DELETE FROM ord WHERE orderid = $1', [id]);
        if (result.rowCount == 0) {
            res.status(404).send('Order info not found');
        } else {
            res.status(200).json(result.rows[0]);
        }
    } catch (err) {
        console.send(err);
        res.status(500).send('Error! Order info has not been deleted.')
    }
})

router.put('/:id', async(req, res) => {
    const id = req.params.id;
    const {productid, buyerid, deliveryid, status, total_price, quantity, time, date} = req.body;
    try {
        const result = await client.query('UPDATE ord SET productid = $1, buyerid = $2, deliveryid = $3, status = $4 , total_price = $5, quantity = $6, time = $7, date = $8 WHERE orderid = $9', [productid, buyerid, deliveryid, status, total_price, quantity, time, date, id]);
        if (result.rowCount == 0) {
            res.status(404).send('Order info not found!');
        } else {
            res.status(200).send('Info updated');
        }
    } catch (err) {
        console.send(err);
        res.status(200).send('Error updating the order info!');
    }
})

module.exports = router;