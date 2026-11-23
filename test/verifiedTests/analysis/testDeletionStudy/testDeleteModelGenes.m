% The COBRAToolbox: testDeleteModelGenes.m
%
% Purpose:
%     - deleteModelGenes marks the given genes as deleted (suffix '_deleted' on model.genes),
%       evaluates the gene-reaction rules of the reactions of those genes with every gene
%       marked '_deleted' set to false, and constrains the reactions whose rule becomes false:
%       bounds set to zero (full deletion) or scaled by downRegFraction. It returns the model,
%       hasEffect (true when at least one reaction was constrained), constrRxnNames (those
%       reactions) and deletedGenes (the requested genes). This test uses a hand-built model
%       with a single-gene rule, an AND rule (complex), an OR rule (isoenzymes), a gene in
%       several reactions, a reaction without a rule, a gene without reactions, and gene names
%       that are prefixes of others (g1 and g10). Every expected value is derived by hand from
%       the rules and the bounds.
%
% Function under test:
%     src/analysis/deletion/deleteModelGenes.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation (bounds, gene names) on a hand-built model, no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The error for several genes that are not in the model joins their names
%       SEVERITY: cosmetic
%       TRIGGER: deleteModelGenes(model, {'g8', 'g9'}) with neither gene in model.genes
%       OBSERVED: (R2025a, 2026-11-23) error "Gene g8g9 not in model!": the names of the
%         missing genes are concatenated without a separator
%       EXPECTED: the missing gene names listed separately (for example "Genes g8, g9 not in
%         model!")
%       LINES: 108
%     - DEFECT: Deleting a gene that is already marked deleted appends the suffix again
%       SEVERITY: cosmetic
%       TRIGGER: model = deleteModelGenes(model, 'g1'); model = deleteModelGenes(model, 'g1')
%       OBSERVED: (R2025a, 2026-11-23) model.genes{1} is 'g1_deleted_deleted' after the
%         second call; the constraints are the same as after the first call, because lines 66
%         and 84 strip or search every '_deleted'
%       EXPECTED: the gene name stays 'g1_deleted' ("appends '_deleted' to the gene(s)")
%       LINES: 77
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDeleteModelGenes'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% hand-built model: rules in the x(i) form, gene i = model.genes{i}
%   R1: g1               (single gene)
%   R2: g1 and g2        (complex: either gene deleted blocks it)
%   R3: g1 or g10        (isoenzymes: both must be deleted)
%   R4: g10              (g10 shares the prefix 'g1' with g1)
%   R5: no rule
%   R6: g2 or g3         (isoenzymes)
% g5 is in no reaction. The bounds differ per reaction so that scaling can be checked.
model = struct();
model.rxns = {'R1'; 'R2'; 'R3'; 'R4'; 'R5'; 'R6'};
model.genes = {'g1'; 'g2'; 'g10'; 'g3'; 'g5'};
model.rules = {'x(1)'; 'x(1) & x(2)'; 'x(1) | x(3)'; 'x(3)'; ''; 'x(2) | x(4)'};
model.lb = [-1000; 0; -10; 0; 0; -5];
model.ub = [1000; 100; 10; 50; 20; 5];

%% one gene given as a character vector: single-gene and AND rules are constrained

% g1 deleted: R1 (g1) and R2 (g1 and g2) become false; R3 stays true through g10, and g10
% (whose name starts with 'g1') is neither marked nor affected. Bounds are integers, so
% exact equality is used throughout.
[modelOut, hasEffect, constrRxnNames, deletedGenes] = deleteModelGenes(model, 'g1');
assert(isequal(modelOut.genes, {'g1_deleted'; 'g2'; 'g10'; 'g3'; 'g5'}));
assert(hasEffect == true);
assert(isequal(constrRxnNames, {'R1'; 'R2'}));
assert(isequal(deletedGenes, {'g1'}));
assert(isequal(modelOut.lb, [0; 0; -10; 0; 0; -5]));
assert(isequal(modelOut.ub, [0; 0; 10; 50; 20; 5]));
% the reaction-gene matrix was missing and is built (6 reactions x 5 genes, from the rules)
expectedRxnGeneMat = zeros(6, 5);
expectedRxnGeneMat(1, 1) = 1;
expectedRxnGeneMat(2, [1 2]) = 1;
expectedRxnGeneMat(3, [1 3]) = 1;
expectedRxnGeneMat(4, 3) = 1;
expectedRxnGeneMat(6, [2 4]) = 1;
assert(isequal(full(modelOut.rxnGeneMat) ~= 0, expectedRxnGeneMat ~= 0));
% nothing else is changed
assert(isequal(modelOut.rules, model.rules) && isequal(modelOut.rxns, model.rxns));

%% g10 alone: only its own reaction; g1 (a prefix of g10) is untouched

% R3 (g1 or g10) stays true through g1; R4 (g10) becomes false
[modelOut, hasEffect, constrRxnNames, deletedGenes] = deleteModelGenes(model, {'g10'});
assert(isequal(modelOut.genes, {'g1'; 'g2'; 'g10_deleted'; 'g3'; 'g5'}));
assert(hasEffect == true);
assert(isequal(constrRxnNames, {'R4'}));
assert(isequal(deletedGenes, {'g10'}));
assert(isequal(modelOut.lb, [-1000; 0; -10; 0; 0; -5]));
assert(isequal(modelOut.ub, [1000; 100; 10; 0; 20; 5]));

%% both isoenzymes of R3 deleted together: R1 to R4 are constrained

[modelOut, hasEffect, constrRxnNames, deletedGenes] = deleteModelGenes(model, {'g1', 'g10'});
assert(isequal(modelOut.genes, {'g1_deleted'; 'g2'; 'g10_deleted'; 'g3'; 'g5'}));
assert(hasEffect == true);
assert(isequal(constrRxnNames, {'R1'; 'R2'; 'R3'; 'R4'}));
assert(isequal(deletedGenes, {'g1', 'g10'}));
assert(isequal(modelOut.lb, [0; 0; 0; 0; 0; -5]));
assert(isequal(modelOut.ub, [0; 0; 0; 0; 20; 5]));

%% successive calls: a gene marked deleted earlier still counts as absent

% after g1 is deleted, deleting g10 also blocks R3 (g1 or g10), because the rules are
% evaluated with every gene marked '_deleted' set to false; the earlier marking is kept
modelStep = deleteModelGenes(model, 'g1');
[modelStep, hasEffect, constrRxnNames, deletedGenes] = deleteModelGenes(modelStep, 'g10');
assert(isequal(modelStep.genes, {'g1_deleted'; 'g2'; 'g10_deleted'; 'g3'; 'g5'}));
assert(hasEffect == true);
assert(isequal(constrRxnNames, {'R3'; 'R4'}));
assert(isequal(deletedGenes, {'g10'}));
assert(isequal(modelStep.lb, [0; 0; 0; 0; 0; -5]));
assert(isequal(modelStep.ub, [0; 0; 0; 0; 20; 5]));

%% a gene whose reactions keep an isoenzyme: marked, but no effect

% g3 appears only in R6 (g2 or g3), which stays true through g2: no reaction is constrained
[modelOut, hasEffect, constrRxnNames, deletedGenes] = deleteModelGenes(model, 'g3');
assert(isequal(modelOut.genes, {'g1'; 'g2'; 'g10'; 'g3_deleted'; 'g5'}));
assert(hasEffect == false);
assert(isempty(constrRxnNames) && iscell(constrRxnNames));
assert(isequal(deletedGenes, {'g3'}));
assert(isequal(modelOut.lb, model.lb) && isequal(modelOut.ub, model.ub));

%% a gene in no reaction: marked, no effect

[modelOut, hasEffect, constrRxnNames, deletedGenes] = deleteModelGenes(model, 'g5');
assert(isequal(modelOut.genes, {'g1'; 'g2'; 'g10'; 'g3'; 'g5_deleted'}));
assert(hasEffect == false);
assert(isempty(constrRxnNames));
assert(isequal(deletedGenes, {'g5'}));
assert(isequal(modelOut.lb, model.lb) && isequal(modelOut.ub, model.ub));

%% a gene in several reactions, including an isoenzyme pair

% g2 is in R2 (g1 and g2) and R6 (g2 or g3): only R2 becomes false
[modelOut, hasEffect, constrRxnNames] = deleteModelGenes(model, 'g2');
assert(hasEffect == true);
assert(isequal(constrRxnNames, {'R2'}));
assert(isequal(modelOut.ub, [1000; 0; 10; 50; 20; 5]));

%% default gene list: every gene is deleted

% all rules become false, so every reaction with a rule (R1-R4, R6) is constrained; R5 has
% no rule and keeps its bounds
[modelOut, hasEffect, constrRxnNames, deletedGenes] = deleteModelGenes(model);
assert(isequal(modelOut.genes, strcat(model.genes, '_deleted')));
assert(hasEffect == true);
assert(isequal(constrRxnNames, {'R1'; 'R2'; 'R3'; 'R4'; 'R6'}));
assert(isequal(deletedGenes, model.genes));
assert(isequal(modelOut.lb, [0; 0; 0; 0; 0; 0]));
assert(isequal(modelOut.ub, [0; 0; 0; 0; 20; 0]));

%% down-regulation: the bounds of the affected reactions are scaled by downRegFraction

% with fraction 0.5, R1-R4 keep half of their bounds (lb and ub separately); the halves are
% exact in binary floating point, so exact equality is used
[modelOut, hasEffect, constrRxnNames] = deleteModelGenes(model, {'g1', 'g10'}, 0.5);
assert(hasEffect == true);
assert(isequal(constrRxnNames, {'R1'; 'R2'; 'R3'; 'R4'}));
assert(isequal(modelOut.lb, [-500; 0; -5; 0; 0; -5]));
assert(isequal(modelOut.ub, [500; 50; 5; 25; 20; 5]));
assert(isequal(modelOut.genes, {'g1_deleted'; 'g2'; 'g10_deleted'; 'g3'; 'g5'}));

%% an existing rxnGeneMat is used as given, and a reaction listed there without a rule is skipped

% the given matrix links g5 to R5, which has no rule: the empty rule is not evaluated, so
% deleting g5 constrains nothing; the matrix is not rebuilt (the extra entry stays)
modelMat = model;
modelMat.rxnGeneMat = sparse(expectedRxnGeneMat);
modelMat.rxnGeneMat(5, 5) = 1;
[modelOut, hasEffect, constrRxnNames] = deleteModelGenes(modelMat, 'g5');
assert(hasEffect == false);
assert(isempty(constrRxnNames));
assert(isequal(modelOut.rxnGeneMat, modelMat.rxnGeneMat));
assert(isequal(modelOut.lb, model.lb) && isequal(modelOut.ub, model.ub));

%% errors raised by design

% a gene that is not in the model (one missing gene, so the message is not affected by the
% cosmetic defect in the header)
assert(verifyCobraFunctionError('deleteModelGenes', 'inputs', {model, {'g1', 'g8'}}, ...
    'testMessage', 'Gene g8 not in model!'));
% a gene name that only shares a prefix with model genes is not a match
assert(verifyCobraFunctionError('deleteModelGenes', 'inputs', {model, 'g'}, ...
    'testMessage', 'Gene g not in model!'));
% a model without genes
modelNoGenes = rmfield(model, 'genes');
assert(verifyCobraFunctionError('deleteModelGenes', 'inputs', {modelNoGenes, 'g1'}, ...
    'testMessage', 'Gene-reaction associations not included with the model'));

% change the directory
cd(currentDir)
