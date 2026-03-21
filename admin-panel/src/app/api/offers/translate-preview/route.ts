import { NextRequest, NextResponse } from 'next/server';
import { checkAuth } from '@/lib/auth';
import { forceTranslateOfferFromEnglish, hasTranslateCredentials } from '@/lib/translate';

/**
 * POST — แปล Title / Description / CTA จากภาษาอังกฤษไปทุก locale ที่รองรับ (ให้ตรวจในฟอร์มก่อน Save)
 */
export async function POST(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    if (!hasTranslateCredentials()) {
      return NextResponse.json(
        {
          success: false,
          error:
            'Translation API needs the same service account as Firestore (FIREBASE_* in .env.local or serviceAccountKey.json). Also enable Cloud Translation API in GCP.',
        },
        { status: 503 },
      );
    }

    const body = await request.json();
    const titleEn = String(body.titleEn ?? body.title?.en ?? '').trim();
    const descriptionEn = String(body.descriptionEn ?? body.description?.en ?? '').trim();
    const ctaEn = String(body.ctaEn ?? body.ctaText?.en ?? 'Claim').trim();

    if (!titleEn) {
      return NextResponse.json(
        { success: false, error: 'English title is required' },
        { status: 400 },
      );
    }

    const result = await forceTranslateOfferFromEnglish(
      titleEn,
      descriptionEn,
      ctaEn || 'Claim',
    );

    return NextResponse.json({
      success: true,
      title: result.title,
      description: result.description,
      ctaText: result.ctaText,
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : 'Translation failed';
    console.error('[translate-preview]', error);
    const status =
      /PERMISSION_DENIED|Translation API error|no service account/i.test(message) ? 503 : 500;
    return NextResponse.json({ success: false, error: message }, { status });
  }
}
