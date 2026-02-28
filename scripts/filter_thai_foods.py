"""
Script สำหรับกรอง global_food_database.json ให้เหลือเฉพาะอาหารไทยและวัตถุดิบ

Usage:
    python scripts/filter_thai_foods.py
"""

import json
import sys
from pathlib import Path

# Fix Windows console encoding
if sys.platform == 'win32':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

# คำสำคัญอาหารไทย (ภาษาอังกฤษ)
THAI_FOOD_KEYWORDS = [
    'pad thai', 'padthai', 'padtai',
    'tom yum', 'tomyum', 'tom yam', 'tomyam',
    'tom kha', 'tomkha', 'tom ka', 'tomka',
    'green curry', 'red curry', 'yellow curry', 'massaman curry', 'panang curry',
    'som tam', 'somtam', 'papaya salad',
    'mango sticky rice', 'sticky rice',
    'thai basil', 'holy basil',
    'larb', 'laab', 'larp',
    'satay', 'sate',
    'pad see ew', 'pad see eiw',
    'pad kee mao', 'drunken noodles',
    'khao soi', 'khaosoi',
    'thai', 'thailand',
    'nam prik', 'namphrik',
    'gaeng', 'gang', 'kaeng',
    'khao', 'kao',
    'moo', 'mu',
    'gai', 'kai',
    'pla', 'fish',
    'kung', 'shrimp',
    'yum', 'yam',
    'tod', 'thod',
    'pla ra', 'plara',
]

# หมวดหมู่วัตถุดิบ
INGREDIENT_CATEGORIES = [
    'raw vegetables and fruits',
    'raw vegetables',
    'raw fruits',
    'vegetables',
    'fruits',
    'spices',
    'herbs',
    'grains',
    'cereals',
    'meat',
    'seafood',
    'fish',
    'poultry',
    'dairy',
    'nuts',
    'seeds',
    'legumes',
    'beans',
    'rice',
    'flour',
    'oil',
    'vinegar',
    'sauce',
    'condiments',
    'beverages',
    'drinks',
    'ingredients',
    'raw',
    'fresh',
]

def is_thai_food(food_item):
    """ตรวจสอบว่าอาหารนี้เป็นอาหารไทยหรือไม่"""
    name = food_item.get('name', '').lower()
    name_en = food_item.get('name_en', '').lower()
    cuisine = food_item.get('cuisine', '').lower()
    
    # ตรวจสอบ cuisine
    if 'thai' in cuisine:
        return True
    
    # ตรวจสอบชื่ออาหาร
    full_text = f"{name} {name_en}".lower()
    for keyword in THAI_FOOD_KEYWORDS:
        if keyword in full_text:
            return True
    
    return False

def create_index(foods, index_file):
    """สร้าง index สำหรับค้นหาที่เร็วขึ้น"""
    print(f"\n🔍 กำลังสร้าง search index...")
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

def is_ingredient(food_item):
    """ตรวจสอบว่าอาหารนี้เป็นวัตถุดิบหรือไม่"""
    category = (food_item.get('category') or '').lower()
    cooking_method = (food_item.get('cooking_method') or '').lower()
    
    # ตรวจสอบ category
    for ing_category in INGREDIENT_CATEGORIES:
        if ing_category in category:
            return True
    
    # ถ้า cooking_method เป็น "Raw" หรือ "Fresh" ก็ถือว่าเป็นวัตถุดิบ
    if cooking_method and cooking_method in ['raw', 'fresh']:
        return True
    
    return False

def filter_foods(input_file, output_file):
    """กรองอาหารให้เหลือเฉพาะอาหารไทยและวัตถุดิบ"""
    print(f"📥 กำลังโหลดไฟล์: {input_file}")
    
    with open(input_file, 'r', encoding='utf-8') as f:
        foods = json.load(f)
    
    print(f"✅ โหลดสำเร็จ: {len(foods)} รายการ")
    
    print("\n🔍 กำลังกรองข้อมูล...")
    filtered_foods = []
    thai_count = 0
    ingredient_count = 0
    
    for idx, food in enumerate(foods):
        is_thai = is_thai_food(food)
        is_ing = is_ingredient(food)
        
        if is_thai or is_ing:
            # อัพเดท id ให้เป็นลำดับใหม่
            food['id'] = len(filtered_foods)
            filtered_foods.append(food)
            
            if is_thai:
                thai_count += 1
            if is_ing:
                ingredient_count += 1
        
        if (idx + 1) % 10000 == 0:
            print(f"   ประมวลผลแล้ว: {idx + 1}/{len(foods)} รายการ (พบแล้ว: {len(filtered_foods)} รายการ)")
    
    print(f"\n✅ กรองเสร็จสิ้น!")
    print(f"   - อาหารไทย: {thai_count} รายการ")
    print(f"   - วัตถุดิบ: {ingredient_count} รายการ")
    print(f"   - รวมทั้งหมด: {len(filtered_foods)} รายการ")
    
    print(f"\n💾 กำลังบันทึกไฟล์: {output_file}")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(filtered_foods, f, ensure_ascii=False, indent=2)
    
    print(f"✅ บันทึกสำเร็จ!")
    
    # สร้างไฟล์สำรองของไฟล์เดิม
    backup_file = input_file.parent / f"{input_file.stem}_backup{input_file.suffix}"
    if not backup_file.exists():
        print(f"\n💾 กำลังสร้างไฟล์สำรอง: {backup_file}")
        with open(input_file, 'r', encoding='utf-8') as src, \
             open(backup_file, 'w', encoding='utf-8') as dst:
            dst.write(src.read())
        print(f"✅ สร้างไฟล์สำรองสำเร็จ!")
    
    # สร้าง index ใหม่
    create_index(filtered_foods, output_file.parent / "global_food_index.json")

if __name__ == "__main__":
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    
    input_file = project_root / "assets" / "data" / "global_food_database.json"
    output_file = project_root / "assets" / "data" / "global_food_database.json"
    
    if not input_file.exists():
        print(f"❌ ไม่พบไฟล์: {input_file}")
        sys.exit(1)
    
    filter_foods(input_file, output_file)
