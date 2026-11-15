% The COBRAToolbox: testMosekParamSetEFBA.m
%
% Purpose:
%     - mosekParamSetEFBA adds to (or overrides in) a parameter structure the twelve MOSEK
%       parameters used by entropic flux balance analysis and keeps every other field. The test
%       checks the exact field names and values against the values listed in the help text,
%       that unrelated fields are kept, that the twelve fields are overridden when present, and
%       that the function also works without an input. MOSEK itself is not called.
%
% Function under test:
%     src/base/solvers/entropicFBA/mosekParamSetEFBA.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built structures.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMosekParamSetEFBA'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the values listed under INPUT in the help text of mosekParamSetEFBA
expectedParam = struct( ...
    'MSK_IPAR_LOG_PRESOLVE', 1, ...
    'MSK_IPAR_INTPNT_SCALING', 'MSK_SCALING_FREE', ...
    'MSK_IPAR_INTPNT_REGULARIZATION_USE', 'MSK_OFF', ...
    'MSK_DPAR_INTPNT_CO_TOL_DFEAS', 1e-11, ...
    'MSK_DPAR_INTPNT_CO_TOL_PFEAS', 1e-11, ...
    'MSK_DPAR_INTPNT_CO_TOL_REL_GAP', 1e-11, ...
    'MSK_IPAR_INTPNT_MAX_ITERATIONS', 400, ...
    'MSK_IPAR_BI_IGNORE_MAX_ITER', 'MSK_OFF', ...
    'MSK_IPAR_INTPNT_SOLVE_FORM', 'MSK_SOLVE_FREE', ...
    'MSK_DPAR_INTPNT_TOL_INFEAS', 1e-8, ...
    'MSK_IPAR_LOG_INTPNT', 5, ...
    'MSK_IPAR_INFEAS_REPORT_AUTO', 'MSK_OFF', ...
    'MSK_IPAR_INFEAS_REPORT_LEVEL', 100);

%% an empty structure receives exactly the documented fields and values

param = mosekParamSetEFBA(struct());
% field names and values are compared exactly: the values are literal constants in the code
% (1e-11 and 1e-8 are the same double literals as above), so no tolerance is needed
assert(isequal(sort(fieldnames(param)), sort(fieldnames(expectedParam))));
assert(isequal(orderfields(param), orderfields(expectedParam)));

%% other fields are kept and the MOSEK fields are overridden

inputParam = struct('printLevel', 2, 'feasTol', 1e-6, ...
    'MSK_IPAR_LOG_INTPNT', 0, 'MSK_IPAR_INTPNT_SCALING', 'MSK_SCALING_NONE');
param = mosekParamSetEFBA(inputParam);
% the two unrelated fields are unchanged
assert(param.printLevel == 2);
assert(param.feasTol == 1e-6);
% the two MOSEK fields given in the input are replaced by the values of the function
assert(param.MSK_IPAR_LOG_INTPNT == 5);
assert(strcmp(param.MSK_IPAR_INTPNT_SCALING, 'MSK_SCALING_FREE'));
% no other field than the input fields and the documented MOSEK fields is present
assert(isequal(sort(fieldnames(param)), ...
    sort(union(fieldnames(expectedParam), {'printLevel'; 'feasTol'}))));

%% without an input the function returns the documented structure

param = mosekParamSetEFBA();
assert(isequal(orderfields(param), orderfields(expectedParam)));

% change the directory
cd(currentDir)
