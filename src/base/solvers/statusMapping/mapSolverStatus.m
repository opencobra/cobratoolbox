function [stat, origStatText] = mapSolverStatus(solver, problemType, origStat)
% Map a solver's native status code to the COBRA canonical solution status.
%
% USAGE:
%
%    [stat, origStatText] = mapSolverStatus(solver, problemType, origStat)
%
% INPUTS:
%    solver:         solver name as used by `changeCobraSolver` (for example
%                    `'gurobi'`, `'ibm_cplex'`, `'tomlab_cplex'`,
%                    `'tomlab_cplex_tomRun'`, `'cplexlp'`, `'cplex_direct'`,
%                    `'glpk'`, `'dqqMinos'`, `'quadMinos'`, `'pdco'`,
%                    `'lp_solve'`, `'mosek_linprog'`, `'matlab'`, `'qpng'`,
%                    `'gurobi_mex'`)
%    problemType:    problem type: `'LP'`, `'QP'`, `'MILP'` or `'MIQP'`
%    origStat:       solver-native status code returned by the solver (numeric
%                    scalar, or the native status string for `gurobi`)
%
% OUTPUTS:
%    stat:           canonical COBRA solution status:
%
%                      * 1 - optimal solution found
%                      * 0 - infeasible (LP/QP), integer infeasible (MILP/MIQP)
%                      * 2 - unbounded
%                      * 3 - solution exists but not proven optimal / numerical
%                      * -1 - other (time limit / numerical for LP/QP; no
%                             integer solution exists for MILP/MIQP)
%    origStatText:   human-readable native status text where the solver provides
%                    one (empty `''` otherwise)
%
% NOTE:
%
%    This is the single canonical native-to-`.stat` translation used by the
%    `solveCobra*` dispatchers, consolidating the status maps that were
%    previously duplicated across (and within) those files (feature
%    015-solver-spine-hardening). The relation is keyed on
%    `(solver, problemType, origStat)` because the same native code maps to a
%    different canonical `.stat` across problem types (for example the CPLEX MIP
%    codes, or GLPK codes `3`/`4`), so each `(solver, problemType)` branch
%    reproduces the exact mapping the dispatcher used before and returned
%    `.stat`/`.origStat` are unchanged.
%
%    An unrecognized `origStat` for a known `(solver, problemType)` folds into a
%    defined non-optimal `.stat` (never `1`): `-1` for most branches, and `3`
%    for the CPLEX MILP/MIQP branches whose inline default was `3`. The dynamic
%    re-solve disambiguation for the gurobi/CPLEX `INF_OR_UNBD` / code-`4` paths
%    is control flow and remains in the dispatcher; this function is called with
%    the terminal native outcome only.
%
% Author:
%    - Generated for feature 009-fba-characterization-statusmap, 2026-07-15.
%    - Extended to the full (solver, problemType, nativeStatus) relation for
%      feature 015-solver-spine-hardening, 2026-07-20.

% default: the solver provides no separate native status label
origStatText = '';

switch upper(problemType)

    case 'LP'
        switch solver

            case {'dqqMinos', 'quadMinos'}
                [stat, origStatText] = dqqStatusMap(origStat);

            case 'glpk'
                if (origStat == 180 || origStat == 5)
                    stat = 1;   % optimal solution found
                elseif (origStat == 182 || origStat == 183 || origStat == 3 || origStat == 110)
                    stat = 0;   % infeasible
                elseif (origStat == 184 || origStat == 6)
                    stat = 2;   % unbounded
                else
                    stat = -1;  % solution not optimal or solver problem
                end

            case 'lp_solve'
                if (origStat == 0)
                    stat = 1;   % optimal solution found
                elseif (origStat == 3)
                    stat = 2;   % unbounded
                elseif (origStat == 2)
                    stat = 0;   % infeasible
                else
                    stat = -1;  % solution not optimal or solver problem
                end

            case 'mosek_linprog'
                if (origStat > 0)
                    stat = 1;   % optimal solution found
                elseif (origStat < 0)
                    stat = 0;   % infeasible
                else
                    stat = -1;  % solution did not converge
                end

            case 'matlab'
                if (origStat > 0)
                    stat = 1;   % optimal solution found
                elseif (origStat < -1)
                    stat = 0;   % infeasible
                elseif (origStat == -1)
                    stat = 3;   % maybe some partial success
                else
                    stat = -1;  % solution not optimal or solver problem
                end

            case 'gurobi'
                stat = gurobiLpQpStatus(origStat);

            case {'tomlab_cplex', 'cplexlp'}
                stat = cplexBaseStatus(origStat);

            case 'ibm_cplex'
                % Note: code 4 (INF_OR_UNBD) is disambiguated by a re-solve in
                % the dispatcher and is not resolved here. Code 101 (and any
                % other unlisted code) folds to -1, restoring a defined status
                % for the previously warn-only-and-left-at-0 case.
                if origStat == 1
                    stat = 1;   % optimal solution
                elseif origStat == 2 || origStat == 20
                    stat = 2;   % unbounded
                elseif origStat == 3
                    stat = 0;   % infeasible
                elseif origStat == 5 || origStat == 6
                    stat = 3;   % almost optimal solution
                elseif (origStat >= 10 && origStat <= 12) || origStat == 21 || origStat == 22
                    stat = 3;   % limit reached, solution may be available
                else
                    stat = -1;  % other problem (time limit, numerical, MIP code)
                end

            case 'pdco'
                stat = pdcoStatus(origStat);

            otherwise
                error('COBRA:mapSolverStatus:unmappedSolver', ...
                    'mapSolverStatus: no LP status map for solver ''%s''.', solver);
        end

    case 'QP'
        switch solver

            case {'tomlab_cplex', 'tomlab_cplex_tomRun', 'ibm_cplex'}
                stat = cplexBaseStatus(origStat);

            case 'qpng'
                if (origStat == 0)
                    stat = 1;   % optimal solution found
                elseif (origStat == 1)
                    stat = 0;   % infeasible
                else
                    stat = -1;  % solution not optimal or solver problem
                end

            case 'pdco'
                stat = pdcoStatus(origStat);

            case 'gurobi'
                stat = gurobiLpQpStatus(origStat);

            case 'dqqMinos'
                [stat, origStatText] = dqqStatusMap(origStat);

            otherwise
                error('COBRA:mapSolverStatus:unmappedSolver', ...
                    'mapSolverStatus: no QP status map for solver ''%s''.', solver);
        end

    case 'MILP'
        switch solver

            case 'glpk'
                if (origStat == 5)
                    stat = 1;   % optimal
                elseif (origStat == 6)
                    stat = 2;   % unbounded
                elseif (origStat == 4)
                    stat = 0;   % infeasible
                elseif (origStat == 171)
                    stat = 1;   % optimal integer within tolerance
                elseif (origStat == 173)
                    stat = 0;   % integer infeasible
                elseif (origStat == 184)
                    stat = 2;   % unbounded
                elseif (origStat == 172)
                    stat = 3;   % other problem, but integer solution exists
                else
                    stat = -1;  % no integer solution exists
                end

            case {'cplex_direct', 'tomlab_cplex'}
                stat = cplexMipStatus(origStat);

            case 'gurobi_mex'
                stat = gurobiMexMipStatus(origStat);

            case 'ibm_cplex'
                stat = ibmMipStatus(origStat);

            case 'gurobi'
                stat = gurobiMipStatus(origStat, true);

            otherwise
                error('COBRA:mapSolverStatus:unmappedSolver', ...
                    'mapSolverStatus: no MILP status map for solver ''%s''.', solver);
        end

    case 'MIQP'
        switch solver

            case 'tomlab_cplex'
                if (origStat == 1 || origStat == 101 || origStat == 102)
                    stat = 1;   % optimal
                elseif (origStat == 3 || origStat == 4)
                    stat = 0;   % infeasible
                elseif (origStat == 103)
                    stat = 0;   % integer infeasible
                elseif (origStat == 2 || origStat == 118 || origStat == 119)
                    stat = 2;   % unbounded
                elseif any(origStat == [106, 108, 110, 112, 114, 117])
                    stat = -1;  % no integer solution exists
                elseif (origStat >= 10)
                    stat = -1;  % no optimal solution (time or other limits)
                else
                    stat = 3;   % solution exists, scaling / not proven optimal
                end

            case 'gurobi_mex'
                stat = gurobiMexMipStatus(origStat);

            case 'gurobi'
                stat = gurobiMipStatus(origStat, false);

            case 'ibm_cplex'
                stat = ibmMipStatus(origStat);

            otherwise
                error('COBRA:mapSolverStatus:unmappedSolver', ...
                    'mapSolverStatus: no MIQP status map for solver ''%s''.', solver);
        end

    otherwise
        error('COBRA:mapSolverStatus:unmappedProblemType', ...
            'mapSolverStatus: no status map for problemType ''%s''.', problemType);
end
end


function [stat, origStatText] = dqqStatusMap(origStat)
% Single definition of the DQQ / quadMinos exit-code map (shared by the LP
% dqqMinos/quadMinos and QP dqqMinos branches). Translation of DQQ exit codes
% (https://github.com/kerrickstaley/lp_solve/blob/master/lp_lib.h).
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

codes = cell2mat(dqqStatMap(:, 1));
k = find(codes == origStat, 1);

if isempty(k)
    % guarded fallback: unrecognized code is a defined non-optimal outcome
    origStatText = 'UNMAPPED';
    stat = -1;
else
    origStatText = dqqStatMap{k, 2};
    stat = dqqStatMap{k, 3};
end
end


function stat = cplexBaseStatus(origStat)
% CPLEX-family LP/QP solution status (tomlab_cplex, tomlab_cplex_tomRun,
% ibm_cplex QP, cplexlp LP).
if origStat == 1
    stat = 1;   % optimal
elseif origStat == 3
    stat = 0;   % infeasible
elseif origStat == 2 || origStat == 4
    stat = 2;   % unbounded
elseif origStat == 5 || origStat == 6
    stat = 3;   % almost optimal / numerical
else
    stat = -1;  % other (time limit, numerical, etc.)
end
end


function stat = cplexMipStatus(origStat)
% CPLEX MIP solution status for cplex_direct / tomlab_cplex (MILP). Unrecognized
% codes fold to 3, matching the inline default these branches used.
if origStat == 101 || origStat == 102
    stat = 1;   % optimal integer within tolerance
elseif origStat == 103
    stat = 0;   % integer infeasible
elseif origStat == 118 || origStat == 119
    stat = 2;   % unbounded
elseif any(origStat == [106, 108, 110, 112, 114, 117])
    stat = -1;  % no integer solution exists
else
    stat = 3;   % other problem, but integer solution exists
end
end


function stat = ibmMipStatus(origStat)
% CPLEX MIP solution status for ibm_cplex (MILP and MIQP). ibm_cplex also
% returns the simplified codes 1/2/3, so those are mapped alongside the raw
% CPLEX codes. Unrecognized codes fold to 3, matching the inline default.
if origStat == 101 || origStat == 102 || origStat == 1
    stat = 1;   % optimal integer within tolerance
elseif origStat == 103 || origStat == 3
    stat = 0;   % integer infeasible
elseif origStat == 118 || origStat == 119 || origStat == 2
    stat = 2;   % unbounded
elseif any(origStat == [106, 108, 110, 112, 114, 117])
    stat = -1;  % no integer solution exists
else
    stat = 3;   % other problem, but integer solution exists
end
end


function stat = gurobiLpQpStatus(origStat)
% gurobi LP/QP native status string. The INF_OR_UNBD re-solve is control flow in
% the dispatcher, so it is not resolved here (an unlisted status folds to -1).
if strcmp(origStat, 'OPTIMAL')
    stat = 1;   % optimal solution found
elseif strcmp(origStat, 'INFEASIBLE')
    stat = 0;   % infeasible
elseif strcmp(origStat, 'UNBOUNDED')
    stat = 2;   % unbounded
else
    stat = -1;  % solution not optimal or solver problem
end
end


function stat = gurobiMipStatus(origStat, isMILP)
% gurobi MILP/MIQP native status string. INF_OR_UNBD is a hard 0 (no re-solve)
% for the integer dispatchers; TIME_LIMIT -> 3 is handled by MILP only.
if strcmp(origStat, 'OPTIMAL')
    stat = 1;   % optimal solution found
elseif strcmp(origStat, 'INFEASIBLE')
    stat = 0;   % infeasible
elseif strcmp(origStat, 'UNBOUNDED')
    stat = 2;   % unbounded
elseif strcmp(origStat, 'INF_OR_UNBD')
    stat = 0;   % gurobi reports infeasible *or* unbounded
elseif isMILP && strcmp(origStat, 'TIME_LIMIT')
    stat = 3;   % time limit reached, solution might not be optimal
else
    stat = -1;  % solution not optimal or solver problem
end
end


function stat = gurobiMexMipStatus(origStat)
% gurobi_mex MILP/MIQP native status code.
if origStat == 2
    stat = 1;   % optimal solution found
elseif origStat == 3
    stat = 0;   % infeasible
elseif origStat == 5
    stat = 2;   % unbounded
elseif origStat == 4
    stat = 0;   % gurobi reports infeasible *or* unbounded
else
    stat = -1;  % solution not optimal or solver problem
end
end


function stat = pdcoStatus(origStat)
% pdco LP/QP inform code: 0 solution found; 1/2/3 failure modes; 4 not PD.
if (origStat == 0)
    stat = 1;   % solution found
elseif (origStat == 1 || origStat == 2 || origStat == 3)
    stat = 0;   % infeasible / did not converge
else
    stat = -1;  % other (Cholesky not positive definite, etc.)
end
end
