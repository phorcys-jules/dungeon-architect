#!/usr/bin/env python3
import subprocess
import json
import sys
from pathlib import Path

def run():
    p = subprocess.run([sys.executable, 'tools/daily_challenge.py', '--date', '2026-08-03'], check=False)
    if p.returncode != 0:
        print('daily_challenge script failed')
        return 1
    path = Path('data/daily/current.json')
    if not path.exists():
        print('output file missing')
        return 2
    data = json.loads(path.read_text(encoding='utf-8'))
    if data.get('date') != '2026-08-03':
        print('date mismatch')
        return 3
    print('daily challenge smoke test passed')
    return 0

if __name__ == '__main__':
    raise SystemExit(run())
