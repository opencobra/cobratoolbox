% The COBRAToolbox: testUniqueMetabolites.m
%
% Purpose:
%     - uniqueMetabolites removes every compartment tag '[...]' from the metabolite IDs of a
%       model and returns the sorted unique names. Expected values are written out by hand.
%
% Function under test:
%     src/visualization/metabolicCartography/uniqueMetabolites.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation on a hand-built model structure (mets only); no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testUniqueMetabolites'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% compartment tags are removed and the names made unique and sorted

% glc_D in two compartments counts once; h2o has no tag; every tag of x[c][m] is removed
% (the pattern is lazy, so each bracket pair is removed separately)
model.mets = {'glc_D[c]'; 'h2o'; 'glc_D[e]'; 'atp[c]'; 'x[c][m]'; 'h2o[e]'};
assert(isequal(uniqueMetabolites(model), {'atp'; 'glc_D'; 'h2o'; 'x'}));

%% names differing only in case stay distinct

model.mets = {'A[c]'; 'a[c]'};
assert(isequal(uniqueMetabolites(model), {'A'; 'a'}));

% change the directory
cd(currentDir)
