import json
import sys

try:
    with open('assets/data/pickup_lines.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    print(f"JSON is valid! Found {len(data)} categories:")
    for category in data:
        print(f"- {category['category_name']}: {len(category['messages'])} messages")
except Exception as e:
    print(f"Error: {e}")
    print(f"Error type: {type(e)}")
