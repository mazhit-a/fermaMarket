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


router.get('/farm/:farmid', async (req, res) => {
        const {farmid} = req.params;
        try {
            const result = await client.query('SELECT * FROM offers WHERE farmid = $1 ORDER BY created_at DESC', [farmid]);
            // Return the offers as JSON response
            res.json(result.rows);
        } catch (err) {
            console.error('Error fetching offers:', err);
            res.status(500).send('Error fetching offers');
        }
});

router.get('/', async (req, res) => {
        try {
            const result = await client.query('SELECT * FROM offers ORDER BY created_at DESC');
            // Return the offers as JSON response
            res.json(result.rows);
        } catch (err) {
            console.error('Error fetching offers:', err);
            res.status(500).send('Error fetching offers');
        }
});


router.patch('/:id', async (req, res) => {
    const { id } = req.params;
    const { status, offered_price } = req.body;

    // Validate that status is provided
    if (!status) {
        return res.status(400).json({ error: 'Status is required' });
    }

    // Base query to update the offer status
    let query = 'UPDATE offers SET status = $1';
    const values = [status];  // Initialize the query with the status value

    // If the status is "Countered" and an offeredprice is provided, update counter_price
    if (status === 'Countered' && offered_price !== undefined) {
        query += ', counter_price = $2';
        values.push(offered_price);  // Add the counter offer price to the query
    } else if (status === 'Accepted') {
        // If the status is "Accepted", set counter_price to NULL
        query += ', counter_price = NULL';
    }

    // Final part of the query to specify which offer to update
    query += ' WHERE id = $' + (values.length + 1) + ' RETURNING *';
    values.push(id);  // Add the offer ID to the query values

    try {
        // Execute the query
        const result = await client.query(query, values);

        // If no offer was found with the provided ID
        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Offer not found' });
        }

        // Respond with the updated offer
        res.json(result.rows[0]);

    } catch (err) {
        // Log any errors that occur
        console.error('Error updating offer:', err.message);
        console.error('Query:', query);
        console.error('Query parameters:', values);
        res.status(500).send('Error updating offer');
    }
});

router.post('/', async(req, res) => {
    const {productid, farmid, buyerid, offered_price} = req.body;
    try {
        const result = client.query(`
                INSERT INTO offers (productid, buyerid, offered_price, farmid)
                VALUES ($1, $2, $3, $4) RETURNING *
            `, [productid, buyerid, offered_price, farmid]);
        res.status(201).json({success: true});
    } catch (err){
        res.status(500).json({success: false});
    }
});

router.put('/offers/:id/:status', async (req, res) => {
    const offerId = req.params.id;
    const status = req.params.status.toLowerCase();

    // Define allowed statuses
    const allowedStatuses = ['pending', 'approved', 'rejected'];

    // Validate the status
    if (!allowedStatuses.includes(status)) {
        return res.status(400).json({ error: `Invalid status. Allowed statuses are: ${allowedStatuses.join(', ')}` });
    }

    try {
        // Begin transaction
        await client.query('BEGIN');

        // Update the offer's status
        const offerResult = await client.query(
            'UPDATE offers SET status = $1 WHERE offer_id = $2 RETURNING *',
            [status, offerId]
        );

        if (offerResult.rowCount === 0) {
            await client.query('ROLLBACK');
            return res.status(404).json({ error: 'Offer not found' });
        }

        const offer = offerResult.rows[0];

        // If the status is "approved," update the product price
        if (status === 'approved') {
            const productUpdateResult = await client.query(
                'UPDATE product SET price = $1 WHERE productid = $2 RETURNING *',
                [offer.offered_price, offer.productid]
            );

            if (productUpdateResult.rowCount === 0) {
                await client.query('ROLLBACK');
                return res.status(404).json({ error: 'Product not found' });
            }
        }

        // Commit the transaction
        await client.query('COMMIT');

        res.status(200).json({ message: 'Offer status updated successfully', offer: offerResult.rows[0] });
    } catch (error) {
        console.error('Error updating offer status:', error);
        // Rollback the transaction in case of an error
        await client.query('ROLLBACK');
        res.status(500).json({ error: 'An error occurred while updating the offer status' });
    }
});




module.exports = router;