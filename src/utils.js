const { GoogleGenerativeAI } = require('@google/generative-ai');
const { v4: uuidv4 } = require('uuid');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

const API_KEY = process.env.GEMINI_API_KEY;
if (!API_KEY) {
  console.error("GEMINI_API_KEY is not set. Please set the environment variable.");
  process.exit(1);
}
const genAI = new GoogleGenerativeAI(API_KEY);

// Helper function to get the Gemini model response
async function getModelResponse(prompt, isJson, useSearch) {
  try {
    const generationConfig = isJson ? { responseMimeType: "application/json" } : {};
    const tools = useSearch ? [{ google_search: {} }] : undefined;

    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash-preview-05-20", generationConfig, tools });

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();

    return { text };
  } catch (error) {
    console.error('Gemini API error:', error);
    throw new Error('Failed to get response from Gemini API.');
  }
}

// Helper function to get service metadata
function getServiceMetadata() {
  return {
    name: "Universal Reconciliation Service API",
    identifierSpace: "[http://www.freebase.com/ns/freebase](http://www.freebase.com/ns/freebase)",
    schemaSpace: "[http://www.freebase.com/ns/type.type](http://www.freebase.com/ns/type.type)",
    view: {
      url: "{{id}}"
    },
    defaultTypes: [{
      id: "/common/topic",
      name: "Topic"
    }],
    reconcile: {
      path: "/reconcile",
      serviceUrl: "/.netlify/functions/api"
    },
    suggest: {
      entity: {
        path: "/suggest/entity",
        serviceUrl: "/.netlify/functions/api"
      },
      type: {
        path: "/suggest/type",
        serviceUrl: "/.netlify/functions/api"
      },
      property: {
        path: "/suggest/property",
        serviceUrl: "/.netlify/functions/api"
      }
    },
    preview: {
      path: "/preview",
      serviceUrl: "/.netlify/functions/api"
    },
    extend: {
      propose_properties: {
        path: "/extend/propose",
        serviceUrl: "/.netlify/functions/api"
      },
      serviceUrl: "/.netlify/functions/api"
    }
  };
}

// Helper function to handle reconciliation matching
async function getMatchingResults(queries) {
  const results = {};
  for (const qid in queries) {
    const query = queries[qid];
    const userPrompt = `Reconcile the entity "${query.query}" against entities of type "${query.type}". Provide a list of 5 possible matches in JSON format, each with a 'name', 'id', 'score' (0-100), and 'type' property. The 'score' should reflect the confidence of the match.`;
    const modelResponse = await getModelResponse(userPrompt, true, false);

    const matches = JSON.parse(modelResponse.text);

    results[qid] = {
      result: matches.map(match => ({
        id: match.id || uuidv4(),
        name: match.name,
        score: match.score / 100,
        match: match.score > 70 ? true : false,
        type: [{
          id: match.type,
          name: match.type
        }]
      }))
    };
  }
  return results;
}

// Helper function to handle suggestions
async function getSuggestions(type, prefix) {
  let userPrompt;
  switch (type) {
    case 'entity':
      userPrompt = `Suggest 5 entities related to "${prefix}" in JSON format. Each entity should have a 'name' and 'id'.`;
      break;
    case 'type':
      userPrompt = `Suggest 5 data types related to "${prefix}" in JSON format. Each type should have a 'name' and 'id'.`;
      break;
    case 'property':
      userPrompt = `Suggest 5 properties that start with "${prefix}" in JSON format. Each property should have a 'name' and 'id'.`;
      break;
    default:
      throw new Error(`Invalid suggestion type: ${type}`);
  }

  const modelResponse = await getModelResponse(userPrompt, true, false);
  const suggestions = JSON.parse(modelResponse.text);

  return {
    result: suggestions.map(s => ({
      id: s.id || uuidv4(),
      name: s.name,
      description: s.description || ""
    }))
  };
}

// Helper function to get preview HTML
async function getPreviewHTML(id) {
  const userPrompt = `Generate a short HTML description for an entity with the ID "${id}". Make sure the HTML is well-formed.`;
  const modelResponse = await getModelResponse(userPrompt, true, false);
  return modelResponse.text;
}

// Helper function to get extended properties
async function getExtendedProperties(ids, properties) {
  const data = {};
  for (const id of ids) {
    const userPrompt = `For the entity with ID "${id}", retrieve the values for the following properties: ${properties.map(p => p.id).join(', ')}. Provide the result in a JSON object where keys are the property IDs and values are the corresponding values.`;
    const modelResponse = await getModelResponse(userPrompt, true, false);

    const values = JSON.parse(modelResponse.text);
    data[id] = values;
  }
  return {
    meta: properties.map(p => ({ id: p.id, name: p.name })),
    rows: ids.map(id => ({ id: id, values: properties.map(p => data[id][p.id] ? [{ str: data[id][p.id] }] : []) }))
  };
}


module.exports = {
  getServiceMetadata,
  getModelResponse,
  getMatchingResults,
  getSuggestions,
  getPreviewHTML,
  getExtendedProperties,
};

