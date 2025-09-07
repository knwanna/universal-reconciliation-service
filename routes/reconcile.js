const { GoogleGenerativeAI } = require('@google/generative-ai');
const Joi = require('joi');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const reconcileSchema = Joi.object({
  queries: Joi.object().pattern(
    Joi.string(),
    Joi.object({
      query: Joi.string().required(),
      type: Joi.string().optional(),
      limit: Joi.number().optional(),
      properties: Joi.array().items(Joi.object()).optional()
    })
  ).required()
});

async function reconcileEntities(query, type = null, limit = 5) {
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-pro" });
    
    const prompt = "You are an entity reconciliation service. Match the following query to known entities.\n" +
                   "Query: \"" + query + "\"\n" +
                   (type ? "Entity type: " + type + "\n" : "") +
                   "\nReturn a JSON array of matches with this structure:\n" +
                   "[{\n" +
                   '  "id": "unique_identifier",\n' +
                   '  "name": "matched_entity_name",\n' +
                   '  "type": ["entity_type"],\n' +
                   '  "score": 0.95,\n' +
                   '  "match": true,\n' +
                   '  "features": {\n' +
                   '    "description": "brief_description",\n' +
                   '    "confidence": "high/medium/low"\n' +
                   '  }\n' +
                   "}]\n\n" +
                   "Limit to " + limit + " best matches.";

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();
    
    // Extract JSON from response
    const jsonMatch = text.match(/\[[\s\S]*\]/);
    if (jsonMatch) {
      return JSON.parse(jsonMatch[0]);
    }
    
    return [];
  } catch (error) {
    console.error('Gemini API error:', error);
    throw new Error('Failed to reconcile entities');
  }
}

module.exports = (req, res, next) => {
  if (req.path === '/reconcile' && req.method === 'POST') {
    const { error, value } = reconcileSchema.validate(req.body);
    
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { queries } = value;
    const results = {};

    Promise.all(
      Object.entries(queries).map(async ([queryId, queryData]) => {
        try {
          const matches = await reconcileEntities(
            queryData.query,
            queryData.type,
            queryData.limit || 5
          );
          
          results[queryId] = {
            result: matches.map(match => ({
              id: match.id,
              name: match.name,
              type: match.type,
              score: match.score,
              match: match.match,
              features: match.features
            }))
          };
        } catch (error) {
          results[queryId] = {
            error: error.message
          };
        }
      })
    ).then(() => {
      res.json(results);
    }).catch(next);
  } else {
    next();
  }
};
