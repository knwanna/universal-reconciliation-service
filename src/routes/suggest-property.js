const express = require('express');
const router = express.Router();
const { getModelResponse } = require('../utils');
const { v4: uuidv4 } = require('uuid');

// Suggest Property Route
// This endpoint suggests properties based on a query.
router.get('/', async (req, res) => {
  try {
    const query = req.query.prefix;
    const type = req.query.type;
    if (!query) {
      return res.status(400).json({ error: 'Query prefix is required.' });
    }

    let userPrompt;
    if (type) {
      userPrompt = `Suggest 5 properties for a data type named "${type}" that start with "${query}". Provide the suggestions in JSON format, each with a 'name' and 'id'.`;
    } else {
      userPrompt = `Suggest 5 properties that start with "${query}" in JSON format. Each property should have a 'name' and 'id'.`;
    }
    
    const modelResponse = await getModelResponse(userPrompt, true, false);
    const suggestions = JSON.parse(modelResponse.text);

    res.status(200).json({
      result: suggestions.map(s => ({
        id: s.id || uuidv4(),
        name: s.name
      }))
    });
  } catch (error) {
    console.error('Suggest property error:', error);
    res.status(500).json({ error: 'Failed to get property suggestions.' });
  }
});

module.exports = router;
