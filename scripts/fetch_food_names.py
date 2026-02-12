"""
ดึงรายชื่ออาหารจาก:
1. thai-food-open-data (GitHub) — อาหารไทย
2. Food101 (HuggingFace) — อาหารสากล

Output: assets/data/food_names.json

วิธีใช้:
  pip install requests
  python scripts/fetch_food_names.py
"""

import json, os, re, requests, sys

# Fix encoding สำหรับ Windows
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

OUTPUT = os.path.join(os.path.dirname(__file__), "..", "assets", "data", "food_names.json")

# Fallback: รายชื่ออาหารไทยที่พบบ่อย (ประมาณ 100 เมนู)
THAI_FOOD_FALLBACK = [
    {"th": "ข้าวผัด", "en": "Fried Rice", "cal": None},
    {"th": "ข้าวผัดกุ้ง", "en": "Shrimp Fried Rice", "cal": None},
    {"th": "ข้าวผัดปู", "en": "Crab Fried Rice", "cal": None},
    {"th": "ข้าวผัดหมู", "en": "Pork Fried Rice", "cal": None},
    {"th": "ข้าวผัดไก่", "en": "Chicken Fried Rice", "cal": None},
    {"th": "ข้าวผัดอเมริกัน", "en": "American Fried Rice", "cal": None},
    {"th": "ข้าวผัดพริกแกง", "en": "Curry Fried Rice", "cal": None},
    {"th": "ข้าวผัดน้ำพริก", "en": "Chili Paste Fried Rice", "cal": None},
    {"th": "ข้าวผัดกะเพรา", "en": "Basil Fried Rice", "cal": None},
    {"th": "ผัดซีอิ้ว", "en": "Soy Sauce Noodles", "cal": None},
    {"th": "ผัดไทย", "en": "Pad Thai", "cal": None},
    {"th": "ผัดกระเพรา", "en": "Basil Stir Fry", "cal": None},
    {"th": "ผัดกระเพราหมู", "en": "Basil Pork", "cal": None},
    {"th": "ผัดกระเพราไก่", "en": "Basil Chicken", "cal": None},
    {"th": "ผัดกระเพราหมูสับ", "en": "Basil Minced Pork", "cal": None},
    {"th": "ผัดกระเพราไข่ดาว", "en": "Basil with Fried Egg", "cal": None},
    {"th": "ส้มตำ", "en": "Papaya Salad", "cal": None},
    {"th": "ส้มตำไทย", "en": "Thai Papaya Salad", "cal": None},
    {"th": "ส้มตำปู", "en": "Papaya Salad with Crab", "cal": None},
    {"th": "ต้มยำ", "en": "Tom Yum", "cal": None},
    {"th": "ต้มยำกุ้ง", "en": "Tom Yum Goong", "cal": None},
    {"th": "ต้มยำไก่", "en": "Tom Yum Chicken", "cal": None},
    {"th": "ต้มยำหมู", "en": "Tom Yum Pork", "cal": None},
    {"th": "ต้มยำทะเล", "en": "Tom Yum Seafood", "cal": None},
    {"th": "แกงเขียวหวาน", "en": "Green Curry", "cal": None},
    {"th": "แกงเขียวหวานไก่", "en": "Green Curry Chicken", "cal": None},
    {"th": "แกงเขียวหวานหมู", "en": "Green Curry Pork", "cal": None},
    {"th": "แกงแดง", "en": "Red Curry", "cal": None},
    {"th": "แกงแดงไก่", "en": "Red Curry Chicken", "cal": None},
    {"th": "แกงมัสมั่น", "en": "Massaman Curry", "cal": None},
    {"th": "แกงมัสมั่นไก่", "en": "Massaman Chicken", "cal": None},
    {"th": "แกงพะแนง", "en": "Panang Curry", "cal": None},
    {"th": "แกงพะแนงไก่", "en": "Panang Chicken", "cal": None},
    {"th": "ข้าวมันไก่", "en": "Chicken Rice", "cal": None},
    {"th": "ข้าวขาหมู", "en": "Braised Pork Leg Rice", "cal": None},
    {"th": "ข้าวหมูแดง", "en": "Red Pork Rice", "cal": None},
    {"th": "ข้าวหมูกรอบ", "en": "Crispy Pork Rice", "cal": None},
    {"th": "ข้าวหมูทอด", "en": "Fried Pork Rice", "cal": None},
    {"th": "ข้าวกะเพรา", "en": "Basil Rice", "cal": None},
    {"th": "ข้าวต้ม", "en": "Rice Porridge", "cal": None},
    {"th": "ข้าวต้มหมู", "en": "Pork Porridge", "cal": None},
    {"th": "ข้าวต้มไก่", "en": "Chicken Porridge", "cal": None},
    {"th": "ข้าวต้มปลา", "en": "Fish Porridge", "cal": None},
    {"th": "ข้าวเหนียว", "en": "Sticky Rice", "cal": None},
    {"th": "ข้าวเหนียวมะม่วง", "en": "Mango Sticky Rice", "cal": None},
    {"th": "ข้าวเหนียวทุเรียน", "en": "Durian Sticky Rice", "cal": None},
    {"th": "ข้าวเหนียวสังขยา", "en": "Custard Sticky Rice", "cal": None},
    {"th": "ก๋วยเตี๋ยว", "en": "Noodles", "cal": None},
    {"th": "ก๋วยเตี๋ยวต้มยำ", "en": "Tom Yum Noodles", "cal": None},
    {"th": "ก๋วยเตี๋ยวเรือ", "en": "Boat Noodles", "cal": None},
    {"th": "ก๋วยเตี๋ยวน้ำใส", "en": "Clear Noodle Soup", "cal": None},
    {"th": "ก๋วยเตี๋ยวน้ำตก", "en": "Spicy Noodle Soup", "cal": None},
    {"th": "ก๋วยเตี๋ยวแห้ง", "en": "Dry Noodles", "cal": None},
    {"th": "ก๋วยเตี๋ยวผัด", "en": "Stir Fried Noodles", "cal": None},
    {"th": "บะหมี่", "en": "Egg Noodles", "cal": None},
    {"th": "บะหมี่น้ำ", "en": "Noodle Soup", "cal": None},
    {"th": "บะหมี่แห้ง", "en": "Dry Noodles", "cal": None},
    {"th": "บะหมี่ผัด", "en": "Fried Noodles", "cal": None},
    {"th": "ราดหน้า", "en": "Gravy Noodles", "cal": None},
    {"th": "ราดหน้าหมู", "en": "Pork Gravy Noodles", "cal": None},
    {"th": "ราดหน้าไก่", "en": "Chicken Gravy Noodles", "cal": None},
    {"th": "ราดหน้าทะเล", "en": "Seafood Gravy Noodles", "cal": None},
    {"th": "ผัดหมี่", "en": "Stir Fried Noodles", "cal": None},
    {"th": "ผัดหมี่ซั่ว", "en": "Stir Fried Wide Noodles", "cal": None},
    {"th": "ผัดหมี่ขาว", "en": "Stir Fried Rice Noodles", "cal": None},
    {"th": "ผัดหมี่เหลือง", "en": "Stir Fried Yellow Noodles", "cal": None},
    {"th": "หมี่กรอบ", "en": "Crispy Noodles", "cal": None},
    {"th": "หมี่กะทิ", "en": "Coconut Noodles", "cal": None},
    {"th": "หมี่ซั่ว", "en": "Wide Noodles", "cal": None},
    {"th": "หมี่ขาว", "en": "Rice Noodles", "cal": None},
    {"th": "หมี่เหลือง", "en": "Yellow Noodles", "cal": None},
    {"th": "หมี่น้ำ", "en": "Noodle Soup", "cal": None},
    {"th": "หมี่แห้ง", "en": "Dry Noodles", "cal": None},
    {"th": "หมี่ผัด", "en": "Fried Noodles", "cal": None},
    {"th": "หมี่เกี๊ยว", "en": "Wonton Noodles", "cal": None},
    {"th": "หมี่เกี๊ยวน้ำ", "en": "Wonton Soup", "cal": None},
    {"th": "หมี่เกี๊ยวแห้ง", "en": "Dry Wonton", "cal": None},
    {"th": "หมี่เกี๊ยวผัด", "en": "Fried Wonton", "cal": None},
    {"th": "หมี่กรอบราดหน้า", "en": "Crispy Noodles with Gravy", "cal": None},
    {"th": "ยำวุ้นเส้น", "en": "Glass Noodle Salad", "cal": None},
    {"th": "ยำมาม่า", "en": "Instant Noodle Salad", "cal": None},
    {"th": "ยำหมูยอ", "en": "Pork Sausage Salad", "cal": None},
    {"th": "ยำกุ้ง", "en": "Shrimp Salad", "cal": None},
    {"th": "ยำไก่", "en": "Chicken Salad", "cal": None},
    {"th": "ยำปลากระป๋อง", "en": "Canned Fish Salad", "cal": None},
    {"th": "ยำทูน่า", "en": "Tuna Salad", "cal": None},
    {"th": "ยำปลาหมึก", "en": "Squid Salad", "cal": None},
    {"th": "ลาบ", "en": "Larb", "cal": None},
    {"th": "ลาบหมู", "en": "Pork Larb", "cal": None},
    {"th": "ลาบไก่", "en": "Chicken Larb", "cal": None},
    {"th": "ลาบเนื้อ", "en": "Beef Larb", "cal": None},
    {"th": "น้ำตก", "en": "Nam Tok", "cal": None},
    {"th": "น้ำตกหมู", "en": "Pork Nam Tok", "cal": None},
    {"th": "น้ำตกเนื้อ", "en": "Beef Nam Tok", "cal": None},
    {"th": "ต้มข่าไก่", "en": "Galangal Chicken Soup", "cal": None},
    {"th": "ต้มแซ่บ", "en": "Spicy Soup", "cal": None},
    {"th": "ต้มแซ่บหมู", "en": "Spicy Pork Soup", "cal": None},
    {"th": "ต้มแซ่บไก่", "en": "Spicy Chicken Soup", "cal": None},
    {"th": "ต้มแซ่บเนื้อ", "en": "Spicy Beef Soup", "cal": None},
    {"th": "ต้มแซ่บปลา", "en": "Spicy Fish Soup", "cal": None},
    {"th": "ต้มแซ่บทะเล", "en": "Spicy Seafood Soup", "cal": None},
    {"th": "ลาบหมู", "en": "Pork Larb", "cal": None},
    {"th": "ลาบไก่", "en": "Chicken Larb", "cal": None},
    {"th": "ลาบเนื้อ", "en": "Beef Larb", "cal": None},
    {"th": "ลาบปลา", "en": "Fish Larb", "cal": None},
    {"th": "น้ำตก", "en": "Nam Tok", "cal": None},
    {"th": "น้ำตกหมู", "en": "Pork Nam Tok", "cal": None},
    {"th": "น้ำตกเนื้อ", "en": "Beef Nam Tok", "cal": None},
    {"th": "น้ำตกไก่", "en": "Chicken Nam Tok", "cal": None},
    {"th": "ต้มข่าไก่", "en": "Galangal Chicken Soup", "cal": None},
    {"th": "ต้มแซ่บ", "en": "Spicy Soup", "cal": None},
    {"th": "ต้มแซ่บหมู", "en": "Spicy Pork Soup", "cal": None},
    {"th": "ต้มแซ่บไก่", "en": "Spicy Chicken Soup", "cal": None},
    {"th": "ต้มแซ่บเนื้อ", "en": "Spicy Beef Soup", "cal": None},
    {"th": "ต้มแซ่บปลา", "en": "Spicy Fish Soup", "cal": None},
    {"th": "ต้มแซ่บทะเล", "en": "Spicy Seafood Soup", "cal": None},
]

def fetch_thai_food():
    """ดึงอาหารไทย (fallback list เพราะ API ไม่มี)"""
    print("[1/2] ใช้รายชื่ออาหารไทย (fallback list) ...")
    
    foods = []
    for item in THAI_FOOD_FALLBACK:
        foods.append({
            "th": item["th"],
            "en": item.get("en"),
            "cal": item.get("cal"),
            "src": "thai",
        })

    print(f"   -> ได้ {len(foods)} เมนูไทย")
    return foods


def fetch_food101():
    """ดึง 101 categories จาก Food101 (HuggingFace)"""
    print("[2/2] ดึง Food101 categories ...")

    # ดึง label names จาก HuggingFace dataset info API (ไม่ต้องโหลด dataset ทั้งหมด)
    url = "https://datasets-server.huggingface.co/info?dataset=ethz/food101&config=default"
    try:
        resp = requests.get(url, timeout=30)
        resp.raise_for_status()
        info = resp.json()
        labels = info["dataset_info"]["features"]["label"]["names"]
    except Exception as e:
        # Fallback: ใช้ list ที่รู้อยู่แล้ว
        print(f"   -> ใช้ fallback list (error: {e})")
        labels = FOOD101_FALLBACK

    foods = []
    for label in labels:
        en = label.replace("_", " ").title()
        foods.append({
            "th": None,
            "en": en,
            "cal": None,
            "src": "food101",
        })

    print(f"   -> ได้ {len(foods)} เมนูสากล")
    return foods


# Fallback กรณี API ไม่ตอบ
FOOD101_FALLBACK = [
    "apple_pie","baby_back_ribs","baklava","beef_carpaccio","beef_tartare",
    "beet_salad","beignets","bibimbap","bread_pudding","breakfast_burrito",
    "bruschetta","caesar_salad","cannoli","caprese_salad","carrot_cake",
    "ceviche","cheese_plate","cheesecake","chicken_curry","chicken_quesadilla",
    "chicken_wings","chocolate_cake","chocolate_mousse","churros","clam_chowder",
    "club_sandwich","crab_cakes","creme_brulee","croque_madame","cup_cakes",
    "deviled_eggs","donuts","dumplings","edamame","eggs_benedict",
    "escargots","falafel","filet_mignon","fish_and_chips","foie_gras",
    "french_fries","french_onion_soup","french_toast","fried_calamari","fried_rice",
    "frozen_yogurt","garlic_bread","gnocchi","greek_salad","grilled_cheese_sandwich",
    "grilled_salmon","guacamole","gyoza","hamburger","hot_and_sour_soup",
    "hot_dog","huevos_rancheros","hummus","ice_cream","lasagna",
    "lobster_bisque","lobster_roll_sandwich","macaroni_and_cheese","macarons","miso_soup",
    "mussels","nachos","omelette","onion_rings","oysters",
    "pad_thai","paella","pancakes","panna_cotta","peking_duck",
    "pho","pizza","pork_chop","poutine","prime_rib",
    "pulled_pork_sandwich","ramen","ravioli","red_velvet_cake","risotto",
    "samosa","sashimi","scallops","seaweed_salad","shrimp_and_grits",
    "spaghetti_bolognese","spaghetti_carbonara","spring_rolls","steak","strawberry_shortcake",
    "sushi","tacos","takoyaki","tiramisu","tuna_tartare",
    "waffles",
]


def main():
    thai = fetch_thai_food()
    intl = fetch_food101()

    # รวมและลบซ้ำ (เช็คจาก en name)
    seen_en = set()
    merged = []

    for f in thai:
        key = (f.get("en") or "").lower().strip()
        if key:
            seen_en.add(key)
        merged.append(f)

    for f in intl:
        key = (f.get("en") or "").lower().strip()
        if key and key not in seen_en:
            seen_en.add(key)
            merged.append(f)

    # Sort: ไทยก่อน แล้วสากล
    merged.sort(key=lambda x: (0 if x["src"] == "thai" else 1, x.get("th") or x.get("en") or ""))

    # บันทึก
    os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
    with open(OUTPUT, "w", encoding="utf-8") as f:
        json.dump(merged, f, ensure_ascii=False, indent=2)

    print(f"\n✅ บันทึกแล้ว: {OUTPUT}")
    print(f"   รวม {len(merged)} เมนู (ไทย {len(thai)}, สากล {len(intl)}, หลังลบซ้ำ {len(merged)})")


if __name__ == "__main__":
    main()
