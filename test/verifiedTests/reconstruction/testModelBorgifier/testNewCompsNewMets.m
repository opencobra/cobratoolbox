% The COBRAToolbox: testNewCompsNewMets.m
%
% Purpose:
%     - newCompsNewMets gives new indices to the metabolites of the candidate model that have no match and whose compartment does not exist in the template model.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/newCompsNewMets.m
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
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testNewCompsNewMets'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% template model: compartments [c] and [m]; candidate model: [c], [x] and [e]
templateModel.mets = {'x[c]'; 'y[c]'; 'z[m]'};
candidateModel.mets = {'a[c]'; 'b[x]'; 'd[e]'};

%% metabolites in new compartments get new indices after the template metabolites

% a[c] is in a known compartment (stays 0); b[x] and d[e] are numbered 4 and 5
assert(isequal(newCompsNewMets([0; 0; 0], candidateModel, templateModel), [0; 4; 5]));

%% numbering continues after the largest index already in the list

% the highest used index is 5, larger than the 3 template metabolites -> next index is 6
assert(isequal(newCompsNewMets([0; 5; 0], candidateModel, templateModel), [0; 5; 6]));

% an existing index smaller than the number of template metabolites does not change the start
assert(isequal(newCompsNewMets([2; 0; 0], candidateModel, templateModel), [2; 4; 5]));

%% all compartments known: nothing changes

knownOnly.mets = {'a[c]'};
assert(isequal(newCompsNewMets(0, knownOnly, templateModel), 0));

% change the directory
cd(currentDir)
