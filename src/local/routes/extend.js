const express = require('express');
const router = express.Router();
const { getExtendedProperties } = require('../../shared/utils');

router.post('/', async (req, res) => {
  try {
    const { ids, properties } = req.body;
    
    if (!ids || !properties || !Array.isArray(ids) || !Array.isArray(properties)) {
      return res.status(400).json({ error: 'Invalid ids or properties format' });
    }

    const result = await getExtendedProperties(ids, properties);
    res.json(result);
  } catch (error) {
    console.error('Extend error:', error);
    res.status(500).json({ error: 'Failed to extend properties' });
  }
});

module.exports = router;