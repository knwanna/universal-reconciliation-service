const request = require('supertest');
const baseUrl = 'http://localhost:8888';

describe('Accuracy Tests', () => {
  test('Reconcile accuracy', async () => {
    const response = await request(baseUrl)
      .post('/reconcile')
      .send({ queries: { q0: { query: 'Paris', type: '/location' } } });
    const result = response.body.q0.result[0];
    expect(result.name).toContain('Paris');
    expect(result.score).toBeGreaterThan(0.8);
  });

  test('Stream chunk accuracy', async () => {
    const response = await request(baseUrl)
      .post('/stream-chunk')
      .send({ input: 'par' });
    const matches = response.body.matches;
    expect(matches.length).toBeGreaterThan(0);
    expect(matches[0].chunk).toBe('par');
  });
});
