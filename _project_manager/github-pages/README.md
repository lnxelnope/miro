# MIRO Legal Pages

GitHub Pages สำหรับเอกสารทางกฎหมายของแอป MIRO

## ขั้นตอนการใช้งาน:

### 1. สร้าง GitHub Repository ใหม่

```bash
# สร้าง repo ชื่อ miro-legal (public repo)
# ไปที่ https://github.com/new
```

### 2. Push ไฟล์ทั้งหมดใน folder นี้ขึ้น repo

```bash
cd _project_manager/github-pages
git init
git add .
git commit -m "Add legal documents for MIRO"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/miro-legal.git
git push -u origin main
```

### 3. เปิด GitHub Pages

1. ไปที่ Repository Settings
2. เลือก **Pages** ในเมนูซ้าย
3. Source: **Deploy from a branch**
4. Branch: **main** / **root**
5. Save

### 4. รอ 1-2 นาที แล้วเข้าถึงได้ที่:

```
https://YOUR_USERNAME.github.io/miro-legal/
https://YOUR_USERNAME.github.io/miro-legal/privacy-policy.html
https://YOUR_USERNAME.github.io/miro-legal/terms-of-service.html
```

### 5. เอา URL นี้ใส่ใน Play Console

**Google Play Console → App content → Privacy Policy:**

ใส่ URL:
```
https://YOUR_USERNAME.github.io/miro-legal/privacy-policy.html
```

---

## ไฟล์ที่มี:

- `index.html` - หน้าแรก (redirect/link ไป privacy + terms)
- `privacy-policy.html` - นโยบายความเป็นส่วนตัว
- `terms-of-service.html` - ข้อกำหนดการใช้งาน
- `README.md` - คู่มือนี้

---

## หมายเหตุ:

- **ต้องเป็น public repo** เท่านั้น (ถึงจะใช้ GitHub Pages ฟรีได้)
- เนื้อหาตรงกับใน app ทุกประการ
- ถ้าแก้ไขเนื้อหา → commit + push ใหม่ → GitHub Pages จะอัพเดทอัตโนมัติ
