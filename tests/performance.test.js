const request = require('supertest');

// Set the base URL from an environment variable for flexibility.
const baseUrl = process.env.BASE_URL || 'http://localhost:8888/.netlify/functions/api';

describe('Performance Tests', () => {
  // Tests the latency of the reconciliation endpoint.
  test('Reconcile endpoint latency', async () => {
    const start = Date.now();
    await request(baseUrl)
      .post('/reconcile')
      .send({ queries: { q0: { query: 'Paris', type: '/location', limit: 3 } } });
      
    const latency = Date.now() - start;
    console.log(`Reconcile latency: ${latency}ms`);
    // Ensure the response time is less than 10 seconds.
    expect(latency).toBeLessThan(10000);
  });

  // Tests the latency of the stream chunk endpoint.
  test('Stream chunk endpoint latency', async () => {
    const start = Date.now();
    await request(baseUrl)
      .post('/stream-chunk')
      .send({ input: 'Apple Inc.', fileName: 'sample.json' });

    const latency = Date.now() - start;
    console.log(`Stream chunk latency: ${latency}ms`);
    // Ensure the response time is less than 10 seconds.
    expect(latency).toBeLessThan(10000);
  });
});
