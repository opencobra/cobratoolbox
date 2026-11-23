% The COBRAToolbox: testCPLEXParamSet.m
%
% Purpose:
%     - CPLEXParamSet(interface) returns a template of CPLEX control parameters: for
%       'tomlab_cplex' (the default) a structure of 23 parameters with the values written in the
%       source (and its comments), checked one by one here; for 'ILOGcomplex' the default values
%       of all parameters of a Cplex object, or [] when ibm_cplex cannot be selected.
%
% Function under test:
%     src/base/solvers/cplex/CPLEXParamSet.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - no model; the 'ILOGcomplex' branch selects the ibm_cplex solver with
%     changeCobraSolver. No requirement is declared: the 'tomlab_cplex' template needs no
%     solver, and the 'ILOGcomplex' branch is checked whether or not ibm_cplex is installed.
%
% Coverage exemptions:
%     Lines 253-262: need IBM ILOG CPLEX (ibm_cplex), not installed on the reference machine,
%         where changeCobraSolver('ibm_cplex') returns false.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCPLEXParamSet'));
cd(fileDir);

% declare the requirements of this test. None is listed: the 'tomlab_cplex' template needs no
% solver and the 'ILOGcomplex' branch is checked with or without ibm_cplex
prepareTest();

% the solver state may be changed by changeCobraSolver below; note the globals that exist now to
% remove new ones at the end, and save the state to restore it
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();

% the values written in the source, parameter by parameter
expected = struct('AGGIND', -1, 'BARCOLNZ', 0, 'BAREPCOMP', 1e-8, 'BARITLIM', 2000, ...
    'BARMAXCOR', -1, 'BAROBJRNG', 1e21, 'COEREDIND', 2, 'CUTLO', -1e76, 'DATACHECK', 1, ...
    'EPMRK', 0.01, 'EPOPT', 1e-6, 'EPPER', 1e-6, 'EPRELAX', 1e-6, 'EPRHS', 1e-6, ...
    'FEASOPTMODE', 0, 'ITLIM', 5000, 'LPMETHOD', 4, 'NUMERICALEMPHASIS', 0, 'POLISHTIME', 0, ...
    'SCAIND', 0, 'SIMDISPLAY', 1, 'CLOCKTYPE', 1, 'TILIM', 600);

%% the TOMLAB template, by default and by name
% the values are constants of the source, so the comparison is exact
cpxControl = CPLEXParamSet();
assert(isequal(sort(fieldnames(cpxControl)), sort(fieldnames(expected))));
names = fieldnames(expected);
for k = 1:numel(names)
    assert(isequal(cpxControl.(names{k}), expected.(names{k})));
end
assert(isequal(CPLEXParamSet('tomlab_cplex'), cpxControl));

%% the ILOG template: [] without ibm_cplex, the default parameter values with it
% changeCobraSolver('ibm_cplex') warns and returns false when CPLEX is not installed
global SOLVERS
cpxControl = CPLEXParamSet('ILOGcomplex');
if isfield(SOLVERS, 'ibm_cplex') && SOLVERS.ibm_cplex.installed
    assert(isstruct(cpxControl) && ~isempty(fieldnames(cpxControl)));
else
    assert(isempty(cpxControl));
end

% restore the solver state and remove the globals created by the test
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clearvars('-global', newGlobals{k});
end

% change the directory
cd(currentDir)
