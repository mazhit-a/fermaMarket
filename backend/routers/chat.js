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

// POST: Send a new chat message
// POST: Send a new chat message
router.post('/', async (req, res) => {
    const { sender, message, timestamp, is_attachment } = req.body;

    // Validate input
    if (!sender || !message || !timestamp) {
        return res.status(400).json({ error: 'Sender, message, and timestamp are required' });
    }

    try {
        const query = 'INSERT INTO chat_messages (sender, message, timestamp, is_attachment) VALUES ($1, $2, $3, $4) RETURNING *';
        const values = [sender, message, timestamp, is_attachment];

        // Execute the query
        const result = await client.query(query, values);

        // Return the inserted message as a response
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error inserting message:', err);
        res.status(500).send('Error inserting message.');
    }
});

// GET: Fetch all chat messages
// GET: Fetch all chat messages
// GET: Fetch all chat messages
// GET: Fetch all chat messages
router.get('/messages', async (req, res) => {
    // Disable caching
    res.set('Cache-Control', 'no-cache, no-store, must-revalidate');  // Prevent caching

    try {
        // Query to select all chat messages ordered by timestamp
        const result = await client.query('SELECT * FROM chat_messages ORDER BY timestamp');

        // Return all chat messages inside a "messages" key
        res.json({
            messages: result.rows // Messages in the expected structure
        });
    } catch (err) {
        console.error('Error fetching messages:', err);
        res.status(500).send('Error fetching messages');
    }
});



module.exports = router;