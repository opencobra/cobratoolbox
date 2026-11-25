% The COBRAToolbox: testChangeGeneAssociation.m
%
% Purpose:
%     - changeGeneAssociation(model, rxnName, grRule, geneNameList, systNameList,
%       addRxnGeneMat) replaces the gene-reaction rule of one reaction (rules, grRules and,
%       when present or requested, the reaction's row of rxnGeneMat), appends the genes of
%       the rule that are not in the model and extends every other gene field (proteins,
%       geneNames, ...) with its default for them. Given geneNameList and systNameList, the
%       gene names of the rule are translated (common name -> systematic name) before they
%       are looked up in model.genes. The test uses a hand-built three-reaction model with
%       one gene and checks existing and new genes, and/or rules with nested parentheses,
%       the translation lists, rxnGeneMat present, absent and requested, models without
%       genes, rules or grRules, an empty rule, and the error for an unknown reaction.
%
% Function under test:
%     src/reconstruction/refinement/changeGeneAssociation.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; a hand-built model (createModel).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A requested rxnGeneMat that the model lacks marks the genes of the changed reaction only
%       SEVERITY: wrong-result
%       TRIGGER: m = createModel({'R1','R2','R3'}, {'','',''}, {'a[c] -> b[c]', 'b[c] -> c[c]',
%         'c[c] -> '}, 'grRuleList', {'g1','',''}, 'printLevel', 0); m = rmfield(m, 'rxnGeneMat');
%         m2 = changeGeneAssociation(m, 'R2', 'g2', [], [], true)
%       OBSERVED: (R2025a, 2026-11-25) full(m2.rxnGeneMat) = [0 0; 0 1; 0 0]: the row of R1 is
%         empty although its rule is g1; the matrix is created empty (line 85) and only the
%         row of the changed reaction is filled (lines 87, 106-109). No caller in src requests
%         a rxnGeneMat for a model without one. The input is skipped below: the test requests
%         rxnGeneMat only on models whose other reactions have no rule.
%       EXPECTED: every reaction's row marks the genes of its rule (reactions x genes, as
%         buildRxnGeneMat builds it)
%       LINES: 82-87, 106-109
%     - DEFECT: The help gives true as the default of addRxnGeneMat
%       SEVERITY: cosmetic
%       TRIGGER: changeGeneAssociation(model, rxnName, grRule) on a model without rxnGeneMat
%       OBSERVED: (R2025a, 2026-11-25) no rxnGeneMat is created: the default is true only when
%         the model already has rxnGeneMat, false otherwise (lines 56-62)
%       EXPECTED: the help states the default as the code applies it
%       LINES: 22, 56-62
%
%     (The three defects recorded on 2026-11-23 - new genes did not extend the other gene
%     fields, translated gene names were taken from the wrong positions, and a requested
%     rxnGeneMat was created with one row per reaction up to the changed one - were fixed by
%     feature 20261125-161147-blocker-fixes-two and are tested below.)
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.
%     - Full test after the fix (feature 20261125-161147-blocker-fixes-two), 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testChangeGeneAssociation'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% three reactions, one gene g1 on R1, and two further gene fields:
%     R1: a -> b   (g1)
%     R2: b -> c   (no rule)
%     R3: c ->     (no rule)
model = createModel({'R1', 'R2', 'R3'}, {'', '', ''}, {'a[c] -> b[c]', 'b[c] -> c[c]', 'c[c] -> '}, ...
    'grRuleList', {'g1', '', ''}, 'printLevel', 0);
model.proteins = {'P1'};
model.geneNames = {'gene one'};
assert(isequal(model.genes, {'g1'}) && isequal(size(model.rxnGeneMat), [3, 1]));

%% an existing gene: no gene is added, the rule refers to it

model2 = changeGeneAssociation(model, 'R2', 'g1');
% the gene fields are unchanged, the rule of R2 is x(1), and rxnGeneMat marks g1 for R1 and R2
assert(isequal(model2.genes, {'g1'}) && isequal(model2.proteins, {'P1'}) && isequal(model2.geneNames, {'gene one'}));
assert(isequal(model2.rules, {'x(1)'; 'x(1)'; ''}) && isequal(model2.grRules, {'g1'; 'g1'; ''}));
assert(isequal(full(model2.rxnGeneMat), [1; 1; 0]));
assertGeneFieldsConsistent(model2);
% the reactions and the stoichiometry are untouched
assert(isequal(model2.rxns, model.rxns) && isequal(model2.mets, model.mets) && isequal(model2.S, model.S));
assert(isequal(model2.lb, model.lb) && isequal(model2.ub, model.ub));

%% new genes in an and/or rule extend every gene field

model2 = changeGeneAssociation(model, 'R2', '(g3 or g1) and g2');
% the new genes are appended in sorted order; the rule refers to the positions in model.genes
assert(isequal(model2.genes, {'g1'; 'g2'; 'g3'}));
assert(isequal(model2.rules{2}, '( x(3) | x(1) ) & x(2)'));
assert(isequal(model2.grRules, {'g1'; '( g3 or g1 ) and g2'; ''}));
% the other gene fields get their defaults for the new genes (proteins COBRAProtein<i>,
% geneNames the gene identifier) and keep their values for g1
assert(isequal(model2.proteins, {'P1'; 'COBRAProtein2'; 'COBRAProtein3'}));
assert(isequal(model2.geneNames, {'gene one'; 'g2'; 'g3'}));
% rxnGeneMat is reactions x genes and marks the genes of each rule
assert(isequal(full(model2.rxnGeneMat), [1 0 0; 1 1 1; 0 0 0]));
assertGeneFieldsConsistent(model2);
assert(isequal(model2.rxns, model.rxns) && isequal(model2.S, model.S));

% nested parentheses on a further reaction, starting from a model with three genes: g1 and g3
% are reused, g4 and g5 are added
model3 = changeGeneAssociation(model2, 'R3', 'g4 or (g1 and (g3 or g5))');
assert(isequal(model3.genes, {'g1'; 'g2'; 'g3'; 'g4'; 'g5'}));
% (the spacing around the parentheses is the one parseGPR writes)
assert(isequal(model3.rules{3}, 'x(4) | ( x(1) & ( x(3) | x(5) ))'));
assert(isequal(model3.grRules{3}, 'g4 or ( g1 and ( g3 or g5 ))'));
assert(isequal(model3.proteins, {'P1'; 'COBRAProtein2'; 'COBRAProtein3'; 'COBRAProtein4'; 'COBRAProtein5'}));
assert(isequal(full(model3.rxnGeneMat(3, :)), [1 0 1 1 1]));
% the rules of R1 and R2 are kept
assert(isequal(model3.rules(1:2), model2.rules(1:2)));
assertGeneFieldsConsistent(model3);

% replacing a rule with an existing association: R1 changes from g1 to g2
model3 = changeGeneAssociation(model2, 'R1', 'g2');
assert(isequal(model3.genes, model2.genes) && isequal(model3.grRules{1}, 'g2'));
assert(isequal(full(model3.rxnGeneMat(1, :)), [0 1 0]));
assertGeneFieldsConsistent(model3);

%% an empty rule removes the association

model2 = changeGeneAssociation(model, 'R1', '');
% the gene stays in the model, the reaction has no rule and no gene in rxnGeneMat
assert(isequal(model2.genes, {'g1'}) && isequal(model2.rules, {''; ''; ''}) && isequal(model2.grRules, {''; ''; ''}));
assert(nnz(model2.rxnGeneMat) == 0);
assertGeneFieldsConsistent(model2);

%% translation lists (common name -> systematic name)

% each gene is translated by its own position in the lists (the first recorded trigger:
% a -> A, b -> B, given in reverse order)
model2 = changeGeneAssociation(model, 'R2', 'a and b', {'b'; 'a'}, {'B'; 'A'});
assert(isequal(model2.genes, {'g1'; 'A'; 'B'}) && isequal(model2.grRules{2}, 'A and B'));
assert(isequal(model2.rules{2}, 'x(2) & x(3)'));
assert(isequal(model2.proteins, {'P1'; 'COBRAProtein2'; 'COBRAProtein3'}));
assertGeneFieldsConsistent(model2);

% a list in which the gene is not first (the second recorded trigger)
model2 = changeGeneAssociation(model, 'R2', 'a', {'x'; 'a'}, {'X'; 'A'});
assert(isequal(model2.genes, {'g1'; 'A'}) && isequal(model2.grRules{2}, 'A'));
assertGeneFieldsConsistent(model2);

% a gene name that is not in the list is kept unchanged
model2 = changeGeneAssociation(model, 'R2', 'a or c', {'a'}, {'A'});
assert(isequal(model2.genes, {'g1'; 'A'; 'c'}) && isequal(model2.grRules{2}, 'A or c'));
assertGeneFieldsConsistent(model2);

% a translated name that is already in the model is reused, not added twice
model2 = changeGeneAssociation(model, 'R2', 'one and z', {'one'}, {'g1'});
assert(isequal(model2.genes, {'g1'; 'z'}) && isequal(model2.rules{2}, 'x(1) & x(2)'));
assert(isequal(model2.grRules{2}, 'g1 and z'));
assertGeneFieldsConsistent(model2);

% the translation comes before the look-up: a name equal to a model gene is translated too
model2 = changeGeneAssociation(model, 'R2', 'g1', {'g1'}, {'G1'});
assert(isequal(model2.genes, {'g1'; 'G1'}) && isequal(model2.rules{2}, 'x(2)'));
assertGeneFieldsConsistent(model2);

% gene names with '.', '_' and '-', row lists, and a name that is part of another name
% (b is translated, b.1 is not in the list)
model2 = changeGeneAssociation(model, 'R2', '(b0001.1 or gene_2-a) and b', {'gene_2-a', 'b'}, {'YAL_001-c.2', 'B'});
assert(isequal(model2.genes, {'g1'; 'B'; 'YAL_001-c.2'; 'b0001.1'}));
assert(isequal(model2.grRules{2}, '( b0001.1 or YAL_001-c.2 ) and B'));
assertGeneFieldsConsistent(model2);

% an empty rule with translation lists removes the association
model2 = changeGeneAssociation(model, 'R1', '', {'a'}, {'A'});
assert(isequal(model2.genes, {'g1'}) && isequal(model2.grRules, {''; ''; ''}));

% without systNameList, the names are not translated
model2 = changeGeneAssociation(model, 'R2', 'a', {'a'}, {});
assert(isequal(model2.genes, {'g1'; 'a'}) && isequal(model2.grRules{2}, 'a'));
assertGeneFieldsConsistent(model2);

%% rxnGeneMat: absent, requested, or not updated

modelNoMat = rmfield(model, 'rxnGeneMat');

% absent and not requested (the default): it is not created; the other gene fields are extended
model2 = changeGeneAssociation(modelNoMat, 'R2', 'g2');
assert(~isfield(model2, 'rxnGeneMat'));
assert(isequal(model2.genes, {'g1'; 'g2'}) && isequal(model2.proteins, {'P1'; 'COBRAProtein2'}));
assertGeneFieldsConsistent(model2);

% absent and requested (the third recorded trigger): created as reactions x genes, with the
% genes of the changed reaction marked (R2 and R3 have no rule)
model2 = changeGeneAssociation(modelNoMat, 'R1', 'g2', [], [], true);
assert(isequal(size(model2.rxnGeneMat), [3, 2]));
assert(isequal(full(model2.rxnGeneMat), [0 1; 0 0; 0 0]));
assertGeneFieldsConsistent(model2);

% requested without a new gene
model2 = changeGeneAssociation(modelNoMat, 'R1', 'g1', [], [], true);
assert(isequal(full(model2.rxnGeneMat), [1; 0; 0]));

% present but not to be updated (addRxnGeneMat false): the row is left as it was, the
% matrix still gets one column per gene
model2 = changeGeneAssociation(model, 'R2', 'g2', [], [], false);
assert(isequal(size(model2.rxnGeneMat), [3, 2]) && isequal(full(model2.rxnGeneMat(1, :)), [1 0]));
assert(isequal(model2.proteins, {'P1'; 'COBRAProtein2'}));

%% a model without genes, rules or grRules

% no genes field and no rules or grRules: the genes and rules are created
modelNoGenes = rmfield(model, {'genes', 'rules', 'grRules', 'rxnGeneMat', 'proteins', 'geneNames'});
model2 = changeGeneAssociation(modelNoGenes, 'R1', 'g1 or g2');
assert(isequal(model2.genes, {'g1'; 'g2'}) && isequal(model2.rules, {'x(1) | x(2)'; ''; ''}));
assert(isequal(model2.grRules, {'g1 or g2'; ''; ''}) && ~isfield(model2, 'rxnGeneMat'));
% with rxnGeneMat requested, it is reactions x genes
model2 = changeGeneAssociation(modelNoGenes, 'R1', 'g1 or g2', [], [], true);
assert(isequal(full(model2.rxnGeneMat), [1 1; 0 0; 0 0]));
assertGeneFieldsConsistent(model2);
% an empty rule on a model without genes adds no gene
model2 = changeGeneAssociation(modelNoGenes, 'R1', '');
assert(isempty(model2.genes) && isequal(model2.grRules, {''; ''; ''}));

% rules missing, grRules present: the rules are generated from grRules first, so R1 keeps g1
model2 = changeGeneAssociation(rmfield(model, 'rules'), 'R2', 'g2');
assert(isequal(model2.rules, {'x(1)'; 'x(2)'; ''}) && isequal(model2.grRules, {'g1'; 'g2'; ''}));
assertGeneFieldsConsistent(model2);

% genes present, rules and grRules missing: every reaction starts without a rule
model2 = changeGeneAssociation(rmfield(model, {'rules', 'grRules'}), 'R2', 'g1');
assert(isequal(model2.rules, {''; 'x(1)'; ''}) && isequal(model2.grRules, {''; 'g1'; ''}));
assert(isequal(model2.genes, {'g1'}));

%% error: a reaction that is not in the model

assert(verifyCobraFunctionError('changeGeneAssociation', 'inputs', {model, 'R9', 'g1'}, ...
    'testMessage', 'Reaction R9 not in the model'));

% change the directory
cd(currentDir)

function assertGeneFieldsConsistent(model)
% every gene field has one entry per gene, rules and grRules one per reaction, rxnGeneMat
% (when present) is reactions x genes and marks exactly the genes that each rule refers to,
% and grRules is the rules written with the gene names
nGenes = numel(model.genes);
nRxns = numel(model.rxns);
geneFields = intersect(fieldnames(model), {'proteins', 'geneNames'});
for i = 1:numel(geneFields)
    assert(numel(model.(geneFields{i})) == nGenes);
end
assert(numel(model.rules) == nRxns && numel(model.grRules) == nRxns);
expectedGrRules = strrep(strrep(model.rules, '&', 'and'), '|', 'or');
expectedGrRules = regexprep(expectedGrRules, 'x\(([0-9]+)\)', '${model.genes{str2double($1)}}');
assert(isequal(model.grRules, expectedGrRules));
if isfield(model, 'rxnGeneMat')
    assert(isequal(size(model.rxnGeneMat), [nRxns, nGenes]));
    for j = 1:nRxns
        geneIdx = cellfun(@str2double, regexp(model.rules{j}, '(?<=x\()[0-9]+(?=\))', 'match'));
        expectedRow = false(1, nGenes);
        expectedRow(geneIdx) = true;
        assert(isequal(full(model.rxnGeneMat(j, :) ~= 0), expectedRow));
    end
end
end
