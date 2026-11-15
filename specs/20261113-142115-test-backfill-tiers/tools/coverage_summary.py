#!/usr/bin/env python3
"""Line coverage of src/ before and after the back-fill (research R10).

usage: coverage_summary.py <repo root> <feature dir>

Before: the 557 tested files from the final runs of feature 20261104-115314-test-coverage-100
(covered = lines hit by the file's own test), and the 1085 untested files with 0 covered lines
(their executable-line counts from inventory/coverage/baseline-untested.jsonl). After: the same,
with each file tested in this feature replaced by its latest record in inventory/coverage/
wave*.jsonl or tier*.jsonl. Writes inventory/coverage-before.tsv (once) and
inventory/coverage-summary.md.

Feature 20261113-142115-test-backfill-tiers (campaign tool; not part of the toolbox).
"""
import glob
import json
import os
import sys

ROOT, FEATURE = sys.argv[1], sys.argv[2]
INV = os.path.join(FEATURE, 'inventory')


def as_list(v):
    return [] if v is None else (v if isinstance(v, list) else [v])


def records(paths):
    for p in paths:
        for line in open(p):
            if line.strip():
                yield json.loads(line)


def counts(rec):
    # class files list each line once per method context: count each line number once
    best = {}
    for n, h in zip(as_list(rec.get('lines')), as_list(rec.get('hits'))):
        best[n] = max(best.get(n, 0), h)
    return len(best), sum(1 for h in best.values() if h > 0)


before_file = os.path.join(INV, 'coverage-before.tsv')
previous = sorted(glob.glob(os.path.join(ROOT, 'specs', '20261104-115314-test-coverage-100',
                                         'coverage-runs', 'zz-final-*.jsonl')))
before = {}
if os.path.exists(before_file):
    for line in list(open(before_file))[1:]:
        k, n, c = line.rstrip('\n').split('\t')
        before[k] = (int(n), int(c))
    previous = []
for rec in records(previous):
    if rec.get('lines') is not None and rec['source'].startswith('src/'):
        before[rec['source']] = counts(rec)
if previous:
    for rec in records([os.path.join(INV, 'coverage', 'baseline-untested.jsonl')]):
        before.setdefault(rec['source'], (len(as_list(rec.get('lines'))), 0))

if not os.path.exists(before_file):
    with open(before_file, 'w') as f:
        f.write('file\texecutable_lines\tcovered_lines\n')
        for k in sorted(before):
            f.write('%s\t%d\t%d\n' % (k, before[k][0], before[k][1]))

after = dict(before)
runs = sorted(glob.glob(os.path.join(INV, 'coverage', 'wave*.jsonl'))) + \
    sorted(glob.glob(os.path.join(INV, 'coverage', 'tier*.jsonl')))
for rec in records(runs):
    if rec.get('status') == 'passed' and rec.get('lines') is not None:
        after[rec['source']] = counts(rec)


def total(d):
    lines = sum(v[0] for v in d.values())
    covered = sum(v[1] for v in d.values())
    files = sum(1 for v in d.values() if v[1] > 0)
    return lines, covered, files


bl, bc, bf = total(before)
al, ac, af = total(after)
with open(os.path.join(INV, 'coverage-summary.md'), 'w') as f:
    f.write('## Line coverage of src/ by each file\'s own test (research R10)\n\n')
    f.write('Measured over %d files (executable lines from MATLAB\'s coverage tool; files the earlier '
            'feature could not measure are counted only if this feature measured them).\n\n' % len(after))
    f.write('| | Executable lines | Covered lines | Coverage | Files with covered lines |\n')
    f.write('|---|---|---|---|---|\n')
    f.write('| Before | %d | %d | %.1f%% | %d |\n' % (bl, bc, 100.0 * bc / bl, bf))
    f.write('| After | %d | %d | %.1f%% | %d |\n' % (al, ac, 100.0 * ac / al, af))
# generated c13 solver files (slvrCumomer*, slvrEMU*) dominate the line count: report without them
generated = [k for k in after if os.path.basename(k).startswith(('slvrCumomer', 'slvrEMU'))]
gbl = sum(before[k][0] for k in generated)
gbc = sum(before[k][1] for k in generated)
gal = sum(after[k][0] for k in generated)
gac = sum(after[k][1] for k in generated)
with open(os.path.join(INV, 'coverage-summary.md'), 'a') as f:
    f.write('\nWithout the generated c13 solver files (%s, %d executable lines): before %.1f%%, '
            'after %.1f%%.\n' % (', '.join(sorted(os.path.basename(k) for k in generated)), gal,
                               100.0 * (bc - gbc) / (bl - gbl), 100.0 * (ac - gac) / (al - gal)))
print('before %d/%d (%.1f%%), after %d/%d (%.1f%%)' % (bc, bl, 100.0 * bc / bl, ac, al, 100.0 * ac / al))
