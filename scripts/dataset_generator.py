import json
import random
import os

def create_dataset_dir(env):
    """Ensures the dataset directory exists."""
    os.makedirs(f'../dataset/{env}', exist_ok=True)

def generate_mock_data(size=100):
    """Generates a large mock dataset for testing purposes."""
    dataset = []
    
    # Core entities
    core_entities = [
        {"name": "Apple Inc.", "query": "Apple"},
        {"name": "Microsoft Corp.", "query": "Microsoft"},
        {"name": "London", "query": "London"},
        {"name": "Albert Einstein", "query": "Einstein"},
        {"name": "The Godfather", "query": "Godfather"},
    ]

    # Expert Knowledge (Critical Fields)
    expert_entities = [
        {"name": "Myocardial Infarction", "query": "heart attack", "type": "medical_condition"},
        {"name": "Neural Network", "query": "backpropagation algorithm", "type": "AI"},
        {"name": "Quantum Entanglement", "query": "quantum entanglement", "type": "physics"},
        {"name": "Sarbanes-Oxley Act", "query": "SOX Act", "type": "legal"},
        {"name": "Gross Domestic Product", "query": "GDP", "type": "economics"},
    ]

    # Special Cases (Fine-Tuning)
    special_cases = [
        {"name": "The Flash (DC Comics)", "query": "Flash"},
        {"name": "Taylor Swift", "query": "Taylor Swift"},
        {"name": "Tyler Swift", "query": "Tyler Swift"},
        {"name": "The Lord of the Rings: The Fellowship of the Ring", "query": "Fellowship of the Ring"},
        {"name": "N.W.A.", "query": "NWA"}
    ]

    # Combine all data sources to create a rich dataset
    data_sources = [core_entities, expert_entities, special_cases]

    # Generate the requested number of data points
    for i in range(size):
        # Select a random entity type from our data sources
        source = random.choice(data_sources)
        item = random.choice(source).copy()

        # Introduce some variation (e.g., misspellings, new queries)
        if i % 5 == 0:
            item["query"] = f"A variant of {item['query']}"
        elif i % 7 == 0:
            item["query"] = item["query"].replace('e', 'ee').replace('a', 'aa')
        
        dataset.append(item)
    import json
import random
import os

def create_dataset_dir(env):
    """Ensures the dataset directory exists."""
    os.makedirs(f'../dataset/{env}', exist_ok=True)

def generate_mock_data(size=100):
    """Generates a large mock dataset for testing purposes."""
    dataset = []
    
    # Core entities
    core_entities = [
        {"name": "Apple Inc.", "query": "Apple"},
        {"name": "Microsoft Corp.", "query": "Microsoft"},
        {"name": "London", "query": "London"},
        {"name": "Albert Einstein", "query": "Einstein"},
        {"name": "The Godfather", "query": "Godfather"},
    ]

    # Expert Knowledge (Critical Fields)
    expert_entities = [
        {"name": "Myocardial Infarction", "query": "heart attack", "type": "medical_condition"},
        {"name": "Neural Network", "query": "backpropagation algorithm", "type": "AI"},
        {"name": "Quantum Entanglement", "query": "quantum entanglement", "type": "physics"},
        {"name": "Sarbanes-Oxley Act", "query": "SOX Act", "type": "legal"},
        {"name": "Gross Domestic Product", "query": "GDP", "type": "economics"},
    ]

    # Special Cases (Fine-Tuning)
    special_cases = [
        {"name": "The Flash (DC Comics)", "query": "Flash"},
        {"name": "Taylor Swift", "query": "Taylor Swift"},
        {"name": "Tyler Swift", "query": "Tyler Swift"},
        {"name": "The Lord of the Rings: The Fellowship of the Ring", "query": "Fellowship of the Ring"},
        {"name": "N.W.A.", "query": "NWA"}
    ]

    # Combine all data sources to create a rich dataset
    data_sources = [core_entities, expert_entities, special_cases]

    # Generate the requested number of data points
    for i in range(size):
        # Select a random entity type from our data sources
        source = random.choice(data_sources)
        item = random.choice(source).copy()

        # Introduce some variation (e.g., misspellings, new queries)
        if i % 5 == 0:
            item["query"] = f"A variant of {item['query']}"
        elif i % 7 == 0:
            item["query"] = item["query"].replace('e', 'ee').replace('a', 'aa')
        
        dataset.append(item)
    
    return dataset

def save_dataset(dataset, filename, env):
    """Saves the dataset to a JSON file in the specified environment directory."""
    create_dataset_dir(env)
    file_path = f'../dataset/{env}/{filename}.json'
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(dataset, f, indent=2)
    print(f"Saved {len(dataset)} items to {file_path}")

if __name__ == "__main__":
    # Generate a rich and diverse special dataset with 100 entries
    special_data = generate_mock_data(size=100)
    save_dataset(special_data, 'special-100-entries', 'special')

    # Example for other environments (e.g., development)
    # dev_data = generate_mock_data(size=100)
    # save_dataset(dev_data, 'dev-100-entries', 'development')
    

    return dataset

def save_dataset(dataset, filename, env):
    """Saves the dataset to a JSON file in the specified environment directory."""
    create_dataset_dir(env)
    file_path = f'../dataset/{env}/{filename}.json'
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(dataset, f, indent=2)
    print(f"Saved {len(dataset)} items to {file_path}")

if __name__ == "__main__":
    # Generate a rich and diverse special dataset with 100 entries
    special_data = generate_mock_data(size=100)
    save_dataset(special_data, 'special-100-entries', 'special')

    # Example for other environments (e.g., development)
    # dev_data = generate_mock_data(size=100)
    # save_dataset(dev_data, 'dev-100-entries', 'development')
    
