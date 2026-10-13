% The COBRAToolbox: testFindMetinOrgan.m
%
% Purpose:
%     - findMetinOrgan lists the metabolites of a whole-body model that carry a given metabolite
%     name after an organ prefix, and the organs in which they occur.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/findMetinOrgan.m
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
fileDir = fileparts(which('testFindMetinOrgan'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.mets = {'Liver_glc[c]'; 'Brain_glc[c]'; 'Liver_pyr[c]'; 'glc'};

%% organs holding the metabolite

[organListLong, organListOnly] = findMetinOrgan(model, 'glc');
% the plain name without an organ prefix does not match
assert(isequal(organListLong, {'Liver_glc[c]'; 'Brain_glc[c]'}));
% organ names, sorted alphabetically
assert(isequal(organListOnly, {'Brain'; 'Liver'}));

%% a metabolite that is not present

[organListLong, organListOnly] = findMetinOrgan(model, 'xyz');
assert(isempty(organListLong) && isempty(organListOnly));

% change the directory
cd(currentDir)
