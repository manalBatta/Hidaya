import json
import numpy as np
from sentence_transformers import SentenceTransformer

# Initialize sentence-transformers model
model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')

# Load the search function and data
def load_search_data():
    """Load the search data and function"""
    # Import the search function from the other file
    import sys
    import os
    sys.path.append(os.path.dirname(__file__))
    
    # Load metadata
    with open(r"C:\Users\manal\Desktop\Hidaya\Python\search_metadata.json", "r", encoding="utf-8") as f:
        metadata = json.load(f)
    
    # Load embedding matrix
    vectors = []
    for item in metadata:
        vectors.append(np.array(item["embedding"], dtype=np.float32))
    
    embedding_matrix = np.stack(vectors)
    
    return metadata, embedding_matrix

def search_similar(query_embedding, embedding_matrix, metadata, top_k=3):
    """Search for similar embeddings using cosine similarity"""
    from sklearn.metrics.pairwise import cosine_similarity
    
    query_vector = np.array([query_embedding], dtype=np.float32)
    
    # Check dimensions
    if query_vector.shape[1] != embedding_matrix.shape[1]:
        print(f"❌ Dimension mismatch: Query has {query_vector.shape[1]} dimensions, but stored embeddings have {embedding_matrix.shape[1]} dimensions")
        return []
    
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

def embed_query(query_text, target_dimension):
    """Embed a query text using sentence-transformers"""
    print(f"🔧 Using sentence-transformers model for {target_dimension} dimensions")
    
    try:
        # Use the same model that was used for the original embeddings
        embedding = model.encode(query_text).tolist()
        
        if embedding:
            print(f"✅ Generated embedding with {len(embedding)} dimensions")
            return embedding
        else:
            print("❌ No embedding generated for query")
            return None
            
    except Exception as e:
        print(f"❌ Error embedding query: {e}")
        return None

def search_and_display(query_text, top_k=3):
    """Search for similar texts and display results"""
    print(f"🔍 Searching for: '{query_text}'")
    print("=" * 50)
    
    # Load data
    metadata, embedding_matrix = load_search_data()
    target_dimension = embedding_matrix.shape[1]
    print(f"📊 Target embedding dimension: {target_dimension}")
    
    # Embed the query
    query_embedding = embed_query(query_text, target_dimension)
    if not query_embedding:
        return
    
    # Search for similar texts
    results = search_similar(query_embedding, embedding_matrix, metadata, top_k)
    
    if not results:
        print("❌ No results found (dimension mismatch)")
        return
    
    # Display results
    for i, result in enumerate(results, 1):
        print(f"\n{i}. 📖 {result['text'][:100]}...")
        print(f"   🆔 ID: {result['id']}")
        print(f"   📊 Similarity: {result['similarity']:.3f}")
        if result['metadata'].get('type'):
            print(f"   📝 Type: {result['metadata']['type']}")
        if result['metadata'].get('surah'):
            print(f"   📚 Surah: {result['metadata']['surah']}")
        if result['metadata'].get('ayah_no'):
            print(f"   🎯 Ayah: {result['metadata']['ayah_no']}")
    
    print("\n" + "=" * 50)

# Example usage
if __name__ == "__main__":
    print("🚀 Quran & Hadith Search Engine")
    print("=" * 50)
    
    # Example queries
    example_queries = [
        "من هو الله؟",
        "ما هو الإسلام؟",
        "كيف نصلي؟",
        "ما هي أركان الإسلام؟",
        "فضل الصدقة"
    ]
    
    print("📝 Example queries:")
    for i, query in enumerate(example_queries, 1):
        print(f"   {i}. {query}")
    
    print("\n" + "=" * 50)
    
    # Search for each example
    for query in example_queries:
        search_and_display(query, top_k=3)
        print("\n" + "=" * 50)
    
    # Interactive search
    print("\n🎯 Interactive Search Mode")
    print("Type 'quit' to exit")
    
    while True:
        user_query = input("\n🔍 Enter your search query: ").strip()
        if user_query.lower() == 'quit':
            break
        if user_query:
            search_and_display(user_query, top_k=3) 