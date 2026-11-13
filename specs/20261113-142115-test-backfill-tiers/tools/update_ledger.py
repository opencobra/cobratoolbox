#!/usr/bin/env python3
"""Maintain the back-fill ledger: waves, results, blocking, checks and reports.

usage:
  update_ledger.py <feature dir> --next-wave <tier> [--limit N] [--slice-size 10]
  update_ledger.py <feature dir> --apply <results.jsonl> [...]
  update_ledger.py <feature dir> --existing-defect <src file> <test file> "<defect title>"
  update_ledger.py <feature dir> --reclassify <review.tsv> [...]   (file, decision, reason)
  update_ledger.py <feature dir> --check
  update_ledger.py <feature dir> --summary

Ledger: <feature dir>/inventory/ledger.tsv (data-model.md). Results: contracts/agent-result.md;
the lead adds "confirmed_by" to records with a quarantining defect after the second reading.

Feature 20261113-142115-test-backfill-tiers (campaign tool; not part of the toolbox).
"""
import argparse
import collections
import csv
import glob
import json
import os
import re
import sys

FIELDS = ['order', 'file', 'tier', 'status', 'reason', 'flags', 'cycle', 'untested_callees',
          'callers', 'test', 'lines', 'missed', 'exempt', 'wave', 'confirmed_by', 'notes']
FINAL_OK = {'TESTED', 'EXCLUDED'}
BLOCKERS = {'QUARANTINED', 'BLOCKED'}


def name_of(path):
    return os.path.basename(path)[:-2]


class Ledger:
    def __init__(self, feature):
        self.feature = feature
        self.inv = os.path.join(feature, 'inventory')
        self.path = os.path.join(self.inv, 'ledger.tsv')
        with open(self.path) as f:
            self.rows = list(csv.DictReader(f, delimiter='\t'))
        for r in self.rows:
            for k in FIELDS:
                r.setdefault(k, '')
                if r[k] is None:
                    r[k] = ''
        self.by_name = {name_of(r['file']): r for r in self.rows}
        self.by_file = {r['file']: r for r in self.rows}
        self.existing = self._read_existing()

    # ---- persistence
    def save(self):
        with open(self.path, 'w', newline='') as f:
            w = csv.DictWriter(f, fieldnames=FIELDS, delimiter='\t', lineterminator='\n')
            w.writeheader()
            for r in sorted(self.rows, key=lambda r: int(r['order'])):
                w.writerow({k: r.get(k, '') for k in FIELDS})

    def _read_existing(self):
        path = os.path.join(self.inv, 'existing-defective.tsv')
        out = {}
        if os.path.exists(path):
            for line in open(path):
                if line.strip() and not line.startswith('#'):
                    src, test, title = line.rstrip('\n').split('\t')[:3]
                    out[name_of(src)] = (src, test, title)
        return out

    # ---- graph helpers
    def callees(self, r):
        return [c for c in r['untested_callees'].split(',') if c]

    def cycle(self, r):
        return set(c for c in r['cycle'].split(',') if c) - {name_of(r['file'])}

    def root_blockers(self, name, seen=None):
        """Quarantined (or existing-defective) functions reached through a blocked/quarantined name."""
        seen = seen or set()
        if name in seen:
            return set()
        seen.add(name)
        if name in self.existing:
            return {name}
        r = self.by_name.get(name)
        if r is None:
            return set()
        if r['status'] == 'QUARANTINED':
            return {name}
        if r['status'] == 'BLOCKED':
            out = set()
            for b in re.findall(r'[A-Za-z]\w*', r['reason'].replace('blocked by', '')):
                out |= self.root_blockers(b, seen)
            return out
        return set()

    def existing_callers(self, name):
        """Untested rows that call an already-tested function (static calls and name references)."""
        out = set()
        raw = os.path.join(self.inv, 'callgraph-raw.tsv')
        for line in open(raw):
            a, b, c = (line.rstrip('\n').split('\t') + ['', ''])[:3]
            if c == 'call' and b == name and a in self.by_file:
                out.add(a)
        root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(self.inv))))
        pattern = re.compile(r'(@\s*%s\b)|((feval|str2func)\s*\(\s*[\'"]%s[\'"])' % (name, name))
        for r in self.rows:
            try:
                if pattern.search(open(os.path.join(root, r['file']), errors='ignore').read()):
                    out.add(r['file'])
            except OSError:
                pass
        return out

    def propagate(self):
        """Block every PENDING row (and, by the late-edge rule, every TESTED row) that reaches a
        quarantined or existing-defective function. Returns the tests that must be removed."""
        removed = []
        for name in self.existing:
            for f in self.existing_callers(name):
                r = self.by_file[f]
                if name not in self.callees(r):
                    r['untested_callees'] = ','.join(self.callees(r) + [name])
        changed = True
        while changed:
            changed = False
            for r in self.rows:
                if r['status'] not in ('PENDING', 'TESTED'):
                    continue
                blockers = set()
                for c in self.callees(r):
                    if c in self.cycle(r):
                        continue
                    blockers |= self.root_blockers(c)
                if blockers:
                    if r['status'] == 'TESTED':
                        removed.append(r['test'])
                        r['notes'] = (r['notes'] + '; ' if r['notes'] else '') + \
                            'test removed: late-discovered call to a quarantined function (FR-009)'
                        r['test'] = ''
                    r['status'] = 'BLOCKED'
                    r['reason'] = 'blocked by ' + ', '.join(sorted(blockers))
                    changed = True
        return removed

    # ---- waves
    def next_wave(self, tier, limit, slice_size):
        removed = self.propagate()
        ready = []
        for r in sorted(self.rows, key=lambda r: int(r['order'])):
            if r['status'] != 'PENDING' or r['tier'] != str(tier):
                continue
            ok = True
            for c in self.callees(r):
                if c in self.cycle(r):
                    continue
                cr = self.by_name.get(c)
                if c in self.existing:
                    ok = False
                elif cr is not None and cr['status'] not in FINAL_OK:
                    ok = False
            if ok:
                ready.append(r)
        if limit:
            ready = ready[:limit]
        # keep cycle members together; group by folder so a slice shares context
        ready.sort(key=lambda r: (os.path.dirname(r['file']), int(r['order'])))
        slices, current = [], []
        for r in ready:
            if len(current) >= slice_size and not (self.cycle(r) & {name_of(x['file']) for x in current}):
                slices.append(current)
                current = []
            current.append(r)
        if current:
            slices.append(current)
        waves = sorted(glob.glob(os.path.join(self.inv, 'waves', 'wave*.tsv')))
        number = len({os.path.basename(w)[4:6] for w in waves}) + 1
        os.makedirs(os.path.join(self.inv, 'waves'), exist_ok=True)
        out = os.path.join(self.inv, 'waves', 'wave%02d.tsv' % number)
        if ready:
            with open(out, 'w') as f:
                f.write('slice\torder\tfile\ttier\tflags\tcycle\tuntested_callees\tcallers\tnotes\n')
                for k, s in enumerate(slices):
                    for r in s:
                        f.write('\t'.join([chr(ord('a') + k), r['order'], r['file'], r['tier'],
                                           r['flags'], r['cycle'], r['untested_callees'],
                                           r['callers'], r['notes']]) + '\n')
        self.save()
        return number, slices, removed, out

    # ---- results
    def apply(self, files):
        problems = []
        extra = os.path.join(self.inv, 'extra-edges.tsv')
        for path in files:
            wave = re.search(r'wave(\d+)', os.path.basename(path))
            for line in open(path):
                if not line.strip():
                    continue
                rec = json.loads(line)
                r = self.by_file.get(rec['file'])
                if r is None:
                    problems.append('unknown file ' + rec['file'])
                    continue
                status = rec['status']
                missed = sorted(rec.get('missed') or [])
                exempt = sorted(rec.get('exempt') or [])
                defects = rec.get('defects') or []
                if status == 'TESTED' and (not rec.get('passed') or missed != exempt):
                    problems.append('%s: TESTED but passed=%s, undocumented lines %s' % (
                        rec['file'], rec.get('passed'), sorted(set(missed) - set(exempt))))
                    continue
                if status == 'QUARANTINED':
                    if not any(d.get('quarantine') for d in defects):
                        problems.append(rec['file'] + ': QUARANTINED without a quarantining defect')
                        continue
                    if not rec.get('confirmed_by'):
                        problems.append(rec['file'] + ': quarantine not confirmed by a second reader')
                        continue
                    r['reason'] = '; '.join(d['title'] for d in defects if d.get('quarantine'))
                    r['confirmed_by'] = rec['confirmed_by']
                elif status == 'EXCLUDED':
                    r['reason'] = rec.get('reason', '')
                else:
                    r['reason'] = '; '.join('defect (%s, input skipped): %s' % (d['severity'], d['title'])
                                            for d in defects)
                r['status'] = status
                r['tier'] = str(rec.get('tier') or r['tier'])
                r['test'] = rec.get('test') or ''
                r['lines'] = str(rec.get('lines') or '')
                r['missed'] = ' '.join(map(str, missed))
                r['exempt'] = ' '.join(map(str, exempt))
                r['wave'] = wave.group(1) if wave else ''
                if rec.get('notes'):
                    r['notes'] = rec['notes']
                for e in rec.get('extra_edges') or []:
                    callee = name_of(e)
                    with open(extra, 'a') as f:
                        f.write('%s\t%s\n' % (rec['file'], e))
                    if callee in self.by_name and callee not in self.callees(r):
                        r['untested_callees'] = ','.join(self.callees(r) + [callee])
        removed = self.propagate()
        self.save()
        return problems, removed

    # ---- reclassification after reading the code (T008)
    def reclassify(self, files):
        changes = []
        for path in files:
            with open(path) as f:
                for rec in csv.DictReader(f, delimiter='\t'):
                    r = self.by_file.get(rec['file'])
                    if r is None or r['status'] not in ('PENDING', 'EXCLUDED'):
                        continue
                    decision = rec['decision'].strip().upper()
                    if decision == 'TESTABLE' and r['status'] == 'EXCLUDED':
                        r['status'], r['reason'] = 'PENDING', ''
                        r['notes'] = 'reclassified testable (T008): ' + rec['reason']
                        changes.append((r['file'], 'PENDING'))
                    elif decision in ('EXCLUDE', 'EXCLUDED') and r['status'] == 'PENDING':
                        r['status'], r['reason'] = 'EXCLUDED', rec['reason']
                        r['notes'] = 'reclassified excluded (T008)'
                        changes.append((r['file'], 'EXCLUDED'))
                    elif decision == 'KEEP' and r['status'] == 'EXCLUDED':
                        r['reason'] = rec['reason'] or r['reason']
        self.save()
        return changes

    # ---- checks
    def check(self):
        issues = []
        pos = {name_of(r['file']): int(r['order']) for r in self.rows}
        counts = collections.Counter(r['status'] for r in self.rows)
        for r in self.rows:
            n = name_of(r['file'])
            for c in self.callees(r):
                if c in pos and pos[c] > pos[n] and c not in self.cycle(r):
                    issues.append('order: %s before its callee %s' % (n, c))
            if r['status'] == 'BLOCKED' and not self.root_blockers(n):
                issues.append('BLOCKED without a quarantined reach: ' + n)
            if r['status'] == 'QUARANTINED' and (not r['reason'] or not r['confirmed_by']):
                issues.append('QUARANTINED without confirmed defect: ' + n)
            if r['status'] in ('TESTED', 'QUARANTINED') and not r['test']:
                issues.append('%s without a test file: %s' % (r['status'], n))
            if r['status'] == 'TESTED' and r['missed'] != r['exempt']:
                issues.append('TESTED with undocumented missed lines: ' + n)
            if r['status'] == 'EXCLUDED' and not r['reason']:
                issues.append('EXCLUDED without reason: ' + n)
        return counts, issues

    # ---- reports
    def blocked_by_root(self):
        out = collections.defaultdict(list)
        for r in self.rows:
            if r['status'] == 'BLOCKED':
                for b in self.root_blockers(name_of(r['file'])):
                    out[b].append(r['file'])
        return out

    def reports(self):
        blocked = self.blocked_by_root()
        with open(os.path.join(self.inv, 'quarantine.md'), 'w') as f:
            f.write('# Quarantine list\n\nGenerated by tools/update_ledger.py --summary. Ranked by '
                    'the number of untested files each defect blocks.\n')
            roots = [r for r in self.rows if r['status'] == 'QUARANTINED']
            roots += [{'file': v[0], 'reason': v[2], 'test': v[1], 'confirmed_by': 'existing test',
                       'existing': True} for v in self.existing.values()]
            roots.sort(key=lambda r: (-len(blocked.get(name_of(r['file']), [])), r['file']))
            for r in roots:
                n = name_of(r['file'])
                f.write('\n## %s%s\n\n- File: `%s`\n- Defect: %s\n- Test: `%s`\n- Confirmed by: %s\n'
                        '- Blocks %d file(s)%s\n' % (
                            n, ' (existing test, FR-012)' if r.get('existing') else '', r['file'],
                            r['reason'], r['test'], r['confirmed_by'], len(blocked.get(n, [])),
                            ':' if blocked.get(n) else ''))
                for b in sorted(blocked.get(n, [])):
                    f.write('  - `%s`\n' % b)
        counts = collections.Counter((r['status'], r['tier']) for r in self.rows)
        statuses = ['PENDING', 'TESTED', 'QUARANTINED', 'BLOCKED', 'EXCLUDED']
        with open(os.path.join(self.inv, 'summary.md'), 'w') as f:
            f.write('# Campaign summary\n\nGenerated by tools/update_ledger.py --summary.\n\n')
            f.write('| Status | Tier 1 | Tier 2 | Tier 3 | Tier 4/5 | Total |\n|---|---|---|---|---|---|\n')
            for s in statuses:
                cells = [counts.get((s, t), 0) for t in '1234']
                f.write('| %s | %s | %d |\n' % (s, ' | '.join(map(str, cells)), sum(cells)))
            f.write('\n## Excluded files by reason\n\n')
            reasons = collections.Counter(re.split(r'[:(]', r['reason'])[0].strip()
                                          for r in self.rows if r['status'] == 'EXCLUDED')
            for k, v in reasons.most_common():
                f.write('- %s: %d\n' % (k, v))
            f.write('\n## Quarantine ranking\n\n')
            for n, files in sorted(blocked.items(), key=lambda kv: -len(kv[1])):
                f.write('- %s: blocks %d\n' % (n, len(files)))
            cov = os.path.join(self.inv, 'coverage-summary.md')
            if os.path.exists(cov):
                f.write('\n' + open(cov).read())
            counts2, issues = self.check()
            f.write('\n## Checks\n\n%s\n' % ('\n'.join('- ' + i for i in issues) if issues else 'No issues.'))


def main():
    p = argparse.ArgumentParser()
    p.add_argument('feature')
    p.add_argument('--next-wave', type=int)
    p.add_argument('--limit', type=int, default=0)
    p.add_argument('--slice-size', type=int, default=10)
    p.add_argument('--apply', nargs='+')
    p.add_argument('--existing-defect', nargs=3)
    p.add_argument('--reclassify', nargs='+')
    p.add_argument('--check', action='store_true')
    p.add_argument('--summary', action='store_true')
    a = p.parse_args()
    L = Ledger(a.feature)
    if a.existing_defect:
        with open(os.path.join(L.inv, 'existing-defective.tsv'), 'a') as f:
            f.write('\t'.join(a.existing_defect) + '\n')
        L = Ledger(a.feature)
        removed = L.propagate()
        L.save()
        print('existing-defective recorded; tests to remove:', removed)
    if a.reclassify:
        changes = L.reclassify(a.reclassify)
        print('reclassified %d rows' % len(changes))
        for f, st in changes:
            print('  %s -> %s' % (f, st))
    if a.apply:
        problems, removed = L.apply(a.apply)
        print('applied; problems: %d' % len(problems))
        for x in problems:
            print('  PROBLEM', x)
        for t in removed:
            print('  REMOVE TEST (late edge):', t)
    if a.next_wave:
        number, slices, removed, out = L.next_wave(a.next_wave, a.limit, a.slice_size)
        for t in removed:
            print('  REMOVE TEST (late edge):', t)
        print('wave %02d: %d rows in %d slices -> %s' % (number, sum(map(len, slices)), len(slices),
                                                         out if slices else '(none)'))
    if a.check:
        counts, issues = L.check()
        print('statuses:', dict(counts))
        print('issues: %d' % len(issues))
        for x in issues[:50]:
            print('  ', x)
    if a.summary:
        L.reports()
        print('wrote quarantine.md and summary.md')


if __name__ == '__main__':
    main()
