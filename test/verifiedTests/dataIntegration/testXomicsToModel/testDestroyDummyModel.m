% The COBRAToolbox: testDestroyDummyModel.m
%
% Purpose:
%     - destroyDummyModel removes the dummy metabolites and reactions added for the one-reaction-
%     per-active-gene formulation from a model, in every model field that depends on them.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/XomicsToModel/oneRxnPerActiveGene/destroyDummyModel.m
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
fileDir = fileparts(which('testDestroyDummyModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a model with one dummy metabolite and one dummy reaction and many optional fields
base.mets = {'a'; 'dummy_Met_1'; 'b'};
base.rxns = {'r1'; 'dummy_Rxn_1'};
base.S = [1 0; 0 1; 1 0];
base.b = zeros(3, 1);
base.rxnNames = {'x'; 'y'};
base.lb = [0; 0];
base.ub = [1; 1];
base.c = [0; 0];

%% default detection of dummy metabolites and reactions by name

out = destroyDummyModel(base);
assert(isequal(out.mets, {'a'; 'b'}) && isequal(out.rxns, {'r1'}));
assert(isequal(out.S, [1; 1]) && isequal(out.b, [0; 0]));
assert(isequal(out.rxnNames, {'x'}) && out.lb == 0 && out.ub == 1 && out.c == 0);

%% optional fields are reduced as well

full = base;
full.csense = ['E'; 'E'; 'L'];
full.rxnGeneMat = sparse([1 0; 0 1]);
full.rules = {'x(1)'; ''};
full.subSystems = {'s1'; 's2'};
full.SIntMetBool = [true; false; true];
full.SIntRxnBool = [true; false];
full.SConsistentMetBool = true(3, 1);
full.SConsistentRxnBool = true(2, 1);
full.fluxConsistentMetBool = true(3, 1);
full.fluxConsistentRxnBool = true(2, 1);
full.thermoFluxConsistentMetBool = true(3, 1);
full.thermoFluxConsistentRxnBool = true(2, 1);
full.dummyMetBool = [false; true; false];
full.dummyRxnBool = [false; true];
out = destroyDummyModel(full);
assert(isequal(out.csense, ['E'; 'L']));
assert(isequal(size(out.rxnGeneMat), [1 2]) && isequal(out.rules, {'x(1)'}) && isequal(out.subSystems, {'s1'}));
assert(isequal(out.SIntMetBool, [true; true]) && isequal(out.SIntRxnBool, true));
assert(isequal(out.SConsistentMetBool, true(2, 1)) && isequal(out.SConsistentRxnBool, true));
assert(isequal(out.fluxConsistentMetBool, true(2, 1)) && isequal(out.fluxConsistentRxnBool, true));
assert(isequal(out.thermoFluxConsistentMetBool, true(2, 1)) && isequal(out.thermoFluxConsistentRxnBool, true));
% the helper fields are removed
assert(~isfield(out, 'dummyMetBool') && ~isfield(out, 'dummyRxnBool'));

%% coupling constraints lose the columns of the dummy reactions

coupled = base;
coupled.C = sparse([1 1]);
coupled.ctrs = {'c1'};
out = destroyDummyModel(coupled);
assert(isequal(size(out.C), [1 1]));

%% explicit logical vectors

out = destroyDummyModel(base, [false; true; false], [false; true]);
assert(isequal(out.mets, {'a'; 'b'}) && isequal(out.rxns, {'r1'}));

%% a model without dummies is unchanged

clean = base;
clean.mets = {'a'; 'b'; 'c'};
clean.rxns = {'r1'; 'r2'};
clean.S = zeros(3, 2);
clean.b = zeros(3, 1);
assert(isequal(destroyDummyModel(clean), clean));

%% consistency check against the original lists

% matching lists give no warning
lastwarn('');
destroyDummyModel(base, [], [], {'a'; 'b'}, {'r1'});
assert(isempty(lastwarn));
% lists that differ from the result make the function warn and trim the fields to them
mismatch = base;
mismatch.mets = {'a'; 'b'; 'c'};
mismatch.rxns = {'r1'; 'r2'};
mismatch.S = zeros(3, 2);
destroyDummyModel(mismatch, [], [], {'a'; 'b'; 'x'}, {'r1'; 'r3'});
assert(contains(lastwarn, 'mets/rxns were not consistently deleted in all fields!'));

% change the directory
cd(currentDir)
