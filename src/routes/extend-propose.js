/**
 * @swagger
 * /extend-propose:
 *   get:
 *     summary: Example GET endpoint for extend-propose
 *     description: Detailed description for the extend-propose endpoint.
 *     responses:
 *       200:
 *         description: Success response.
 */
const express = require('express');
const router = express.Router();
const { getModelResponse } = require('../utils');
const { v4: uuidv4 } = require('uuid');

// Extend Propose Route
// This endpoint proposes properties for data extension.
router.post('/', async (req, res) => {
  try {
    const type = req.body.type;
    const userPrompt = `Propose 5 properties to extend data for the entity type "${type}". Provide the suggestions in JSON format. Each property should have an 'id' and 'name'.`;
    const modelResponse = await getModelResponse(userPrompt, true, false);

    const properties = JSON.parse(modelResponse.text);

    res.status(200).json({
      properties: properties.map(p => ({
        id: p.id || uuidv4(),
        name: p.name
      }))
    });
  } catch (error) {
    console.error('Extend propose error:', error);
    res.status(500).json({ error: 'Failed to propose properties.' });
  }
});

module.exports = router;
