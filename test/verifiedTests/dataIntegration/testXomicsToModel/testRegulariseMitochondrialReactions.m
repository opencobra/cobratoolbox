% The COBRAToolbox: testRegulariseMitochondrialReactions.m
%
% Purpose:
%     - regulariseMitochondrialReactions moves the protons of the mitochondrial intermembrane
%       space to the cytosol: in every reaction that uses h[i], except Htmi, the coefficient of
%       h[i] becomes the coefficient of h[c] and the reaction is renamed with the suffix new; the
%       reaction Htmi (h[i] -> h[m]) and the metabolite h[i] are then removed. Renamed reactions
%       are also renamed in options.activeReactions and options.rxns2constrain. If removing Htmi
%       would remove any metabolite other than h[i], the function stops with an error.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the five renamed reactions and the model size asserted below were
%       recorded from the first run on 2026-11-03 with Recon3DModel_301 (no solver). They were not
%       derived independently, so they guard consistency, not independent correctness (Tier 5).
%       The expected stoichiometry is also derived independently from the input S.
%     - Recon3DModel_301 is used because it is the only distributed model with the intermembrane
%       space metabolite h[i] and the reaction Htmi. It has no coupling constraints (no field C),
%       so the 'infeasible' constraint removal of removeRxns calls no solver.
%     - The options are built in the test: a list of active reactions and a table of reaction
%       constraints, each with one renamed and one other reaction. The error input is built from
%       the loaded model by adding one metabolite that only Htmi uses.
%     - With printLevel 1 the old and new reaction formulas are printed; this output is not
%       suppressed.
%
% Function under test:
%     src/dataIntegration/XomicsToModel/prepareData/regulariseMitochondrialReactions.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; Recon3DModel_301 loaded through getDistributedModel.
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
fileDir = fileparts(which('testRegulariseMitochondrialReactions'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (10600 reactions, 5835 metabolites)
model = getDistributedModel('Recon3DModel_301.mat');

%% the protons of h[i] are moved to h[c], the reactions renamed and Htmi and h[i] removed

options = struct();
options.activeReactions = {'ATPS4mi'; 'PGI'};
options.rxns2constrain = table({'CYOR_u10mi'; 'HEX1'}, [0; 0], [10; 10], ...
    'VariableNames', {'rxns', 'lb', 'ub'});
[modelOut, optionsOut, problemRxnList, fixedRxnList] = ...
    regulariseMitochondrialReactions(model, options, 0);

% the problem reactions are those that use h[i], without Htmi, in sorted order (Tier-5
% reference, first run 2026-11-03), and the fixed reactions carry the suffix new
isHi = strcmp(model.mets, 'h[i]');
isHc = strcmp(model.mets, 'h[c]');
expectedProblemRxns = setdiff(model.rxns(model.S(isHi, :) ~= 0), 'Htmi');
assert(isequal(problemRxnList, expectedProblemRxns));
assert(isequal(problemRxnList, {'ATPS4mi'; 'CYOOm2i'; 'CYOOm3i'; 'CYOR_u10mi'; 'NADH2_u10mi'}));
assert(isequal(fixedRxnList, strcat(problemRxnList, 'new')));

% Htmi and h[i] are removed, nothing else (Tier-5 sizes, first run 2026-11-03)
keepRxn = ~strcmp(model.rxns, 'Htmi');
assert(isequal(size(modelOut.S), [numel(model.mets) - 1, numel(model.rxns) - 1]));
assert(isequal(size(modelOut.S), [5834, 10599]));
assert(~any(strcmp(modelOut.mets, 'h[i]')) && ~any(strcmp(modelOut.rxns, 'Htmi')));
assert(isequal(modelOut.mets, model.mets(~isHi)));

% the reactions keep their order and only the problem reactions are renamed
[isProblem, problemIdx] = ismember(model.rxns, problemRxnList);
expectedRxns = model.rxns;
expectedRxns(isProblem) = fixedRxnList(problemIdx(isProblem));
assert(isequal(modelOut.rxns, expectedRxns(keepRxn)));

% the stoichiometry is the input one with the h[i] coefficients of the problem reactions moved
% to h[c]; the problem reactions do not use h[c] in the input, so the move loses nothing.
% Coefficients are copied, not computed, so equality is exact
assert(~any(model.S(isHc, isProblem)));
expectedS = model.S;
expectedS(isHc, isProblem) = model.S(isHi, isProblem);
expectedS(isHi, isProblem) = 0;
assert(isequal(modelOut.S, expectedS(~isHi, keepRxn)));
assert(isequal(modelOut.lb, model.lb(keepRxn)) && isequal(modelOut.ub, model.ub(keepRxn)));

% the result is structurally consistent: every reaction- and metabolite-sized field of the input
% has lost one row, rxnGeneMat is reactions x genes and the rules only use existing gene indices
nRxns = numel(model.rxns);
nMets = numel(model.mets);
rxnFields = fieldnames(model);
rxnFields = rxnFields(cellfun(@(f) size(model.(f), 1) == nRxns && ~strcmp(f, 'S'), rxnFields));
metFields = fieldnames(model);
metFields = metFields(cellfun(@(f) size(model.(f), 1) == nMets && ~strcmp(f, 'S'), metFields));
assert(all(cellfun(@(f) size(modelOut.(f), 1) == nRxns - 1, rxnFields)));
assert(all(cellfun(@(f) size(modelOut.(f), 1) == nMets - 1, metFields)));
assert(isequal(size(modelOut.rxnGeneMat), [nRxns - 1, numel(modelOut.genes)]));
ruleGeneIdx = str2double(regexp(strjoin(modelOut.rules', ' '), '(?<=x\()\d+(?=\))', 'match'));
assert(all(ruleGeneIdx >= 1 & ruleGeneIdx <= numel(modelOut.genes)));
assert(isequal(modelOut.genes, model.genes));

% the renamed reactions are renamed in the options too; the other entries are unchanged
assert(isequal(optionsOut.activeReactions, {'ATPS4minew'; 'PGI'}));
assert(isequal(optionsOut.rxns2constrain.rxns, {'CYOR_u10minew'; 'HEX1'}));
assert(isequal(optionsOut.rxns2constrain(:, {'lb', 'ub'}), options.rxns2constrain(:, {'lb', 'ub'})));

%% printLevel 1 prints the old and new formulas and gives the same result; options are optional

[modelQuiet, ~, problemQuiet, fixedQuiet] = regulariseMitochondrialReactions(model, struct(), 0);
[modelOut, optionsOut, problemRxnList, fixedRxnList] = ...
    regulariseMitochondrialReactions(model, struct(), 1);
assert(isequal(modelOut, modelQuiet));
assert(isequal(problemRxnList, problemQuiet) && isequal(fixedRxnList, fixedQuiet));

% options without activeReactions or rxns2constrain are returned unchanged
assert(isequal(optionsOut, struct()));

%% a model in which Htmi is the only user of another metabolite is rejected

% add one metabolite to the mitochondrial side of Htmi, so that removing Htmi would also remove it
modelExtra = addMetabolite(model, 'htmiProbe[m]');
modelExtra.S(end, strcmp(modelExtra.rxns, 'Htmi')) = 1;
clear model
assert(verifyCobraFunctionError('regulariseMitochondrialReactions', ...
    'inputs', {modelExtra, struct(), 1}, 'testMessage', 'Incorrect removal of metabolite h[i]'));

% change the directory
cd(currentDir)
