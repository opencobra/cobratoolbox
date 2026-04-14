"""Run a minimal COBRA x OptArrow LP proof of concept."""

from __future__ import annotations

import json
from pathlib import Path

import numpy as np
from scipy import sparse

from cobra_lp_adapter import (
    solve_cobra_lp_via_optarrow,
    solve_cobra_lp_via_optarrow_contract_highs,
)


def make_toy_lp_problem() -> dict:
    # max 3x + 4y
    # s.t.
    #   2x +  y <= 8
    #    x + 2y <= 8
    #   x, y >= 0
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
    model, raw_result, cobra_solution = solve_cobra_lp_via_optarrow(lp_problem)
    _, raw_contract_result, cobra_contract_solution = solve_cobra_lp_via_optarrow_contract_highs(lp_problem)

    expected_obj = 56.0 / 3.0
    if cobra_solution["stat"] != 1:
        raise RuntimeError(f"Expected optimal status, got {cobra_solution['stat']}: {cobra_solution}")
    if not np.isclose(cobra_solution["obj"], expected_obj, atol=1e-8):
        raise RuntimeError(
            f"Expected objective {expected_obj}, got {cobra_solution['obj']}"
        )

    print("OptArrow source:", Path(__file__).resolve())
    print("\nCOBRA-style LPproblem -> OptArrow model")
    print(_pretty(model))
    print("\nRaw OptArrow result")
    print(_pretty(raw_result))
    print("\nMapped COBRA-like solution")
    print(_pretty(cobra_solution))

    print("\nRaw direct-HiGHS-on-OptArrow-contract result")
    print(_pretty(raw_contract_result))
    print("\nMapped COBRA-like solution from direct-HiGHS contract path")
    print(_pretty(cobra_contract_solution))


if __name__ == "__main__":
    main()
