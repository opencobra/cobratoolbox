% The COBRAToolbox: testIntegrateGeneExpressionData.m
%
% Purpose:
%     - integrateGeneExpressionData(model, dataGenes) takes a numeric vector of absent genes
%       (Entrez numbers), finds the transcripts of model.genes whose part before the first '.'
%       is one of these numbers, and deletes them with deleteModelGenes (bounds of the
%       reactions whose rule becomes false set to zero, '_deleted' appended to the
%       transcripts). The function is QUARANTINED (Constitution III-Defects, quarantine in
%       back-fill campaigns): it stops with an error when no absent gene is in the model,
%       including an empty list of absent genes; no assertion about the function is made.
%
% Function under test:
%     src/dataIntegration/metabotools/integrateGeneExpressionData.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation (gene deletion on a hand-built model), no solver.
%
% Coverage exemptions:
%     every line - integrateGeneExpressionData is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A list of absent genes none of which is in the model stops with an error
%       SEVERITY: error
%       TRIGGER: model = createModel({'R1'; 'R2'}, {'R1'; 'R2'}, {' -> A'; 'A -> '},
%         'grRuleList', {''; '535.1'}); integrateGeneExpressionData(model, 99) (the same
%         with dataGenes = [] or [99; 98])
%       OBSERVED: (R2025a, 2026-11-23) MATLAB:UndefinedFunction "Unrecognized function or
%         variable 'ExpressionData'.": the structure ExpressionData is created only inside
%         the loop when a transcript matches, and is read unconditionally by the
%         deleteModelGenes call
%       EXPECTED: the model returned unchanged (no gene to constrain)
%       LINES: 40
%     - DEFECT: A gene identifier that is not a number stops the call for two or more absent genes
%       SEVERITY: limitation
%       TRIGGER: model = createModel({'R1'; 'R2'; 'R3'}, {'R1'; 'R2'; 'R3'}, {' -> A';
%         'A -> B'; 'B -> '}, 'grRuleList', {''; '535.1'; 'b0001'});
%         integrateGeneExpressionData(model, [535; 7])
%       OBSERVED: (R2025a, 2026-11-23) MATLAB:sizeDimensionsMustMatch "Arrays have
%         incompatible sizes for this operation.": str2num('b0001') is empty and
%         dataGenes == [] has incompatible sizes for a non-scalar dataGenes (with a scalar
%         dataGenes the non-numeric gene is skipped and the call succeeds)
%       EXPECTED: the non-numeric gene skipped, as for a scalar dataGenes
%       LINES: 28
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIntegrateGeneExpressionData'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so nothing calls it;
% a Tier 2 test needs no solver, MATLAB toolbox or particular operating system, and the call
% is the standard opening of a COBRA test
prepareTest();

% change the directory
cd(currentDir)
