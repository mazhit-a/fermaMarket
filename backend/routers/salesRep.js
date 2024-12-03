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

// Get Sales Report with Product and Buyer Details
router.get('/', async (req, res) => {
    try {
        const result = await client.query(`
            SELECT
                o.orderid,
                o.status,
				o.total_price,
				order_items.quantity,
				TIME '12:00:00' as time,
                o.order_date as date,
                p.name AS product_name,
                p.price AS product_price,
                p.image_url AS product_image_url,
                b.name AS buyer_name,
                b.email AS buyer_email,
                b.phone_number AS buyer_phone,
                b.delivery_address AS buyer_address,
                b.preffered_payment AS buyer_payment_method,
                b.activity AS buyer_activity,
                b.userlogin AS buyer_userlogin
            FROM
                orders o
				JOIN order_items ON o.orderid = order_items.orderid
                    JOIN
                product p ON order_items.productid = p.productid
                    JOIN
                buyer b ON o.buyerid = b.buyerid
            ORDER BY
                o.order_date DESC;
        `);

        res.json({ salesReport: result.rows });
        console.log(result.rows);
    } catch (err) {
        console.error('Error fetching sales report:', err);
        res.status(500).send('Error fetching sales report');
    }
});

module.exports = router;