const express = require('express');
const router = express.Router();
const { getServiceMetadata } = require('../../shared/utils');

router.get('/', (req, res) => {
  try {
    const baseUrl = `${req.protocol}://${req.get('host')}`;
    const metadata = getServiceMetadata(baseUrl);
    res.json(metadata);
  } catch (error) {
    console.error('Metadata error:', error);
    res.status(500).json({ error: 'Failed to get service metadata' });
  }
});

module.exports = router;