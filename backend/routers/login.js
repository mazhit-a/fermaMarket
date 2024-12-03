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

router.post('/', async (req, res) => {
    const { login, password } = req.body;

    try {
        // Query the users table to determine the user type
        const userResult = await client.query(
            'SELECT usertype FROM users WHERE userlogin = $1',
            [login]
        );

        if (userResult.rows.length > 0) {
            const userType = userResult.rows[0].usertype;

            if (userType === 'farmer') {
                // Query the farmer table
                const farmerResult = await client.query(
                    'SELECT * FROM farmer WHERE userlogin = $1',
                    [login]
                );

                if (farmerResult.rows.length > 0) {
                    const farmer = farmerResult.rows[0];

                    if (farmer.activity === 'active') {
                        if (farmer.status === 'approved') {
                            res.json({
                                success: true,
                                user_type: 'farmer',
                                user_id: farmer.farmerid,
                            });
                        } else if (farmer.status === 'pending') {
                            res.json({
                                success: false,
                                user_type: 'Registration is pending',
                            });
                        } else {
                            res.json({
                                success: false,
                                user_type: 'Registration is rejected',
                            });
                        }
                    } else {
                        res.json({
                            success: false,
                            user_type: 'Account is disabled',
                        });
                    }
                } else {
                    res.status(401).json({ success: false, user_type: 'Invalid login or password' });
                }
            } else if (userType === 'buyer') {
                // Query the buyer table
                const buyerResult = await client.query(
                    'SELECT * FROM buyer WHERE userlogin = $1',
                    [login]
                );

                if (buyerResult.rows.length > 0) {
                    const buyer = buyerResult.rows[0];
                    res.json({
                        success: true,
                        user_type: 'buyer',
                        user_id: buyer.buyerid,
                    });
                } else {
                    res.status(401).json({ success: false, user_type: 'Invalid login or password' });
                }
            } else {
                res.json({
                    success: false,
                    user_type: 'Unknown user type',
                });
            }
        } else {
            res.status(401).json({ success: false, user_type: 'Invalid login or password' });
        }
    } catch (err) {
        console.error('Database query error:', err);
        res.status(500).send('Internal server error');
    }
});

module.exports = router;