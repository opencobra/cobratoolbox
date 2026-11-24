% The COBRAToolbox: testChangeGeneAssociation.m
%
% Purpose:
%     - changeGeneAssociation(model, rxnName, grRule, geneNameList, systNameList,
%       addRxnGeneMat) replaces the gene-reaction rule of a reaction (rules, grRules,
%       rxnGeneMat) and appends the genes of the rule that are not in the model. The function
%       is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): the other
%       gene fields are not extended for new genes, the name translation assigns wrong
%       systematic names or stops, and a requested rxnGeneMat gets the wrong number of rows;
%       no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/refinement/changeGeneAssociation.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a small hand-built model (createModel), no solver.
%
% Coverage exemptions:
%     every line - changeGeneAssociation is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: New genes do not extend the other gene fields
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'R1','R2','R3'}, {'','',''}, {'a[c] -> b[c]',
%         'b[c] -> c[c]', 'c[c] -> '}, 'grRuleList', {'g1','',''}, 'printLevel', 0);
%         model.proteins = {'P1'}; model2 = changeGeneAssociation(model, 'R2', 'g2')
%       OBSERVED: (R2025a, 2026-11-23) numel(model2.genes) = 2 but numel(model2.proteins) = 1
%         (likewise geneNames): nGenes is never updated after the new genes are appended
%         (line 74), so the test nGenes > nGenesInit of line 88 is always false and
%         extendModelFieldsForType (line 89) never runs
%       EXPECTED: model2.proteins = {'P1'; 'COBRAProtein2'} (the field default), every gene
%         field as long as model2.genes
%       LINES: 57-58, 88-90
%     - DEFECT: Translated gene names are taken from the wrong positions
%       SEVERITY: wrong-result
%       TRIGGER: model as above; changeGeneAssociation(model, 'R2', 'a and b', {'b'; 'a'},
%         {'B'; 'A'}); changeGeneAssociation(model, 'R2', 'a', {'x'; 'a'}, {'X'; 'A'})
%       OBSERVED: (R2025a, 2026-11-23) first call: genes {'g1'; 'B'; 'A'} and grRules{2} =
%         'B and A' (gene a is named B); second call: "Index exceeds the number of array
%         elements. Index must not exceed 1." at line 72, which indexes the presence vector
%         pres with the list positions pos (systNameList(pres(pos)) instead of
%         systNameList(pos(pres)))
%       EXPECTED: grRules{2} = 'A and B' and genes {'g1'; 'A'; 'B'}; genes {'g1'; 'A'} and
%         grRules{2} = 'A'
%       LINES: 71-72
%     - DEFECT: A requested rxnGeneMat is created with one row per reaction up to the changed one
%       SEVERITY: wrong-result
%       TRIGGER: model as above without rxnGeneMat (rmfield); changeGeneAssociation(model,
%         'R1', 'g2', [], [], true)
%       OBSERVED: (R2025a, 2026-11-23) size(rxnGeneMat) = [1 2]: line 66 creates the field by
%         assigning row rxnID only
%       EXPECTED: size [3 2] (reactions x genes) with the entries of R1 set
%       LINES: 66, 81
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testChangeGeneAssociation'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
