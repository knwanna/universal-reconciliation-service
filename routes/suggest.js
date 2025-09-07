const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

async function getSuggestions(prefix, type = null, limit = 10) {
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-pro" });
    
    const prompt = "Suggest entity names starting with: \"" + prefix + "\"\n" +
                   (type ? "Entity type: " + type + "\n" : "") +
                   "\nReturn a JSON array of suggestions:\n" +
                   "[{\n" +
                   '  "id": "unique_id",\n' +
                   '  "name": "suggested_name",\n' +
                   '  "type": ["entity_type"],\n' +
                   '  "score": 0.9\n' +
                   "}]\n\n" +
                   "Limit to " + limit + " suggestions.";

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();
    
    const jsonMatch = text.match(/\[[\s\S]*\]/);
    if (jsonMatch) {
      return JSON.parse(jsonMatch[0]);
    }
    
    return [];
  } catch (error) {
    console.error('Suggestion error:', error);
    throw new Error('Failed to get suggestions');
  }
}

module.exports = (req, res, next) => {
  if (req.path === '/suggest' && req.method === 'GET') {
    const { prefix, type, limit = 10 } = req.query;
    
    if (!prefix) {
      return res.status(400).json({ error: 'Prefix parameter is required' });
    }

    getSuggestions(prefix, type, parseInt(limit))
      .then(suggestions => {
        res.json({
          result: suggestions.map(suggestion => ({
            id: suggestion.id,
            name: suggestion.name,
            type: suggestion.type,
            score: suggestion.score
          }))
        });
      })
      .catch(next);
  } else {
    next();
  }
};
