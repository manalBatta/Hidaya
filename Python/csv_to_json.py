import csv
import json
import os

# Paths to your CSV files
quran_csv = r'C:\Users\manal\Downloads\archive\data\quran\quran.csv'
surah_info_csv = r'C:\Users\manal\Downloads\archive\data\surah\surah_info.csv'
jalalayn_csv = r'C:\Users\manal\Downloads\archive\data\tafaseer\english\Tafsir_al-Jalalayn_tafseer.csv'
translation_csv = r'C:\Users\manal\Downloads\archive\data\translation\english\The Quran Dataset.csv'
rawis_csv = r'C:\Users\manal\Downloads\archive\data\hadith\kaggle_rawis.csv'
hadith_csv = r"C:\Users\manal\Downloads\archive\data\hadith\kaggle_hadiths_clean.csv"

# Output file
output_jsonl = r'C:\Users\manal\Downloads\archive\data\combined_dataset.jsonl'

# Create list to hold all entries
all_entries = []

# ----------- 1. Quran Ayat ----------- #
with open(quran_csv, newline='', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        words_str = row.get("list_of_words", "")
        words = []
        if words_str.startswith("[") and words_str.endswith("]"):
            inner = words_str[1:-1]
            words = [w.strip() for w in inner.split(",") if w.strip()]

        entry = {
            "type": "quran_ayah",
            "id": f"q-{row['surah_no']}-{row['ayah_no_surah']}",
            "text": row["ayah"],
            "surah": row["surah_name"],
            "surah_no": int(row["surah_no"]),
            "ayah_no": int(row["ayah_no_surah"]),
            "words": words,
        }
        all_entries.append(entry)

# ----------- 2. Surah Info ----------- #
with open(surah_info_csv, newline='', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        number_of_rukus = row["NumberOfRukus"].strip().strip("'\"")  # Keep as string
        
        try:
            surah_no = int(row["SurahNumber"].strip().strip("'\""))
        except (ValueError, AttributeError):
            print(f"Warning: Invalid SurahNumber value: {row['SurahNumber']}")
            surah_no = 0

        try:
            number_of_verses = int(row["NumberOfVerses"].strip().strip("'\""))
        except (ValueError, AttributeError):
            print(f"Warning: Invalid NumberOfVerses value: {row['NumberOfVerses']}")
            number_of_verses = 0

        entry = {
            "type": "surah_info",
            "surah_no": surah_no,
            "english_title": row["EnglishTitle"],
            "arabic_title": row["ArabicTitle"],
            "roman_title": row["RomanTitle"],
            "number_of_verses": number_of_verses,
            "number_of_rukus": number_of_rukus,  # <-- string here
            "place_of_revelation": row["PlaceOfRevelation"]
        }
        all_entries.append(entry)


# ----------- 3. Tafsir Al-Jalalayn ----------- #
with open(jalalayn_csv, newline='', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        entry = {
            "type": "tafsir_jalalayn",
            "ayah_ar": row["Arabic"],
            "tafsir_en": row["Tafseer"]
        }
        all_entries.append(entry)

# ----------- 4. English Quran Translation ----------- #
with open(translation_csv, newline='', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        entry = {
            "type": "translation",
            "surah_no": int(row["surah_no"]),
            "ayah_no": int(row["ayah_no_surah"]),
            "text_ar": row["ayah_ar"],
            "text_en": row["ayah_en"],
            "surah_name_en": row["surah_name_en"],
            "surah_name_ar": row["surah_name_ar"],
            "place_of_revelation": row["place_of_revelation"]
        }
        all_entries.append(entry)

# ----------- 5. Hadith Narrators (Rawis) ----------- #
with open(rawis_csv, newline='', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        entry = {
            "type": "narrator",
            "id": row["scholar_indx"],
            "name": row["name"],
            "grade": row["grade"],
            "birth": row.get("birth_date_place", ""),
            "death": row.get("death_date_place", ""),
            "books": row.get("books", ""),
            "tags": row.get("tags", ""),
            "area_of_interest": row.get("area_of_interest", "")
        }
        all_entries.append(entry)

#----------- 6. Hadiths ----------- #
with open(hadith_csv, newline='', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        entry = {
            "type": "hadith",
            "id": row["id"].strip(),
            "hadith_id": row["hadith_id"].strip(),
            "source": row["source"].strip(),
            "chapter_no": row["chapter_no"].strip(),
            "hadith_no": row["hadith_no"].strip(),
            "chapter": row["chapter"].strip(),
            "chain_indx": row["chain_indx"].strip(),
            "text_ar": row["text_ar"].strip(),
            "text_en": row["text_en"].strip(),
        }
        all_entries.append(entry)

        
# ----------- Write to JSONL ----------- #
with open(output_jsonl, 'w', encoding='utf-8') as out:
    for entry in all_entries:
        out.write(json.dumps(entry, ensure_ascii=False) + '\n')

print(f"✅ All data converted and saved to: {output_jsonl}")
