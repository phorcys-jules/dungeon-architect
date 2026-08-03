#!/usr/bin/env python3
"""Performance bench runner for CI and local use.
Runs deterministic CPU work across seeds, measures wall time, CPU time and peak Python memory (tracemalloc),
writes a JSON report and exits non-zero if thresholds are exceeded (useful for CI budget checks).
"""
import argparse
import json
import os
import time
import tracemalloc
from datetime import datetime
import statistics


def work(seed):
    # artificial CPU load proportional to seed mod (fast, deterministic)
    loops = 10000 + (int(seed) % 10000)
    s = 0
    for i in range(loops):
        s += (i * i) % 97
    return s


def run(seeds, out_dir):
    results = []
    timings = []
    cpu_times = []
    tracemalloc.start()
    for s in seeds:
        start_wall = time.perf_counter()
        start_cpu = time.process_time()
        work(s)
        end_wall = time.perf_counter()
        end_cpu = time.process_time()
        elapsed = end_wall - start_wall
        cpu = end_cpu - start_cpu
        timings.append(elapsed)
        cpu_times.append(cpu)
        results.append({"seed": int(s), "elapsed": elapsed, "cpu": cpu})
    snapshot = tracemalloc.take_snapshot()
    tracemalloc.stop()
    # approximate peak using top statistics (sum of top entries)
    stats = snapshot.statistics('traceback') if snapshot else []
    peak = sum(s.size for s in stats[:20]) if stats else 0
    summary = {
        "generated": datetime.utcnow().isoformat() + "Z",
        "total_runs": len(results),
        "avg_time": statistics.mean(timings) if timings else 0.0,
        "p95_time": statistics.quantiles(timings, n=100)[94] if len(timings) >= 100 else (max(timings) if timings else 0.0),
        "avg_cpu": statistics.mean(cpu_times) if cpu_times else 0.0,
        "peak_memory_bytes": int(peak),
    }
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "perf_bench.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump({"summary": summary, "results": results}, f, indent=2)
    return out_path, summary


def parse_seeds(s: str):
    parts = []
    for part in s.split(','):
        part = part.strip()
        if '-' in part:
            a,b = part.split('-',1)
            parts.extend(range(int(a), int(b)+1))
        else:
            parts.append(int(part))
    return parts


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--seeds', '-s', default='1-20', help='Seeds (comma list or range a-b)')
    p.add_argument('--out', '-o', default='tools/reports/perf', help='Output directory')
    p.add_argument('--max-avg-time', type=float, default=0.02, help='Max average wall time per run (s)')
    p.add_argument('--max-peak-memory', type=int, default=50_000_000, help='Max allowed peak memory (bytes)')
    args = p.parse_args()
    seeds = parse_seeds(args.seeds)
    out_path, summary = run(seeds, args.out)
    print(f"Wrote: {out_path}")
    avg = summary['avg_time']
    peak = summary['peak_memory_bytes']
    if avg > args.max_avg_time:
        print(f"ERROR: avg time {avg:.4f}s > threshold {args.max_avg_time}s")
        raise SystemExit(2)
    if peak > args.max_peak_memory:
        print(f"ERROR: peak memory {peak} bytes > threshold {args.max_peak_memory}")
        raise SystemExit(3)
    print("Perf bench within thresholds")

if __name__ == '__main__':
    main()
