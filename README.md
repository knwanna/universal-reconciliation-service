# Step-by-Step Guide to Replicate the Universal Reconciliation Service

## Prerequisites
- Windows, macOS, or Linux machine
- Node.js 18+ installed
- Git installed
- Netlify account (for deployment)
- Google Gemini API key (optional)

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

### 1.3 Install Netlify CLI (Optional)
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

### 2.2 Create the Setup Script
Create a file named `setup_universal.ps1` (Windows) or `setup_universal.sh` (Linux/macOS) with the complete code provided earlier.

### 2.3 Run the Setup Script

**Windows:**
```powershell
# Enable script execution if needed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

# Run the setup script
.\setup_universal.ps1
```

**Linux/macOS:**
```bash
# Make the script executable
chmod +x setup_universal.sh

# Run the setup script
./setup_universal.sh
```

### 2.4 Verify Project Structure
After running the script, verify the project structure:
```
universal-reconciliation-service/
├── netlify/
│   └── functions/
│       └── api.js
├── public/
│   ├── index.html
│   └── test-runner.html
├── data/
│   ├── sample-people.json
│   ├── sample-organizations.json
│   ├── sample-locations.json
│   └── sample-books.json
├── tests/
│   ├── unit/
│   ├── integration/
│   └── performance/
├── scripts/
│   ├── test-with-curl.sh
│   ├── run-tests.sh
│   ├── analyze-datasets.js
│   └── export-postman-collection.js
├── package.json
├── netlify.toml
├── server.js
├── .env
└── README.md
```

---

## Step 3: Configuration

### 3.1 Environment Variables
Edit the `.env` file:
```bash
# Update with your Gemini API key (optional)
GEMINI_API_KEY=your_actual_gemini_api_key_here

# Adjust other settings as needed
NODE_ENV=development
PORT=8888
LOG_LEVEL=debug
```

### 3.2 Install Dependencies
```bash
# Install all npm dependencies
npm install
```

---

## Step 4: Local Testing

### 4.1 Start the Development Server
```bash
# Option 1: Using Netlify Dev
npm run dev

# Option 2: Using standalone Express server
npm start
```

### 4.2 Test the Application
Open your browser and navigate to:
- Main application: http://localhost:8888
- Test runner: http://localhost:8888/test-runner.html
- Health endpoint: http://localhost:8888/health

### 4.3 Run Comprehensive Tests
```bash
# Make test scripts executable (Linux/macOS)
chmod +x scripts/*.sh

# Run all tests
npm test

# Run specific test types
npm run test:unit
npm run test:integration
npm run test:performance

# Run with cURL
./scripts/test-with-curl.sh

# Run with built-in test runner
./scripts/run-tests.sh
```

### 4.4 Generate Postman Collections
```bash
# Generate Postman collections
npm run export-postman
```

---

## Step 5: Deployment to Netlify

### 5.1 Prepare for Deployment
```bash
# Build the project (if needed)
npm run build

# Test production build locally
npm run dev
```

### 5.2 Deploy to Netlify

**Option A: Using Netlify CLI**
```bash
# Login to Netlify
netlify login

# Initialize site
netlify init

# Deploy to production
netlify deploy --prod
```

**Option B: Using Git Repository**
1. Create a GitHub repository
2. Push your code to GitHub
3. Connect your repository to Netlify
4. Configure build settings in Netlify:
   - Build command: `npm run build`
   - Publish directory: `public`
   - Functions directory: `netlify/functions`

**Option C: Drag and Drop**
1. Run `npm run build`
2. Zip the project folder
3. Drag and drop to Netlify deploy area

### 5.3 Configure Environment Variables in Netlify
1. Go to your site in Netlify dashboard
2. Navigate to Site settings > Environment variables
3. Add your environment variables:
   - `GEMINI_API_KEY`
   - `NODE_ENV=production`
   - Any other required variables

---

## Step 6: Post-Deployment Verification

### 6.1 Test Production Endpoints
```bash
# Replace with your actual Netlify URL
PRODUCTION_URL="https://your-site.netlify.app"

# Test health endpoint
curl "$PRODUCTION_URL/.netlify/functions/api/health"

# Test reconciliation
curl -X POST "$PRODUCTION_URL/.netlify/functions/api/reconcile" \
  -H "Content-Type: application/json" \
  -d '{"query":"Albert Einstein","type":"person","limit":3}'
```

### 6.2 Monitor Performance
Check Netlify functions dashboard for:
- Function invocation counts
- Execution durations
- Error rates

### 6.3 Set Up Monitoring (Optional)
```bash
# Add monitoring services to .env
SENTRY_DSN=your_sentry_dsn_here
LOGGLY_TOKEN=your_loggly_token_here
```

---

## Step 7: Maintenance and Updates

### 7.1 Regular Testing
```bash
# Run tests regularly
npm test

# Update test data as needed
node scripts/analyze-datasets.js
```

### 7.2 Update Dependencies
```bash
# Check for outdated packages
npm outdated

# Update packages
npm update

# Update specific packages
npm install package-name@latest
```

### 7.3 Backup Important Data
```bash
# Backup datasets
cp -r data/ backup-data/

# Backup environment configuration
cp .env backup.env
```

---

## Troubleshooting Common Issues

### Port Already in Use
```bash
# Find process using port 8888
lsof -i :8888

# Kill the process (replace PID with actual process ID)
kill -9 PID

# Or use a different port
PORT=8889 npm start
```

### Netlify Deployment Issues
1. Check Netlify build logs
2. Verify `netlify.toml` configuration
3. Ensure all required files are committed to Git

### API Key Issues
1. Verify Gemini API key is correct
2. Check API quota and billing
3. Test without API key (fallback should work)

### Function Timeouts
1. Check Netlify function timeout settings
2. Optimize code for better performance
3. Add caching where possible

---

## Quick Reference Commands

```bash
# Development
npm run dev          # Start Netlify dev
npm start           # Start standalone server

# Testing
npm test            # Run all tests
npm run test:unit   # Run unit tests
npm run test:integration  # Run integration tests
npm run test:performance # Run performance tests

# Deployment
netlify deploy      # Deploy to staging
netlify deploy --prod  # Deploy to production

# Maintenance
npm update          # Update dependencies
node scripts/analyze-datasets.js  # Analyze data
```

This step-by-step guide will help you replicate the Universal Reconciliation Service on any machine. The process is designed to be straightforward and includes all necessary components for local development, testing, and production deployment.