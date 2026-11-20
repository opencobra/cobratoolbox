% The COBRAToolbox: testGetDietComposition.m
%
% Purpose:
%     - getDietComposition(input, ...) returns the mass in grams of ten macro categories of a diet
%       given as metabolite fluxes, as USDA, Frida or BLS food items, or as a whole-body model
%       (struct) whose Food_EX_ bounds define the diet. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): the documented model
%       (struct) input is rejected by the input parser; no assertion about the function is made.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/getDietComposition.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would pass hand-built nutrient tables and load
%     hand-made database files of a fictitious edition from a tempname folder.
%
% Coverage exemptions:
%     every line - getDietComposition is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A whole-body model (struct) input is rejected
%       SEVERITY: error
%       TRIGGER: getDietComposition(struct('rxns', {{'Food_EX_x[d]'}}, 'lb', -1, 'ub', -1))
%       OBSERVED: (R2025a, 2026-11-15) error MATLAB:InputParser:ArgumentFailedValidation "The value
%         of 'input' is invalid. It must satisfy the function: iscell." - line 68 declares the
%         required input with @iscell, so the model branch (lines 98-111) is never reached
%       EXPECTED: the composition of the diet set by the model's Food_EX_ reactions, as the help
%         text documents "Either a whole-body metabolic model (struct) or a diet given as an
%         n x 2 cell array" and lines 98-111 handle a struct
%       LINES: 68, 98-111
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetDietComposition'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
