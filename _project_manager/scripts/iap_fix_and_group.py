#!/usr/bin/env python3
"""
Fix 2 issues:
1. PATCH truncated IAP descriptions (rewrite to fit 55 chars naturally)
2. POST subscription group localizations for missing languages

Run after iap_localization_api.py.
"""

import json
import os
import time
from pathlib import Path

import requests

KEY_ID = os.environ.get("ASC_KEY_ID", "3G9Q2GCT9V")
ISSUER_ID = os.environ.get("ASC_ISSUER_ID", "db062b0c-572d-4341-9aa3-2fb053ed0337")
P8_PATH = os.environ.get("ASC_P8_PATH", "/Users/nu_mac_studio/Library/CloudStorage/Dropbox/miro/AuthKey_3G9Q2GCT9V.p8")
BUNDLE_ID = os.environ.get("ASC_BUNDLE_ID", "com.tanabun.miroHybrid")

BASE = "https://api.appstoreconnect.apple.com"

# ── Rewritten descriptions (all ≤ 55 chars, natural endings) ──

CONSUMABLE_DESC_FIX = {
    "energy_first_purchase_200": {
        "es-ES": "¡Bienvenida! 200 energía para nuevos usuarios.",
        "fr-FR": "Bienvenue ! 200 énergie pour nouveaux utilisateurs.",
        "hi": "स्वागत! नए उपयोगकर्ताओं हेतु 200 ऊर्जा।",
        "id": "Selamat datang! 200 energi untuk pengguna baru.",
        "pt-BR": "Boas-vindas! 200 energia para novos usuários.",
    },
    "energy_100": {
        "hi": "AI सुविधाओं हेतु 100 ऊर्जा प्राप्त करें।",
    },
    "energy_550": {
        "hi": "AI हेतु 10% बोनस के साथ 550 ऊर्जा।",
    },
    "energy_1200": {
        "fr-FR": "1 200 énergie pour usage intensif de l'IA.",
        "hi": "गहन AI उपयोग हेतु 1,200 ऊर्जा।",
    },
    "energy_2000": {
        "hi": "सर्वोत्तम! AI हेतु 2,000 ऊर्जा।",
    },
}

# ── Subscription Group Localization (group-level, not per-subscription) ──

SUB_GROUP_LOCALES = {
    "de-DE": ("Energy Pass", "ArCal: KI-Kalorienzähler"),
    "es-ES": ("Energy Pass", "ArCal: Contador de Calorías IA"),
    "fr-FR": ("Energy Pass", "ArCal : Compteur de Calories IA"),
    "hi": ("Energy Pass", "ArCal: AI कैलोरी काउंटर"),
    "id": ("Energy Pass", "ArCal: Penghitung Kalori AI"),
    "ja": ("Energy Pass", "ArCal：AIカロリーカウンター"),
    "ko": ("Energy Pass", "ArCal: AI 칼로리 카운터"),
    "pt-BR": ("Energy Pass", "ArCal: Contador de Calorias IA"),
    "zh-Hans": ("Energy Pass", "ArCal：AI卡路里计算器"),
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
    if r.status_code >= 400:
        print(f"  {method} {path} → {r.status_code}: {r.text[:300]}")
        return None
    return r.json()


def main():
    session = requests.Session()
    session.headers.update({
        "Authorization": f"Bearer {get_jwt()}",
        "Content-Type": "application/json",
    })

    # 1) Find app
    apps = api(session, "GET", "/v1/apps", params={"filter[bundleId]": BUNDLE_ID, "limit": "1"})
    app_id = apps["data"][0]["id"]
    print(f"App: {app_id}")

    # 2) List IAPs
    iaps = api(session, "GET", f"/v1/apps/{app_id}/inAppPurchasesV2", params={"limit": "200"})
    pid_to_id = {}
    for iap in iaps.get("data", []):
        pid = iap["attributes"].get("productId", "")
        if pid:
            pid_to_id[pid] = iap["id"]

    # ─── FIX 1: PATCH truncated descriptions ───
    print("\n=== Fix 1: Patch truncated descriptions ===")
    for product_id, fixes in CONSUMABLE_DESC_FIX.items():
        iap_id = pid_to_id.get(product_id)
        if not iap_id:
            print(f"  Skip {product_id} (not found)")
            continue
        print(f"\n  {product_id} ({iap_id})")
        locs = api(session, "GET", f"/v2/inAppPurchases/{iap_id}/inAppPurchaseLocalizations", params={"limit": "200"})
        if not locs:
            continue
        locale_to_loc_id = {loc["attributes"]["locale"]: loc["id"] for loc in locs.get("data", [])}

        for locale, new_desc in fixes.items():
            loc_id = locale_to_loc_id.get(locale)
            if not loc_id:
                print(f"    {locale}: no existing localization to patch")
                continue
            body = {
                "data": {
                    "type": "inAppPurchaseLocalizations",
                    "id": loc_id,
                    "attributes": {"description": new_desc},
                }
            }
            result = api(session, "PATCH", f"/v1/inAppPurchaseLocalizations/{loc_id}", data=body)
            if result:
                print(f"    {locale}: patched ({len(new_desc)} chars)")
            else:
                print(f"    {locale}: patch failed")

    # ─── FIX 2: Add Subscription Group Localizations ───
    print("\n=== Fix 2: Subscription Group Localizations ===")
    sg_list = api(session, "GET", f"/v1/apps/{app_id}/subscriptionGroups", params={"limit": "50"})
    if not sg_list or not sg_list.get("data"):
        print("  No subscription groups found")
        return

    for sg in sg_list.get("data", []):
        sg_id = sg["id"]
        sg_name = sg["attributes"].get("referenceName", sg_id)
        print(f"\n  Group: {sg_name} ({sg_id})")

        existing_locs = api(session, "GET", f"/v1/subscriptionGroups/{sg_id}/subscriptionGroupLocalizations", params={"limit": "50"})
        existing_locales = set()
        if existing_locs and existing_locs.get("data"):
            existing_locales = {loc["attributes"]["locale"] for loc in existing_locs["data"]}
        print(f"    Existing: {sorted(existing_locales)}")

        for locale, (group_name, custom_app_name) in SUB_GROUP_LOCALES.items():
            if locale in existing_locales:
                print(f"    {locale}: already exists")
                continue
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
            if result:
                print(f"    {locale}: created")
            else:
                print(f"    {locale}: failed")

    print("\nDone.")


if __name__ == "__main__":
    main()
