#!/usr/bin/env python3
"""Simple performance bench runner that simulates CPU work across seeds and measures timing.
"""
import argparse
import json
import os
import time
from datetime import datetime


def work(seed):
    # artificial CPU load proportional to seed mod
    loops = 10000 + (int(seed) % 10000)
    s = 0
    for i in range(loops):
        s += (i * i) % 97
    return s


def run(seeds, out_dir):
    results = []
    for s in seeds:
        t0 = time.perf_counter()
        work(s)
        t1 = time.perf_counter()
        results.append({"seed": int(s), "time": t1 - t0})
    os.makedirs(out_dir, exist_ok=True)
    out = os.path.join(out_dir, "perf_bench.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump({"generated": datetime.utcnow().isoformat()+"Z", "results": results}, f, indent=2)
    return out


def main():
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument('--seeds', default='1-5')
    p.add_argument('--out', default='perf')
    args = p.parse_args()
    # parse simple range
    seeds = []
    for part in args.seeds.split(','):
        if '-' in part:
            a,b = part.split('-')
            seeds.extend(range(int(a), int(b)+1))
        else:
            seeds.append(int(part))
    out = run(seeds, args.out)
    print(f"Wrote: {out}")

if __name__ == '__main__':
    main()
