import * as fs from 'fs';
import * as path from 'path';
import { TranslationServiceClient } from '@google-cloud/translate';
import { OFFER_LOCALES, type OfferLocale } from './offer-locales';

type LocaleMap = Partial<Record<OfferLocale, string>>;

let client: TranslationServiceClient | null = null;
let projectId: string | null = null;

/** ใช้ credential เดียวกับ Firebase Admin — ห้ามพึ่ง ADC บน localhost */
function getServiceAccountForTranslate(): {
  projectId: string;
  credentials: { client_email: string; private_key: string };
} | null {
  const email = process.env.FIREBASE_CLIENT_EMAIL;
  const keyRaw = process.env.FIREBASE_PRIVATE_KEY;
  const pid = process.env.FIREBASE_PROJECT_ID;

  if (pid && email && keyRaw) {
    return {
      projectId: pid,
      credentials: {
        client_email: email,
        private_key: keyRaw.replace(/\\n/g, '\n'),
      },
    };
  }

  const jsonPath = path.join(process.cwd(), 'serviceAccountKey.json');
  if (fs.existsSync(jsonPath)) {
    try {
      const sa = JSON.parse(fs.readFileSync(jsonPath, 'utf8')) as {
        project_id?: string;
        client_email?: string;
        private_key?: string;
      };
      if (sa.project_id && sa.client_email && sa.private_key) {
        return {
          projectId: sa.project_id,
          credentials: {
            client_email: sa.client_email,
            private_key: sa.private_key,
          },
        };
      }
    } catch {
      return null;
    }
  }

  return null;
}

/** ใช้ใน API route ตรวจว่าแปลได้จริง */
export function hasTranslateCredentials(): boolean {
  return getServiceAccountForTranslate() !== null;
}

function grpcErrorDetails(e: unknown): string {
  if (e && typeof e === 'object') {
    const x = e as Record<string, unknown>;
    if (typeof x.details === 'string' && x.details.trim()) return x.details;
    if (typeof x.message === 'string' && x.message.trim()) return x.message;
  }
  return e instanceof Error ? e.message : String(e);
}

function isPermissionDenied(e: unknown): boolean {
  const msg = grpcErrorDetails(e);
  if (/PERMISSION_DENIED/i.test(msg)) return true;
  const code = (e as { code?: number })?.code;
  return code === 7;
}

/**
 * เรียกครั้งเดียวก่อนแปลหลายภาษา — ถ้า IAM/API ไม่พร้อมจะ throw พร้อมข้อความแนะนำ
 * (PERMISSION_DENIED มักแปลว่า: เปิด API แล้วแต่ service account ยังไม่มี roles/cloudtranslate.user)
 */
export async function assertTranslationApiWorks(): Promise<void> {
  const ctx = getClient();
  if (!ctx) {
    throw new Error('Translation: no service account configured.');
  }
  const sa = getServiceAccountForTranslate();
  const email = sa?.credentials.client_email ?? '(unknown)';

  try {
    await ctx.client.translateText({
      parent: `projects/${ctx.projectId}/locations/global`,
      contents: ['ok'],
      mimeType: 'text/plain',
      sourceLanguageCode: 'en',
      targetLanguageCode: 'th',
    });
  } catch (e) {
    const extra = grpcErrorDetails(e);
    if (isPermissionDenied(e)) {
      throw new Error(
        `Cloud Translation API: PERMISSION_DENIED (project ${ctx.projectId}). ` +
          `Grant service account "${email}" the IAM role "Cloud Translation API User" (roles/cloudtranslate.user). ` +
          `Open: https://console.cloud.google.com/iam-admin/iam?project=${encodeURIComponent(ctx.projectId)} ` +
          `Ensure API is enabled: https://console.cloud.google.com/apis/library/translate.googleapis.com?project=${encodeURIComponent(ctx.projectId)} ` +
          (extra && extra !== '7 PERMISSION_DENIED: ' ? ` — ${extra}` : ''),
      );
    }
    throw new Error(`Translation API error: ${extra || 'unknown'}`);
  }
}

function getClient(): { client: TranslationServiceClient; projectId: string } | null {
  if (client && projectId) return { client, projectId };

  const sa = getServiceAccountForTranslate();
  if (!sa) {
    console.warn(
      '[translate] No service account for Translation API — set FIREBASE_PROJECT_ID + FIREBASE_CLIENT_EMAIL + FIREBASE_PRIVATE_KEY in .env.local or add serviceAccountKey.json (same as Firestore)',
    );
    return null;
  }

  try {
    client = new TranslationServiceClient({
      projectId: sa.projectId,
      credentials: sa.credentials,
    });
    projectId = sa.projectId;
    return { client, projectId };
  } catch (e) {
    console.warn('[translate] Failed to create TranslationServiceClient:', e);
    return null;
  }
}

async function translateText(text: string, targetLang: string, sourceLang: string = 'en'): Promise<string> {
  const ctx = getClient();
  if (!ctx || !text.trim()) return text;

  try {
    const [response] = await ctx.client.translateText({
      parent: `projects/${ctx.projectId}/locations/global`,
      contents: [text],
      mimeType: 'text/plain',
      sourceLanguageCode: sourceLang,
      targetLanguageCode: targetLang === 'zh' ? 'zh-CN' : targetLang,
    });

    return response.translations?.[0]?.translatedText || text;
  } catch (e) {
    const detail = grpcErrorDetails(e);
    console.warn(
      `[translate] Failed to translate to ${targetLang}:`,
      detail || e,
    );
    return text;
  }
}

async function autoTranslateField(input: LocaleMap): Promise<LocaleMap> {
  const enText = input.en || '';
  if (!enText.trim()) return input;

  const result: LocaleMap = { ...input };
  const missingLocales = OFFER_LOCALES.filter((l) => l !== 'en' && !result[l]?.trim());

  const translations = await Promise.allSettled(
    missingLocales.map((locale) => translateText(enText, locale))
  );

  missingLocales.forEach((locale, i) => {
    const t = translations[i];
    if (t.status === 'fulfilled' && t.value) {
      result[locale] = t.value;
    }
  });

  return result;
}

export async function autoTranslateOfferFields(
  title: LocaleMap,
  description: LocaleMap,
  ctaText: LocaleMap,
): Promise<{ title: LocaleMap; description: LocaleMap; ctaText: LocaleMap }> {
  const [tTitle, tDescription, tCtaText] = await Promise.all([
    autoTranslateField(title),
    autoTranslateField(description),
    autoTranslateField(ctaText),
  ]);

  return { title: tTitle, description: tDescription, ctaText: tCtaText };
}

/** แปลจากภาษาอังกฤษไปทุก locale อื่น (เขียนทับค่าเดิม) — ใช้ปุ่ม Translate ในฟอร์ม */
export async function forceTranslateOfferFromEnglish(
  titleEn: string,
  descriptionEn: string,
  ctaEn: string,
): Promise<{ title: LocaleMap; description: LocaleMap; ctaText: LocaleMap }> {
  await assertTranslationApiWorks();

  const targets = OFFER_LOCALES.filter((l) => l !== 'en');
  const title: LocaleMap = { en: titleEn };
  const description: LocaleMap = { en: descriptionEn };
  const ctaText: LocaleMap = { en: ctaEn };

  await Promise.all(
    targets.map(async (locale) => {
      const [tT, tD, tC] = await Promise.all([
        translateText(titleEn, locale),
        translateText(descriptionEn, locale),
        translateText(ctaEn, locale),
      ]);
      title[locale] = tT;
      description[locale] = tD;
      ctaText[locale] = tC;
    }),
  );

  return { title, description, ctaText };
}
