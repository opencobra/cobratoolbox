# Data model: lrsSpecifyRows without sed

| Item | Before | After |
|---|---|---|
| lrs file (`.ine`/`.ext`) | edited in place by `sed -i` | read and rewritten by MATLAB; same bytes except each `*****` |
| row count | lines from the count line to `end`, minus the count line | same rule |
| `[status, result]` | sed's exit status and output | `0`, `''` |
| file identifier | left open | closed before return or error |
