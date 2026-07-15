% The COBRAToolbox: testMapSolverStatus.m
%
% Purpose:
%     - Unit test for the consolidated mapSolverStatus helper (feature
%       009-fba-characterization-statusmap, W2). It pins the native->canonical
%       status map exactly. This is the guard for the status-map consolidation on
%       solvers that the CI net does not exercise (e.g. DQQ/quadMinos), since the
%       helper is solver-independent and needs no solver installed.
%
% Authors:
%     - Generated for feature 009-fba-characterization-statusmap, 2026-07-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMapSolverStatus'));
cd(fileDir);

% Expected DQQ / quadMinos LP map, transcribed from solveCobraLP.m: {inform, stat, text}
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

% both solver aliases share the same LP map
for solverName = {'dqqMinos', 'quadMinos'}
    for i = 1:size(dqq, 1)
        [stat, origStatText] = mapSolverStatus(solverName{1}, 'LP', dqq{i, 1});
        assert(stat == dqq{i, 2});
        assert(strcmp(origStatText, dqq{i, 3}));
    end
end

% problemType is accepted case-insensitively (upper-cased internally)
[statLower, ~] = mapSolverStatus('dqqMinos', 'lp', 0);
assert(statLower == 1);

% CPLEX-family QP status map, transcribed from solveCobraQP.m: {origStat, stat}
qpCplex = {1,  1;    % optimal
           2,  2;    % unbounded
           3,  0;    % infeasible
           4,  2;    % unbounded
           5,  3;    % numerical / not proven optimal
           6,  3;    % numerical / not proven optimal
           0, -1;    % other
          10, -1;    % other (>= 10)
          99, -1};   % other
for solverName = {'tomlab_cplex', 'tomlab_cplex_tomRun', 'ibm_cplex'}
    for i = 1:size(qpCplex, 1)
        stat = mapSolverStatus(solverName{1}, 'QP', qpCplex{i, 1});
        assert(stat == qpCplex{i, 2});
    end
end

% fail loud (no silent status) on an unmapped solver or problem type
errored = false;
try
    mapSolverStatus('someUnknownSolver', 'LP', 0);
catch
    errored = true;
end
assert(errored);

errored = false;
try
    mapSolverStatus('dqqMinos', 'ZZZ', 0);
catch
    errored = true;
end
assert(errored);

% change the directory back
cd(currentDir);
