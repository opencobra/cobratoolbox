% The COBRAToolbox: testFindIntracellularRxns.m
%
% Purpose:
%     - findIntracellularRxns lists the reactions of a model whose formula does not contain an
%     extracellular metabolite (compartment [e]).
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/fastGapFill/AuxillaryFiles/findIntracellularRxns.m
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
fileDir = fileparts(which('testFindIntracellularRxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.mets = {'a[c]'; 'b[c]'; 'a[e]'};
model.rxns = {'conv'; 'trans'; 'EX_a'};
model.S = [-1  1  0; ...
            1  0  0; ...
            0 -1 -1];
model.lb = [0; 0; -10];
model.ub = [10; 10; 10];

%% reactions without extracellular metabolites

intracellular = findIntracellularRxns(model);
assert(isequal(intracellular, {'conv'}));

%% no extracellular metabolites

model.mets{3} = 'a[c]';
intracellular = findIntracellularRxns(model);
assert(isequal(intracellular, {'conv'; 'trans'; 'EX_a'}));

% change the directory
cd(currentDir)
