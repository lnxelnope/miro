#!/usr/bin/env python3
"""
Reset ALL consumable IAP localizations (delete rejected → recreate)
via App Store Connect API.

Usage:
  python3 iap_reset_consumables.py
"""

import os
import time
from pathlib import Path

import requests

KEY_ID = os.environ.get("ASC_KEY_ID", "TM977W2QA2")
ISSUER_ID = os.environ.get("ASC_ISSUER_ID", "db062b0c-572d-4341-9aa3-2fb053ed0337")
P8_PATH = os.environ.get("ASC_P8_PATH", "/Users/nu_mac_studio/Downloads/AuthKey_TM977W2QA2.p8")
BUNDLE_ID = os.environ.get("ASC_BUNDLE_ID", "com.tanabun.miroHybrid")

BASE = "https://api.appstoreconnect.apple.com"

LOCALES = [
    "en-US", "th", "vi", "de-DE", "es-ES", "fr-FR",
    "hi", "id", "ja", "ko", "pt-BR", "zh-Hans",
]

IAP_DESCRIPTION_MAX_LEN = 55


def _t(s: str) -> str:
    return s[:IAP_DESCRIPTION_MAX_LEN] if len(s) > IAP_DESCRIPTION_MAX_LEN else s


CONSUMABLE_IAP = {
    "energy_100": {
        "en-US": ("Starter Kick – 100 Energy", "100 energy to power AI food analysis."),
        "th": ("Starter Kick – 100 พลังงาน", "พลังงาน 100 สำหรับวิเคราะห์อาหารด้วย AI"),
        "vi": ("Starter Kick – 100 Năng lượng", "100 năng lượng cho phân tích thực phẩm AI."),
        "de-DE": ("Starter Kick – 100 Energie", "100 Energie für KI-Lebensmittelanalyse."),
        "es-ES": ("Starter Kick – 100 Energía", "100 energía para análisis de alimentos con IA."),
        "fr-FR": ("Starter Kick – 100 Énergie", "100 énergie pour l'analyse alimentaire IA."),
        "hi": ("Starter Kick – 100 ऊर्जा", "AI खाद्य विश्लेषण हेतु 100 ऊर्जा।"),
        "id": ("Starter Kick – 100 Energi", "100 energi untuk analisis makanan AI."),
        "ja": ("Starter Kick – 100 エネルギー", "AI食品分析に使える100エネルギー。"),
        "ko": ("Starter Kick – 100 에너지", "AI 식품 분석을 위한 100 에너지."),
        "pt-BR": ("Starter Kick – 100 Energia", "100 energia para análise alimentar com IA."),
        "zh-Hans": ("Starter Kick – 100 能量", "100能量用于AI食品分析。"),
    },
    "energy_550": {
        "en-US": ("Value Pack – 550 Energy", "550 energy with 10% bonus for AI food analysis."),
        "th": ("Value Pack – 550 พลังงาน", "พลังงาน 550 พร้อมโบนัส 10% สำหรับ AI"),
        "vi": ("Value Pack – 550 Năng lượng", "550 năng lượng kèm 10% thưởng cho AI."),
        "de-DE": ("Value Pack – 550 Energie", "550 Energie mit 10% Bonus für KI-Analyse."),
        "es-ES": ("Value Pack – 550 Energía", "550 energía con 10% de bonificación para IA."),
        "fr-FR": ("Value Pack – 550 Énergie", "550 énergie avec 10% bonus pour l'IA."),
        "hi": ("Value Pack – 550 ऊर्जा", "AI हेतु 10% बोनस के साथ 550 ऊर्जा।"),
        "id": ("Value Pack – 550 Energi", "550 energi dengan bonus 10% untuk AI."),
        "ja": ("Value Pack – 550 エネルギー", "10%ボーナス付き550エネルギー。"),
        "ko": ("Value Pack – 550 에너지", "10% 보너스 포함 550 에너지."),
        "pt-BR": ("Value Pack – 550 Energia", "550 energia com 10% bónus para IA."),
        "zh-Hans": ("Value Pack – 550 能量", "550能量附赠10%奖励。"),
    },
    "energy_1200": {
        "en-US": ("Power User – 1,200 Energy", "1,200 energy for heavy AI food analysis use."),
        "th": ("Power User – 1,200 พลังงาน", "พลังงาน 1,200 สำหรับใช้ AI วิเคราะห์อาหาร"),
        "vi": ("Power User – 1.200 Năng lượng", "1.200 năng lượng cho phân tích thực phẩm AI."),
        "de-DE": ("Power User – 1.200 Energie", "1.200 Energie für intensive KI-Analyse."),
        "es-ES": ("Power User – 1.200 Energía", "1.200 energía para uso intensivo de IA."),
        "fr-FR": ("Power User – 1 200 Énergie", "1 200 énergie pour analyse alimentaire IA."),
        "hi": ("Power User – 1,200 ऊर्जा", "गहन AI खाद्य विश्लेषण हेतु 1,200 ऊर्जा।"),
        "id": ("Power User – 1.200 Energi", "1.200 energi untuk analisis makanan AI."),
        "ja": ("Power User – 1,200 エネルギー", "AI食品分析向け1,200エネルギー。"),
        "ko": ("Power User – 1,200 에너지", "AI 식품 분석을 위한 1,200 에너지."),
        "pt-BR": ("Power User – 1.200 Energia", "1.200 energia para análise alimentar com IA."),
        "zh-Hans": ("Power User – 1,200 能量", "1,200能量用于AI食品分析。"),
    },
    "energy_2000": {
        "en-US": ("Ultimate Saver – 2,000 Energy", "Best value! 2,000 energy for AI food analysis."),
        "th": ("Ultimate Saver – 2,000 พลังงาน", "คุ้มที่สุด! พลังงาน 2,000 สำหรับ AI"),
        "vi": ("Ultimate Saver – 2.000 Năng lượng", "Tốt nhất! 2.000 năng lượng cho AI."),
        "de-DE": ("Ultimate Saver – 2.000 Energie", "Bester Wert! 2.000 Energie für KI."),
        "es-ES": ("Ultimate Saver – 2.000 Energía", "¡Mejor oferta! 2.000 energía para IA."),
        "fr-FR": ("Ultimate Saver – 2 000 Énergie", "Meilleure offre ! 2 000 énergie pour l'IA."),
        "hi": ("Ultimate Saver – 2,000 ऊर्जा", "सर्वोत्तम! AI हेतु 2,000 ऊर्जा।"),
        "id": ("Ultimate Saver – 2.000 Energi", "Nilai terbaik! 2.000 energi untuk AI."),
        "ja": ("Ultimate Saver – 2,000 エネルギー", "最もお得！AI向け2,000エネルギー。"),
        "ko": ("Ultimate Saver – 2,000 에너지", "최고 가성비! AI 위한 2,000 에너지."),
        "pt-BR": ("Ultimate Saver – 2.000 Energia", "Melhor valor! 2.000 energia para IA."),
        "zh-Hans": ("Ultimate Saver – 2,000 能量", "超值！2,000能量用于AI食品分析。"),
    },
}


def get_jwt():
    import jwt as pyjwt
    key = Path(P8_PATH).expanduser().read_text()
    now = int(time.time())
    payload = {"iss": ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"}
    return pyjwt.encode(payload, key, algorithm="ES256", headers={"kid": KEY_ID})


def api(session, method, path, data=None, params=None):
    url = path if path.startswith("http") else (BASE + path)
    r = session.request(method, url, json=data, params=params, timeout=30)
    if method == "DELETE" and r.status_code == 204:
        return {"ok": True}
    if r.status_code >= 400:
        print(f"    {method} {path} → {r.status_code}: {r.text[:300]}")
        return None
    if r.status_code == 204:
        return {"ok": True}
    return r.json()


def main():
    session = requests.Session()
    session.headers.update({
        "Authorization": f"Bearer {get_jwt()}",
        "Content-Type": "application/json",
    })

    # 1) Find app
    apps = api(session, "GET", "/v1/apps", params={"filter[bundleId]": BUNDLE_ID, "limit": "1"})
    if not apps or not apps.get("data"):
        raise SystemExit(f"No app found for bundleId={BUNDLE_ID}")
    app_id = apps["data"][0]["id"]
    app_name = apps["data"][0]["attributes"].get("name", "?")
    print(f"✅ App: {app_name} ({app_id})")

    # 2) List all IAPs (v2)
    print("\nListing in-app purchases...")
    all_iaps = []
    next_url = f"{BASE}/v1/apps/{app_id}/inAppPurchasesV2?limit=200"
    while next_url:
        r = session.get(next_url, timeout=30)
        if r.status_code >= 400:
            raise SystemExit(f"List IAPs failed: {r.status_code} {r.text}")
        data = r.json()
        all_iaps.extend(data.get("data", []))
        next_url = data.get("links", {}).get("next")

    pid_to_id = {}
    for iap in all_iaps:
        pid = iap["attributes"].get("productId", "")
        if pid:
            pid_to_id[pid] = iap["id"]
            iap_type = iap["attributes"].get("inAppPurchaseType", "?")
            print(f"  Found: {pid} ({iap_type}) → id={iap['id']}")

    # 3) For each consumable IAP: delete rejected localizations, then recreate
    for product_id, locales_data in CONSUMABLE_IAP.items():
        iap_id = pid_to_id.get(product_id)
        if not iap_id:
            print(f"\n⚠️  Skip {product_id} (not found in App Store Connect)")
            continue

        print(f"\n{'='*60}")
        print(f"📦 {product_id} ({iap_id})")
        print(f"{'='*60}")

        # Get existing localizations
        locs = api(session, "GET",
                   f"/v2/inAppPurchases/{iap_id}/inAppPurchaseLocalizations",
                   params={"limit": "200"})
        if not locs or not locs.get("data"):
            print("  No existing localizations found")
        else:
            # Delete all existing localizations
            loc_list = locs["data"]
            for loc in loc_list:
                loc_id = loc["id"]
                locale = loc["attributes"]["locale"]
                state = loc["attributes"].get("state", "?")
                print(f"  🗑  Deleting {locale} (state: {state}, id: {loc_id})...")
                api(session, "DELETE", f"/v1/inAppPurchaseLocalizations/{loc_id}")
            time.sleep(1)

        # Create new localizations
        for locale in LOCALES:
            if locale not in locales_data:
                continue
            name, desc = locales_data[locale]
            desc = _t(desc)
            body = {
                "data": {
                    "type": "inAppPurchaseLocalizations",
                    "attributes": {
                        "locale": locale,
                        "name": name,
                        "description": desc,
                    },
                    "relationships": {
                        "inAppPurchaseV2": {
                            "data": {"type": "inAppPurchases", "id": iap_id}
                        },
                    },
                }
            }
            result = api(session, "POST", "/v1/inAppPurchaseLocalizations", data=body)
            status = "✅" if result else "❌"
            print(f"  {status} {locale}: {'created' if result else 'FAILED'}")

    print(f"\n{'='*60}")
    print("🎉 Done! Consumable IAP localizations reset.")
    print(f"{'='*60}")


if __name__ == "__main__":
    main()
