# Research: bottom-up test back-fill with defect quarantine

All values measured on 2026-11-13 on branch `20261113-142115-test-backfill-tiers` (upstream/develop
5200aad48), MATLAB R2025a, with `tools/dumpCallGraph.m` and `tools/build_inventory.py`.

## R1 — Inventory and initial classification

**Decision**: `tools/dumpCallGraph.m` (getcallinfo over every `src/` file outside `old/`,
`deprecated/`, `external/`) gives file type, local functions and called names;
`tools/build_inventory.py` maps tests to files (as the spec defines "untested"), classifies and
orders the untested files, and writes `inventory/ledger.tsv`.

Measured: 1642 files (1551 functions, 70 scripts, 20 classes, 1 parse failure); 557 with a test,
**1085 untested**:

(Tiers in this table are before the effective-tier rule of R4, which moves 20 rows from Tier 1 to
Tier 2.)

| Initial status | Tier 1 | Tier 2 | Tier 3 | Tier 4/5 | Total |
|---|---|---|---|---|---|
| PENDING | 391 | 226 | 274 | 39 | 930 |
| EXCLUDED | 118 | 12 | 15 | 10 | 155 |

Exclusions: script 70, internet 38, interactive input 24, GUI 22, parse failure 1
(`src/visualization/cellDesigner/intergrate.m`). Flags (not exclusions): calls an external program
62 (`system`/`unix`/`dos`/`!`; decided per function: excluded only if every line needs the
program), shadowed name 8 (the file MATLAB resolves first is tested; the others are EXCLUDED as
shadowed when the test is written).

**Rationale**: static signals are cheap and reproducible; the person writing a test sees the code
and corrects the classification (reclassification is recorded in the ledger with the reason).

**Alternatives**: classify by hand (1085 files, not reproducible); classify by running each function
(needs inputs, which is the work itself).

## R2 — Tiers

**Decision**: initial tier = Tier 4/5 if the file reaches a model-loading function
(`readCbModel`, `getDistributedModel`, `readSBML`, `TranslateSBML`, `loadPSCMfile`, ...) through
`src/` calls; else Tier 3 if it reaches a solver (`solveCobra*`, `optimizeCbModel`, `gurobi`,
`cplex`, `glpk`, `linprog`, `pdco`, ...); else Tier 2 if its signature takes a model; else Tier 1.
Files in a call cycle share the highest tier of the cycle. The test writer sets the final tier from
III-Coverage (what the test actually needs) and records changes. A reclassification never moves a
function before a PENDING callee: the order is re-derived from the graph (R4) whenever a tier
changes.

**Rationale**: matches the maintainer's order (Tier 1 → 2 → 3 → 4/5) and the constitution's tier
meanings; transitive reachability is what makes a function need a solver or a model.

**Alternatives**: direct calls only (misses wrappers: a function calling `optimizeCbModel` through a
helper would be put in Tier 1).

## R3 — Call graph and dynamic calls

**Decision**: edges = getcallinfo calls resolved to `src/` files by name, plus name references in
code without comments: `@name` handles and `feval('name')`/`str2func('name')` strings. Names that
match no `src/` file (MATLAB, external, toolboxes) are not nodes. A dependency discovered only while
running a test (e.g. a name built at run time) is added to `inventory/extra-edges.tsv` and the
graph re-derived. 4 cycles (strongly connected components) exist among untested files (e.g.
`AndNode`/`OrNode`, `removeRxns`/`removeMetabolites`, the rBioNet `ReconstructionTool` trio);
each cycle is taken as one unit.

**Rationale**: the static graph is what decides blocking; text references catch the common dynamic
patterns in this code base without running it.

**Alternatives**: runtime tracing with the profiler (needs every function to run first; circular).

## R4 — Order

**Decision**: each call-graph component gets an effective tier = the highest tier in it and in
every untested component it calls (16 caller→callee pairs crossed tiers upward before this rule,
e.g. `GPR2models` (Tier 1) → `createModel` (Tier 2)); order = effective tier, then Tarjan's
component order (callees before callers), then path. Result: Tier 1 371, Tier 2 246, Tier 3 274,
Tier 4/5 39 PENDING.
A function's test is written only when every untested function it calls is no longer PENDING. The
work proceeds in **waves**: a wave is the set of PENDING functions (lowest tier first) whose
untested callees are all TESTED (or EXCLUDED for a reason other than a defect). After each wave the
ledger is updated and blocking propagated (R6) before the next wave is formed.

**Rationale**: waves give parallelism (functions in one wave do not call each other) while keeping
the bottom-up guarantee the quarantine needs.

## R5 — What counts as a defect; severity

**Decision**: a defect is behaviour that contradicts the function's documentation (header, USAGE,
INPUTS/OUTPUTS), an independent derivation (hand calculation, mathematical property, reference
from the literature) or MATLAB semantics the code evidently intends — found with an input the
documentation allows. Severities as III-Defects. Per FR-007 (clarified): `wrong-result`, `error`,
`unusable-option` quarantine; `cosmetic`, `limitation` use the input-level rule. Inputs the
documentation does not allow are not defects (they are not tested, or tested as documented errors).
A test writer who suspects a defect records the evidence (input, observed, expected, source lines);
every quarantine is checked by a second reader (R9) before callers are blocked.

**Rationale**: blocking can affect hundreds of callers, so a false defect is costly; the second
reading keeps quarantines evidence-based.

## R6 — Quarantine propagation

**Decision**: when f is QUARANTINED: every PENDING file that reaches f through the graph becomes
BLOCKED with `blocked_by = f` (several blockers listed if several apply). Files already TESTED in an
earlier wave cannot call f (they were tested after f and their other callees by construction, R4),
except through edges discovered later (R3). For such a file the constitution's quarantine clause
applies unchanged: its new test is removed and it becomes BLOCKED by f, and so does every TESTED
file that calls it (analysis C1). Functions outside the 1085
(already tested) are never BLOCKED; FR-012 handles defects found in them.

## R7 — Execution: writers, MATLAB sessions, memory

**Decision**: tests are written by helper agents in parallel, each given one wave slice of up to 10
functions, the constitution sections (III, VII), the ledger rows, and the test template contract
(`contracts/`). Each agent runs its tests through `~/.local/bin/matlab-safe` (at most 3 MATLAB
sessions machine-wide, memory-capped; the machine's desktop was killed by memory pressure on
2026-11-04), measures coverage with `tools/measureCoverage.m`, and returns one result record per
function (`contracts/agent-result.md`). The lead integrates: checks each record, updates the
ledger, propagates blocking, runs the wave's tests together once more, regenerates the defect
registry and commits the wave. At most 3 agents run at a time (one MATLAB slot each).

**Rationale**: ~930 tests cannot be written serially in one context; one MATLAB slot per agent
respects the memory guard.

**Alternatives**: one agent for everything (context exhaustion); more than 3 parallel agents (they
would queue on MATLAB slots anyway).

## R8 — Test location, models, fixtures

**Decision**: `test/verifiedTests/<area>/test<Area>/test<Name>.m` following the existing folders
(`src/analysis/topology/...` → `test/verifiedTests/analysis/testTopology/`); a new subfolder only
when no existing one matches the source area. Tier 1/2 inputs are hand-built, or a small
model built with `createModel` (`src/reconstruction/refinement/createModel.m`, used by 40 tests) or
the toy-model builders in the test folders (`createToyModel`, `createToyModelForgapFind`, ...), or
`ecoli_core_model`; Tier 3 uses the smallest model reaching the code; models via `getDistributedModel`. The local
`test/models` checkout is at 11da48e while the branch records 75c070d01, and
`Recon3DModel_301_xomics_input.mat` is an HTML page from a failed download: the checkout is synced
to the recorded commit before Tier 4 work (local only; the submodule pointer is never committed).

## R9 — Review

**Decision**: every quarantine is checked by a second reader before propagation (R5). At the end
an independent review (Codex if the ChatGPT account accepts a model, otherwise reviewer agents that
receive only the code and the tests) samples the TESTED tests (at least one per source area and
every Tier 5 reference) and reads every QUARANTINED entry; findings and resolutions go to
`review.md`.

## R10 — Coverage before and after

**Decision**: SC-006 reports executable-line coverage over all 1642 files: covered lines of each
file by its own test. Before: existing tests from the final runs of feature
20261104-115314-test-coverage-100 (`coverage-runs/zz-final-*.jsonl`) plus 0 for the 1085 untested
files, whose executable-line counts are taken by one coverage run with an empty test
(`tools/measureCoverage.m` on a no-op script). After: the same plus the new tests' records.

## R11 — Commits and delivery

**Decision**: one commit per wave (tests, ledger, registry), as the maintainer, no co-author line;
submodule pointers never staged; privacy scan before each commit (no machine paths, keys,
licences, private names). The branch is pushed only when the maintainer asks; one PR at the end.
