const express = require('express');
const serverless = require('serverless-http');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Import route handlers
const metadata = require('./metadata');
const reconcile = require('./reconcile');
const preview = require('./preview');
const suggestEntity = require('./suggest-entity');
const suggestType = require('./suggest-type');
const suggestProperty = require('./suggest-property');
const extend = require('./extend');
const extendPropose = require('./extend-propose');
const streamChunk = require('./stream-chunk');

// Mount routes
app.get('/.netlify/functions/api', metadata.handler);
app.post('/.netlify/functions/api/reconcile', reconcile.handler);
app.get('/.netlify/functions/api/preview', preview.handler);
app.get('/.netlify/functions/api/suggest/entity', suggestEntity.handler);
app.get('/.netlify/functions/api/suggest/type', suggestType.handler);
app.get('/.netlify/functions/api/suggest/property', suggestProperty.handler);
app.post('/.netlify/functions/api/extend', extend.handler);
app.post('/.netlify/functions/api/extend/propose', extendPropose.handler);
app.post('/.netlify/functions/api/stream-chunk', streamChunk.handler);

// Health check endpoint
app.get('/.netlify/functions/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Catch-all 404
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `The requested URL ${req.originalUrl} was not found.`
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

module.exports.handler = serverless(app);