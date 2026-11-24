% The COBRAToolbox: testSteadyComCplex.m
%
% Purpose:
%     - SteadyComCplex finds the maximum community growth rate of a community model with the
%       SteadyCom algorithm, calling the IBM CPLEX Cplex class directly. Before it builds the
%       CPLEX problem it checks the community information (infoCom or indCom), reads the
%       options and the default CPLEX parameters, and stops with the identified error
%       COBRA:SteadyComCplex:requiresCplex when IBM CPLEX is not installed. The test checks
%       those steps on the two-organism community of testSteadyCom: the error for a model
%       without infoCom and indCom, and the requiresCplex error for a model with infoCom only
%       (indCom derived from it), with indCom, with and without options and CPLEX parameters.
%       To make the test independent of the machine, the global SOLVERS entry of ibm_cplex is
%       set to "not installed" for these calls and restored afterwards.
%
% Function under test:
%     src/analysis/multiSpecies/SteadyCom/subroutines/SteadyComCplex.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - the function needs IBM CPLEX; only its checks before the solver are reachable
%     here, on a hand-built two-organism community model (no solver is called).
%
% Coverage exemptions:
%     Lines 185-1165 (every executable line after line 182, including the local functions
%     constructLPcom, LP4fzero1, LP4fzero2 and ErrBecauseInfeas): need IBM CPLEX (the Cplex
%     class), which is not installed on the reference machine; the function has no path to
%     another solver.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSteadyComCplex'));
cd(fileDir);

% declare the requirements of this test. The reachable part calls no solver, MATLAB toolbox
% or system program, so none is listed; the call is the standard opening of a COBRA test and
% the place where a requirement (needsLP with ibm_cplex) would be added for the CPLEX part
globalsBefore = who('global');
prepareTest();

% the two-organism community of testSteadyCom: each organism lacks one of A2B and A2C
rxns = {'EX_a(e)'; 'EX_b(e)'; 'EX_c(e)'; 'TransA'; 'TransB'; 'TransC'; 'A2B'; 'A2C'; 'BIOMASS'};
rxnEqs = {'a[e] <=>'; 'b[e] <=>'; 'c[e] <=>'; ...
    'a[e] <=> a[c]'; 'b[e] <=> b[c]'; 'c[e] <=> c[c]'; ...
    'a[c] -> b[c]'; 'a[c] -> 0.5 c[c]'; '30 b[c] + 20 c[c] ->'};
model = createModel(rxns, rxns, rxnEqs, ...
    'lowerBoundList', [-1; 0; 0; -1000; -1000; -1000; 0; 0; 0], 'printLevel', 0);
org1 = changeRxnBounds(model, 'A2B', 0);
org2 = changeRxnBounds(model, 'A2C', 0);
modelJoint = createMultipleSpeciesModel({org1; org2}, 'nameTagsModels', {'Org1'; 'Org2'});
[modelJoint.infoCom, modelJoint.indCom] = getMultiSpeciesModelId(modelJoint, {'Org1'; 'Org2'});
% the biomass reactions of the organisms, as in testSteadyCom
modelJoint.infoCom.spBm = {'Org1BIOMASS'; 'Org2BIOMASS'};
modelJoint.indCom.spBm = findRxnIDs(modelJoint, modelJoint.infoCom.spBm);

% models with only one of the two community structures, and with neither
modelInfoOnly = rmfield(modelJoint, 'indCom');
modelNoInfo = rmfield(modelJoint, {'infoCom', 'indCom'});

% make the CPLEX check deterministic: the ibm_cplex entry of SOLVERS says "not installed"
global SOLVERS
savedSolvers = SOLVERS;
SOLVERS.ibm_cplex.installed = false;

%% neither infoCom nor indCom: the documented error (lines 130-134)
assert(verifyCobraFunctionError('SteadyComCplex', 'inputs', {modelNoInfo}, ...
    'testMessage', 'SteadyComCplex: *.infoCom or *.indCom must be provided.\n'));

% an infoCom without the required fields is rejected the same way
modelBadInfo = modelNoInfo;
modelBadInfo.infoCom = struct('spBm', {modelJoint.infoCom.spBm});
assert(verifyCobraFunctionError('SteadyComCplex', 'inputs', {modelBadInfo}, ...
    'testMessage', 'SteadyComCplex: *.infoCom or *.indCom must be provided.\n'));

%% infoCom only: indCom is derived (line 136), the default options and CPLEX parameters are
% read (lines 141, 146), and without CPLEX the identified error is raised (line 181)
try
    SteadyComCplex(modelInfoOnly);
    error('testSteadyComCplex:noError', 'SteadyComCplex did not stop without CPLEX');
catch ME
    assert(strcmp(ME.identifier, 'COBRA:SteadyComCplex:requiresCplex'), ...
        sprintf('unexpected error %s: %s (%s line %d)', ME.identifier, ME.message, ...
        ME.stack(1).file, ME.stack(1).line));
end

%% indCom given, verbose options and a non-empty CPLEX parameter structure: the progress
% message of line 170 is printed before the same identified error
options = struct('verbFlag', 1, 'GRguess', 0.1);
cplexParams = struct('simplex', struct('display', 0));
try
    SteadyComCplex(modelJoint, options, cplexParams);
    error('testSteadyComCplex:noError', 'SteadyComCplex did not stop without CPLEX');
catch ME
    assert(strcmp(ME.identifier, 'COBRA:SteadyComCplex:requiresCplex'), ...
        sprintf('unexpected error %s: %s (%s line %d)', ME.identifier, ME.message, ...
        ME.stack(1).file, ME.stack(1).line));
end

%% empty options and an empty parameter structure fall back to the defaults (lines 140-146);
% an empty SOLVERS (toolbox not initialised) is treated as "CPLEX not installed" (line 180)
SOLVERS = [];
try
    SteadyComCplex(modelJoint, [], struct());
    error('testSteadyComCplex:noError', 'SteadyComCplex did not stop without CPLEX');
catch ME
    assert(strcmp(ME.identifier, 'COBRA:SteadyComCplex:requiresCplex'), ...
        sprintf('unexpected error %s: %s (%s line %d)', ME.identifier, ME.message, ...
        ME.stack(1).file, ME.stack(1).line));
end

% restore the solver registry and remove the globals created by this test
SOLVERS = savedSolvers;
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clear('global', newGlobals{:});
end

% change the directory
cd(currentDir)
