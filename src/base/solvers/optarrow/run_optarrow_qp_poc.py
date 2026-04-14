"""Run a minimal COBRA x OptArrow QP proof of concept."""

from __future__ import annotations

import json
import numpy as np
from scipy import sparse

from cobra_qp_adapter import solve_cobra_qp_via_optarrow


def make_toy_qp_problem() -> dict:
    # min x^2 + y^2 - 2x - 5y
    # s.t. x + y = 3, x,y >= 0
    return {
        "F": sparse.coo_matrix(np.array([[2.0, 0.0], [0.0, 2.0]], dtype=float)),
        "c": [-2.0, -5.0],
        "A": sparse.coo_matrix(np.array([[1.0, 1.0]], dtype=float)),
        "b": [3.0],
        "lb": [0.0, 0.0],
        "ub": [1000.0, 1000.0],
        "csense": ["E"],
        "osense": 1,
    }


def _pretty(value) -> str:
    return json.dumps(value, indent=2, sort_keys=True)


def main() -> None:
    qp_problem = make_toy_qp_problem()
    model, raw_result, cobra_solution = solve_cobra_qp_via_optarrow(qp_problem)

    expected_obj = -7.125
    if cobra_solution["stat"] != 1:
        raise RuntimeError(f"Expected optimal status, got {cobra_solution['stat']}: {cobra_solution}")
    if not np.isclose(raw_result["obj_val"], expected_obj, atol=1e-6):
        raise RuntimeError(f"Expected objective {expected_obj}, got {raw_result['obj_val']}")

    print("COBRA-style QPproblem -> OptArrow model")
    print(_pretty(model))
    print("\nRaw OptArrow result")
    print(_pretty(raw_result))
    print("\nMapped COBRA-like QP solution")
    print(_pretty(cobra_solution))


if __name__ == "__main__":
    main()
