# Step-by-Step Guide to Replicate the Universal Reconciliation Service

## Prerequisites
- Windows, macOS, or Linux machine
- Node.js 18+ installed
- Git installed
- Netlify account (for deployment)
- Google Gemini API key

---

## Step 1: Environment Setup

### 1.1 Install Node.js
```bash
# Check if Node.js is installed
node --version
npm --version

# If not installed, download from: https://nodejs.org/
```

### 1.2 Install Git
```bash
# Check if Git is installed
git --version

# If not installed, download from: https://git-scm.com/
```

### 1.3 Install Netlify CLI
```bash
# Install Netlify CLI globally
npm install -g netlify-cli

# Verify installation
netlify --version
```

---

## Step 2: Project Setup

### 2.1 Create Project Directory
```bash
# Create and navigate to project directory
mkdir universal-reconciliation-service
cd universal-reconciliation-service
```

### 2.2 Initialize Project
```bash
# Initialize npm project
npm init -y

# Create directory structure
mkdir -p src/local/routes src/functions src/shared tests/local tests/functions public data/development data/production
```

### 2.3 Create Essential Files
Create the following files with the code provided in the previous implementation:

**Root Files:**
- `.env.example`
- `.gitignore`
- `netlify.toml`
- `package.json`
- `README.md`
- `LICENSE`

**Source Files:**
- `src/local/server.js`
- `src/local/routes/reconcile.js`
- `src/local/routes/suggest.js`
- `src/local/routes/preview.js`
- `src/local/routes/extend.js`
- `src/local/routes/metadata.js`
- `src/functions/api.js`
- `src/functions/reconcile.js`
- `src/functions/suggest.js`
- `src/functions/preview.js`
- `src/functions/extend.js`
- `src/functions/metadata.js`
- `src/shared/gemini-service.js`
- `src/shared/utils.js`
- `src/shared/validation.js`

**Test Files:**
- `tests/local/reconcile.test.js`
- `tests/local/suggest.test.js`
- `tests/functions/reconcile.test.js`
- `tests/functions/suggest.test.js`

**Public Files:**
- `public/index.html`

**Data Files:**
- `data/development/scientists.json`
- `data/development/companies.json`
- `data/production/sample-data.json`

### 2.4 Install Dependencies
```bash
# Install production dependencies
npm install express cors body-parser helmet compression joi winston dotenv @google/generative-ai uuid

# Install development dependencies
npm install --save-dev netlify-cli jest eslint supertest
```

---

## Step 3: Configuration

### 3.1 Environment Setup
```bash
# Copy environment example file
cp .env.example .env

# Edit .env file with your actual values
# Add your Gemini API key and other configuration
```

### 3.2 Configure Netlify
```bash
# Login to Netlify
netlify login

# Initialize Netlify in your project
netlify init
```

---

## Step 4: Local Development

### 4.1 Start Local Server
```bash
# Start the local Express server
npm run dev

# The server will start on http://localhost:3000
```

### 4.2 Test Local Endpoints
```bash
# Test health endpoint
curl http://localhost:3000/api/health

# Test reconciliation endpoint
curl -X POST http://localhost:3000/api/reconcile \
  -H "Content-Type: application/json" \
  -d '{"queries":{"q0":{"query":"Albert Einstein","type":"scientist"}}}'
```

### 4.3 Run Tests
```bash
# Run all tests
npm test

# Run only local tests
npm run test:local

# Run only function tests
npm run test:functions
```

---

## Step 5: Netlify Development

### 5.1 Start Netlify Dev
```bash
# Start Netlify development environment
npm run dev:netlify

# This will start on http://localhost:8888
```

### 5.2 Test Netlify Functions
```bash
# Test Netlify health endpoint
curl http://localhost:8888/.netlify/functions/api/health

# Test Netlify reconciliation
curl -X POST http://localhost:8888/.netlify/functions/api/reconcile \
  -H "Content-Type: application/json" \
  -d '{"queries":{"q0":{"query":"Albert Einstein","type":"scientist"}}}'
```

---

## Step 6: Deployment

### 6.1 Deploy to Netlify
```bash
# Deploy to Netlify
npm run deploy

# Or use Netlify CLI directly
netlify deploy --prod
```

### 6.2 Configure Environment Variables in Netlify
1. Go to your Netlify dashboard
2. Select your site
3. Go to Site settings > Environment variables
4. Add your environment variables:
   - `GEMINI_API_KEY=your_actual_api_key`
   - `NODE_ENV=production`
   - Any other required variables

### 6.3 Verify Deployment
```bash
# Test production endpoints
curl https://universal-reconciliation-service.netlify.app/.netlify/functions/api/health

# Test production reconciliation
curl -X POST https://universal-reconciliation-service.netlify.app/.netlify/functions/api/reconcile \
  -H "Content-Type: application/json" \
  -d '{"queries":{"q0":{"query":"Albert Einstein","type":"scientist"}}}'
```

---

## Step 7: Advanced Configuration

### 7.1 Custom Domain (Optional)
1. In Netlify dashboard, go to Domain management
2. Add your custom domain
3. Configure DNS settings as instructed

### 7.2 Monitoring and Analytics (Optional)
```bash
# Add monitoring packages
npm install express-status-monitor
```

### 7.3 Rate Limiting (Optional)
```bash
# Add rate limiting package
npm install express-rate-limit
```

---

## Step 8: Maintenance

### 8.1 Update Dependencies
```bash
# Check for outdated packages
npm outdated

# Update packages
npm update

# Update specific packages
npm install package-name@latest
```

### 8.2 Monitor Logs
```bash
# View Netlify function logs
netlify logs

# View specific function logs
netlify logs --function reconcile
```

### 8.3 Backup Configuration
```bash
# Backup important files
cp .env .env.backup
cp netlify.toml netlify.toml.backup
```

---

## Troubleshooting

### Common Issues and Solutions

1. **Gemini API Errors**
   - Verify your API key is correct
   - Check your API quota
   - Ensure billing is set up

2. **Netlify Deployment Failures**
   - Check `netlify.toml` configuration
   - Verify all required files are committed
   - Check build logs in Netlify dashboard

3. **Function Timeouts**
   - Optimize code for faster execution
   - Consider increasing timeout in `netlify.toml`

4. **CORS Issues**
   - Verify CORS configuration in both local and Netlify environments
   - Check allowed origins

5. **Environment Variables**
   - Ensure all required variables are set in both `.env` and Netlify dashboard
   - Restart Netlify dev after changing `.env`

---

## Support

If you encounter issues:

1. Check the logs: `netlify logs`
2. Verify all setup steps were completed
3. Ensure all dependencies are installed
4. Confirm environment variables are set correctly
5. Check the Netlify status page for outages

For additional help, refer to:
- Netlify documentation: https://docs.netlify.com/
- Google Gemini documentation: https://ai.google.dev/
- Express.js documentation: https://expressjs.com/

This step-by-step guide will help you successfully replicate and deploy the Universal Reconciliation Service with advanced AI integration and dual-environment support.