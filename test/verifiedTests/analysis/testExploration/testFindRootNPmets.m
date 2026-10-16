% The COBRAToolbox: testFindRootNPmets.m
%
% Purpose:
%     - findRootNPmets finds the root no-production metabolites of a model (metabolites that are
%     only consumed by irreversible reactions) and, optionally, the root no-consumption metabolites.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/exploration/findRootNPmets.m
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
fileDir = fileparts(which('testFindRootNPmets'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a chain a -> b -> c <-> d with a reversible third reaction
model.mets = {'a'; 'b'; 'c'; 'd'};
model.lb = [0; 0; -10];
%                 r1  r2  r3
model.S = [-1  0  0; ... % a is only consumed
            1 -1  0; ... % b is produced then consumed
            0  1 -1; ... % c is produced by r2 and consumed by r3
            0  0  1];    % d is produced by r3, which is reversible

%% root no-production metabolites

% a is consumed but never produced and its only reaction is irreversible; d is produced
gaps = findRootNPmets(model);
assert(isequal(gaps, {'a'}));

%% the reversible reaction removes a metabolite from the root set

% a metabolite that is only consumed but takes part in a reversible reaction is not a root
model2 = model;
model2.S = [-1 0 0; 0 -1 0; 0 1 -1; 0 0 -1];
% a and b are only consumed by irreversible reactions; d is only consumed but r3 is reversible
gaps = findRootNPmets(model2);
assert(isequal(gaps, {'a'; 'b'}));

%% root no-consumption metabolites as well

% in the original model nothing is root no-consumption (d takes part in the reversible r3)
gaps = findRootNPmets(model, true);
assert(isequal(gaps, {'a'}));
% make r3 irreversible: d is now produced only and never consumed
model3 = model;
model3.lb(3) = 0;
gaps = findRootNPmets(model3, true);
assert(isequal(gaps, {'a'; 'd'}));
% with the flag off only the no-production roots are returned
gaps = findRootNPmets(model3, false);
assert(isequal(gaps, {'a'}));

% change the directory
cd(currentDir)
