#!/usr/bin/env python3
"""Print the prompt for the helper of one slice of a wave.

usage: slice_prompt.py <feature dir> <wave number> <slice letter>
Feature 20261113-142115-test-backfill-tiers (campaign tool; not part of the toolbox).
"""
import csv
import os
import sys

feature, wave, letter = sys.argv[1], int(sys.argv[2]), sys.argv[3]
path = os.path.join(feature, 'inventory', 'waves', 'wave%02d.tsv' % wave)
rows = [r for r in csv.DictReader(open(path), delimiter='\t') if r['slice'] == letter]
lines = []
for r in rows:
    extra = []
    if r['cycle']:
        extra.append('call cycle with %s: test each member in its own file' % r['cycle'])
    if r['untested_callees']:
        extra.append('untested callees (done earlier): ' + r['untested_callees'])
    if r['flags']:
        extra.append('flags: ' + r['flags'])
    if r.get('notes'):
        extra.append('reviewer note: ' + r['notes'])
    lines.append('%s | tier %s%s' % (r['file'], r['tier'], (' | ' + ' | '.join(extra)) if extra else ''))
print('''You are a test-writing helper for the COBRA Toolbox back-fill campaign. Repository: %s (work
from its root). Your complete instructions are in %s/inventory/agent-brief.md: read it first, then
the constitution sections and contracts it names, and follow it exactly. You are wave %02d, slice %s.
Write your results to %s/inventory/results/wave%02d-%s.jsonl.

Your slice:
%s

Never edit src/, existing tests, the ledger or git state. Start MATLAB only through the tools named
in the brief. Keep your final message to at most 15 lines: one line per row
(name: STATUS - very short note) and then only the decisions the lead must take; all details
belong in the records' notes.''' % (os.getcwd(), feature, wave, letter, feature, wave, letter,
                                    '\n'.join(lines)))
