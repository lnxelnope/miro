"""
Script สำหรับสร้าง index จาก global_food_database.json

Usage:
    python scripts/create_food_index.py
"""

import json
import sys
from pathlib import Path

# Fix Windows console encoding
if sys.platform == 'win32':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

def create_index(foods, index_file):
    """สร้าง index สำหรับค้นหาที่เร็วขึ้น"""
    print(f"🔍 กำลังสร้าง search index...")
    index_data = {
        'total_foods': len(foods),
        'by_name': {},
        'by_category': {},
        'by_cuisine': {},
    }
    
    for food in foods:
        name_lower = food.get('name', '').lower()
        # Index by name (first word)
        if name_lower:
            first_word = name_lower.split()[0] if name_lower.split() else name_lower
            if first_word not in index_data['by_name']:
                index_data['by_name'][first_word] = []
            index_data['by_name'][first_word].append(food['id'])
        
        # Index by category
        if food.get('category'):
            cat = food['category'].lower()
            if cat not in index_data['by_category']:
                index_data['by_category'][cat] = []
            index_data['by_category'][cat].append(food['id'])
        
        # Index by cuisine
        if food.get('cuisine'):
            cuisine = food['cuisine'].lower()
            if cuisine not in index_data['by_cuisine']:
                index_data['by_cuisine'][cuisine] = []
            index_data['by_cuisine'][cuisine].append(food['id'])
    
    print(f"💾 กำลังบันทึก index: {index_file}")
    with open(index_file, 'w', encoding='utf-8') as f:
        json.dump(index_data, f, ensure_ascii=False, indent=2)
    
    print(f"✅ สร้าง index สำเร็จ!")
    print(f"   - ชื่ออาหาร: {len(index_data['by_name'])} คำ")
    print(f"   - หมวดหมู่: {len(index_data['by_category'])} หมวด")
    print(f"   - อาหารประจำชาติ: {len(index_data['by_cuisine'])} ประเทศ")

if __name__ == "__main__":
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    
    input_file = project_root / "assets" / "data" / "global_food_database.json"
    index_file = project_root / "assets" / "data" / "global_food_index.json"
    
    if not input_file.exists():
        print(f"❌ ไม่พบไฟล์: {input_file}")
        sys.exit(1)
    
    print(f"📥 กำลังโหลดไฟล์: {input_file}")
    with open(input_file, 'r', encoding='utf-8') as f:
        foods = json.load(f)
    
    print(f"✅ โหลดสำเร็จ: {len(foods)} รายการ")
    
    create_index(foods, index_file)
