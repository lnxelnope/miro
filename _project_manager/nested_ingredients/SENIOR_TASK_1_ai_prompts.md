# 🤖 SENIOR TASK 1: แก้ AI Prompts (3 จุด)

> **ระดับความยาก:** 🔴 Senior (ยาก — ต้องเข้าใจ AI behavior)  
> **เวลาประมาณ:** 2-3 ชั่วโมง  
> **ความรู้ที่ต้องมี:** AI prompting, JSON structure, calorie counting logic

---

## 🎯 เป้าหมาย

แก้ไข AI prompts ทั้ง 3 จุดให้รองรับ hierarchical ingredients และป้องกัน double counting

---

## 📍 จุดที่ต้องแก้ (3 ไฟล์)

1. **Image Analysis** — `lib/core/ai/gemini_service.dart` (`_getImageAnalysisPrompt()`, line ~661)
2. **Text Analysis** — `lib/core/ai/gemini_service.dart` (`_getTextAnalysisPrompt()`, line ~803)
3. **Chat Analysis** — `functions/src/analyzeFood.ts` (`buildChatPrompt()`, line ~376)

---

## ⚠️ Critical Requirements

### 1. Calorie Counting Rules (ต้องเข้าใจก่อน)

```
MyMeal.totalCalories = sum ของ ROOT ingredients เท่านั้น
  ├── ROOT ingredient 1: 150 kcal  ✅ นับ
  │   ├── SUB 1: 100 kcal          ❌ ไม่นับ (อธิบาย)
  │   ├── SUB 2: 30 kcal           ❌ ไม่นับ (อธิบาย)
  │   └── SUB 3: 20 kcal           ❌ ไม่นับ (อธิบาย)
  └── ROOT ingredient 2: 50 kcal   ✅ นับ

sum(ROOT) = 150 + 50 = 200 kcal
sum(SUB of ROOT 1) ≈ 150 kcal (breakdown, not addition)
```

**กฎสำคัญ:**
- `sum(ROOT.calories)` MUST equal `nutrition.calories`
- `sum(sub_ingredients.calories)` ≈ parent ROOT.calories
- NEVER put both composite AND raw materials at ROOT level

---

## 📋 Implementation Steps

### Phase 1: เตรียม Prompt Rules (เขียนครั้งเดียว ใช้ทั้ง 3 จุด)

**สร้าง prompt section ใหม่:**

```text
INGREDIENT HIERARCHY RULES (CRITICAL — prevents double counting):

1. "ingredients_detail" contains ONLY recognizable food components at the ROOT level.
   These ROOT items are what get COUNTED for total calories.
   
2. Each ROOT ingredient MAY have "sub_ingredients" — these are the atomic breakdown
   showing what the component is made of. Sub-ingredients are INFORMATIONAL ONLY.
   
3. CALORIE RULES:
   - sum(ROOT.calories) MUST equal nutrition.calories (the total)
   - sum(sub_ingredients.calories) ≈ parent ROOT ingredient calories
   - NEVER put both a composite AND its raw materials at ROOT level
   
4. When to use sub_ingredients:
   - Deep-fried items → show meat + batter + absorbed oil
   - Sauces → show base ingredients (sugar, vinegar, chili)
   - Processed foods → show components
   - Simple items (plain rice, raw egg) → no sub_ingredients needed
   - Packaged multi-item foods → show per-unit breakdown

5. Each ingredient and sub_ingredient should include:
   - "name": Thai name
   - "name_en": English name (optional)
   - "detail": Preparation/composition description (optional)
   - "amount", "unit": Quantity
   - "calories", "protein", "carbs", "fat": Macros

WRONG (double counting):
{
  "ingredients_detail": [
    {"name": "ไก่ทอดแป้ง", "calories": 150},
    {"name": "เนื้อไก่", "calories": 100},     ← DUPLICATE!
    {"name": "แป้ง", "calories": 30},          ← DUPLICATE!
    {"name": "น้ำมัน", "calories": 80}         ← DUPLICATE!
  ]
}
Sum = 360 kcal ≠ nutrition.calories (300 kcal) ❌

CORRECT (hierarchical):
{
  "nutrition": {"calories": 300, ...},
  "ingredients_detail": [
    {
      "name": "ไก่ชิ้นเล็กทอดแป้ง",
      "name_en": "Fried Battered Chicken Pieces",
      "detail": "Deep-fried chicken coated in seasoned flour batter",
      "calories": 250,
      "sub_ingredients": [
        {"name": "เนื้อไก่หน้าอก", "name_en": "Chicken Breast Meat", "calories": 132, ...},
        {"name": "แป้งปรุงรส", "name_en": "Seasoned Flour Batter", "calories": 48, ...},
        {"name": "น้ำมันที่ดูดซับ", "name_en": "Absorbed Frying Oil", "calories": 70, ...}
      ]
    },
    {
      "name": "ซอสจิ้ม",
      "name_en": "Dipping Sauce",
      "calories": 50,
      ...
    }
  ]
}
Sum(ROOT) = 250 + 50 = 300 kcal ✅
Sum(SUB of first ROOT) = 132 + 48 + 70 = 250 ≈ parent ✅
```

---

### Phase 2: แก้ Image Analysis Prompt

**ไฟล์:** `lib/core/ai/gemini_service.dart`

**หา method:** `String _getImageAnalysisPrompt()`

**ขั้นตอน:**

1. **เพิ่ม hierarchy rules section** (ใช้ prompt จาก Phase 1)
   - วางไว้หลังจากส่วน "JSON FORMAT REQUIREMENTS"

2. **อัปเดต example JSON** ให้มี `sub_ingredients`

   ดูตัวอย่างเต็มใน `NESTED_INGREDIENTS_PLAN.md` (line 240-363)

3. **เพิ่ม schema สำหรับ `detail` และ `sub_ingredients`:**

   ```dart
   "properties": {
     "ingredients_detail": {
       "type": "array",
       "items": {
         "type": "object",
         "properties": {
           "name": {"type": "string"},
           "name_en": {"type": "string"},
           "detail": {"type": "string"},           // NEW
           "amount": {"type": "number"},
           "unit": {"type": "string"},
           "calories": {"type": "number"},
           "protein": {"type": "number"},
           "carbs": {"type": "number"},
           "fat": {"type": "number"},
           "sub_ingredients": {                    // NEW
             "type": "array",
             "items": {
               "type": "object",
               "properties": {
                 "name": {"type": "string"},
                 "name_en": {"type": "string"},
                 "detail": {"type": "string"},
                 "amount": {"type": "number"},
                 "unit": {"type": "string"},
                 "calories": {"type": "number"},
                 "protein": {"type": "number"},
                 "carbs": {"type": "number"},
                 "fat": {"type": "number"}
               }
             }
           }
         }
       }
     }
   }
   ```

---

### Phase 3: แก้ Text Analysis Prompt

**ไฟล์:** `lib/core/ai/gemini_service.dart`

**หา method:** `String _getTextAnalysisPrompt()`

**ขั้นตอน:**

1. **Copy hierarchy rules จาก Phase 1** (เหมือนกับ Image Analysis)
2. **อัปเดต example JSON** (เหมือนกับ Image Analysis)
3. **อัปเดต schema** (เหมือนกับ Image Analysis)

**หมายเหตุ:** Text analysis ต้องระวังเรื่อง ambiguity มากกว่า image
- "ไก่ทอด 1 serving" → ต้อง infer ว่ามีแป้ง, น้ำมัน
- "ข้าวผัด" → composite มาก ต้องแยก ingredient ให้ถูก

---

### Phase 4: แก้ Chat Analysis Prompt (Backend)

**ไฟล์:** `functions/src/analyzeFood.ts`

**หา function:** `buildChatPrompt()`

**ขั้นตอน:**

1. **เพิ่ม hierarchy rules** (เหมือนเดิม)
2. **อัปเดต example JSON** (เหมือนเดิม)

**ความแตกต่าง:**
- Chat context มี conversation history → AI ต้อง infer จาก context
- เช่น: "กินไก่ทอดเมื่อกี้ 5 ชิ้น" → ต้องอ้างอิง meal ก่อนหน้า

**เพิ่ม instruction:**

```text
CHAT CONTEXT HANDLING:
- If user references previous meal ("อีก 2 ชิ้น", "เพิ่ม"), look at conversation history
- Maintain hierarchical structure consistent with previous analyses
- If user asks "มีอะไรบ้าง", explain sub_ingredients breakdown
```

---

## 🧪 Testing Strategy

### 1. Unit Test Cases (AI Response)

**Simple Foods (ไม่ต้องมี sub):**
- ข้าวเปล่า 1 ถ้วย → flat ingredients (no sub)
- ไข่ต้ม 1 ฟอง → flat (no sub)

**Deep-fried Foods (ต้องมี sub):**
- KFC Chicken Pop → ไก่+แป้ง+น้ำมัน as subs of "ไก่ทอดแป้ง"
- ปลาทอด → ปลา+แป้ง+น้ำมัน

**Composite Dishes:**
- ข้าวผัดไก่ → ข้าว, ไก่, ผัก, ไข่, น้ำมัน (ROOT), NO sub (เพราะไม่มี composite item)
- แกงเขียวหวาน → กะทิ, เนื้อ, ผัก (ROOT), NO sub

**Sauces:**
- Sweet Chili Sauce → มี sub (chili paste, sugar, vinegar)

**Packaged Foods:**
- Pocky Box (10 sticks) → ROOT: "Pocky Stick" × 10, SUB: chocolate coating, biscuit, sugar

---

### 2. Validation Checks

สำหรับแต่ละ test case:

```python
# Pseudo-code for validation
def validate_response(response):
    nutrition_total = response['nutrition']['calories']
    root_sum = sum(ing['calories'] for ing in response['ingredients_detail'])
    
    # Rule 1: ROOT sum must equal nutrition total
    assert abs(root_sum - nutrition_total) < 5, f"ROOT sum {root_sum} ≠ total {nutrition_total}"
    
    # Rule 2: Each ROOT with subs → sub sum ≈ parent
    for ing in response['ingredients_detail']:
        if 'sub_ingredients' in ing and ing['sub_ingredients']:
            sub_sum = sum(sub['calories'] for sub in ing['sub_ingredients'])
            parent_cal = ing['calories']
            tolerance = parent_cal * 0.1  # 10% tolerance
            assert abs(sub_sum - parent_cal) < tolerance, \
                f"Sub sum {sub_sum} ≠ parent {parent_cal} for {ing['name']}"
    
    # Rule 3: No duplicate names at ROOT level
    root_names = [ing['name'].lower() for ing in response['ingredients_detail']]
    for ing in response['ingredients_detail']:
        if 'sub_ingredients' in ing and ing['sub_ingredients']:
            for sub in ing['sub_ingredients']:
                assert sub['name'].lower() not in root_names, \
                    f"Duplicate: {sub['name']} appears in both ROOT and SUB"
```

---

### 3. Manual Testing

1. **Image Analysis:**
   - ถ่ายรูป KFC Chicken Pop
   - ตรวจสอบ response ว่ามี sub_ingredients
   - ตรวจสอบ calorie sum

2. **Text Analysis:**
   - พิมพ์ "ไก่ทอด 1 serving"
   - ตรวจสอบว่า AI infer แป้ง+น้ำมัน เป็น sub

3. **Chat Analysis:**
   - Chat "กินไก่ทอด KFC"
   - Chat "กินอีก 2 ชิ้น"
   - ตรวจสอบว่า maintain structure เหมือนเดิม

---

## ⚠️ Common Pitfalls

### 1. AI ยังคง double count

**สาเหตุ:** Prompt ไม่ชัดเจนพอ

**แก้:**
- เน้น "NEVER put both composite AND raw materials at ROOT"
- ใส่ตัวอย่าง WRONG vs CORRECT มากขึ้น
- ใช้ bold text, ALL CAPS สำหรับ rules สำคัญ

### 2. AI ไม่สร้าง sub_ingredients เลย

**สาเหตุ:** Prompt บอกว่า "optional" เยอะเกินไป

**แก้:**
- เปลี่ยนจาก "MAY have sub_ingredients" เป็น "SHOULD have sub_ingredients for composite items"
- ให้ AI think step-by-step: "Is this item composite? → Yes → List subs"

### 3. sub_ingredients มี sub ซ้อนหลายชั้น

**ปัญหา:** AI สร้าง depth 2, 3, 4... (ไม่จำเป็น)

**แก้:**
- เพิ่ม rule: "sub_ingredients should NOT have nested sub_ingredients (max 1 level)"

### 4. Calorie sum ไม่ตรง

**สาเหตุ:** AI estimate แคลไม่แม่น

**แก้:**
- เน้น "sum(ROOT.calories) MUST EXACTLY equal nutrition.calories"
- ใช้ JSON schema validation (ถ้าทำได้)

---

## 🔄 Iteration Process

1. **Deploy prompts ใหม่** → test
2. **Collect AI responses** ที่ผิด
3. **วิเคราะห์** ว่า AI ทำผิดตรงไหน
4. **Adjust prompt** → เน้นส่วนที่ AI ทำผิด
5. **Repeat** จนกว่า success rate > 90%

**คาดว่าต้อง iterate 3-5 รอบ**

---

## 📊 Success Criteria

- [ ] Image analysis → hierarchical ingredients (90%+ cases)
- [ ] Text analysis → hierarchical ingredients (90%+ cases)
- [ ] Chat analysis → consistent with context (85%+ cases)
- [ ] No double counting (sum(ROOT) = nutrition total)
- [ ] Simple foods → no unnecessary subs
- [ ] Complex foods → appropriate subs

---

## 🔜 Next Steps

**เมื่อทำเสร็จ:**
- → `SENIOR_TASK_2_provider_logic.md`

**Dependencies:**
- ✅ JUNIOR_TASK_1 (models)
- ✅ JUNIOR_TASK_2 (build_runner)

---

## 🆘 ถ้าติดปัญหา

1. **AI ทำผิดซ้ำๆ:** ใส่ตัวอย่างเพิ่ม (few-shot learning)
2. **Calorie ไม่ตรง:** ลอง prompt "Think step-by-step: 1) Calculate ROOT sum 2) Adjust to match total"
3. **Response format ผิด:** ใช้ JSON schema validation (ถ้ามี)
4. **Backend vs frontend ไม่เหมือนกัน:** ตรวจสอบว่า prompt ใน `analyzeFood.ts` ตรงกับ `gemini_service.dart` หรือไม่

---

**หมายเหตุ:** Task นี้เป็น Senior task ที่ยากที่สุด ต้องใช้เวลา iterate และทดสอบมาก อดทนและ experiment!
