"""
Script สำหรับประมวลผล MM-Food-100K dataset และ export เป็น JSON
สำหรับใช้ใน Flutter/Dart application

Usage:
    python scripts/process_food_dataset.py

Requirements:
    pip install datasets huggingface_hub
"""

import json
import os
import sys
from datasets import load_dataset
from pathlib import Path

# Fix Windows console encoding
if sys.platform == 'win32':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

def process_mm_food_dataset():
    """ดาวน์โหลดและประมวลผล MM-Food-100K dataset"""
    print("📥 กำลังดาวน์โหลด MM-Food-100K dataset...")
    
    try:
        # Login using e.g. `huggingface-cli login` to access this dataset
        ds = load_dataset("Codatta/MM-Food-100K")
        print(f"✅ โหลด dataset สำเร็จ!")
        print(f"   - Split: {list(ds.keys())}")
        
        # ใช้ train split (หรือ split ที่มีข้อมูลมากที่สุด)
        train_split = None
        for split_name in ds.keys():
            if 'train' in split_name.lower() or len(ds[split_name]) > 0:
                train_split = ds[split_name]
                print(f"   - ใช้ split: {split_name} ({len(train_split)} รายการ)")
                break
        
        if train_split is None:
            print("❌ ไม่พบ train split")
            return
        
        # ประมวลผลข้อมูล
        print("\n🔄 กำลังประมวลผลข้อมูล...")
        foods = []
        
        # ดูโครงสร้างข้อมูลก่อน
        if len(train_split) > 0:
            print(f"\n📋 ตัวอย่างข้อมูล (แถวแรก):")
            example = train_split[0]
            print(json.dumps(example, indent=2, ensure_ascii=False))
        
        # ประมวลผลแต่ละรายการ
        for idx, item in enumerate(train_split):
            try:
                # Parse nutritional_profile JSON string
                nutritional_profile = {}
                if 'nutritional_profile' in item and item['nutritional_profile']:
                    try:
                        nutritional_profile = json.loads(item['nutritional_profile'])
                    except:
                        nutritional_profile = {}
                
                # Parse ingredients
                ingredients = []
                if 'ingredients' in item and item['ingredients']:
                    try:
                        ingredients = json.loads(item['ingredients'])
                    except:
                        ingredients = []
                
                # Parse portion_size
                portion_size = {}
                if 'portion_size' in item and item['portion_size']:
                    try:
                        portion_list = json.loads(item['portion_size'])
                        if portion_list:
                            # Extract size from first item (e.g., "chicken:300g" -> 300)
                            first_portion = portion_list[0] if isinstance(portion_list, list) else str(portion_list)
                            if ':' in str(first_portion):
                                size_str = str(first_portion).split(':')[1].replace('g', '').strip()
                                portion_size['size'] = float(size_str) if size_str.isdigit() else 100
                            else:
                                portion_size['size'] = 100
                    except:
                        portion_size['size'] = 100
                
                # สร้างข้อมูลอาหาร
                food_data = {
                    'id': idx,
                    'name': item.get('dish_name', item.get('food_name', item.get('name', ''))),
                    'name_en': item.get('dish_name', item.get('food_name_en', item.get('name_en', ''))),
                    'calories': nutritional_profile.get('calories_kcal', nutritional_profile.get('calories', 0)),
                    'protein': nutritional_profile.get('protein_g', nutritional_profile.get('protein', 0)),
                    'carbs': nutritional_profile.get('carbohydrate_g', nutritional_profile.get('carbs', nutritional_profile.get('carbohydrate', 0))),
                    'fat': nutritional_profile.get('fat_g', nutritional_profile.get('fat', 0)),
                    'fiber': nutritional_profile.get('fiber_g', nutritional_profile.get('fiber', 0)),
                    'sugar': nutritional_profile.get('sugar_g', nutritional_profile.get('sugar', 0)),
                    'sodium': nutritional_profile.get('sodium_mg', nutritional_profile.get('sodium', 0)),
                    'serving_size': portion_size.get('size', 100),
                    'serving_unit': 'g',
                    'category': item.get('food_type', item.get('category', '')),
                    'cuisine': item.get('cuisine', ''),
                    'image_url': item.get('image_url', item.get('image', '')),
                    'cooking_method': item.get('cooking_method', ''),
                    'ingredients': ingredients,
                }
                
                # กรองเฉพาะรายการที่มีชื่อและข้อมูลโภชนาการ
                if food_data['name'] and food_data['calories'] > 0:
                    foods.append(food_data)
                
                if (idx + 1) % 1000 == 0:
                    print(f"   ประมวลผลแล้ว: {idx + 1}/{len(train_split)} รายการ")
                    
            except Exception as e:
                print(f"   ⚠️  ข้ามรายการที่ {idx}: {e}")
                continue
        
        print(f"\n✅ ประมวลผลเสร็จสิ้น: {len(foods)} รายการ")
        
        # Export เป็น JSON
        output_dir = Path(__file__).parent.parent / "assets" / "data"
        output_dir.mkdir(parents=True, exist_ok=True)
        
        output_file = output_dir / "global_food_database.json"
        
        print(f"\n💾 กำลังบันทึกเป็น JSON: {output_file}")
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(foods, f, ensure_ascii=False, indent=2)
        
        print(f"✅ บันทึกสำเร็จ! ({len(foods)} รายการ)")
        
        # สร้าง index สำหรับค้นหาที่เร็วขึ้น
        print("\n🔍 กำลังสร้าง search index...")
        index_data = {
            'total_foods': len(foods),
            'by_name': {},
            'by_category': {},
            'by_cuisine': {},
        }
        
        for food in foods:
            name_lower = food['name'].lower()
            # Index by name (first word)
            first_word = name_lower.split()[0] if name_lower.split() else name_lower
            if first_word not in index_data['by_name']:
                index_data['by_name'][first_word] = []
            index_data['by_name'][first_word].append(food['id'])
            
            # Index by category
            if food['category']:
                cat = food['category'].lower()
                if cat not in index_data['by_category']:
                    index_data['by_category'][cat] = []
                index_data['by_category'][cat].append(food['id'])
            
            # Index by cuisine
            if food['cuisine']:
                cuisine = food['cuisine'].lower()
                if cuisine not in index_data['by_cuisine']:
                    index_data['by_cuisine'][cuisine] = []
                index_data['by_cuisine'][cuisine].append(food['id'])
        
        index_file = output_dir / "global_food_index.json"
        with open(index_file, 'w', encoding='utf-8') as f:
            json.dump(index_data, f, ensure_ascii=False, indent=2)
        
        print(f"✅ สร้าง index สำเร็จ: {index_file}")
        
        # สร้างไฟล์สรุป
        summary = {
            'total_foods': len(foods),
            'categories': len(index_data['by_category']),
            'cuisines': len(index_data['by_cuisine']),
            'sample_foods': foods[:10],  # ตัวอย่าง 10 รายการแรก
        }
        
        summary_file = output_dir / "global_food_summary.json"
        with open(summary_file, 'w', encoding='utf-8') as f:
            json.dump(summary, f, ensure_ascii=False, indent=2)
        
        print(f"✅ สร้าง summary สำเร็จ: {summary_file}")
        print(f"\n📊 สรุป:")
        print(f"   - อาหารทั้งหมด: {len(foods)} รายการ")
        print(f"   - หมวดหมู่: {len(index_data['by_category'])} หมวด")
        print(f"   - อาหารประจำชาติ: {len(index_data['by_cuisine'])} ประเทศ")
        
    except Exception as e:
        print(f"❌ เกิดข้อผิดพลาด: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    process_mm_food_dataset()
