const { handler } = require('../../src/functions/reconcile');

describe('Netlify Reconciliation Function', () => {
  test('should handle valid reconciliation request', async () => {
    const event = {
      body: JSON.stringify({
        queries: {
          q0: { query: 'Albert Einstein', type: 'scientist', limit: 5 }
        }
      })
    };
    
    const response = await handler(event);
    expect(response.statusCode).toBe(200);
  });

  test('should handle invalid input', async () => {
    const event = {
      body: JSON.stringify({ invalid: 'data' })
    };
    
    const response = await handler(event);
    expect(response.statusCode).toBe(400);
  });
});