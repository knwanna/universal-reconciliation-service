const request = require('supertest');
const app = require('../../src/local/server');

describe('Local Suggestion API', () => {
  test('GET /api/suggest should require prefix', async () => {
    const response = await request(app).get('/api/suggest');
    expect(response.status).toBe(400);
  });

  test('GET /api/suggest should accept valid parameters', async () => {
    const response = await request(app)
      .get('/api/suggest?prefix=test&type=entity&limit=5');
    
    expect(response.status).toBe(200);
  });
});