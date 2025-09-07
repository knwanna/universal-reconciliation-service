const { getServiceMetadata } = require('../shared/utils');

exports.handler = async (event) => {
  try {
    const baseUrl = process.env.BASE_URL || 'http://localhost:8888';
    const metadata = getServiceMetadata(baseUrl);
    
    return {
      statusCode: 200,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify(metadata)
    };
  } catch (error) {
    console.error('Metadata error:', error);
    return {
      statusCode: 500,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({ error: 'Failed to get service metadata' })
    };
  }
};