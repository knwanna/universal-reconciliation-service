const { callGemini } = require('./utils');

exports.handler = async (event) => {
  try {
    const { type = '', limit = 10 } = JSON.parse(event.body || '{}');
    const prompt = Propose properties for type "", limit to . Return as JSON with properties array of {id, name}.;
    const llmResponse = await callGemini(prompt, {
      type: "object",
      properties: {
        properties: {
          type: "array",
          items: {
            type: "object",
            properties: {
              id: { type: "string" },
              name: { type: "string" },
            },
          },
        },
      },
    });
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify(llmResponse),
    };
  } catch (error) {
    console.error('Propose properties error:', error);
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ properties: [] }),
    };
  }
};
