% The COBRAToolbox: testSetCplexParam.m
%
% Purpose:
%     - setCplexParam(LP, solverParams, verbFlag) copies the values of a user parameter
%       structure into the `.Cur` fields of LP.Param, matching each user parameter to an
%       LP.Param parameter by its last name (case-insensitive) when that name is unique, and
%       by its full path otherwise; a user value may be given directly or as `.Cur`.
%       Parameters that cannot be matched, or matched only ambiguously, are ignored with a
%       warning (no warning when verbFlag is false).
%     - The function only reads and writes LP.Param, so a hand-built structure with the layout
%       of Cplex().Param (parameter groups whose leaves hold Cur and Def) stands in for the
%       IBM ILOG CPLEX object; no CPLEX installation is needed. Expected values are the values
%       the test assigns: every matched `.Cur` equals the user value, everything else is
%       unchanged.
%
% Function under test:
%     src/base/solvers/cplex/setCplexParam.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a hand-built parameter structure replaces the Cplex object.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetCplexParam'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a stand-in for Cplex().Param: 'display' exists twice (simplex and barrier), every other
% parameter name once
initialLP.Param.threads = struct('Cur', 0, 'Def', 0);
initialLP.Param.simplex.display = struct('Cur', 1, 'Def', 1);
initialLP.Param.simplex.tolerances.optimality = struct('Cur', 1e-6, 'Def', 1e-6);
initialLP.Param.simplex.tolerances.feasibility = struct('Cur', 1e-6, 'Def', 1e-6);
initialLP.Param.barrier.display = struct('Cur', 1, 'Def', 1);
initialLP.Param.mip.tolerances.mipgap = struct('Cur', 1e-4, 'Def', 1e-4);

%% no user parameters: LP is returned unchanged

assert(isequal(setCplexParam(initialLP, struct()), initialLP));
assert(isequal(setCplexParam(initialLP, struct(), false), initialLP));

%% parameters with a unique name: matched by name, at any depth and in any case

solverParams = struct();
solverParams.threads = 4;                                   % same path as in LP.Param
solverParams.optimality = 1e-9;                             % name only, path differs
solverParams.simplex.tolerances.feasibility.Cur = 1e-8;     % value given as .Cur
solverParams.MIPGAP = 0.01;                                 % name in upper case
LP = setCplexParam(initialLP, solverParams);
% the values are copied, so equality is exact
expectedLP = initialLP;
expectedLP.Param.threads.Cur = 4;
expectedLP.Param.simplex.tolerances.optimality.Cur = 1e-9;
expectedLP.Param.simplex.tolerances.feasibility.Cur = 1e-8;
expectedLP.Param.mip.tolerances.mipgap.Cur = 0.01;
assert(isequal(LP, expectedLP));

%% an ambiguous name ('display') is matched by its full path

solverParams = struct();
solverParams.simplex.display = 0;
solverParams.barrier.display.Cur = 2;
LP = setCplexParam(initialLP, solverParams, true);
expectedLP = initialLP;
expectedLP.Param.simplex.display.Cur = 0;
expectedLP.Param.barrier.display.Cur = 2;
assert(isequal(LP, expectedLP));
% the path is compared in lower case
solverParams = struct();
solverParams.Simplex.Display = 3;
LP = setCplexParam(initialLP, solverParams);
assert(LP.Param.simplex.display.Cur == 3 && LP.Param.barrier.display.Cur == 1);

%% an ambiguous name without a matching path is ignored, with a warning if verbFlag is true

solverParams = struct('display', 0);
lastwarn('');
LP = setCplexParam(initialLP, solverParams);
assert(isequal(LP, initialLP));
assert(strcmp(lastwarn, '*.display cannot be uniquely identified as a valid cplex parameter. Ignore.'));
lastwarn('');
LP = setCplexParam(initialLP, solverParams, false);
assert(isequal(LP, initialLP) && isempty(lastwarn));

%% an unknown parameter is ignored, with a warning if verbFlag is true; the others are set

solverParams = struct('notAParameter', 1, 'threads', 2);
lastwarn('');
LP = setCplexParam(initialLP, solverParams);
assert(LP.Param.threads.Cur == 2 && ~isfield(LP.Param, 'notAParameter'));
assert(strcmp(lastwarn, '*.notAParameter cannot be identified as a valid cplex parameter. Ignore.'));
lastwarn('');
LP = setCplexParam(initialLP, solverParams, false);
assert(LP.Param.threads.Cur == 2 && ~isfield(LP.Param, 'notAParameter') && isempty(lastwarn));

% change the directory
cd(currentDir)
