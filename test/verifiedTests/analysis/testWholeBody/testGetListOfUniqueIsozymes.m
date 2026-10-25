% The COBRAToolbox: testGetListOfUniqueIsozymes.m
%
% Purpose:
%     - getListOfUniqueIsozymes collects the unique isozyme rules (gene rules joined by or) of the
%     genes of a model, with the genes of each rule sorted.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/getListOfUniqueIsozymes.m
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
fileDir = fileparts(which('testGetListOfUniqueIsozymes'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.genes = {'g1'; 'g2'; 'g3'};
model.rxns = {'r1'; 'r2'; 'r3'};

%% isozyme rules of the genes of a model

model.grRules = {'g2 or g1'; '(g1 or g2) and g3'; 'g3'};
listIsozymes = getListOfUniqueIsozymes(model);
% the genes of a rule are sorted ("g2 or g1" becomes "g1 or g2") and duplicates are removed;
% rules that also contain an and keep their brackets
assert(isequal(listIsozymes, {'(g1 or g2) and g3'; 'g1 or g2'}));

%% a model without isozymes gives an empty list

model.grRules = {'g1'; 'g2 and g3'; 'g3'};
listIsozymes = getListOfUniqueIsozymes(model);
assert(isempty(listIsozymes));

% change the directory
cd(currentDir)
