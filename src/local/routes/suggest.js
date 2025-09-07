const express = require('express');
const router = express.Router();
const { getSuggestions } = require('../../shared/utils');
const { suggestionSchema } = require('../../shared/validation');

router.get('/', async (req, res) => {
  try {
    const { error, value } = suggestionSchema.validate(req.query);
    
    if (error) {
      return res.status(400).json({
        error: 'Invalid query parameters',
        details: error.details,
        metadata: { validationError: true }
      });
    }

    const { prefix, type = 'entity', limit = 10 } = value;
    const context = {
      sessionId: req.headers['x-session-id'] || req.ip,
      userAgent: req.get('User-Agent'),
      referrer: req.get('Referer')
    };

    const suggestions = await getSuggestions(type, prefix, parseInt(limit), context);
    
    res.json({
      ...suggestions,
      metadata: {
        apiVersion: '2.1.0',
        processedAt: new Date().toISOString(),
        query: { prefix, type, limit },
        environment: 'local'
      }
    });
  } catch (error) {
    console.error('Suggestion error:', error);
    res.status(500).json({
      error: 'Failed to get suggestions',
      metadata: { errorType: 'suggestion_error' }
    });
  }
});

// Flyout suggestions for UI components
router.get('/flyout', async (req, res) => {
  try {
    const { prefix, type = 'entity', limit = 5 } = req.query;
    
    const suggestions = await getSuggestions(type, prefix, parseInt(limit), {
      flyout: true,
      sessionId: req.headers['x-session-id']
    });

    res.json(suggestions);
  } catch (error) {
    res.status(500).json({
      error: 'Flyout suggestions failed',
      metadata: { errorType: 'flyout_error' }
    });
  }
});

module.exports = router;