# Python Modules Documentation

## Overview

This document provides comprehensive documentation for all Python modules and utilities used in the Hidaya project. These modules primarily handle Islamic content processing, semantic search, AI integration, and data transformation.

## Module Structure

```
Python/
├── search_example.py          # Semantic search implementation
├── qur.py                     # Quran Q&A with AI integration
├── csv_to_json.py            # Data format conversion utility
├── load_into_chormeDB.py     # Database loading utility
├── embedding_jsonl_combined_file.py  # Embedding generation
├── search_metadata.json      # Preprocessed search metadata (68MB)
├── dataset/                  # Islamic content datasets
└── LangChain/
    └── connect.py            # LangChain AI model connection
```

## Core Modules

### 1. Search Engine Module

**File:** `search_example.py`

**Purpose:** Implements semantic search functionality for Islamic content using sentence transformers and cosine similarity.

#### Key Components

##### Model Initialization
```python
from sentence_transformers import SentenceTransformer
model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')
```

##### Core Functions

###### `load_search_data()`
Loads preprocessed embeddings and metadata for search operations.

**Returns:**
- `metadata` (list): List of content metadata
- `embedding_matrix` (numpy.ndarray): Matrix of embeddings

**Usage:**
```python
metadata, embedding_matrix = load_search_data()
print(f"Loaded {len(metadata)} entries with {embedding_matrix.shape[1]} dimensions")
```

###### `search_similar(query_embedding, embedding_matrix, metadata, top_k=3)`
Performs semantic search using cosine similarity.

**Parameters:**
- `query_embedding` (list): Embedded query vector
- `embedding_matrix` (numpy.ndarray): Precomputed embeddings
- `metadata` (list): Content metadata
- `top_k` (int): Number of results to return

**Returns:**
- `results` (list): List of similar content with similarity scores

**Example:**
```python
query_embedding = embed_query("What is Islam?", target_dimension=384)
results = search_similar(query_embedding, embedding_matrix, metadata, top_k=5)

for result in results:
    print(f"Text: {result['text'][:100]}...")
    print(f"Similarity: {result['similarity']:.3f}")
    print(f"Type: {result['metadata']['type']}")
```

###### `embed_query(query_text, target_dimension)`
Converts text query to embedding vector.

**Parameters:**
- `query_text` (str): Input text to embed
- `target_dimension` (int): Expected embedding dimension

**Returns:**
- `embedding` (list): Query embedding vector

**Usage:**
```python
embedding = embed_query("ما هي أركان الإسلام؟", 384)
if embedding:
    print(f"Generated {len(embedding)}-dimensional embedding")
```

###### `search_and_display(query_text, top_k=3)`
End-to-end search function with formatted output.

**Parameters:**
- `query_text` (str): Search query
- `top_k` (int): Number of results to display

**Example Usage:**
```python
# Search for Islamic content
search_and_display("من هو الله؟", top_k=3)
search_and_display("كيف نصلي؟", top_k=5)
search_and_display("فضل الصدقة", top_k=3)
```

#### Interactive Mode
The module supports interactive searching:

```python
if __name__ == "__main__":
    print("🚀 Quran & Hadith Search Engine")
    
    # Interactive search loop
    while True:
        user_query = input("🔍 Enter your search query: ").strip()
        if user_query.lower() == 'quit':
            break
        if user_query:
            search_and_display(user_query, top_k=3)
```

### 2. Quran Q&A Module

**File:** `qur.py`

**Purpose:** Provides AI-powered question answering based on Quran and Hadith content using Google Gemini API.

#### Configuration
```python
GOOGLE_API_KEY = "your_gemini_api_key"
EMBEDDED_METADATA_PATH = "path/to/search_metadata.json"

# Initialize Gemini client
from google import genai
client = genai.Client(api_key=GOOGLE_API_KEY)
```

#### Core Functions

###### `get_context_for_query(query_text)`
Retrieves relevant Islamic content as context for AI responses.

**Parameters:**
- `query_text` (str): User's question

**Returns:**
- `context` (str): Concatenated relevant verses/hadith

**Process:**
1. Embed the query using sentence transformers
2. Search for top 3 most similar content pieces
3. Concatenate results as context

```python
context = get_context_for_query("ما هو الإسلام؟")
print(f"Retrieved context: {context[:200]}...")
```

###### `ask_gemini_with_context(query_text)`
Sends query with Islamic context to Google Gemini for accurate responses.

**Parameters:**
- `query_text` (str): User's question in Arabic

**Returns:**
- `answer` (str): AI-generated response based on Islamic sources

**Implementation:**
```python
def ask_gemini_with_context(query_text):
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
    return response.choices[0].message.content.strip()
```

**Usage Example:**
```python
answer = ask_gemini_with_context("ما هي أركان الإسلام؟")
print(f"الإجابة: {answer}")
```

###### `interactive_qa()`
Provides interactive Q&A session.

**Features:**
- Continuous question-answer loop
- Arabic language support
- Error handling
- Graceful exit commands

```python
# Start interactive session
interactive_qa()

# Example interaction:
# 📝 اطرح سؤالك: ما هو الإسلام؟
# ⏳ يتم البحث والإجابة...
# 💡 الإجابة: الإسلام هو دين التوحيد...
```

### 3. Data Conversion Module

**File:** `csv_to_json.py`

**Purpose:** Converts various Islamic datasets from CSV format to unified JSONL format for processing.

#### Supported Datasets

1. **Quran Ayat** (`quran.csv`)
2. **Surah Information** (`surah_info.csv`)
3. **Tafsir Al-Jalalayn** (`Tafsir_al-Jalalayn_tafseer.csv`)
4. **English Translation** (`The Quran Dataset.csv`)
5. **Hadith Narrators** (`kaggle_rawis.csv`)
6. **Hadith Collection** (`kaggle_hadiths_clean.csv`)

#### Data Structures

###### Quran Ayah Entry
```python
{
    "type": "quran_ayah",
    "id": "q-{surah_no}-{ayah_no}",
    "text": "Arabic text of the verse",
    "surah": "Surah name",
    "surah_no": 1,
    "ayah_no": 1,
    "words": ["word1", "word2", ...]
}
```

###### Surah Information Entry
```python
{
    "type": "surah_info",
    "surah_no": 1,
    "english_title": "The Opening",
    "arabic_title": "الفاتحة",
    "roman_title": "Al-Fatiha",
    "number_of_verses": 7,
    "number_of_rukus": "1",
    "place_of_revelation": "Mecca"
}
```

###### Hadith Entry
```python
{
    "type": "hadith",
    "id": "hadith_id",
    "hadith_id": "unique_identifier",
    "source": "Bukhari/Muslim/etc",
    "chapter_no": "chapter_number",
    "hadith_no": "hadith_number",
    "chapter": "Chapter name",
    "chain_indx": "chain_index",
    "text_ar": "Arabic hadith text",
    "text_en": "English hadith text"
}
```

#### Usage
```python
# Run the conversion script
python csv_to_json.py

# Output: combined_dataset.jsonl with all Islamic content
```

#### Error Handling
The module includes robust error handling for data inconsistencies:

```python
try:
    surah_no = int(row["SurahNumber"].strip().strip("'\""))
except (ValueError, AttributeError):
    print(f"Warning: Invalid SurahNumber value: {row['SurahNumber']}")
    surah_no = 0
```

### 4. Database Loading Module

**File:** `load_into_chormeDB.py`

**Purpose:** Loads embedded dataset into searchable format and provides search functionality.

#### Core Functions

###### Data Loading
```python
# Load embedded JSONL file
with open("embedded_dataset_local.jsonl", "r", encoding="utf-8") as f:
    data = [json.loads(line) for line in f]

# Separate vectors and metadata
vectors = []
metadata = []

for item in data:
    embedding = item.get("embedding")
    if embedding:
        vectors.append(np.array(embedding, dtype=np.float32))
        metadata.append(item)
```

###### Search Function
```python
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
```

#### Output
- Creates `search_metadata.json` for fast retrieval
- Provides ready-to-use search function
- Supports similarity-based content discovery

### 5. LangChain Integration

**File:** `LangChain/connect.py`

**Purpose:** Establishes connection to Google Gemini through LangChain framework.

#### Setup
```python
import getpass
import os
from dotenv import load_dotenv

load_dotenv()  # Load environment variables

# API key configuration
if not os.environ.get("GEMINI_API_KEY"):
    os.environ["GEMINI_API_KEY"] = getpass.getpass("Enter API key for Google Gemini: ")

# Initialize model
from langchain.chat_models import init_chat_model
model = init_chat_model("gemini-2.0-flash", model_provider="google_genai")
```

#### Usage
```python
# Simple model invocation
response = model.invoke("Hello, world!")
print(response)

# For Islamic Q&A integration
response = model.invoke("Explain the concept of Tawhid in Islam")
```

## API Integration

### Backend Integration

The Python modules integrate with the Node.js backend through the AI services:

**File:** `backend/services/langchainGemini.js`

```javascript
// Example integration pattern
const { spawn } = require('child_process');

async function queryIslamicContent(question) {
    return new Promise((resolve, reject) => {
        const pythonProcess = spawn('python', ['Python/qur.py'], {
            stdio: ['pipe', 'pipe', 'pipe']
        });
        
        pythonProcess.stdin.write(question);
        pythonProcess.stdin.end();
        
        let result = '';
        pythonProcess.stdout.on('data', (data) => {
            result += data.toString();
        });
        
        pythonProcess.on('close', (code) => {
            if (code === 0) {
                resolve(result.trim());
            } else {
                reject(new Error(`Python process exited with code ${code}`));
            }
        });
    });
}
```

## Performance Considerations

### Optimization Strategies

1. **Embedding Caching**
   - Pre-compute embeddings for all content
   - Store in optimized format (numpy arrays)
   - Use memory mapping for large datasets

2. **Search Optimization**
   - Use approximate nearest neighbor for large datasets
   - Implement query caching
   - Batch processing for multiple queries

3. **Memory Management**
   - Load embeddings once on startup
   - Use generators for large file processing
   - Implement garbage collection for long-running processes

### Example Optimizations

```python
# Efficient batch processing
def process_queries_batch(queries, batch_size=100):
    results = []
    for i in range(0, len(queries), batch_size):
        batch = queries[i:i + batch_size]
        batch_embeddings = model.encode(batch)
        
        for j, embedding in enumerate(batch_embeddings):
            query_results = search_similar(embedding, top_k=3)
            results.append(query_results)
    
    return results

# Memory-efficient file processing
def process_large_dataset(file_path):
    with open(file_path, 'r') as f:
        for line_num, line in enumerate(f):
            if line_num % 10000 == 0:
                print(f"Processed {line_num} lines")
            
            data = json.loads(line)
            yield process_item(data)
```

## Testing

### Unit Tests Example

```python
import unittest
from unittest.mock import patch, MagicMock

class TestSearchModule(unittest.TestCase):
    
    def setUp(self):
        self.sample_metadata = [
            {
                "id": "test1",
                "text": "Test Islamic content",
                "type": "quran_ayah",
                "surah": "Al-Fatiha"
            }
        ]
        self.sample_embedding = [0.1, 0.2, 0.3]
    
    def test_embed_query(self):
        """Test query embedding generation"""
        with patch('search_example.model.encode') as mock_encode:
            mock_encode.return_value = self.sample_embedding
            
            result = embed_query("test query", 3)
            self.assertEqual(result, self.sample_embedding)
            mock_encode.assert_called_once_with("test query")
    
    def test_search_similar(self):
        """Test similarity search functionality"""
        import numpy as np
        
        # Create mock embedding matrix
        embedding_matrix = np.array([[0.1, 0.2, 0.3], [0.4, 0.5, 0.6]])
        query_embedding = [0.1, 0.2, 0.3]
        
        results = search_similar(query_embedding, embedding_matrix, self.sample_metadata, top_k=1)
        
        self.assertEqual(len(results), 1)
        self.assertIn('text', results[0])
        self.assertIn('similarity', results[0])

if __name__ == '__main__':
    unittest.main()
```

### Integration Tests

```python
def test_end_to_end_search():
    """Test complete search workflow"""
    query = "What is Islam?"
    
    # Load search data
    metadata, embedding_matrix = load_search_data()
    
    # Embed query
    query_embedding = embed_query(query, embedding_matrix.shape[1])
    
    # Perform search
    results = search_similar(query_embedding, embedding_matrix, metadata, top_k=3)
    
    # Validate results
    assert len(results) <= 3
    assert all('similarity' in result for result in results)
    assert all(0 <= result['similarity'] <= 1 for result in results)
```

## Deployment

### Environment Setup

```bash
# Install required packages
pip install -r requirements.txt

# Required packages:
# sentence-transformers>=2.2.0
# scikit-learn>=1.0.0
# numpy>=1.21.0
# google-generativeai>=0.3.0
# langchain>=0.1.0
# python-dotenv>=0.19.0
```

### Environment Variables

```bash
# .env file
GEMINI_API_KEY=your_gemini_api_key_here
EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
SEARCH_METADATA_PATH=/path/to/search_metadata.json
MAX_SEARCH_RESULTS=10
```

### Production Configuration

```python
# config.py
import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
    EMBEDDING_MODEL = os.getenv('EMBEDDING_MODEL', 'sentence-transformers/all-MiniLM-L6-v2')
    SEARCH_METADATA_PATH = os.getenv('SEARCH_METADATA_PATH', 'search_metadata.json')
    MAX_SEARCH_RESULTS = int(os.getenv('MAX_SEARCH_RESULTS', '10'))
    
    # Validation
    if not GEMINI_API_KEY:
        raise ValueError("GEMINI_API_KEY environment variable is required")
```

## Troubleshooting

### Common Issues

1. **Embedding Dimension Mismatch**
   ```python
   # Check embedding dimensions
   if query_vector.shape[1] != embedding_matrix.shape[1]:
       print(f"Dimension mismatch: Query has {query_vector.shape[1]} dimensions, "
             f"but stored embeddings have {embedding_matrix.shape[1]} dimensions")
   ```

2. **Memory Issues with Large Datasets**
   ```python
   # Use memory mapping for large files
   import mmap
   
   def load_large_file(filename):
       with open(filename, 'r') as f:
           with mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ) as mmapped_file:
               for line in iter(mmapped_file.readline, b""):
                   yield json.loads(line.decode('utf-8'))
   ```

3. **API Rate Limiting**
   ```python
   import time
   from functools import wraps
   
   def rate_limit(calls_per_second=1):
       def decorator(func):
           last_called = [0.0]
           
           @wraps(func)
           def wrapper(*args, **kwargs):
               elapsed = time.time() - last_called[0]
               left_to_wait = 1.0 / calls_per_second - elapsed
               if left_to_wait > 0:
                   time.sleep(left_to_wait)
               ret = func(*args, **kwargs)
               last_called[0] = time.time()
               return ret
           return wrapper
       return decorator
   
   @rate_limit(calls_per_second=0.5)  # 2 seconds between calls
   def call_gemini_api(prompt):
       return client.chat.completions.create(...)
   ```

This documentation provides a comprehensive guide to all Python modules in the Hidaya project, enabling developers to understand, maintain, and extend the Islamic content processing and AI integration functionality.