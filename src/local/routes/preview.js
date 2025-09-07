const express = require('express');
const router = express.Router();
const { getPreviewHTML } = require('../../shared/utils');

router.get('/', async (req, res) => {
  try {
    const { id } = req.query;
    
    if (!id) {
      return res.status(400).json({ error: 'ID parameter is required' });
    }

    const html = await getPreviewHTML(id);
    res.send(html);
  } catch (error) {
    console.error('Preview error:', error);
    res.status(500).send('<p>Error generating preview</p>');
  }
});

module.exports = router;