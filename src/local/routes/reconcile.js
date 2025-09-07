const express = require('express');
const router = express.Router();
const { getMatchingResults } = require('../../shared/utils');
const { reconciliationSchema } = require('../../shared/validation');

router.post('/', async (req, res) => {
  try {
    const { error, value } = reconciliationSchema.validate(req.body);
    
    if (error) {
      return res.status(400).json({
        error: 'Invalid input format',
        details: error.details,
        metadata: { validationError: true }
      });
    }

    const { queries } = value;
    const context = {
      sessionId: req.headers['x-session-id'] || req.ip,
      userAgent: req.get('User-Agent'),
      timestamp: new Date().toISOString()
    };

    const results = await getMatchingResults(queries, context);
    
    res.json({
      ...results,
      metadata: {
        apiVersion: '2.1.0',
        processedAt: new Date().toISOString(),
        environment: 'local',
        sessionId: context.sessionId
      }
    });
  } catch (error) {
    console.error('Advanced reconciliation error:', error);
    res.status(500).json({
      error: 'Failed to reconcile entities',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined,
      metadata: { errorType: 'processing_error' }
    });
  }
});

// Batch processing endpoint
router.post('/batch', async (req, res) => {
  try {
    const { queries, batchSize = 10 } = req.body;
    
    if (!Array.isArray(queries)) {
      return res.status(400).json({
        error: 'Queries must be an array',
        metadata: { validationError: true }
      });
    }

    const results = [];
    for (let i = 0; i < queries.length; i += batchSize) {
      const batch = queries.slice(i, i + batchSize);
      const batchResults = await Promise.all(
        batch.map(query => getMatchingResults({ q0: query }, {
          sessionId: req.headers['x-session-id'],
          batchIndex: i
        }))
      );
      results.push(...batchResults);
    }

    res.json({
      results,
      metadata: {
        totalProcessed: queries.length,
        batchSize,
        processedAt: new Date().toISOString()
      }
    });
  } catch (error) {
    res.status(500).json({
      error: 'Batch processing failed',
      metadata: { errorType: 'batch_error' }
    });
  }
});

module.exports = router;