# Contract: lrsSpecifyRows (unchanged interface)

`[status, result] = lrsSpecifyRows(fileNameIn)`: `fileNameIn` is a name relative to the current
folder (no file separator) or a path. On success the file's `*****` placeholders hold the number of
data rows and `status = 0`, `result = ''`.

Errors: 'Could not open lrs output file.' (file cannot be opened for reading and writing; before:
an undefined-variable error), 'Could not read lrs output file.' (no `end` after `begin`; unchanged).
The error 'sed failed on file <name>' no longer exists. Requirements: none (before: GNU sed on
Unix).
