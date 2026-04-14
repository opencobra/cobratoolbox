"""Arrow IPC helpers for a COBRA-to-OptArrow LP proof of concept.

This file defines a small Arrow-based contract around the existing OptArrow
model schema so we can exercise a typed, portable boundary that is cleaner
than ad-hoc JSON blobs.
"""

from __future__ import annotations

from pathlib import Path
from typing import Any

import pyarrow as pa


def _single_row_table(payload: dict[str, Any]) -> pa.Table:
    names = list(payload.keys())
    arrays = [pa.array([payload[name]]) for name in names]
    return pa.Table.from_arrays(arrays, names=names)


def _table_to_single_row_dict(table: pa.Table) -> dict[str, Any]:
    payload: dict[str, Any] = {}
    for name in table.column_names:
        values = table.column(name).to_pylist()
        payload[name] = values[0] if len(values) == 1 else values
    return payload


def cobra_lp_request_to_arrow_table(
    optarrow_model: dict[str, Any],
    *,
    solver_name: str = "HiGHS",
    solver_params: dict[str, Any] | None = None,
    model_name: str = "cobra_lp",
    engine: str = "PYTHON",
    time_limit: int = 300,
) -> pa.Table:
    payload = {
        "model": optarrow_model,
        "model_name": model_name,
        "engine": engine,
        "time_limit": int(time_limit),
        "solver": {
            "solver_name": solver_name,
            "solver_type": "LP",
            "solver_params": solver_params or {},
        },
    }
    return _single_row_table(payload)


def cobra_lp_response_to_arrow_table(
    raw_result: dict[str, Any],
    cobra_solution: dict[str, Any],
) -> pa.Table:
    payload = {
        "success": bool(raw_result.get("success", False)),
        "status": raw_result.get("status", ""),
        "obj_val": raw_result.get("obj_val"),
        "solution": list(raw_result.get("solution") or []),
        "dual": list(raw_result.get("dual") or []),
        "rcost": list(raw_result.get("rcost") or []),
        "time": float(raw_result.get("time", 0.0)),
        "stat": int(cobra_solution.get("stat", -1)),
        "origStat": cobra_solution.get("origStat", ""),
        "origStatText": cobra_solution.get("origStatText", ""),
        "solver": cobra_solution.get("solver", ""),
        "lpmethod": cobra_solution.get("lpmethod", ""),
        "full": list(cobra_solution.get("full") or []),
        "obj": cobra_solution.get("obj"),
    }
    return _single_row_table(payload)


def write_arrow_stream(table: pa.Table, path: str | Path) -> None:
    output_path = Path(path)
    with pa.OSFile(str(output_path), "wb") as sink:
        with pa.ipc.new_stream(sink, table.schema) as writer:
            writer.write_table(table)


def read_arrow_stream(path: str | Path) -> pa.Table:
    input_path = Path(path)
    with pa.memory_map(str(input_path), "r") as source:
        reader = pa.ipc.open_stream(source)
        return reader.read_all()


def read_cobra_lp_request(path: str | Path) -> dict[str, Any]:
    return _table_to_single_row_dict(read_arrow_stream(path))


def read_cobra_lp_response(path: str | Path) -> dict[str, Any]:
    return _table_to_single_row_dict(read_arrow_stream(path))
