# COBRA x OptArrow Proof Of Concept

This directory contains a minimal proof of concept for routing COBRA-style
`LPproblem` and `QPproblem` structs through OptArrow without using MATLAB's
native solver interfaces.

The current design deliberately keeps the integration thin:

- Convert a COBRA-style LP/QP struct into the OptArrow model schema.
- Call OptArrow's Python solver stack directly in-process.
- Map the result back into a COBRA-like solution struct.

This is a downstream adapter, not a patch to OptArrow itself. That keeps the
first proof small and avoids coupling COBRA to OptArrow's current MATLAB
client, which depends on MATLAB's Python bridge.

## Files

- `cobra_lp_adapter.py`: COBRA-style LP adapter for OptArrow.
- `cobra_lp_arrow_ipc.py`: Arrow IPC request/response helpers for the LP proof.
- `cobra_qp_adapter.py`: COBRA-style QP adapter for OptArrow.
- `run_optarrow_lp_poc.py`: Runnable end-to-end proof using a toy LP.
- `run_optarrow_lp_status_cases.py`: Runnable status sweep for optimal,
  infeasible, and unbounded LPs.
- `run_optarrow_lp_arrow_ipc_poc.py`: Runnable file-based Arrow IPC LP proof.
- `run_optarrow_qp_poc.py`: Runnable end-to-end proof using a toy QP.
- `solveCobraLPOptArrow.m`: Thin MATLAB wrapper for the LP CLI bridge.
- `solveCobraQPOptArrow.m`: Thin MATLAB wrapper for the QP CLI bridge.

## Todo

- [x] Define a minimal COBRA LP to OptArrow model mapping.
- [x] Implement a thin, non-MATLAB-specific adapter.
- [x] Validate the path on a toy LP with a real solver backend.
- [ ] Add COBRA-compatible dual and reduced-cost extraction.
- [x] Extend the adapter to `QP`.
- [x] Define an Arrow IPC contract for the LP proof.
- [ ] Add support for `MILP` and `MIQP` once OptArrow exposes them cleanly.
- [x] Prototype MATLAB wrappers that call the thin adapter instead of `py.*`.

## Running The Proof

Create and populate the local proof virtualenv from the repository root:

```bash
python3 -m venv .venv_optarrow_poc
.venv_optarrow_poc/bin/python -m pip install pyarrow pyomo highspy scipy
```

Then run:

```bash
.venv_optarrow_poc/bin/python src/base/solvers/optarrow/run_optarrow_lp_poc.py
.venv_optarrow_poc/bin/python src/base/solvers/optarrow/run_optarrow_lp_status_cases.py
.venv_optarrow_poc/bin/python src/base/solvers/optarrow/run_optarrow_lp_arrow_ipc_poc.py
.venv_optarrow_poc/bin/python src/base/solvers/optarrow/run_optarrow_qp_poc.py
```

The scripts print:

- the COBRA-style problem
- the raw OptArrow solver result
- the mapped COBRA-like solution struct

The status sweep additionally verifies normalized COBRA-style statuses for:

- optimal (`stat = 1`)
- infeasible (`stat = 0`)
- unbounded (`stat = 2`)

and asserts the expected optimal objective value for the toy LP.

## Current State

- LP uses a direct HiGHS contract path and returns primal values, duals,
  reduced costs, objective, and normalized statuses.
- LP now also has a file-based Arrow IPC proof so the solver boundary is not
  tied to JSON.
- QP uses the current OptArrow Pyomo solver path and confirms objective,
  primal values, and normalized statuses.
- The MATLAB wrappers are thin shims that keep COBRA-specific adaptation in
  the COBRA Toolbox rather than in OptArrow itself.
