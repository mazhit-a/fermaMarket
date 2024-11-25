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
        const result = await client.query('SELECT * FROM buyer');
        res.json(result.rows);
    } catch (err) {
        console.log(err);
        res.send('Error');
    }
})

router.get('/:id', async (req, res) => {
    const id = req.params.id;
    try {
        const result = await client.query('SELECT * FROM buyer WHERE buyerId = $1', [id]);
        res.json(result.rows);
    } catch (err){
        console.log(err);
        res.status(500).send('Error');
    }
})

router.get('/email/:email', async (req, res) => {
    const email = req.params.email;
    try {
        const result = await client.query('SELECT * FROM buyer WHERE email = $1', [email]);
        if (result.rows.length > 0) {
            res.json({success: true});
        } 
        else {
            res.status(401).json({success: false});
        }
    } catch (err){
        console.log(err);
        res.status(500).send('Error');
    }
})

router.post('/', async(req, res) => {
    const {name, email, phone_number, delivery_address, preferred_payment, userLogin, password} = req.body;
    try {
        console.log("222");
        const result = await client.query('INSERT INTO buyer (name, email, phone_number, delivery_address, preffered_payment, activity, userlogin) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *', 
            [name, email, phone_number, delivery_address, preferred_payment, 'active', userLogin]
        );
        console.log("111");
        const res1 = await client.query('INSERT INTO users (userlogin, password, usertype) VALUES ($1, $2, $3) RETURNING *', [userLogin, password, 'buyer']);
        res.status(201).json(result.rows[0]);
    } catch(err) {
        console.log(err);
        res.status(500).send('Error! User was not added.')
    }
})

router.delete('/:id', async(req, res) => {
    const id = req.params.id;
    try {
        const result = await client.query('DELETE FROM buyer WHERE buyerid = $1', [id]);
        if (result.rowCount == 0) {
            res.status(404).send('Buyer info not found');
        } else {
            res.status(200).json(result.rows[0]);
        }
    } catch (err) {
        console.send(err);
        res.status(500).send('Error! Buyer info has not been deleted.')
    }
})

router.put('/:id', async(req, res) => {
    const id = req.params.id;
    const {email, phone_number, name, delivery_address} = req.body;
    try {
        const result = await client.query('UPDATE buyer SET email = $1, phone_number = $2, name = $3, delivery_address = $4 WHERE buyerid = $5', [email, phone_number, name, delivery_address, id]);
        if (result.rowCount == 0) {
            res.status(404).send('Buyer info not found!');
        } else {
            res.status(200).send('Info updated');
        }
    } catch (err) {
        console.send(err);
        res.status(200).send('Error updating the buyer info!');
    }
})

module.exports = router;