# Simple smoke test for perf_bench: run 1 seed and ensure it produces a report file
import subprocess
import sys
from pathlib import Path

out = Path('tools/reports/perf_smoke')
out.mkdir(parents=True, exist_ok=True)
ret = subprocess.run([sys.executable, 'tools/perf_bench.py', '--seeds', '1-3', '--out', str(out)], capture_output=True, text=True)
print(ret.stdout)
if ret.returncode != 0:
    print(ret.stderr)
    raise SystemExit(ret.returncode)
print('Perf smoke test passed')
