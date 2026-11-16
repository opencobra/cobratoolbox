% The COBRAToolbox: testAnnotateModel.m
%
% Purpose:
%     - annotateModel fills the reaction and metabolite annotation fields of a model (EC
%       numbers, database identifiers, SBO terms, names, formulas, charges) from the VMH
%       reaction and metabolite tables, and sets the model identifier, name and annotation. A
%       test would check the SBO terms of biomass, exchange, demand, sink and transport
%       reactions and the metabolite fields on a small hand-built model.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       the reaction SBO terms are wrong for every model with an exchange reaction (first
%       defect below), so this file makes no assertion about the function.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/annotateModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - annotation of a small hand-built model, no solver.
%
% Coverage exemptions:
%     every line - annotateModel is quarantined for the defects below
%     (feature 20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: every non-transport reaction gets the exchange SBO term when any reaction is an exchange
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'EX_a', 'PGI', 'biomass'}, {'', '', ''}, {'a <=> ', 'a -> b',
%       'b -> '}); model.subSystems = {''; ''; ''}; out = annotateModel(model, 0, 0)
%       OBSERVED: MATLAB R2025a: out.rxnSBOTerms = {'SBO:0000628'; 'SBO:0000628'; 'SBO:0000628'};
%       lines 167 and 169 test strfind on the whole list model.rxns instead of model.rxns{i},
%       so the loop of lines 164-174 overwrites every reaction, including the biomass term
%       SBO:0000629 set at line 155
%       EXPECTED: SBO:0000629 for biomass (line 155) and the exchange term only for EX_a; PGI is
%       not an exchange reaction
%       LINES: 164-174
%     - DEFECT: modelID without modelName stops the call
%       SEVERITY: error
%       TRIGGER: annotateModel(model, 0, 0, 'myID') with the model above
%       OBSERVED: MATLAB R2025a: "Not enough input arguments." at line 67; line 66 tests
%       exist('modelID') instead of exist('modelName') before reading modelName
%       EXPECTED: model.modelID = 'myID' and modelName left out (both are documented as optional)
%       LINES: 66-67
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAnnotateModel'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
