"""Exercise status handling for the direct-HiGHS OptArrow contract shim."""

from __future__ import annotations

import json

import highspy

from cobra_lp_adapter import solve_cobra_lp_via_optarrow_contract_highs


def _pretty(value) -> str:
    return json.dumps(value, indent=2, sort_keys=True)


def _cases() -> dict:
    return {
        "optimal": {
            "A": {"row": [0, 0, 1, 1], "col": [0, 1, 0, 1], "val": [2.0, 1.0, 1.0, 2.0]},
            "b": [8.0, 8.0],
            "c": [3.0, 4.0],
            "lb": [0.0, 0.0],
            "ub": [1000.0, 1000.0],
            "csense": ["L", "L"],
            "osense": -1,
        },
        "infeasible": {
            "A": {"row": [0, 1], "col": [0, 0], "val": [1.0, 1.0]},
            "b": [1.0, 2.0],
            "c": [1.0],
            "lb": [0.0],
            "ub": [1000.0],
            "csense": ["L", "G"],
            "osense": -1,
        },
        "unbounded": {
            "A": {"row": [], "col": [], "val": []},
            "b": [],
            "c": [1.0],
            "lb": [0.0],
            "ub": [highspy.kHighsInf],
            "csense": [],
            "osense": -1,
        },
    }


def main() -> None:
    expected = {"optimal": 1, "infeasible": 0, "unbounded": 2}
    for name, lp_problem in _cases().items():
        _, raw_result, cobra_solution = solve_cobra_lp_via_optarrow_contract_highs(lp_problem)
        if cobra_solution["stat"] != expected[name]:
            raise RuntimeError(
                f"{name}: expected stat {expected[name]}, got {cobra_solution['stat']} with result {cobra_solution}"
            )
        print(f"\nCASE: {name}")
        print("Raw result")
        print(_pretty(raw_result))
        print("Mapped COBRA-like solution")
        print(_pretty(cobra_solution))


if __name__ == "__main__":
    main()
