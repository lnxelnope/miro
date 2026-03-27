#!/usr/bin/env python3
"""
App Store Connect API — Add IAP & Energy Pass localizations for all languages.
Uses JWT auth with .p8 key. Run once then revoke the key if desired.

Usage:
  pip install pyjwt cryptography requests
  python iap_localization_api.py

Set env or edit below: KEY_ID, ISSUER_ID, P8_PATH, BUNDLE_ID
"""

import json
import os
import time
from pathlib import Path

import requests

# -----------------------------------------------------------------------------
# Config (override with env: ASC_KEY_ID, ASC_ISSUER_ID, ASC_P8_PATH, ASC_BUNDLE_ID)
# -----------------------------------------------------------------------------
KEY_ID = os.environ.get("ASC_KEY_ID", "3G9Q2GCT9V")
ISSUER_ID = os.environ.get("ASC_ISSUER_ID", "db062b0c-572d-4341-9aa3-2fb053ed0337")
P8_PATH = os.environ.get("ASC_P8_PATH", "/Users/nu_mac_studio/Library/CloudStorage/Dropbox/miro/AuthKey_3G9Q2GCT9V.p8")
BUNDLE_ID = os.environ.get("ASC_BUNDLE_ID", "com.tanabun.miroHybrid")

BASE_URL = "https://api.appstoreconnect.apple.com"

# Apple locale codes (must match App Store Connect)
# Apple-supported locale codes (use "ko" not "ko-KR")
LOCALES = [
    "en-US", "th", "vi", "de-DE", "es-ES", "fr-FR", "hi", "id", "ja", "ko", "pt-BR", "zh-Hans"
]

# Apple limit for IAP description (characters)
IAP_DESCRIPTION_MAX_LEN = 55


def _truncate_desc(s: str, max_len: int = IAP_DESCRIPTION_MAX_LEN) -> str:
    return s[:max_len] if len(s) > max_len else s

# Consumable IAP: product_id -> (display_name, description) per locale
# Order: en-US, th, vi, de-DE, es-ES, fr-FR, hi, id, ja, ko-KR, pt-BR, zh-Hans
CONSUMABLE_IAP = {
    "energy_first_purchase_200": {
        "en-US": ("First Purchase – 200 Energy", "Welcome deal! 200 energy for new users."),
        "th": ("ซื้อครั้งแรก – 200 พลังงาน", "ดีลต้อนรับ! พลังงาน 200 สำหรับผู้ใช้ใหม่"),
        "vi": ("Mua lần đầu – 200 Năng lượng", "Ưu đãi chào mừng! 200 năng lượng."),
        "de-DE": ("Erstkauf – 200 Energie", "Willkommensdeal! 200 Energie für neue Nutzer."),
        "es-ES": ("Primera compra – 200 Energía", "¡Oferta de bienvenida! 200 energía para nuevos usuarios."),
        "fr-FR": ("Premier achat – 200 Énergie", "Offre de bienvenue ! 200 énergie pour les nouveaux utilisateurs."),
        "hi": ("पहली खरीदारी – 200 ऊर्जा", "स्वागत ऑफ़र! नए उपयोगकर्ताओं के लिए 200 ऊर्जा।"),
        "id": ("Pembelian Pertama – 200 Energi", "Penawaran selamat datang! 200 energi untuk pengguna baru."),
        "ja": ("初回購入 – 200 エネルギー", "歓迎特典！新規ユーザー向け200エネルギー。"),
        "ko": ("첫 구매 – 200 에너지", "환영 혜택! 신규 사용자를 위한 200 에너지."),
        "pt-BR": ("Primeira compra – 200 Energia", "Oferta de boas-vindas! 200 energia para novos utilizadores."),
        "zh-Hans": ("首次购买 – 200 能量", "欢迎优惠！新用户200能量。"),
    },
    "energy_50": {
        "en-US": ("Starter Energy Pack", "Get 50 energy to power AI features."),
        "th": ("แพ็กเริ่มต้นพลังงาน", "รับพลังงาน 50 หน่วย สำหรับใช้ฟีเจอร์ AI"),
        "vi": ("Gói năng lượng khởi đầu", "Nhận 50 năng lượng cho tính năng AI."),
        "de-DE": ("Starter-Energiepaket", "50 Energie für KI-Funktionen."),
        "es-ES": ("Pack de energía inicial", "Obtén 50 energía para funciones de IA."),
        "fr-FR": ("Pack Énergie Débutant", "Obtenez 50 énergie pour les fonctions IA."),
        "hi": ("स्टार्टर एनर्जी पैक", "AI सुविधाओं के लिए 50 ऊर्जा प्राप्त करें।"),
        "id": ("Paket Energi Pemula", "Dapatkan 50 energi untuk fitur AI."),
        "ja": ("スターターエナジーパック", "AI機能に使える50エネルギー。"),
        "ko": ("스타터 에너지 팩", "AI 기능을 위한 50 에너지."),
        "pt-BR": ("Pacote de Energia Inicial", "Receba 50 de energia para recursos de IA."),
        "zh-Hans": ("新手能量包", "获取50能量，驱动AI功能。"),
    },
    "energy_200": {
        "en-US": ("Standard Energy Pack", "Get 200 energy for regular AI usage."),
        "th": ("แพ็กพลังงานมาตรฐาน", "รับพลังงาน 200 หน่วย สำหรับใช้ AI เป็นประจำ"),
        "vi": ("Gói năng lượng tiêu chuẩn", "Nhận 200 năng lượng cho nhu cầu AI hằng ngày."),
        "de-DE": ("Standard-Energiepaket", "200 Energie für die tägliche KI-Nutzung."),
        "es-ES": ("Pack de energía estándar", "Obtén 200 energía para uso habitual de IA."),
        "fr-FR": ("Pack Énergie Standard", "Obtenez 200 énergie pour une utilisation IA régulière."),
        "hi": ("स्टैंडर्ड एनर्जी पैक", "नियमित AI उपयोग के लिए 200 ऊर्जा प्राप्त करें।"),
        "id": ("Paket Energi Standar", "Dapatkan 200 energi untuk penggunaan AI rutin."),
        "ja": ("スタンダードエナジーパック", "日常的なAI利用向け200エネルギー。"),
        "ko": ("스탠다드 에너지 팩", "일상적인 AI 사용을 위한 200 에너지."),
        "pt-BR": ("Pacote de Energia Padrão", "Receba 200 de energia para uso regular de IA."),
        "zh-Hans": ("标准能量包", "获取200能量，满足日常AI使用。"),
    },
    "energy_500": {
        "en-US": ("Power Energy Pack", "Best value! 500 energy for heavy AI use."),
        "th": ("แพ็กพลังงานโปร", "คุ้มที่สุด! พลังงาน 500 หน่วย สำหรับใช้ AI หนัก"),
        "vi": ("Gói năng lượng cao cấp", "Giá tốt! 500 năng lượng cho nhu cầu AI cao."),
        "de-DE": ("Power-Energiepaket", "Bestes Preis-Leistungs-Verhältnis! 500 Energie."),
        "es-ES": ("Pack de energía avanzado", "¡Mejor valor! 500 energía para uso intensivo de IA."),
        "fr-FR": ("Pack Énergie Avancé", "Meilleur rapport qualité-prix ! 500 énergie pour l'IA."),
        "hi": ("पावर एनर्जी पैक", "सर्वश्रेष्ठ मूल्य! गहन AI उपयोग के लिए 500 ऊर्जा।"),
        "id": ("Paket Energi Power", "Nilai terbaik! 500 energi untuk penggunaan AI tinggi."),
        "ja": ("パワーエナジーパック", "高利用向け。お得な500エネルギー。"),
        "ko": ("파워 에너지 팩", "가성비 최고! 고사용량 AI를 위한 500 에너지."),
        "pt-BR": ("Pacote de Energia Power", "Melhor valor! 500 de energia para uso intenso de IA."),
        "zh-Hans": ("高阶能量包", "超值！500能量，适合重度AI使用。"),
    },
}

# Subscription: product_id -> (display_name, description) per locale
SUBSCRIPTION_IAP = {
    "miro_energy_pass_weekly": {
        "en-US": ("Energy Pass Weekly", "Unlimited AI analysis for 1 week"),
        "th": ("Energy Pass รายสัปดาห์", "วิเคราะห์ AI 1 สัปดาห์ไม่จำกัด"),
        "vi": ("Energy Pass Hàng tuần", "Phân tích AI không giới hạn 1 tuần"),
        "de-DE": ("Energy Pass Wöchentlich", "Unbegrenzte KI-Analyse für 1 Woche"),
        "es-ES": ("Energy Pass Semanal", "Análisis de IA ilimitado por 1 semana"),
        "fr-FR": ("Energy Pass Hebdomadaire", "Analyse IA illimitée pendant 1 semaine"),
        "hi": ("Energy Pass साप्ताहिक", "1 सप्ताह के लिए असीमित AI विश्लेषण"),
        "id": ("Energy Pass Mingguan", "Analisis AI tanpa batas selama 1 minggu"),
        "ja": ("Energy Pass ウィークリー", "1週間AIの分析が無制限"),
        "ko": ("Energy Pass 주간", "1주일간 무제한 AI 분석"),
        "pt-BR": ("Energy Pass Semanal", "Análise de IA ilimitada por 1 semana"),
        "zh-Hans": ("Energy Pass 每周", "1周无限AI分析"),
    },
    "miro_energy_pass_monthly": {
        "en-US": ("Energy Pass Monthly", "Unlimited AI analysis for 1 month"),
        "th": ("Energy Pass รายเดือน", "วิเคราะห์ AI 1 เดือนไม่จำกัด"),
        "vi": ("Energy Pass Hàng tháng", "Phân tích AI không giới hạn 1 tháng"),
        "de-DE": ("Energy Pass Monatlich", "Unbegrenzte KI-Analyse für 1 Monat"),
        "es-ES": ("Energy Pass Mensual", "Análisis de IA ilimitado por 1 mes"),
        "fr-FR": ("Energy Pass Mensuel", "Analyse IA illimitée pendant 1 mois"),
        "hi": ("Energy Pass मासिक", "1 महीने के लिए असीमित AI विश्लेषण"),
        "id": ("Energy Pass Bulanan", "Analisis AI tanpa batas selama 1 bulan"),
        "ja": ("Energy Pass マンスリー", "1か月間AIの分析が無制限"),
        "ko": ("Energy Pass 월간", "1개월간 무제한 AI 분석"),
        "pt-BR": ("Energy Pass Mensal", "Análise de IA ilimitada por 1 mês"),
        "zh-Hans": ("Energy Pass 每月", "1个月无限AI分析"),
    },
    "miro_energy_pass_yearly": {
        "en-US": ("Energy Pass Yearly", "Unlimited AI analysis. Save 62%"),
        "th": ("Energy Pass รายปี", "วิเคราะห์ AI ไม่จำกัด ประหยัดถึง 62%"),
        "vi": ("Energy Pass Hàng năm", "Phân tích AI không giới hạn. Tiết kiệm 62%"),
        "de-DE": ("Energy Pass Jährlich", "Unbegrenzte KI-Analyse. 62 % sparen"),
        "es-ES": ("Energy Pass Anual", "Análisis de IA ilimitado. Ahorra un 62 %"),
        "fr-FR": ("Energy Pass Annuel", "Analyse IA illimitée. Économisez 62 %"),
        "hi": ("Energy Pass वार्षिक", "असीमित AI विश्लेषण। 62% की बचत"),
        "id": ("Energy Pass Tahunan", "Analisis AI tanpa batas. Hemat 62%"),
        "ja": ("Energy Pass 年間", "AI分析が無制限。62%お得"),
        "ko": ("Energy Pass 연간", "무제한 AI 분석. 62% 할인"),
        "pt-BR": ("Energy Pass Anual", "Análise de IA ilimitada. Poupe 62%"),
        "zh-Hans": ("Energy Pass 年度", "无限AI分析。节省62%"),
    },
}


def get_jwt():
    try:
        import jwt as pyjwt
    except ImportError:
        raise SystemExit("Install: pip install pyjwt cryptography")

    p8_path = Path(P8_PATH).expanduser()
    if not p8_path.is_file():
        raise SystemExit(f"P8 key not found: {p8_path}")

    key = p8_path.read_text()
    now = int(time.time())
    payload = {
        "iss": ISSUER_ID,
        "iat": now,
        "exp": now + 1200,
        "aud": "appstoreconnect-v1",
    }
    token = pyjwt.encode(
        payload,
        key,
        algorithm="ES256",
        headers={"kid": KEY_ID},
    )
    return token if isinstance(token, str) else token.decode()


def api_get(session, path, params=None):
    url = path if path.startswith("http") else (BASE_URL + path)
    r = session.get(url, params=params, timeout=30)
    if r.status_code >= 400:
        raise SystemExit(f"GET {path} failed: {r.status_code} {r.text}")
    return r.json()


def api_post(session, path, data):
    url = path if path.startswith("http") else (BASE_URL + path)
    r = session.post(url, json=data, timeout=30)
    if r.status_code >= 400:
        raise SystemExit(f"POST {path} failed: {r.status_code} {r.text}")
    return r.json()


def main():
    token = get_jwt()
    session = requests.Session()
    session.headers["Authorization"] = f"Bearer {token}"
    session.headers["Content-Type"] = "application/json"

    # 1) Resolve app id
    print(f"Finding app with bundleId={BUNDLE_ID}...")
    apps = api_get(session, "/v1/apps", params={"filter[bundleId]": BUNDLE_ID, "limit": "1"})
    if not apps.get("data"):
        raise SystemExit(f"No app found for bundleId={BUNDLE_ID}")
    app_id = apps["data"][0]["id"]
    print(f"  App id: {app_id}")

    # 2) List all IAPs (v2) for this app
    print("Listing in-app purchases...")
    all_iaps = []
    next_url = BASE_URL + f"/v1/apps/{app_id}/inAppPurchasesV2?limit=200"
    while next_url:
        r = session.get(next_url, timeout=30)
        if r.status_code >= 400:
            raise SystemExit(f"List IAPs failed: {r.status_code} {r.text}")
        data = r.json()
        all_iaps.extend(data.get("data", []))
        next_url = data.get("links", {}).get("next")

    # Build map: productId or referenceName -> IAP id (and type: consumable vs subscription)
    product_to_id = {}
    for iap in all_iaps:
        aid = iap["id"]
        attrs = iap.get("attributes", {})
        # inAppPurchasesV2 may have productId or name we can match
        pid = attrs.get("productId") or attrs.get("referenceName") or ""
        if pid:
            product_to_id[pid] = ("iap", aid)
        # Also try referenceName for display (e.g. "First Purchase - 200 Energy" -> we use product id)
        ref = (attrs.get("referenceName") or "").strip()
        if ref and ref not in product_to_id:
            product_to_id[ref] = ("iap", aid)

    # Match our consumable product IDs (and common reference names if API returns them)
    consumable_ids = list(CONSUMABLE_IAP.keys())
    subscription_ids = list(SUBSCRIPTION_IAP.keys())
    all_product_ids = consumable_ids + subscription_ids

    iap_id_by_product = {}
    for pid in all_product_ids:
        if pid in product_to_id:
            iap_id_by_product[pid] = product_to_id[pid][1]
        else:
            # Try without underscore (e.g. energy_100 vs energy100)
            alt = pid.replace("_", "")
            if alt in product_to_id:
                iap_id_by_product[pid] = product_to_id[alt][1]
            else:
                print(f"  Warning: no API IAP found for productId '{pid}' (will skip)")

    # 3) For each consumable IAP: get existing localizations, then POST missing
    for product_id, locales_data in CONSUMABLE_IAP.items():
        if product_id not in iap_id_by_product:
            print(f"Skip consumable {product_id} (not found in app)")
            continue
        iap_id = iap_id_by_product[product_id]
        print(f"\nConsumable: {product_id} ({iap_id})")
        # GET existing localizations
        # v2 path for listing localizations (same id as from inAppPurchasesV2 list)
        locs = api_get(session, f"/v2/inAppPurchases/{iap_id}/inAppPurchaseLocalizations", params={"limit": "200"})
        existing = {loc["attributes"]["locale"] for loc in locs.get("data", [])}
        for locale in LOCALES:
            if locale not in locales_data:
                continue
            if locale in existing:
                print(f"  {locale}: already exists")
                continue
            name, desc = locales_data[locale]
            desc = _truncate_desc(desc)
            body = {
                "data": {
                    "type": "inAppPurchaseLocalizations",
                    "attributes": {"locale": locale, "name": name, "description": desc},
                    "relationships": {
                        "inAppPurchaseV2": {"data": {"type": "inAppPurchases", "id": iap_id}},
                    },
                }
            }
            try:
                api_post(session, "/v1/inAppPurchaseLocalizations", body)
                print(f"  {locale}: created")
            except Exception as e:
                print(f"  {locale}: error - {e}")

    # 4) Subscriptions: API structure differs - subscriptions live under subscriptionGroups
    # List subscription groups for app
    print("\nListing subscription groups...")
    sg_list = api_get(session, f"/v1/apps/{app_id}/subscriptionGroups", params={"limit": "50"})
    sub_id_by_product = {}
    for sg in sg_list.get("data", []):
        sg_id = sg["id"]
        subs = api_get(session, f"/v1/subscriptionGroups/{sg_id}/subscriptions", params={"limit": "50"})
        for sub in subs.get("data", []):
            sid = sub["id"]
            attrs = sub.get("attributes", {})
            # API may return productId or name/referenceName
            pid = attrs.get("productId") or attrs.get("referenceName") or attrs.get("name") or ""
            if pid:
                sub_id_by_product[pid] = sid
        if not sub_id_by_product and subs.get("data"):
            print("  Debug subscription attributes:", list(subs["data"][0].get("attributes", {}).keys()))
    for product_id in subscription_ids:
        if product_id not in sub_id_by_product:
            print(f"  Warning: subscription '{product_id}' not found in any group")
    for k, v in sub_id_by_product.items():
        iap_id_by_product[k] = ("sub", v)

    # 5) For each subscription: add subscriptionLocalizations
    for product_id, locales_data in SUBSCRIPTION_IAP.items():
        if product_id not in iap_id_by_product:
            print(f"Skip subscription {product_id} (not found)")
            continue
        sub_id = iap_id_by_product[product_id]
        if isinstance(sub_id, tuple):
            sub_id = sub_id[1]
        print(f"\nSubscription: {product_id} ({sub_id})")
        locs = api_get(session, f"/v1/subscriptions/{sub_id}/subscriptionLocalizations", params={"limit": "200"})
        existing = {loc["attributes"]["locale"] for loc in locs.get("data", [])}
        for locale in LOCALES:
            if locale not in locales_data:
                continue
            if locale in existing:
                print(f"  {locale}: already exists")
                continue
            name, desc = locales_data[locale]
            desc = _truncate_desc(desc)
            body = {
                "data": {
                    "type": "subscriptionLocalizations",
                    "attributes": {"locale": locale, "name": name, "description": desc},
                    "relationships": {
                        "subscription": {"data": {"type": "subscriptions", "id": sub_id}},
                    },
                }
            }
            try:
                api_post(session, "/v1/subscriptionLocalizations", body)
                print(f"  {locale}: created")
            except Exception as e:
                print(f"  {locale}: error - {e}")

    print("\nDone. Revoke the API key in App Store Connect if you created it only for this run.")


if __name__ == "__main__":
    main()
