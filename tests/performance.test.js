const request = require('supertest');
const baseUrl = 'http://localhost:8888';

describe('Performance Tests', () => {
  test('Reconcile endpoint latency', async () => {
    const start = Date.now();
    await request(baseUrl)
      .post('/reconcile')
      .send({ queries: { q0: { query: 'Paris', type: '/location', limit: 3 } } });
    const latency = Date.now() - start;
    console.log(Reconcile latency: ms);
    expect(latency).toBeLessThan(10000);
  });

  test('Stream chunk endpoint latency', async () => {
    const start = Date.now();
    await request(baseUrl)
      .post('/stream-chunk')
      .send({ input: 'paris' });
    const latency = Date.now() - start;
    console.log(Stream chunk latency: ms);
    expect(latency).toBeLessThan(10000);
  });
});
