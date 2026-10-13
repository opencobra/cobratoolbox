% The COBRAToolbox: testCompareMatricies.m
%
% Purpose:
%     - compareMatricies sorts two models by reaction and metabolite IDs and returns the difference
%     of the absolute stoichiometric coefficients, ignoring the rows of protons and water.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/compareMatricies.m
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
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareMatricies'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% two models with the same network written in different orders
modelA.rxnID = {'r2'; 'r1'};
modelA.metID = {'h2o[c]'; 'a[c]'; 'h[c]'};
modelA.S = [1 0; 1 1; 0 -1];
modelB.rxnID = {'r1'; 'r2'};
modelB.metID = {'a[c]'; 'h[c]'; 'h2o[c]'};
modelB.S = [1 1; -1 0; 0 -1];

%% the same network in a different order: no difference after sorting

result = compareMatricies(modelA, modelB);
assert(isequal(result.CrxnsSort, {'r1'; 'r2'}) && isequal(result.CmetsSort, {'a[c]'; 'h2o[c]'; 'h[c]'}));
assert(isequal(result.CmodelS, [1 1; 0 1; -1 0]));
assert(isequal(result.CspawnS, [1 1; 0 -1; -1 0]));
% the sign of a coefficient does not matter: only the absolute values are compared
assert(isequal(result.diffS, zeros(3, 2)));

%% a difference in an ordinary metabolite is reported

changedB = modelB;
changedB.S(1, 1) = 3;                          % a[c] in r1
result = compareMatricies(modelA, changedB);
assert(isequal(result.diffS, [-2 0; 0 0; 0 0]));

%% protons and water are ignored, in any of their spellings

protonModelA = modelA;
protonModelA.metID = {'proton[c]'; 'a[c]'; 'h+[c]'};
protonModelB = modelB;
protonModelB.metID = {'a[c]'; 'h+[c]'; 'water[c]'};
protonModelB.S(2, 2) = -5;                     % a different coefficient for the proton row
result = compareMatricies(protonModelA, protonModelB);
assert(isequal(result.diffS, zeros(3, 2)));

%% matrices of different sizes: the comparison is not made

% (3 x 2 against 2 x 2: the sizes cannot be combined)
result = compareMatricies(modelA, struct('rxnID', {{'r1'; 'r2'}}, 'metID', {{'a[c]'; 'h[c]'}}, 'S', [1 1; 0 1]));
assert(~isfield(result, 'diffS'));

% change the directory
cd(currentDir)
