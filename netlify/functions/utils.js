const fetch = require('node-fetch');

async function callGemini(prompt, schema) {
  const apiKey = process.env.GEMINI_API_KEY;
  const response = await fetch(https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      contents: [{ role: 'user', parts: [{ text: prompt }] }],
      generationConfig: { responseMimeType: 'application/json', responseSchema: schema },
    }),
  });

  if (!response.ok) {
    throw new Error(API error: );
  }

  const result = await response.json();
  return JSON.parse(result.candidates[0].content.parts[0].text);
}

function getReconcileSchema() {
  return {
    type: 'object',
    properties: {
      result: {
        type: 'array',
        items: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            name: { type: 'string' },
            score: { type: 'number' },
            match: { type: 'boolean' },
            type: {
              type: 'array',
              items: { type: 'object', properties: { id: { type: 'string' }, name: { type: 'string' } } },
            },
          },
        },
      },
    },
  };
}

module.exports = { callGemini, getReconcileSchema };
