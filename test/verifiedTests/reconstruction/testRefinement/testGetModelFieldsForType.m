% The COBRAToolbox: testGetModelFieldsForType.m
%
% Purpose:
%     - getModelFieldsForType lists the fields of a model that belong to a type (rxns, mets,
%       genes, comps, ctrs, evars, ...) with the dimension in which they match, from the field
%       definitions (getDefinedFieldProperties), the sizes of the fields and, when another type
%       has the same size, the field name prefix. This test checks the input validation, an
%       empty model (fieldSize 0), a one-reaction model, general models with a custom field,
%       the fieldSize option in both forms, rxnNotes, a reaction x reaction field, a model whose
%       reactions and metabolites have the same size, coupling constraints and extra variables.
%       The expected lists follow from the field definitions (S is mets x rxns, rxnGeneMat is
%       rxns x genes, lb/ub/c/rules/grRules/rxnNames/subSystems are reaction fields, b/csense/
%       metNames are metabolite fields).
%     - Quarantined: the body asserts nothing about the function (the checks above describe
%       the test written before the quarantine, kept for the lead).
%
% Function under test:
%     src/reconstruction/refinement/getModelFieldsForType.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation without a solver, hand-built models (createModel).
%
% Coverage exemptions:
%     every line - getModelFieldsForType is quarantined for the wrong-result defect(s)
%     below (feature 20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: custom fields named after the type are missed for a model with one or no
%       element of that type
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'R1'}, {'r1'}, {'a -> b'}); model.rxnCustom = {'z'};
%                getModelFieldsForType(model, 'rxns')
%       OBSERVED: MATLAB R2025a: rxnCustom is not in the result (S, rxnGeneMat, c, grRules, lb,
%                 rules, rxnNames, rxns, subSystems, ub), while the same model with two
%                 reactions lists it. Line 104 reads strncmp(x, type, length(type-1)): type-1
%                 subtracts one from each character code, so the length is that of the whole
%                 type name and the fields must start with 'rxns', not 'rxn' as the comment
%                 ("Remove the s from the type") and line 184 intend
%       EXPECTED: rxnCustom listed with dimension 1, as documented ("fields named e.g. rxnXYZ
%                 are associated with rxns") and as for two or more reactions
%       LINES: 104
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetModelFieldsForType'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
