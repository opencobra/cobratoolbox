"""Minimal COBRA-style QP adapter for OptArrow."""

from __future__ import annotations

from pathlib import Path
import os
import sys
import time
from typing import Any

import numpy as np
from scipy import sparse


def _default_optarrow_src() -> Path:
    repo_root = Path(__file__).resolve().parents[4]
    return repo_root.parent / "optArrow_mat" / "src"


def _ensure_optarrow_importable(optarrow_src: str | Path | None = None) -> Path:
    src = Path(optarrow_src or os.environ.get("OPTARROW_SRC") or _default_optarrow_src())
    if not src.exists():
        raise FileNotFoundError(
            f"OptArrow source path not found: {src}. "
            "Set OPTARROW_SRC or pass optarrow_src explicitly."
        )
    src_str = str(src)
    if src_str not in sys.path:
        sys.path.insert(0, src_str)
    return src


def _as_1d_float_array(value: Any, *, default: float | None = None, length: int | None = None) -> list[float]:
    if value is None:
        if default is None or length is None:
            raise ValueError("A required vector was not provided.")
        return [float(default)] * length
    arr = np.asarray(value, dtype=float).reshape(-1)
    if length is not None and arr.shape[0] != length:
        raise ValueError(f"Expected vector of length {length}, got {arr.shape[0]}.")
    return arr.astype(float).tolist()


def _coo_triplet(matrix: Any) -> tuple[list[int], list[int], list[float], tuple[int, int]]:
    if isinstance(matrix, dict) and all(key in matrix for key in ("row", "col", "val")):
        row = [int(x) for x in matrix["row"]]
        col = [int(x) for x in matrix["col"]]
        val = [float(x) for x in matrix["val"]]
        n_rows = (max(row) + 1) if row else 0
        n_cols = (max(col) + 1) if col else 0
        if "shape" in matrix and matrix["shape"] is not None:
            n_rows, n_cols = (int(matrix["shape"][0]), int(matrix["shape"][1]))
        return row, col, val, (n_rows, n_cols)
    if sparse.issparse(matrix):
        coo = matrix.tocoo()
    else:
        arr = np.asarray(matrix, dtype=float)
        if arr.ndim != 2:
            raise ValueError("Expected a 2-D matrix.")
        coo = sparse.coo_matrix(arr)
    return (
        coo.row.astype(int).tolist(),
        coo.col.astype(int).tolist(),
        coo.data.astype(float).tolist(),
        tuple(int(x) for x in coo.shape),
    )


def _normalize_osense(value: Any) -> str:
    if value is None:
        return "min"
    if isinstance(value, str):
        return "max" if value.strip().lower() == "max" else "min"
    if float(value) == -1:
        return "max"
    return "min"


def _normalize_csense(value: Any, n_rows: int) -> list[str]:
    if value is None:
        return ["E"] * n_rows
    if isinstance(value, str):
        items = list(value) if len(value) == n_rows else [value]
    else:
        arr = np.asarray(value).reshape(-1)
        items = [str(x) for x in arr.tolist()]
    if len(items) != n_rows:
        raise ValueError(f"Expected {n_rows} constraint senses, got {len(items)}.")
    return [item.strip().upper()[0] for item in items]


def _subset_triplet(row: list[int], col: list[int], val: list[float], keep_rows: set[int]) -> tuple[list[int], list[int], list[float]]:
    out_row = []
    out_col = []
    out_val = []
    row_map = {r: idx for idx, r in enumerate(sorted(keep_rows))}
    for r, c, v in zip(row, col, val):
        if r in keep_rows:
            out_row.append(row_map[r])
            out_col.append(c)
            out_val.append(v)
    return out_row, out_col, out_val


def cobra_qp_problem_to_optarrow_model(qp_problem: dict[str, Any]) -> dict[str, Any]:
    if "F" not in qp_problem or "c" not in qp_problem:
        raise ValueError("QPproblem must include F and c.")

    q_row, q_col, q_val, q_shape = _coo_triplet(qp_problem["F"])
    n_vars = max(q_shape[0], q_shape[1], int(np.asarray(qp_problem["c"]).reshape(-1).shape[0]))

    model = {
        "Q": {"row": q_row, "col": q_col, "val": q_val, "shape": [n_vars, n_vars]},
        "c": _as_1d_float_array(qp_problem["c"], length=n_vars),
        "lb": _as_1d_float_array(qp_problem.get("lb"), default=0.0, length=n_vars),
        "ub": _as_1d_float_array(qp_problem.get("ub"), default=1.0e6, length=n_vars),
        "osense": _normalize_osense(qp_problem.get("osense")),
    }

    if "A" in qp_problem and qp_problem["A"] is not None:
        a_row, a_col, a_val, a_shape = _coo_triplet(qp_problem["A"])
        n_rows = max(a_shape[0], int(np.asarray(qp_problem.get("b", [])).reshape(-1).shape[0]))
        csense = _normalize_csense(qp_problem.get("csense"), n_rows)
        rhs = _as_1d_float_array(qp_problem.get("b", []), length=n_rows)

        eq_rows = {idx for idx, sense in enumerate(csense) if sense == "E"}
        le_rows = {idx for idx, sense in enumerate(csense) if sense == "L"}
        ge_rows = {idx for idx, sense in enumerate(csense) if sense == "G"}

        if eq_rows:
            row, col, val = _subset_triplet(a_row, a_col, a_val, eq_rows)
            model["A"] = {"row": row, "col": col, "val": val, "shape": [len(eq_rows), n_vars]}
            model["b"] = [rhs[idx] for idx in sorted(eq_rows)]

        ineq_rows = set()
        if le_rows:
            ineq_rows |= le_rows
        if ge_rows:
            ineq_rows |= ge_rows
        if ineq_rows:
            row, col, val = _subset_triplet(a_row, a_col, a_val, ineq_rows)
            # Flip >= rows so everything becomes Gx <= h.
            mapped_rows = sorted(ineq_rows)
            row_sign = {r: (-1.0 if r in ge_rows else 1.0) for r in mapped_rows}
            row_back_map = {new_idx: old_idx for new_idx, old_idx in enumerate(mapped_rows)}
            val = [v * row_sign[row_back_map[r]] for r, v in zip(row, val)]
            h = []
            for old_idx in mapped_rows:
                h.append(-rhs[old_idx] if old_idx in ge_rows else rhs[old_idx])
            model["G"] = {"row": row, "col": col, "val": val, "shape": [len(mapped_rows), n_vars]}
            model["h"] = h

    return model


def _map_status(status: str | None) -> int:
    normalized = (status or "").strip().lower()
    if normalized in {"optimal", "locallyoptimal"}:
        return 1
    if normalized in {"infeasible"}:
        return 0
    if normalized in {"unbounded"}:
        return 2
    return -1


def solve_cobra_qp_via_optarrow(
    qp_problem: dict[str, Any],
    *,
    solver_name: str = "HiGHS",
    solver_params: dict[str, Any] | None = None,
    optarrow_src: str | Path | None = None,
) -> tuple[dict[str, Any], dict[str, Any], dict[str, Any]]:
    _ensure_optarrow_importable(optarrow_src)
    from service.optimization_service.python.pyomo.service.opt_solver import PyomoSolver

    model = cobra_qp_problem_to_optarrow_model(qp_problem)
    request = dict(model)
    request["solver"] = {
        "solver_name": solver_name,
        "solver_type": "QP",
        "solver_params": solver_params or {},
    }

    started = time.perf_counter()
    raw_result = PyomoSolver().run(request)
    elapsed = time.perf_counter() - started

    solution = {
        "full": list(raw_result.get("solution") or []),
        "stat": _map_status(raw_result.get("status")),
        "origStat": raw_result.get("status", ""),
        "origStatText": raw_result.get("status", ""),
        "solver": f"optarrow:{solver_name}",
        "qpmethod": "optarrow-direct",
        "time": elapsed,
        "dual": list(raw_result.get("dual") or []),
        "rcost": list(raw_result.get("rcost") or []),
        "slack": [],
    }
    return model, raw_result, solution
