#!/usr/bin/env python3
"""
ARB Auto-Translation Script for MiRO
Translates Flutter ARB localization files from English to multiple languages
using Google Translate (free, no API key required).

Usage:
    pip install deep-translator
    python scripts/translate_arb.py                    # Translate all languages
    python scripts/translate_arb.py --langs es ja ko   # Translate specific languages
    python scripts/translate_arb.py --dry-run           # Preview without writing files
    python scripts/translate_arb.py --skip-existing      # Skip already translated keys
"""

import json
import os
import sys
import time
import re
import argparse
from pathlib import Path
from collections import OrderedDict

try:
    from deep_translator import GoogleTranslator
except ImportError:
    print("=" * 60)
    print("ERROR: deep-translator not installed")
    print("Run:  pip install deep-translator")
    print("=" * 60)
    sys.exit(1)

# ─── Target Languages ────────────────────────────────────────────────
# Format: (flutter_locale, google_translate_code, language_name, region_note)
#
# Tier 1: Must-have for global reach
# Tier 2: Recommended for wider coverage
# Tier 3: Nice-to-have for maximum reach

TIER_1_LANGUAGES = [
    ("es", "es", "Spanish", "Latin America + Spain, 500M+ speakers"),
    ("zh", "zh-CN", "Chinese (Simplified)", "China, 1.1B+ speakers"),
    ("ja", "ja", "Japanese", "Japan, health-conscious high-spending market"),
    ("ko", "ko", "Korean", "Korea, strong fitness/health culture"),
    ("hi", "hi", "Hindi", "India, 600M+ speakers, fast-growing market"),
    ("pt", "pt", "Portuguese", "Brazil 200M+, Portugal, Mozambique"),
    ("fr", "fr", "French", "France, Canada, Africa, 300M+ speakers"),
    ("de", "de", "German", "Germany/Austria/Switzerland, high-spending EU"),
    ("id", "id", "Indonesian", "Indonesia 270M population, SE Asia hub"),
    ("vi", "vi", "Vietnamese", "Vietnam 100M, growing health market"),
]

TIER_2_LANGUAGES = [
    ("ar", "ar", "Arabic", "Middle East + North Africa, 400M+ speakers"),
    ("it", "it", "Italian", "Italy, strong food culture"),
    ("tr", "tr", "Turkish", "Turkey 85M, growing tech adoption"),
    ("ru", "ru", "Russian", "Russia + CIS countries, 250M+ speakers"),
    ("ms", "ms", "Malay", "Malaysia + Brunei, SE Asia"),
    ("fil", "fil", "Filipino", "Philippines 110M, high English+local"),
    ("pl", "pl", "Polish", "Poland 38M, large EU market"),
    ("nl", "nl", "Dutch", "Netherlands + Belgium, high spending"),
]

TIER_3_LANGUAGES = [
    ("uk", "uk", "Ukrainian", "Ukraine 44M"),
    ("ro", "ro", "Romanian", "Romania 19M, EU member"),
    ("cs", "cs", "Czech", "Czech Republic, EU member"),
    ("sv", "sv", "Swedish", "Sweden, health-conscious market"),
    ("da", "da", "Danish", "Denmark, Nordic market"),
    ("nb", "no", "Norwegian", "Norway, high spending power"),
    ("fi", "fi", "Finnish", "Finland, Nordic market"),
    ("el", "el", "Greek", "Greece, Mediterranean diet culture"),
    ("hu", "hu", "Hungarian", "Hungary, EU member"),
    ("he", "iw", "Hebrew", "Israel, tech-savvy market"),
    ("bn", "bn", "Bengali", "Bangladesh + India, 250M+ speakers"),
    ("sw", "sw", "Swahili", "East Africa, 100M+ speakers"),
    ("my", "my", "Burmese", "Myanmar, SE Asia neighbor"),
    ("km", "km", "Khmer", "Cambodia, SE Asia"),
]

ALL_TIERS = {
    1: TIER_1_LANGUAGES,
    2: TIER_2_LANGUAGES,
    3: TIER_3_LANGUAGES,
}

# Words/patterns that should NOT be translated
PRESERVE_WORDS = [
    "MiRO", "Miro", "miro",
    "Gemini", "API Key", "API",
    "Google AI Studio", "Google",
    "kcal", "BMR", "TDEE", "BMI",
    "Pro", "Premium", "VIP",
    "Firebase", "Cloud",
]

# ─── Placeholder Protection ──────────────────────────────────────────

def protect_placeholders(text):
    """Replace {placeholder} with tokens to prevent translation."""
    placeholders = []
    pattern = re.compile(r'\{([^}]+)\}')

    def replacer(match):
        idx = len(placeholders)
        placeholders.append(match.group(0))
        return f"__PH{idx}__"

    protected = pattern.sub(replacer, text)
    return protected, placeholders


def restore_placeholders(text, placeholders):
    """Restore placeholder tokens back to {placeholder} format."""
    for idx, ph in enumerate(placeholders):
        token = f"__PH{idx}__"
        variations = [
            token,
            f"__ PH{idx}__",
            f"__PH{idx} __",
            f"__ PH{idx} __",
            f"__ph{idx}__",
            f"__ ph{idx}__",
            f"__ph{idx} __",
            f"__ ph{idx} __",
            f"__Ph{idx}__",
            f"PH{idx}",
            f"ph{idx}",
        ]
        for var in variations:
            if var in text:
                text = text.replace(var, ph, 1)
                break
        else:
            # If token completely lost, try regex
            loose = re.compile(rf'_*\s*PH\s*{idx}\s*_*', re.IGNORECASE)
            text = loose.sub(ph, text, count=1)

    return text


def protect_special_words(text):
    """Protect brand names and technical terms."""
    protected = []
    for word in PRESERVE_WORDS:
        if word in text:
            idx = len(protected)
            token = f"__SW{idx}__"
            protected.append((token, word))
            text = text.replace(word, token)
    return text, protected


def restore_special_words(text, protected):
    """Restore protected special words."""
    for token, word in protected:
        variations = [
            token,
            token.replace("__", "__ ").replace("__", " __"),
            token.lower(),
        ]
        for var in variations:
            if var in text:
                text = text.replace(var, word, 1)
                break
        else:
            loose = re.compile(rf'_*\s*SW{token[4:-2]}\s*_*', re.IGNORECASE)
            text = loose.sub(word, text, count=1)
    return text

# ─── Translation ─────────────────────────────────────────────────────

def translate_text(text, target_lang, retries=3):
    """Translate a single text string with placeholder protection."""
    if not text or not text.strip():
        return text

    # Protect placeholders and special words
    protected_text, placeholders = protect_placeholders(text)
    protected_text, special_words = protect_special_words(protected_text)

    for attempt in range(retries):
        try:
            translator = GoogleTranslator(source='en', target=target_lang)
            translated = translator.translate(protected_text)

            if not translated:
                return text

            # Restore protected content
            translated = restore_special_words(translated, special_words)
            translated = restore_placeholders(translated, placeholders)

            return translated

        except Exception as e:
            if attempt < retries - 1:
                wait = (attempt + 1) * 2
                print(f"    ⚠ Retry {attempt + 1}/{retries} after {wait}s: {e}")
                time.sleep(wait)
            else:
                print(f"    ✗ Failed to translate: {e}")
                return text

    return text


def is_metadata_key(key):
    """Check if a key is ARB metadata (starts with @)."""
    return key.startswith("@")


def should_skip_translation(key, value):
    """Determine if a value should be skipped (not translated)."""
    if is_metadata_key(key):
        return True
    if key == "@@locale":
        return True
    if not isinstance(value, str):
        return True
    if not value.strip():
        return True
    # Skip keys that are just technical values
    if key in ("kcal", "appName"):
        return True
    # Skip if value is just a placeholder pattern
    if re.fullmatch(r'[\{\}\w\s\\n]*', value) and '{' in value and len(value.replace(' ', '').replace('{', '').replace('}', '')) < 3:
        return True
    return False

# ─── Main Logic ──────────────────────────────────────────────────────

def load_arb(filepath):
    """Load an ARB file preserving key order."""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.loads(f.read(), object_pairs_hook=OrderedDict)


def save_arb(data, filepath):
    """Save ARB data to file with proper formatting."""
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write('\n')


def translate_arb(source_data, target_lang_code, flutter_locale, existing_data=None, skip_existing=False):
    """Translate all entries in an ARB file."""
    result = OrderedDict()
    result["@@locale"] = flutter_locale

    total_keys = sum(1 for k in source_data if not should_skip_translation(k, source_data.get(k, "")) == False and not is_metadata_key(k) and k != "@@locale")
    translatable_keys = [k for k in source_data if not should_skip_translation(k, source_data[k])]
    translated_count = 0
    skipped_count = 0

    for key in source_data:
        if key == "@@locale":
            continue

        value = source_data[key]

        # Copy metadata as-is
        if is_metadata_key(key):
            result[key] = value
            continue

        # Skip non-translatable values
        if should_skip_translation(key, value):
            result[key] = value
            continue

        # Skip if already translated and flag is set
        if skip_existing and existing_data and key in existing_data:
            result[key] = existing_data[key]
            skipped_count += 1
            continue

        # Translate
        translated = translate_text(value, target_lang_code)
        result[key] = translated
        translated_count += 1

        # Rate limiting (avoid being blocked)
        if translated_count % 5 == 0:
            time.sleep(0.5)

        # Progress
        if translated_count % 20 == 0:
            print(f"    ... translated {translated_count} keys")

    return result, translated_count, skipped_count


def count_translatable_keys(data):
    """Count how many keys need translation."""
    return sum(1 for k, v in data.items() if not should_skip_translation(k, v))


def main():
    parser = argparse.ArgumentParser(description="Translate MiRO ARB files using Google Translate")
    parser.add_argument('--langs', nargs='+', help='Specific language codes to translate (e.g., es ja ko)')
    parser.add_argument('--tiers', nargs='+', type=int, choices=[1, 2, 3],
                        help='Which tiers to translate (1=must-have, 2=recommended, 3=nice-to-have)')
    parser.add_argument('--dry-run', action='store_true', help='Preview languages without translating')
    parser.add_argument('--skip-existing', action='store_true', help='Skip keys that already exist in target file')
    parser.add_argument('--list', action='store_true', help='List all available languages')
    args = parser.parse_args()

    # Paths
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    l10n_dir = project_root / "lib" / "l10n"
    source_file = l10n_dir / "app_en.arb"

    if not source_file.exists():
        print(f"ERROR: Source file not found: {source_file}")
        sys.exit(1)

    # List languages mode
    if args.list:
        print("\n" + "=" * 70)
        print("   Available Languages for Translation")
        print("=" * 70)
        for tier_num, tier_langs in ALL_TIERS.items():
            tier_names = {1: "MUST-HAVE", 2: "RECOMMENDED", 3: "NICE-TO-HAVE"}
            print(f"\n── Tier {tier_num}: {tier_names[tier_num]} ──")
            for locale, gt_code, name, note in tier_langs:
                print(f"  {locale:>5}  {name:<25} {note}")
        print(f"\n  Total: {sum(len(t) for t in ALL_TIERS.values())} languages")
        print(f"  Already have: en (English), th (Thai)")
        print("=" * 70)
        return

    # Determine target languages
    target_languages = []

    if args.langs:
        all_langs = {loc: (loc, gt, name, note) for tier in ALL_TIERS.values() for loc, gt, name, note in tier}
        for lang in args.langs:
            if lang in all_langs:
                target_languages.append(all_langs[lang])
            elif lang in ('en', 'th'):
                print(f"  Skipping {lang} (already exists)")
            else:
                print(f"  WARNING: Unknown language code '{lang}', skipping")
    elif args.tiers:
        for tier in sorted(args.tiers):
            target_languages.extend(ALL_TIERS[tier])
    else:
        # Default: Tier 1 only
        target_languages = TIER_1_LANGUAGES

    if not target_languages:
        print("No target languages selected.")
        return

    # Load source
    print(f"\n📂 Source: {source_file}")
    source_data = load_arb(source_file)
    key_count = count_translatable_keys(source_data)
    print(f"📊 Found {key_count} translatable keys\n")

    # Preview mode
    print("=" * 60)
    print("  Target Languages:")
    print("=" * 60)
    for locale, gt_code, name, note in target_languages:
        target_file = l10n_dir / f"app_{locale}.arb"
        exists = "✓ exists" if target_file.exists() else "  new"
        print(f"  {locale:>5}  {name:<25} [{exists}]")
    print(f"\n  Total: {len(target_languages)} languages × {key_count} keys")
    print("=" * 60)

    if args.dry_run:
        print("\n🔍 Dry run mode - no files will be written")
        return

    # Confirm
    response = input(f"\nProceed with translation? (y/n): ").strip().lower()
    if response != 'y':
        print("Cancelled.")
        return

    # Translate each language
    print()
    success_count = 0
    fail_count = 0

    for i, (locale, gt_code, name, note) in enumerate(target_languages, 1):
        target_file = l10n_dir / f"app_{locale}.arb"
        print(f"[{i}/{len(target_languages)}] 🌐 Translating to {name} ({locale})...")

        existing_data = None
        if target_file.exists() and args.skip_existing:
            existing_data = load_arb(target_file)

        try:
            start_time = time.time()
            translated_data, translated_count, skipped_count = translate_arb(
                source_data, gt_code, locale,
                existing_data=existing_data,
                skip_existing=args.skip_existing
            )
            elapsed = time.time() - start_time

            save_arb(translated_data, target_file)
            status = f"✓ {translated_count} translated"
            if skipped_count:
                status += f", {skipped_count} skipped"
            status += f" ({elapsed:.1f}s)"
            print(f"  {status}")
            print(f"  → {target_file}")
            success_count += 1

        except Exception as e:
            print(f"  ✗ Error: {e}")
            fail_count += 1

        # Pause between languages to avoid rate limiting
        if i < len(target_languages):
            time.sleep(1)

    # Summary
    print("\n" + "=" * 60)
    print(f"  Translation Complete!")
    print(f"  ✓ Success: {success_count}")
    if fail_count:
        print(f"  ✗ Failed: {fail_count}")
    print("=" * 60)

    # Reminder
    print(f"""
📋 Next steps:
  1. Review translations in lib/l10n/app_*.arb
  2. Update l10n.yaml or pubspec.yaml to add new locales
  3. Run: flutter gen-l10n
  4. Test the app in each language

⚠️  Machine translations should be reviewed by native speakers
   for production quality, especially for:
   - Marketing text (subscription screens, onboarding)
   - Legal text (privacy policy, terms)
   - Health/nutrition terminology
""")


if __name__ == "__main__":
    main()
