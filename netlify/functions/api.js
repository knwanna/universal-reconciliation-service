const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Import Swagger setup and swaggerSpec
const setupSwagger = require('../../src/swagger');
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

// Setup Swagger UI & JSON spec
const baseUrl = process.env.BASE_URL || 'http://localhost:8888';

const swaggerOptions = {
  definition: {
    openapi: '3.0.3',
    info: {
      title: 'Universal Reconciliation Service API',
      version: '1.0.0',
      description: 'API for reconciliation service using Express and Gemini API',
      contact: { name: 'Google', email: 'support@example.com' },
      license: { name: 'MIT', url: 'https://opensource.org/licenses/MIT' },
    },
    servers: [{ url: baseUrl, description: 'API base URL' }],
  },
  apis: [path.join(__dirname, 'routes', '*.js')],
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
app.get('/swagger.json', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.send(swaggerSpec);
});

// Import your route handlers
const reconcileRouter = require('./routes/reconcile');
const metadataRouter = require('./routes/metadata');
const previewRouter = require('./routes/preview');
const suggestRouter = require('./routes/suggest-entity');
const suggestPropertyRouter = require('./routes/suggest-property');
const suggestTypeRouter = require('./routes/suggest-type');
const extendRouter = require('./routes/extend');
const extendProposeRouter = require('./routes/extend-propose');
const streamChunkRouter = require('./routes/stream-chunk');

// Register routes
app.use('/', metadataRouter);
app.use('/reconcile', reconcileRouter);
app.use('/preview', previewRouter);
app.use('/suggest/entity', suggestRouter);
app.use('/suggest/property', suggestPropertyRouter);
app.use('/suggest/type', suggestTypeRouter);
app.use('/extend', extendRouter);
app.use('/extend/propose', extendProposeRouter);
app.use('/stream-chunk', streamChunkRouter);

// Catch-all 404 for unknown routes
app.use((req, res, next) => {
  res.status(404).json({
    error: 'Not Found',
    message: `The requested URL ${req.originalUrl} was not found on this server.`,
  });
});

// Global error handler (production ready)
app.use((err, req, res, next) => {
  console.error('Server error:', err.stack || err);

  // Customize error response based on environment
  const response = {
    error: 'Internal Server Error',
  };

  if (process.env.NODE_ENV !== 'production') {
    response.message = err.message;
    response.stack = err.stack;
  }

  res.status(500).json(response);
});

module.exports = app;
