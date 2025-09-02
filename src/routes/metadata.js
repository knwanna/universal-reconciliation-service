/**
 * @swagger
 * /metadata:
 *   get:
 *     summary: Example GET endpoint for metadata
 *     description: Detailed description for the metadata endpoint.
 *     responses:
 *       200:
 *         description: Success response.
 */
// src/routes/metadata.js
const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  const baseUrl = `${req.protocol}://${req.get('host')}`;
  res.json({
    name: 'Universal Reconciliation Service',
    identifierSpace: 'http://example.com/identifiers',
    schemaSpace: 'http://example.com/schemas',
    defaultTypes: [{ id: '/general', name: 'General Entity' }],
    view: { url: 'http://example.com/view/{{id}}' },
    preview: {
      url: `${baseUrl}/preview?id={{id}}`,
      width: 400,
      height: 200,
    },
    suggest: {
      entity: { service_url: baseUrl, service_path: '/suggest/entity' },
      type: { service_url: baseUrl, service_path: '/suggest/type' },
      property: { service_url: baseUrl, service_path: '/suggest/property' },
    },
    extend: {
      propose_properties: { service_url: baseUrl, service_path: '/extend/propose' },
      property_settings: [
        {
          name: 'maxItems',
          label: 'Maximum number of values',
          type: 'number',
          default: 1,
        },
      ],
    },
  });
});

module.exports = router;
