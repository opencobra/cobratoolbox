# Solver compatibility matrices

## Unix (macOS or Linux)

| SolverName        | R2017b             | R2017a             | R2016b             | R2016a             | R2015b             | R2015a             | R2014b             | R2014a             |
|-------------------|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|
| IBM CPLEX 12.7.1  | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| IBM CPLEX 12.7    | :x:                | :x:                | :x:                | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| IBM CPLEX 12.6.3  | :x:                | :x:                | :x:                | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| GUROBI 7.5.1      | :x:                | :x:                | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| GUROBI 7.0.2      | :x:                | :x:                | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| GUROBI 6.5.0      | :x:                | :x:                | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| TOMLAB CPLEX 8.2  | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :x:                |
| MOSEK 8           | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| GLPK              | :x:                | :x:                | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| DQQ MINOS         | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| OPTI              | :x:                | :x:                | :x:                | :x:                | :x:                | :x:                | :x:                | :x:                |
| LINDO LEGACY      | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |
| PDCO              | :warning:          | :warning:          | :white_check_mark: | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |
| LP SOLVE          | :warning:          | :warning:          | :x:                | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |

## Windows

| SolverName        | R2017b             | R2017a             | R2016b             | R2016a             | R2015b             | R2015a             | R2014b             | R2014a             |
|-------------------|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|
| IBM CPLEX 12.7.1  | :warning:          | :warning:          | :x:                | :warning:          | :warning:          | :warning:          | :white_check_mark: | :warning:          |
| IBM CPLEX 12.7    | :warning:          | :warning:          | :x:                | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |
| IBM CPLEX 12.6.3  | :warning:          | :warning:          | :white_check_mark: | :warning:          | :white_check_mark: | :warning:          | :white_check_mark: | :warning:          |
| GUROBI 7.5.1      | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |
| GUROBI 7.0.2      | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |
| GUROBI 6.5.0      | :warning:          | :warning:          | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| TOMLAB CPLEX 8.2  | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :x:                |
| MOSEK 8           | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |
| GLPK              | :warning:          | :warning:          | :white_check_mark: | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |
| DQQ MINOS         | :x:                | :x:                | :x:                | :x:                | :x:                | :x:                | :x:                | :x:                |
| OPTI              | :x:                | :x:                | :x:                | :x:                | :x:                | :x:                | :warning:          | :warning:          |
| LINDO LEGACY      | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |
| PDCO              | :warning:          | :warning:          | :white_check_mark: | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |
| LP SOLVE          | :warning:          | :warning:          | :x:                | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |

### Legend

- :white_check_mark: : compatible with the COBRA Toolbox (tested)
- :x: : not compatible with the COBRA Toolbox (tested)
- :warning: : unverified compatibility with the COBRA Toolbox (not tested)

### Notes

- The interfaces `cplex_direct` and `tomlab_snopt` bear the same compatibility pattern as `tomlab_cplex`.
- The interface `quadMinos` bears the same compatibility pattern as `dqqMinos`.
- The interface `lindo_old` bears the same compatibility pattern as `lindo_legacy`.