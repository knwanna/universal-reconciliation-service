const serverless = require('serverless-http');
const app = require('../../src/api');

// Wrapper to export the Express app as a Netlify Function handler
exports.handler = serverless(app);