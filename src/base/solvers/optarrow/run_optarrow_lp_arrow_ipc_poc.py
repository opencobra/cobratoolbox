"""Run a file-based Arrow IPC proof for a COBRA-style LP solve."""

from __future__ import annotations

import json
from pathlib import Path
import tempfile

import numpy as np
from scipy import sparse

from cobra_lp_adapter import cobra_lp_problem_to_optarrow_model
from cobra_lp_arrow_ipc import (
    cobra_lp_request_to_arrow_table,
    read_cobra_lp_response,
    write_arrow_stream,
)
from solve_cobra_lp_arrow_ipc_cli import main as cli_main


def make_toy_lp_problem() -> dict:
    return {
        "A": sparse.coo_matrix(np.array([[2.0, 1.0], [1.0, 2.0]], dtype=float)),
        "b": [8.0, 8.0],
        "c": [3.0, 4.0],
        "lb": [0.0, 0.0],
        "ub": [1000.0, 1000.0],
        "csense": ["L", "L"],
        "osense": -1,
    }


def _pretty(value) -> str:
    return json.dumps(value, indent=2, sort_keys=True)


def main() -> None:
    lp_problem = make_toy_lp_problem()
    optarrow_model = cobra_lp_problem_to_optarrow_model(lp_problem)
    request_table = cobra_lp_request_to_arrow_table(optarrow_model)

    with tempfile.TemporaryDirectory(prefix="cobra_optarrow_arrow_") as tmp_dir:
        request_path = Path(tmp_dir) / "request.arrow"
        response_path = Path(tmp_dir) / "response.arrow"
        write_arrow_stream(request_table, request_path)

        import sys

        argv_backup = sys.argv[:]
        try:
            sys.argv = [
                "solve_cobra_lp_arrow_ipc_cli.py",
                "--input",
                str(request_path),
                "--output",
                str(response_path),
            ]
            cli_main()
        finally:
            sys.argv = argv_backup

        response = read_cobra_lp_response(response_path)

    expected_obj = 56.0 / 3.0
    if int(response["stat"]) != 1:
        raise RuntimeError(f"Expected optimal status, got: {response}")
    if not np.isclose(float(response["obj"]), expected_obj, atol=1e-8):
        raise RuntimeError(f"Expected objective {expected_obj}, got {response['obj']}")

    print("OptArrow model encoded as Arrow IPC request")
    print(_pretty(optarrow_model))
    print("\nArrow IPC response")
    print(_pretty(response))


if __name__ == "__main__":
    main()
