% The COBRAToolbox: testColorRxnsFromGenes.m
%
% Purpose:
%     - colorRxnsFromGenes finds the reactions of the genes given as Entrez IDs (model gene
%       IDs are compared without their '.x' transcript suffix), and sets the colour
%       (createColorsMap code) and the line width of those reactions on a CellDesigner map
%       structure; when the map has reactant and product line fields, the non-empty secondary
%       lines of those reactions get the same colour and width. Quarantined: no behaviour of
%       colorRxnsFromGenes is asserted until the defect below is fixed.
%
% Function under test:
%     src/visualization/metabolicCartography/colorRxnsFromGenes.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model and map manipulation on hand-built structures, no solver, no figure.
%
% Coverage exemptions:
%     every line - colorRxnsFromGenes is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A gene list with no gene of the model stops with an error
%       SEVERITY: error
%       TRIGGER: model = struct('rxns', {{'R1'}}, 'genes', {{'10.1'}}, 'rules', {{'x(1)'}});
%         map = struct('rxnName', {{'R1'}}); colorRxnsFromGenes(map, model, {'99'})
%       OBSERVED: (R2025a, 2026-11-23) error "Input A of class cell and input B of class
%         double must be cell arrays of character vectors, unless one is a character vector."
%         raised by ismember at line 82: with no matching gene, globalList stays [] (line 67),
%         so rxnName = unique([]) is a double; the same call with {'10', '99'} returns the map
%         with R1 coloured
%       EXPECTED: the map returned unchanged, since no reaction is implicated by the given
%         genes
%       LINES: 67, 78, 82
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testColorRxnsFromGenes'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
