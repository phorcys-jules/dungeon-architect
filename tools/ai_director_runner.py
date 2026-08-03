#!/usr/bin/env python3
"""AI Director runner: aggregates balance report summaries and shows director adjustments.
Usage:
  python tools\ai_director_runner.py --reports-dir reports --out-dir director_out
"""
import argparse
import json
import os
from datetime import datetime

from collections import deque


def load_summaries(dirpath):
    summaries = []
    for root, _, files in os.walk(dirpath):
        for f in files:
            if f.endswith("balance_report.json"):
                path = os.path.join(root, f)
                try:
                    with open(path, 'r', encoding='utf-8') as fh:
                        rep = json.load(fh)
                        summaries.append(rep.get('summary', {}))
                except Exception:
                    continue
    return summaries


def simulate_director(summaries, window=10, target=0.5):
    # Simple director: running history of summaries
    history = deque(maxlen=window)
    spawn_rate = 1.0
    outputs = []
    for s in summaries:
        history.append(s)
        total = sum(h.get('total',0) for h in history)
        wins = sum(h.get('victories',0) for h in history)
        current = (wins / total) if total>0 else 0.0
        diff = current - target
        delta = max(min(diff * 0.8, 0.5), -0.5)
        spawn_rate = max(min(spawn_rate + delta, 3.0), 0.2)
        difficulty_modifier = 1.0 + (spawn_rate - 1.0) * 0.6
        outputs.append({'time': datetime.utcnow().isoformat()+'Z', 'spawn_rate': spawn_rate, 'difficulty_modifier': difficulty_modifier, 'win_rate': current})
    return outputs


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--reports-dir', default='reports')
    p.add_argument('--out-dir', default='director_out')
    args = p.parse_args()
    summaries = load_summaries(args.reports_dir)
    outputs = simulate_director(summaries)
    os.makedirs(args.out_dir, exist_ok=True)
    out_path = os.path.join(args.out_dir, 'director_timeline.json')
    with open(out_path, 'w', encoding='utf-8') as fh:
        json.dump(outputs, fh, indent=2, ensure_ascii=False)
    print(f'Wrote: {out_path}')

if __name__ == '__main__':
    main()
