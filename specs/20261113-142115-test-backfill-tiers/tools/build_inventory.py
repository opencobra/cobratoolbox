#!/usr/bin/env python3
"""Build the inventory and bottom-up order of untested src/ files.

usage: build_inventory.py <repo root> <feature dir>

Reads <feature dir>/inventory/callgraph-raw.tsv (from dumpCallGraph.m) and writes
<feature dir>/inventory/ledger.tsv, one row per untested file in campaign order, with the
initial status (PENDING or EXCLUDED), tier, reason, the untested callees and every caller.

Feature 20261113-142115-test-backfill-tiers (measurement tool; not part of the toolbox).
"""
import collections
import os
import re
import sys

ROOT, FEATURE = sys.argv[1], sys.argv[2]
SKIP_DIRS = {'old', 'deprecated', 'external'}

# names whose (transitive) use puts a function in Tier 3: they solve an optimisation problem
SOLVER_NAMES = {
    'solveCobraLP', 'solveCobraMILP', 'solveCobraQP', 'solveCobraMIQP', 'solveCobraNLP',
    'solveCobraEP', 'solveCobraCLP', 'solveCobraLPCPLEX', 'solveCobraCPLEX', 'optimizeCbModel',
    'gurobi', 'cplex', 'cplexlp', 'cplexmilp', 'cplexqp', 'glpk', 'mosekopt', 'linprog',
    'intlinprog', 'quadprog', 'pdco', 'Cplex', 'tomRun', 'qpng', 'lp_solve'}
# names whose use means the function loads a model or a data file shipped elsewhere: Tier 4/5
LOAD_NAMES = {'readCbModel', 'getDistributedModel', 'readSBML', 'TranslateSBML', 'loadPSCMfile',
              'readMinervaModel', 'loadIdentifiedModel'}
GUI_PATTERNS = [r'\bgui_mainfcn\b', r'\bguidata\s*\(', r'\buicontrol\s*\(', r'\buimenu\s*\(',
                r'\buifigure\s*\(', r'\bappdesigner\b']
INTERACTIVE_PATTERNS = [r'(?<![\w.])input\s*\(\s*[\'"]', r'\bkeyboard\b', r'\buigetfile\s*\(',
                        r'\buiputfile\s*\(', r'\binputdlg\s*\(', r'\bquestdlg\s*\(',
                        r'\bginput\s*\(', r'\bwaitforbuttonpress\b', r'\buigetdir\s*\(',
                        r'\blistdlg\s*\(']
INTERNET_PATTERNS = [r'\bwebread\s*\(', r'\burlread\s*\(', r'\bwebsave\s*\(', r'\bwebwrite\s*\(',
                     r'\burlwrite\s*\(', r'\bmatlab\.net\.http\b', r'\bweboptions\s*\(']
EXTERNAL_PATTERNS = [r'\bsystem\s*\(', r'\bunix\s*\(', r'\bdos\s*\(', r'^\s*!']


def code_of(path):
    """Text of a MATLAB file without comments and block comments (strings kept)."""
    text = open(path, errors='ignore').read()
    text = re.sub(r'^\s*%\{.*?^\s*%\}', '', text, flags=re.S | re.M)
    lines = []
    for line in text.splitlines():
        out, quote = [], False
        for i, ch in enumerate(line):
            if ch == "'" and (quote or i == 0 or not (line[i - 1].isalnum() or line[i - 1] in ")]}_.'")):
                quote = not quote
            if ch == '%' and not quote:
                break
            out.append(ch)
        lines.append(''.join(out))
    return '\n'.join(lines)


# ---- source files, types, local functions and calls
files, ftype, calls, parsefail = [], {}, collections.defaultdict(set), {}
for line in open(os.path.join(FEATURE, 'inventory', 'callgraph-raw.tsv')):
    a, b, c = (line.rstrip('\n').split('\t') + ['', ''])[:3]
    if a == 'FILE':
        files.append(b)
        ftype[b] = c
    elif a == 'PARSEFAIL':
        parsefail[b] = c
        files.append(b)
        ftype[b] = 'parsefail'
    elif a == 'LOCAL':
        pass
    else:
        calls[a].add(b)

by_name = collections.defaultdict(list)
for f in files:
    by_name[os.path.basename(f)[:-2]].append(f)

# ---- which files have a test: test<Name>.m, or a test naming the file under "Function under test"
tested_names, tested_paths = set(), set()
for dp, _, fs in os.walk(os.path.join(ROOT, 'test', 'verifiedTests')):
    for f in fs:
        if f.startswith('test') and f.endswith('.m'):
            tested_names.add(f[4:-2].lower())
            head = open(os.path.join(dp, f), errors='ignore').read(6000)
            for m in re.findall(r'src/[\w/.+-]+\.m', head):
                tested_paths.add(m)


def has_test(f):
    name = os.path.basename(f)[:-2]
    return f in tested_paths or name.lower() in tested_names


# ---- resolved call graph between src files, plus name references (handles, feval strings)
codes = {f: code_of(os.path.join(ROOT, f)) for f in files}
edges = collections.defaultdict(set)
for f in files:
    for name in calls.get(f, ()):
        for g in by_name.get(name, ()):
            if g != f:
                edges[f].add(g)
    for name in set(re.findall(r'@\s*([A-Za-z]\w*)', codes[f])) | set(
            re.findall(r'(?:feval|str2func)\s*\(\s*[\'"]([A-Za-z]\w*)[\'"]', codes[f])):
        for g in by_name.get(name, ()):
            if g != f:
                edges[f].add(g)
callers = collections.defaultdict(set)
for f, gs in edges.items():
    for g in gs:
        callers[g].add(f)


def reaches(f, names, memo):
    """True if f calls (transitively, through src files) one of the given names."""
    if f in memo:
        return memo[f]
    memo[f] = False
    hit = bool(calls.get(f, set()) & names)
    if not hit:
        hit = any(reaches(g, names, memo) for g in edges[f])
    memo[f] = hit
    return hit


solver_memo, load_memo = {}, {}


def tier_of(f):
    if reaches(f, LOAD_NAMES, load_memo):
        return '4'
    if reaches(f, SOLVER_NAMES, solver_memo):
        return '3'
    signature = re.search(r'^\s*function\b[^\n]*', codes[f], flags=re.M)
    if signature and re.search(r'\bmodel\w*\b', signature.group(0), flags=re.I):
        return '2'
    return '1'


def exclusion(f):
    code = codes[f]
    if ftype[f] == 'parsefail':
        return 'does not parse: ' + parsefail[f]
    if ftype[f] == 'script':
        return 'script (no function to call)'
    base = os.path.join(ROOT, f[:-2])
    if os.path.exists(base + '.fig') or any(re.search(p, code) for p in GUI_PATTERNS):
        return 'GUI'
    if any(re.search(p, code) for p in INTERACTIVE_PATTERNS):
        return 'interactive input'
    if any(re.search(p, code) for p in INTERNET_PATTERNS):
        return 'internet'
    return ''


def flags(f):
    code = codes[f]
    out = []
    if any(re.search(p, code, flags=re.M) for p in EXTERNAL_PATTERNS):
        out.append('external-program')
    if len(by_name[os.path.basename(f)[:-2]]) > 1:
        out.append('shadowed-name')
    return out


# ---- untested files, order: tier, then callees before callers (strongly connected components)
untested = [f for f in files if not has_test(f)]
U = set(untested)
tiers = {f: tier_of(f) for f in untested}

index, low, stack, onstack, comps, counter = {}, {}, [], set(), [], [0]
sys.setrecursionlimit(20000)


def strong(v):
    index[v] = low[v] = counter[0]
    counter[0] += 1
    stack.append(v)
    onstack.add(v)
    for w in edges[v] & U:
        if w not in index:
            strong(w)
            low[v] = min(low[v], low[w])
        elif w in onstack:
            low[v] = min(low[v], index[w])
    if low[v] == index[v]:
        comp = []
        while True:
            w = stack.pop()
            onstack.discard(w)
            comp.append(w)
            if w == v:
                break
        comps.append(sorted(comp))


for v in sorted(U):
    if v not in index:
        strong(v)
# Tarjan emits components callees-first. A component's tier is the highest tier in it and in
# every untested component it calls (effective tier, analysis F1): a caller is never taken in a
# lower tier than an untested callee, so callees always come first in the campaign order.
position = {}
for i, comp in enumerate(comps):
    for v in comp:
        position[v] = i
comp_tier = {}
for i, comp in enumerate(comps):
    callee_tiers = [comp_tier[position[w]] for v in comp for w in edges[v] & U if position[w] != i]
    comp_tier[i] = max([tiers[v] for v in comp] + callee_tiers)
for i, comp in enumerate(comps):
    for v in comp:
        tiers[v] = comp_tier[i]
order = sorted(untested, key=lambda v: (tiers[v], position[v], v))

with open(os.path.join(FEATURE, 'inventory', 'ledger.tsv'), 'w') as out:
    out.write('order\tfile\ttier\tstatus\treason\tflags\tcycle\tuntested_callees\tcallers\n')
    for k, f in enumerate(order, 1):
        reason = exclusion(f)
        comp = comps[position[f]]
        out.write('\t'.join([
            str(k), f, tiers[f], 'EXCLUDED' if reason else 'PENDING', reason, ','.join(flags(f)),
            ','.join(os.path.basename(c)[:-2] for c in comp) if len(comp) > 1 else '',
            ','.join(sorted(os.path.basename(g)[:-2] for g in edges[f] & U)),
            ','.join(sorted(os.path.basename(g)[:-2] for g in callers[f]))]) + '\n')

# ---- summary on stdout
print(f'src files: {len(files)}; with a test: {len(files) - len(untested)}; untested: {len(untested)}')
rows = [l.rstrip('\n').split('\t') for l in open(os.path.join(FEATURE, 'inventory', 'ledger.tsv'))][1:]
print('status x tier:', collections.Counter((r[3], r[2]) for r in rows))
print('exclusion reasons:', collections.Counter(r[4].split(':')[0] for r in rows if r[4]))
print('flags:', collections.Counter(x for r in rows for x in r[5].split(',') if x))
print('cycles (components > 1):', sum(1 for c in comps if len(c) > 1))
