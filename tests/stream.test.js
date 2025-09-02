const request = require('supertest');

// Set the base URL from an environment variable for flexibility.
const baseUrl = process.env.BASE_URL || 'http://localhost:8888/.netlify/functions/api';

describe('Stream Chunk Tests', () => {
  // Tests that the endpoint returns the correct structure for a valid chunk.
  test('Returns correct match and confidence for a valid chunk', async () => {
    const response = await request(baseUrl)
      .post('/stream-chunk')
      .send({ input: 'Apple Inc.', fileName: 'sample.json' });
    
    // The new API returns a single `match` and `confidence` score.
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('match');
    expect(response.body).toHaveProperty('confidence');
    expect(typeof response.body.match).toBe('string');
    expect(typeof response.body.confidence).toBe('number');
  });

  // Tests that the endpoint handles empty input gracefully.
  test('Handles empty input and missing filename', async () => {
    const response = await request(baseUrl)
      .post('/stream-chunk')
      .send({ input: '', fileName: '' });
      
    // The API should return a 400 Bad Request error.
    expect(response.status).toBe(400);
    expect(response.body.error).toBe('Input text and file name are required.');
  });
});
