const { GoogleGenerativeAI } = require('@google/generative-ai');

class AdvancedGeminiService {
  constructor() {
    if (!process.env.GEMINI_API_KEY) {
      throw new Error('GEMINI_API_KEY environment variable is not set');
    }
    this.genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    this.conversationContext = new Map();
  }

  async generateAdvancedContent(prompt, options = {}) {
    try {
      const model = this.genAI.getGenerativeModel({ 
        model: options.model || "gemini-1.5-flash",
        generationConfig: {
          temperature: options.temperature || 0.3,
          maxOutputTokens: options.maxTokens || 4096,
          topP: 0.8,
          topK: 40,
        },
        safetySettings: [
          {
            category: "HARM_CATEGORY_HARASSMENT",
            threshold: "BLOCK_MEDIUM_AND_ABOVE"
          },
          {
            category: "HARM_CATEGORY_HATE_SPEECH",
            threshold: "BLOCK_MEDIUM_AND_ABOVE"
          }
        ]
      });

      const enhancedPrompt = this.enhancePrompt(prompt, options.context);
      
      const result = await model.generateContent(enhancedPrompt);
      const response = await result.response;
      
      // Store conversation context for follow-up queries
      if (options.sessionId) {
        this.updateConversationContext(options.sessionId, prompt, response.text());
      }
      
      return response.text();
    } catch (error) {
      console.error('Advanced Gemini API Error:', error);
      throw new Error(`Advanced Gemini API call failed: ${error.message}`);
    }
  }

  enhancePrompt(basePrompt, context = {}) {
    const domain = context.domain || 'general';
    const precision = context.precision || 'high';
    const language = context.language || 'english';
    
    const promptTemplates = {
      reconciliation: `You are an expert entity reconciliation system with deep domain knowledge in ${domain}.

ANALYSIS TASK:
${basePrompt}

DOMAIN-SPECIFIC GUIDELINES:
1. Consider cultural naming conventions and variations
2. Account for historical naming changes
3. Handle transliterations and phonetic similarities
4. Recognize organizational hierarchies and relationships
5. Understand temporal context for entity matching

OUTPUT REQUIREMENTS:
- Precision level: ${precision}
- Language: ${language}
- Include confidence scores with explanation
- Provide alternative matching possibilities
- Flag ambiguous matches for human review

Return structured JSON with detailed matching rationale.`,

      suggestion: `You are an intelligent entity suggestion system specializing in ${domain}.

SUGGESTION TASK:
${basePrompt}

CONTEXTUAL UNDERSTANDING:
1. Consider partial matches and fuzzy matching
2. Include related entities and associations
3. Account for common misspellings and variations
4. Provide hierarchical relationships
5. Include temporal relevance

OUTPUT FORMAT:
- Ordered by relevance score
- Include match confidence percentages
- Provide brief contextual descriptions
- Group related suggestions`,

      extension: `You are a data enrichment system with expertise in ${domain} data modeling.

ENRICHMENT TASK:
${basePrompt}

ENRICHMENT GUIDELINES:
1. Maintain data consistency and integrity
2. Provide verified information only
3. Include source reliability indicators
4. Handle missing data appropriately
5. Preserve original data relationships

OUTPUT STANDARDS:
- Structured property-value pairs
- Data quality indicators
- Source attribution when available
- Confidence levels for each property`
    };

    return promptTemplates[context.taskType] || basePrompt;
  }

  updateConversationContext(sessionId, query, response) {
    const currentContext = this.conversationContext.get(sessionId) || [];
    currentContext.push({ query, response });
    
    // Keep only last 10 exchanges to manage context length
    if (currentContext.length > 10) {
      currentContext.shift();
    }
    
    this.conversationContext.set(sessionId, currentContext);
  }

  async extractStructuredJSON(text, schema) {
    try {
      const jsonMatch = text.match(/```json\n([\s\S]*?)\n```/) || 
                       text.match(/{[\s\S]*}/) || 
                       text.match(/\[[\s\S]*\]/);
      
      if (jsonMatch) {
        const jsonText = jsonMatch[0].replace(/```json\n?|\n```/g, '');
        const parsed = JSON.parse(jsonText);
        
        // Validate against schema if provided
        if (schema && this.validateAgainstSchema(parsed, schema)) {
          return parsed;
        }
        return parsed;
      }
      
      // Fallback: try to extract JSON from text
      const fallbackMatch = text.match(/{[\s\S]*}/) || text.match(/\[[\s\S]*\]/);
      return fallbackMatch ? JSON.parse(fallbackMatch[0]) : null;
    } catch (error) {
      console.error('JSON extraction error:', error);
      return null;
    }
  }

  validateAgainstSchema(data, schema) {
    // Basic schema validation
    try {
      if (schema.type === 'array' && !Array.isArray(data)) return false;
      if (schema.type === 'object' && typeof data !== 'object') return false;
      return true;
    } catch {
      return false;
    }
  }

  async validateApiKey() {
    try {
      const model = this.genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
      await model.generateContent('API key validation test');
      return true;
    } catch (error) {
      throw new Error(`Invalid Gemini API key: ${error.message}`);
    }
  }
}

module.exports = new AdvancedGeminiService();