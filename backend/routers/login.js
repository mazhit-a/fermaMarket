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
            const result = await client.query(
                'SELECT * FROM users WHERE userlogin = $1 AND password = $2',
                [login, password]
            );
    
            if (result.rows.length > 0) {
                const user = result.rows[0];
                if (user.usertype == 'buyer') {
                    const res1 = await client.query(
                        'SELECT activity FROM buyer WHERE userlogin = $1', [login]
                    );
                    if (res1.rows[0].activity == 'active') {
                        console.log(res1.rows[0]);
                        console.log(user.usertype);
                        res.json({
                            success: true,
                            user_type: user.usertype
                        });
                    }
                    else {
                        res.json({
                            success: false,
                            user_type: 'Account is disabled'
                        });
                    }
                }
                else if (user.usertype == 'farmer') {
                    const res2 = await client.query(
                        'SELECT status, activity FROM farmer WHERE userlogin = $1', [login]
                    );
                    if (res2.rows[0].activity == 'active') {
                        if (res2.rows[0].status == 'approved') {
                            res.json({
                                success: true,
                                user_type: user.usertype
                            });
                        }
                        else if (res2.rows[0].status == 'pending') {
                            res.json({
                                success: false, 
                                user_type: 'Registration is pending'
                            })
                        }
                        else {
                            res.json({
                                success: false,
                                user_type: 'Registration is rejected'
                            })
                        }
                    }
                    else {
                        res.json({
                            success: false,
                            user_type: 'Account is disabled'
                        });
                    }
                }
            } else {
                res.status(401).json({ success: false, user_type: 'Invalid login or password' });
            }
        } catch (err) {
            console.log(err);
            res.status(500).send('Error');
        }
    });
    
    

module.exports = router;