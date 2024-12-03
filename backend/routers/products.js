const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
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

const upload = multer({
        dest: 'uploads/', // Temporary directory for uploads
        limits: { fileSize: 5 * 1024 * 1024 }, // Limit: 5 MB
        fileFilter: (req, file, cb) => {
            const allowedTypes = ['image/jpeg', 'image/png'];
            if (!allowedTypes.includes(file.mimetype)) {
                return cb(new Error('Only JPEG and PNG files are allowed'), false);
            }
            cb(null, true);
        }
});

router.get('/', async (req, res) => {
    const category = req.query.category;

    try {
        let query = `
        SELECT p.productId, p.farmId, p.name, p.quantity, p.description, p.category, p.organic_certification, p.price, p.image_url, f.name AS farm_name
        FROM Product p
        INNER JOIN farm f ON p.farmid = f.farmid
        `;
        const params = [];

        if (category) {
            query += ' WHERE p.category = $1';
            params.push(category);
        }

        const result = await client.query(query, params);
        res.json(result.rows);
    } catch (err) {
        console.log(err);
        res.status(500).send('Error fetching products');
    }
});

router.get('/far', async (req, res) => {
    const farmer_id = req.query.farmer_id; // Read farmer_id from query params

    try {
        let result;
        if (farmer_id) {
            // Fetch products for the specific farmer
            result = await client.query('SELECT * FROM product WHERE farmid = $1', [farmer_id]);
        } else {
            // Fetch all products if no farmer_id is provided
            result = await client.query('SELECT * FROM product');
        }

        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).send('Error fetching products');
    }
});

router.get('/fari/', async (req, res) => {
    const farmer_id = req.query.farmer_id; // Read farmer_id from query params

    try {
        let result;
        if (farmer_id) {
            // Fetch products for the specific farmer
            result = await client.query('SELECT * FROM product WHERE farmid = $1', [farmer_id]);
        } else {
            // Fetch all products if no farmer_id is provided
            result = await client.query('SELECT * FROM product');
        }

        res.json(result.rows);
    } catch (err) {
        console.error('Error fetching products:', err);
        res.status(500).send('Error fetching products');
    }
});

router.get('/low-stock', async (req, res) => {
    const farmId = req.query.farmId;

    try {
        const result = await client.query(
            'SELECT * FROM product WHERE farmid = $1 AND quantity < 5',
            [farmId]
        );
        res.json(result.rows);
    } catch (err) {
        console.error('Error fetching low-stock products:', err);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

router.get('/random-products', async (req, res) => {
    try {
        const result = await client.query(`
            SELECT p.productId, p.farmId, p.name, p.quantity, p.description, p.category, p.organic_certification, p.price, p.image_url, f.name AS farm_name
            FROM Product p
            INNER JOIN farm f ON p.farmid = f.farmid
            ORDER BY RANDOM()
            LIMIT 7
        `);
        res.json(result.rows);
        console.log(result.rows)

    } catch (err) {
        console.error(err);
        res.status(500).send('Error fetching random products');
    }
});

router.get('/categories', async (req, res) => {
    try {
        const result = await client.query(`
            SELECT DISTINCT category
            FROM Product
        `);
        res.json(result.rows.map(row => row.category));
    } catch (err) {
        console.error(err);
        res.status(500).send('Error fetching product categories');
    }
});

router.get('/:id', async (req, res) => {
    const id = req.params.id;
    try {
        const result = await client.query(`
            SELECT p.productId, p.farmId, p.name, p.quantity, p.description, p.category, p.organic_certification, p.price, p.image_url, f.name AS farm_name
            FROM Product p
            INNER JOIN farm f ON p.farmid = f.farmid WHERE p.productid = $1`, [id]);
        if (result.rowCount === 0) {
            res.status(404).send("Product not found");
        } else {
            const product = result.rows[0];

            // Optional: Validate the existence of the image file
            if (product.image_url) {
                const filePath = path.join(__dirname, '../uploads', path.basename(product.image_url));
                if (!fs.existsSync(filePath)) {
                    console.log(`Image file not found at: ${filePath}`);
                }
            }

            res.json(product);
        }
    } catch (err) {
        console.error(err);
        res.status(500).send('Error fetching the product');
    }
});

// POST: Add a new product with image upload
router.post('/', upload.single('image'), async (req, res) => {
    const { farmer_id, name, quantity, description, category, organic_certification, price } = req.body;

    if (!farmer_id || !name || !quantity || !price) {
        return res.status(400).send({ error: 'Required fields are missing' });
    }

    try {
        let imageUrl = null;

        if (req.file) {
            const fileExtension = path.extname(req.file.originalname);
            const newFileName = `${Date.now()}-${req.file.originalname}`;
            const newFilePath = path.join(__dirname, '../uploads', newFileName);
            fs.renameSync(req.file.path, newFilePath);
            imageUrl = `http://localhost:3000/uploads/${newFileName}`;
        }

        const result = await client.query(
            'INSERT INTO product (farmid, name, quantity, description, category, organic_certification, price, image_url) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *',
            [farmer_id, name, quantity, description, category, organic_certification === 'true', price, imageUrl]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Database Error:', err.stack);
        res.status(500).send({ error: 'Error adding product', details: err.message });
    }
});


// DELETE product by ID
router.delete('/:id', async (req, res) => {
    const id = req.params.id;
    try {
        const result = await client.query('DELETE FROM product WHERE productid = $1', [id]);
        if (result.rowCount == 0) {
            res.status(404).send('Product not found');
        } else {
            res.status(200).send('Product deleted successfully');
        }
    } catch (err) {
        console.log(err);
        res.status(500).send('Error deleting the product');
    }
});

// PUT: Update a product (excluding image)
router.put('/:id', async (req, res) => {
    const id = req.params.id;
    const { name, quantity, description, category, organic_certification, price } = req.body;

    try {
        const result = await client.query(
            'UPDATE product SET name = $1, quantity = $2, description = $3, category = $4, organic_certification = $5, price = $6 WHERE productid = $7 RETURNING *',
            [name, quantity, description, category, organic_certification === 'true', price, id]
        );

        if (result.rowCount == 0) {
            res.status(404).send('Product not found');
        } else {
            res.status(200).json(result.rows[0]);
        }
    } catch (err) {
        console.log(err);
        res.status(500).send('Error updating the product');
    }
});

module.exports = router;
