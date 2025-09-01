const { callGemini } = require('./utils');

exports.handler = async (event) => {
  try {
    const { prefix = '', type = '' } = event.queryStringParameters;
    const prompt = Suggest entities starting with "" for type "". Return as JSON with result array of {id, name, description}.;
    const llmResponse = await callGemini(prompt, {
      type: "object",
      properties: {
        result: {
          type: "array",
          items: {
            type: "object",
            properties: {
              id: { type: "string" },
              name: { type: "string" },
              description: { type: "string" },
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
    console.error('Suggest entity error:', error);
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ result: [] }),
    };
  }
};
