#!/usr/bin/env python3
"""Print one line per record of a measureCoverage JSON-lines file: status, executable lines,
missed line numbers, leftover state and the failure message.

usage: coverage_report.py <output.jsonl>   (feature 20261113-142115-test-backfill-tiers)
"""
import json
import sys


def as_list(value):
    if value is None:
        return []
    return value if isinstance(value, list) else [value]


for line in open(sys.argv[1]):
    if not line.strip():
        continue
    r = json.loads(line)
    lines, hits = as_list(r.get('lines')), as_list(r.get('hits'))
    best = {}
    for n, h in zip(lines, hits):
        best[n] = max(best.get(n, 0), h)
    missed = sorted(n for n, h in best.items() if h == 0)
    print('%s | %s | lines %d | missed %s | leftover: %s | %s' % (
        r['source'], r['status'], len(best), missed, r.get('leftover') or '-',
        (r.get('message') or '')[:300]))
