% The COBRAToolbox: testGeneReactionMILP.m
%
% Purpose:
%     - geneReactionMILP turns the Boolean terms of the gene-protein-reaction rules (as produced
%       by readGeneRules) into the matrices of a mixed-integer linear program over binary
%       variables: one variable per gene, internal term and repressible reaction, two inequality
%       rows per and/or term (output = AND/OR of its inputs) and one equality row per equal term;
%       genes and internal terms have the objective weight 1. It only BUILDS the problem; no
%       solver is called.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the term and nonzero counts of iAF1260 asserted below were recorded from
%       the first run on 2026-11-03 with iAF1260 (no solver). They were not derived independently,
%       so they guard consistency, not independent correctness (Tier 5). The matrices of the
%       hand-built example are derived by hand, and the logic of both problems is checked
%       independently by evaluating the Boolean terms for given gene states.
%     - iAF1260 is used because readGeneRules, which builds the input terms, stops with an error
%       on the gene rules of ecoli_core_model and of the AGORA models; iAF1260 is the smallest
%       distributed model it accepts. The hand-built example uses the first three genes of
%       iAF1260.
%
% Function under test:
%     src/design/TrimGdel/geneReactionMILP.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; iAF1260 loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGeneReactionMILP'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (2382 reactions, 1668 metabolites, 1261 genes)
model = getDistributedModel('iAF1260.mat');

%% a hand-built example with one and, one or and one equal term

% three genes; term_1 = g1 and g2, reactionKO_1 = term_1 or g3, reactionKO_2 = g3
toyModel.genes = model.genes(1:3);
g = toyModel.genes;
term = struct('output', {'term_1', 'reactionKO_1', 'reactionKO_2'}, ...
    'function', {'and', 'or', 'equal'}, ...
    'input', {{g{1}; g{2}}, {'term_1'; g{3}}, {g{3}}});
[f, A, b, Aeq, beq, lb, ub, xname] = geneReactionMILP(toyModel, term, 3, 1, 2, 2);

% the variables are the genes, then the term outputs; genes and the internal term are weighted
assert(isequal(xname, [g; {'term_1'; 'reactionKO_1'; 'reactionKO_2'}]));
assert(isequal(f, [1; 1; 1; 1; 0; 0]));
assert(isequal(lb, zeros(6, 1)) && isequal(ub, ones(6, 1)));

% the rows derived by hand (columns g1 g2 g3 term_1 reactionKO_1 reactionKO_2):
% and:  2*term_1 - g1 - g2 <= 0 and -term_1 + g1 + g2 <= 1
% or:  -2*reactionKO_1 + term_1 + g3 <= 0 and reactionKO_1 - term_1 - g3 <= 0
% equal: reactionKO_2 - g3 = 0
assert(isequal(A, [-1 -1  0  2  0 0; ...
                    1  1  0 -1  0 0; ...
                    0  0  1  1 -2 0; ...
                    0  0 -1 -1  1 0]));
assert(isequal(b, [0; 1; 0; 0]));
assert(isequal(Aeq, [0 0 -1 0 0 1]) && isequal(beq, 0));

% for every binary state of the three genes, exactly one binary state of the terms is feasible,
% and it is the value of the Boolean terms
for state = 0:7
    genes = bitget(state, 1:3)';
    feasible = false(8, 1);
    for termState = 0:7
        x = [genes; bitget(termState, 1:3)'];
        feasible(termState + 1) = all(A * x <= b) && all(Aeq * x == beq);
    end
    expectedTerms = [genes(1) && genes(2); (genes(1) && genes(2)) || genes(3); genes(3)];
    assert(isequal(find(feasible) - 1, expectedTerms' * [1; 2; 4]));
end

%% the gene rules of iAF1260

[term, ng, nt, nr, nko] = readGeneRules(model);
[f, A, b, Aeq, beq, lb, ub, xname] = geneReactionMILP(model, term, ng, nt, nr, nko);

% Tier-5 reference (first run, 2026-11-03): the numbers of genes, internal terms and repressible
% reactions, and of and, or and equal terms
termFunctions = arrayfun(@(t) char(t.function), term, 'UniformOutput', false);
nAnd = sum(strcmp(termFunctions, 'and'));
nOr = sum(strcmp(termFunctions, 'or'));
nEqual = sum(strcmp(termFunctions, 'equal'));
assert(ng == 1261 && nt == 166 && nko == 1944 && nr == numel(model.rxns));
assert(nAnd + nOr + nEqual == numel(term));

% the sizes follow from the numbers of variables and terms
nVar = ng + nt + nko;
assert(isequal(size(f), [nVar, 1]) && isequal(size(lb), [nVar, 1]) && isequal(size(ub), [nVar, 1]));
assert(isequal(size(A), [2 * (nAnd + nOr), nVar]) && isequal(size(b), [2 * (nAnd + nOr), 1]));
assert(isequal(size(Aeq), [nEqual, nVar]) && isequal(size(beq), [nEqual, 1]));

% the variables are the genes of the model, then the term outputs; the genes and internal terms
% are weighted, the repressible reactions are not, and all variables are binary
assert(isequal(xname(1:ng), model.genes));
assert(isequal(xname(ng + 1:end), {term.output}'));
assert(isequal(f, [ones(ng + nt, 1); zeros(nko, 1)]));
assert(isequal(lb, zeros(nVar, 1)) && isequal(ub, ones(nVar, 1)));

% every equality row equates one term output with one gene
assert(all(sum(Aeq == 1, 2) == 1) && all(sum(Aeq == -1, 2) == 1) && all(sum(Aeq ~= 0, 2) == 2));
assert(all(beq == 0));

% each and/or term with k inputs fills two rows with k + 1 nonzeros each, and each and term
% with k inputs has the right-hand side k - 1 in its second row
nInputs = arrayfun(@(t) numel(t.input), term);
isAndOr = ismember(termFunctions, {'and', 'or'});
isAnd = strcmp(termFunctions, 'and');
assert(nnz(A) == 2 * sum(nInputs(isAndOr) + 1));
assert(sum(b) == sum(nInputs(isAnd) - 1) && all(b >= 0));

% Tier-5 reference (first run, 2026-11-03): the term counts and the nonzeros of the matrices
assert(nAnd == 339 && nOr == 597 && nEqual == 1174);
assert(nnz(A) == 7518 && sum(b) == 685 && nnz(Aeq) == 2348);

% the problem encodes the Boolean terms: for given gene states, the term values computed by
% evaluating the terms in order satisfy every row (the terms are ordered so that each input is
% a gene or an earlier term)
geneStates = [ones(ng, 1), zeros(ng, 1), mod((1:ng)', 2), double(mod((1:ng)', 3) == 0)];
termInputs = arrayfun(@(t) cellfun(@char, t.input, 'UniformOutput', false), term, ...
    'UniformOutput', false);
for s = 1:size(geneStates, 2)
    values = containers.Map(model.genes, num2cell(geneStates(:, s)));
    for i = 1:numel(term)
        inputValues = cellfun(@(name) values(name), termInputs{i});
        switch termFunctions{i}
            case 'and'
                values(term(i).output) = double(all(inputValues));
            case 'or'
                values(term(i).output) = double(any(inputValues));
            case 'equal'
                values(term(i).output) = inputValues(1);
        end
    end
    x = cellfun(@(name) values(name), xname);
    assert(all(A * x <= b) && all(Aeq * x == beq));
end

% change the directory
cd(currentDir)
