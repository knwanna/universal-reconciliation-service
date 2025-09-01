const { callGemini } = require('./utils');

exports.handler = async (event) => {
  try {
    const { id = '' } = event.queryStringParameters;
    const prompt = Generate a preview for entity with ID "". Return as JSON with html containing the preview content.;
    const llmResponse = await callGemini(prompt, {
      type: "object",
      properties: { html: { type: "string" } },
    });
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify(llmResponse),
    };
  } catch (error) {
    console.error('Preview error:', error);
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ html: '<p>Error generating preview</p>' }),
    };
  }
};
