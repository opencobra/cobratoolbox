"""Minimal COBRA-style LP adapter for OptArrow.

This module is intentionally small and downstream-facing. It does not try to
replace COBRA's solver stack yet; it only proves that a COBRA-style LP problem
can be translated into OptArrow's schema and solved outside MATLAB's solver
interfaces.
"""

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
    normalized = [item.strip().upper()[0] for item in items]
    allowed = {"L", "E", "G", "<", "=", ">"}
    if any(item not in allowed for item in normalized):
        raise ValueError(f"Unsupported constraint senses: {normalized}")
    return normalized


def _normalize_osense(value: Any) -> str:
    if value is None:
        return "max"
    if isinstance(value, str):
        return "max" if value.strip().lower() == "max" else "min"
    if float(value) == -1:
        return "max"
    return "min"


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
            raise ValueError("LPproblem.A must be a 2-D matrix.")
        coo = sparse.coo_matrix(arr)
    return (
        coo.row.astype(int).tolist(),
        coo.col.astype(int).tolist(),
        coo.data.astype(float).tolist(),
        tuple(int(x) for x in coo.shape),
    )


def cobra_lp_problem_to_optarrow_model(lp_problem: dict[str, Any]) -> dict[str, Any]:
    if "A" not in lp_problem or "b" not in lp_problem or "c" not in lp_problem:
        raise ValueError("LPproblem must include A, b, and c.")

    row, col, val, shape = _coo_triplet(lp_problem["A"])
    n_rows, n_cols = shape
    n_rows = max(n_rows, int(np.asarray(lp_problem["b"]).reshape(-1).shape[0]))
    n_cols = max(n_cols, int(np.asarray(lp_problem["c"]).reshape(-1).shape[0]))

    model = {
        "A": {"row": row, "col": col, "val": val, "shape": [n_rows, n_cols]},
        "b": _as_1d_float_array(lp_problem["b"], length=n_rows),
        "c": _as_1d_float_array(lp_problem["c"], length=n_cols),
        "lb": _as_1d_float_array(lp_problem.get("lb"), default=0.0, length=n_cols),
        "ub": _as_1d_float_array(lp_problem.get("ub"), default=1.0e6, length=n_cols),
        "csense": _normalize_csense(lp_problem.get("csense"), n_rows),
        "osense": _normalize_osense(lp_problem.get("osense")),
    }
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


def optarrow_result_to_cobra_solution(result: dict[str, Any], *, solver_name: str, elapsed: float) -> dict[str, Any]:
    if not result.get("success"):
        return {
            "full": [],
            "obj": np.nan,
            "rcost": [],
            "dual": [],
            "solver": f"optarrow:{solver_name}",
            "lpmethod": "optarrow-direct",
            "stat": -1,
            "origStat": result.get("status", "error"),
            "origStatText": result.get("error_message", "OptArrow solve failed"),
            "time": elapsed,
        }

    solution = np.asarray(result.get("solution", []), dtype=float).reshape(-1)
    status = result.get("status", "")
    return {
        "full": solution.tolist(),
        "obj": float(result.get("obj_val", np.nan)),
        "rcost": [],
        "dual": [],
        "solver": f"optarrow:{solver_name}",
        "lpmethod": "optarrow-direct",
        "stat": _map_status(status),
        "origStat": status,
        "origStatText": status,
        "time": elapsed,
    }


def _highs_status_string(model_status: Any) -> str:
    status = str(model_status).strip()
    return status.split(".")[-1]


def solve_lp_on_optarrow_model_via_highspy(
    model: dict[str, Any],
    *,
    solver_params: dict[str, Any] | None = None,
) -> dict[str, Any]:
    """Solve an OptArrow-style LP model directly with highspy.

    This is not a replacement for OptArrow itself. It is a thin prototype for
    the LP backend behavior we would want from an OptArrow-compatible solver
    layer that serves COBRA well: robust statuses, primal values, row duals,
    and reduced costs from the same sparse model contract.
    """

    import highspy

    solver_params = solver_params or {}

    n_cols = len(model["c"])
    n_rows = len(model["b"])
    row = model["A"]["row"]
    col = model["A"]["col"]
    val = model["A"]["val"]
    csense = model["csense"]
    rhs = model["b"]
    lower = model["lb"]
    upper = model["ub"]
    cost = model["c"]
    maximize = model["osense"] == "max"

    highs = highspy.Highs()
    highs.setOptionValue("output_flag", False)
    for key, value in solver_params.items():
        try:
            highs.setOptionValue(str(key), value)
        except Exception:
            # Keep the proof forgiving while we learn the right parameter map.
            pass

    row_lower = []
    row_upper = []
    for i, sense in enumerate(csense):
        if sense in {"L", "<"}:
            row_lower.append(-highspy.kHighsInf)
            row_upper.append(float(rhs[i]))
        elif sense in {"G", ">"}:
            row_lower.append(float(rhs[i]))
            row_upper.append(highspy.kHighsInf)
        else:
            row_lower.append(float(rhs[i]))
            row_upper.append(float(rhs[i]))

    matrix = sparse.coo_matrix((val, (row, col)), shape=(n_rows, n_cols)).tocsc()

    lp = highspy.HighsLp()
    lp.num_col_ = int(n_cols)
    lp.num_row_ = int(n_rows)
    lp.col_cost_ = np.asarray([-x if maximize else x for x in cost], dtype=np.float64)
    lp.col_lower_ = np.asarray(lower, dtype=np.float64)
    lp.col_upper_ = np.asarray(upper, dtype=np.float64)
    lp.row_lower_ = np.asarray(row_lower, dtype=np.float64)
    lp.row_upper_ = np.asarray(row_upper, dtype=np.float64)
    lp.offset_ = 0.0
    lp.sense_ = highspy.ObjSense.kMinimize
    lp.a_matrix_.format_ = highspy.MatrixFormat.kColwise
    lp.a_matrix_.num_col_ = int(n_cols)
    lp.a_matrix_.num_row_ = int(n_rows)
    lp.a_matrix_.start_ = matrix.indptr.astype(np.int32)
    lp.a_matrix_.index_ = matrix.indices.astype(np.int32)
    lp.a_matrix_.value_ = matrix.data.astype(np.float64)

    started = time.perf_counter()
    highs.passModel(lp)
    highs.run()
    elapsed = time.perf_counter() - started

    model_status = highs.getModelStatus()
    status_text = _highs_status_string(highs.modelStatusToString(model_status))
    solution = highs.getSolution()

    primal = list(solution.col_value)
    rcost = list(solution.col_dual)
    dual = list(solution.row_dual)

    obj_val = highs.getObjectiveValue()
    if maximize and status_text.lower() == "optimal":
        obj_val = -obj_val

    success = status_text.lower() in {"optimal", "infeasible", "unbounded"}
    if status_text.lower() != "optimal":
        primal = []
        obj_val = None

    return {
        "success": success,
        "solution": primal,
        "status": status_text.lower(),
        "obj_val": obj_val,
        "dual": dual,
        "rcost": rcost,
        "time": elapsed,
    }


def highspy_result_to_cobra_solution(result: dict[str, Any], *, elapsed: float) -> dict[str, Any]:
    return {
        "full": list(result.get("solution") or []),
        "obj": float(result["obj_val"]) if result.get("obj_val") is not None else np.nan,
        "rcost": list(result.get("rcost") or []),
        "dual": list(result.get("dual") or []),
        "solver": "optarrow-contract:highs-direct",
        "lpmethod": "highs-direct",
        "stat": _map_status(result.get("status")),
        "origStat": result.get("status", ""),
        "origStatText": result.get("status", ""),
        "time": elapsed,
    }


def solve_cobra_lp_via_optarrow(
    lp_problem: dict[str, Any],
    *,
    solver_name: str = "HiGHS",
    solver_params: dict[str, Any] | None = None,
    optarrow_src: str | Path | None = None,
) -> tuple[dict[str, Any], dict[str, Any], dict[str, Any]]:
    """Solve a COBRA-style LPproblem through OptArrow's Python solver stack.

    Returns a tuple of:

    1. the OptArrow model payload,
    2. the raw OptArrow result,
    3. the mapped COBRA-like solution struct.
    """

    _ensure_optarrow_importable(optarrow_src)
    from service.optimization_service.python.pyomo.service.opt_solver import PyomoSolver

    model = cobra_lp_problem_to_optarrow_model(lp_problem)
    request = dict(model)
    request["solver"] = {
        "solver_name": solver_name,
        "solver_type": "LP",
        "solver_params": solver_params or {},
    }

    started = time.perf_counter()
    raw_result = PyomoSolver().run(request)
    elapsed = time.perf_counter() - started
    cobra_solution = optarrow_result_to_cobra_solution(
        raw_result, solver_name=solver_name, elapsed=elapsed
    )
    return model, raw_result, cobra_solution


def solve_cobra_lp_via_optarrow_contract_highs(
    lp_problem: dict[str, Any],
    *,
    solver_params: dict[str, Any] | None = None,
) -> tuple[dict[str, Any], dict[str, Any], dict[str, Any]]:
    """Solve a COBRA-style LPproblem on the OptArrow model contract via highspy.

    This path is useful for prototyping the solver behavior COBRA would want
    from an OptArrow-tailored LP backend: same sparse schema, richer status
    handling, and access to row duals and reduced costs.
    """

    model = cobra_lp_problem_to_optarrow_model(lp_problem)
    raw_result = solve_lp_on_optarrow_model_via_highspy(
        model, solver_params=solver_params
    )
    cobra_solution = highspy_result_to_cobra_solution(
        raw_result, elapsed=float(raw_result.get("time", np.nan))
    )
    return model, raw_result, cobra_solution
