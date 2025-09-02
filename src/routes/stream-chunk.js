const express = require('express');
const router = express.Router();
const { getModelResponse } = require('../utils');
const path = require('path');
const fs = require('fs');

// Stream Chunk Route
// This endpoint handles real-time stream chunk matching.
router.post('/', async (req, res) => {
  try {
    const { input, fileName } = req.body;
    if (!input || !fileName) {
      return res.status(400).json({ error: 'Input text and file name are required.' });
    }

    const filePath = path.join(__dirname, '..', '..', 'data', fileName);
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ error: 'File not found.' });
    }

    const fileContent = fs.readFileSync(filePath, 'utf-8');
    const userPrompt = `Given the input chunk "${input}" and the following data:\n\n---\n${fileContent}\n---\n\nDetermine the best match from the data for the input chunk. Provide a JSON object with 'match' and 'confidence' (0-100) properties. If no match is found, set 'match' to null.`;
    const modelResponse = await getModelResponse(userPrompt, true, false);

    const result = JSON.parse(modelResponse.text);

    res.status(200).json({
      match: result.match,
      confidence: result.confidence / 100
    });
  } catch (error) {
    console.error('Stream chunk error:', error);
    res.status(500).json({ error: 'Failed to process stream chunk.' });
  }
});

module.exports = router;

