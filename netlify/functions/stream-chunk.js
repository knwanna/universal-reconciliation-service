const fs = require('fs').promises;
const path = require('path');
const { callGemini } = require('./utils');

exports.handler = async (event) => {
  try {
    const { input } = JSON.parse(event.body || '{}');
    if (!input) {
      return {
        statusCode: 400,
        headers: { "Access-Control-Allow-Origin": "*" },
        body: JSON.stringify({ error: 'Input required' }),
      };
    }

    const chunks = [];
    for (let i = 0; i < input.length; i += 3) {
      chunks.push(input.slice(i, i + 3));
    }

    const dataDir = path.join(__dirname, '../../data');
    const files = await fs.readdir(dataDir);
    const matches = [];

    for (const file of files) {
      if (file.endsWith('.txt') || file.endsWith('.json')) {
        const content = await fs.readFile(path.join(dataDir, file), 'utf8');
        let fileData = content;
        if (file.endsWith('.json')) {
          fileData = JSON.stringify(JSON.parse(content));
        }

        for (const chunk of chunks) {
          if (fileData.toLowerCase().includes(chunk.toLowerCase())) {
            const prompt = Match chunk "" in file . Return context (20 chars before/after).;
            const llmResponse = await callGemini(prompt, {
              type: 'object',
              properties: { context: { type: 'string' } },
            });
            matches.push({
              chunk,
              file,
              context: llmResponse.context || fileData.slice(Math.max(0, fileData.indexOf(chunk) - 20), fileData.indexOf(chunk) + 23),
            });
          }
        }
      }
    }

    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ matches }),
    };
  } catch (error) {
    console.error('Stream chunk error:', error);
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ matches: [] }),
    };
  }
};
