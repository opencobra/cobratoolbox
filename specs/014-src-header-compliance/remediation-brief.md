# Remediation brief — feature 014-src-header-compliance (per-folder header remediation)

You are a `matlab-developer` agent remediating openCOBRA function-header comments so the
CI Sphinx documentation build generates correct pages. This is approved, gated,
**documentation-only, behaviour-preserving** work. You are given a list of `src/` folders
to remediate. Edit **only** the `.m` files directly in those folders (non-recursive
unless a subfolder is explicitly in your list).

## Read first (authoritative)

- `specs/014-src-header-compliance/contracts/header-rules.md` — the rule catalog
  (H-EMPTY … H-AUTHOR) you must satisfy, with severities and pass/fail examples.
- `specs/014-src-header-compliance/research.md` — R4 (exactly how to interrogate the body
  for inputs, name-value params, and used struct fields) and R5 (behaviour check).
- `documentation/source/guides/documentationGuide.rst` — the canonical generator format.
- Field meanings: `documentation/source/guides/COBRAModelFields.rst` for COBRA model
  fields; `src/base/solvers/solveCobraLP.m` and `src/analysis/FBA/optimizeCbModel.m` for
  LP/QP problem and solution struct fields (`.A`, `.b`, `.c`, `.lb`, `.ub`, `.osense`,
  `.csense`, `.stat`, `.origStat`, `.full`, `.obj`, `.rcost`, `.dual`).

## Your oracle (already built — use it)

```matlab
addpath('test/verifiedTests/documentation');
r = checkHeaderCompliance('<folder>', 0);   % r.violations = {file, ruleId, line, detail, severity}
% or per file:  v = checkFunctionHeaders('<file>');
```
Goal: **0 error-severity violations** for every file in every folder you are assigned.

## What to do for each .m file

1. Read the whole file; understand the primary function — its declared inputs/outputs,
   which name-value/`varargin` parameters the body actually reads, and which struct
   arguments it reads fields of (inputs) or writes fields of (outputs).
2. Rewrite **only the header comment block** (between the `function` line and the first
   executable line) to satisfy the catalog:
   - a brief description line; a `USAGE:` block containing the real call signature;
   - `INPUTS:`/`OPTIONAL INPUTS:` line for every consumed input (colon after the name,
     ≥4 spaces before the description);
   - `OUTPUTS:` line for every declared output;
   - for every struct argument, a `* .field - description` sub-bullet for **each field the
     function uses** (reads for inputs, writes for outputs) — **only used fields**, never
     the whole schema;
   - formatting: exactly one space after `%`, 4-space body/arg indentation, canonical
     signature spacing (space after commas, around `=`), `% ..`-prefixed `Author` lines,
     one blank comment line before the body.
3. Take standard field meanings from the references above; otherwise infer conservatively
   from the code. **Never fabricate** a meaning the code does not support. **Never invent**
   a name-value parameter the code never reads. **Never document** an unused struct field
   (drop it if a stale header lists one).

## Hard constraints (non-negotiable)

- **Behaviour-preserving**: change ONLY comment text and, where H-SIG requires it,
  function-signature whitespace. NEVER change an executable line, function/argument name,
  argument order, or algorithm. If clearing a checker finding would require an executable
  change (e.g. a comment-only typo like `model.rxn` for `model.rxns`), fix the comment,
  not the code; if a signature uses space-separated outputs `[a b c]`, do NOT add commas
  (that is an executable change) — document them on one keyword line instead.
- **Verify before you finish**, using your MATLAB MCP tools:
  1. `checkHeaderCompliance('<folder>', 0)` → 0 error-severity violations for each folder.
  2. Comments-only: for each edited file, the non-comment/non-blank lines with whitespace
     removed must be byte-identical to `git show HEAD:<file>`.
  3. `check_matlab_code` on each edited file introduces no new issues (compare to HEAD).
- Do NOT touch excluded-vendored files (the checker classifies and skips them). Do NOT
  edit files outside your assigned folders. Do NOT run `initCobraToolbox` (not needed).
- **NEVER run git commands that modify the working tree, index, or refs** — no
  `git stash`, `git checkout -- …`, `git reset`, `git restore`, `git add`, `git commit`,
  `git clean`. Other agents are editing other folders in parallel; a stash/reset can
  clobber their in-flight edits. Read-only git is fine (`git show HEAD:<file>`,
  `git diff <file>`, `git status`). Edit files only through the file-editing tools.

## Report back (data for the orchestrator)

Per folder: files edited, before→after error-severity count (must end at 0), and
confirmation the comments-only check passed. Flag any file you could not bring to 0 and
why, and any struct field whose meaning you could not determine from the code.
