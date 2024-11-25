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
        const result = await client.query('SELECT * FROM payment');
        res.json(result.rows);
    } catch (err) {
        console.log(err);
        res.send('Error');
    }
})

router.get('/:id', async (req, res) => {
    const id = req.params.id;
    try {
        const result = await client.query('SELECT * FROM payment WHERE payment_id = $1', [id]);
        res.json(result.rows);
    } catch (err){
        console.log(err);
        res.status(500).send('Error');
    }
})

router.post('/', async(req, res) => {
    const {payment_id, orderid, buyerid, payment_method, payment_status, amount, payment_date} = req.body;
    try {
        const result = await client.query('INSERT INTO payment (payment_id, orderid, buyerid, payment_method, payment_status, amount, payment_date) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *', 
            [payment_id, orderid, buyerid, payment_method, payment_status, amount, payment_date]
        );
        res.status(201).json(result.rows[0]);
    } catch(err) {
        console.log(err);
        res.status(500).send('Error! Payment info was not added.')
    }
})

router.delete('/:id', async(req, res) => {
    const id = req.params.id;
    try {
        const result = await client.query('DELETE FROM payment WHERE paymentid = $1', [id]);
        if (result.rowCount == 0) {
            res.status(404).send('Payment info not found');
        } else {
            res.status(200).json(result.rows[0]);
        }
    } catch (err) {
        console.send(err);
        res.status(500).send('Error! Payment info has not been deleted.')
    }
})

router.put('/:id', async(req, res) => {
    const id = req.params.id;
    const {orderid, buyerid, payment_method, payment_status, amount, payment_date} = req.body;
    try {
        const result = await client.query('UPDATE ord SET orderid = $1, buyerid = $2, payment_method = $3, payment_status = $4 , amount = $5, payment_date = $6 WHERE paymentid = $7', [orderid, buyerid, payment_method, payment_status, amount, payment_date, id]);
        if (result.rowCount == 0) {
            res.status(404).send('Payment info not found!');
        } else {
            res.status(200).send('Info updated');
        }
    } catch (err) {
        console.send(err);
        res.status(200).send('Error updating the payment info!');
    }
})


module.exports = router;