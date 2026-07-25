# Implementation Receipt

**Feature**: 014-src-header-compliance
**Run (UTC)**: 20260717T235748Z (per-folder header remediation + closeout; resumed a
previously-started run that had completed the checker/CI-gate and the base, design, and
visualization domains)
**Scope**: COMPLETE — all six in-scope `src/` domains remediated to zero error-severity
header violations; the standing CI gate passes; behaviour preservation and the Sphinx
secondary oracle both verified. Tasks T001–T253 are checked.

## Prompt

Resume the feature-014 header remediation (agent-assign implementation pipeline; same
gate). At resume, the checker/CI-gate (US1) and the base, design, and visualization
domains were already committed; the reconstruction domain sat as uncommitted, unverified
edits. Directive during the run: drive remaining domains via `matlab-developer` agents,
scaled to ~20 concurrent.

## Final response

All `src/` in-scope function headers are openCOBRA-documentation-guide compliant.

Delivered and verified (MATLAB MCP, R2026a; sphinxcontrib-matlabdomain 0.18.0):

- **Full gate (T249)** — `checkHeaderCompliance('src')` / `testHeaderCompliance`:
  **1498 in-scope files (80 vendored-excluded), 0 error-severity violations.** The
  standing gate test passes headless (1/1) and is discovered by `test/testAll.m`'s
  recursive `verifiedTests/` scan.
- **Per domain (before → after error-severity):** analysis 1986→0, base 526→0,
  dataIntegration 1132→0, design 151→0, reconstruction 900→0, visualization 401→0.
  Total **5096 → 0** across 1270 files. Residual warnings (H-BODYGAP / H-AUTHOR,
  non-blocking) 298 → 142. Recorded in `reports/post-remediation.md` (T252, SC-006).
- **Behaviour preservation (T250)** — `checkCommentsOnly.sh develop HEAD`: **1266
  changed `src/*.m` files, all comments/whitespace-only.** The verifier was made
  line-continuation-aware so a behaviour-preserving multi-line-signature reflow (H-SIG)
  is not misreported as an executable change; validated it still catches real token
  add/remove/reorder. One file (`analysis/persephone/runSeqC.m`) needed such a reflow —
  its original `runSeqC( ... )` layout itself tripped H-SIG; the rewrite is
  token-identical to HEAD once continuations are joined.
- **Sphinx secondary oracle (T251, SC-004)** — a minimal build with the exact target
  extension over a cross-domain sample of remediated functions: build succeeds, pages
  generate, matlabdomain signature parsing clean for every audited function. Before→after
  diagnostics went 7→5 "Unexpected indentation" and 2→2 matlabdomain warnings; the 2 are
  pre-existing filename/function-name mismatches (`addMultipleReactions`,
  `persWBMetabolomics`) that comment-only work cannot change. **No header-format or
  signature-parse error is attributable to the remediation.**

Behaviour-preserving throughout: only comment text and (where H-SIG required) function-
signature whitespace changed. Struct fields were documented only where the body uses them;
stale/unused documented fields were dropped; checker false-positives from string literals
(e.g. `model.met` inside a `disp`, `sampleFile.mat`, `inchi.inchi`) were documented
truthfully, never fabricated as struct fields. Numerous latent code bugs surfaced during
the audit (filename/function-name mismatches, undefined-variable typos, unused declared
args) were left untouched per the documentation-only scope and flagged in agent reports.

One operational note: an early agent ran `git show` inside MATLAB (`system(...)`), whose
pager blocked the shared MCP MATLAB session; fixed by setting `core.pager cat` globally and
adding a "don't let git page inside MATLAB" instruction to later agents.

`test/testAll.m` was NOT run in full (it requires the whole solver stack + initCobraToolbox
and is out of scope for this documentation-only feature); the new gate it discovers was run
directly and passes.

## Diff summary

- M ~1266 `src/**/*.m` — header comments rewritten to the documentation-guide format;
  executable lines unchanged (behaviour-preserving), committed per domain:
  - `8bf8c4432` reconstruction (23 folders, 220 files)
  - `b52130729` dataIntegration (39 folders, 216 files)
  - `fa094d826` analysis (117 folders, 507 files)
  - (base / design / visualization committed earlier in the run)
- M `test/verifiedTests/documentation/checkCommentsOnly.sh` — join `...` line
  continuations before comparing (correctness fix; still catches real token changes).
- A `specs/014-src-header-compliance/reports/post-remediation.md` (SC-006 before/after).
- A `specs/014-src-header-compliance/agent-runs/20260717T235748Z-src-header-compliance/implementation-receipt.md` (this file).
- M `specs/014-src-header-compliance/tasks.md` — T001–T253 checked.
- UNCHANGED: every executable line of every audited `.m` file; vendored subtrees
  (`rBioNet/`, `modelBorgifier/`) and the licence-guarded `py_addpath.m` (excluded).
