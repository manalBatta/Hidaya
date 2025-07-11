from sentence_transformers import SentenceTransformer
import json

model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')  # Small, fast, and great for Arabic+English

input_path = "dataset/combined_dataset.jsonl"
output_path = "dataset/embedded_dataset_local.jsonl"

with open(input_path, 'r', encoding='utf-8') as infile, open(output_path, 'w', encoding='utf-8') as outfile:
    for line in infile:
        item = json.loads(line)
        text = item.get("text")
        if not text:
            continue

        embedding = model.encode(text).tolist()
        item['embedding'] = embedding
        outfile.write(json.dumps(item, ensure_ascii=False) + '\n')

print("✅ Done embedding with sentence-transformers.")
