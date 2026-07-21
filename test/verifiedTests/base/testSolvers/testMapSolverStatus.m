% The COBRAToolbox: testMapSolverStatus.m
%
% Purpose:
%     - Unit test for the consolidated mapSolverStatus helper. It pins the
%       native->canonical status map EXACTLY for every (solver, problemType,
%       nativeStatus) triple the inline dispatcher maps handled before feature
%       015-solver-spine-hardening consolidated them (research.md R1.1 tables +
%       the by-problem-type divergences R1.6). This is the behaviour-preservation
%       oracle for the status-map consolidation and is solver-independent (pure
%       function), so it needs no solver installed.
%     - Also guards the two store-side bugs the consolidation fixes:
%         Bug A - MIQP gurobi returns a NUMERIC .stat and a STRING .origStat.
%         Bug B - LP ibm_cplex native 101 does NOT yield .stat == 0.
%
% Authors:
%     - Generated for feature 009-fba-characterization-statusmap, 2026-07-15.
%     - Extended to the full relation for feature 015-solver-spine-hardening,
%       2026-07-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMapSolverStatus'));
cd(fileDir);

% -------------------------------------------------------------------------
% DQQ / quadMinos LP map, transcribed from solveCobraLP.m: {inform, stat, text}
% -------------------------------------------------------------------------
dqq = {-5, -1, 'UNKNOWNERROR';
       -4, -1, 'DATAIGNORED';
       -3, -1, 'NOBFP';
       -2, -1, 'NOMEMORY';
       -1, -1, 'NOTRUN';
        0,  1, 'OPTIMAL';
        1, -1, 'SUBOPTIMAL';
        2,  0, 'INFEASIBLE';
        3,  2, 'UNBOUNDED';
        4, -1, 'DEGENERATE';
        5, -1, 'NUMFAILURE';
        6, -1, 'USERABORT';
        7, -1, 'TIMEOUT';
        8, -1, 'RUNNING';
        9, -1, 'PRESOLVED'};

% dqqMinos/quadMinos share the same LP map, and dqqMinos QP uses the same map
for solverName = {'dqqMinos', 'quadMinos'}
    for i = 1:size(dqq, 1)
        [stat, origStatText] = mapSolverStatus(solverName{1}, 'LP', dqq{i, 1});
        assert(stat == dqq{i, 2});
        assert(strcmp(origStatText, dqq{i, 3}));
    end
end
for i = 1:size(dqq, 1)
    [stat, origStatText] = mapSolverStatus('dqqMinos', 'QP', dqq{i, 1});
    assert(stat == dqq{i, 2});
    assert(strcmp(origStatText, dqq{i, 3}));
end

% guarded fallback for the DQQ map: out-of-table code -> -1, text 'UNMAPPED'
[stat, origStatText] = mapSolverStatus('dqqMinos', 'LP', 999);
assert(stat == -1);
assert(strcmp(origStatText, 'UNMAPPED'));

% problemType is accepted case-insensitively (upper-cased internally)
assert(mapSolverStatus('dqqMinos', 'lp', 0) == 1);

% -------------------------------------------------------------------------
% Exact per-(solver, problemType, nativeStatus) fixtures: {solver, ptype, code, stat}
% Numeric codes are numeric; gurobi native codes are strings.
% -------------------------------------------------------------------------
fixtures = {
    % --- LP glpk (solveGlpk) ---
    'glpk', 'LP', 180, 1; 'glpk', 'LP', 5, 1;
    'glpk', 'LP', 182, 0; 'glpk', 'LP', 183, 0; 'glpk', 'LP', 3, 0; 'glpk', 'LP', 110, 0;
    'glpk', 'LP', 184, 2; 'glpk', 'LP', 6, 2;
    'glpk', 'LP', 4, -1; 'glpk', 'LP', 999, -1;      % 4 -> -1 (diverges from MILP glpk 4 -> 0)
    % --- LP lp_solve ---
    'lp_solve', 'LP', 0, 1; 'lp_solve', 'LP', 3, 2; 'lp_solve', 'LP', 2, 0; 'lp_solve', 'LP', 1, -1;
    % --- LP mosek_linprog (linprog exitflag) ---
    'mosek_linprog', 'LP', 1, 1; 'mosek_linprog', 'LP', 5, 1;
    'mosek_linprog', 'LP', -1, 0; 'mosek_linprog', 'LP', -5, 0; 'mosek_linprog', 'LP', 0, -1;
    % --- LP matlab (linprog exitflag) ---
    'matlab', 'LP', 1, 1; 'matlab', 'LP', 5, 1;
    'matlab', 'LP', -2, 0; 'matlab', 'LP', -5, 0;
    'matlab', 'LP', -1, 3; 'matlab', 'LP', 0, -1;
    % --- LP gurobi (native string) ---
    'gurobi', 'LP', 'OPTIMAL', 1; 'gurobi', 'LP', 'INFEASIBLE', 0;
    'gurobi', 'LP', 'UNBOUNDED', 2; 'gurobi', 'LP', 'SUBOPTIMAL', -1;
    % --- LP tomlab_cplex / cplexlp (identical CPLEX base map) ---
    'tomlab_cplex', 'LP', 1, 1; 'tomlab_cplex', 'LP', 3, 0; 'tomlab_cplex', 'LP', 2, 2;
    'tomlab_cplex', 'LP', 4, 2; 'tomlab_cplex', 'LP', 5, 3; 'tomlab_cplex', 'LP', 6, 3;
    'tomlab_cplex', 'LP', 0, -1; 'tomlab_cplex', 'LP', 99, -1;
    'cplexlp', 'LP', 1, 1; 'cplexlp', 'LP', 3, 0; 'cplexlp', 'LP', 2, 2; 'cplexlp', 'LP', 4, 2;
    'cplexlp', 'LP', 5, 3; 'cplexlp', 'LP', 6, 3; 'cplexlp', 'LP', 0, -1;
    % --- LP ibm_cplex (code 4 = dispatcher re-solve; not asserted here) ---
    'ibm_cplex', 'LP', 1, 1; 'ibm_cplex', 'LP', 2, 2; 'ibm_cplex', 'LP', 20, 2;
    'ibm_cplex', 'LP', 3, 0; 'ibm_cplex', 'LP', 5, 3; 'ibm_cplex', 'LP', 6, 3;
    'ibm_cplex', 'LP', 10, 3; 'ibm_cplex', 'LP', 11, 3; 'ibm_cplex', 'LP', 12, 3;
    'ibm_cplex', 'LP', 21, 3; 'ibm_cplex', 'LP', 22, 3;
    'ibm_cplex', 'LP', 101, -1;                      % Bug B: 101 -> -1 (not 0)
    'ibm_cplex', 'LP', 102, -1; 'ibm_cplex', 'LP', 0, -1;
    % --- LP pdco ---
    'pdco', 'LP', 0, 1; 'pdco', 'LP', 1, 0; 'pdco', 'LP', 2, 0; 'pdco', 'LP', 3, 0;
    'pdco', 'LP', 4, -1;
    % --- QP tomlab_cplex / tomlab_cplex_tomRun / ibm_cplex ---
    'tomlab_cplex', 'QP', 1, 1; 'tomlab_cplex', 'QP', 3, 0; 'tomlab_cplex', 'QP', 2, 2;
    'tomlab_cplex', 'QP', 4, 2; 'tomlab_cplex', 'QP', 5, 3; 'tomlab_cplex', 'QP', 6, 3;
    'tomlab_cplex', 'QP', 0, -1;
    'tomlab_cplex_tomRun', 'QP', 1, 1; 'tomlab_cplex_tomRun', 'QP', 3, 0;
    'tomlab_cplex_tomRun', 'QP', 2, 2; 'tomlab_cplex_tomRun', 'QP', 10, -1;
    'ibm_cplex', 'QP', 1, 1; 'ibm_cplex', 'QP', 3, 0; 'ibm_cplex', 'QP', 4, 2;
    'ibm_cplex', 'QP', 5, 3; 'ibm_cplex', 'QP', 99, -1;
    % --- QP qpng ---
    'qpng', 'QP', 0, 1; 'qpng', 'QP', 1, 0; 'qpng', 'QP', 2, -1; 'qpng', 'QP', 5, -1;
    % --- QP pdco ---
    'pdco', 'QP', 0, 1; 'pdco', 'QP', 1, 0; 'pdco', 'QP', 2, 0; 'pdco', 'QP', 3, 0;
    'pdco', 'QP', 4, -1;
    % --- QP gurobi (native string) ---
    'gurobi', 'QP', 'OPTIMAL', 1; 'gurobi', 'QP', 'INFEASIBLE', 0;
    'gurobi', 'QP', 'UNBOUNDED', 2; 'gurobi', 'QP', 'SUBOPTIMAL', -1;
    % --- MILP glpk ---
    'glpk', 'MILP', 5, 1; 'glpk', 'MILP', 6, 2; 'glpk', 'MILP', 4, 0;   % 4 -> 0 (diverges from LP glpk 4 -> -1)
    'glpk', 'MILP', 171, 1; 'glpk', 'MILP', 173, 0; 'glpk', 'MILP', 184, 2;
    'glpk', 'MILP', 172, 3; 'glpk', 'MILP', 3, -1; 'glpk', 'MILP', 999, -1;  % 3 -> -1 (diverges from LP glpk 3 -> 0)
    % --- MILP cplex_direct / tomlab_cplex (unrecognized -> 3) ---
    'cplex_direct', 'MILP', 101, 1; 'cplex_direct', 'MILP', 102, 1; 'cplex_direct', 'MILP', 103, 0;
    'cplex_direct', 'MILP', 118, 2; 'cplex_direct', 'MILP', 119, 2;
    'cplex_direct', 'MILP', 106, -1; 'cplex_direct', 'MILP', 108, -1; 'cplex_direct', 'MILP', 110, -1;
    'cplex_direct', 'MILP', 112, -1; 'cplex_direct', 'MILP', 114, -1; 'cplex_direct', 'MILP', 117, -1;
    'cplex_direct', 'MILP', 999, 3; 'cplex_direct', 'MILP', 1, 3;      % default is 3 (not -1) for CPLEX MILP
    'tomlab_cplex', 'MILP', 101, 1; 'tomlab_cplex', 'MILP', 103, 0; 'tomlab_cplex', 'MILP', 118, 2;
    'tomlab_cplex', 'MILP', 106, -1; 'tomlab_cplex', 'MILP', 999, 3;
    % --- MILP gurobi_mex ---
    'gurobi_mex', 'MILP', 2, 1; 'gurobi_mex', 'MILP', 3, 0; 'gurobi_mex', 'MILP', 5, 2;
    'gurobi_mex', 'MILP', 4, 0; 'gurobi_mex', 'MILP', 999, -1;
    % --- MILP ibm_cplex (simplified codes 1/2/3 also mapped) ---
    'ibm_cplex', 'MILP', 101, 1; 'ibm_cplex', 'MILP', 102, 1; 'ibm_cplex', 'MILP', 1, 1;
    'ibm_cplex', 'MILP', 103, 0; 'ibm_cplex', 'MILP', 3, 0;
    'ibm_cplex', 'MILP', 118, 2; 'ibm_cplex', 'MILP', 119, 2; 'ibm_cplex', 'MILP', 2, 2;
    'ibm_cplex', 'MILP', 106, -1; 'ibm_cplex', 'MILP', 117, -1; 'ibm_cplex', 'MILP', 999, 3;
    % --- MILP gurobi (native string; INF_OR_UNBD -> 0, TIME_LIMIT -> 3) ---
    'gurobi', 'MILP', 'OPTIMAL', 1; 'gurobi', 'MILP', 'INFEASIBLE', 0; 'gurobi', 'MILP', 'UNBOUNDED', 2;
    'gurobi', 'MILP', 'INF_OR_UNBD', 0; 'gurobi', 'MILP', 'TIME_LIMIT', 3; 'gurobi', 'MILP', 'SUBOPTIMAL', -1;
    % --- MIQP tomlab_cplex (>= 10 -> -1; else -> 3) ---
    'tomlab_cplex', 'MIQP', 1, 1; 'tomlab_cplex', 'MIQP', 101, 1; 'tomlab_cplex', 'MIQP', 102, 1;
    'tomlab_cplex', 'MIQP', 3, 0; 'tomlab_cplex', 'MIQP', 4, 0; 'tomlab_cplex', 'MIQP', 103, 0;
    'tomlab_cplex', 'MIQP', 2, 2; 'tomlab_cplex', 'MIQP', 118, 2; 'tomlab_cplex', 'MIQP', 119, 2;
    'tomlab_cplex', 'MIQP', 106, -1; 'tomlab_cplex', 'MIQP', 117, -1;
    'tomlab_cplex', 'MIQP', 10, -1; 'tomlab_cplex', 'MIQP', 50, -1;
    'tomlab_cplex', 'MIQP', 0, 3; 'tomlab_cplex', 'MIQP', 5, 3; 'tomlab_cplex', 'MIQP', 9, 3;
    % --- MIQP gurobi_mex ---
    'gurobi_mex', 'MIQP', 2, 1; 'gurobi_mex', 'MIQP', 3, 0; 'gurobi_mex', 'MIQP', 5, 2;
    'gurobi_mex', 'MIQP', 4, 0; 'gurobi_mex', 'MIQP', 999, -1;
    % --- MIQP gurobi (native string; INF_OR_UNBD -> 0; no TIME_LIMIT special) ---
    'gurobi', 'MIQP', 'OPTIMAL', 1; 'gurobi', 'MIQP', 'INFEASIBLE', 0; 'gurobi', 'MIQP', 'UNBOUNDED', 2;
    'gurobi', 'MIQP', 'INF_OR_UNBD', 0; 'gurobi', 'MIQP', 'TIME_LIMIT', -1; 'gurobi', 'MIQP', 'SUBOPTIMAL', -1;
    % --- MIQP ibm_cplex ---
    'ibm_cplex', 'MIQP', 101, 1; 'ibm_cplex', 'MIQP', 1, 1; 'ibm_cplex', 'MIQP', 103, 0;
    'ibm_cplex', 'MIQP', 3, 0; 'ibm_cplex', 'MIQP', 118, 2; 'ibm_cplex', 'MIQP', 2, 2;
    'ibm_cplex', 'MIQP', 106, -1; 'ibm_cplex', 'MIQP', 999, 3;
    };

for i = 1:size(fixtures, 1)
    solverName = fixtures{i, 1};
    problemType = fixtures{i, 2};
    code = fixtures{i, 3};
    expected = fixtures{i, 4};
    stat = mapSolverStatus(solverName, problemType, code);
    assert(stat == expected, ...
        sprintf('mapSolverStatus(''%s'', ''%s'', %s) = %d, expected %d', ...
        solverName, problemType, num2str(code), stat, expected));
end

% -------------------------------------------------------------------------
% Guarded fallback: an out-of-table code for a KNOWN (solver, problemType) whose
% inline default was -1 returns -1 with NO throw.
% -------------------------------------------------------------------------
assert(mapSolverStatus('glpk', 'LP', 12345) == -1);
assert(mapSolverStatus('gurobi', 'LP', 'NO_SUCH_STATUS') == -1);
assert(mapSolverStatus('pdco', 'QP', 42) == -1);
assert(mapSolverStatus('gurobi_mex', 'MILP', 12345) == -1);

% -------------------------------------------------------------------------
% Bug B regression guard (pure): LP ibm_cplex native 101 must NOT be infeasible.
% -------------------------------------------------------------------------
assert(mapSolverStatus('ibm_cplex', 'LP', 101) ~= 0);
assert(mapSolverStatus('ibm_cplex', 'LP', 101) == -1);

% -------------------------------------------------------------------------
% Defined errors only: unknown solver / unknown problemType throw the two ids.
% -------------------------------------------------------------------------
threw = false;
try
    mapSolverStatus('someUnknownSolver', 'LP', 0);
catch ME
    threw = true;
    assert(strcmp(ME.identifier, 'COBRA:mapSolverStatus:unmappedSolver'));
end
assert(threw);

threw = false;
try
    mapSolverStatus('gurobi', 'MILP', 'someUnknownMilpSolverStatusButKnownSolver'); %#ok<*NASGU>
catch
    threw = true;
end
assert(~threw);   % a known solver with an out-of-table string still resolves (no throw)

threw = false;
try
    mapSolverStatus('someUnknownSolver', 'MIQP', 0);
catch ME
    threw = true;
    assert(strcmp(ME.identifier, 'COBRA:mapSolverStatus:unmappedSolver'));
end
assert(threw);

threw = false;
try
    mapSolverStatus('dqqMinos', 'ZZZ', 0);
catch ME
    threw = true;
    assert(strcmp(ME.identifier, 'COBRA:mapSolverStatus:unmappedProblemType'));
end
assert(threw);

% -------------------------------------------------------------------------
% Bug A regression guard (solver-backed): MIQP gurobi returns a NUMERIC .stat in
% {-1,0,1,2,3} and a STRING .origStat (they are not swapped). prepareTest-gated.
% -------------------------------------------------------------------------
solversMIQP = prepareTest('needsMIQP', true, 'requiredSolvers', {'gurobi'}, 'requireOneSolverOf', {'gurobi'});
if any(strcmp(solversMIQP.MIQP, 'gurobi'))
    changeCobraSolver('gurobi', 'MIQP', 0);

    % small feasible MIQP: min (x-2)^2 + (y-2)^2 s.t. x + y <= 3, x,y in {0,1,2,3}
    MIQPproblem = struct();
    MIQPproblem.A = sparse([1, 1]);
    MIQPproblem.b = 3;
    MIQPproblem.c = [-4; -4];
    MIQPproblem.F = 2 * speye(2);
    MIQPproblem.lb = [0; 0];
    MIQPproblem.ub = [3; 3];
    MIQPproblem.osense = 1;
    MIQPproblem.csense = 'L';
    MIQPproblem.vartype = ['I'; 'I'];
    MIQPproblem.x0 = [0; 0];

    sol = solveCobraMIQP(MIQPproblem);
    assert(isnumeric(sol.stat) && isscalar(sol.stat));      % Bug A: .stat is numeric scalar
    assert(ismember(sol.stat, [-1, 0, 1, 2, 3]));           % canonical value set
    assert(ischar(sol.origStat) || isstring(sol.origStat)); % Bug A: .origStat is the native string
    assert(sol.stat == 1);                                  % this MIQP is feasible/optimal
end

% change the directory back
cd(currentDir);
