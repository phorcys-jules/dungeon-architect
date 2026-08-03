#!/usr/bin/env python3
"""Balance runner for CI and local use.
Produces JSON and Markdown reports using a deterministic LCG to match the in-engine simulator.
"""
import argparse
import json
import os
import statistics
from datetime import datetime


def lcg(seed):
    state = int(seed) & 0x7fffffff
    def randf():
        nonlocal state
        state = (1103515245 * state + 12345) & 0x7fffffff
        return float(state) / 2147483647.0
    return randf


def simulate(seed: int, difficulty: float = 1.0):
    r = lcg(seed)
    victory_chance = 0.5 + (r() - 0.5) - (0.05 * difficulty)
    victory = r() < victory_chance
    duration = 30.0 + int(r() * 60.0)
    damage = int(round(r() * 120.0 * difficulty))
    traps_used = 1 + int(r() * 5)
    return {
        "seed": int(seed),
        "victory": bool(victory),
        "duration": float(duration),
        "damage": int(damage),
        "traps_used": int(traps_used),
        "difficulty": float(difficulty),
    }


def summarize(results):
    total = len(results)
    if total == 0:
        return {"total": 0}
    victories = sum(1 for r in results if r.get("victory"))
    avg_duration = statistics.mean(r.get("duration", 0.0) for r in results)
    avg_damage = statistics.mean(r.get("damage", 0) for r in results)
    return {
        "total": total,
        "victories": victories,
        "win_rate": victories / total,
        "avg_duration": avg_duration,
        "avg_damage": avg_damage,
    }


def to_markdown(report):
    s = report.get("summary", {})
    md = f"# Balance simulation report\n\nGenerated: {datetime.utcnow().isoformat()}Z\n\n"
    md += f"- Total runs: {s.get('total',0)}\n"
    md += f"- Victories: {s.get('victories',0)} (win rate: {s.get('win_rate',0.0):.2f})\n"
    md += f"- Avg duration: {s.get('avg_duration',0.0):.2f}\n"
    md += f"- Avg damage: {s.get('avg_damage',0.0):.2f}\n\n"
    md += "## Runs\n\n"
    for r in report.get("results", []):
        md += f"- seed: {r['seed']} — victory: {r['victory']} — duration: {r['duration']:.1f} — damage: {r['damage']} — traps: {r['traps_used']}\n"
    return md


def run_matrix(seeds, difficulty, out_dir):
    results = []
    for s in seeds:
        results.append(simulate(int(s), difficulty))
    summary = summarize(results)
    report = {"summary": summary, "results": results}
    os.makedirs(out_dir, exist_ok=True)
    json_path = os.path.join(out_dir, "balance_report.json")
    md_path = os.path.join(out_dir, "balance_report.md")
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
    with open(md_path, "w", encoding="utf-8") as f:
        f.write(to_markdown(report))
    return json_path, md_path


def parse_seeds(s: str):
    # formats: 1,2,3 or 1-10 or start:end:step
    parts = []
    for part in s.split(','):
        part = part.strip()
        if '-' in part and ':' not in part:
            a,b = part.split('-',1)
            parts.extend(range(int(a), int(b)+1))
        elif ':' in part:
            a,b,step = part.split(':')
            parts.extend(range(int(a), int(b)+1, int(step)))
        else:
            parts.append(int(part))
    return parts


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--seeds', '-s', default='1-10', help='Seeds (comma list, range a-b, or a:b:step)')
    p.add_argument('--difficulty', '-d', type=float, default=1.0)
    p.add_argument('--out', '-o', default='reports')
    args = p.parse_args()
    seeds = parse_seeds(args.seeds)
    json_path, md_path = run_matrix(seeds, args.difficulty, args.out)
    print(f"Wrote: {json_path} and {md_path}")


if __name__ == '__main__':
    main()
