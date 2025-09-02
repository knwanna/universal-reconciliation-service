const request = require('supertest');

// Set the base URL from an environment variable for flexibility.
const baseUrl = process.env.BASE_URL || 'http://localhost:8888/.netlify/functions/api';

describe('Accuracy Tests', () => {
  // Tests the accuracy of the reconciliation endpoint.
  test('Reconcile accuracy for a known entity', async () => {
    const response = await request(baseUrl)
      .post('/reconcile')
      .send({ queries: { q0: { query: 'Paris', type: '/location' } } });

    // The first result should contain "Paris" and have a high confidence score.
    const result = response.body.q0.result[0];
    expect(result.name).toContain('Paris');
    expect(result.score).toBeGreaterThan(0.8);
  });

  // Tests the accuracy of the stream-chunk endpoint.
  test('Stream chunk accuracy for a valid input', async () => {
    const response = await request(baseUrl)
      .post('/stream-chunk')
      .send({ input: 'Apple Inc.', fileName: 'sample.json' });

    // The API should return a high-confidence match.
    const result = response.body;
    expect(result.match).toBe('Apple Inc.');
    expect(result.confidence).toBeGreaterThan(0.8);
  });
});
