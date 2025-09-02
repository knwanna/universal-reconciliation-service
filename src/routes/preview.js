const express = require('express');
const router = express.Router();
const { getModelResponse } = require('../utils');

// Preview Route
// This endpoint generates a preview of an entity.
router.get('/', async (req, res) => {
  try {
    const id = req.query.id;
    if (!id) {
      return res.status(400).send('Entity ID is required.');
    }

    const userPrompt = `Generate a short HTML description for an entity with the ID "${id}". Make sure the HTML is well-formed.`;
    const modelResponse = await getModelResponse(userPrompt, true, false);

    const htmlContent = modelResponse.text;

    res.status(200).send(htmlContent);
  } catch (error) {
    console.error('Preview error:', error);
    res.status(500).send('Failed to generate preview.');
  }
});

module.exports = router;