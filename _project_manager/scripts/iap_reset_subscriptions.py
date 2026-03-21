#!/usr/bin/env python3
"""
Reset ALL subscription localizations (delete rejected → recreate) and
subscription group localizations via App Store Connect API.

Usage:
  pip install pyjwt cryptography requests
  python iap_reset_subscriptions.py
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

# ─── Subscription Localizations (per subscription product) ───
SUBSCRIPTION_LOCALES = {
    "miro_energy_pass_weekly": {
        "en-US": ("Energy Pass Weekly", "Unlimited AI food analysis for 1 week"),
        "th": ("Energy Pass รายสัปดาห์", "วิเคราะห์อาหารด้วย AI ไม่จำกัด 1 สัปดาห์"),
        "vi": ("Energy Pass Hàng tuần", "Phân tích thực phẩm AI không giới hạn 1 tuần"),
        "de-DE": ("Energy Pass Wöchentlich", "Unbegrenzte KI-Lebensmittelanalyse für 1 Woche"),
        "es-ES": ("Energy Pass Semanal", "Análisis de alimentos con IA ilimitado por 1 semana"),
        "fr-FR": ("Energy Pass Hebdomadaire", "Analyse alimentaire IA illimitée pendant 1 semaine"),
        "hi": ("Energy Pass साप्ताहिक", "1 सप्ताह के लिए असीमित AI खाद्य विश्लेषण"),
        "id": ("Energy Pass Mingguan", "Analisis makanan AI tanpa batas selama 1 minggu"),
        "ja": ("Energy Pass ウィークリー", "1週間AI食品分析が無制限"),
        "ko": ("Energy Pass 주간", "1주일간 무제한 AI 식품 분석"),
        "pt-BR": ("Energy Pass Semanal", "Análise alimentar com IA ilimitada por 1 semana"),
        "zh-Hans": ("Energy Pass 每周", "1周无限AI食品分析"),
    },
    "miro_energy_pass_monthly": {
        "en-US": ("Energy Pass Monthly", "Unlimited AI food analysis for 1 month"),
        "th": ("Energy Pass รายเดือน", "วิเคราะห์อาหารด้วย AI ไม่จำกัด 1 เดือน"),
        "vi": ("Energy Pass Hàng tháng", "Phân tích thực phẩm AI không giới hạn 1 tháng"),
        "de-DE": ("Energy Pass Monatlich", "Unbegrenzte KI-Lebensmittelanalyse für 1 Monat"),
        "es-ES": ("Energy Pass Mensual", "Análisis de alimentos con IA ilimitado por 1 mes"),
        "fr-FR": ("Energy Pass Mensuel", "Analyse alimentaire IA illimitée pendant 1 mois"),
        "hi": ("Energy Pass मासिक", "1 महीने के लिए असीमित AI खाद्य विश्लेषण"),
        "id": ("Energy Pass Bulanan", "Analisis makanan AI tanpa batas selama 1 bulan"),
        "ja": ("Energy Pass マンスリー", "1か月間AI食品分析が無制限"),
        "ko": ("Energy Pass 월간", "1개월간 무제한 AI 식품 분석"),
        "pt-BR": ("Energy Pass Mensal", "Análise alimentar com IA ilimitada por 1 mês"),
        "zh-Hans": ("Energy Pass 每月", "1个月无限AI食品分析"),
    },
    "miro_energy_pass_yearly": {
        "en-US": ("Energy Pass Yearly", "Unlimited AI food analysis for 1 year. Best value."),
        "th": ("Energy Pass รายปี", "วิเคราะห์อาหารด้วย AI ไม่จำกัด 1 ปี คุ้มที่สุด"),
        "vi": ("Energy Pass Hàng năm", "Phân tích thực phẩm AI không giới hạn 1 năm"),
        "de-DE": ("Energy Pass Jährlich", "Unbegrenzte KI-Lebensmittelanalyse für 1 Jahr"),
        "es-ES": ("Energy Pass Anual", "Análisis de alimentos con IA ilimitado por 1 año"),
        "fr-FR": ("Energy Pass Annuel", "Analyse alimentaire IA illimitée pendant 1 an"),
        "hi": ("Energy Pass वार्षिक", "1 वर्ष के लिए असीमित AI खाद्य विश्लेषण"),
        "id": ("Energy Pass Tahunan", "Analisis makanan AI tanpa batas selama 1 tahun"),
        "ja": ("Energy Pass 年間", "1年間AI食品分析が無制限。最もお得"),
        "ko": ("Energy Pass 연간", "1년간 무제한 AI 식품 분석. 최고 가성비"),
        "pt-BR": ("Energy Pass Anual", "Análise alimentar com IA ilimitada por 1 ano"),
        "zh-Hans": ("Energy Pass 年度", "1年无限AI食品分析。最超值"),
    },
}

# ─── Subscription Group Localizations ───
SUB_GROUP_LOCALES = {
    "en-US": ("Energy Pass", "ArCal : AI Calorie Counter"),
    "th": ("Energy Pass", "ArCal : คำนวณแคลอรี่ด้วย AI"),
    "vi": ("Energy Pass", "ArCal: Máy tính Calo AI"),
    "de-DE": ("Energy Pass", "ArCal: KI-Kalorienzähler"),
    "es-ES": ("Energy Pass", "ArCal: Contador de Calorías IA"),
    "fr-FR": ("Energy Pass", "ArCal: Compteur de Calories IA"),
    "hi": ("Energy Pass", "ArCal: AI कैलोरी काउंटर"),
    "id": ("Energy Pass", "ArCal: Penghitung Kalori AI"),
    "ja": ("Energy Pass", "ArCal: AIカロリーカウンター"),
    "ko": ("Energy Pass", "ArCal: AI 칼로리 카운터"),
    "pt-BR": ("Energy Pass", "ArCal: Contador de Calorias IA"),
    "zh-Hans": ("Energy Pass", "ArCal: AI卡路里计算器"),
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

    # 2) Find subscription groups
    sg_list = api(session, "GET", f"/v1/apps/{app_id}/subscriptionGroups", params={"limit": "50"})
    if not sg_list or not sg_list.get("data"):
        raise SystemExit("No subscription groups found")

    for sg in sg_list["data"]:
        sg_id = sg["id"]
        sg_name = sg["attributes"].get("referenceName", sg_id)
        print(f"\n{'='*60}")
        print(f"📦 Subscription Group: {sg_name} ({sg_id})")
        print(f"{'='*60}")

        # ─── STEP A: Reset Subscription Group Localizations ───
        print(f"\n  ── Step A: Reset Group Localizations ──")
        grp_locs = api(session, "GET",
                       f"/v1/subscriptionGroups/{sg_id}/subscriptionGroupLocalizations",
                       params={"limit": "50"})
        if grp_locs and grp_locs.get("data"):
            for loc in grp_locs["data"]:
                loc_id = loc["id"]
                locale = loc["attributes"]["locale"]
                print(f"    🗑  Deleting group loc {locale} ({loc_id})...")
                api(session, "DELETE", f"/v1/subscriptionGroupLocalizations/{loc_id}")
            time.sleep(1)

        for locale, (group_name, custom_app_name) in SUB_GROUP_LOCALES.items():
            body = {
                "data": {
                    "type": "subscriptionGroupLocalizations",
                    "attributes": {
                        "locale": locale,
                        "name": group_name,
                        "customAppName": custom_app_name,
                    },
                    "relationships": {
                        "subscriptionGroup": {
                            "data": {"type": "subscriptionGroups", "id": sg_id}
                        }
                    },
                }
            }
            result = api(session, "POST", "/v1/subscriptionGroupLocalizations", data=body)
            status = "✅" if result else "❌"
            print(f"    {status} Group loc {locale}: {'created' if result else 'FAILED'}")

        # ─── STEP B: Reset Per-Subscription Localizations ───
        print(f"\n  ── Step B: Reset Subscription Localizations ──")
        subs = api(session, "GET",
                   f"/v1/subscriptionGroups/{sg_id}/subscriptions",
                   params={"limit": "50"})
        if not subs or not subs.get("data"):
            print("    No subscriptions found in this group")
            continue

        for sub in subs["data"]:
            sub_id = sub["id"]
            product_id = sub["attributes"].get("productId", "?")
            sub_name = sub["attributes"].get("name", product_id)
            state = sub["attributes"].get("state", "?")
            print(f"\n    📱 {sub_name} ({product_id}) — state: {state}")

            if product_id not in SUBSCRIPTION_LOCALES:
                print(f"      ⚠️  No locale data defined for {product_id}, skipping")
                continue

            # Delete existing localizations
            sub_locs = api(session, "GET",
                          f"/v1/subscriptions/{sub_id}/subscriptionLocalizations",
                          params={"limit": "50"})
            if sub_locs and sub_locs.get("data"):
                for loc in sub_locs["data"]:
                    loc_id = loc["id"]
                    locale = loc["attributes"]["locale"]
                    loc_state = loc["attributes"].get("state", "?")
                    print(f"      🗑  Deleting {locale} (state: {loc_state}, id: {loc_id})...")
                    api(session, "DELETE", f"/v1/subscriptionLocalizations/{loc_id}")
                time.sleep(1)

            # Create new localizations
            locales_data = SUBSCRIPTION_LOCALES[product_id]
            for locale in LOCALES:
                if locale not in locales_data:
                    continue
                name, desc = locales_data[locale]
                body = {
                    "data": {
                        "type": "subscriptionLocalizations",
                        "attributes": {
                            "locale": locale,
                            "name": name,
                            "description": desc,
                        },
                        "relationships": {
                            "subscription": {
                                "data": {"type": "subscriptions", "id": sub_id}
                            }
                        },
                    }
                }
                result = api(session, "POST", "/v1/subscriptionLocalizations", data=body)
                status = "✅" if result else "❌"
                print(f"      {status} {locale}: {'created' if result else 'FAILED'}")

    print(f"\n{'='*60}")
    print("🎉 Done! Check App Store Connect to verify.")
    print("   Subscriptions should now show 'Waiting for Review' or 'Ready to Submit'.")
    print(f"{'='*60}")


if __name__ == "__main__":
    main()
