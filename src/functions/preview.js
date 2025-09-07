const { getPreviewHTML } = require('../shared/utils');

exports.handler = async (event) => {
  try {
    const { id } = event.queryStringParameters || {};
    
    if (!id) {
      return {
        statusCode: 400,
        headers: { 'Access-Control-Allow-Origin': '*' },
        body: JSON.stringify({ error: 'ID parameter is required' })
      };
    }

    const html = await getPreviewHTML(id);
    
    return {
      statusCode: 200,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: html
    };
  } catch (error) {
    console.error('Preview error:', error);
    return {
      statusCode: 500,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: '<p>Error generating preview</p>'
    };
  }
};