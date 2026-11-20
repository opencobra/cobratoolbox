# Brief: cosmetic entries, help text to match the code

You work in the COBRA Toolbox repository at the repository root (the current git branch is
`20261120-151023-doc-matches-code`). The maintainer asked: where help text or a comment contradicts
what the code does, change the TEXT so it describes the code. Never change the code.

## Your input

- A slice file `specs/20261120-151023-doc-matches-code/inventory/cosmetic-slice-N.txt`, which lists
  test files (one per line).
- `specs/20261120-151023-doc-matches-code/inventory/cosmetic.json`, which holds every cosmetic entry
  (`source`, `title`, `test`). Work only on the entries whose `test` is in your slice.
- Each entry is written out in full in the "Known defects documented" section of its test file's
  header (DEFECT / SEVERITY: cosmetic / TRIGGER / OBSERVED / EXPECTED / LINES). Read that entry and
  the source lines it names, and enough of the surrounding source to know what the code does.

## Classify each cosmetic entry

- **A, text fix:** a help text or comment line (a line whose first non-blank character is `%`)
  says something the code does not do, and the code's behaviour looks deliberate. Examples: a wrong
  default, a wrong output name or size, an input documented as optional that is required, a wrong
  file name, a misspelled field name in the help. Fix the TEXT.
- **B, out of scope:** the entry is about an error or warning message string, printed or displayed
  output, a figure, missing input validation, a leftover file, or any other behaviour. Leave it
  untouched.
- **C, the code is the slip:** the help or comment states the evident intent and the code is a
  mistake (a typo in a variable or field name, a wrong index, a value contradicted by the
  surrounding code). Documenting it would write a bug down as behaviour. Leave it untouched and say
  why.

When in doubt between A and C, choose C.

## How to fix an A entry

1. Edit only full comment lines of the source file (the first non-blank character is `%`). Do not
   touch code lines, string literals, trailing comments after code, or `%{ ... %}` blocks.
2. Keep the file's number of lines exactly the same: reword within the existing comment lines
   (a line may become longer). Do not add or delete lines. Other tests, coverage exemptions and
   records refer to line numbers.
3. Write the corrected text in the style of the surrounding help (openCOBRA headers: USAGE,
   INPUTS, OUTPUTS, ...). State what the code does, plainly and precisely, without mentioning that it
   used to be wrong.
4. In the test file's header, delete that entry (its DEFECT line and all its continuation lines)
   from "Known defects documented (NOT tested, NOT fixed here):". If no entry is left, the section
   body becomes the single line `%     None found.`
5. In the test file's Authors section, add one line after the last author line:
   `%     - Help text of <functionName> corrected to match the code (feature 20261120-151023-doc-matches-code), 2026-11-20.`
   Add it once per test file, even when you fix several entries there.
6. If the test's "Coverage exemptions" mention the entry or its lines, do not change them; report
   it.

Check your source edits with
`python3 specs/20261120-151023-doc-matches-code/tools/comment_only_check.py HEAD`. It lists every
changed `src/` file, including other helpers' files, so look only at yours. Every one of your files
must show no problem.

## Do not

- Do not run MATLAB. Not needed.
- Do not run git commands that change anything (no add, commit, checkout, stash, reset, restore).
- Do not edit files outside your slice's tests and their source files, and do not edit
  `test/known-defects.md`; the lead regenerates it.
- Do not write machine paths, user names, e-mail addresses or licence details into any file. The
  repository is public.

## Output

Write `specs/20261120-151023-doc-matches-code/inventory/results/cosmetic-slice-N.jsonl`, with one
JSON object per line for every cosmetic entry of your slice:

```json
{"source": "src/...m", "test": "test/...m", "title": "<entry title>", "class": "A|B|C",
 "reason": "<one or two sentences: what the text said, what the code does, why A/B/C>",
 "lines": [<source line numbers you changed, empty for B/C>], "note": "<exemptions or anything the lead must check, else empty>"}
```

Your final message: the counts of A, B and C, and the list of notes.
