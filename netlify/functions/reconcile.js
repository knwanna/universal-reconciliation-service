const { callGemini, getReconcileSchema } = require('./utils');

exports.handler = async (event) => {
  try {
    const queries = JSON.parse(event.body?.queries || event.queryStringParameters?.queries || '{}');
    const callback = event.queryStringParameters?.callback;
    const results = {};

    for (const [key, query] of Object.entries(queries)) {
      const prompt = Reconcile query: , Type: , Limit: , Properties: ;
      const llmResponse = await callGemini(prompt, getReconcileSchema());
      results[key] = { result: llmResponse.result || [] };
    }

    const response = {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify(results),
    };

    if (callback) {
      response.headers["Content-Type"] = "application/javascript";
      response.body = ${callback}();
    }

    return response;
  } catch (error) {
    console.error('Reconcile error:', error);
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({}),
    };
  }
};
