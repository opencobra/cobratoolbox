% The COBRAToolbox: testExtractElementalTransitionNetwork.m
%
% Purpose:
%     - extractElementalTransitionNetwork extracts the part of an atom transition network that
%     involves the given elements.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/fluxomics/atomTransition/ATN/extractElementalTransitionNetwork.m
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
fileDir = fileparts(which('testExtractElementalTransitionNetwork'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a network of four nodes (two carbon, two nitrogen) and three transitions
ATN.A = [1 0 1; ...
         0 1 0; ...
         0 0 1; ...
         1 0 0];
ATN.mets = {'m1'; 'm2'; 'm3'; 'm4'};
ATN.rxns = {'t1'; 't2'; 't3'};
ATN.elements = {'C'; 'C'; 'N'; 'N'};
ATN.inputBool = [true; false; false; true];
ATN.outputBool = [false; true; true; false];
ATN.reverseBool = [false; false; true];

%% carbon network

ETN = extractElementalTransitionNetwork(ATN, {'C'});
% rows of the two carbon nodes; columns with at least one of their entries
assert(isequal(ETN.A, [1 0 1; 0 1 0]));
assert(isequal(ETN.mets, {'m1'; 'm2'}) && isequal(ETN.rxns, {'t1'; 't2'; 't3'}));
assert(isequal(ETN.elements, {'C'; 'C'}));
assert(isequal(ETN.inputBool, [true; false]) && isequal(ETN.outputBool, [false; true]));
assert(isequal(ETN.reverseBool, [false; false; true]));

%% nitrogen network drops the transitions that do not involve nitrogen

ETN = extractElementalTransitionNetwork(ATN, 'N');
assert(isequal(ETN.A, [0 1; 1 0]));
assert(isequal(ETN.rxns, {'t1'; 't3'}) && isequal(ETN.reverseBool, [false; true]));
assert(isequal(ETN.mets, {'m3'; 'm4'}));

% change the directory
cd(currentDir)
