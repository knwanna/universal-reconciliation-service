const request = require('supertest');
const app = require('../netlify/functions/api');

describe('Reconciliation Service API', () => {
  test('GET /health should return status OK', async () => {
    const response = await request(app).get('/.netlify/functions/api/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('OK');
  });

  test('GET /metadata should return service info', async () => {
    const response = await request(app).get('/.netlify/functions/api');
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('name');
    expect(response.body).toHaveProperty('identifierSpace');
  });

  test('POST /reconcile should validate input', async () => {
    const response = await request(app)
      .post('/.netlify/functions/api/reconcile')
      .send({ invalid: 'data' });
    
    expect(response.status).toBe(400);
  });
});
