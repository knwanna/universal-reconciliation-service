const { handler } = require('../../src/functions/suggest');

describe('Netlify Suggestion Function', () => {
  test('should handle valid suggestion request', async () => {
    const event = {
      queryStringParameters: { prefix: 'test', type: 'entity', limit: '5' }
    };
    
    const response = await handler(event);
    expect(response.statusCode).toBe(200);
  });

  test('should require prefix parameter', async () => {
    const event = {
      queryStringParameters: { type: 'entity' }
    };
    
    const response = await handler(event);
    expect(response.statusCode).toBe(400);
  });
});