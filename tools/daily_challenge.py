#!/usr/bin/env python3
"""Generate a deterministic daily challenge config and write to data/daily/current.json
"""
import json
from pathlib import Path
from datetime import date
import argparse


def make_daily_config(d: date):
    # simple deterministic LCG seed from date
    seed = d.year * 10000 + d.month * 100 + d.day
    cfg = {
        'date': d.isoformat(),
        'seed': seed,
        'rules': {
            'no_permanent_rewards': True,
            'mutator': 'double_rewards' if seed % 2 == 0 else 'tougher_monsters'
        }
    }
    return cfg


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--out', default='data/daily/current.json')
    p.add_argument('--date')
    args = p.parse_args()
    if args.date:
        d = date.fromisoformat(args.date)
    else:
        d = date.today()
    cfg = make_daily_config(d)
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(cfg, indent=2), encoding='utf-8')
    print(f"Wrote {out}")

if __name__ == '__main__':
    main()
