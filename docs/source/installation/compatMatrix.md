## Unix (macOS or Linux)

| SolverName        | Interface          | R2017b             | R2017a             | R2016b             | R2016a             | R2015b             | R2015a             | R2014b             | R2014a             |
|-------------------|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|
| IBM CPLEX 12.7.1  | `ibm_cplex`        | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| IBM CPLEX 12.7.0  | `ibm_cplex`        | :x:                | :x:                | :x:                | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| IBM CPLEX 12.6.3  | `ibm_cplex`        | :x:                | :x:                | :x:                | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| GUROBI 7.5.1      | `gurobi`           | :x:                | :x:                | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| GUROBI 7.0.2      | `gurobi`           | :x:                | :x:                | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| GUROBI 6.5.0      | `gurobi`           | :x:                | :x:                | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| TOMLAB CPLEX 8.2  | `cplex_direct`     | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |
| MOSEK 8           | `mosek`            | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| DQQ MINOS         | `dqq_minos`        | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |

## Windows

| SolverName        | R2017b             | R2017a             | R2016b             | R2016a             | R2015b             | R2015a             | R2014b             | R2014a             |
|-------------------|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|
| IBM CPLEX 12.7.1  | :warning:          | :warning:          | :x:                | :warning:          | :warning:          | :warning:          | :white_check_mark: | :warning:          |
| IBM CPLEX 12.7.0  | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |
| IBM CPLEX 12.6.3  | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |
| GUROBI 7.5.1      | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |
| GUROBI 7.0.2      | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |
| GUROBI 6.5.0      | :warning:          | :warning:          | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| TOMLAB CPLEX 8    | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |
| MOSEK 8           | :white_check_mark: | :white_check_mark: | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |
| DQQ MINOS         | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          | :warning:          |

### Legend

- :white_check_mark: : compatible with the COBRA Toolbox (tested)
- :x: : not compatible with the COBRA Toolbox (tested)
- :warning: : unverified compatibility with the COBRA Toolbox (not tested)