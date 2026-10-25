% The COBRAToolbox: testMosekParamStrip.m
%
% Purpose:
%     - mosekParamStrip keeps only the fields of a parameter structure whose name contains MSK_ and
%     copies a COBRA time limit into the MOSEK time limit parameter.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/mosek/mosekParamStrip.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMosekParamStrip'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% non-MOSEK fields are removed

params = struct('MSK_IPAR_LOG', 0, 'feasTol', 1e-9, 'MSK_DPAR_INTPNT_TOL_PFEAS', 1e-8);
stripped = mosekParamStrip(params);
assert(isequal(sort(fieldnames(stripped)), {'MSK_DPAR_INTPNT_TOL_PFEAS'; 'MSK_IPAR_LOG'}));
assert(stripped.MSK_IPAR_LOG == 0 && stripped.MSK_DPAR_INTPNT_TOL_PFEAS == 1e-8);

%% the COBRA time limit becomes the MOSEK time limit

stripped = mosekParamStrip(struct('timelimit', 30, 'other', 1));
assert(isequal(fieldnames(stripped), {'MSK_DPAR_OPTIMIZER_MAX_TIME'}));
assert(stripped.MSK_DPAR_OPTIMIZER_MAX_TIME == 30);

%% the time limit overwrites an existing MOSEK value

stripped = mosekParamStrip(struct('timelimit', 30, 'MSK_DPAR_OPTIMIZER_MAX_TIME', 5));
assert(stripped.MSK_DPAR_OPTIMIZER_MAX_TIME == 30);

%% no MOSEK field

stripped = mosekParamStrip(struct('a', 1));
assert(isempty(fieldnames(stripped)));

% change the directory
cd(currentDir)
