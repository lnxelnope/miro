#!/usr/bin/env python3
"""
Fix ICU plural syntax in ARB files.
Replaces incorrect plural keywords with 'other'.
"""

import json
import re
import os
from pathlib import Path

# Mapping of incorrect plural keywords to fix
INCORRECT_PLURAL_KEYWORDS = {
    'andere': 'other',    # German
    'otro': 'other',      # Spanish
    'autre': 'other',     # French
    'outro': 'other',     # Portuguese
    'lainnya': 'other',   # Indonesian
    'अन्य': 'other',      # Hindi
    '其他': 'other',       # Chinese
    '기타': 'other',       # Korean
    'その他': 'other',     # Japanese
    'その他の': 'other',   # Japanese variant
    'khác': 'other',      # Vietnamese
}

def fix_icu_syntax(text):
    """Fix ICU plural syntax by replacing incorrect keywords with 'other'."""
    if not isinstance(text, str):
        return text
    
    # Pattern to match plural expressions
    # Format: {var, plural, =1 {text} incorrect_keyword {text}}
    pattern = r'\{(\w+),\s*plural,\s*=1\s*\{([^}]+)\}\s*(' + '|'.join(map(re.escape, INCORRECT_PLURAL_KEYWORDS.keys())) + r')\s*\{([^}]+)\}\}'
    
    def replacer(match):
        var = match.group(1)
        singular_text = match.group(2)
        incorrect_keyword = match.group(3)
        plural_text = match.group(4)
        
        # Replace with correct 'other' keyword
        return f'{{{var}, plural, =1 {{{singular_text}}} other {{{plural_text}}}}}'
    
    fixed_text = re.sub(pattern, replacer, text)
    
    return fixed_text

def fix_arb_file(file_path):
    """Fix ICU syntax in a single ARB file."""
    print(f"Processing {file_path.name}...")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        fixed_count = 0
        
        # Iterate through all keys
        for key in list(data.keys()):
            # Skip metadata keys (those starting with @)
            if key.startswith('@'):
                continue
            
            original_value = data[key]
            fixed_value = fix_icu_syntax(original_value)
            
            if fixed_value != original_value:
                data[key] = fixed_value
                fixed_count += 1
                print(f"  Fixed: {key}")
        
        if fixed_count > 0:
            # Write back to file
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            print(f"  [OK] Fixed {fixed_count} entries in {file_path.name}")
        else:
            print(f"  [INFO] No fixes needed for {file_path.name}")
        
        return fixed_count
        
    except Exception as e:
        print(f"  [ERROR] Error processing {file_path.name}: {e}")
        return 0

def main():
    # Get the l10n directory
    script_dir = Path(__file__).parent
    project_dir = script_dir.parent
    l10n_dir = project_dir / 'lib' / 'l10n'
    
    if not l10n_dir.exists():
        print(f"[ERROR] l10n directory not found: {l10n_dir}")
        return
    
    print(f"Fixing ICU syntax in ARB files at: {l10n_dir}\n")
    
    # Get all ARB files except the template (app_en.arb)
    arb_files = sorted(l10n_dir.glob('app_*.arb'))
    
    # Exclude English template
    arb_files = [f for f in arb_files if f.name != 'app_en.arb' and f.name != 'app_th.arb']
    
    if not arb_files:
        print("[ERROR] No ARB files found to fix")
        return
    
    print(f"Found {len(arb_files)} ARB files to check\n")
    
    total_fixed = 0
    for arb_file in arb_files:
        fixed = fix_arb_file(arb_file)
        total_fixed += fixed
        print()
    
    print(f"\n{'='*60}")
    print(f"[DONE] Fixed {total_fixed} total entries across {len(arb_files)} files")
    print(f"{'='*60}")

if __name__ == '__main__':
    main()
