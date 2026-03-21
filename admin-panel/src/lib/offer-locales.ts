/** Locales stored on offer_templates (must match app + translate.ts). */
export const OFFER_LOCALES = [
  'en',
  'th',
  'vi',
  'de',
  'es',
  'fr',
  'hi',
  'id',
  'ja',
  'ko',
  'pt',
  'zh',
] as const;

export type OfferLocale = (typeof OFFER_LOCALES)[number];

/** Short tab labels; use `title` attribute for full name where needed */
export const LOCALE_LABELS: Record<OfferLocale, string> = {
  en: 'EN',
  th: 'TH',
  vi: 'VI',
  de: 'DE',
  es: 'ES',
  fr: 'FR',
  hi: 'HI',
  id: 'ID',
  ja: 'JA',
  ko: 'KO',
  pt: 'PT',
  zh: 'ZH',
};

export const LOCALE_TITLES: Record<OfferLocale, string> = {
  en: 'English',
  th: 'ไทย',
  vi: 'Tiếng Việt',
  de: 'Deutsch',
  es: 'Español',
  fr: 'Français',
  hi: 'हिन्दी',
  id: 'Indonesia',
  ja: '日本語',
  ko: '한국어',
  pt: 'Português',
  zh: '中文',
};

export type OfferLocaleStrings = Record<OfferLocale, string>;

export function createEmptyLocaleStrings(): OfferLocaleStrings {
  const o = {} as OfferLocaleStrings;
  for (const l of OFFER_LOCALES) o[l] = '';
  return o;
}

export function normalizeOfferLocaleStrings(
  input: Partial<Record<string, string>> | undefined,
): OfferLocaleStrings {
  const o = createEmptyLocaleStrings();
  if (!input) return o;
  for (const l of OFFER_LOCALES) {
    o[l] = (input[l] ?? '').trim();
  }
  return o;
}

/** PUT: body field wins when key is present on body object */
export function mergeOfferLocaleStringsForUpdate(
  body: Partial<Record<string, string>> | undefined,
  existing: Partial<Record<string, string>> | undefined,
): OfferLocaleStrings {
  const o = createEmptyLocaleStrings();
  for (const l of OFFER_LOCALES) {
    if (body && Object.prototype.hasOwnProperty.call(body, l)) {
      o[l] = (body[l] ?? '').trim();
    } else {
      o[l] = (existing?.[l] ?? '').trim();
    }
  }
  return o;
}
