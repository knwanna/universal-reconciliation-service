const { getMatchingResults } = require('../shared/utils');

exports.handler = async (event) => {
  try {
    const body = JSON.parse(event.body || '{}');
    const { queries } = body;
    
    if (!queries || typeof queries !== 'object') {
      return {
        statusCode: 400,
        headers: { 'Access-Control-Allow-Origin': '*' },
        body: JSON.stringify({ error: 'Invalid queries format' })
      };
    }

    const results = await getMatchingResults(queries);
    
    return {
      statusCode: 200,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify(results)
    };
  } catch (error) {
    console.error('Reconciliation error:', error);
    return {
      statusCode: 500,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({ error: 'Failed to reconcile entities' })
    };
  }
};