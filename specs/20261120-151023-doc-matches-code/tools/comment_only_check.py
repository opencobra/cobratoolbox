#!/usr/bin/env python3
"""Check that every changed src/ MATLAB file differs from a base commit only in comment lines.

usage: comment_only_check.py [base-ref]   (default: the merge base with the parent branch, HEAD~0 index)

Files are compared as bytes, so a change of line endings (CRLF/LF) counts as a change.
A changed file passes when it has the same number of lines as at the base and every line that
differs is a full comment line (first non-blank character '%') in both versions. Block comments
and trailing comments after code count as code. Exit status 1 lists the offending files and lines.
"""
import subprocess
import sys

base = sys.argv[1] if len(sys.argv) > 1 else 'HEAD'
changed = subprocess.run(['git', 'diff', '--name-only', base, '--', 'src/'], capture_output=True,
                         text=True, check=True).stdout.split()
problems = []
for path in changed:
    if not path.endswith('.m'):
        problems.append(f'{path}: not a MATLAB file')
        continue
    try:
        old = subprocess.run(['git', 'show', f'{base}:{path}'], capture_output=True,
                             check=True).stdout.decode('utf-8', 'surrogateescape').split('\n')
    except subprocess.CalledProcessError:
        problems.append(f'{path}: new file')
        continue
    new = open(path, 'rb').read().decode('utf-8', 'surrogateescape').split('\n')
    if len(old) != len(new):
        problems.append(f'{path}: line count {len(old)} -> {len(new)}')
        continue
    for n, (a, b) in enumerate(zip(old, new), 1):
        if a != b:
            isComment = lambda s: s.lstrip().startswith('%') and not s.lstrip().startswith('%{') \
                and not s.lstrip().startswith('%}')
            if not (isComment(a) and isComment(b)):
                problems.append(f'{path}:{n}: a non-comment line changed')
print(f'{len(changed)} changed src file(s); {len(problems)} problem(s)')
for p in problems:
    print('  ' + p)
sys.exit(1 if problems else 0)
