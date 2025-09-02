const express = require('express');
const router = express.Router();
const { getModelResponse } = require('../utils');

// Extend Route
// This endpoint extends data by adding properties to entities.
router.post('/', async (req, res) => {
  try {
    const ids = req.body.ids;
    const properties = req.body.properties;

    if (!ids || !properties || !Array.isArray(ids) || !Array.isArray(properties)) {
      return res.status(400).json({ error: 'Missing or invalid ids or properties.' });
    }

    const data = {};
    for (const id of ids) {
      const userPrompt = `For the entity with ID "${id}", retrieve the values for the following properties: ${properties.map(p => p.id).join(', ')}. Provide the result in a JSON object where keys are the property IDs and values are the corresponding values.`;
      const modelResponse = await getModelResponse(userPrompt, true, false);

      const values = JSON.parse(modelResponse.text);
      data[id] = values;
    }

    res.status(200).json({
      meta: properties.map(p => ({ id: p.id, name: p.name })),
      rows: ids.map(id => ({ id: id, values: properties.map(p => data[id][p.id] ? [{ str: data[id][p.id] }] : []) }))
    });
  } catch (error) {
    console.error('Extend error:', error);
    res.status(500).json({ error: 'Failed to extend data.' });
  }
});

module.exports = router;
