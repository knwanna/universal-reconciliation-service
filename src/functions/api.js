const express = require('express');
const serverless = require('serverless-http');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();

app.use(cors());
app.use(bodyParser.json({ limit: '10mb' }));

// Mount individual function routes
app.use('/.netlify/functions/api/reconcile', require('./reconcile'));
app.use('/.netlify/functions/api/suggest', require('./suggest'));
app.use('/.netlify/functions/api/preview', require('./preview'));
app.use('/.netlify/functions/api/extend', require('./extend'));
app.use('/.netlify/functions/api/metadata', require('./metadata'));

// Health check
app.get('/.netlify/functions/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    environment: 'netlify'
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

module.exports.handler = serverless(app);