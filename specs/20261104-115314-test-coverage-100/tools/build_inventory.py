#!/usr/bin/env python3
"""Build coverage-inventory.md from the measurement records (coverage-runs/*.jsonl).

Status per mapped test (spec US1):
  COMPLETE  the test passed and every missed line is documented (or coverage is 100%)
  GAP       the test passed and some missed lines are not documented
  SKIPPED   the test's requirements are not met on the reference machine
  FAILING   the test failed
  ERROR     the measurement itself failed (no coverage data)
Documented lines (research R2): line numbers in the header's "Coverage exemptions" block, in a
line-number context, plus the LINES field of III-Defects entries. Later records for the same
test (re-measurements) replace earlier ones.

Usage: python3 build_inventory.py [--json out.json]
"""
import glob
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
FEATURE = os.path.dirname(HERE)
ROOT = os.path.dirname(os.path.dirname(FEATURE))

HEADER_LABELS = re.compile(
    r'^%\s*(Purpose|Function under test|Tier|Coverage exemptions|Known defects documented|'
    r'Authors?|Reference values|Notes?|Inputs?|Requirements?)\b', re.I)
RANGE = r'(\d+)(?:\s*(?:-|–|to)\s*(\d+))?'


def expand(text):
    """All line numbers in a list such as '64-72, 161 and 200'."""
    out = set()
    for a, b in re.findall(RANGE, text):
        a = int(a)
        b = int(b) if b else a
        if 0 < a <= b and b - a < 2000:
            out.update(range(a, b + 1))
    return out


def documented_lines(test_path):
    lines = open(os.path.join(ROOT, test_path), errors='ignore').read().splitlines()
    head = []
    for line in lines:
        if not line.lstrip().startswith('%') and line.strip():
            break
        head.append(line)
    doc = set()
    block = None
    for line in head:
        m = HEADER_LABELS.match(line)
        if m:
            label = m.group(1).lower()
            block = 'cov' if label.startswith('coverage') else ('def' if label.startswith('known') else None)
            rest = line[m.end():]
        else:
            rest = line
        text = rest.lstrip('%').strip()
        if block == 'cov':
            # "Line 33", "Lines 64 to 72, 161", "lines 95-96, 102-103"
            for seg in re.findall(r'\blines?\s+((?:\d+(?:\s*(?:-|–|to)\s*\d+)?(?:\s*(?:,|and|&)\s*)?)+)', text, re.I):
                doc |= expand(seg)
            # bullet that starts with line numbers: "477-480, 483   metabolites ..." or "54: ..."
            m2 = re.match(r'^(?:-\s*)?((?:\d+(?:\s*(?:-|–)\s*\d+)?\s*,?\s*)+)(?::|\s{2,}|\s*-\s|\s*\()', text)
            if m2:
                doc |= expand(m2.group(1))
        elif block == 'def':
            m3 = re.match(r'^LINES:\s*(.*)$', text)
            if m3:
                doc |= expand(m3.group(1))
    return doc


def load_records():
    recs = {}
    for f in sorted(glob.glob(os.path.join(FEATURE, 'coverage-runs', '*.jsonl'))):
        for line in open(f):
            line = line.strip()
            if line:
                r = json.loads(line)
                recs[r['test']] = r          # later files override earlier ones
    return recs


def as_list(v):
    if v is None or v == []:
        return []
    return v if isinstance(v, list) else [v]


def main():
    mapping = json.load(open(os.path.join(FEATURE, 'test-map.json')))
    recs = load_records()
    rows, out_of_scope = [], []
    for test, source, how in mapping:
        if how not in ('header', 'name'):
            out_of_scope.append(test)
            continue
        r = recs.get(test)
        if r is None:
            rows.append(dict(test=test, source=source, status='NOT MEASURED'))
            continue
        lines, hits = as_list(r.get('lines')), as_list(r.get('hits'))
        missed = [ln for ln, h in zip(lines, hits) if h == 0]
        status = r.get('status', '')
        row = dict(test=test, source=source, seconds=r.get('seconds'), message=(r.get('message') or '')[:160],
                   total=len(lines), covered=len(lines) - len(missed), missed=missed)
        if status == 'skipped':
            row['status'] = 'SKIPPED'
        elif status == 'failed':
            row['status'] = 'FAILING'
        elif status != 'passed' or not lines:
            row['status'] = 'ERROR'
        else:
            doc = documented_lines(test)
            undoc = [ln for ln in missed if ln not in doc]
            row['undocumented'] = undoc
            row['status'] = 'GAP' if undoc else 'COMPLETE'
        rows.append(row)
    if '--json' in sys.argv:
        json.dump(rows, open(sys.argv[sys.argv.index('--json') + 1], 'w'), indent=1)
    write_md(rows, out_of_scope)


def compress(nums):
    nums = sorted(nums)
    out, i = [], 0
    while i < len(nums):
        j = i
        while j + 1 < len(nums) and nums[j + 1] == nums[j] + 1:
            j += 1
        out.append(str(nums[i]) if i == j else f'{nums[i]}-{nums[j]}')
        i = j + 1
    return ', '.join(out)


def write_md(rows, out_of_scope):
    from collections import Counter
    c = Counter(r['status'] for r in rows)
    md = ['# Coverage inventory', '',
          '> Generated by `tools/build_inventory.py` from `coverage-runs/*.jsonl`; do not edit by hand.',
          '> Coverage is of the single function under test, measured by running the whole test once.',
          '', '## Summary', '', '| Status | Tests |', '|---|---:|']
    for s in ('COMPLETE', 'GAP', 'SKIPPED', 'FAILING', 'ERROR', 'NOT MEASURED'):
        md.append(f'| {s} | {c.get(s, 0)} |')
    md.append(f'| out of scope (no single function under test) | {len(out_of_scope)} |')
    for s in ('GAP', 'FAILING', 'ERROR', 'SKIPPED', 'COMPLETE', 'NOT MEASURED'):
        sel = [r for r in rows if r['status'] == s]
        if not sel:
            continue
        md += ['', f'## {s} ({len(sel)})', '']
        if s in ('GAP', 'COMPLETE'):
            md += ['| Test | Function | Covered | Undocumented missed lines |', '|---|---|---|---|']
            for r in sorted(sel, key=lambda r: r['source']):
                md.append(f"| `{r['test'].split('/')[-1]}` | `{r['source']}` | {r['covered']}/{r['total']} | "
                          f"{compress(r.get('undocumented', [])) or '—'} |")
        else:
            md += ['| Test | Function | Reason |', '|---|---|---|']
            for r in sorted(sel, key=lambda r: r['source']):
                msg = (r.get('message') or '').replace('|', '/').replace('\n', ' ')
                md.append(f"| `{r['test'].split('/')[-1]}` | `{r['source']}` | {msg} |")
    md += ['', f'## Out of scope ({len(out_of_scope)})', '',
           'No single function under test (legacy multi-function tests); III-Coverage is defined per function.', '']
    md += [f'- `{t}`' for t in sorted(out_of_scope)]
    open(os.path.join(FEATURE, 'coverage-inventory.md'), 'w').write('\n'.join(md) + '\n')
    print(dict(c), 'out of scope', len(out_of_scope))


if __name__ == '__main__':
    main()
