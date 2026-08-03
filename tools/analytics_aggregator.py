#!/usr/bin/env python3
"""Aggregate balance_report.json files into a single analytics summary and simple HTML dashboard.
Usage:
  python tools\analytics_aggregator.py --reports-dir reports --out-dir analytics
"""
import argparse
import json
import os
import statistics
from datetime import datetime


def load_reports(dirpath):
    reports = []
    for root, _, files in os.walk(dirpath):
        for f in files:
            if f.endswith("balance_report.json"):
                path = os.path.join(root, f)
                try:
                    with open(path, 'r', encoding='utf-8') as fh:
                        reports.append(json.load(fh))
                except Exception:
                    continue
    return reports


def aggregate(reports):
    entries = []
    for rep in reports:
        summary = rep.get('summary', {})
        entries.append(summary)
    total_runs = sum(e.get('total', 0) for e in entries)
    if total_runs == 0:
        return {"generated": datetime.utcnow().isoformat() + 'Z', "total_runs": 0}
    wins = sum(e.get('victories', 0) for e in entries)
    avg_duration = statistics.mean(e.get('avg_duration', 0.0) for e in entries if e.get('total',0)>0)
    avg_damage = statistics.mean(e.get('avg_damage', 0.0) for e in entries if e.get('total',0)>0)
    return {
        "generated": datetime.utcnow().isoformat() + 'Z',
        "report_count": len(entries),
        "total_runs": total_runs,
        "total_wins": wins,
        "global_win_rate": wins / total_runs,
        "mean_avg_duration": avg_duration,
        "mean_avg_damage": avg_damage,
    }


def to_html(agg, out_path):
    html = ["<html><head><meta charset='utf-8'><title>Analytics dashboard</title></head><body>"]
    html.append(f"<h1>Analytics Dashboard</h1>")
    html.append(f"<p>Generated: {agg.get('generated')}</p>")
    html.append("<ul>")
    html.append(f"<li>Reports aggregated: {agg.get('report_count',0)}</li>")
    html.append(f"<li>Total runs: {agg.get('total_runs',0)}</li>")
    html.append(f"<li>Total wins: {agg.get('total_wins',0)}</li>")
    html.append(f"<li>Global win rate: {agg.get('global_win_rate',0):.2f}</li>")
    html.append(f"<li>Mean avg duration: {agg.get('mean_avg_duration',0):.2f}</li>")
    html.append(f"<li>Mean avg damage: {agg.get('mean_avg_damage',0):.2f}</li>")
    html.append("</ul>")
    html.append("</body></html>")
    with open(out_path, 'w', encoding='utf-8') as fh:
        fh.write('\n'.join(html))


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--reports-dir', default='reports', help='Directory to scan for balance_report.json')
    p.add_argument('--out-dir', default='analytics', help='Directory to write aggregated outputs')
    args = p.parse_args()
    reports = load_reports(args.reports_dir)
    agg = aggregate(reports)
    os.makedirs(args.out_dir, exist_ok=True)
    agg_json = os.path.join(args.out_dir, 'analytics_summary.json')
    agg_html = os.path.join(args.out_dir, 'analytics_dashboard.html')
    with open(agg_json, 'w', encoding='utf-8') as fh:
        json.dump(agg, fh, indent=2, ensure_ascii=False)
    to_html(agg, agg_html)
    print(f'Wrote: {agg_json} and {agg_html}')

if __name__ == '__main__':
    main()
