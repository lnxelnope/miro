# IAP Localization — App Store Connect API

Script `iap_localization_api.py` adds all 12 language localizations to every IAP and Energy Pass subscription via the App Store Connect API.

## Prerequisites

- Python 3.8+
- App Store Connect API Key (.p8) with **App Manager** or **Admin** role

## Setup

```bash
cd _project_manager/scripts
pip install -r requirements-iap-api.txt
```

## Config

Edit the top of `iap_localization_api.py` or set env vars:

| Env | Default | Description |
|-----|---------|-------------|
| `ASC_KEY_ID` | (in script) | Key ID from App Store Connect |
| `ASC_ISSUER_ID` | (in script) | Issuer ID from App Store Connect |
| `ASC_P8_PATH` | (in script) | Full path to `.p8` key file |
| `ASC_BUNDLE_ID` | `com.tanabun.miroHybrid` | App bundle ID |

## Run

```bash
python iap_localization_api.py
```

The script will:

1. Find the app by bundle ID
2. List all consumable IAPs and subscriptions
3. For each product, list existing localizations
4. **POST** missing locales (only creates; does not overwrite existing)

After use, revoke the API key in **App Store Connect → Users and Access → Integrations → Keys** if you created it only for this run.

## Product IDs

- Consumables: `energy_first_purchase_200`, `energy_100`, `energy_550`, `energy_1200`, `energy_2000`
- Subscriptions: `miro_energy_pass_weekly`, `miro_energy_pass_monthly`, `miro_energy_pass_yearly`

If a product is not found (e.g. different product ID in App Store Connect), that product is skipped and a warning is printed.
