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
        const result = await client.query('SELECT * FROM orders');
        res.json(result.rows);
    } catch (err) {
        console.log(err);
        res.send('Error');
    }
})

router.get('/orders-by-farm/:farmID', async (req, res) => {
    console.log(`Received GET request for farmID: ${req.params.farmID}`);
    const farmID = req.params.farmID;

    try {
        const query = `
            SELECT 
                oi.order_item_id, 
                oi.productid, 
                oi.quantity, 
                oi.status, 
                o.buyerid, 
                b.name AS buyer_name,  -- Fetch buyer's name
                p.name AS product_name, -- Fetch product name
                p.image_url -- Fetch product image
            FROM order_items oi
            INNER JOIN orders o ON oi.orderid = o.orderid
            INNER JOIN product p ON oi.productid = p.productid
            INNER JOIN buyer b ON o.buyerid = b.buyerid -- Join with buyer table
            WHERE p.farmid = $1
            ORDER BY oi.status, o.order_date DESC
        `;
        const result = await client.query(query, [farmID]);
        console.log('Query Result:', result.rows); // Log the query result for debugging

        if (result.rows.length > 0) {
            const groupedItems = result.rows.reduce((acc, item) => {
                acc[item.status] = acc[item.status] || [];
                acc[item.status].push(item);
                return acc;
            }, {});
            res.json(groupedItems);
        } 
        else {
            res.status(404).send(`No orders found for farmID: ${farmID}`);
        }
    } catch (err) {
        console.error('Error fetching orders by farm:', err);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

router.get('/:id', async (req, res) => {
    const id = req.params.id;
    try {
        const orderQuery = `
            SELECT orderid, buyerid, order_date, total_price, payment_method, delivery_method, delivery_address 
            FROM orders 
            WHERE orderid = $1
        `;
        const itemsQuery = `
            SELECT oi.productid, oi.quantity, oi.price, oi.total_price, p.name AS product_name, p.image_url, oi.status
            FROM order_items oi
            INNER JOIN product p ON oi.productid = p.productid
            WHERE oi.orderid = $1
        `;
        const orderResult = await client.query(orderQuery, [id]);
        const itemsResult = await client.query(itemsQuery, [id]);

        if (orderResult.rows.length > 0) {
            const order = orderResult.rows[0];
            order.items = itemsResult.rows; // Add items array to the order
            res.json(order);
        } else {
            res.status(404).send('Order not found');
        }
    } catch (err) {
        console.error(err);
        res.status(500).send('Server error');
    }
});


router.get('/buyer/:id', async(req, res) => {
    const id = req.params.id;
    try {
        const result = await client.query('SELECT orderid, buyerid, order_date, total_price, payment_method, delivery_method, delivery_address FROM orders WHERE buyerid = $1 ORDER BY order_date DESC', [id]);
        res.json(result.rows);
    }
    catch (err){
        console.error(err.message);
        res.status(500).send('Server error');
    }
})

router.post('/', async(req, res) => {
    const {buyerid, total_price, payment_method, delivery_method, delivery_address} = req.body;
    try {
        const result = await client.query('INSERT INTO orders (buyerid, total_price, payment_method, delivery_method, delivery_address) VALUES ($1, $2, $3, $4, $5) RETURNING *', 
            [buyerid, total_price, payment_method, delivery_method, delivery_address]
        );
        res.status(201).json(result.rows[0]);
    } catch(err) {
        console.log(err);
        res.status(500).json({error: "Error adding order"});
    }
})

router.put('/order-items/update-status', async (req, res) => {
    const { items } = req.body; // Expecting an array of { order_item_id, status }

    if (!items || !Array.isArray(items)) {
        return res.status(400).json({ error: 'Invalid payload. "items" should be an array.' });
    }

    try {
        // Start a transaction
        await client.query('BEGIN');

        for (const item of items) {
            const { order_item_id, status } = item;

            if (!order_item_id || !status) {
                await client.query('ROLLBACK');
                return res
                    .status(400)
                    .json({ error: 'Each item must have "order_item_id" and "status".' });
            }

            await client.query(
                'UPDATE order_items SET status = $1 WHERE order_item_id = $2',
                [status, order_item_id]
            );
        }

        // Commit the transaction
        await client.query('COMMIT');
        res.status(200).json({ message: 'Statuses updated successfully!' });
    } catch (err) {
        console.error('Error updating statuses:', err);
        await client.query('ROLLBACK');
        res.status(500).json({ error: 'Failed to update statuses.' });
    }
});

router.post('/order-items', async(req, res) => {
    const {orderid, productid, quantity, price, total_price} = req.body;
    console.log(req.body);
    try {
        const result = await client.query('INSERT INTO order_items(orderid, productid, quantity, price, total_price) VALUES ($1, $2, $3, $4, $5) RETURNING *',
            [orderid, productid, quantity, price, total_price]
        );
        console.log("update query starting");
        const updateProductQuantityQuery = `
            UPDATE product
            SET quantity = quantity - $1
            WHERE productid = $2 AND quantity >= $1
            RETURNING quantity;
        `;
        const result1 = await client.query(updateProductQuantityQuery, [quantity, productid]);
        console.log("update query finished");
        res.status(201).json(result.rows[0]);
    } catch(err) {
        res.status(500).send('Order details were not added');
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