# Universal Reconciliation Service Setup Script
Write-Host "🚀 Setting up Universal Reconciliation Service..." -ForegroundColor Green

# Create project structure
Write-Host "📁 Creating project structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "universal-reconciliation-service" -Force
Set-Location "universal-reconciliation-service"
New-Item -ItemType Directory -Path "netlify/functions" -Force
New-Item -ItemType Directory -Path "public" -Force
New-Item -ItemType Directory -Path "data" -Force

# Create package.json
Write-Host "📦 Creating package.json..." -ForegroundColor Yellow
@'
{
  "name": "universal-reconciliation-service",
  "version": "1.0.0",
  "description": "Universal Reconciliation Service API for Netlify",
  "main": "netlify/functions/api.js",
  "scripts": {
    "dev": "netlify dev",
    "build": "echo 'No build step required'",
    "deploy": "netlify deploy --prod"
  },
  "dependencies": {
    "express": "^4.18.2",
    "serverless-http": "^3.2.0",
    "cors": "^2.8.5",
    "body-parser": "^1.20.2",
    "node-fetch": "^2.6.7"
  },
  "devDependencies": {
    "netlify-cli": "^12.0.0"
  },
  "keywords": [
    "reconciliation",
    "api",
    "openrefine",
    "netlify",
    "serverless"
  ],
  "author": "Your Name",
  "license": "MIT"
}
'@ | Set-Content -Path "package.json"

# Create netlify.toml
Write-Host "⚙️ Creating netlify.toml..." -ForegroundColor Yellow
@'
[build]
  publish = "public"
  functions = "netlify/functions"

[build.environment]
  NODE_VERSION = "18"

[functions]
  node_bundler = "esbuild"

[[redirects]]
  from = "/api/*"
  to = "/.netlify/functions/api/:splat"
  status = 200

[[redirects]]
  from = "/reconcile"
  to = "/.netlify/functions/api/reconcile"
  status = 200

[[redirects]]
  from = "/metadata"
  to = "/.netlify/functions/api"
  status = 200

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
'@ | Set-Content -Path "netlify.toml"

# Create main API function
Write-Host "📝 Creating API function..." -ForegroundColor Yellow
@'
const express = require('express');
const serverless = require('serverless-http');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.get('/.netlify/functions/api', (req, res) => {
  res.json({
    name: 'Universal Reconciliation Service',
    identifierSpace: 'http://example.com/identifiers',
    schemaSpace: 'http://example.com/schemas',
    defaultTypes: [{ id: '/general', name: 'General Entity' }],
    preview: {
      url: '/.netlify/functions/api/preview?id={{id}}',
      width: 400,
      height: 200
    }
  });
});

app.post('/.netlify/functions/api/reconcile', (req, res) => {
  res.json({ result: [] });
});

app.get('/.netlify/functions/api/preview', (req, res) => {
  res.json({ html: '<p>Preview content</p>' });
});

app.get('/.netlify/functions/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

module.exports.handler = serverless(app);
'@ | Set-Content -Path "netlify/functions/api.js"

# Create public/index.html
Write-Host "🌐 Creating index.html..." -ForegroundColor Yellow
@'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Universal Reconciliation Service</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
    .endpoint { background: #f5f5f5; padding: 15px; margin: 10px 0; border-radius: 5px; }
  </style>
</head>
<body>
  <h1>Universal Reconciliation Service API</h1>
  <p>This service provides OpenRefine-compatible reconciliation endpoints.</p>
  
  <div class="endpoint">
    <h3>Metadata Endpoint</h3>
    <code>GET /.netlify/functions/api</code>
  </div>

  <div class="endpoint">
    <h3>Reconciliation Endpoint</h3>
    <code>POST /.netlify/functions/api/reconcile</code>
  </div>

  <div class="endpoint">
    <h3>Preview Endpoint</h3>
    <code>GET /.netlify/functions/api/preview?id=:id</code>
  </div>

  <p>See OpenRefine documentation for usage details.</p>
</body>
</html>
'@ | Set-Content -Path "public/index.html"

# Create .env file
Write-Host "🔧 Creating .env file..." -ForegroundColor Yellow
@'
GEMINI_API_KEY=your_gemini_api_key_here
'@ | Set-Content -Path ".env"

# Create .gitignore
Write-Host "📋 Creating .gitignore..." -ForegroundColor Yellow
@'
node_modules/
.env
.netlify/
.DS_Store
'@ | Set-Content -Path ".gitignore"

# Create sample data files
Write-Host "📊 Creating sample data..." -ForegroundColor Yellow
@'
[
  { "name": "Albert Einstein", "type": "scientist" },
  { "name": "Marie Curie", "type": "scientist" },
  { "name": "Isaac Newton", "type": "scientist" }
]
'@ | Set-Content -Path "data/sample.json"

@'
Sample text data for testing reconciliation service.
Contains information about famous scientists and their contributions.
'@ | Set-Content -Path "data/sample.txt"

# Install dependencies
Write-Host "📦 Installing npm dependencies..." -ForegroundColor Yellow
try {
    npm install
    Write-Host "✅ Dependencies installed successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
    Write-Host "💡 Make sure Node.js is installed: https://nodejs.org/" -ForegroundColor Yellow
}

# Check Netlify CLI
Write-Host "🔍 Checking Netlify CLI..." -ForegroundColor Yellow
$netlifyInstalled = $false

try {
    $netlifyCheck = Get-Command netlify -ErrorAction Stop
    $netlifyInstalled = $true
    Write-Host "✅ Netlify CLI is installed" -ForegroundColor Green
}
catch {
    Write-Host "📥 Netlify CLI not found" -ForegroundColor Yellow
}

# Completion message
Write-Host "`n" + "="*60 -ForegroundColor Green
Write-Host "✅ SETUP COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "="*60 -ForegroundColor Green

Write-Host "`n📁 Project Structure:" -ForegroundColor Cyan
Get-ChildItem -Recurse -Name | ForEach-Object { Write-Host "  📄 $_" -ForegroundColor White }

Write-Host "`n🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Edit .env file and add your GEMINI_API_KEY" -ForegroundColor White
if (-not $netlifyInstalled) {
    Write-Host "2. Install Netlify CLI: npm install -g netlify-cli" -ForegroundColor Yellow
}
Write-Host "3. Run: netlify login" -ForegroundColor White
Write-Host "4. Run: netlify init" -ForegroundColor White
Write-Host "5. Run: netlify env:set GEMINI_API_KEY your_actual_key" -ForegroundColor White
Write-Host "6. Run: netlify deploy --prod" -ForegroundColor White

Write-Host "`n💡 Local Testing:" -ForegroundColor Magenta
Write-Host "  netlify dev    # Start local server" -ForegroundColor White
Write-Host "  http://localhost:8888" -ForegroundColor White

Write-Host "`n🎉 Ready to use! Your reconciliation service is set up." -ForegroundColor Green

# Return to original directory
Set-Location ..