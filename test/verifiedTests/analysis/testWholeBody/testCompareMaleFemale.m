% The COBRAToolbox: testCompareMaleFemale.m
%
% Purpose:
%     - compareMaleFemale compares the reactions of a male and a female whole-body model: reactions only in one of them, in both, per organ counts, gall-bladder subsystems and biofluid exchanges.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/compareMaleFemale.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found. (The function uses the old strmatch function.)
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareMaleFemale'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% two tiny models; reaction names start with the organ ("Gall_", "Liver_")
male = struct('rxns', {{'Liver_a'; 'Gall_b'; 'Gall_EX_c'; 'Liver_d'}}, 'subSystems', {{'x'; 'y'; 'y'; 'x'}});
female = struct('rxns', {{'Liver_a'; 'Gall_c'; 'Gall_EX_d'; 'Gall_e'}}, 'subSystems', {{'x'; 'z'; 'z'; 'w'}});

results = compareMaleFemale(male, female);

%% reactions only in one model, or in both (sorted)

assert(isequal(results.MaleOnly, {'Gall_EX_c'; 'Gall_b'; 'Liver_d'}));
assert(isequal(results.FemaleOnly, {'Gall_EX_d'; 'Gall_c'; 'Gall_e'}));
assert(isequal(results.BothGender, {'Liver_a'}));

%% per organ counts: [reactions in the organ, of which sex specific, fraction]

assert(isequal(results.maleOrgans, {'Gall'; 'Liver'}));
assert(isequal(results.femaleOrgans, {'Gall'; 'Liver'}));
assert(isequal(results.OrgansNumRxnMale, [2 2 1; 2 1 0.5]));
assert(isequal(results.OrgansNumRxnFemale, [3 3 1; 1 0 0]));

%% subsystems of the gall-bladder specific reactions, with counts as text

assert(isequal(results.FemaleGallSSEnrich, {'w', '1'; 'z', '2'}));
assert(isequal(results.MaleGallSSEnrich, {'y', '2'}));

%% sex specific biofluid (exchange) reactions

assert(isequal(results.MaleOnlyBiofluid, {'Gall_EX_c'}));
assert(isequal(results.FemaleOnlyBiofluid, {'Gall_EX_d'}));

% change the directory
cd(currentDir)
