const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const morgan = require('morgan');
const cors = require('cors');
const path = require('path');
require('dotenv/config');

app.use(cors());
app.options('*', cors());

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

const api = process.env.API_URL;

//middleware
app.use(bodyParser.json());
app.use(morgan('tiny'));

const productsRouter = require('./routers/products');
const farmersRouter = require('./routers/farmers');
const farmsRouter = require('./routers/farms');
const deliveryRouter = require('./routers/delivery');
const buyersRouter = require('./routers/buyers');
const ordersRouter = require('./routers/orders');
const paymentRouter = require('./routers/payment');
const loginRouter = require('./routers/login');
const pendingRouter = require('./routers/pending');



//database connection
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


//routers
app.use(`${api}/products`, productsRouter);
app.use(`${api}/farmers`, farmersRouter);
app.use(`${api}/farms`, farmsRouter);
app.use(`${api}/delivery`, deliveryRouter);
app.use(`${api}/buyers`, buyersRouter);
app.use(`${api}/orders`, ordersRouter);
app.use(`${api}/payment`, paymentRouter);
app.use(`${api}/login`, loginRouter);
app.use(`${api}/pending`, pendingRouter);


app.listen(3000, ()=>{
    console.log(api);
    console.log("server is running http://localhost:3000");
})

