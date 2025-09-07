const { getExtendedProperties } = require('../shared/utils');

exports.handler = async (event) => {
  try {
    const body = JSON.parse(event.body || '{}');
    const { ids, properties } = body;
    
    if (!ids || !properties || !Array.isArray(ids) || !Array.isArray(properties)) {
      return {
        statusCode: 400,
        headers: { 'Access-Control-Allow-Origin': '*' },
        body: JSON.stringify({ error: 'Invalid ids or properties format' })
      };
    }

    const result = await getExtendedProperties(ids, properties);
    
    return {
      statusCode: 200,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify(result)
    };
  } catch (error) {
    console.error('Extend error:', error);
    return {
      statusCode: 500,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({ error: 'Failed to extend properties' })
    };
  }
};