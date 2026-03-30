# MiRO Admin Panel - Deployment Guide

## โปรดอ่านก่อน: production ใช้ Cloud Run — ไม่ใช่ Firebase Hosting

- **Admin panel (Next.js)** ในโปรเจกต์นี้ deploy ไป **Google Cloud Run** (region `asia-southeast1`) คู่กับโปรเจกต์ Firebase/GCP `miro-d6856`  
  - คู่มือหลัก: **[DEPLOYMENT_GCP.md](./DEPLOYMENT_GCP.md)** และ **[CLOUD_RUN.md](./CLOUD_RUN.md)**  
  - ตัวอย่าง URL ปัจจุบัน: `https://admin-panel-65396857547.asia-southeast1.run.app`
- **`firebase.json` → hosting** ใน repo นี้ชี้ไปที่ **`website/deploy`** (เว็บไซต์/landing) เท่านั้น — **ไม่ได้ host admin-panel**
- ส่วนด้านล่างนี้คือทางเลือก **Vercel** (deploy Next.js แบบอื่น) ถ้าทีมต้องการใช้แทน Cloud Run

---

## 🚀 Vercel Deployment (ทางเลือก — ไม่ใช่ production ปัจจุบันของ MiRO)

### Prerequisites
- Vercel account (https://vercel.com)
- Firebase Service Account Key
- Admin credentials

---

## 📋 Step-by-Step Deployment

### 1. Install Vercel CLI (ถ้ายังไม่มี)
```bash
npm install -g vercel
```

### 2. Login to Vercel
```bash
vercel login
```

### 3. Navigate to admin-panel directory
```bash
cd admin-panel
```

### 4. Deploy to Vercel
```bash
vercel
```

Follow the prompts:
- Set up and deploy? **Y**
- Which scope? (Select your account)
- Link to existing project? **N**
- What's your project's name? `miro-admin-panel`
- In which directory is your code located? `./`
- Want to modify settings? **N**

### 5. Set Environment Variables

Go to Vercel Dashboard → Project Settings → Environment Variables

Add these variables for **Production**:

#### Firebase Admin SDK
```
FIREBASE_PROJECT_ID=miro-d6856
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-fbsvc@miro-d6856.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----
... (copy จาก .env.local) ...
-----END PRIVATE KEY-----"
```

#### Admin Authentication
```
ADMIN_USERNAME=lnxelnope
ADMIN_PASSWORD=6six6yesonly
```

#### JWT Secret (ควรเปลี่ยนเป็น random string ใหม่)
```
JWT_SECRET=your-super-secret-random-string-here-change-me
```

#### Next.js
```
NODE_ENV=production
```

### 6. Redeploy with Environment Variables
```bash
vercel --prod
```

---

## 🔒 Security Checklist

### Before Production:
- [ ] เปลี่ยน `JWT_SECRET` เป็น random string ที่ปลอดภัย
- [ ] เปลี่ยน `ADMIN_PASSWORD` เป็นรหัสผ่านที่แข็งแรง
- [ ] ตรวจสอบว่า `.env.local` และ `serviceAccountKey.json` ไม่ถูก commit ไป Git
- [ ] ตรวจสอบ Firestore Security Rules
- [ ] ตั้งค่า CORS ใน Firebase Functions (ถ้าจำเป็น)
- [ ] เพิ่ม domain ของ Vercel ใน Firebase Authorized Domains

---

## 📊 Firestore Indexes (Required)

สร้าง composite indexes ใน Firebase Console:

### Index 1: Transactions by deviceId + createdAt
```
Collection: transactions
Fields:
  - deviceId (Ascending)
  - createdAt (Descending)
```

### Index 2: Transactions by userId + createdAt
```
Collection: transactions
Fields:
  - userId (Ascending)
  - createdAt (Descending)
```

**สร้างได้ที่:** Firebase Console → Firestore Database → Indexes

หรือคลิก link ที่แสดงใน error logs

---

## 🔧 Manual Deploy Alternative

### Option 2: Deploy via Vercel Dashboard

1. Go to https://vercel.com/new
2. Import Git Repository หรือ Upload folder
3. Select `admin-panel` directory
4. Set Environment Variables (same as above)
5. Click Deploy

---

## ✅ Verify Deployment

After deployment, test these features:

1. **Login** - ใช้ admin credentials
2. **Dashboard** - ดู metrics แสดงถูกต้อง
3. **User Search** - ค้นหา user และดู details
4. **User Management** - Top-up, Reset Streak, Ban/Unban
5. **Subscription Management** - Cancel, Extend, Activate
6. **Config Management** - แก้ไข promotions, rewards, challenges
7. **Subscriptions Page** - ดู metrics และ subscribers list

---

## 🐛 Troubleshooting

### Error: Firebase Admin initialization failed
- ตรวจสอบว่า `FIREBASE_PRIVATE_KEY` ถูก format ถูกต้อง (มี `\n` สำหรับ line breaks)
- ตรวจสอบว่า environment variables ถูกตั้งใน Vercel

### Error: The query requires an index
- สร้าง Firestore indexes ตาม link ที่แสดงใน error
- รอ 2-5 นาทีให้ index build เสร็จ

### Error: JWT Secret is required
- ตรวจสอบว่าตั้ง `JWT_SECRET` environment variable แล้ว
- Redeploy หลังตั้งค่า

### Error: Cannot read properties of null
- ตรวจสอบว่า Firebase Admin SDK initialize สำเร็จ
- ดู logs ใน Vercel Dashboard → Deployments → Functions

---

## 📝 Post-Deployment

### Update Admin Credentials
```bash
# In Vercel Dashboard:
# Project Settings → Environment Variables
# Update ADMIN_USERNAME and ADMIN_PASSWORD
# Click "Redeploy" after changes
```

### Monitor Logs
```bash
vercel logs <deployment-url>
```

### Check Performance
- Vercel Dashboard → Analytics
- Monitor response times และ error rates

---

## 🔗 Useful Links

- Vercel Dashboard: https://vercel.com/dashboard
- Firebase Console: https://console.firebase.google.com
- Next.js Deployment Docs: https://nextjs.org/docs/app/building-your-application/deploying

---

## 💡 Tips

1. **Development vs Production:**
   - Development: ใช้ `serviceAccountKey.json` file
   - Production: ใช้ environment variables

2. **Automatic Deployments:**
   - Connect Git repository ใน Vercel
   - Auto-deploy on push to main branch

3. **Custom Domain:**
   - Vercel Dashboard → Project → Settings → Domains
   - เพิ่ม custom domain (e.g., admin.miro.app)

4. **Preview Deployments:**
   - แต่ละ branch ได้ preview URL ของตัวเอง
   - ทดสอบ changes ก่อน merge to main

---

## 📞 Support

หากมีปัญหา:
1. Check Vercel logs
2. Check Firebase Console logs
3. ดู error messages ใน browser DevTools Console

---

**Last Updated:** 2026-02-18
**Version:** 1.0.0
