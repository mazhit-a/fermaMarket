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
        const result = await client.query('SELECT * FROM pending');
        res.json(result.rows);
    } catch (err) {
        console.log(err);
        res.send('Error');
    }
})

router.get('/:id', async (req, res) => {
    const id = req.params.id;
    try {
        const result = await client.query('SELECT * FROM pending WHERE userid = $1', [id]);
        if (result.rowCount == 0) {
            res.status(404).send("User not found")
        } else {
        res.json(result.rows);
        }
    } catch (err){
        console.log(err);
        res.status(500).send('Error');
    }
})
/*
router.post('/', async(req, res) => {
    const {userid, name, email, phone, govId, address, size, crops,userlogin,userpassword} = req.body;
    try {
        console.log("hh")
        const result = await client.query('INSERT INTO pending (userid, name, email, phone, govId, address, size, crops, userlogin, userpassword) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *', 
            [userid, name, email, phone, govId, address, size, crops,userlogin,userpassword]
        );
        res.status(201).json(result.rows[0]);
    } catch(err) {
        console.log(err);
        res.status(500).send('Error! User was not added.')
    }
})*/
router.post('/', async (req, res) => {
    const { name, email, phone, govId, farmname, size, address, equipment, seeds, crops, userlogin, userpassword } = req.body;

    // Validate required fields
    if (!name || !email || !phone ||  !govId || !address || !size || !crops || !userlogin || !userpassword || !farmname || !equipment || !seeds) {
        return res.status(400).send('Missing required fields');
    }

    try {
        // Check if userlogin already exists
        const userCheck = await client.query('SELECT * FROM users WHERE userlogin = $1', [userlogin]);
        // Before returning a 409 status
        if (userCheck.rowCount > 0) {
            console.error('Conflict: User login already exists:', userlogin);
            return res.status(409).send('User login already exists');
        }


        // Proceed with insertion if userlogin does not exist
        const result = await client.query(
            'INSERT INTO users (userlogin, password, usertype) VALUES ($1, $2, $3) RETURNING *',
            [userlogin, userpassword, 'farmer']
        );
        const res1 = await client.query(
            'INSERT INTO farmer (email, name, phone_number, gov_id, status, activity, userlogin) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *',
            [email, name, phone, govId, 'pending', 'active', userlogin]
        );
        const res2 = await client.query(
            'INSERT INTO farm (farmerid, name, farm_size, location, crop_types, equipment, seeds) VALUES ((SELECT farmerid FROM farmer WHERE userlogin = $1 LIMIT 1), $4, $7, $2, $3, $5, $6)',
            [userlogin, address, crops, farmname, equipment, seeds, size]
        );

        res.status(201).json(result.rows[0]); // Includes the generated userid
    } catch (err) {
        console.error('Database error:', err.stack);
        res.status(500).send('Error adding user');
    }
});


router.delete('/:id', async(req, res) => {
    const id = req.params.id;
    try {
        const result = await client.query('DELETE FROM pending WHERE userid = $1', [id]);
        if (result.rowCount == 0) {
            res.status(404).send('User not found');
        } else {
            res.status(200).json(result.rows[0]);
        }
    } catch (err) {
        console.send(err);
        res.status(500).send('Error! User has not been deleted.')
    }
})

router.put('/:id', async(req, res) => {
    const id = req.params.id;
    const {name, email, phone, govId, address, size, crops,userlogin,userpassword} = req.body;

try {
        const result = await client.query('UPDATE pending SET name = $1, email = $2, phone = $3, govId = $4, address = $5, size = $6, crops = $7, userlogin = $8, userpassword = $9 WHERE userid = $10', [name, email, phone, govId, address, size, crops,userlogin,userpassword, id]);
        if (result.rowCount == 0) {
            res.status(404).send('User not found!');
        } else {
            res.status(200).json(result.rows[0]);
        }
    } catch (err) {
        console.send(err);
        res.status(200).send('Error updating the product!');
    }
})

module.exports = router;