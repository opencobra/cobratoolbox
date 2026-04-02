"""CLI bridge for solving a COBRA-style LPproblem via the OptArrow contract."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from cobra_lp_adapter import solve_cobra_lp_via_optarrow_contract_highs


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, help="Path to JSON input payload")
    parser.add_argument("--output", required=True, help="Path to JSON output payload")
    return parser


def main() -> None:
    args = build_parser().parse_args()
    input_path = Path(args.input)
    output_path = Path(args.output)

    payload = json.loads(input_path.read_text())
    lp_problem = payload["lp_problem"]
    solver_params = payload.get("solver_params", {})

    _, raw_result, cobra_solution = solve_cobra_lp_via_optarrow_contract_highs(
        lp_problem,
        solver_params=solver_params,
    )

    output = {
        "raw_result": raw_result,
        "cobra_solution": cobra_solution,
    }
    output_path.write_text(json.dumps(output))


if __name__ == "__main__":
    main()
