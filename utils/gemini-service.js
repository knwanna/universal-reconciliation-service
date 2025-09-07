const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

class GeminiService {
  static async generateContent(prompt, options = {}) {
    try {
      const model = genAI.getGenerativeModel({ 
        model: options.model || "gemini-pro",
        generationConfig: {
          temperature: options.temperature || 0.7,
          maxOutputTokens: options.maxTokens || 2048,
        }
      });

      const result = await model.generateContent(prompt);
      const response = await result.response;
      return response.text();
    } catch (error) {
      console.error('Gemini API Error:', error);
      throw new Error(`Gemini API call failed: ${error.message}`);
    }
  }

  static async extractJSONFromResponse(text) {
    try {
      const jsonMatch = text.match(/\[[\s\S]*\]/) || text.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        return JSON.parse(jsonMatch[0]);
      }
      return null;
    } catch (error) {
      console.error('JSON extraction error:', error);
      return null;
    }
  }

  static async validateApiKey() {
    if (!process.env.GEMINI_API_KEY) {
      throw new Error('GEMINI_API_KEY environment variable is not set');
    }
    
    try {
      const model = genAI.getGenerativeModel({ model: "gemini-pro" });
      await model.generateContent('test');
      return true;
    } catch (error) {
      throw new Error(`Invalid Gemini API key: ${error.message}`);
    }
  }
}

module.exports = GeminiService;
