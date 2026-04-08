import Link from 'next/link';
import Image from 'next/image';
import {
  Camera,
  Utensils,
  Shield,
  Zap,
  BarChart3,
  ChevronRight,
  Globe,
  Smartphone,
  Download,
  ScanLine,
  MessageSquare,
  Clock,
  Unlock,
  Gift,
  CheckCircle2,
  XCircle,
  Scale,
  Layers,
  Edit3,
  Sparkles,
} from 'lucide-react';
import { publicAsset } from '@/lib/publicAsset';
import { StoreButtons } from '@/components/StoreButtons';

const uspItems = [
  'ไม่ต้องจ่ายก่อน ถึงจะใช้ได้',
  'ไม่ต้องสมัครสมาชิก',
  'สแกนจานด้วย AR',
  'เปิดแล้วใช้ได้ใน 10 วินาที',
  'มีโทเค็นให้ลองฟรี',
  'เลือกได้ 15 แบบอาหาร',
  'แยกทีละอย่างถึงระดับวัตถุดิบ',
  'ถ่ายวัตถุดิบคู่ตาชั่งในรูปเดียว',
  'รวมหลายอย่างเป็นเมนูของฉัน',
  'ใช้ซ้ำที่เคยหาแล้ว ไม่โดนหักโทเค็นซ้ำ',
  'แก้หรือลบหลังวิเคราะห์ได้',
  'เพิ่มรายการแล้วให้ AI ช่วยหาโภชนาการ',
  'ข้อมูลอยู่ในเครื่องคุณ',
  'ใช้งานได้แม้ไม่มีเน็ตบางส่วน',
  'ซื้อโทเค็นแล้วไม่หมดอายุ',
  'ดึงรีเฟรช → วิเคราะห์ทั้งวัน',
  'ลดน้ำหนักแบบไม่ต้องจดทุกมื้อ',
];

const showcaseFeatures = [
  {
    title: 'สแกนจานด้วย AR — แบบที่ไม่เคยมีมาก่อน',
    subtitle: 'ชี้กล้อง สแกน ได้เลขแคล',
    description:
      'เอา AR ไปส่องจานบนโต๊ะ แอปจับอาหาร แยกทีละอย่าง แล้วคำนวณแคลให้แบบเห็นไปเรื่อยๆ ผ่านกล้อง — ใครอยากรู้แคลแบบไม่ต้องพิมพ์เอง นี่คือทางลัดที่ชัดกว่าถ่ายรูปธรรมดา',
    image: '/arcal/screens/store-ar-precision.png',
    imageAlt: 'ArCal สแกน AR จับอาหารบนจาน',
    reverse: false,
  },
  {
    title: 'สรุปทั้งวันด้วยปุ่มเดียว',
    subtitle: 'ดึงรีเฟรช แล้วกดวิเคราะห์ทั้งหมด — สำหรับคนขี้เกียจจด',
    description:
      'หน้าแดชบอร์ด ให้ดึงลงรีเฟรชเพื่อดึงรูปมื้อที่เก็บไว้ในเครื่อง แล้วกด «วิเคราะห์ทั้งหมด» ครั้งเดียว — ได้ตัวเลขโดยประมาณทั้งวันโดยไม่ต้องไล่กรอกทีละมื้อ เหมาะคนอยากผอมแต่ไม่อยากจดทุกคำ: พอได้ภาพรวมก่อน รายละเอียดค่อยตามมาทีหลัง',
    image: '/arcal/screens/dashboard.png',
    imageAlt: 'ArCal แดชบอร์ด ดึงรูปแล้ววิเคราะห์เป็นชุด',
    reverse: true,
  },
  {
    title: 'เปิดแอปแล้วใช้ได้เลย',
    subtitle: 'ไม่สมัคร ไม่ล็อกอิน ไม่ถามยาวเป็นหน้า',
    description:
      'โหลดมาแล้วเริ่มนับได้ทันที ไม่ต้องสร้างบัญชี ไม่มีแบบสอบถามยาวเหยียด ไม่มีหน้าจอเก็บเงินก่อนเข้าใช้ — มีโทเค็นให้ลองอยู่แล้ว สแกนแรกได้ภายในไม่กี่วินาที',
    image: '/arcal/screens/zero-setup.png',
    imageAlt: 'ArCal เปิดแล้วใช้ ไม่ต้องล็อกอิน',
    reverse: false,
  },
  {
    title: 'แยกทีละอย่าง ละเอียดถึงวัตถุดิบ',
    subtitle: 'แก้ได้ ลบได้ ตามใจคุณ',
    description:
      'เช่นแกงแดง — แอปแยกให้เห็นกุ้ง พริกแกง กะทิ ฯลฯ ทีละกรัมแคล ไม่กินอย่างไหนก็ลบออก เติมเองก็ได้ ให้ AI ช่วยเติมโภชนาการ',
    image: '/arcal/screens/store-sub-ingredients.png',
    imageAlt: 'ArCal แยกวัตถุดิบละเอียด',
    reverse: true,
  },
  {
    title: 'เข้าใจอาหารไทย ไม่สับสนกับของเมืองนอก',
    subtitle: 'เลือกแบบอาหารให้ตรงกับที่คุณกิน',
    description:
      'เลือกสไตล์อาหารให้ตรงกับจานของคุณ — ชื่อจาน สูตร และแคลจะไปทางเดียวกับของจริงที่คุณกิน ไม่เอาแกงไปเทียบเป็นคนละชนิด',
    image: '/arcal/screens/cuisines.png',
    imageAlt: 'ArCal เลือกแบบอาหารได้หลายแบบ',
    reverse: false,
  },
  {
    title: 'ข้อมูลอยู่ในมือถือคุณ ไม่หลุดไปไหน',
    subtitle: 'เก็บในเครื่อง — ไม่อัปโหลด ไม่แอบตาม',
    description:
      'บันทึกโภชนาการอยู่ในเครื่องคุณ ไม่ส่งขึ้นเซิร์ฟเวอร์ให้ใครมอง ไม่มีการติดตามแบบลับหลัง — ยิ่งใช้ยิ่งสะสมเมนูของคุณเอง ยิ่งใช้ยิ่งรู้จักนิสัยการกินของคุณ',
    image: '/arcal/screens/local-data.png',
    imageAlt: 'ArCal เก็บข้อมูลในเครื่อง',
    reverse: true,
  },
  {
    title: 'ทำเองที่บ้าน — ถ่ายวัตถุดิบคู่ตาชั่ง',
    subtitle: 'ตาชั่ง ถ้วยตวง อยู่ในรูปเดียวก็พอ',
    description:
      'จัดวัตถุดิบข้างตาชั่งหรือถ้วยตวง แล้วถ่ายรูปเดียว บอกน้ำหนักชัดๆ หรือให้แอปช่วยเดา — สัดส่วนจะสอดคล้องกับที่เห็นในรูป',
    image: '/arcal/screens/store-snap-ingredients-recipe.png',
    imageAlt: 'ArCal ถ่ายวัตถุดิบกับตาชั่ง',
    reverse: false,
  },
  {
    title: 'รวมหลายอย่างเป็นเมนูของฉัน',
    subtitle: 'หลายบรรทัด → หนึ่งเมนู → เก็บไว้ใช้ยาว',
    description:
      'เอาหลายบรรทัดที่วิเคราะห์แล้วมารวมเป็นหนึ่งเมนู ตั้งชื่อ แนบรูปปกจากอัลบั้ม แล้วเก็บในเมนูของฉัน — อยู่ในแอปเดียว เก็บในเครื่องคุณ วิเคราะห์ รวม ใช้ซ้ำ ไม่ต้องย้ายไปโปรแกรมอื่น',
    image: '/arcal/screens/store-snap-ingredients-recipe.png',
    imageAlt: 'ArCal รวมเป็นเมนูของฉัน',
    reverse: true,
  },
  {
    title: 'ใช้ซ้ำที่เคยหาแล้ว ไม่โดนหักโทเค็นซ้ำ',
    subtitle: 'ฐานในเครื่องคือของคุณ',
    description:
      'เมนูหรือวัตถุดิบที่เคยค้นหรือวิเคราะห์แล้วอยู่ในเครื่อง พอกลับมาบันทึกซ้ำจากรายการเดิม ไม่ต้องเสียโทเค็นไปกับการค้นซ้ำไม่รู้จบ — เพราะมันถูกเก็บไว้ใกล้ตัวคุณ ไม่ใช่หายไปบนคลาวด์ที่ควบคุมไม่ได้',
    image: '/arcal/screens/local-data.png',
    imageAlt: 'ArCal ใช้ซ้ำจากที่เก็บในเครื่อง',
    reverse: false,
  },
];

const gridFeatures = [
  {
    icon: ScanLine,
    title: 'สแกนอาหารด้วย AR',
    description:
      'ชี้กล้องแล้วสแกนจานบนโต๊ะ — แอปนับแคลที่ทำแบบนี้ได้ก่อนใครในแนวนี้',
  },
  {
    icon: Camera,
    title: 'วิเคราะห์จากรูปด้วย AI',
    description:
      'ถ่ายมื้อไหนก็ได้ แล้วให้ AI แยกทีละอย่าง พร้อมแคลให้ดูทันที',
  },
  {
    icon: Utensils,
    title: 'แยกทีละอย่างละเอียด',
    description:
      'เห็นทั้งเนื้อ แป้ง น้ำมันที่ซึม — แยกแคลทีละส่วนให้ชัด',
  },
  {
    icon: Globe,
    title: 'เลือกได้ 15 แบบอาหาร',
    description:
      'แกงไทยก็ยังเป็นแกงไทย ก๋วยเตี๋ยวก็ยังเป็นก๋วยเตี๋ยว — ไม่เอาไปเรียกผิดชนิด',
  },
  {
    icon: MessageSquare,
    title: 'บันทึกผ่านแชต',
    description:
      'พิมพ์เล่าวันทั้งวันในข้อความเดียว — แอปช่วยแยกมื้อให้',
  },
  {
    icon: Shield,
    title: 'เป็นส่วนตัว เก็บในเครื่อง',
    description:
      'ไม่ต้องล็อกอิน ไม่ส่งขึ้นเมฆ บันทึกการกินเป็นของคุณจริงๆ',
  },
  {
    icon: Scale,
    title: 'ทำเองที่บ้าน — ถ่ายคู่ตาชั่ง',
    description:
      'วางวัตถุดิบข้างตาชั่งหรือถ้วยตวง แล้วถ่ายรูปเดียว — แอปช่วยอ่านจากภาพหรือใช้ตัวเลขที่คุณใส่',
  },
  {
    icon: Layers,
    title: 'รวมหลายอย่างเป็นเมนูของฉัน',
    description:
      'รวมหลายบรรทัดที่วิเคราะห์แล้วเป็นสูตรเดียว แนบรูปจากอัลบั้ม — กินซ้ำเมื่อไหร่ก็เรียกใช้ได้',
  },
  {
    icon: Zap,
    title: 'ใช้ซ้ำที่เคยหาแล้วคุ้มกว่า',
    description:
      'รายการที่เคยค้นอยู่ในเครื่อง บันทึกซ้ำโดยไม่ต้องเสียโทเค็นไปกับการค้นซ้ำไม่รู้จบ',
  },
  {
    icon: Edit3,
    title: 'แก้ ลบ หรือเพิ่มหลังวิเคราะห์',
    description:
      'ผิดก็แก้ ไม่กินก็ลบ เติมรายการใหม่ให้ AI ช่วยเติมโปรตีน คาร์บ ไขมัน',
  },
  {
    icon: Sparkles,
    title: 'บอกว่ากินอะไร แล้วให้ AI ช่วยหา',
    description:
      'อธิบายมื้อ เลือกจากเมนูของฉันหรือรายการวัตถุดิบ หรือให้ AI ช่วยเติมโภชนาการ — คุณคุมได้ ไม่ใช่กล่องดำ',
  },
];

const steps = [
  {
    step: '01',
    title: 'เปิดแล้วสแกนหรือถ่าย',
    description:
      'ไม่ต้องล็อกอิน เปิดแอปแล้วชี้กล้องสแกน AR — หรือถ่ายรูปมื้อ หรือพิมพ์เล่าว่ากินอะไร',
    icon: ScanLine,
  },
  {
    step: '02',
    title: 'ให้ AI ช่วยคิด',
    description:
      'ไม่กี่วินาที AI จะแยกทีละอย่าง พร้อมแคล โปรตีน คาร์บ ไขมัน — ใช้ Google Gemini',
    icon: Zap,
  },
  {
    step: '03',
    title: 'แก้ให้ตรง แล้วเก็บไว้',
    description:
      'ปรับปริมาณ ลบอย่างที่ไม่ได้กิน — ยิ่งใช้ยิ่งมีเมนูของคุณเองในเครื่อง',
    icon: BarChart3,
  },
];

const comparisonRows = [
  { feature: 'สแกนมื้อด้วย AR', arcal: true, others: false },
  { feature: 'AI แยกทีละอย่างในจาน', arcal: true, others: false },
  { feature: 'แยกแคลถึงระดับวัตถุดิบย่อย', arcal: true, others: false },
  {
    feature: 'ถ่ายวัตถุดิบคู่ตาชั่ง/ถ้วยตวงในรูปเดียว',
    arcal: true,
    others: false,
  },
  {
    feature: 'รวมหลายอย่างเป็นเมนูของฉัน (My Meals)',
    arcal: true,
    others: false,
  },
  {
    feature: 'ใส่รูปเมนูจากอัลบั้ม แล้วบันทึกซ้ำได้ไม่จำกัด',
    arcal: true,
    others: false,
  },
  {
    feature: 'ใช้ซ้ำการค้นเก่าโดยไม่เสียโทเค็นซ้ำ',
    arcal: true,
    others: false,
  },
  {
    feature: 'ลบทีละอย่างที่ไม่ได้กิน',
    arcal: true,
    others: false,
  },
  {
    feature: 'เพิ่มรายการใหม่แล้วให้ AI ช่วยหาโภชนาการ',
    arcal: true,
    others: false,
  },
  {
    feature: 'บอกว่าในมื้อมีอะไร แล้วปรับกับ AI ได้',
    arcal: true,
    others: false,
  },
  {
    feature: 'จดมือฟรี + มีโทเค็นให้ลองตอนเริ่ม',
    arcal: true,
    others: false,
  },
  { feature: 'เลือกแบบอาหารได้ 15 แบบ', arcal: true, others: false },
  { feature: 'แก้วัตถุดิบหลังวิเคราะห์ได้', arcal: true, others: false },
  { feature: 'ไม่ต้องล็อกอิน ไม่บังคับสมาชิก', arcal: true, others: false },
  { feature: 'เก็บในเครื่อง ใช้ได้แม้ไม่มีเน็ตบางส่วน', arcal: true, others: false },
  { feature: 'บันทึกผ่านแชต', arcal: true, others: false },
  { feature: 'ดึงรูปจากเครื่องแล้ววิเคราะห์เป็นชุด', arcal: true, others: false },
  { feature: 'ซื้อโทเค็นแล้วไม่หมดอายุ', arcal: true, others: false },
];

/** ตรงกับ lib/core/services/purchase_service.dart (IAP ชุดปัจจุบัน) */
const energyPackages = [
  {
    name: 'Starter Pack · เริ่มต้น',
    energy: 50,
    price: '$1.99',
    badge: null,
    featured: false,
  },
  {
    name: 'Standard Pack · มาตรฐาน',
    energy: 200,
    price: '$5.99',
    badge: null,
    featured: false,
  },
  {
    name: 'Power Pack · พลังงานเยอะ',
    energy: 500,
    price: '$12.99',
    badge: 'คุ้มสุด',
    featured: true,
  },
];

/** ตรงกับ lib/features/subscription/models/subscription_plan.dart */
const energyPassPlans = [
  {
    name: 'Energy Pass · รายเดือน',
    price: '$9.99',
    period: '/ เดือน',
    badge: null,
    featured: false,
  },
  {
    name: 'Energy Pass · รายปี',
    price: '$22.99',
    period: '/ ปี',
    badge: 'คุ้มสุด',
    featured: true,
  },
];

function HeroSection() {
  return (
    <section className="hero-gradient relative overflow-hidden pt-28 pb-16 lg:pt-36 lg:pb-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="grid items-center gap-12 lg:grid-cols-2 lg:gap-16">
          <div className="text-center lg:text-left">
            <div className="mb-6 inline-flex flex-col items-center gap-2 sm:flex-row lg:items-start">
              <span className="inline-flex items-center gap-2 rounded-full border border-brand-200 bg-brand-50 px-4 py-1.5 text-sm font-medium text-brand-800">
                <ScanLine size={14} className="text-brand-600" />
                นับแคลด้วย AI สแกนจานด้วย AR
              </span>
              <span className="inline-flex items-center gap-2 rounded-full border border-amber-200 bg-amber-50 px-4 py-1.5 text-sm font-medium text-amber-900">
                ไม่ชอบจดทุกคำก็ไม่เป็นไร
              </span>
              <span className="inline-flex items-center gap-2 rounded-full border border-emerald-200 bg-emerald-50 px-4 py-1.5 text-sm font-medium text-emerald-900">
                <Unlock size={14} className="text-emerald-600" />
                ไม่ต้องจ่ายก่อน ถึงจะใช้ได้
              </span>
            </div>

            <h1 className="text-4xl font-extrabold leading-[1.1] tracking-tight text-brand-950 sm:text-5xl lg:text-6xl">
              รู้แคลแบบพอใช้ได้
              <br />
              <span className="gradient-text-hero">โดยไม่ต้องลุยจดเองทุกมื้อ</span>
            </h1>

            <p className="mx-auto mt-6 max-w-xl text-lg text-gray-600 sm:text-xl lg:mx-0">
              อยาก<strong>ลดน้ำหนัก</strong>แต่<strong>ขี้เกียจจด</strong>ทุกมื้อใช่ไหม?
              บนหน้าแดชบอร์ดให้<strong>ดึงลงรีเฟรช</strong>เพื่อดึงรูปอาหารที่ถ่ายเก็บไว้
              แล้วกด <strong>วิเคราะห์ทั้งหมด</strong> <strong>ปุ่มเดียว</strong> — จะได้ภาพรวม
              <strong>แคลโดยประมาณ</strong>ของวันนั้น ตัวเลขอาจไม่เป๊ะเหมือนห้องแล็บ
              แต่พอให้รู้ว่าวันนี้กินประมาณไหน — แบบนี้ก็เริ่ม<strong>รู้ตัว</strong>ได้แล้ว
              โดยไม่รู้สึกว่า &ldquo;ต้องสมบูรณ์แบบถึงจะเริ่มได้&rdquo; พอพร้อมเมื่อไหร่ค่อย
              <strong>แก้ทีละบรรทัด</strong> ลบอย่างที่ไม่ได้กิน เพิ่มรายการ
              หรือไปใช้สแกน AR กับมื้อทำเองที่บ้านทีหลังก็ได้
            </p>

            <div className="mx-auto mt-4 flex max-w-md flex-wrap items-center justify-center gap-x-6 gap-y-2 text-sm font-medium text-brand-700 lg:justify-start">
              <span className="flex items-center gap-1.5">
                <Gift size={15} className="text-brand-500" />
                มีโทเค็นให้ลองฟรี
              </span>
              <span className="flex items-center gap-1.5">
                <Shield size={15} className="text-brand-500" />
                ไม่ต้องสมัครสมาชิก
              </span>
              <span className="flex items-center gap-1.5">
                <Clock size={15} className="text-brand-500" />
                เปิดแล้วใช้ได้ในไม่กี่วินาที
              </span>
              <span className="flex items-center gap-1.5">
                <Unlock size={15} className="text-emerald-600" />
                ไม่มีหน้าจอเก็บเงินก่อนเข้าใช้
              </span>
            </div>

            <StoreButtons className="mt-10" size="large" />

            <p className="mt-5 text-sm text-gray-500">
              เริ่มใช้ฟรี · ไม่ต้องใส่บัตร · ใช้งานบางส่วนได้แม้ไม่มีเน็ต
            </p>
            <p className="mt-3">
              <Link
                href="/"
                className="text-sm font-medium text-brand-700 underline-offset-4 hover:underline"
              >
                English site →
              </Link>
            </p>
          </div>

          <div className="relative mx-auto w-full max-w-md lg:max-w-lg">
            <div className="absolute -inset-8 rounded-3xl bg-gradient-to-br from-brand-300/30 via-brand-200/20 to-brand-400/20 blur-3xl" />
            <Image
              src={publicAsset('/arcal/screens/store-ar-precision.png')}
              alt="ArCal — สแกน AR นับแคลจากจาน (ภาพโปรโมต)"
              width={473}
              height={1024}
              className="relative mx-auto max-h-[min(70vh,520px)] w-auto rounded-2xl shadow-2xl object-contain"
              priority
            />
          </div>
        </div>
      </div>

      <div className="pointer-events-none absolute inset-x-0 bottom-0 h-24 bg-gradient-to-t from-white" />
    </section>
  );
}

function USPBanner() {
  return (
    <div className="overflow-hidden border-y border-brand-100 bg-brand-50/50 py-4">
      <div className="flex animate-scroll items-center gap-8 whitespace-nowrap">
        {[...uspItems, ...uspItems].map((item, i) => (
          <div
            key={i}
            className="flex items-center gap-3 text-sm font-medium text-brand-800"
          >
            <ChevronRight size={14} className="text-brand-500" />
            {item}
          </div>
        ))}
      </div>
    </div>
  );
}

function LazyWeightLossSection() {
  return (
    <section
      id="lazy-tracking"
      className="border-y border-amber-100 bg-gradient-to-b from-amber-50/40 via-white to-white py-16 lg:py-20"
    >
      <div className="mx-auto max-w-3xl px-4 text-center sm:px-6 lg:px-8">
        <h2 className="text-2xl font-bold tracking-tight text-brand-950 sm:text-3xl lg:text-4xl">
          อยากผอม แต่ไม่อยากไล่จดเป็นตาราง
        </h2>
        <p className="mt-4 text-lg leading-relaxed text-gray-600">
          ArCal ทำมาให้คนที่อยาก<strong>รู้ว่าวันนี้กินประมาณเท่าไร</strong> แต่
          <strong>ไม่ไหวถ้าต้องพิมพ์ทุกมื้อ</strong> ในเครื่องคุณก็มีรูปมื้อเก็บไว้อยู่แล้วอยู่ดี —
          ให้แอปดึงขึ้นมา แล้วกด <strong>วิเคราะห์ทั้งหมด ครั้งเดียว</strong> จะได้ตัวเลข
          <strong>แคลกับสารอาหารหลักโดยประมาณ</strong> รอบแรกแค่นี้ก็พอเห็นภาพว่ากินไปทางไหน
          ความละเอียดมาทีหลังตอนคุณ<strong>แก้ทีละบรรทัด</strong>หรือเติมรายละเอียดเอง
        </p>
      </div>
    </section>
  );
}

function SocialProofStrip() {
  const stats = [
    { value: '10 วินาที', label: 'จากเปิดแอปถึงเริ่มใช้' },
    { value: '95%', label: 'ค่ามั่นใจของ AI (โดยประมาณ)' },
    { value: '15', label: 'แบบอาหารให้เลือก' },
    { value: '0', label: 'บังคับให้สมัคร' },
  ];

  return (
    <section className="border-y border-brand-100 bg-brand-950 py-12">
      <div className="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-2 gap-8 lg:grid-cols-4">
          {stats.map((stat) => (
            <div key={stat.label} className="text-center">
              <div className="text-3xl font-extrabold text-brand-400 sm:text-4xl">
                {stat.value}
              </div>
              <div className="mt-1 text-sm text-gray-400">{stat.label}</div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function ShowcaseSection() {
  return (
    <section id="features" className="py-20 lg:py-28">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-3xl text-center">
          <h2 className="text-3xl font-bold tracking-tight text-brand-950 sm:text-4xl lg:text-5xl">
            ครบที่อยากได้{' '}
            <span className="gradient-text">ไม่ยัดของที่ไม่เอา</span>
          </h2>
          <p className="mt-4 text-lg text-gray-500">
            มีทั้งสแกน AR มื้อทำเองที่ถ่ายคู่ตาชั่ง รวมเป็นเมนูของคุณ ใช้ซ้ำจากที่เก็บในเครื่อง
            แก้ทีละอย่างให้ตรงกับอาหารจริง — แอปเดียวที่ไม่รบกวนเวลา ไม่แอบเอาข้อมูลไปไหน และไม่บังคับจ่ายรายเดือน
          </p>
        </div>

        <div className="mt-20 space-y-24 lg:space-y-32">
          {showcaseFeatures.map((feature, i) => (
            <div
              key={feature.title}
              className={`flex flex-col items-center gap-10 lg:gap-16 ${
                feature.reverse ? 'lg:flex-row-reverse' : 'lg:flex-row'
              }`}
            >
              <div className="w-full lg:w-1/2">
                <div className="relative mx-auto max-w-md">
                  <div
                    className={`absolute -inset-6 rounded-3xl blur-2xl ${
                      i % 3 === 0
                        ? 'bg-brand-400/10'
                        : i % 3 === 1
                          ? 'bg-brand-300/10'
                          : 'bg-brand-500/10'
                    }`}
                  />
                  <Image
                    src={publicAsset(feature.image)}
                    alt={feature.imageAlt}
                    width={540}
                    height={1080}
                    className="relative rounded-2xl shadow-xl"
                  />
                </div>
              </div>

              <div className="w-full text-center lg:w-1/2 lg:text-left">
                <div className="mb-3 text-sm font-semibold tracking-wide text-brand-600">
                  {feature.subtitle}
                </div>
                <h3 className="text-2xl font-bold tracking-tight text-brand-950 sm:text-3xl lg:text-4xl">
                  {feature.title}
                </h3>
                <p className="mt-4 text-lg leading-relaxed text-gray-500">
                  {feature.description}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function FeaturesGrid() {
  return (
    <section className="section-gradient py-20 lg:py-28">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="mx-auto mb-16 max-w-3xl text-center">
          <h2 className="text-3xl font-bold tracking-tight text-brand-950 sm:text-4xl">
            ต่างจากแอปทั่วไปยังไง
          </h2>
          <p className="mt-3 text-lg text-gray-500">
            สิบเอ็ดอย่างที่ครอบคลุม — มื้อที่ AI ช่วยสร้างให้แก้ทีละบรรทัดได้ มีสแกน AR
            เมนูเก็บในเครื่อง และใช้ซ้ำสิ่งที่เคยหาแล้วโดยไม่โดนหักโทเค็นซ้ำ
          </p>
        </div>
        <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
          {gridFeatures.map((feature) => (
            <div
              key={feature.title}
              className="glass-card group p-6 transition-all hover:border-brand-300 hover:shadow-md"
            >
              <div className="mb-4 inline-flex rounded-xl bg-brand-50 p-3 text-brand-600 transition-colors group-hover:bg-brand-100">
                <feature.icon size={24} />
              </div>
              <h3 className="mb-2 text-lg font-semibold text-brand-950">
                {feature.title}
              </h3>
              <p className="text-sm leading-relaxed text-gray-500">
                {feature.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function HowItWorksSection() {
  return (
    <section id="how-it-works" className="py-20 lg:py-28">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-3xl text-center">
          <h2 className="text-3xl font-bold tracking-tight text-brand-950 sm:text-4xl lg:text-5xl">
            เริ่มใช้ให้ <span className="gradient-text">ไวภายในไม่กี่วินาที</span>
          </h2>
          <p className="mt-4 text-lg text-gray-500">
            จากเปิดแอปถึงสแกนหรือถ่ายแรก ไม่ต้องรอนาน
          </p>
        </div>

        <div className="mt-16 grid gap-8 lg:grid-cols-3">
          {steps.map((item) => (
            <div key={item.step} className="relative text-center">
              <div className="mx-auto mb-6 flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-brand-500 to-brand-700 shadow-lg shadow-brand-500/25">
                <item.icon size={28} className="text-white" />
              </div>
              <div className="mb-2 text-sm font-bold text-brand-600">
                ขั้นที่ {item.step}
              </div>
              <h3 className="mb-3 text-xl font-bold text-brand-950">
                {item.title}
              </h3>
              <p className="text-gray-500">{item.description}</p>
            </div>
          ))}
        </div>

        <div className="mt-12 text-center">
          <a href="#download" className="cta-button">
            <Download size={20} />
            ลองฟรี
          </a>
        </div>
      </div>
    </section>
  );
}

function AiMealControlSection() {
  return (
    <section
      id="ai-meal-builder"
      className="border-y border-brand-100 bg-gradient-to-b from-white via-brand-50/40 to-white py-20 lg:py-28"
    >
      <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
        <h2 className="text-center text-3xl font-bold tracking-tight text-brand-950 sm:text-4xl">
          ให้ AI ช่วยร่างมื้อ —{' '}
          <span className="gradient-text">แต่ทุกบรรทัดยังเป็นของคุณ</span>
        </h2>
        <p className="mt-4 text-center text-lg leading-relaxed text-gray-600">
          ถ้าคุณอยากได้<strong>แอปที่เริ่มใช้ฟรี</strong> แล้ว<strong>ให้ AI ช่วยสร้างเมนูกับบันทึกมื้อ</strong>
          จากนั้น<strong>แก้รายการ</strong> <strong>ลบอย่างที่ไม่ได้กิน</strong>{' '}
          <strong>เพิ่มบรรทัด</strong> <strong>บอกว่าในจานมีอะไร</strong> และ
          <strong>ให้ AI ช่วยหาโภชนาการวัตถุดิบ</strong> — วิธีใช้แบบนี้คือใจกลางของ ArCal
          ไม่ใช่ฟีเจอร์แถมๆ
        </p>
        <ul className="mt-10 space-y-5 text-base leading-relaxed text-gray-600">
          <li className="flex gap-3">
            <span className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-brand-500" />
            <span>
              <strong className="text-brand-950">สร้างรายการด้วย AI</strong> — จากรูป
              สแกน AR ดึงรูปจากเครื่องเป็นชุด หรือคุยกับ Gemini ให้เสนอวัตถุดิบกับแคล
              คุณตกลงหรือแก้เองได้หมด
            </span>
          </li>
          <li className="flex gap-3">
            <span className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-brand-500" />
            <span>
              <strong className="text-brand-950">แก้ทีละบรรทัด</strong> — ลบวัตถุดิบ
              ปรับน้ำหนัก หรือเพิ่มที่ขาด จดมือยังฟรี ส่วนที่ใช้ AI หนักๆ ใช้โทเค็น Energy ตามที่คุณเลือก
            </span>
          </li>
          <li className="flex gap-3">
            <span className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-brand-500" />
            <span>
              <strong className="text-brand-950">ฉลาดเรื่องวัตถุดิบ</strong> — พิมพ์ค้นหรือเลือกจาก
              <em> เมนูของฉัน</em> กับรายการวัตถุดิบของคุณ เรียก AI ตอนต้องการเติมโภชนาการให้ครบ
            </span>
          </li>
        </ul>
        <p className="mt-10 rounded-2xl border border-brand-200/80 bg-white/90 p-5 text-center text-sm leading-relaxed text-gray-700 shadow-sm">
          <strong className="text-brand-900">เน้นคนขี้เกียจจด:</strong>{' '}
          เริ่มจาก <strong>ดึงรีเฟรช แล้วกดวิเคราะห์ทั้งหมด</strong> ให้ได้ภาพรวมวันก่อน
          รายละเอียดค่อยทีหลัง — ข้อมูลสำคัญเก็บในมือถือคุณ{' '}
          <Link
            href="/"
            className="font-semibold text-brand-800 underline underline-offset-2 hover:text-brand-950"
          >
            ฉบับภาษาอังกฤษ (ถ้าอยากอ่านคำเดิม)
          </Link>
        </p>
      </div>
    </section>
  );
}

function ComparisonSection() {
  return (
    <section className="section-gradient-reverse py-20 lg:py-28">
      <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
        <div className="text-center">
          <h2 className="text-3xl font-bold tracking-tight text-brand-950 sm:text-4xl lg:text-5xl">
            ทำไมถึงเลือก <span className="gradient-text">ArCal?</span>
          </h2>
          <p className="mt-4 text-lg text-gray-500">
            หลายอย่างที่แอปนับแคลทั่วไปมักไม่ทำให้
          </p>
        </div>

        <div className="mt-12 overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-lg">
          <table className="w-full text-left text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-brand-50/50">
                <th className="px-6 py-4 font-semibold text-gray-700">ความสามารถ</th>
                <th className="px-6 py-4 text-center font-semibold text-brand-700">
                  ArCal
                </th>
                <th className="px-6 py-4 text-center font-semibold text-gray-400">
                  แอปอื่น
                </th>
              </tr>
            </thead>
            <tbody>
              {comparisonRows.map((row, i) => (
                <tr
                  key={row.feature}
                  className={i % 2 === 0 ? 'bg-brand-50/30' : 'bg-white'}
                >
                  <td className="px-6 py-3.5 text-gray-700">{row.feature}</td>
                  <td className="px-6 py-3.5 text-center">
                    <CheckCircle2 size={18} className="mx-auto text-brand-500" />
                  </td>
                  <td className="px-6 py-3.5 text-center">
                    <XCircle size={18} className="mx-auto text-gray-300" />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </section>
  );
}

function PricingSection() {
  return (
    <section id="pricing" className="section-gradient py-20 lg:py-28">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-3xl text-center">
          <h2 className="text-3xl font-bold tracking-tight text-brand-950 sm:text-4xl lg:text-5xl">
            จ่ายตามที่ใช้จริง{' '}
            <span className="gradient-text">โทเค็นซื้อแล้วไม่หาย</span>
          </h2>
          <p className="mt-4 text-lg text-gray-500">
            ซื้อแพ็กโทเค็นแบบครั้งเดียวแล้วเก็บไว้ใช้ได้เรื่อยๆ ไม่หมดอายุ หรือเลือกสมัคร{' '}
            <strong className="font-medium text-gray-600">Energy Pass</strong>{' '}
            เพื่อวิเคราะห์ด้วย AI ไม่จำกัด (ราคาเดียวกับในแอป) ส่วนที่จดมือเองยังฟรี
          </p>
        </div>

        <p className="mx-auto mt-10 max-w-2xl text-center text-sm font-semibold tracking-wide text-brand-800">
          แพ็กโทเค็น Energy (ซื้อครั้งเดียว)
        </p>
        <div className="mx-auto mt-4 grid max-w-4xl gap-6 sm:grid-cols-3">
          {energyPackages.map((pkg) => (
            <div
              key={pkg.name}
              className={`relative rounded-2xl border p-6 text-center transition-all hover:scale-105 ${
                pkg.featured
                  ? 'border-brand-400 bg-white shadow-xl glow-green'
                  : 'border-gray-200 bg-white shadow-md'
              }`}
            >
              {pkg.badge && (
                <div className="absolute -top-3 left-1/2 -translate-x-1/2 rounded-full bg-gradient-to-r from-brand-500 to-brand-700 px-3 py-1 text-xs font-bold text-white">
                  {pkg.badge}
                </div>
              )}
              <div className="mt-2 text-3xl font-extrabold text-brand-950">
                {pkg.energy}
              </div>
              <div className="text-sm text-gray-500">โทเค็น Energy</div>
              <div className="my-4 text-2xl font-bold text-brand-700">
                {pkg.price}
              </div>
              <div className="text-xs text-gray-400">{pkg.name}</div>
            </div>
          ))}
        </div>

        <p className="mx-auto mt-14 max-w-2xl text-center text-sm font-semibold tracking-wide text-brand-800">
          Energy Pass (สมัครสมาชิก)
        </p>
        <div className="mx-auto mt-4 grid max-w-2xl gap-6 sm:grid-cols-2">
          {energyPassPlans.map((plan) => (
            <div
              key={plan.name}
              className={`relative rounded-2xl border p-6 text-center transition-all hover:scale-105 ${
                plan.featured
                  ? 'border-brand-400 bg-white shadow-xl glow-green'
                  : 'border-gray-200 bg-white shadow-md'
              }`}
            >
              {plan.badge && (
                <div className="absolute -top-3 left-1/2 -translate-x-1/2 rounded-full bg-gradient-to-r from-brand-500 to-brand-700 px-3 py-1 text-xs font-bold text-white">
                  {plan.badge}
                </div>
              )}
              <div className="mt-2 flex items-baseline justify-center gap-1">
                <span className="text-3xl font-extrabold text-brand-950">
                  {plan.price}
                </span>
                <span className="text-sm text-gray-500">{plan.period}</span>
              </div>
              <div className="mt-3 text-sm text-gray-500">
                วิเคราะห์ด้วย AI ไม่จำกัด เหรียญสะสมพิเศษ ติดต่อทีมได้เร็วขึ้น
              </div>
              <div className="mt-4 text-xs text-gray-400">{plan.name}</div>
            </div>
          ))}
        </div>

        <div className="mt-8 text-center text-sm text-gray-400">
          <p>
            มีโทเค็นให้ตอนเปิดแอปครั้งแรก · วิเคราะห์ด้วย AI ฟรีวันละ 1 ครั้งเมื่อต่อสตรีค ·
            จดมือเองฟรีตลอด
          </p>
        </div>
      </div>
    </section>
  );
}

function DownloadSection() {
  return (
    <section
      id="download"
      className="relative overflow-hidden py-24 lg:py-32"
    >
      <div className="absolute inset-0 hero-gradient" />
      <div className="relative mx-auto max-w-4xl px-4 text-center sm:px-6 lg:px-8">
        <h2 className="text-3xl font-bold tracking-tight text-brand-950 sm:text-4xl lg:text-5xl">
          เริ่มใช้ได้ใน <span className="gradient-text">ไม่กี่วินาที</span>
        </h2>
        <p className="mx-auto mt-4 max-w-xl text-lg text-gray-600">
          ไม่ต้องสมัคร ไม่ต้องใส่บัตร ไม่มีแบบทดสอบยาว เหมือนกดโหลดแล้วก็เริ่มได้
          มีโทเค็นให้ลองใช้ AI นับแคลทันที
        </p>

        <StoreButtons className="mt-10" size="large" />

        <div className="mt-12 flex flex-wrap items-center justify-center gap-8 text-sm font-medium text-gray-500">
          <div className="flex items-center gap-2">
            <Shield size={16} className="text-brand-500" />
            ไม่ต้องมีบัญชีก็ใช้ได้
          </div>
          <div className="flex items-center gap-2">
            <Smartphone size={16} className="text-brand-500" />
            รองรับแอนดรอยด์และไอโอเอส
          </div>
          <div className="flex items-center gap-2">
            <Gift size={16} className="text-brand-500" />
            มีโทเค็นให้ลองตั้งแต่แรก
          </div>
        </div>
      </div>
    </section>
  );
}

export default function ThaiHomePage() {
  return (
    <div lang="th" className="min-h-screen bg-white pb-16">
      <HeroSection />
      <USPBanner />
      <LazyWeightLossSection />
      <SocialProofStrip />
      <ShowcaseSection />
      <FeaturesGrid />
      <HowItWorksSection />
      <AiMealControlSection />
      <ComparisonSection />
      <PricingSection />
      <DownloadSection />

      <div className="mx-auto max-w-7xl px-4 py-8 text-center">
        <Link
          href="/"
          className="inline-flex items-center gap-2 text-sm font-medium text-brand-700 hover:underline"
        >
          <ChevronRight className="h-4 w-4 rotate-180" />
          ไปหน้าภาษาอังกฤษ
        </Link>
      </div>
    </div>
  );
}
