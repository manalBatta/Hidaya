import json
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity

# Load embedded JSONL file
with open(r"C:\Users\manal\Desktop\Hidaya\Python\dataset\embedded_dataset_local.jsonl", "r", encoding="utf-8") as f:
    data = [json.loads(line) for line in f]

# Create lists for vectors and metadata
vectors = []
metadata = []

for item in data:
    embedding = item.get("embedding")
    if embedding:
        vectors.append(np.array(embedding, dtype=np.float32))
        metadata.append(item)
    else:
        print(f"⚠️ No embedding found for item {item.get('id', 'unknown')}")

# Convert to NumPy array
embedding_matrix = np.stack(vectors)

print(f"✅ Loaded {len(metadata)} embeddings with dimension {embedding_matrix.shape[1]}")

# Save metadata for later use
with open("search_metadata.json", "w", encoding="utf-8") as f:
    json.dump(metadata, f, ensure_ascii=False, indent=2)

print("✅ Metadata saved to search_metadata.json")

# Example search function
def search_similar(query_embedding, top_k=3):
    """Search for similar embeddings using cosine similarity"""
    query_vector = np.array([query_embedding], dtype=np.float32)
    
    # Calculate cosine similarity
    similarities = cosine_similarity(query_vector, embedding_matrix)[0]
    
    # Get top k indices
    top_indices = np.argsort(similarities)[::-1][:top_k]
    
    results = []
    for idx in top_indices:
        results.append({
            'text': metadata[idx]['text'],
            'id': metadata[idx]['id'],
            'similarity': float(similarities[idx]),
            'metadata': metadata[idx]
        })
    
    return results

print("🔍 Search function ready! Use search_similar(query_embedding, top_k=3) to search")

