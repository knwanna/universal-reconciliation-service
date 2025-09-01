const { callGemini } = require('./utils');

exports.handler = async (event) => {
  try {
    const { ids = [], properties = [] } = JSON.parse(event.body || '{}');
    const results = { rows: {} };

    for (const id of ids) {
      const prompt = Extend data for entity ID "" with properties: . Return as JSON with values for each property as array of {str or num}.;
      const llmResponse = await callGemini(prompt, {
        type: "object",
        properties: properties.reduce((acc, prop) => ({
          ...acc,
          [prop.id]: {
            type: "array",
            items: { type: "object", properties: { str: { type: "string" }, num: { type: "number" } } },
          },
        }), {}),
      });
      results.rows[id] = llmResponse;
    }

    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify(results),
    };
  } catch (error) {
    console.error('Extend error:', error);
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ rows: {} }),
    };
  }
};
