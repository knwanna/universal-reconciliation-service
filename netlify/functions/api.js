const express = require('express');
const serverless = require('serverless-http');
const cors = require('cors');
const bodyParser = require('body-parser');
const helmet = require('helmet');
const compression = require('compression');
const { RateLimiterMemory } = require('rate-limiter-flexible');
const winston = require('winston');

// Import route handlers
const reconcileRoutes = require('./routes/reconcile');
const suggestRoutes = require('./routes/suggest');
const previewRoutes = require('./routes/preview');
const extendRoutes = require('./routes/extend');
const docsRoutes = require('./routes/docs');

const app = express();

// Security middleware
app.use(helmet());
app.use(compression());

// Rate limiting
const rateLimiter = new RateLimiterMemory({
  points: 100, // 100 requests
  duration: 60, // per 60 seconds
});

app.use((req, res, next) => {
  rateLimiter.consume(req.ip)
    .then(() => next())
    .catch(() => res.status(429).json({ error: 'Too many requests' }));
});

// CORS configuration
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? ['https://your-domain.netlify.app'] 
    : ['http://localhost:3000', 'http://localhost:8888'],
  credentials: true
}));

app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ extended: true, limit: '10mb' }));

// Logger configuration
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple()
  }));
}

// Request logging middleware
app.use((req, res, next) => {
  logger.info({
    method: req.method,
    url: req.url,
    ip: req.ip,
    userAgent: req.get('User-Agent')
  });
  next();
});

// Routes
app.use('/.netlify/functions/api', reconcileRoutes);
app.use('/.netlify/functions/api', suggestRoutes);
app.use('/.netlify/functions/api', previewRoutes);
app.use('/.netlify/functions/api', extendRoutes);
app.use('/.netlify/functions/api', docsRoutes);

// Health check endpoint
app.get('/.netlify/functions/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    version: '2.0.0',
    environment: process.env.NODE_ENV || 'development'
  });
});

// Error handling middleware
app.use((error, req, res, next) => {
  logger.error({
    error: error.message,
    stack: error.stack,
    url: req.url,
    method: req.method
  });

  res.status(error.status || 500).json({
    error: process.env.NODE_ENV === 'production' 
      ? 'Internal server error' 
      : error.message
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

module.exports.handler = serverless(app);
