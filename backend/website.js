
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { Client } = require('pg');
const bcrypt = require('bcrypt'); 
const crypto = require('crypto');
const nodemailer = require('nodemailer');
const session = require('express-session');
const cookieParser = require('cookie-parser');


const app = express();
app.use(bodyParser.json());
app.use(cors({
  origin: 'http://localhost:8080',
  credentials: true,  
}));
app.use(cookieParser());
app.use(session({
  secret: 'my_secret_key',
  resave: false,
  saveUninitialized: true,
  cookie: { secure: false }, 
}));


const dbConfig = {
  host: 'localhost',
    port: 5432,
    user: 'postgres',
    password: 'Alibek2003%',
    database: 'farm-data',
};

const client = new Client(dbConfig);
client.connect();

app.post('/api/register', async (req, res) => {
  const { username, email, password } = req.body;
  try {

    const hashedPassword = await bcrypt.hash(password, 10);

    const checkQuery = 'SELECT * FROM admins WHERE username = $1 OR email = $2';
    const checkValues = [username, email];
    const checkResult = await client.query(checkQuery, checkValues);

    if (checkResult.rows.length > 0) {
      return res.status(400).json({ message: 'Username or email already exists' });
    }
 
    const query = 'INSERT INTO admins (username, email, password) VALUES ($1, $2, $3) RETURNING *';
    const values = [username, email, hashedPassword];
    const result = await client.query(query, values);
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Registration failed' });
  }
});


app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;

  try {
    const query = 'SELECT * FROM admins WHERE username = $1';
    const values = [username];
    const result = await client.query(query, values);

    if (result.rows.length === 0) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const user = result.rows[0];

    const match = await bcrypt.compare(password, user.password);
    if (match) {
      req.session.userId = user.id;
      req.session.username = user.username;

      res.status(200).json({ message: 'Login successful' });
    } else {
      return res.status(401).json({ message: 'Invalid credentials' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Login failed' });
  }
});


app.post('/api/forgot-password', async (req, res) => {
  const { email } = req.body;

  try {
    const query = 'SELECT * FROM admins WHERE email = $1';
    const result = await client.query(query, [email]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Email not found' });
    }

    const token = crypto.randomBytes(20).toString('hex');
    const expiration = new Date(Date.now() + 3600000); // Token valid for 1 hour
    await client.query('UPDATE admins SET reset_token = $1, reset_token_expiration = $2 WHERE email = $3', [token, expiration, email]);

    const transporter = nodemailer.createTransport({
      service: 'Gmail',
      auth: {
        user: 'chelovekus6@gmail.com',
        pass: 'ghkk mikk gsed swuj',
      },
    });

    const mailOptions = {
      to: email,
      from: 'chelovekus6@gmail.com',
      subject: 'Password Reset',
      text: `You are receiving this because you (or someone else) have requested the reset of the password for your account.\n\nPlease click on the following link, or paste it into your browser to complete the process within one hour:\n\nhttp://localhost:8080/reset-password/${token}\n\nIf you did not request this, please ignore this email and your password will remain unchanged.\n`,
    };

    transporter.sendMail(mailOptions, (error) => {
      if (error) {
        console.error('Error sending email:', error);
        return res.status(500).json({ message: 'Error sending email' });
      }
      res.status(200).json({ message: 'Recovery email sent' });
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Password recovery failed' });
  }
});


app.post('/api/reset-password/:token', async (req, res) => {
  const { token } = req.params;
  const { password } = req.body;

  try {
    const query = 'SELECT * FROM admins WHERE reset_token = $1 AND reset_token_expiration > NOW()';
    const result = await client.query(query, [token]);

    if (result.rows.length === 0) {
      return res.status(400).json({ message: 'Invalid or expired token' });
    }

    const hashedPassword = await bcrypt.hash(password, 10); // Hash the new password

    await client.query('UPDATE admins SET password = $1, reset_token = NULL, reset_token_expiration = NULL WHERE reset_token = $2', [hashedPassword, token]);

    res.status(200).json({ message: 'Password reset successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Password reset failed' });
  }
});



app.get('/api/pending-farmers', async (req, res) => {
  if (!req.session.userId) {
    return res.status(403).json({ message: 'Access denied. Please log in.' });
  }
  try {
    const query = `
    SELECT a.farmerid, a.name AS farmer_name, a.email, a.phone_number, b.location 
    FROM farmer AS a 
    JOIN farm AS b ON a.farmerid = b.farmerid 
    WHERE a.status = $1`;
  const values = ['pending'];  
  const result = await client.query(query, values);

    if (result.rows.length === 0) {
      return res.status(200).json({ message: 'No pending farmers', data: [] });
    }

    res.status(200).json({ data: result.rows });
  } catch (error) {
    console.error('Error fetching pending farmers:', error);
    res.status(500).json({ message: 'Error fetching pending farmers' });
  }
});


app.post('/api/approve-farmer', async (req, res) => {
  if (!req.session.userId) {
    return res.status(403).json({ message: 'Access denied. Please log in.' });
  }
  const { farmerid } = req.body;

  try {

    const query = 'SELECT email FROM farmer WHERE farmerid = $1';
    const values = [farmerid];
    const result = await client.query(query, values);

    
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Farmer not found' });
    }
    const farmerEmail = result.rows[0].email;

    const updateQuery = 'UPDATE farmer SET status = $1 WHERE farmerid = $2';
    const updateValues = ['approved', farmerid];
    await client.query(updateQuery, updateValues);

    sendApproveEmail(farmerEmail);

    res.status(200).json({ message: 'Farmer approved successfully' });
  } catch (error) {
    console.error('Error approving farmer:', error);
    res.status(500).json({ message: 'Error approving farmer' });
  }
});


app.post('/api/reject-farmer', async (req, res) => {
  if (!req.session.userId) {
    return res.status(403).json({ message: 'Access denied. Please log in.' });
  }
  const { farmerId, reason } = req.body;

  try {

    const query = 'SELECT email FROM farmer WHERE farmerid = $1';
    const values = [farmerId];
    const result = await client.query(query, values);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Farmer not found' });
    }

    const farmerEmail = result.rows[0].email;

    const updateQuery = 'UPDATE farmer SET status = $1 WHERE farmerid = $2';
    const updateValues = ['rejected', farmerId];
    await client.query(updateQuery, updateValues);

    sendRejectionEmail(farmerEmail, reason);

    res.status(200).json({ message: 'Farmer rejected' });
  } catch (error) {
    console.error('Error rejecting farmer:', error);
    res.status(500).json({ message: 'Error rejecting farmer' });
  }
});

function sendRejectionEmail(farmerEmail, reason) {
  const nodemailer = require('nodemailer');

  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'chelovekus6@gmail.com',
      pass: 'ghkk mikk gsed swuj',
    },
  });

  const mailOptions = {
    from: 'chelovekus6@gmail.com',
    to: farmerEmail,
    subject: 'Your farmer registration status',
    text: `Dear Farmer, \n\nUnfortunately, your registration has been rejected. Reason: ${reason}\n\nThank you.`,
  };


  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.log('Error sending email:', error);
    } else {
      console.log('Email sent: ' + info.response);
    }
  });
}



function sendApproveEmail(farmerEmail) {
  const nodemailer = require('nodemailer');

  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'chelovekus6@gmail.com',
      pass: 'ghkk mikk gsed swuj',
    },
  });

  const mailOptions = {
    from: 'chelovekus6@gmail.com',
    to: farmerEmail,
    subject: 'Your farmer registration status',
    text: `Dear Farmer, \n\nYour registration has been approved.\n\nThank you.`,
  };


  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.log('Error sending email:', error);
    } else {
      console.log('Email sent: ' + info.response);
    }
  });
}


app.get('/api/users', async (req, res) => {
  if (!req.session.userId) {
    return res.status(403).json({ message: 'Access denied. Please log in.' });
  }
  try {
    const farmers = await client.query('SELECT * FROM farmer');
    const buyers = await client.query('SELECT * FROM buyer');
    res.status(200).json({ farmers: farmers.rows, buyers: buyers.rows });
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ message: 'Failed to fetch users' });
  }
});


app.get('/api/users/:type/:id', async (req, res) => {
  if (!req.session.userId) {
    return res.status(403).json({ message: 'Access denied. Please log in.' });
  }
  const { type, id } = req.params;
  try {
    if (!id || !type) {
      return res.status(400).json({ error: 'Missing user type or ID' });
    }
 
    if (type !== 'farmer' && type !== 'buyer') {
      return res.status(400).json({ error: 'Invalid user type' });
    }

    const query = `SELECT * FROM ${type} WHERE ${type}id = $1`; 
    const result = await client.query(query, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(result.rows[0]); 
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


app.put('/api/edit-user', async (req, res) => {
  if (!req.session.userId) {
    return res.status(403).json({ message: 'Access denied. Please log in.' });
  }
  const { userId, type, updates } = req.body;
  const table = type === 'farmer' ? 'farmer' : 'buyer';
  const userIdColumn = type === 'farmer' ? 'farmerid' : 'buyerid';

  if (!['farmer', 'buyer'].includes(type)) {
    return res.status(400).json({ message: 'Invalid user type' });
  }

  try {
    const keys = Object.keys(updates);
    const values = Object.values(updates);
    const setString = keys.map((key, i) => `${key} = $${i + 1}`).join(', ');

    const result = await client.query(
      `UPDATE ${table} SET ${setString} WHERE ${userIdColumn} = $${keys.length + 1} RETURNING *`,
      [...values, userId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ message: `${type} updated successfully`, user: result.rows[0] });
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({ message: 'Failed to update user' });
  }
});


app.delete('/api/delete-user', async (req, res) => {
  if (!req.session.userId) {
    return res.status(403).json({ message: 'Access denied. Please log in.' });
  }
  const { userId, type } = req.body;
  const table = type === 'farmer' ? 'farmer' : 'buyer';
  const userIdColumn = type === 'farmer' ? 'farmerid' : 'buyerid';

  if (!['farmer', 'buyer'].includes(type)) {
    return res.status(400).json({ message: 'Invalid user type' });
  }

  try {
    const result = await client.query(`DELETE FROM ${table} WHERE ${userIdColumn} = $1 RETURNING *`, [userId]);

    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ message: `${type} deleted successfully`, user: result.rows[0] });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({ message: 'Failed to delete user' });
  }
});


app.post('/api/toggle-user-status', async (req, res) => {
  if (!req.session.userId) {
    return res.status(403).json({ message: 'Access denied. Please log in.' });
  }
  const { userId, type, enable } = req.body;
  const table = type === 'farmer' ? 'farmer' : 'buyer';
  const userIdColumn = type === 'farmer' ? 'farmerid' : 'buyerid';

  if (!['farmer', 'buyer'].includes(type)) {
    return res.status(400).json({ message: 'Invalid user type' });
  }

  try {
    const result = await client.query(
      `UPDATE ${table} SET activity = $1 WHERE ${userIdColumn} = $2 RETURNING *`,
      [enable ? 'active' : 'disabled', userId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({
      message: `${type} ${enable ? 'enabled' : 'disabled'} successfully`,
      user: result.rows[0],
    });
  } catch (error) {
    console.error('Error toggling user status:', error);
    res.status(500).json({ message: 'Failed to toggle user status' });
  }
});


app.post('/api/logout', (req, res) => {

  req.session.destroy((err) => {
    if (err) {
      return res.status(500).json({ message: 'Failed to log out' });
    }
    res.clearCookie('connect.sid');

    return res.status(200).json({ message: 'Logged out successfully' });
  });
});


const PORT = 3003;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});