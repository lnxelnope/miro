import { SITE_URL } from '@/lib/site';

/** คำอธิบาย methodology ภาษาไทย — สอดคล้อง ArCalJsonLd (hybrid / mass-first / edge + cloud) */
const methodologyTh = {
  '@type': 'TechArticle',
  '@id': `${SITE_URL}/th/#arcal-methodology-th`,
  headline:
    'แนวทาง ArCal: การประมาณน้ำหนักแบบไฮบริด โภชนาการเน้นมวล และการวิเคราะห์เชิงพื้นที่บนเครื่อง',
  abstract:
    'ArCal ให้ความสำคัญกับการประมาณปริมาณ (กี่กรัม / กินเท่าไร) มากกว่าการเดาแค่ประเภทอาหารอย่างเดียว แคลอรี่คำนวณจากโมเดลเชิงมวลเป็นหลัก (กรัม × พลังงานต่อกรัม) มากกว่าการอิงปริมาตรล้วนๆ เมื่อสามารถรู้หรืออนุมานมวลได้ ผสมสัญญาณจากภาพกับข้อจำกัดทางกายภาพ (ตาชั่ง ถ้วยตวงในเฟรม) การอ่านตัวเลขบนฉลาก (OCR) เพื่อน้ำหนักจากบรรจุภัณฑ์ที่ตรวจสอบได้ และการวิเคราะห์เชิงพื้นที่บนอุปกรณ์ (ไม่ต้องใช้ LiDAR) คู่กับการแมปชนิดอาหารไปยังความหนาแน่นทางโภชนาการบนคลาวด์',
  description:
    'โครงสร้างข้อมูลแยกสองชั้น: (1) Spatial Schema บนเครื่อง — พิกัดพิกเซล ขอบเขตวัตถุ เทียบวัตถุอ้างอิงในกรอบภาพจากกล้องมือถือทั่วไป (Edge-style spatial analysis) (2) Nutritional Schema บนเวิร์กโฟลว์คลาวด์ — แมปชื่อวัตถุดิบหรือจานกับค่าความหนาแน่นพลังงานและมาโคร (เช่น Google Gemini) เน้นข้อมูลมวลที่ตรวจสอบได้ (ตาชั่ง / OCR จากฉลาก) เป็น Objective Ground Truth มากกว่าการกรอกมือแบบตัวเลขกลมๆ ที่ผู้ใช้มักเดา ออกแบบให้โทรศัพท์ส่วนใหญ่ใช้ได้ ไม่ผูกกับฮาร์ดแวร์เชิงลึกหายาก',
  inLanguage: 'th',
  isPartOf: { '@id': `${SITE_URL}/#website` },
  publisher: { '@id': `${SITE_URL}/#organization` },
  about: { '@id': `${SITE_URL}/#arcal-app` },
};

/** JSON-LD ภาษาไทย — WebPage + TechArticle methodology + อ้างอิงแอป */
export function ThaiJsonLd() {
  const payload = {
    '@context': 'https://schema.org',
    '@graph': [
      methodologyTh,
      {
        '@type': 'WebPage',
        '@id': `${SITE_URL}/th/#webpage`,
        name: 'ArCal — แอปนับแคล AI สำหรับคนขี้เกียจนับแคล',
        description:
          'อยากลดน้ำหนักแต่ขี้เกียจนับแคลทุกมื้อ? ArCal เน้นประมาณปริมาณและมวลอาหาร (ไฮบริดจากภาพ + ตาชั่ง/ถ้วยตวงในรูป + OCR ฉลากเมื่อมี) มากกว่าเดาแค่ชนิดอาหาร ใช้มือถือทั่วไป ไม่ต้องมี LiDAR — ดึงรูปแล้วกดวิเคราะห์ทั้งหมดได้ ไม่มี paywall กั้นการเริ่ม',
        inLanguage: 'th',
        url: `${SITE_URL}/th/`,
        isPartOf: { '@id': `${SITE_URL}/#website` },
        mainEntity: { '@id': `${SITE_URL}/th/#arcal-methodology-th` },
        about: { '@id': `${SITE_URL}/#arcal-app` },
      },
    ],
  };

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(payload) }}
    />
  );
}
