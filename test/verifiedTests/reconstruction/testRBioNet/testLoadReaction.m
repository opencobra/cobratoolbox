% The COBRAToolbox: testLoadReaction.m
%
% Purpose:
%     - testLoadReaction tests the functionality of LoadReaction and
%       balancecheck, and formula2mets in the rBioNet extension
%
% Authors:
%     - Stefania Magnusdottir April 2017
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLoadReaction'));
cd(fileDir);

% load E. coli model
model = getDistributedModel('ecoli_core_model.mat');

% load reaction and metabolite databases
load([fileDir, filesep 'metab.mat'])
load([fileDir, filesep 'rxn.mat'])
load([fileDir, filesep 'compartments.mat'])

% calculate reaction information
output = LoadReaction(rxn(1, :), metab, compartments, 1);

% extract metabolites from reaction formula
formulaMetsComp = parseRxnFormula(rxn{1, 3});
formulaMets = regexprep(formulaMetsComp, '\[.+\]', '');

% test metabolite output
assert(isequal(sort(formulaMets'), sort(output(:, 1))))

% test metabolite description output
assert(isequal(sort(metab(find(ismember(metab(:, 1), formulaMets)), 2)), ...
    sort(output(:, 2))))

% test metabolite formula output
assert(isequal(sort(metab(find(ismember(metab(:, 1), formulaMets)), 4)), ...
    sort(output(:, 6))))

% test metabolite charge output
assert(isequal(sort(metab(find(ismember(metab(:, 1), formulaMets)), 5)), ...
    sort(output(:, 7))))

%TEST: balancecheck
% check match for made up reaction, uses output from LoadReaction
% calculate reaction information
output = LoadReaction(rxn(1, :), metab, compartments, 1);
balance = balancecheck(output);

% test that reaction was balanced
assert(isempty(balance))

%TEST: formula2mets
% extract metabolite formulas
metabolites = formula2mets(rxn{1, 3});

% test that metabolites are the same as in formulaMets from before
assert(isequal(sort(metabolites), sort(formulaMets)))

% change the directory
cd(currentDir)
