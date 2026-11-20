% The COBRAToolbox: testAddMetInfoInCBmodel.m
%
% Purpose:
%     - addMetInfoInCBmodel reads a table of metabolite identifiers (KEGG, HMDB, ChEBI,
%       PubChem, SMILES, InChI) and writes them into the matching metabolite fields of a COBRA
%       model, filling empty entries or replacing existing ones. Quarantined: no behaviour of
%       addMetInfoInCBmodel is asserted until the defects below are fixed.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/metabolites/addMetInfoInCBmodel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation on a createModel toy model and a table written to a
%     tempname folder, no solver.
%
% Coverage exemptions:
%     every line - addMetInfoInCBmodel is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: replace = true stops with an error for every matched metabolite
%       SEVERITY: unusable-option
%       TRIGGER: addMetInfoInCBmodel(model, csvFile, true) with model.mets = {'a[c]'; 'b[c]'}
%         and a csv file with columns mets, KEGG and rows a, C00001 / b, C00002
%       OBSERVED: error "Conversion to cell from char is not possible." - line 88 assigns the
%         character identifier to the cell field with () instead of {}
%       EXPECTED: the existing identifiers replaced (help text: replace "If the new ID should
%         replace an existing ID")
%       LINES: 88
%     - DEFECT: A struct as inputData stops with an error
%       SEVERITY: unusable-option
%       TRIGGER: addMetInfoInCBmodel(model, struct('mets', {{'a'}}, 'KEGG', {{'C00001'}}))
%       OBSERVED: error "Input path must be text." raised by isfile at line 29; line 32 would
%         pass the struct to readtable, which also accepts only a file name
%       EXPECTED: the struct data integrated (help text: inputData "External file (path) or
%         struct with the metabolite data to integrate")
%       LINES: 29-32
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddMetInfoInCBmodel'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
