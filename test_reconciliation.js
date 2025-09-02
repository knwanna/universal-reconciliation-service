import { promises as fs } from 'fs';
import path from 'path';

// --- Configuration ---
// Set the base URL for your reconciliation service here.
// NOTE: This is a placeholder. You must replace it with the actual URL of your service.
const SERVICE_URL = "http://localhost:5000/reconcile";
const DATASET_DIR = "dataset";
const PRODUCTION_DIR = path.join(DATASET_DIR, "production");
const DEVELOPMENT_DIR = path.join(DATASET_DIR, "development");

/**
 * Loads a JSON dataset, sends reconciliation queries, and prints the results.
 *
 * @param {string} filePath The path to the JSON dataset file.
 * @param {string} serviceUrl The URL of the reconciliation service endpoint.
 */
async function runReconciliationTest(filePath, serviceUrl) {
    console.log(\n--- Testing dataset: \ ---);

    let testData;
    // Load the test data from the JSON file.
    try {
        const fileContent = await fs.readFile(filePath, 'utf-8');
        testData = JSON.parse(fileContent);
    } catch (error) {
        if (error.code === 'ENOENT') {
            console.error(ERROR: File not found at \);
        } else {
            console.error(ERROR: Invalid JSON in file at \);
            console.error(error.message);
        }
        return;
    }

    // Prepare a list of queries for the API call.
    const queries = {};
    testData.forEach((item, i) => {
        // We use a unique key for each query (e.g., "q0", "q1", ...)
        queries[q\] = { "query": item.query || "" };
    });

    // Send the request to the reconciliation service.
    try {
        const response = await fetch(serviceUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ queries: JSON.stringify(queries) })
        });

        if (!response.ok) {
            throw new Error(HTTP error! Status: \);
        }

        const apiResults = await response.json();

        // Process and validate the results.
        testData.forEach((item, i) => {
            const queryKey = q\;
            
            // Check if the API returned a result for this query.
            if (!apiResults[queryKey]) {
                console.log(FAIL: '\' - No result found for query key '\');
                return;
            }

            const queryResult = apiResults[queryKey].result || [];
            
            // Check if the result list is not empty.
            if (queryResult.length === 0) {
                console.log(FAIL: '\' - Result list is empty);
                return;
            }

            // Simple validation: Check if the top candidate's name matches the expected name.
            const topCandidate = queryResult[0];
            const reconciledName = topCandidate.name || "";
            const expectedName = item.name || "";

            // A successful match.
            if (reconciledName === expectedName) {
                console.log(SUCCESS: '\' -> '\');
            } else {
                console.log(FAIL: '\' - Expected '\', got '\');
            }
        });

    } catch (error) {
        console.error(ERROR: Failed to connect to service at \. Please ensure the service is running.);
        console.error(Exception: \);
    }
}

async function main() {
    console.log("Starting reconciliation service test suite...");
    console.log("------------------------------------------");

    const allFiles = [];

    // Get a list of all JSON files in the development and production directories.
    try {
        if (await fs.stat(DEVELOPMENT_DIR).then(() => true).catch(() => false)) {
            const devFiles = (await fs.readdir(DEVELOPMENT_DIR)).filter(filename => filename.endsWith(".json"));
            allFiles.push(...devFiles.map(file => path.join(DEVELOPMENT_DIR, file)));
        }
    } catch (e) { /* directory does not exist */ }

    try {
        if (await fs.stat(PRODUCTION_DIR).then(() => true).catch(() => false)) {
            const prodFiles = (await fs.readdir(PRODUCTION_DIR)).filter(filename => filename.endsWith(".json"));
            allFiles.push(...prodFiles.map(file => path.join(PRODUCTION_DIR, file)));
        }
    } catch (e) { /* directory does not exist */ }

    if (allFiles.length === 0) {
        console.log("No test dataset files found. Please run the generation scripts first.");
        return;
    }

    // Run the tests for each discovered file.
    for (const file of allFiles) {
        await runReconciliationTest(file, SERVICE_URL);
    }
}

main();
