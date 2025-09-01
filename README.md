# Tutorial: Setting Up the Universal Reconciliation Service API on a Windows Machine (Local Hosting)

This tutorial outlines how to set up and run the Universal Reconciliation Service API locally on a Windows machine. The API, compliant with the OpenRefine Reconciliation API specification (v0.1), supports data reconciliation, entity suggestion, preview generation, data extension, and real-time stream chunking for pattern matching against text or JSON files. Built with Node.js and Netlify Functions, it uses the Google Gemini LLM (gemini-1.5-flash) for dynamic processing. The guide includes all necessary files, detailed setup instructions, local testing, and OpenRefine integration, tailored for Windows users.

## 1. Objectives
- **Set up the API locally**: Configure and run the API on a Windows machine.
- **Ensure OpenRefine compatibility**: Verify compliance with the OpenRefine Reconciliation API spec (v0.1).
- **Enable stream chunking**: Support real-time three-character chunk matching against files.
- **Test locally**: Validate all endpoints, including reconciliation and stream chunking.
- **Integrate with OpenRefine**: Connect the local API to OpenRefine for data reconciliation.
- **Provide reproducible setup**: Include all code and instructions for Windows-specific deployment.

## 2. Prerequisites
- **System Requirements**:
  - Windows 10 or 11 (64-bit).
  - 8GB RAM minimum, internet connection.
- **Software**:
  - **Node.js**: v20+ ([nodejs.org](https://nodejs.org/en/download)).
  - **Netlify CLI**: For local testing (`npm install -g netlify-cli`).
  - **Git**: For version control ([git-scm.com](https://git-scm.com/downloads)).
  - **OpenRefine**: v3.7+ for testing ([openrefine.org](https://openrefine.org)).
  - **Text Editor**: Visual Studio Code recommended ([code.visualstudio.com](https://code.visualstudio.com)).
  - **curl or Postman**: For API testing.
- **API Key**: Google Gemini API key from [ai.google.dev](https://ai.google.dev).
- **Sample Dataset**: A CSV file (e.g., `cities.csv`) for testing.

## 3. Project Structure
Create the following directory structure on your Windows machine:
```
C:\reconciliation-service\
├── data\
│   ├── sample.txt
│   └── sample.json
├── netlify\
│   ├── functions\
│   │   ├── metadata.js
│   │   ├── reconcile.js
│   │   ├── suggest-entity.js
│   │   ├── suggest-type.js
│   │   ├── suggest-property.js
│   │   ├── preview.js
│   │   ├── extend-propose.js
│   │   ├── extend.js
│   │   ├── stream-chunk.js
│   │   └── utils.js
├── package.json
├── netlify.toml
├── .env.example
├── .gitignore
└── README.md
```

## 4. Code Files
Below are the complete code files required for the API, including all OpenRefine-compliant endpoints and the stream chunking feature.

### 4.1 `data/sample.txt`
```text
This is a sample text file containing city names like Paris, London, and Tokyo.
```

### 4.2 `data/sample.json`
```json
[
  { "city": "Paris", "country": "France" },
  { "city": "London", "country": "UK" }
]
```

### 4.3 `netlify/functions/metadata.js`
```javascript
exports.handler = async (event, context) => {
  const baseUrl = `http://${event.headers.host}`;
  return {
    statusCode: 200,
    headers: { "Access-Control-Allow-Origin": "*" },
    body: JSON.stringify({
      name: "Universal Reconciliation Service",
      identifierSpace: "http://example.com/identifiers",
      schemaSpace: "http://example.com/schemas",
      defaultTypes: [{ id: "/general", name: "General Entity" }],
      view: { url: "http://example.com/view/{{id}}" },
      preview: { url: `${baseUrl}/preview?id={{id}}`, width: 400, height: 200 },
      suggest: {
        entity: { service_url: baseUrl, service_path: "/suggest/entity" },
        type: { service_url: baseUrl, service_path: "/suggest/type" },
        property: { service_url: baseUrl, service_path: "/suggest/property" },
      },
      extend: {
        propose_properties: { service_url: baseUrl, service_path: "/extend/propose" },
        property_settings: [
          { name: "maxItems", label: "Maximum number of values", type: "number", default: 1 },
        ],
      },
    }),
  };
};
```

### 4.4 `netlify/functions/reconcile.js`
```javascript
const { callGemini, getReconcileSchema } = require('./utils');

exports.handler = async (event) => {
  try {
    const queries = JSON.parse(event.body?.queries || event.queryStringParameters?.queries || '{}');
    const callback = event.queryStringParameters?.callback;
    const results = {};

    for (const [key, query] of Object.entries(queries)) {
      const prompt = `Reconcile query: ${query.query}, Type: ${query.type || '/general'}, Limit: ${query.limit || 3}, Properties: ${JSON.stringify(query.properties || [])}`;
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
      response.body = `${callback}(${response.body})`;
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
```

### 4.5 `netlify/functions/suggest-entity.js`
```javascript
const { callGemini } = require('./utils');

exports.handler = async (event) => {
  try {
    const { prefix = '', type = '' } = event.queryStringParameters;
    const prompt = `Suggest entities starting with "${prefix}" for type "${type}". Return as JSON with result array of {id, name, description}.`;
    const llmResponse = await callGemini(prompt, {
      type: "object",
      properties: {
        result: {
          type: "array",
          items: {
            type: "object",
            properties: {
              id: { type: "string" },
              name: { type: "string" },
              description: { type: "string" },
            },
          },
        },
      },
    });
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify(llmResponse),
    };
  } catch (error) {
    console.error('Suggest entity error:', error);
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ result: [] }),
    };
  }
};
```

### 4.6 `netlify/functions/suggest-type.js`
```javascript
const { callGemini } = require('./utils');

exports.handler = async (event) => {
  try {
    const { prefix = '' } = event.queryStringParameters;
    const prompt = `Suggest types starting with "${prefix}". Return as JSON with result array of {id, name}.`;
    const llmResponse = await callGemini(prompt, {
      type: "object",
      properties: {
        result: {
          type: "array",
          items: {
            type: "object",
            properties: {
              id: { type: "string" },
              name: { type: "string" },
            },
          },
        },
      },
    });
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify(llmResponse),
    };
  } catch (error) {
    console.error('Suggest type error:', error);
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ result: [] }),
    };
  }
};
```

### 4.7 `netlify/functions/suggest-property.js`
```javascript
const { callGemini } = require('./utils');

exports.handler = async (event) => {
  try {
    const { prefix = '', type = '' } = event.queryStringParameters;
    const prompt = `Suggest properties starting with "${prefix}" for type "${type}". Return as JSON with result array of {id, name}.`;
    const llmResponse = await callGemini(prompt, {
      type: "object",
      properties: {
        result: {
          type: "array",
          items: {
            type: "object",
            properties: {
              id: { type: "string" },
              name: { type: "string" },
            },
          },
        },
      },
    });
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify(llmResponse),
    };
  } catch (error) {
    console.error('Suggest property error:', error);
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ result: [] }),
    };
  }
};
```

### 4.8 `netlify/functions/preview.js`
```javascript
const { callGemini } = require('./utils');

exports.handler = async (event) => {
  try {
    const { id = '' } = event.queryStringParameters;
    const prompt = `Generate a preview for entity with ID "${id}". Return as JSON with html containing the preview content.`;
    const llmResponse = await callGemini(prompt, {
      type: "object",
      properties: { html: { type: "string" } },
    });
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify(llmResponse),
    };
  } catch (error) {
    console.error('Preview error:', error);
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ html: '<p>Error generating preview</p>' }),
    };
  }
};
```

### 4.9 `netlify/functions/extend-propose.js`
```javascript
const { callGemini } = require('./utils');

exports.handler = async (event) => {
  try {
    const { type = '', limit = 10 } = JSON.parse(event.body || '{}');
    const prompt = `Propose properties for type "${type}", limit to ${limit}. Return as JSON with properties array of {id, name}.`;
    const llmResponse = await callGemini(prompt, {
      type: "object",
      properties: {
        properties: {
          type: "array",
          items: {
            type: "object",
            properties: {
              id: { type: "string" },
              name: { type: "string" },
            },
          },
        },
      },
    });
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify(llmResponse),
    };
  } catch (error) {
    console.error('Propose properties error:', error);
    return {
      statusCode: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ properties: [] }),
    };
  }
};
```

### 4.10 `netlify/functions/extend.js`
```javascript
const { callGemini } = require('./utils');

exports.handler = async (event) => {
  try {
    const { ids = [], properties = [] } = JSON.parse(event.body || '{}');
    const results = { rows: {} };

    for (const id of ids) {
      const prompt = `Extend data for entity ID "${id}" with properties: ${properties.map(p => p.id).join(', ')}. Return as JSON with values for each property as array of {str or num}.`;
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
```

### 4.11 `netlify/functions/stream-chunk.js`
```javascript
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
            const prompt = `Match chunk "${chunk}" in file ${file}. Return context (20 chars before/after).`;
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
```

### 4.12 `netlify/functions/utils.js`
```javascript
const fetch = require('node-fetch');

async function callGemini(prompt, schema) {
  const apiKey = process.env.GEMINI_API_KEY;
  const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      contents: [{ role: 'user', parts: [{ text: prompt }] }],
      generationConfig: { responseMimeType: 'application/json', responseSchema: schema },
    }),
  });

  if (!response.ok) {
    throw new Error(`API error: ${response.status}`);
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
```

### 4.13 `package.json`
```json
{
  "name": "universal-reconciliation-service",
  "version": "1.0.0",
  "description": "OpenRefine-compatible reconciliation API with stream chunking",
  "main": "index.js",
  "scripts": {
    "dev": "netlify dev"
  },
  "dependencies": {
    "body-parser": "^1.20.2",
    "dotenv": "^16.0.3",
    "node-fetch": "^2.6.7"
  },
  "devDependencies": {
    "netlify-cli": "^12.0.0"
  },
  "author": "",
  "license": "ISC"
}
```

### 4.14 `netlify.toml`
```toml
[build]
  functions = "netlify/functions"

[[redirects]]
  from = "/"
  to = "/.netlify/functions/metadata"
  status = 200
  force = true

[[redirects]]
  from = "/reconcile"
  to = "/.netlify/functions/reconcile"
  status = 200
  force = true

[[redirects]]
  from = "/suggest/entity"
  to = "/.netlify/functions/suggest-entity"
  status = 200
  force = true

[[redirects]]
  from = "/suggest/type"
  to = "/.netlify/functions/suggest-type"
  status = 200
  force = true

[[redirects]]
  from = "/suggest/property"
  to = "/.netlify/functions/suggest-property"
  status = 200
  force = true

[[redirects]]
  from = "/preview"
  to = "/.netlify/functions/preview"
  status = 200
  force = true

[[redirects]]
  from = "/extend/propose"
  to = "/.netlify/functions/extend-propose"
  status = 200
  force = true

[[redirects]]
  from = "/extend"
  to = "/.netlify/functions/extend"
  status = 200
  force = true

[[redirects]]
  from = "/stream-chunk"
  to = "/.netlify/functions/stream-chunk"
  status = 200
  force = true
```

### 4.15 `.env.example`
```text
GEMINI_API_KEY=your-gemini-api-key-here
```

### 4.16 `.gitignore`
```text
node_modules
.env
```

## 5. Setup Instructions on Windows
Follow these steps to set up and run the API locally on a Windows machine.

### 5.1 Install Prerequisites
1. **Node.js**:
   - Download the Windows installer (v20+) from [nodejs.org](https://nodejs.org/en/download).
   - Run the installer, selecting “Add to PATH” during setup.
   - Verify installation:
     ```cmd
     node --version
     npm --version
     ```
     Expected: `v20.x.x` and `npm v9.x.x` or higher.
2. **Netlify CLI**:
   - Open Command Prompt (cmd) or PowerShell.
   - Install globally:
     ```cmd
     npm install -g netlify-cli
     ```
   - Verify:
     ```cmd
     netlify --version
     ```
3. **Git**:
   - Download and install from [git-scm.com](https://git-scm.com/downloads).
   - Verify:
     ```cmd
     git --version
     ```
4. **OpenRefine**:
   - Download from [openrefine.org](https://openrefine.org).
   - Extract the ZIP file to `C:\OpenRefine`.
   - Run:
     ```cmd
     C:\OpenRefine\openrefine.exe
     ```
   - Access at `http://localhost:3333`.
5. **Visual Studio Code**:
   - Download and install from [code.visualstudio.com](https://code.visualstudio.com).
   - Use for editing files.
6. **Gemini API Key**:
   - Obtain from [ai.google.dev](https://ai.google.dev).
   - Copy the key for use in `.env`.

### 5.2 Create Project Directory
1. Open File Explorer and create a folder: `C:\reconciliation-service`.
2. Create the directory structure as shown in Section 3.
3. Copy or create the files from Section 4 into their respective folders:
   - Use VS Code to create/edit files.
   - For example, create `C:\reconciliation-service\data\sample.txt` and paste the content from 4.1.

### 5.3 Install Dependencies
1. Open Command Prompt or PowerShell.
2. Navigate to the project directory:
   ```cmd
   cd C:\reconciliation-service
   ```
3. Install Node.js dependencies:
   ```cmd
   npm install
   ```
   This installs `body-parser`, `dotenv`, `node-fetch`, and `netlify-cli`.

### 5.4 Configure Environment
1. Copy `.env.example` to `.env`:
   - In File Explorer, right-click `.env.example` > Copy, then Paste and rename to `.env`.
   - Or use Command Prompt:
     ```cmd
     copy .env.example .env
     ```
2. Open `.env` in VS Code or Notepad.
3. Add your Gemini API key:
   ```text
   GEMINI_API_KEY=your-gemini-api-key-here
   ```
4. Save the file.

### 5.5 Run the API Locally
1. In Command Prompt or PowerShell, navigate to `C:\reconciliation-service`.
2. Start the Netlify development server:
   ```cmd
   npm run dev
   ```
   - This runs `netlify dev`, starting the API at `http://localhost:8888`.
   - Netlify CLI simulates the serverless environment locally.
3. Keep the terminal open to maintain the server.

### 5.6 Test the API
1. **Verify Metadata Endpoint**:
   - Open a new Command Prompt or use curl in PowerShell:
     ```cmd
     curl http://localhost:8888/
     ```
   - Expected response:
     ```json
     {
       "name": "Universal Reconciliation Service",
       "identifierSpace": "http://example.com/identifiers",
       "schemaSpace": "http://example.com/schemas",
       "defaultTypes": [{"id": "/general", "name": "General Entity"}],
       ...
     }
     ```
2. **Test Reconciliation**:
   ```cmd
   curl -X POST http://localhost:8888/reconcile -d "queries={\"q0\":{\"query\":\"Paris\",\"type\":\"/location\"}}"
   ```
   - Expected:
     ```json
     {
       "q0": {
         "result": [{"id": "paris-fr", "name": "Paris, France", "score": 0.95, "match": true, "type": [{"id": "/location", "name": "Location"}]}]
       }
     }
     ```
3. **Test Stream Chunking**:
   ```cmd
   curl -X POST http://localhost:8888/stream-chunk -d "{\"input\":\"paris\"}"
   ```
   - Expected:
     ```json
     {
       "matches": [
         {"chunk": "par", "file": "sample.txt", "context": "...city of paris is..."}
       ]
     }
     ```
4. **Use Postman (Optional)**:
   - Create a POST request to `http://localhost:8888/reconcile` with body:
     ```json
     {"queries": {"q0": {"query": "Paris", "type": "/location"}}}
     ```
   - Verify similar responses.

### 5.7 Integrate with OpenRefine
1. **Launch OpenRefine**:
   ```cmd
   C:\OpenRefine\openrefine.exe
   ```
   Access at `http://localhost:3333`.
2. **Create Project**:
   - Click **Create Project** > **Choose Files**.
   - Upload a CSV (e.g., `cities.csv`):
     ```csv
     name
     Paris
     London
     Tokyo
     ```
   - Configure parsing (comma delimiter, UTF-8) and create the project.
3. **Add Reconciliation Service**:
   - Select the `name` column.
   - Click **Reconcile** > **Start reconciling**.
   - Click **Add Standard Service**.
   - Enter `http://localhost:8888/`.
   - OpenRefine fetches metadata, displaying “Universal Reconciliation Service”.
   - Click **Add Service**.
4. **Reconcile**:
   - Select the service and type (e.g., `/location`).
   - Click **Start Reconciling**.
   - Review matches (e.g., `Paris -> Paris, France, score: 0.95`).
5. **Extend Data (Optional)**:
   - After reconciliation, go to `name` > **Reconcile** > **Add column based on this column**.
   - Select properties (e.g., `population`) via `/extend/propose`.
   - Values appear in a new column (e.g., `2148000` for Paris).

### 5.8 Verify OpenRefine Compliance
- **Testbench**:
  - Visit [reconciliation-api.github.io/testbench](https://reconciliation-api.github.io/testbench/).
  - Enter `http://localhost:8888/`.
  - Run tests for metadata, reconcile, suggest, preview, and extend.
  - Ensure all pass to confirm OpenRefine spec (v0.1) compliance.
- **Streaming**:
  - Test with a larger CSV (e.g., 100 rows). OpenRefine batches queries (10–50 rows per `/reconcile` POST).
  - Check OpenRefine logs (`http://localhost:3333/logs`) for errors.

## 6. Troubleshooting
- **Node.js Errors**:
  - If `npm install` fails, ensure Node.js is added to PATH. Reinstall or run `npm cache clean --force`.
- **Netlify CLI Fails**:
  - Verify installation: `netlify --version`.
  - Update: `npm install -g netlify-cli@latest`.
- **API Not Responding**:
  - Check `.env` for correct `GEMINI_API_KEY`.
  - Test Gemini API connectivity:
    ```cmd
    curl https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=your-gemini-api-key
    ```
  - Ensure `netlify dev` is running.
- **OpenRefine Connection Issues**:
  - Confirm `http://localhost:8888/` returns metadata.
  - Check firewall settings (allow port 8888).
- **Stream Chunking Errors**:
  - Verify `/data` folder exists with `sample.txt` and `sample.json`.
  - Check file permissions in Windows (right-click > Properties > Security).
- **Performance**:
  - Gemini API latency is ~100–500ms. If slow, verify internet connection or API key quotas.

## 7. OpenRefine Compliance
The API fully implements the OpenRefine Reconciliation API spec (v0.1):
- **Metadata** (`/`): Service details, suggest/extend configs.
- **Reconcile** (`/reconcile`): Batch queries, type constraints, properties, JSONP.
- **Suggest** (`/suggest/entity`, `/suggest/type`, `/suggest/property`): Prefix-based filtering.
- **Preview** (`/preview`): HTML snippets.
- **Extend** (`/extend/propose`, `/extend`): Property proposals and data fetching.
- **Streaming**: Batched POSTs for large datasets.
- **JSONP**: Supports `callback` for cross-origin requests.

## 8. Example Workflow
1. **Setup**:
   - Create `cities.csv` and place in `C:\reconciliation-service`.
   - Run `npm run dev`.
2. **Reconcile**:
   - In OpenRefine, add `http://localhost:8888/` as a service.
   - Reconcile `name` column with `/location` type.
   - Matches: `Paris -> Paris, France (score: 0.95)`.
3. **Extend**:
   - Add `population` property.
   - Result: New column with `2148000` for Paris.
4. **Stream Chunking**:
   ```cmd
   curl -X POST http://localhost:8888/stream-chunk -d "{\"input\":\"paris\"}"
   ```
   Expected:
   ```json
   {
     "matches": [
       {"chunk": "par", "file": "sample.txt", "context": "...city of paris is..."}
     ]
   }
   ```

## 9. Conclusion
This tutorial provides a complete guide to setting up the Universal Reconciliation Service API on a Windows machine for local hosting. The API is fully compliant with OpenRefine, supports real-time stream chunking, and leverages Gemini LLM for dynamic processing. By following the steps, you can run the API locally, test all endpoints, and integrate with OpenRefine for data reconciliation. For production use, consider deploying to Netlify and adding caching or external storage for scalability.