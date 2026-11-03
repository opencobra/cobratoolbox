% The COBRAToolbox: testGenerateGrRules.m
%
% Purpose:
%     - generateGrRules rebuilds model.grRules from model.rules and model.genes (| becomes or,
%       & becomes and, x(i) becomes the i-th gene) and, when a hyperlink command is given, adds
%       grRulesLinked in which every gene is a MATLAB hyperlink. Missing fields are handled: rules
%       are generated from grRules, or set empty when neither exists, and genes are named x(i)
%       when absent.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the counts of non-empty rules, gene links and generated genes asserted
%       below were recorded from the first run on 2026-11-03 with ecoli_core_model (no solver).
%       They were not derived independently, so they guard consistency, not independent
%       correctness (Tier 5). The regenerated rules are also compared with the grRules of the
%       input model, which are stored in the model file and not computed here.
%     - The inputs without rules, grRules or genes are derived from the loaded model by
%       removing those fields.
%
% Function under test:
%     src/analysis/exploration/surfNetSubfunctions/generateGrRules.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Nested hyperlinks when genes are named from the rules and a gene repeats
%       SEVERITY: wrong-result
%       TRIGGER: generateGrRules(rmfield(model, 'genes'), 'fprintf(''%s'')') with
%         ecoli_core_model, whose rules for 3 reactions use a gene twice
%       OBSERVED: the hyperlink of a gene x(i) contains the text x(i), and every occurrence is
%         replaced again for each repetition of the gene in the rule, so grRulesLinked holds
%         hyperlinks nested inside hyperlinks
%       EXPECTED: each gene of the rule hyperlinked exactly once
%       LINES: 64, 73-74
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateGrRules'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites, 137 genes)
model = getDistributedModel('ecoli_core_model.mat');

% the gene indices used in the rules of the input model
ruleGeneIdx = str2double(regexp(strjoin(model.rules', ' '), '(?<=x\()\d+(?=\))', 'match'));

%% default: grRules are regenerated from rules and genes, no hyperlinked field

newModel = generateGrRules(model);

% the regenerated grRules are the grRules stored in the model file; rules and genes are kept
assert(isequal(newModel.grRules, model.grRules));
assert(isequal(newModel.rules, model.rules));
assert(isequal(newModel.genes, model.genes));
assert(~isfield(newModel, 'grRulesLinked'));

% the regenerated grRules use the words and/or and gene names only (no x(i) left), one per
% reaction; Tier-5 count (first run 2026-11-03): 69 reactions have a rule
assert(isequal(size(newModel.grRules), [numel(model.rxns), 1]));
assert(~any(contains(newModel.grRules, {'&', '|', 'x('})));
assert(nnz(~cellfun(@isempty, newModel.grRules)) == 69);

% an empty hyperlink command is the default
assert(isequal(generateGrRules(model, []), newModel));

%% a hyperlink command adds grRulesLinked with every gene hyperlinked

newModel = generateGrRules(model, 'fprintf(''%s'')');

% grRules are the same as without the command
assert(isequal(newModel.grRules, model.grRules));
assert(isequal(size(newModel.grRulesLinked), [numel(model.rxns), 1]));

% every hyperlink runs the command with the gene it shows; removing the hyperlinks gives grRules
linkPattern = '<a href="matlab: fprintf\(''([^'']+)''\)">\1</a>';
assert(isequal(regexprep(newModel.grRulesLinked, linkPattern, '$1'), newModel.grRules));

% one hyperlink per gene occurrence in the rules (Tier-5 count, first run 2026-11-03: 174) and
% the reactions without a rule stay empty
nLinks = numel(regexp(strjoin(newModel.grRulesLinked', ' '), linkPattern));
assert(nLinks == numel(ruleGeneIdx));
assert(nLinks == 174);
assert(isequal(cellfun(@isempty, newModel.grRulesLinked), cellfun(@isempty, model.rules)));

%% without rules, the rules are generated from grRules

newModel = generateGrRules(rmfield(model, 'rules'));

% the generated rules and the regenerated grRules equal those of the input model up to blanks
% (generateRules writes a blank inside each parenthesis); the genes are kept
assert(isequal(regexprep(newModel.rules, '\s', ''), regexprep(model.rules, '\s', '')));
assert(isequal(regexprep(newModel.grRules, '\s', ''), regexprep(model.grRules, '\s', '')));
assert(isequal(newModel.genes, model.genes));
assert(isequal(size(newModel.rules), [numel(model.rxns), 1]));

%% without rules and grRules, every reaction gets an empty rule

newModel = generateGrRules(rmfield(model, {'rules', 'grRules'}));

% one empty rule and one empty grRule per reaction; the genes are kept
assert(isequal(newModel.rules, repmat({''}, numel(model.rxns), 1)));
assert(isequal(newModel.grRules, repmat({''}, numel(model.rxns), 1)));
assert(isequal(newModel.genes, model.genes));

%% without genes, the genes are named x(1) to x(N) after the largest index in the rules

newModel = generateGrRules(rmfield(model, 'genes'));

% the genes are x(1) ... x(N) with N the largest gene index of the rules (Tier-5 value, first
% run 2026-11-03: 137, the number of genes of the input model)
maxGeneIdx = max(ruleGeneIdx);
assert(maxGeneIdx == 137);
assert(isequal(newModel.genes, strcat('x(', arrayfun(@num2str, (1:maxGeneIdx)', 'UniformOutput', false), ')')));

% grRules keep the x(i) names with and/or; written with the gene names of the input model they
% are the input grRules
assert(~any(contains(newModel.grRules, {'&', '|'})));
inputGenes = model.genes;
namedGrRules = regexprep(newModel.grRules, 'x\((\d+)\)', '${inputGenes{str2double($1)}}');
assert(isequal(namedGrRules, model.grRules));

%% without rules, grRules and genes, the gene list is empty

newModel = generateGrRules(rmfield(model, {'rules', 'grRules', 'genes'}));

% the gene list is a 0 x 1 cell and every rule is empty
assert(iscell(newModel.genes) && isequal(size(newModel.genes), [0, 1]));
assert(isequal(newModel.grRules, repmat({''}, numel(model.rxns), 1)));

% change the directory
cd(currentDir)
