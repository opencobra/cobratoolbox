function [stat, origStatText] = mapSolverStatus(solver, problemType, origStat)
% Map a solver's native status code to the COBRA canonical solution status.
%
% USAGE:
%
%    [stat, origStatText] = mapSolverStatus(solver, problemType, origStat)
%
% INPUTS:
%    solver:         solver name as used by `changeCobraSolver`
%                    (for example `'dqqMinos'`, `'quadMinos'`)
%    problemType:    problem type: `'LP'`, `'QP'`, `'MILP'` or `'MIQP'`
%    origStat:       solver-native status code returned by the solver
%
% OUTPUTS:
%    stat:           canonical COBRA solution status:
%
%                      * 1 - optimal solution found
%                      * 0 - infeasible
%                      * 2 - unbounded
%                      * 3 - solution exists but not proven optimal / numerical
%                      * -1 - no optimal solution (other)
%    origStatText:   human-readable native status text where the solver provides
%                    one (empty `''` otherwise)
%
% NOTE:
%
%    This is the single canonical native-to-`.stat` translation used by the
%    `solveCobra*` dispatchers, consolidating status maps that were previously
%    duplicated across (and within) those files. Each (solver, problemType)
%    branch reproduces the exact mapping the dispatcher used before, so returned
%    `.stat`/`.origStat` are unchanged.
%
% Author:
%    - Generated for feature 009-fba-characterization-statusmap, 2026-07-15.

switch upper(problemType)

    case 'LP'
        switch solver

            case {'dqqMinos', 'quadMinos'}
                % Translation of DQQ exit codes
                % (https://github.com/kerrickstaley/lp_solve/blob/master/lp_lib.h)
                dqqStatMap = {-5, 'UNKNOWNERROR', -1;
                              -4, 'DATAIGNORED',  -1;
                              -3, 'NOBFP',        -1;
                              -2, 'NOMEMORY',     -1;
                              -1, 'NOTRUN',       -1;
                               0, 'OPTIMAL',       1;
                               1, 'SUBOPTIMAL',   -1;
                               2, 'INFEASIBLE',    0;
                               3, 'UNBOUNDED',     2;
                               4, 'DEGENERATE',   -1;
                               5, 'NUMFAILURE',   -1;
                               6, 'USERABORT',    -1;
                               7, 'TIMEOUT',      -1;
                               8, 'RUNNING',      -1;
                               9, 'PRESOLVED',    -1};

                origStatText = dqqStatMap{[dqqStatMap{:, 1}] == origStat, 2};
                stat = dqqStatMap{[dqqStatMap{:, 1}] == origStat, 3};

            otherwise
                error('COBRA:mapSolverStatus:unmappedSolver', ...
                    'mapSolverStatus: no LP status map for solver ''%s''.', solver);
        end

    case 'QP'
        switch solver

            case {'tomlab_cplex', 'tomlab_cplex_tomRun', 'ibm_cplex'}
                % CPLEX-family QP solution status (see solveCobraQP)
                origStatText = '';
                if origStat == 1
                    stat = 1;   % optimal
                elseif origStat == 3
                    stat = 0;   % infeasible
                elseif origStat == 2 || origStat == 4
                    stat = 2;   % unbounded
                elseif origStat == 5 || origStat == 6
                    stat = 3;   % solution exists but not proven optimal / numerical
                else
                    stat = -1;  % no optimal solution (other)
                end

            otherwise
                error('COBRA:mapSolverStatus:unmappedSolver', ...
                    'mapSolverStatus: no QP status map for solver ''%s''.', solver);
        end

    otherwise
        error('COBRA:mapSolverStatus:unmappedProblemType', ...
            'mapSolverStatus: no status map for problemType ''%s''.', problemType);
end
end
