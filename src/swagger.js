const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const baseUrl = process.env.BASE_URL || 'http://localhost:8888';

const options = {
  definition: {
    openapi: '3.0.3',
    info: {
      title: 'Universal Reconciliation Service API',
      version: '1.0.0',
      description: 'API for reconciliation service using Express and Gemini API',
      contact: {
        name: 'Google',
        email: 'support@example.com',
      },
      license: {
        name: 'MIT',
        url: 'https://opensource.org/licenses/MIT',
      },
    },
    servers: [
      {
        url: baseUrl,
        description: 'Base URL of the API',
      },
    ],
  },
  apis: ['./netlify/functions/routes/*.js'],
};

const swaggerSpec = swaggerJsdoc(options);

function setupSwagger(app) {
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
}

module.exports = setupSwagger;
