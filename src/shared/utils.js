const geminiService = require('./gemini-service');
const { v4: uuidv4 } = require('uuid');

function getServiceMetadata(baseUrl) {
  return {
    name: "Advanced Universal Reconciliation Service",
    identifierSpace: "http://schema.org/identifier",
    schemaSpace: "http://schema.org/",
    defaultTypes: [
      { id: "Person", name: "Person" },
      { id: "Organization", name: "Organization" },
      { id: "Place", name: "Place" },
      { id: "CreativeWork", name: "Creative Work" }
    ],
    view: { 
      url: "{{id}}",
      description: "Entity detail view"
    },
    preview: {
      url: `${baseUrl}/preview?id={{id}}`,
      width: 600,
      height: 400,
    },
    suggest: {
      entity: { 
        service_url: baseUrl, 
        service_path: "/suggest/entity",
        flyout_service_path: "/suggest/entity/flyout"
      },
      type: { 
        service_url: baseUrl, 
        service_path: "/suggest/type" 
      },
      property: { 
        service_url: baseUrl, 
        service_path: "/suggest/property" 
      },
    },
    extend: {
      propose_properties: { 
        service_url: baseUrl, 
        service_path: "/extend/propose" 
      },
      property_settings: [
        {
          name: "maxItems",
          label: "Maximum values",
          type: "number",
          default: 5,
          description: "Maximum number of values to return"
        },
        {
          name: "confidenceThreshold",
          label: "Confidence threshold",
          type: "number",
          default: 0.7,
          description: "Minimum confidence score for inclusion"
        }
      ],
    },
    analytics: {
      enabled: true,
      endpoint: `${baseUrl}/analytics`
    }
  };
}

async function getMatchingResults(queries, context = {}) {
  const results = {};
  const sessionId = context.sessionId || uuidv4();
  
  for (const [queryId, queryData] of Object.entries(queries)) {
    try {
      const prompt = `Perform advanced entity reconciliation with deep analysis.

PRIMARY QUERY: "${queryData.query}"
ENTITY TYPE: ${queryData.type || 'any'}
MAX RESULTS: ${queryData.limit || 10}
PROPERTIES: ${JSON.stringify(queryData.properties || [])}

ANALYSIS REQUIREMENTS:
1. Perform multi-level matching (exact, partial, contextual)
2. Consider phonetic similarities and common variations
3. Account for temporal context and historical names
4. Evaluate hierarchical relationships
5. Calculate confidence scores with explanation

OUTPUT FORMAT:
{
  "matches": [
    {
      "id": "unique_identifier",
      "name": "canonical_name",
      "score": 0.95,
      "confidence": "high",
      "match": true,
      "type": ["entity_type"],
      "metadata": {
        "matchType": "exact|partial|contextual",
        "variations": ["alternative_names"],
        "explanation": "matching_rationale",
        "sourceReliability": 0.9
      },
      "properties": {
        "additional_data": "values"
      }
    }
  ],
  "analysis": {
    "totalCandidates": 15,
    "matchQuality": "excellent",
    "ambiguityLevel": "low",
    "recommendations": ["suggestions_for_improvement"]
  }
}`;

      const response = await geminiService.generateAdvancedContent(prompt, {
        sessionId,
        context: {
          taskType: 'reconciliation',
          domain: queryData.type || 'general',
          precision: 'high',
          language: 'english'
        }
      });

      const result = await geminiService.extractStructuredJSON(response, {
        type: 'object',
        properties: {
          matches: { type: 'array' },
          analysis: { type: 'object' }
        }
      });

      results[queryId] = {
        result: result?.matches?.map(match => ({
          id: match.id || uuidv4(),
          name: match.name || 'Unknown Entity',
          score: match.score || 0,
          match: match.match || false,
          type: match.type ? match.type.map(t => ({ id: t, name: t })) : [],
          features: {
            description: match.metadata?.explanation || '',
            confidence: match.metadata?.confidence || 'medium',
            matchType: match.metadata?.matchType || 'unknown',
            variations: match.metadata?.variations || [],
            sourceReliability: match.metadata?.sourceReliability || 0.5
          }
        })) || [],
        metadata: result?.analysis || {}
      };

    } catch (error) {
      results[queryId] = { 
        error: error.message,
        metadata: { errorType: 'processing_error' }
      };
    }
  }
  
  return results;
}

async function getSuggestions(type, prefix, limit = 10, context = {}) {
  const sessionId = context.sessionId || uuidv4();
  
  const prompt = `Generate intelligent entity suggestions with contextual understanding.

SUGGESTION REQUEST:
Type: ${type}
Prefix: "${prefix}"
Limit: ${limit}
Context: ${JSON.stringify(context)}

GENERATION GUIDELINES:
1. Include exact matches first
2. Add phonetic and spelling variations
3. Consider contextual relevance
4. Provide hierarchical relationships
5. Include cross-lingual suggestions when appropriate
6. Rank by relevance and popularity

OUTPUT FORMAT:
{
  "suggestions": [
    {
      "id": "unique_id",
      "name": "suggestion_name",
      "description": "brief_context",
      "relevance": 0.95,
      "type": ["entity_types"],
      "metadata": {
        "matchQuality": "exact|partial|related",
        "popularity": 0.8,
        "contextualRelevance": 0.9,
        "alternativeForms": ["variations"]
      }
    }
  ],
  "summary": {
    "totalSuggestions": 25,
    "coverage": "comprehensive",
    "qualityIndicators": {
      "precision": 0.92,
      "recall": 0.88
    }
  }
}`;

  try {
    const response = await geminiService.generateAdvancedContent(prompt, {
      sessionId,
      context: {
        taskType: 'suggestion',
        domain: type || 'general',
        precision: 'high'
      }
    });

    const result = await geminiService.extractStructuredJSON(response, {
      type: 'object',
      properties: {
        suggestions: { type: 'array' },
        summary: { type: 'object' }
      }
    });

    return {
      result: result?.suggestions?.map(s => ({
        id: s.id || uuidv4(),
        name: s.name || 'Unknown',
        description: s.description || '',
        score: s.relevance || 0.5,
        type: s.type ? s.type.map(t => ({ id: t, name: t })) : [],
        metadata: s.metadata || {}
      })) || [],
      summary: result?.summary || {}
    };

  } catch (error) {
    return {
      result: [],
      summary: { error: error.message }
    };
  }
}

async function getPreviewHTML(id, context = {}) {
  const sessionId = context.sessionId || uuidv4();
  
  const prompt = `Generate comprehensive HTML preview for entity with deep contextual analysis.

ENTITY ID: "${id}"
CONTEXT: ${JSON.stringify(context)}

PREVIEW REQUIREMENTS:
1. Create informative and visually clean HTML
2. Include key identifying information
3. Show relationships and connections
4. Provide confidence indicators
5. Include source attribution when available
6. Make responsive for different devices

OUTPUT FORMAT:
{
  "html": "<div class='entity-preview'>...</div>",
  "metadata": {
    "completeness": 0.85,
    "accuracy": 0.92,
    "sources": ["source_references"],
    "generatedAt": "timestamp"
  },
  "styling": {
    "recommendedCSS": ".entity-preview { ... }",
    "colorScheme": "light|dark",
    "accessibility": "WCAG_AA_compliant"
  }
}`;

  try {
    const response = await geminiService.generateAdvancedContent(prompt, {
      sessionId,
      context: {
        taskType: 'preview',
        domain: 'general',
        precision: 'high'
      }
    });

    const result = await geminiService.extractStructuredJSON(response, {
      type: 'object',
      properties: {
        html: { type: 'string' },
        metadata: { type: 'object' }
      }
    });

    return result?.html || `
      <div class="entity-preview">
        <h3>Entity: ${id}</h3>
        <p>Detailed preview could not be generated at this time.</p>
        <p class="error">Error: Preview generation failed</p>
      </div>
    `;

  } catch (error) {
    return `
      <div class="entity-preview error">
        <h3>Preview Unavailable</h3>
        <p>Unable to generate preview for entity: ${id}</p>
        <p><small>Error: ${error.message}</small></p>
      </div>
    `;
  }
}

async function getExtendedProperties(ids, properties, context = {}) {
  const sessionId = context.sessionId || uuidv4();
  const rows = {};
  
  for (const id of ids) {
    try {
      const prompt = `Perform comprehensive data enrichment with quality assurance.

ENTITY ID: "${id}"
PROPERTIES REQUESTED: ${JSON.stringify(properties)}
ENRICHMENT CONTEXT: ${JSON.stringify(context)}

ENRICHMENT GUIDELINES:
1. Provide accurate and verified information only
2. Include data quality indicators
3. Handle missing data appropriately
4. Maintain consistency across properties
5. Provide source attribution when available
6. Include confidence scores for each value

OUTPUT FORMAT:
{
  "enrichedData": {
    "property_id": {
      "values": [
        {
          "str": "string_value",
          "num": 123,
          "metadata": {
            "confidence": 0.95,
            "source": "source_reference",
            "verification": "verified|estimated|inferred",
            "timestamp": "2024-01-01T00:00:00Z"
          }
        }
      ],
      "completeness": 0.9,
      "reliability": 0.95
    }
  },
  "qualitySummary": {
    "overallCompleteness": 0.88,
    "averageConfidence": 0.92,
    "dataQualityScore": 0.9
  }
}`;

      const response = await geminiService.generateAdvancedContent(prompt, {
        sessionId,
        context: {
          taskType: 'extension',
          domain: 'general',
          precision: 'high'
        }
      });

      const result = await geminiService.extractStructuredJSON(response, {
        type: 'object',
        properties: {
          enrichedData: { type: 'object' },
          qualitySummary: { type: 'object' }
        }
      });

      rows[id] = properties.map(prop => {
        const propData = result?.enrichedData?.[prop.id];
        return propData?.values?.map(value => ({
          str: value.str,
          num: value.num,
          metadata: value.metadata || {}
        })) || [];
      });

    } catch (error) {
      rows[id] = properties.map(() => []);
    }
  }

  return {
    meta: properties.map(prop => ({
      id: prop.id,
      name: prop.name,
      type: prop.type || 'string',
      description: prop.description || ''
    })),
    rows: ids.map(id => ({
      id,
      values: rows[id],
      metadata: {
        processedAt: new Date().toISOString(),
        success: rows[id].every(arr => arr.length > 0)
      }
    })),
    quality: {
      overallScore: 0.85,
      timestamp: new Date().toISOString()
    }
  };
}

module.exports = {
  getServiceMetadata,
  getMatchingResults,
  getSuggestions,
  getPreviewHTML,
  getExtendedProperties
};