"""CLI bridge for solving a COBRA-style LP through an Arrow IPC contract."""

from __future__ import annotations

import argparse
from pathlib import Path

from cobra_lp_adapter import solve_lp_on_optarrow_model_via_highspy, highspy_result_to_cobra_solution
from cobra_lp_arrow_ipc import (
    cobra_lp_response_to_arrow_table,
    read_cobra_lp_request,
    write_arrow_stream,
)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, help="Path to Arrow IPC request file")
    parser.add_argument("--output", required=True, help="Path to Arrow IPC response file")
    return parser


def main() -> None:
    args = build_parser().parse_args()
    input_path = Path(args.input)
    output_path = Path(args.output)

    request = read_cobra_lp_request(input_path)
    model = request["model"]
    solver = request.get("solver", {}) or {}
    solver_params = solver.get("solver_params", {}) or {}

    raw_result = solve_lp_on_optarrow_model_via_highspy(
        model,
        solver_params=solver_params,
    )
    cobra_solution = highspy_result_to_cobra_solution(
        raw_result,
        elapsed=float(raw_result.get("time", 0.0)),
    )
    response_table = cobra_lp_response_to_arrow_table(raw_result, cobra_solution)
    write_arrow_stream(response_table, output_path)


if __name__ == "__main__":
    main()
