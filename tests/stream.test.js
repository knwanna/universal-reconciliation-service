const request = require('supertest');
const baseUrl = 'http://localhost:8888';

describe('Stream Chunk Tests', () => {
  test('Matches three-character chunks', async () => {
    const response = await request(baseUrl)
      .post('/stream-chunk')
      .send({ input: 'paris' });
    const matches = response.body.matches;
    expect(matches.some(m => m.chunk === 'par')).toBe(true);
    expect(matches.some(m => m.chunk === 'ris')).toBe(true);
  });

  test('Handles empty input', async () => {
    const response = await request(baseUrl)
      .post('/stream-chunk')
      .send({ input: '' });
    expect(response.status).toBe(400);
    expect(response.body.error).toBe('Input required');
  });
});
