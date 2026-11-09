#!/usr/bin/env python3
"""Measure coverage of many tests through matlab-safe, resumably.

usage: runCoverage.py <pairs file> <record prefix> [--workers 3] [--mem 6G] [--chunk 12] [--idle 1800]

Pairs are `<test path>|<source path>` lines. Tests that already have a record in
coverage-runs/*.jsonl are skipped unless --force is given. Each worker takes a chunk of
neighbouring tests (so tests sharing a folder never run at the same time) in a fresh MATLAB,
which also returns the memory that long sessions accumulate. When a MATLAB is killed, the test it
was running gets an `error` record naming the reason and the rest of the chunk goes back on the queue.
"""
import argparse
import glob
import json
import os
import shutil
import subprocess
import threading
import time

HERE = os.path.dirname(os.path.abspath(__file__))
FEATURE = os.path.dirname(HERE)
ROOT = os.path.dirname(os.path.dirname(FEATURE))
RUNS = os.path.join(FEATURE, 'coverage-runs')
SAFE = shutil.which('matlab-safe') or 'matlab-safe'


def recorded():
    done = set()
    for f in glob.glob(os.path.join(RUNS, '*.jsonl')):
        for line in open(f):
            if line.strip():
                done.add(json.loads(line)['test'])
    return done


def worker(k, queue, lock, args, logdir):
    out = os.path.join(RUNS, f'{args.prefix}-{k}.jsonl')
    n = 0
    while True:
        with lock:
            chunk = queue[:args.chunk]
            del queue[:args.chunk]
        if not chunk:
            return
        n += 1
        listfile = os.path.join(logdir, f'{args.prefix}-{k}-{n}.txt')
        logfile = os.path.join(logdir, f'{args.prefix}-{k}-{n}.log')
        open(listfile, 'w').write('\n'.join(chunk) + '\n')
        open(out, 'a').close()
        before = sum(1 for _ in open(out))
        code = ("initCobraToolbox(false); changeCobraSolver('gurobi','all',0); "
                f"addpath('{HERE}'); measureCoverage('{listfile}', '{out}')")
        with open(logfile, 'w') as log:
            rc = subprocess.run([SAFE, '--mem', args.mem, '--timeout', str(args.timeout), '--idle-file', out,
                                 '--idle-timeout', str(args.idle), '-batch', code],
                                cwd=os.path.join(ROOT, 'test'), stdout=log, stderr=subprocess.STDOUT).returncode
        finished = sum(1 for _ in open(out)) - before
        rest = chunk[finished:]
        print(f'worker {k} chunk {n}: {finished}/{len(chunk)} rc={rc} left={len(queue)}', flush=True)
        if rest:
            reason = next((l.strip() for l in open(logfile, errors='ignore') if 'MATLAB-SAFE-KILLED' in l),
                          f'MATLAB exited with status {rc}')
            test, source = rest[0].split('|')
            with open(out, 'a') as f:
                f.write(json.dumps(dict(test=test, source=source, status='error', seconds=None,
                                        message=reason, lines=[], hits=[])) + '\n')
            print(f'  KILLED {test}: {reason}', flush=True)
            with lock:
                queue[:0] = rest[1:]


def main():
    p = argparse.ArgumentParser()
    p.add_argument('pairs')
    p.add_argument('prefix')
    p.add_argument('--workers', type=int, default=3)
    p.add_argument('--mem', default='6G')
    p.add_argument('--chunk', type=int, default=12)
    p.add_argument('--idle', type=int, default=1800)
    p.add_argument('--timeout', type=int, default=14400)
    p.add_argument('--logs', default=os.path.join(RUNS, 'logs'))
    p.add_argument('--force', action='store_true')
    args = p.parse_args()
    os.makedirs(args.logs, exist_ok=True)
    pairs = [l.strip() for l in open(args.pairs) if l.strip()]
    done = set() if args.force else recorded()
    queue = sorted(l for l in pairs if l.split('|')[0] not in done)
    print(f'{len(queue)} tests to measure, {len(pairs) - len(queue)} already recorded', flush=True)
    lock = threading.Lock()
    threads = [threading.Thread(target=worker, args=(k, queue, lock, args, args.logs))
               for k in range(args.workers)]
    for i, t in enumerate(threads):
        t.start()
        time.sleep(30 if i + 1 < len(threads) else 0)
    for t in threads:
        t.join()
    print('ALL DONE', flush=True)


if __name__ == '__main__':
    main()
