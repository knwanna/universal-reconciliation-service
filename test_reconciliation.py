import os
import json
import requests
from typing import Dict, List, Any

# --- Configuration ---
# Set the base URL for your reconciliation service here.
# NOTE: This is a placeholder. You must replace it with the actual URL of your service.
SERVICE_URL = "http://localhost:5000/reconcile"
DATASET_DIR = "dataset"
PRODUCTION_DIR = os.path.join(DATASET_DIR, "production")
DEVELOPMENT_DIR = os.path.join(DATASET_DIR, "development")

def run_reconciliation_test(file_path: str, service_url: str):
    """
    Loads a JSON dataset, sends reconciliation queries, and prints the results.

    Args:
        file_path (str): The path to the JSON dataset file.
        service_url (str): The URL of the reconciliation service endpoint.
    """
    print(f"\n--- Testing dataset: {os.path.basename(file_path)} ---")
    
    # Load the test data from the JSON file.
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            test_data = json.load(f)
    except FileNotFoundError:
        print(f"ERROR: File not found at {file_path}")
        return
    except json.JSONDecodeError:
        print(f"ERROR: Invalid JSON in file at {file_path}")
        return

    # Prepare a list of queries for the API call.
    queries: Dict[str, Dict[str, str]] = {}
    for i, item in enumerate(test_data):
        # We use a unique key for each query (e.g., "q0", "q1", ...)
        queries[f"q{i}"] = {"query": item.get("query", "")}

    # Construct the payload for the POST request.
    payload = {"queries": json.dumps(queries)}

    # Send the request to the reconciliation service.
    try:
        response = requests.post(service_url, data=payload)
        response.raise_for_status()  # Raises an HTTPError for bad responses (4xx or 5xx)
        api_results: Dict[str, Any] = response.json()
    except requests.exceptions.RequestException as e:
        print(f"ERROR: Failed to connect to service at {service_url}. Please ensure the service is running.")
        print(f"Exception: {e}")
        return
    except json.JSONDecodeError:
        print("ERROR: Invalid JSON response from the API.")
        print("Response content:", response.text)
        return

    # Process and validate the results.
    for i, item in enumerate(test_data):
        query_key = f"q{i}"
        
        # Check if the API returned a result for this query.
        if query_key not in api_results:
            print(f"FAIL: '{item['query']}' - No result found for query key '{query_key}'")
            continue

        query_result = api_results[query_key].get("result", [])
        
        # Check if the result list is not empty.
        if not query_result:
            print(f"FAIL: '{item['query']}' - Result list is empty")
            continue

        # Simple validation: Check if the top candidate's name matches the expected name.
        top_candidate = query_result[0]
        reconciled_name = top_candidate.get("name", "")
        expected_name = item.get("name", "")

        # A successful match.
        if reconciled_name == expected_name:
            print(f"SUCCESS: '{item['query']}' -> '{reconciled_name}'")
        else:
            print(f"FAIL: '{item['query']}' - Expected '{expected_name}', got '{reconciled_name}'")

def main():
    """
    Main function to discover and run all test scripts.
    """
    print("Starting reconciliation service test suite...")
    print("------------------------------------------")

    # Get a list of all JSON files in the development and production directories.
    all_files = []
    if os.path.exists(DEVELOPMENT_DIR):
        for filename in os.listdir(DEVELOPMENT_DIR):
            if filename.endswith(".json"):
                all_files.append(os.path.join(DEVELOPMENT_DIR, filename))
    
    if os.path.exists(PRODUCTION_DIR):
        for filename in os.listdir(PRODUCTION_DIR):
            if filename.endswith(".json"):
                all_files.append(os.path.join(PRODUCTION_DIR, filename))
    
    if not all_files:
        print("No test dataset files found. Please run the generation scripts first.")
        return

    # Run the tests for each discovered file.
    for file in all_files:
        run_reconciliation_test(file, SERVICE_URL)

if __name__ == "__main__":
    main()
