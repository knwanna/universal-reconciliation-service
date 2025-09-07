# Universal Reconciliation Service - Enhanced Testing & Deployment Setup
Write-Host "🚀 Setting up Comprehensive Testing & Deployment Environment..." -ForegroundColor Green

# Create project structure
Write-Host "📁 Creating enhanced project structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "universal-reconciliation-service" -Force
Set-Location "universal-reconciliation-service"

# Main directories
New-Item -ItemType Directory -Path "netlify/functions" -Force
New-Item -ItemType Directory -Path "public" -Force
New-Item -ItemType Directory -Path "data" -Force
New-Item -ItemType Directory -Path "tests" -Force
New-Item -ItemType Directory -Path "test-data" -Force
New-Item -ItemType Directory -Path "scripts" -Force
New-Item -ItemType Directory -Path "docs" -Force
New-Item -ItemType Directory -Path "postman" -Force
New-Item -ItemType Directory -Path "analysis" -Force

# Subdirectories for organized testing
New-Item -ItemType Directory -Path "tests/unit" -Force
New-Item -ItemType Directory -Path "tests/integration" -Force
New-Item -ItemType Directory -Path "tests/performance" -Force
New-Item -ItemType Directory -Path "test-data/samples" -Force
New-Item -ItemType Directory -Path "test-data/benchmarks" -Force
New-Item -ItemType Directory -Path "analysis/reports" -Force
New-Item -ItemType Directory -Path "analysis/datasets" -Force

# Create enhanced package.json with testing dependencies
Write-Host "📦 Creating enhanced package.json with testing capabilities..." -ForegroundColor Yellow
@'
{
  "name": "universal-reconciliation-service",
  "version": "2.1.0",
  "description": "Universal Reconciliation Service with comprehensive testing suite",
  "main": "netlify/functions/api.js",
  "scripts": {
    "dev": "netlify dev",
    "build": "echo 'No build step required'",
    "deploy": "netlify deploy --prod",
    "start": "node server.js",
    "test": "jest --verbose",
    "test:unit": "jest tests/unit --verbose",
    "test:integration": "jest tests/integration --verbose",
    "test:performance": "node tests/performance/runner.js",
    "test:coverage": "jest --coverage",
    "load-test": "artillery run tests/performance/load-test.yml",
    "generate-docs": "node scripts/generate-docs.js",
    "analyze-data": "node scripts/analyze-datasets.js",
    "export-postman": "node scripts/export-postman-collection.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "serverless-http": "^3.2.0",
    "cors": "^2.8.5",
    "body-parser": "^1.20.2",
    "@google/generative-ai": "^0.2.1",
    "rate-limiter-flexible": "^2.4.1",
    "helmet": "^7.1.0",
    "compression": "^1.7.4",
    "joi": "^17.11.0",
    "winston": "^3.11.0"
  },
  "devDependencies": {
    "netlify-cli": "^12.0.0",
    "jest": "^29.7.0",
    "supertest": "^6.3.3",
    "artillery": "^2.0.0",
    "axios": "^1.6.0",
    "chance": "^1.1.11",
    "csv-parser": "^3.0.0",
    "json2csv": "^6.0.0",
    "markdown-table": "^3.0.3"
  },
  "keywords": [
    "reconciliation",
    "api",
    "openrefine",
    "netlify",
    "serverless",
    "testing",
    "postman"
  ],
  "author": "Universal Reconciliation Team",
  "license": "MIT"
}
'@ | Set-Content -Path "package.json"

# Create enhanced netlify.toml with deployment optimization
Write-Host "⚙️ Creating deployment-optimized netlify.toml..." -ForegroundColor Yellow
@'
[build]
  publish = "public"
  functions = "netlify/functions"

[build.environment]
  NODE_VERSION = "18"
  NODE_ENV = "production"

[functions]
  node_bundler = "esbuild"
  external_node_modules = ["@google/generative-ai"]

[[redirects]]
  from = "/api/*"
  to = "/.netlify/functions/api/:splat"
  status = 200

[[redirects]]
  from = "/reconcile"
  to = "/.netlify/functions/api/reconcile"
  status = 200

[[redirects]]
  from = "/suggest"
  to = "/.netlify/functions/api/suggest"
  status = 200

[[redirects]]
  from = "/preview/*"
  to = "/.netlify/functions/api/preview/:splat"
  status = 200

[[redirects]]
  from = "/extend"
  to = "/.netlify/functions/api/extend"
  status = 200

[[redirects]]
  from = "/metadata"
  to = "/.netlify/functions/api"
  status = 200

[[redirects]]
  from = "/health"
  to = "/.netlify/functions/api/health"
  status = 200

[[redirects]]
  from = "/test"
  to = "/test-runner.html"
  status = 200

[[redirects]]
  from = "/docs"
  to = "/documentation.html"
  status = 200

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[functions.api]
  timeout = 30
'@ | Set-Content -Path "netlify.toml"

# Create comprehensive API function with enhanced validation
Write-Host "📝 Creating production-ready API function..." -ForegroundColor Yellow
@'
const express = require('express');
const serverless = require('serverless-http');
const cors = require('cors');
const bodyParser = require('body-parser');
const helmet = require('helmet');
const compression = require('compression');
const { RateLimiterMemory } = require('rate-limiter-flexible');
const winston = require('winston');
const Joi = require('joi');
const { GoogleGenerativeAI } = require('@google/generative-ai');

const app = express();

// Initialize Gemini AI
let genAI;
let geminiInitialized = false;

if (process.env.GEMINI_API_KEY) {
  try {
    genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    geminiInitialized = true;
    console.log('Gemini AI initialized successfully');
  } catch (error) {
    console.error('Failed to initialize Gemini AI:', error.message);
  }
} else {
  console.warn('GEMINI_API_KEY not found. Gemini features will be disabled.');
}

// Security middleware
app.use(helmet());
app.use(compression());

// Rate limiting - more permissive for testing
const rateLimiter = new RateLimiterMemory({
  points: process.env.RATE_LIMIT_MAX || 1000, // Higher for testing
  duration: process.env.RATE_LIMIT_WINDOW || 60, // per 60 seconds
});

app.use((req, res, next) => {
  rateLimiter.consume(req.ip)
    .then(() => next())
    .catch(() => res.status(429).json({ 
      error: 'Too many requests',
      retryAfter: 60 
    }));
});

// CORS configuration
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? ['https://*.netlify.app', 'https://*.openrefine.org'] 
    : ['http://localhost:3000', 'http://localhost:3333', 'http://localhost:8888', 'http://localhost:5000'],
  credentials: true
}));

app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ extended: true, limit: '10mb' }));

// Logger configuration
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' })
  ]
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.simple()
    )
  }));
}

// Request logging middleware
app.use((req, res, next) => {
  logger.info({
    method: req.method,
    url: req.url,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    timestamp: new Date().toISOString()
  });
  next();
});

// Validation schemas
const reconcileSchema = Joi.object({
  queries: Joi.object().pattern(
    Joi.string(),
    Joi.object({
      query: Joi.string().required().max(500),
      type: Joi.string().optional().max(100),
      limit: Joi.number().optional().min(1).max(100),
      properties: Joi.array().items(Joi.object()).optional().max(20)
    })
  ).optional(),
  query: Joi.string().optional().max(500),
  type: Joi.string().optional().max(100),
  limit: Joi.number().optional().min(1).max(100)
});

const suggestSchema = Joi.object({
  prefix: Joi.string().required().min(1).max(100),
  type: Joi.string().optional().max(100),
  limit: Joi.number().optional().min(1).max(50)
});

const previewSchema = Joi.object({
  id: Joi.string().required().min(1).max(100)
});

// Service metadata endpoint
app.get('/.netlify/functions/api', (req, res) => {
  res.json({
    name: 'Universal Reconciliation Service',
    identifierSpace: 'http://rdf.freebase.com/ns/type.object.id',
    schemaSpace: 'http://rdf.freebase.com/ns/type.object.id',
    defaultTypes: [
      { id: '/people/person', name: 'Person' },
      { id: '/organization/organization', name: 'Organization' },
      { id: '/location/location', name: 'Location' },
      { id: '/book/book', name: 'Book' },
      { id: '/general', name: 'General Entity' }
    ],
    view: {
      url: 'https://example.com/entity/{{id}}'
    },
    preview: {
      url: '/.netlify/functions/api/preview?id={{id}}',
      width: 400,
      height: 200
    },
    suggest: {
      entity: {
        service_url: '/.netlify/functions/api',
        service_path: '/suggest'
      }
    },
    extend: {
      propose_properties: {
        service_url: '/.netlify/functions/api',
        service_path: '/properties'
      }
    },
    documentation: {
      service_url: '/.netlify/functions/api',
      service_path: '/docs'
    }
  });
});

// Reconciliation endpoint with comprehensive validation
app.post('/.netlify/functions/api/reconcile', async (req, res) => {
  try {
    // Validate input
    const { error, value } = reconcileSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ 
        error: 'Validation failed',
        details: error.details 
      });
    }

    const { queries, query, type, limit } = value;
    
    // Handle single query
    if (query) {
      const results = await reconcileQuery(query, type, limit || 5);
      return res.json({
        result: results,
        meta: {
          service: 'universal-reconciliation',
          timestamp: new Date().toISOString(),
          engine: geminiInitialized ? 'gemini-ai' : 'basic-matching'
        }
      });
    }
    
    // Handle multiple queries
    if (queries && Object.keys(queries).length > 0) {
      const results = {};
      const queryIds = Object.keys(queries);
      
      // Process queries in parallel with limit
      const processQueue = async (queryId) => {
        try {
          const queryData = queries[queryId];
          const matches = await reconcileQuery(
            queryData.query,
            queryData.type,
            queryData.limit || 5
          );
          
          results[queryId] = {
            result: matches,
            status: 'success'
          };
        } catch (error) {
          results[queryId] = {
            error: error.message,
            status: 'error'
          };
        }
      };
      
      // Process with concurrency limit to avoid overloading
      const concurrencyLimit = 5;
      for (let i = 0; i < queryIds.length; i += concurrencyLimit) {
        const batch = queryIds.slice(i, i + concurrencyLimit);
        await Promise.all(batch.map(processQueue));
      }
      
      return res.json({
        ...results,
        meta: {
          service: 'universal-reconciliation',
          timestamp: new Date().toISOString(),
          engine: geminiInitialized ? 'gemini-ai' : 'basic-matching',
          processed: queryIds.length
        }
      });
    }
    
    // No query provided
    res.status(400).json({ 
      error: 'No query provided',
      details: 'Please provide either a "query" parameter or "queries" object' 
    });
  } catch (error) {
    logger.error('Reconciliation error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      requestId: req.id 
    });
  }
});

// Helper function to reconcile a single query
async function reconcileQuery(query, type, limit) {
  // If Gemini AI is available, use it for reconciliation
  if (geminiInitialized) {
    try {
      return await reconcileWithGemini(query, type, limit);
    } catch (error) {
      logger.warn('Gemini reconciliation failed, falling back to basic matching:', error);
    }
  }
  
  // Fallback to enhanced matching with sample data
  return enhancedReconciliation(query, type, limit);
}

// Gemini AI-powered reconciliation
async function reconcileWithGemini(query, type, limit) {
  const model = genAI.getGenerativeModel({ model: "gemini-pro" });
  
  const prompt = `
    You are an entity reconciliation service. Match the following query to known entities.
    Query: "${query}"
    ${type ? `Entity type: ${type}` : ''}
    
    Return a JSON array of matches with this structure:
    [{
      "id": "unique_identifier",
      "name": "matched_entity_name",
      "type": ["entity_type"],
      "score": 0.95,
      "match": true,
      "features": {
        "description": "brief_description",
        "confidence": "high/medium/low"
      }
    }]
    
    Limit to ${limit} best matches.
  `;

  const result = await model.generateContent(prompt);
  const response = await result.response;
  const text = response.text();
  
  // Extract JSON from response
  const jsonMatch = text.match(/\[[\s\S]*\]/);
  if (jsonMatch) {
    try {
      return JSON.parse(jsonMatch[0]);
    } catch (parseError) {
      logger.error('Failed to parse Gemini response:', parseError);
      throw new Error('Failed to process AI response');
    }
  }
  
  return [];
}

// Enhanced reconciliation with sample data
function enhancedReconciliation(query, type, limit) {
  // Load sample data based on type
  let sampleData = [];
  
  if (!type || type.toLowerCase().includes('person')) {
    sampleData = sampleData.concat(require('../data/sample-people.json'));
  }
  
  if (!type || type.toLowerCase().includes('organization') || type.toLowerCase().includes('company')) {
    sampleData = sampleData.concat(require('../data/sample-organizations.json'));
  }
  
  if (!type || type.toLowerCase().includes('location') || type.toLowerCase().includes('place')) {
    sampleData = sampleData.concat(require('../data/sample-locations.json'));
  }
  
  if (!type || type.toLowerCase().includes('book')) {
    sampleData = sampleData.concat(require('../data/sample-books.json'));
  }
  
  // If no type specified or no matches, use all data
  if (sampleData.length === 0) {
    sampleData = require('../data/sample-people.json')
      .concat(require('../data/sample-organizations.json'))
      .concat(require('../data/sample-locations.json'))
      .concat(require('../data/sample-books.json'));
  }
  
  // Score matches based on query similarity
  const scoredMatches = sampleData.map(item => {
    const queryLower = query.toLowerCase();
    const nameLower = item.name.toLowerCase();
    
    let score = 0;
    
    // Exact match
    if (nameLower === queryLower) {
      score = 1.0;
    }
    // Contains query
    else if (nameLower.includes(queryLower)) {
      score = 0.8 + (0.1 * (queryLower.length / nameLower.length));
    }
    // Query contains name
    else if (queryLower.includes(nameLower)) {
      score = 0.7 + (0.1 * (nameLower.length / queryLower.length));
    }
    // Word overlap
    else {
      const queryWords = new Set(queryLower.split(/\s+/));
      const nameWords = new Set(nameLower.split(/\s+/));
      const intersection = new Set([...queryWords].filter(x => nameWords.has(x)));
      const union = new Set([...queryWords, ...nameWords]);
      
      if (union.size > 0) {
        score = intersection.size / union.size;
      }
    }
    
    // Type bonus
    if (type && item.type && item.type.some(t => 
      t.toLowerCase().includes(type.toLowerCase()))) {
      score += 0.1;
    }
    
    return {
      ...item,
      score: Math.min(0.99, score), // Cap at 0.99 for non-exact matches
      match: score > 0.5
    };
  });
  
  // Sort by score and limit
  return scoredMatches
    .sort((a, b) => b.score - a.score)
    .slice(0, limit)
    .map(match => ({
      id: match.id,
      name: match.name,
      type: match.type,
      score: match.score,
      match: match.match,
      features: {
        description: match.description,
        confidence: match.score > 0.8 ? 'high' : match.score > 0.5 ? 'medium' : 'low'
      }
    }));
}

// Suggestion endpoint with validation
app.get('/.netlify/functions/api/suggest', async (req, res) => {
  try {
    // Validate input
    const { error, value } = suggestSchema.validate(req.query);
    if (error) {
      return res.status(400).json({ 
        error: 'Validation failed',
        details: error.details 
      });
    }

    const { prefix, type, limit } = value;
    
    let suggestions = [];
    
    if (geminiInitialized) {
      try {
        suggestions = await suggestWithGemini(prefix, type, parseInt(limit) || 10);
      } catch (error) {
        logger.warn('Gemini suggestion failed:', error);
      }
    }
    
    // Fallback if Gemini fails or not available
    if (suggestions.length === 0) {
      suggestions = enhancedSuggestion(prefix, type, parseInt(limit) || 10);
    }
    
    res.json({
      result: suggestions.map(suggestion => ({
        id: suggestion.id,
        name: suggestion.name,
        type: suggestion.type,
        score: suggestion.score || 0.8,
        match: true
      })),
      meta: {
        service: 'universal-reconciliation',
        timestamp: new Date().toISOString(),
        engine: geminiInitialized ? 'gemini-ai' : 'basic-matching'
      }
    });
  } catch (error) {
    logger.error('Suggestion error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      requestId: req.id 
    });
  }
});

// Gemini AI-powered suggestions
async function suggestWithGemini(prefix, type, limit) {
  const model = genAI.getGenerativeModel({ model: "gemini-pro" });
  
  const prompt = `
    Suggest entity names starting with: "${prefix}"
    ${type ? `Entity type: ${type}` : ''}
    
    Return a JSON array of suggestions:
    [{
      "id": "unique_id",
      "name": "suggested_name",
      "type": ["entity_type"],
      "score": 0.9
    }]
    
    Limit to ${limit} suggestions.
  `;

  const result = await model.generateContent(prompt);
  const response = await result.response;
  const text = response.text();
  
  const jsonMatch = text.match(/\[[\s\S]*\]/);
  if (jsonMatch) {
    try {
      return JSON.parse(jsonMatch[0]);
    } catch (parseError) {
      logger.error('Failed to parse Gemini suggestion response:', parseError);
      return [];
    }
  }
  
  return [];
}

// Enhanced suggestion with sample data
function enhancedSuggestion(prefix, type, limit) {
  // Load appropriate sample data
  let sampleData = [];
  
  if (!type || type.toLowerCase().includes('person')) {
    sampleData = sampleData.concat(require('../data/sample-people.json'));
  }
  
  if (!type || type.toLowerCase().includes('organization') || type.toLowerCase().includes('company')) {
    sampleData = sampleData.concat(require('../data/sample-organizations.json'));
  }
  
  if (!type || type.toLowerCase().includes('location') || type.toLowerCase().includes('place')) {
    sampleData = sampleData.concat(require('../data/sample-locations.json'));
  }
  
  if (!type || type.toLowerCase().includes('book')) {
    sampleData = sampleData.concat(require('../data/sample-books.json'));
  }
  
  // If no type specified or no matches, use all data
  if (sampleData.length === 0) {
    sampleData = require('../data/sample-people.json')
      .concat(require('../data/sample-organizations.json'))
      .concat(require('../data/sample-locations.json'))
      .concat(require('../data/sample-books.json'));
  }
  
  // Filter by prefix and type
  return sampleData
    .filter(item => 
      item.name.toLowerCase().startsWith(prefix.toLowerCase()) &&
      (!type || item.type.some(t => t.toLowerCase().includes(type.toLowerCase())))
    )
    .slice(0, limit);
}

// Preview endpoint with validation
app.get('/.netlify/functions/api/preview', (req, res) => {
  try {
    // Validate input
    const { error, value } = previewSchema.validate(req.query);
    if (error) {
      return res.status(400).json({ 
        error: 'Validation failed',
        details: error.details 
      });
    }

    const { id } = value;
    
    // Load preview data from all sample datasets
    const allData = []
      .concat(require('../data/sample-people.json'))
      .concat(require('../data/sample-organizations.json'))
      .concat(require('../data/sample-locations.json'))
      .concat(require('../data/sample-books.json'));
    
    const preview = allData.find(item => item.id === id) || {
      id: id,
      name: 'Unknown Entity',
      description: 'No information available for this entity',
      details: {}
    };
    
    res.json({
      id: preview.id,
      name: preview.name,
      description: preview.description,
      details: preview.details || {},
      html: generatePreviewHtml(preview),
      meta: {
        service: 'universal-reconciliation',
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    logger.error('Preview error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      requestId: req.id 
    });
  }
});

// Generate HTML preview
function generatePreviewHtml(preview) {
  return `
    <div style="padding: 20px; font-family: Arial, sans-serif; max-width: 600px;">
      <h2 style="color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px;">
        ${preview.name}
      </h2>
      <p style="color: #7f8c8d; font-style: italic;">${preview.description}</p>
      ${preview.details && Object.keys(preview.details).length > 0 ? `
        <h3 style="color: #34495e;">Details:</h3>
        <ul style="list-style: none; padding: 0;">
          ${Object.entries(preview.details).map(([key, value]) => `
            <li style="padding: 5px 0; border-bottom: 1px solid #ecf0f1;">
              <strong style="color: #2c3e50;">${key}:</strong> 
              <span style="color: #7f8c8d;">${value}</span>
            </li>
          `).join('')}
        </ul>
      ` : ''}
      <div style="margin-top: 20px; padding: 10px; background: #f8f9fa; border-radius: 5px;">
        <small style="color: #95a5a6;">
          Provided by Universal Reconciliation Service • ${new Date().toLocaleDateString()}
        </small>
      </div>
    </div>
  `;
}

// Properties endpoint for data extension
app.get('/.netlify/functions/api/properties', (req, res) => {
  res.json({
    properties: [
      { id: 'name', name: 'Name' },
      { id: 'description', name: 'Description' },
      { id: 'birthDate', name: 'Birth Date' },
      { id: 'deathDate', name: 'Death Date' },
      { id: 'occupation', name: 'Occupation' },
      { id: 'knownFor', name: 'Known For' },
      { id: 'foundationDate', name: 'Foundation Date' },
      { id: 'location', name: 'Location' },
      { id: 'genre', name: 'Genre' },
      { id: 'publishedDate', name: 'Published Date' }
    ],
    meta: {
      service: 'universal-reconciliation',
      timestamp: new Date().toISOString()
    }
  });
});

// Data extension endpoint
app.post('/.netlify/functions/api/extend', (req, res) => {
  try {
    const { ids, properties } = req.body;
    
    if (!ids || !Array.isArray(ids) || ids.length === 0) {
      return res.status(400).json({ 
        error: 'Invalid request',
        details: 'Please provide an array of entity IDs to extend' 
      });
    }
    
    // Load all sample data
    const allData = []
      .concat(require('../data/sample-people.json'))
      .concat(require('../data/sample-organizations.json'))
      .concat(require('../data/sample-locations.json'))
      .concat(require('../data/sample-books.json'));
    
    // Extend each entity with requested properties
    const extendedData = ids.map(id => {
      const entity = allData.find(item => item.id === id) || { id, name: 'Unknown' };
      const extendedProperties = {};
      
      // Add requested properties if available
      if (properties && Array.isArray(properties)) {
        properties.forEach(prop => {
          if (entity[prop] !== undefined) {
            extendedProperties[prop] = entity[prop];
          }
        });
      } else {
        // Include all available properties if none specified
        Object.keys(entity).forEach(key => {
          if (key !== 'id' && key !== 'name' && key !== 'type') {
            extendedProperties[key] = entity[key];
          }
        });
      }
      
      return {
        id: entity.id,
        name: entity.name,
        type: entity.type || ['general'],
        properties: extendedProperties
      };
    });
    
    res.json({ 
      rows: extendedData,
      meta: {
        service: 'universal-reconciliation',
        timestamp: new Date().toISOString(),
        extended: extendedData.length
      }
    });
  } catch (error) {
    logger.error('Extension error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      requestId: req.id 
    });
  }
});

// Documentation endpoint
app.get('/.netlify/functions/api/docs', (req, res) => {
  res.json({
    name: 'Universal Reconciliation Service API Documentation',
    version: '2.1.0',
    endpoints: [
      {
        path: '/',
        method: 'GET',
        description: 'Service metadata and capabilities',
        parameters: []
      },
      {
        path: '/reconcile',
        method: 'POST',
        description: 'Reconcile entities from queries',
        parameters: [
          { name: 'query', type: 'string', description: 'Single query to reconcile', optional: false },
          { name: 'queries', type: 'object', description: 'Multiple queries to reconcile', optional: true },
          { name: 'type', type: 'string', description: 'Entity type filter', optional: true },
          { name: 'limit', type: 'number', description: 'Maximum results per query (1-100)', optional: true }
        ]
      },
      {
        path: '/suggest',
        method: 'GET',
        description: 'Get entity suggestions based on prefix',
        parameters: [
          { name: 'prefix', type: 'string', description: 'Prefix to search for', optional: false },
          { name: 'type', type: 'string', description: 'Entity type filter', optional: true },
          { name: 'limit', type: 'number', description: 'Maximum suggestions (1-50)', optional: true }
        ]
      },
      {
        path: '/preview',
        method: 'GET',
        description: 'Get detailed preview for an entity',
        parameters: [
          { name: 'id', type: 'string', description: 'Entity identifier', optional: false }
        ]
      },
      {
        path: '/properties',
        method: 'GET',
        description: 'Get available properties for data extension',
        parameters: []
      },
      {
        path: '/extend',
        method: 'POST',
        description: 'Extend entity data with additional properties',
        parameters: [
          { name: 'ids', type: 'array', description: 'Entity identifiers to extend', optional: false },
          { name: 'properties', type: 'array', description: 'Properties to include', optional: true }
        ]
      },
      {
        path: '/health',
        method: 'GET',
        description: 'Service health check',
        parameters: []
      }
    ],
    examples: {
      curl: {
        reconcile: 'curl -X POST -H "Content-Type: application/json" -d \'{"query":"Albert Einstein"}\' https://yoursite.netlify.app/reconcile',
        suggest: 'curl "https://yoursite.netlify.app/suggest?prefix=Alb&type=person"',
        preview: 'curl "https://yoursite.netlify.app/preview?id=Q937"'
      }
    }
  });
});

// Health check endpoint
app.get('/.netlify/functions/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    version: '2.1.0',
    environment: process.env.NODE_ENV || 'development',
    gemini: geminiInitialized ? 'connected' : 'disabled',
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    endpoints: [
      '/reconcile', '/suggest', '/preview', '/properties', '/extend', '/health', '/docs'
    ]
  });
});

// Test endpoint for validation and benchmarking
app.post('/.netlify/functions/api/test', async (req, res) => {
  try {
    const { tests, concurrency = 1 } = req.body;
    
    if (!tests || !Array.isArray(tests)) {
      return res.status(400).json({ 
        error: 'Invalid test format',
        details: 'Please provide an array of test cases' 
      });
    }
    
    const results = [];
    const startTime = Date.now();
    
    // Run tests with specified concurrency
    for (let i = 0; i < tests.length; i += concurrency) {
      const batch = tests.slice(i, i + concurrency);
      const batchResults = await Promise.all(
        batch.map(async (test, index) => {
          const testStart = Date.now();
          let result;
          
          try {
            // Simulate API call based on test type
            if (test.type === 'reconcile') {
              result = await reconcileQuery(test.query, test.entityType, test.limit || 5);
            } else if (test.type === 'suggest') {
              result = enhancedSuggestion(test.prefix, test.entityType, test.limit || 10);
            }
            
            return {
              testId: test.id || `test-${i + index + 1}`,
              type: test.type,
              input: test.query || test.prefix,
              status: 'success',
              results: result.length,
              duration: Date.now() - testStart,
              data: result
            };
          } catch (error) {
            return {
              testId: test.id || `test-${i + index + 1}`,
              type: test.type,
              input: test.query || test.prefix,
              status: 'error',
              error: error.message,
              duration: Date.now() - testStart
            };
          }
        })
      );
      
      results.push(...batchResults);
    }
    
    const totalDuration = Date.now() - startTime;
    
    res.json({
      results,
      summary: {
        total: results.length,
        successful: results.filter(r => r.status === 'success').length,
        failed: results.filter(r => r.status === 'error').length,
        totalDuration,
        averageDuration: totalDuration / results.length,
        concurrency
      },
      meta: {
        service: 'universal-reconciliation',
        timestamp: new Date().toISOString(),
        engine: geminiInitialized ? 'gemini-ai' : 'basic-matching'
      }
    });
  } catch (error) {
    logger.error('Test endpoint error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      requestId: req.id 
    });
  }
});

// Error handling middleware
app.use((error, req, res, next) => {
  logger.error('Server error:', error);
  res.status(500).json({ 
    error: 'Internal server error',
    requestId: req.id,
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ 
    error: 'Endpoint not found',
    availableEndpoints: [
      '/reconcile', '/suggest', '/preview', '/properties', '/extend', '/health', '/docs', '/test'
    ],
    timestamp: new Date().toISOString()
  });
});

module.exports.handler = serverless(app);

// Create standalone server for local testing
if (require.main === module) {
  const port = process.env.PORT || 8888;
  app.listen(port, () => {
    console.log(`Universal Reconciliation Service running on http://localhost:${port}`);
    console.log(`API endpoints available at http://localhost:${port}/.netlify/functions/api`);
    console.log(`Health check at http://localhost:${port}/health`);
    console.log(`Documentation at http://localhost:${port}/docs`);
  });
}
'@ | Set-Content -Path "netlify/functions/api.js"

# Create comprehensive test datasets
Write-Host "📊 Creating comprehensive test datasets..." -ForegroundColor Yellow

# Sample people data
@'
[
  {
    "id": "Q937",
    "name": "Albert Einstein",
    "type": ["person", "scientist", "physicist"],
    "description": "Theoretical physicist who developed the theory of relativity",
    "birthDate": "1879-03-14",
    "deathDate": "1955-04-18",
    "occupation": "Physicist",
    "knownFor": "Theory of relativity, E=mc²",
    "nationality": "German"
  },
  {
    "id": "Q7186",
    "name": "Marie Curie",
    "type": ["person", "scientist", "chemist", "physicist"],
    "description": "Pioneering researcher on radioactivity",
    "birthDate": "1867-11-07",
    "deathDate": "1934-07-04",
    "occupation": "Physicist, Chemist",
    "knownFor": "Radioactivity, discovery of polonium and radium",
    "nationality": "Polish"
  },
  {
    "id": "Q935",
    "name": "Isaac Newton",
    "type": ["person", "scientist", "mathematician", "physicist"],
    "description": "Mathematician, physicist, and astronomer",
    "birthDate": "1643-01-04",
    "deathDate": "1727-03-31",
    "occupation": "Mathematician, Physicist",
    "knownFor": "Laws of motion, Universal gravitation, Calculus",
    "nationality": "English"
  },
  {
    "id": "Q42",
    "name": "Douglas Adams",
    "type": ["person", "author", "writer"],
    "description": "English author, humorist, and screenwriter",
    "birthDate": "1952-03-11",
    "deathDate": "2001-05-11",
    "occupation": "Writer",
    "knownFor": "The Hitchhiker's Guide to the Galaxy",
    "nationality": "British"
  },
  {
    "id": "Q80",
    "name": "Steve Jobs",
    "type": ["person", "entrepreneur", "business"],
    "description": "Co-founder of Apple Inc.",
    "birthDate": "1955-02-24",
    "deathDate": "2011-10-05",
    "occupation": "Entrepreneur",
    "knownFor": "Apple, iPhone, iPad, Macintosh",
    "nationality": "American"
  }
]
'@ | Set-Content -Path "data/sample-people.json"

# Sample organizations data
@'
[
  {
    "id": "Q95",
    "name": "Google",
    "type": ["organization", "company", "technology"],
    "description": "Multinational technology company specializing in Internet-related services",
    "founded": "1998-09-04",
    "founders": ["Larry Page", "Sergey Brin"],
    "headquarters": "Mountain View, California, United States",
    "employees": 156500,
    "industry": "Technology"
  },
  {
    "id": "Q2283",
    "name": "Apple Inc.",
    "type": ["organization", "company", "technology"],
    "description": "Multinational technology company that designs, develops, and sells consumer electronics",
    "founded": "1976-04-01",
    "founders": ["Steve Jobs", "Steve Wozniak", "Ronald Wayne"],
    "headquarters": "Cupertino, California, United States",
    "employees": 164000,
    "industry": "Technology"
  },
  {
    "id": "Q37121",
    "name": "Microsoft",
    "type": ["organization", "company", "technology"],
    "description": "Multinational technology corporation producing computer software",
    "founded": "1975-04-04",
    "founders": ["Bill Gates", "Paul Allen"],
    "headquarters": "Redmond, Washington, United States",
    "employees": 221000,
    "industry": "Technology"
  },
  {
    "id": "Q3884",
    "name": "Amazon",
    "type": ["organization", "company", "technology", "ecommerce"],
    "description": "Multinational technology company focusing on e-commerce, cloud computing, and AI",
    "founded": "1994-07-05",
    "founders": ["Jeff Bezos"],
    "headquarters": "Seattle, Washington, United States",
    "employees": 1541000,
    "industry": "Technology, E-commerce"
  }
]
'@ | Set-Content -Path "data/sample-organizations.json"

# Sample locations data
@'
[
  {
    "id": "Q60",
    "name": "New York City",
    "type": ["location", "city"],
    "description": "Largest city in the United States",
    "population": 8336817,
    "area": 783.8,
    "country": "United States",
    "continent": "North America",
    "timezone": "UTC-5",
    "mayor": "Eric Adams"
  },
  {
    "id": "Q84",
    "name": "London",
    "type": ["location", "city"],
    "description": "Capital and largest city of England and the United Kingdom",
    "population": 8982000,
    "area": 1572,
    "country": "United Kingdom",
    "continent": "Europe",
    "timezone": "UTC+0",
    "mayor": "Sadiq Khan"
  },
  {
    "id": "Q90",
    "name": "Paris",
    "type": ["location", "city"],
    "description": "Capital and most populous city of France",
    "population": 2140526,
    "area": 105.4,
    "country": "France",
    "continent": "Europe",
    "timezone": "UTC+1",
    "mayor": "Anne Hidalgo"
  },
  {
    "id": "Q148",
    "name": "China",
    "type": ["location", "country"],
    "description": "Country in East Asia",
    "population": 1402112000,
    "area": 9596961,
    "capital": "Beijing",
    "continent": "Asia",
    "language": "Chinese"
  }
]
'@ | Set-Content -Path "data/sample-locations.json"

# Sample books data
@'
[
  {
    "id": "B001",
    "name": "The Hitchhiker's Guide to the Galaxy",
    "type": ["book", "fiction", "science fiction"],
    "description": "Comic science fiction series by Douglas Adams",
    "author": "Douglas Adams",
    "published": "1979-10-12",
    "publisher": "Pan Books",
    "pages": 180,
    "genre": "Science Fiction, Comedy"
  },
  {
    "id": "B002",
    "name": "1984",
    "type": ["book", "fiction", "dystopian"],
    "description": "Dystopian social science fiction novel by George Orwell",
    "author": "George Orwell",
    "published": "1949-06-08",
    "publisher": "Secker & Warburg",
    "pages": 328,
    "genre": "Dystopian, Political Fiction"
  },
  {
    "id": "B003",
    "name": "To Kill a Mockingbird",
    "type": ["book", "fiction", "classic"],
    "description": "Novel by Harper Lee published in 1960",
    "author": "Harper Lee",
    "published": "1960-07-11",
    "publisher": "J. B. Lippincott & Co.",
    "pages": 281,
    "genre": "Southern Gothic, Bildungsroman"
  },
  {
    "id": "B004",
    "name": "The Great Gatsby",
    "type": ["book", "fiction", "classic"],
    "description": "1925 novel by American writer F. Scott Fitzgerald",
    "author": "F. Scott Fitzgerald",
    "published": "1925-04-10",
    "publisher": "Charles Scribner's Sons",
    "pages": 180,
    "genre": "Tragedy, Jazz Age"
  }
]
'@ | Set-Content -Path "data/sample-books.json"

# Create test data for validation
Write-Host "📝 Creating test validation datasets..." -ForegroundColor Yellow

# Test cases for validation
@'
[
  {
    "id": "test-1",
    "type": "reconcile",
    "query": "Albert Einstein",
    "entityType": "person",
    "limit": 5,
    "expectedMinResults": 1,
    "expectedMaxResults": 5,
    "expectedScore": 0.9
  },
  {
    "id": "test-2",
    "type": "reconcile",
    "query": "Steve Jobs",
    "entityType": "person",
    "limit": 3,
    "expectedMinResults": 1,
    "expectedMaxResults": 3,
    "expectedScore": 0.9
  },
  {
    "id": "test-3",
    "type": "reconcile",
    "query": "Google",
    "entityType": "organization",
    "limit": 5,
    "expectedMinResults": 1,
    "expectedMaxResults": 5,
    "expectedScore": 0.9
  },
  {
    "id": "test-4",
    "type": "suggest",
    "prefix": "Alb",
    "entityType": "person",
    "limit": 10,
    "expectedMinResults": 1,
    "expectedMaxResults": 10
  },
  {
    "id": "test-5",
    "type": "suggest",
    "prefix": "New",
    "entityType": "location",
    "limit": 5,
    "expectedMinResults": 1,
    "expectedMaxResults": 5
  },
  {
    "id": "test-6",
    "type": "preview",
    "id": "Q937",
    "expectedName": "Albert Einstein",
    "expectedDescription": "Theoretical physicist"
  },
  {
    "id": "test-7",
    "type": "preview",
    "id": "Q95",
    "expectedName": "Google",
    "expectedDescription": "Multinational technology company"
  }
]
'@ | Set-Content -Path "test-data/validation-tests.json"

# Performance test data
@'
[
  {
    "id": "perf-1",
    "type": "reconcile",
    "query": "Einstein",
    "entityType": "person"
  },
  {
    "id": "perf-2",
    "type": "reconcile",
    "query": "Apple",
    "entityType": "organization"
  },
  {
    "id": "perf-3",
    "type": "reconcile",
    "query": "York",
    "entityType": "location"
  },
  {
    "id": "perf-4",
    "type": "reconcile",
    "query": "Guide",
    "entityType": "book"
  },
  {
    "id": "perf-5",
    "type": "suggest",
    "prefix": "A",
    "entityType": "person"
  },
  {
    "id": "perf-6",
    "type": "suggest",
    "prefix": "G",
    "entityType": "organization"
  },
  {
    "id": "perf-7",
    "type": "suggest",
    "prefix": "N",
    "entityType": "location"
  },
  {
    "id": "perf-8",
    "type": "suggest",
    "prefix": "T",
    "entityType": "book"
  }
]
'@ | Set-Content -Path "test-data/performance-tests.json"

# Create unit tests
Write-Host "🧪 Creating comprehensive test suite..." -ForegroundColor Yellow

# Unit tests for utility functions
@'
const { enhancedReconciliation, enhancedSuggestion, generatePreviewHtml } = require('../../netlify/functions/api');

describe('Utility Functions', () => {
  describe('enhancedReconciliation', () => {
    test('should return matches for person query', () => {
      const results = enhancedReconciliation('Albert Einstein', 'person', 5);
      expect(results).toBeInstanceOf(Array);
      expect(results.length).toBeGreaterThan(0);
      expect(results[0]).toHaveProperty('id');
      expect(results[0]).toHaveProperty('name');
      expect(results[0]).toHaveProperty('score');
    });

    test('should return matches for organization query', () => {
      const results = enhancedReconciliation('Google', 'organization', 5);
      expect(results).toBeInstanceOf(Array);
      expect(results.length).toBeGreaterThan(0);
      expect(results[0].name).toContain('Google');
    });

    test('should respect limit parameter', () => {
      const results = enhancedReconciliation('a', 'person', 2);
      expect(results.length).toBeLessThanOrEqual(2);
    });

    test('should return empty array for no matches', () => {
      const results = enhancedReconciliation('Nonexistent Entity', 'person', 5);
      expect(results).toBeInstanceOf(Array);
      expect(results.length).toBe(0);
    });
  });

  describe('enhancedSuggestion', () => {
    test('should return suggestions for prefix', () => {
      const results = enhancedSuggestion('Alb', 'person', 5);
      expect(results).toBeInstanceOf(Array);
      expect(results.length).toBeGreaterThan(0);
      expect(results[0].name.toLowerCase()).toContain('alb');
    });

    test('should respect limit parameter', () => {
      const results = enhancedSuggestion('A', 'person', 3);
      expect(results.length).toBeLessThanOrEqual(3);
    });
  });

  describe('generatePreviewHtml', () => {
    test('should generate HTML for preview', () => {
      const preview = {
        id: 'test-1',
        name: 'Test Entity',
        description: 'Test Description',
        details: {
          key1: 'value1',
          key2: 'value2'
        }
      };
      
      const html = generatePreviewHtml(preview);
      expect(html).toContain('Test Entity');
      expect(html).toContain('Test Description');
      expect(html).toContain('key1');
      expect(html).toContain('value1');
    });

    test('should handle preview without details', () => {
      const preview = {
        id: 'test-2',
        name: 'Test Entity',
        description: 'Test Description'
      };
      
      const html = generatePreviewHtml(preview);
      expect(html).toContain('Test Entity');
      expect(html).toContain('Test Description');
    });
  });
});
'@ | Set-Content -Path "tests/unit/utils.test.js"

# Integration tests
@'
const request = require('supertest');
const app = require('../../netlify/functions/api');

describe('API Integration Tests', () => {
  test('GET / should return service metadata', async () => {
    const response = await request(app).get('/.netlify/functions/api');
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('name');
    expect(response.body).toHaveProperty('defaultTypes');
    expect(response.body.defaultTypes).toBeInstanceOf(Array);
  });

  test('POST /reconcile should handle single query', async () => {
    const response = await request(app)
      .post('/.netlify/functions/api/reconcile')
      .send({ query: 'Albert Einstein', type: 'person', limit: 3 });
    
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('result');
    expect(response.body.result).toBeInstanceOf(Array);
    expect(response.body.result.length).toBeGreaterThan(0);
  });

  test('POST /reconcile should handle multiple queries', async () => {
    const response = await request(app)
      .post('/.netlify/functions/api/reconcile')
      .send({
        queries: {
          q1: { query: 'Albert Einstein', type: 'person' },
          q2: { query: 'Google', type: 'organization' }
        }
      });
    
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('q1');
    expect(response.body).toHaveProperty('q2');
    expect(response.body.q1).toHaveProperty('result');
    expect(response.body.q2).toHaveProperty('result');
  });

  test('GET /suggest should return suggestions', async () => {
    const response = await request(app)
      .get('/.netlify/functions/api/suggest?prefix=Alb&type=person&limit=5');
    
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('result');
    expect(response.body.result).toBeInstanceOf(Array);
  });

  test('GET /preview should return entity preview', async () => {
    const response = await request(app)
      .get('/.netlify/functions/api/preview?id=Q937');
    
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('name');
    expect(response.body).toHaveProperty('description');
    expect(response.body).toHaveProperty('html');
  });

  test('GET /health should return service status', async () => {
    const response = await request(app)
      .get('/.netlify/functions/api/health');
    
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('status', 'OK');
    expect(response.body).toHaveProperty('timestamp');
  });

  test('should return 404 for unknown endpoint', async () => {
    const response = await request(app)
      .get('/.netlify/functions/api/unknown');
    
    expect(response.status).toBe(404);
    expect(response.body).toHaveProperty('error');
  });
});
'@ | Set-Content -Path "tests/integration/api.test.js"

# Create performance test runner
@'
const axios = require('axios');
const { performance } = require('perf_hooks');
const fs = require('fs');
const path = require('path');

class PerformanceTestRunner {
  constructor(baseURL, concurrency = 1) {
    this.baseURL = baseURL;
    this.concurrency = concurrency;
    this.results = [];
  }

  async runTest(testCase) {
    const startTime = performance.now();
    let success = false;
    let error = null;
    let responseData = null;

    try {
      let url, method, data;

      if (testCase.type === 'reconcile') {
        url = `${this.baseURL}/reconcile`;
        method = 'post';
        data = {
          query: testCase.query,
          type: testCase.entityType,
          limit: testCase.limit || 5
        };
      } else if (testCase.type === 'suggest') {
        url = `${this.baseURL}/suggest?prefix=${testCase.prefix}`;
        if (testCase.entityType) url += `&type=${testCase.entityType}`;
        if (testCase.limit) url += `&limit=${testCase.limit}`;
        method = 'get';
        data = {};
      }

      const response = await axios[method](url, data);
      success = true;
      responseData = response.data;
    } catch (err) {
      error = err.message;
    }

    const duration = performance.now() - startTime;

    return {
      testId: testCase.id,
      type: testCase.type,
      input: testCase.query || testCase.prefix,
      success,
      error,
      duration,
      timestamp: new Date().toISOString(),
      data: responseData
    };
  }

  async runTests(testCases) {
    console.log(`Running ${testCases.length} tests with concurrency ${this.concurrency}...`);

    const results = [];
    for (let i = 0; i < testCases.length; i += this.concurrency) {
      const batch = testCases.slice(i, i + this.concurrency);
      const batchResults = await Promise.all(batch.map(testCase => this.runTest(testCase)));
      results.push(...batchResults);

      // Progress reporting
      console.log(`Completed ${Math.min(i + this.concurrency, testCases.length)}/${testCases.length} tests`);
    }

    this.results = results;
    return results;
  }

  generateReport() {
    const successfulTests = this.results.filter(r => r.success);
    const failedTests = this.results.filter(r => !r.success);
    
    const totalDuration = this.results.reduce((sum, r) => sum + r.duration, 0);
    const avgDuration = totalDuration / this.results.length;
    
    const byType = {};
    this.results.forEach(result => {
      if (!byType[result.type]) {
        byType[result.type] = { count: 0, totalDuration: 0, successes: 0 };
      }
      byType[result.type].count++;
      byType[result.type].totalDuration += result.duration;
      if (result.success) byType[result.type].successes++;
    });

    const report = {
      summary: {
        totalTests: this.results.length,
        successfulTests: successfulTests.length,
        failedTests: failedTests.length,
        successRate: (successfulTests.length / this.results.length) * 100,
        totalDuration,
        averageDuration: avgDuration,
        concurrency: this.concurrency
      },
      byType: Object.keys(byType).reduce((acc, type) => {
        acc[type] = {
          count: byType[type].count,
          successes: byType[type].successes,
          successRate: (byType[type].successes / byType[type].count) * 100,
          averageDuration: byType[type].totalDuration / byType[type].count
        };
        return acc;
      }, {}),
      details: this.results
    };

    // Save report to file
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const reportPath = path.join(__dirname, '../analysis/reports', `performance-report-${timestamp}.json`);
    
    fs.mkdirSync(path.dirname(reportPath), { recursive: true });
    fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
    
    console.log(`Performance report saved to: ${reportPath}`);
    return report;
  }
}

// Run performance tests if executed directly
if (require.main === module) {
  const baseURL = process.env.TEST_BASE_URL || 'http://localhost:8888/.netlify/functions/api';
  const concurrency = parseInt(process.env.TEST_CONCURRENCY) || 5;
  
  const testCases = require('../test-data/performance-tests.json');
  const runner = new PerformanceTestRunner(baseURL, concurrency);
  
  runner.runTests(testCases)
    .then(() => {
      const report = runner.generateReport();
      console.log('\n=== PERFORMANCE TEST SUMMARY ===');
      console.log(`Total Tests: ${report.summary.totalTests}`);
      console.log(`Successful: ${report.summary.successfulTests}`);
      console.log(`Failed: ${report.summary.failedTests}`);
      console.log(`Success Rate: ${report.summary.successRate.toFixed(2)}%`);
      console.log(`Total Duration: ${report.summary.totalDuration.toFixed(2)}ms`);
      console.log(`Average Duration: ${report.summary.averageDuration.toFixed(2)}ms`);
      
      process.exit(report.summary.failedTests > 0 ? 1 : 0);
    })
    .catch(error => {
      console.error('Performance test failed:', error);
      process.exit(1);
    });
}

module.exports = PerformanceTestRunner;
'@ | Set-Content -Path "tests/performance/runner.js"

# Create Artillery load test configuration
@'
config:
  target: "http://localhost:8888"
  phases:
    - duration: 60
      arrivalRate: 5
      name: "Warm up phase"
    - duration: 120
      arrivalRate: 10
      name: "Sustained load phase"
    - duration: 60
      arrivalRate: 20
      name: "Stress test phase"
  payload:
    path: "../test-data/performance-tests.json"
    fields:
      - "id"
      - "type"
      - "query"
      - "prefix"
      - "entityType"
      - "limit"

scenarios:
  - name: "Reconciliation API Test"
    flow:
      - function: "getRandomTestData"
      - log: "Testing {{ $testData.type }} with {{ $testData.query || $testData.prefix }}"
      - if:
          condition: "{{ $testData.type === 'reconcile' }}"
          then:
            - post:
                url: "/.netlify/functions/api/reconcile"
                json:
                  query: "{{ $testData.query }}"
                  type: "{{ $testData.entityType }}"
                  limit: "{{ $testData.limit || 5 }}"
      - if:
          condition: "{{ $testData.type === 'suggest' }}"
          then:
            - get:
                url: "/.netlify/functions/api/suggest?prefix={{ $testData.prefix }}&type={{ $testData.entityType }}&limit={{ $testData.limit || 10 }}"

processor: "./load-test-processor.js"
'@ | Set-Content -Path "tests/performance/load-test.yml"


# Create load test processor
@'
module.exports = {
  getRandomTestData: (userContext, events, done) => {
    const testData = userContext.vars.payload;
    const randomIndex = Math.floor(Math.random() * testData.length);
    userContext.vars.testData = testData[randomIndex];
    return done();
  }
};
'@ | Set-Content -Path "tests/performance/load-test-processor.js"

# Create Postman collection generator
Write-Host "📋 Creating Postman collection generator..." -ForegroundColor Yellow
@'
const fs = require('fs');
const path = require('path');

// Generate Postman collection for API testing
function generatePostmanCollection(baseUrl) {
  const collection = {
    info: {
      name: 'Universal Reconciliation Service API',
      description: 'Comprehensive API tests for Universal Reconciliation Service',
      schema: 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json'
    },
    item: [
      {
        name: 'Service Metadata',
        request: {
          method: 'GET',
          header: [],
          url: {
            raw: '{{baseUrl}}/',
            host: ['{{baseUrl}}'],
            path: ['']
          },
          description: 'Get service metadata and capabilities'
        }
      },
      {
        name: 'Health Check',
        request: {
          method: 'GET',
          header: [],
          url: {
            raw: '{{baseUrl}}/health',
            host: ['{{baseUrl}}'],
            path: ['health']
          },
          description: 'Check service health status'
        }
      },
      {
        name: 'Single Query Reconciliation',
        request: {
          method: 'POST',
          header: [
            {
              key: 'Content-Type',
              value: 'application/json'
            }
          ],
          body: {
            mode: 'raw',
            raw: JSON.stringify({
              query: 'Albert Einstein',
              type: 'person',
              limit: 5
            }, null, 2)
          },
          url: {
            raw: '{{baseUrl}}/reconcile',
            host: ['{{baseUrl}}'],
            path: ['reconcile']
          },
          description: 'Reconcile a single entity query'
        }
      },
      {
        name: 'Batch Query Reconciliation',
        request: {
          method: 'POST',
          header: [
            {
              key: 'Content-Type',
              value: 'application/json'
            }
          ],
          body: {
            mode: 'raw',
            raw: JSON.stringify({
              queries: {
                q1: { query: 'Albert Einstein', type: 'person', limit: 3 },
                q2: { query: 'Google', type: 'organization', limit: 3 },
                q3: { query: 'New York', type: 'location', limit: 3 }
              }
            }, null, 2)
          },
          url: {
            raw: '{{baseUrl}}/reconcile',
            host: ['{{baseUrl}}'],
            path: ['reconcile']
          },
          description: 'Reconcile multiple entity queries in batch'
        }
      },
      {
        name: 'Entity Suggestions',
        request: {
          method: 'GET',
          header: [],
          url: {
            raw: '{{baseUrl}}/suggest?prefix=Alb&type=person&limit=10',
            host: ['{{baseUrl}}'],
            path: ['suggest'],
            query: [
              { key: 'prefix', value: 'Alb' },
              { key: 'type', value: 'person' },
              { key: 'limit', value: '10' }
            ]
          },
          description: 'Get entity suggestions based on prefix'
        }
      },
      {
        name: 'Entity Preview',
        request: {
          method: 'GET',
          header: [],
          url: {
            raw: '{{baseUrl}}/preview?id=Q937',
            host: ['{{baseUrl}}'],
            path: ['preview'],
            query: [
              { key: 'id', value: 'Q937' }
            ]
          },
          description: 'Get detailed preview for an entity'
        }
      },
      {
        name: 'Available Properties',
        request: {
          method: 'GET',
          header: [],
          url: {
            raw: '{{baseUrl}}/properties',
            host: ['{{baseUrl}}'],
            path: ['properties']
          },
          description: 'Get available properties for data extension'
        }
      },
      {
        name: 'Data Extension',
        request: {
          method: 'POST',
          header: [
            {
              key: 'Content-Type',
              value: 'application/json'
            }
          ],
          body: {
            mode: 'raw',
            raw: JSON.stringify({
              ids: ['Q937', 'Q95'],
              properties: ['description', 'birthDate', 'occupation']
            }, null, 2)
          },
          url: {
            raw: '{{baseUrl}}/extend',
            host: ['{{baseUrl}}'],
            path: ['extend']
          },
          description: 'Extend entity data with additional properties'
        }
      },
      {
        name: 'Documentation',
        request: {
          method: 'GET',
          header: [],
          url: {
            raw: '{{baseUrl}}/docs',
            host: ['{{baseUrl}}'],
            path: ['docs']
          },
          description: 'Get API documentation'
        }
      },
      {
        name: 'Performance Testing',
        request: {
          method: 'POST',
          header: [
            {
              key: 'Content-Type',
              value: 'application/json'
            }
          ],
          body: {
            mode: 'raw',
            raw: JSON.stringify({
              tests: [
                { type: 'reconcile', query: 'Albert Einstein', entityType: 'person' },
                { type: 'reconcile', query: 'Google', entityType: 'organization' },
                { type: 'suggest', prefix: 'A', entityType: 'person' }
              ],
              concurrency: 3
            }, null, 2)
          },
          url: {
            raw: '{{baseUrl}}/test',
            host: ['{{baseUrl}}'],
            path: ['test']
          },
          description: 'Run performance tests'
        }
      }
    ],
    variable: [
      {
        key: 'baseUrl',
        value: baseUrl,
        type: 'string'
      }
    ],
    event: [
      {
        listen: 'prerequest',
        script: {
          exec: [
            'console.log(`Running test: {{request.name}}`);'
          ],
          type: 'text/javascript'
        }
      },
      {
        listen: 'test',
        script: {
          exec: [
            'pm.test("Status code is 200", function () {',
            '    pm.response.to.have.status(200);',
            '});',
            '',
            'pm.test("Response time is less than 2000ms", function () {',
            '    pm.expect(pm.response.responseTime).to.be.below(2000);',
            '});',
            '',
            'pm.test("Response has valid JSON", function () {',
            '    pm.response.to.be.json;',
            '});'
          ],
          type: 'text/javascript'
        }
      }
    ]
  };

  return collection;
}

// Save Postman collection to file
function savePostmanCollection(collection, filename) {
  const dir = path.join(__dirname, '../postman');
  fs.mkdirSync(dir, { recursive: true });
  
  const filepath = path.join(dir, filename);
  fs.writeFileSync(filepath, JSON.stringify(collection, null, 2));
  console.log(`Postman collection saved to: ${filepath}`);
}

// Generate collections for different environments
if (require.main === module) {
  // Local development
  const localCollection = generatePostmanCollection('http://localhost:8888/.netlify/functions/api');
  savePostmanCollection(localCollection, 'universal-reconciliation-local.postman_collection.json');
  
  // Production
  const productionCollection = generatePostmanCollection('https://your-site.netlify.app/.netlify/functions/api');
  savePostmanCollection(productionCollection, 'universal-reconciliation-production.postman_collection.json');
  
  console.log('Postman collections generated successfully!');
}

module.exports = { generatePostmanCollection, savePostmanCollection };
'@ | Set-Content -Path "scripts/export-postman-collection.js"

# Create curl command examples
Write-Host "🔧 Creating curl command examples..." -ForegroundColor Yellow
@'
# Universal Reconciliation Service - cURL Examples
# ===============================================

# Base URL (replace with your actual URL)
BASE_URL="http://localhost:8888/.netlify/functions/api"
# BASE_URL="https://your-site.netlify.app/.netlify/functions/api"

echo "Testing Universal Reconciliation Service API with cURL"

# 1. Service Metadata
echo -e "\n1. Getting service metadata:"
curl -X GET "$BASE_URL/"

# 2. Health Check
echo -e "\n2. Health check:"
curl -X GET "$BASE_URL/health"

# 3. Single Query Reconciliation
echo -e "\n3. Single query reconciliation:"
curl -X POST "$BASE_URL/reconcile" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Albert Einstein",
    "type": "person",
    "limit": 5
  }'

# 4. Batch Query Reconciliation
echo -e "\n4. Batch query reconciliation:"
curl -X POST "$BASE_URL/reconcile" \
  -H "Content-Type: application/json" \
  -d '{
    "queries": {
      "q1": { "query": "Albert Einstein", "type": "person", "limit": 3 },
      "q2": { "query": "Google", "type": "organization", "limit": 3 },
      "q3": { "query": "New York", "type": "location", "limit": 3 }
    }
  }'

# 5. Entity Suggestions
echo -e "\n5. Entity suggestions:"
curl -X GET "$BASE_URL/suggest?prefix=Alb&type=person&limit=10"

# 6. Entity Preview
echo -e "\n6. Entity preview:"
curl -X GET "$BASE_URL/preview?id=Q937"

# 7. Available Properties
echo -e "\n7. Available properties:"
curl -X GET "$BASE_URL/properties"

# 8. Data Extension
echo -e "\n8. Data extension:"
curl -X POST "$BASE_URL/extend" \
  -H "Content-Type: application/json" \
  -d '{
    "ids": ["Q937", "Q95"],
    "properties": ["description", "birthDate", "occupation"]
  }'

# 9. API Documentation
echo -e "\n9. API documentation:"
curl -X GET "$BASE_URL/docs"

# 10. Performance Testing
echo -e "\n10. Performance testing:"
curl -X POST "$BASE_URL/test" \
  -H "Content-Type: application/json" \
  -d '{
    "tests": [
      { "type": "reconcile", "query": "Albert Einstein", "entityType": "person" },
      { "type": "reconcile", "query": "Google", "entityType": "organization" },
      { "type": "suggest", "prefix": "A", "entityType": "person" }
    ],
    "concurrency": 3
  }'

echo -e "\n\nAll tests completed!"
'@ | Set-Content -Path "scripts/test-with-curl.sh"

# Create dataset analysis script
Write-Host "📊 Creating dataset analysis script..." -ForegroundColor Yellow
@'
const fs = require('fs');
const path = require('path');
const { Parser } = require('json2csv');

class DatasetAnalyzer {
  constructor() {
    this.datasets = {};
    this.analysisResults = {};
  }

  loadDatasets() {
    const dataDir = path.join(__dirname, '../data');
    const files = fs.readdirSync(dataDir);
    
    files.forEach(file => {
      if (file.endsWith('.json')) {
        const filePath = path.join(dataDir, file);
        const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
        const datasetName = path.basename(file, '.json');
        this.datasets[datasetName] = data;
      }
    });
  }

  analyzeDatasets() {
    for (const [name, data] of Object.entries(this.datasets)) {
      this.analysisResults[name] = this.analyzeDataset(data, name);
    }
    return this.analysisResults;
  }

  analyzeDataset(dataset, name) {
    if (!Array.isArray(dataset) || dataset.length === 0) {
      return { error: 'Invalid dataset format' };
    }

    const analysis = {
      name,
      totalEntries: dataset.length,
      fields: this.getFieldAnalysis(dataset),
      typeDistribution: this.getTypeDistribution(dataset),
      fieldCompleteness: this.getFieldCompleteness(dataset),
      valueStats: this.getValueStatistics(dataset),
      sampleEntries: dataset.slice(0, 5)
    };

    return analysis;
  }

  getFieldAnalysis(dataset) {
    const allFields = new Set();
    dataset.forEach(item => {
      Object.keys(item).forEach(field => allFields.add(field));
    });
    
    const fieldAnalysis = {};
    Array.from(allFields).forEach(field => {
      const values = dataset.map(item => item[field]).filter(val => val !== undefined);
      fieldAnalysis[field] = {
        count: values.length,
        presence: (values.length / dataset.length) * 100,
        sampleValues: this.getSampleValues(values, 5),
        valueTypes: this.getValueTypes(values)
      };
    });
    
    return fieldAnalysis;
  }

  getTypeDistribution(dataset) {
    const typeCounts = {};
    dataset.forEach(item => {
      if (item.type && Array.isArray(item.type)) {
        item.type.forEach(t => {
          typeCounts[t] = (typeCounts[t] || 0) + 1;
        });
      } else if (item.type && typeof item.type === 'string') {
        typeCounts[item.type] = (typeCounts[item.type] || 0) + 1;
      }
    });
    
    return typeCounts;
  }

  getFieldCompleteness(dataset) {
    const completeness = {};
    const allFields = new Set();
    
    dataset.forEach(item => {
      Object.keys(item).forEach(field => allFields.add(field));
    });
    
    Array.from(allFields).forEach(field => {
      const present = dataset.filter(item => item[field] !== undefined).length;
      completeness[field] = (present / dataset.length) * 100;
    });
    
    return completeness;
  }

  getValueStatistics(values) {
    if (values.length === 0) return {};
    
    const firstValue = values[0];
    
    if (typeof firstValue === 'number') {
      return {
        type: 'number',
        min: Math.min(...values),
        max: Math.max(...values),
        average: values.reduce((a, b) => a + b, 0) / values.length
      };
    } else if (typeof firstValue === 'string') {
      const lengths = values.map(v => v.length);
      return {
        type: 'string',
        minLength: Math.min(...lengths),
        maxLength: Math.max(...lengths),
        avgLength: lengths.reduce((a, b) => a + b, 0) / lengths.length
      };
    } else if (Array.isArray(firstValue)) {
      return {
        type: 'array',
        avgLength: values.map(v => v.length).reduce((a, b) => a + b, 0) / values.length
      };
    }
    
    return { type: typeof firstValue };
  }

  getSampleValues(values, count) {
    return values.slice(0, Math.min(count, values.length));
  }

  getValueTypes(values) {
    const types = {};
    values.forEach(value => {
      const type = Array.isArray(value) ? 'array' : typeof value;
      types[type] = (types[type] || 0) + 1;
    });
    return types;
  }

  generateReports() {
    const reportsDir = path.join(__dirname, '../analysis/reports');
    const datasetsDir = path.join(__dirname, '../analysis/datasets');
    
    fs.mkdirSync(reportsDir, { recursive: true });
    fs.mkdirSync(datasetsDir, { recursive: true });
    
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    
    // Save detailed analysis
    const analysisPath = path.join(reportsDir, `dataset-analysis-${timestamp}.json`);
    fs.writeFileSync(analysisPath, JSON.stringify(this.analysisResults, null, 2));
    
    // Generate CSV summaries
    this.generateCSVReports(datasetsDir, timestamp);
    
    // Generate markdown summary
    this.generateMarkdownSummary(reportsDir, timestamp);
    
    console.log(`Analysis reports generated in: ${reportsDir}`);
    console.log(`Dataset summaries generated in: ${datasetsDir}`);
  }

  generateCSVReports(datasetsDir, timestamp) {
    // Generate CSV for each dataset
    for (const [name, data] of Object.entries(this.datasets)) {
      try {
        const parser = new Parser();
        const csv = parser.parse(data);
        const csvPath = path.join(datasetsDir, `${name}-${timestamp}.csv`);
        fs.writeFileSync(csvPath, csv);
      } catch (error) {
        console.warn(`Could not generate CSV for ${name}:`, error.message);
      }
    }
  }

  generateMarkdownSummary(reportsDir, timestamp) {
    let markdown = `# Dataset Analysis Report\n\n`;
    markdown += `Generated: ${new Date().toISOString()}\n\n`;
    
    for (const [name, analysis] of Object.entries(this.analysisResults)) {
      markdown += `## ${analysis.name}\n\n`;
      markdown += `- **Total Entries**: ${analysis.totalEntries}\n`;
      
      if (analysis.typeDistribution) {
        markdown += `- **Type Distribution**:\n`;
        for (const [type, count] of Object.entries(analysis.typeDistribution)) {
          markdown += `  - ${type}: ${count} (${((count / analysis.totalEntries) * 100).toFixed(1)}%)\n`;
        }
      }
      
      markdown += `\n### Field Completeness\n\n`;
      markdown += `| Field | Presence |\n|-------|----------|\n`;
      for (const [field, completeness] of Object.entries(analysis.fieldCompleteness || {})) {
        markdown += `| ${field} | ${completeness.toFixed(1)}% |\n`;
      }
      
      markdown += `\n### Sample Entries\n\n`;
      markdown += `\`\`\`json\n${JSON.stringify(analysis.sampleEntries, null, 2)}\n\`\`\`\n\n`;
    }
    
    const mdPath = path.join(reportsDir, `dataset-summary-${timestamp}.md`);
    fs.writeFileSync(mdPath, markdown);
  }
}

// Run analysis if executed directly
if (require.main === module) {
  const analyzer = new DatasetAnalyzer();
  analyzer.loadDatasets();
  analyzer.analyzeDatasets();
  analyzer.generateReports();
}

module.exports = DatasetAnalyzer;
'@ | Set-Content -Path "scripts/analyze-datasets.js"

# Create experiment runner for different scenarios
Write-Host "🔬 Creating experiment runner..." -ForegroundColor Yellow
@'
const axios = require('axios');
const { performance } = require('perf_hooks');
const fs = require('fs');
const path = require('path');

class ExperimentRunner {
  constructor(baseURL) {
    this.baseURL = baseURL;
    this.results = [];
  }

  async runExperiment(name, testCases, iterations = 10) {
    console.log(`Running experiment: ${name}`);
    
    const experimentResults = {
      name,
      startTime: new Date().toISOString(),
      iterations: [],
      summary: {}
    };

    for (let i = 0; i < iterations; i++) {
      console.log(`  Iteration ${i + 1}/${iterations}`);
      
      const iterationResults = {
        iteration: i + 1,
        startTime: new Date().toISOString(),
        testResults: []
      };

      for (const testCase of testCases) {
        const result = await this.runTestCase(testCase);
        iterationResults.testResults.push(result);
      }

      iterationResults.endTime = new Date().toISOString();
      iterationResults.duration = new Date(iterationResults.endTime) - new Date(iterationResults.startTime);
      
      experimentResults.iterations.push(iterationResults);
    }

    experimentResults.endTime = new Date().toISOString();
    experimentResults.totalDuration = new Date(experimentResults.endTime) - new Date(experimentResults.startTime);
    
    // Calculate summary statistics
    experimentResults.summary = this.calculateSummary(experimentResults);
    
    this.results.push(experimentResults);
    return experimentResults;
  }

  async runTestCase(testCase) {
    const startTime = performance.now();
    let success = false;
    let error = null;
    let responseData = null;

    try {
      let url, method, data;

      if (testCase.type === 'reconcile') {
        url = `${this.baseURL}/reconcile`;
        method = 'post';
        data = {
          query: testCase.query,
          type: testCase.entityType,
          limit: testCase.limit || 5
        };
      } else if (testCase.type === 'suggest') {
        url = `${this.baseURL}/suggest?prefix=${testCase.prefix}`;
        if (testCase.entityType) url += `&type=${testCase.entityType}`;
        if (testCase.limit) url += `&limit=${testCase.limit}`;
        method = 'get';
      }

      const response = await axios[method](url, data);
      success = true;
      responseData = response.data;
    } catch (err) {
      error = err.message;
    }

    const duration = performance.now() - startTime;

    return {
      testId: testCase.id,
      type: testCase.type,
      input: testCase.query || testCase.prefix,
      success,
      error,
      duration,
      timestamp: new Date().toISOString(),
      data: responseData
    };
  }

  calculateSummary(experimentResults) {
    const allDurations = experimentResults.iterations.flatMap(iteration => 
      iteration.testResults.map(test => test.duration)
    );

    const successfulTests = experimentResults.iterations.flatMap(iteration => 
      iteration.testResults.filter(test => test.success)
    );

    const summary = {
      totalTests: allDurations.length,
      successfulTests: successfulTests.length,
      successRate: (successfulTests.length / allDurations.length) * 100,
      minDuration: Math.min(...allDurations),
      maxDuration: Math.max(...allDurations),
      avgDuration: allDurations.reduce((a, b) => a + b, 0) / allDurations.length,
      p95Duration: this.calculatePercentile(allDurations, 95),
      p99Duration: this.calculatePercentile(allDurations, 99)
    };

    return summary;
  }

  calculatePercentile(values, percentile) {
    const sorted = values.sort((a, b) => a - b);
    const index = (percentile / 100) * (sorted.length - 1);
    
    if (Math.floor(index) === index) {
      return sorted[index];
    } else {
      const lower = sorted[Math.floor(index)];
      const upper = sorted[Math.ceil(index)];
      return lower + (upper - lower) * (index - Math.floor(index));
    }
  }

  generateReport() {
    const reportsDir = path.join(__dirname, '../analysis/experiments');
    fs.mkdirSync(reportsDir, { recursive: true });

    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const reportPath = path.join(reportsDir, `experiment-report-${timestamp}.json`);

    const report = {
      generated: new Date().toISOString(),
      baseURL: this.baseURL,
      experiments: this.results
    };

    fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
    console.log(`Experiment report saved to: ${reportPath}`);

    // Generate summary markdown
    this.generateSummaryMarkdown(reportsDir, timestamp);

    return reportPath;
  }

  generateSummaryMarkdown(reportsDir, timestamp) {
    let markdown = `# Experiment Results Summary\n\n`;
    markdown += `Generated: ${new Date().toISOString()}\n`;
    markdown += `Base URL: ${this.baseURL}\n\n`;

    for (const experiment of this.results) {
      markdown += `## ${experiment.name}\n\n`;
      markdown += `- **Duration**: ${experiment.totalDuration}ms\n`;
      markdown += `- **Iterations**: ${experiment.iterations.length}\n`;
      markdown += `- **Total Tests**: ${experiment.summary.totalTests}\n`;
      markdown += `- **Success Rate**: ${experiment.summary.successRate.toFixed(2)}%\n\n`;

      markdown += `### Performance Summary\n\n`;
      markdown += `| Metric | Value (ms) |\n|--------|------------|\n`;
      markdown += `| Average | ${experiment.summary.avgDuration.toFixed(2)} |\n`;
      markdown += `| Minimum | ${experiment.summary.minDuration.toFixed(2)} |\n`;
      markdown += `| Maximum | ${experiment.summary.maxDuration.toFixed(2)} |\n`;
      markdown += `| 95th %ile | ${experiment.summary.p95Duration.toFixed(2)} |\n`;
      markdown += `| 99th %ile | ${experiment.summary.p99Duration.toFixed(2)} |\n\n`;
    }

    const mdPath = path.join(reportsDir, `experiment-summary-${timestamp}.md`);
    fs.writeFileSync(mdPath, markdown);
  }
}

// Define experiment scenarios
const experiments = {
  basic: [
    { id: 'exp-1', type: 'reconcile', query: 'Albert Einstein', entityType: 'person' },
    { id: 'exp-2', type: 'reconcile', query: 'Google', entityType: 'organization' },
    { id: 'exp-3', type: 'suggest', prefix: 'A', entityType: 'person' }
  ],
  stress: [
    { id: 'stress-1', type: 'reconcile', query: 'Einstein', entityType: 'person' },
    { id: 'stress-2', type: 'reconcile', query: 'Apple', entityType: 'organization' },
    { id: 'stress-3', type: 'reconcile', query: 'York', entityType: 'location' },
    { id: 'stress-4', type: 'suggest', prefix: 'G', entityType: 'organization' },
    { id: 'stress-5', type: 'suggest', prefix: 'N', entityType: 'location' }
  ],
  mixed: [
    { id: 'mixed-1', type: 'reconcile', query: 'Albert Einstein', entityType: 'person' },
    { id: 'mixed-2', type: 'suggest', prefix: 'Alb', entityType: 'person' },
    { id: 'mixed-3', type: 'reconcile', query: 'Google', entityType: 'organization' },
    { id: 'mixed-4', type: 'suggest', prefix: 'Goo', entityType: 'organization' },
    { id: 'mixed-5', type: 'reconcile', query: 'New York', entityType: 'location' }
  ]
};

// Run experiments if executed directly
if (require.main === module) {
  const baseURL = process.env.EXPERIMENT_BASE_URL || 'http://localhost:8888/.netlify/functions/api';
  const runner = new ExperimentRunner(baseURL);

  async function runAllExperiments() {
    console.log('Starting experiments...\n');
    
    await runner.runExperiment('Basic Functionality', experiments.basic, 5);
    await runner.runExperiment('Stress Test', experiments.stress, 8);
    await runner.runExperiment('Mixed Workload', experiments.mixed, 6);
    
    const reportPath = runner.generateReport();
    console.log(`\nAll experiments completed! Report saved to: ${reportPath}`);
  }

  runAllExperiments().catch(console.error);
}

module.exports = { ExperimentRunner, experiments };
'@ | Set-Content -Path "scripts/run-experiments.js"

# Create environment configuration
Write-Host "🔧 Creating environment configuration..." -ForegroundColor Yellow
@'
# Environment Configuration
NODE_ENV=development
GEMINI_API_KEY=your_gemini_api_key_here
PORT=8888
LOG_LEVEL=info

# Rate limiting (higher values for testing)
RATE_LIMIT_MAX=1000
RATE_LIMIT_WINDOW=60

# Testing configurations
TEST_BASE_URL=http://localhost:8888/.netlify/functions/api
TEST_CONCURRENCY=5
EXPERIMENT_BASE_URL=http://localhost:8888/.netlify/functions/api

# Monitoring (optional)
SENTRY_DSN=your_sentry_dsn_here
LOGGLY_TOKEN=your_loggly_token_here
'@ | Set-Content -Path ".env.example"

@'
# Local development environment
NODE_ENV=development
GEMINI_API_KEY=your_local_gemini_key_here
PORT=8888
LOG_LEVEL=debug
RATE_LIMIT_MAX=1000
RATE_LIMIT_WINDOW=60
TEST_BASE_URL=http://localhost:8888/.netlify/functions/api
TEST_CONCURRENCY=3
EXPERIMENT_BASE_URL=http://localhost:8888/.netlify/functions/api
'@ | Set-Content -Path ".env"

# Create comprehensive documentation
Write-Host "📖 Creating comprehensive documentation..." -ForegroundColor Yellow
@'
# Universal Reconciliation Service - Comprehensive Testing & Deployment

A complete OpenRefine-compatible reconciliation API service with extensive testing capabilities, performance monitoring, and deployment automation.

## Features

- ✅ **Full OpenRefine Reconciliation API** compliance
- 🧪 **Comprehensive testing suite** with unit, integration, and performance tests
- 📊 **Dataset analysis** and validation tools
- 🚀 **Performance monitoring** with detailed metrics and reporting
- 🔧 **Postman collections** for API testing
- 📋 **cURL examples** for command-line testing
- 🔬 **Experiment framework** for different usage scenarios
- 📈 **Automated reporting** with JSON, CSV, and Markdown outputs

## Quick Start

### 1. Installation & Setup

```bash
# Run the setup script
./setup_universal.ps1

# Or on Windows
.\setup_universal.ps1

# Install dependencies
npm install