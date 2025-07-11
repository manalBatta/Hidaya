import json
import numpy as np
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
from google import genai
from google.genai import types

# === CONFIG ===
GOOGLE_API_KEY = "AIzaSyCNZeyrlbX5lXBgcj0o7CMaV50iUM_8ECQ"  # Replace with your Gemini API key
EMBEDDED_METADATA_PATH = r"C:\Users\manal\Desktop\Hidaya\Python\search_metadata.json"

# Initialize Gemini client
client = genai.Client(api_key=GOOGLE_API_KEY)

# Load Sentence Transformer model once
model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')

def load_search_data():
    """Load the embedded metadata and embedding matrix"""
    with open(EMBEDDED_METADATA_PATH, "r", encoding="utf-8") as f:
        metadata = json.load(f)
    vectors = [np.array(item["embedding"], dtype=np.float32) for item in metadata]
    embedding_matrix = np.stack(vectors)
    return metadata, embedding_matrix

def embed_query(query_text, target_dimension):
    """Embed the user query text with sentence-transformers"""
    embedding = model.encode(query_text).tolist()
    if len(embedding) != target_dimension:
        print(f"⚠️ Warning: embedding dimension mismatch ({len(embedding)} vs {target_dimension})")
    return embedding

def search_similar(query_embedding, embedding_matrix, metadata, top_k=3):
    """Return top_k most similar texts from dataset"""
    query_vector = np.array([query_embedding], dtype=np.float32)
    similarities = cosine_similarity(query_vector, embedding_matrix)[0]
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

def get_context_for_query(query_text):
    """Search and return concatenated top 3 relevant verses as context"""
    metadata, embedding_matrix = load_search_data()
    target_dim = embedding_matrix.shape[1]
    query_embedding = embed_query(query_text, target_dim)
    results = search_similar(query_embedding, embedding_matrix, metadata, top_k=3)
    context = "\n".join([r['text'] for r in results])
    return context

def ask_gemini_with_context(query_text):
    """Send query + context to Gemini and get an answer"""
    context = get_context_for_query(query_text)
    prompt = f"""أجب عن السؤال التالي بشكل دقيق ومبني فقط على المعلومات التالية من القرآن الكريم:

{context}

السؤال: {query_text}
"""
    response = client.chat.completions.create(
        model="gemini-1-turbo",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.3,
        max_tokens=500,
    )
    answer = response.choices[0].message.content.strip()
    return answer

def interactive_qa():
    print("🚀 Quran Q&A Assistant using Google Gemini")
    print("Type 'exit' or 'quit' to end.\n")
    while True:
        query = input("📝 اطرح سؤالك: ").strip()
        if query.lower() in ["exit", "quit"]:
            print("وداعاً!")
            break
        if not query:
            continue
        print("\n⏳ يتم البحث والإجابة...\n")
        try:
            answer = ask_gemini_with_context(query)
            print(f"💡 الإجابة:\n{answer}\n")
        except Exception as e:
            print(f"❌ خطأ في المعالجة: {e}")

if __name__ == "__main__":
    interactive_qa()
