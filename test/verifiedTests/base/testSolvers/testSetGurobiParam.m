% The COBRAToolbox: testSetGurobiParam.m
%
% Purpose:
%     - setGurobiParam(param) turns a COBRA-style solver parameter structure into the
%       parameter structure of Gurobi's MATLAB interface: timelimit, multiscale, lifted,
%       method, lpmethod and qpmethod are translated to TimeLimit, ScaleFlag, Aggregate and
%       Presolve, and Method; OutputFlag (0) and DisplayInterval (1) are set when absent;
%       FeasibilityTol and OptimalityTol are taken from feasTol and optTol when absent; and
%       every field that is not a Gurobi parameter name is removed. The test checks each
%       translation against the values written in the help and the code (the Gurobi method
%       codes -1 to 4), that the documented optional fields can be left out, that TimeLimit
%       wins over timelimit, the warnings for unknown method names, and the filtering. No
%       solver is called.
%
% Function under test:
%     src/base/solvers/gurobi/setGurobiParam.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; parameter structures written by hand.
%
% Coverage exemptions:
%     Line 419: unreachable. Lines 418-419 remove a field logFile, but the filter just before
%     keeps only Gurobi parameter names (LogFile, not logFile), so logFile is never present.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found. (The three defects recorded on 2026-11-15, the documented optional fields
%     printLevel, feasTol and optTol being required, timelimit overriding TimeLimit, and the
%     lpmethod warning naming qpmethod, were fixed by feature
%     20261120-161825-core-blocker-fixes and are tested below.)
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Full test after the fix (feature 20261120-161825-core-blocker-fixes), 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetGurobiParam'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% every field is optional: an empty structure gives only the two output settings

gurobiParam = setGurobiParam(struct());
assert(isequal(gurobiParam, struct('OutputFlag', 0, 'DisplayInterval', 1)));

%% the COBRA fields of solveCobraLP: tolerances translated, COBRA names removed

cobraParam = struct('printLevel', 2, 'feasTol', 1e-7, 'optTol', 1e-8, 'timeLimit', 1e36, ...
    'problemType', 'LP', 'saveInput', [], 'logFile', []);
gurobiParam = setGurobiParam(cobraParam);
assert(isequal(orderfields(gurobiParam), orderfields(struct('OutputFlag', 0, 'DisplayInterval', 1, ...
    'FeasibilityTol', 1e-7, 'OptimalityTol', 1e-8))));
% the output settings are the same for every printLevel
for printLevel = [0, 1, 3]
    gurobiParam = setGurobiParam(struct('printLevel', printLevel));
    assert(gurobiParam.OutputFlag == 0 && gurobiParam.DisplayInterval == 1);
end
% Gurobi-style values already given are kept
gurobiParam = setGurobiParam(struct('OutputFlag', 1, 'DisplayInterval', 5, 'FeasibilityTol', 1e-9, ...
    'OptimalityTol', 1e-9, 'feasTol', 1e-3, 'optTol', 1e-3));
assert(isequal([gurobiParam.OutputFlag, gurobiParam.DisplayInterval, gurobiParam.FeasibilityTol, ...
    gurobiParam.OptimalityTol], [1, 5, 1e-9, 1e-9]));

%% timelimit is copied to TimeLimit only when TimeLimit is absent

gurobiParam = setGurobiParam(struct('timelimit', 10));
assert(gurobiParam.TimeLimit == 10 && ~isfield(gurobiParam, 'timelimit'));
gurobiParam = setGurobiParam(struct('timelimit', 10, 'TimeLimit', 20));
assert(gurobiParam.TimeLimit == 20);

%% multiscale and lifted

gurobiParam = setGurobiParam(struct('multiscale', 1));
assert(gurobiParam.ScaleFlag == 0 && ~isfield(gurobiParam, 'multiscale'));
gurobiParam = setGurobiParam(struct('multiscale', 0));
assert(~isfield(gurobiParam, 'ScaleFlag'));
gurobiParam = setGurobiParam(struct('lifted', 1));
assert(gurobiParam.Aggregate == 1 && gurobiParam.Presolve == 0 && ~isfield(gurobiParam, 'lifted'));
gurobiParam = setGurobiParam(struct('lifted', 0));
assert(~isfield(gurobiParam, 'Aggregate') && ~isfield(gurobiParam, 'Presolve'));

%% lpmethod and qpmethod: the names of the help, translated to the Gurobi method codes

lpNames = {'AUTOMATIC', 'PRIMAL', 'DUAL', 'BARRIER', 'CONCURRENT', 'DETERMINISTIC_CONCURRENT'};
for k = 1:numel(lpNames)
    gurobiParam = setGurobiParam(struct('lpmethod', lpNames{k}));
    assert(gurobiParam.Method == k - 2 && ~isfield(gurobiParam, 'lpmethod'));
end
qpNames = {'AUTOMATIC', 'PRIMAL', 'DUAL', 'BARRIER'};
for k = 1:numel(qpNames)
    gurobiParam = setGurobiParam(struct('qpmethod', qpNames{k}));
    assert(gurobiParam.Method == k - 2 && ~isfield(gurobiParam, 'qpmethod'));
end
% an unknown name: a warning naming the field it came from, and no Method
lastwarn('');
gurobiParam = setGurobiParam(struct('lpmethod', 'FOO'));
assert(strcmp(lastwarn, 'FOO is an unrecognised param.lpmethod for gurobi') && ~isfield(gurobiParam, 'Method'));
lastwarn('');
gurobiParam = setGurobiParam(struct('qpmethod', 'CONCURRENT'));
assert(strcmp(lastwarn, 'CONCURRENT is an unrecognised param.qpmethod for gurobi') && ~isfield(gurobiParam, 'Method'));

%% method (backward compatible): copied to lpmethod or qpmethod by problemType, unless given

gurobiParam = setGurobiParam(struct('method', 'DUAL', 'problemType', 'LP'));
assert(gurobiParam.Method == 1);
gurobiParam = setGurobiParam(struct('method', 'BARRIER', 'problemType', 'QP'));
assert(gurobiParam.Method == 2);
% an explicit lpmethod wins over method
gurobiParam = setGurobiParam(struct('method', 'DUAL', 'lpmethod', 'PRIMAL', 'problemType', 'LP'));
assert(gurobiParam.Method == 0);
% an empty method is removed and nothing is set
gurobiParam = setGurobiParam(struct('method', '', 'problemType', 'LP'));
assert(~isfield(gurobiParam, 'Method') && ~isfield(gurobiParam, 'method'));

%% only Gurobi parameter names are kept

gurobiParam = setGurobiParam(struct('Threads', 2, 'MIPGap', 1e-4, 'notAGurobiName', 1, 'Seed', 7));
assert(isequal(orderfields(gurobiParam), orderfields(struct('Threads', 2, 'MIPGap', 1e-4, 'Seed', 7, ...
    'OutputFlag', 0, 'DisplayInterval', 1))));

% change the directory
cd(currentDir)
