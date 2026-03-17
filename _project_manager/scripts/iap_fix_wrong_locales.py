#!/usr/bin/env python3
"""
Delete wrong subscription group localizations (ar-SA with Korean text, ca with Chinese text).
These were pre-existing bad entries. The app does not support Arabic or Catalan.
"""

import os
import time
from pathlib import Path
import requests

KEY_ID = os.environ.get("ASC_KEY_ID", "3G9Q2GCT9V")
ISSUER_ID = os.environ.get("ASC_ISSUER_ID", "db062b0c-572d-4341-9aa3-2fb053ed0337")
P8_PATH = os.environ.get("ASC_P8_PATH", "/Users/nu_mac_studio/Library/CloudStorage/Dropbox/miro/AuthKey_3G9Q2GCT9V.p8")
BUNDLE_ID = os.environ.get("ASC_BUNDLE_ID", "com.tanabun.miroHybrid")
BASE = "https://api.appstoreconnect.apple.com"

LOCALES_TO_DELETE = {"ar-SA", "ca"}


def get_jwt():
    import jwt as pyjwt
    key = Path(P8_PATH).expanduser().read_text()
    now = int(time.time())
    payload = {"iss": ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"}
    return pyjwt.encode(payload, key, algorithm="ES256", headers={"kid": KEY_ID})


def main():
    session = requests.Session()
    session.headers.update({
        "Authorization": f"Bearer {get_jwt()}",
        "Content-Type": "application/json",
    })

    # Find app
    r = session.get(f"{BASE}/v1/apps", params={"filter[bundleId]": BUNDLE_ID, "limit": "1"}, timeout=30)
    app_id = r.json()["data"][0]["id"]
    print(f"App: {app_id}")

    # List subscription groups
    r = session.get(f"{BASE}/v1/apps/{app_id}/subscriptionGroups", params={"limit": "50"}, timeout=30)
    for sg in r.json().get("data", []):
        sg_id = sg["id"]
        sg_name = sg["attributes"].get("referenceName", sg_id)
        print(f"\nGroup: {sg_name} ({sg_id})")

        # List group localizations
        r2 = session.get(f"{BASE}/v1/subscriptionGroups/{sg_id}/subscriptionGroupLocalizations", params={"limit": "50"}, timeout=30)
        for loc in r2.json().get("data", []):
            loc_id = loc["id"]
            locale = loc["attributes"]["locale"]
            name = loc["attributes"].get("name", "")
            custom_app = loc["attributes"].get("customAppName", "")
            print(f"  {locale}: name={name}, appName={custom_app} (id={loc_id})")

            if locale in LOCALES_TO_DELETE:
                print(f"    → DELETING {locale} (wrong content)...")
                dr = session.delete(f"{BASE}/v1/subscriptionGroupLocalizations/{loc_id}", timeout=30)
                if dr.status_code < 300:
                    print(f"    → Deleted successfully")
                else:
                    print(f"    → Failed: {dr.status_code} {dr.text[:200]}")

    # Also check if pt-PT needs fixing (duplicate with pt-BR)
    print("\nNote: pt-PT and pt-BR both exist — this is fine (different regions).")
    print("Done.")


if __name__ == "__main__":
    main()
