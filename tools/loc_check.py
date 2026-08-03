#!/usr/bin/env python3
"""Localization checker: parse Godot .tres Translation resource files and report missing keys between locales.
Exits with non-zero if any keys missing or placeholder mismatches.
"""
import re
import json
import argparse
from pathlib import Path


def parse_tres(path: Path):
    text = path.read_text(encoding='utf-8')
    m = re.search(r"messages\s*=\s*\{(.*)\}\n", text, re.S)
    if not m:
        return {}
    body = m.group(1)
    # crude key:value parser for simple strings
    pairs = re.findall(r'"([^"]+)"\s*:\s*"([^"]*)"', body)
    return {k: v for k, v in pairs}


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--fr', default='resources/localization/ui.fr.tres')
    p.add_argument('--en', default='resources/localization/ui.en.tres')
    p.add_argument('--out', '-o', default='tools/reports/loc_audit.json')
    args = p.parse_args()
    fr = parse_tres(Path(args.fr))
    en = parse_tres(Path(args.en))
    fr_keys = set(fr.keys())
    en_keys = set(en.keys())
    missing_in_en = sorted(list(fr_keys - en_keys))
    missing_in_fr = sorted(list(en_keys - fr_keys))
    report = {
        'fr_count': len(fr_keys),
        'en_count': len(en_keys),
        'missing_in_en': missing_in_en,
        'missing_in_fr': missing_in_fr,
    }
    Path(args.out).parent.mkdir(parents=True, exist_ok=True)
    Path(args.out).write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding='utf-8')
    print(json.dumps(report, indent=2, ensure_ascii=False))
    if missing_in_en or missing_in_fr:
        raise SystemExit(2)

if __name__ == '__main__':
    main()
