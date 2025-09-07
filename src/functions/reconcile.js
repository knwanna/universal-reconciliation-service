const { getMatchingResults } = require('../shared/utils');
const { reconciliationSchema } = require('../shared/validation');

exports.handler = async (event) => {
  try {
    const body = JSON.parse(event.body || '{}');
    const { error, value } = reconciliationSchema.validate(body);
    
    if (error) {
      return {
        statusCode: 400,
        headers: { 
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          error: 'Invalid input format',
          details: error.details,
          metadata: { validationError: true }
        })
      };
    }

    const { queries } = value;
    const context = {
      sessionId: event.headers['x-session-id'] || event.requestContext?.identity?.sourceIp,
      userAgent: event.headers['user-agent'],
      environment: 'netlify'
    };

    const results = await getMatchingResults(queries, context);
    
    return {
      statusCode: 200,
      headers: { 
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        ...results,
        metadata: {
          apiVersion: '2.1.0',
          processedAt: new Date().toISOString(),
          environment: 'netlify',
          sessionId: context.sessionId
        }
      })
    };
  } catch (error) {
    console.error('Netlify reconciliation error:', error);
    
    return {
      statusCode: 500,
      headers: { 
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        error: 'Failed to reconcile entities',
        metadata: { 
          errorType: 'processing_error',
          environment: 'netlify'
        }
      })
    };
  }
};