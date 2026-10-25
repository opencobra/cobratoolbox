# Implementation Receipt: known-defects registry (III-Defects)

## Prompt

User: "Yes go all the way from specifying to implementing" (known-defects registry generated from test headers; location test/known-defects.md; not hand written; added to the constitution as III-Defects). Work stays on develop; no personal information in the repository files.

## Final response

Implemented Constitution III-Defects. A Python tool (.github/scripts/known_defects.py, standard library only) reads the standard defect entries from test headers and generates test/known-defects.md (29 defects in 23 functions); its --check mode fails when the registry is stale and runs as a new CI step without MATLAB. The headers of the 55 pilot and batch-2 tests were rewritten in the standard format by comment-only edits: all 55 tests still pass, no code line changed, no src file changed. The tool has 29 automated unit tests. Regeneration is byte-identical from any working directory and takes about 0.06 s.

## Diff summary

New: .github/scripts/known_defects.py, .github/scripts/test_known_defects.py, test/known-defects.md (generated), the feature folder under specs/ (spec, plan, research, data-model, quickstart, contracts/defect-entry-format.md, tasks, checklist, this receipt).
Edited: .github/scripts/README.md (new section), .github/workflows/testAllCI_step1.yml (one step), CLAUDE.md (plan pointer), and the headers (comment lines only) of 26 of the 55 pilot and batch-2 test files.
git diff --stat -- src: empty. Non-comment lines of the 55 tests: identical to before.

## Tests

- Tool unit tests: python3 -m unittest discover -s .github/scripts -p "test_known_defects.py": 29 tests, all pass.
- known_defects.py --check on the clean tree: exit 0 (29 defects).
- Failure modes demonstrated: hand-edited registry -> exit 1; header entry changed without regenerating -> exit 1; invalid severity -> exit 2 with file:line message and the registry untouched.
- Determinism: output byte-identical when generated from different working directories.
- The 55 MATLAB tests through runScriptFile: 55 passed, 0 failed, no failing % sections.

## Unresolved issues

- The CI step was added but has not run in GitHub Actions yet; it is verified locally only.
- Only the 55 tests of features 025 and 026 are in the new format; older tests have no entries (they are ignored by the tool).
- The registry lists 29 defects found so far; further back-fill batches will add more by editing headers and regenerating.

## Other information

The pilot re-read found one defect not recorded before (getMetAbbr silently drops IDs without brackets); two further entries (compareConditions limitation, cleanUpMetabolite_structure console output) came from existing header notes. Coverage exemptions that are not defects (hyperlink, removeSmilesInchiKey) are not entries.
