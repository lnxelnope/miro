# Google Login บน localhost (พัฒนาในเครื่อง)

บนเว็บ production ใช้ได้ปกติ เพราะ **OAuth Client ใน Google Cloud ลง “Authorized redirect URIs” ของโดเมนจริงไว้แล้ว**  
บน localhost จะล้มเหลวได้ถ้า **ยังไม่ลง URI ของเครื่องคุณ** หรือค่า env ไม่ตรงกับพอร์ตที่รัน

## เช็คลิสต์

### 1) Google Cloud Console → OAuth 2.0 Client (ชนิด Web application)

[Credentials](https://console.cloud.google.com/apis/credentials) → เลือก Client ID ที่ใช้กับแอปนี้

**Authorized JavaScript origins** ต้องมี (ตัวอย่างพอร์ต 3000):

- `http://localhost:3000`

**Authorized redirect URIs** ต้องมี **ตรงทุกตัวอักษร**:

- `http://localhost:3000/api/auth/callback/google`

ถ้ารัน `next dev -p 3001` ต้องเพิ่มอีกชุดเป็น `http://localhost:3001` และ  
`http://localhost:3001/api/auth/callback/google` — **พอร์ตต้องตรงกับที่เปิดในเบราว์เซอร์**

### 2) ไฟล์ `.env.local` (โฟลเดอร์ `admin-panel`)

- `NEXTAUTH_URL` ต้องเป็น origin เดียวกับที่เปิดในเบราว์เซอร์ เช่น `http://localhost:3000`  
  ห้ามใส่ URL production ตอนรันในเครื่อง
- `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` ใช้ชุดเดียวกับที่แก้ใน Console ด้านบนได้ (หรือสร้าง OAuth client แยกสำหรับ dev ก็ได้)
- `AUTH_SECRET` (หรือ `NEXTAUTH_SECRET`) ต้องมีค่า
- `ALLOWED_ADMIN_EMAILS` ต้องมีอีเมล Google ที่คุณใช้ล็อกอิน

### 3) หน้าจอ OAuth consent (โหมด Testing)

ถ้าแอปยังอยู่โหมด **Testing** ต้องไปที่ **Audience → Test users** แล้ว **เพิ่มอีเมล Google ของคุณ** ไม่งั้นล็อกอินได้แค่บัญชีที่ลงไว้

### 4) ข้อความ error ที่เจอบ่อย

| อาการ | สาเหตุที่พบบ่อย |
|--------|------------------|
| `redirect_uri_mismatch` | URI ใน Console ไม่ตรงกับที่ Auth.js ส่ง (มักเป็นพอร์ตผิด หรือเป็น `https` แทน `http`) |
| เข้า Google แล้วกลับมาแล้วโดนปฏิเสธ | อีเมลไม่อยู่ใน `ALLOWED_ADMIN_EMAILS` หรือไม่ใช่ Test user (ตอน consent เป็น Testing) |

รายละเอียดเพิ่มเติม: `SETUP_GOOGLE_AUTH.md`
