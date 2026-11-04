% The COBRAToolbox: testLoadReaction.m
%
% Purpose:
%     - testLoadReaction tests the functionality of LoadReaction and
%       balancecheck, and formula2mets in the rBioNet extension
%
% Function under test:
%     src/reconstruction/rBioNet/LoadReaction.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - no solver; ecoli_core_model loaded through getDistributedModel. A message box is
%     opened and closed by the test.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Stefania Magnusdottir April 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLoadReaction'));
cd(fileDir);

% this test needs no solver, MATLAB toolbox or particular operating system
prepareTest();

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

%% the line number is optional, and does not change the output

assert(isequal(LoadReaction(rxn(1, :), metab, compartments), output));

%% a metabolite that is not in the database is reported in the output

unknownMetRxn = rxn(1, :);
unknownMetRxn{3} = 'notInDatabase[c] -> ';
assert(isequal(LoadReaction(unknownMetRxn, metab, compartments, 1), {'', rxn{1, 1}, 'notInDatabase'}));

%% an unknown compartment gives an empty output and a message

unknownCompRxn = rxn(1, :);
unknownCompRxn{3} = [metab{1, 1} '[q] -> '];
assert(isempty(LoadReaction(unknownCompRxn, metab, compartments, 1)));
assert(contains(closeMessageBoxes(), 'Compartment (q) was not recognized.'));

% change the directory
cd(currentDir)

function boxText = closeMessageBoxes()
% Returns the text of the open message boxes and closes them, so that no window stays open.
boxes = findall(0, 'Type', 'figure', '-regexp', 'Tag', '^Msgbox_');
boxText = '';
for iBox = 1:numel(boxes)
    boxLines = cellstr(get(findall(boxes(iBox), 'Type', 'text'), 'String'));
    boxText = [boxText, ' ', strjoin(strtrim(boxLines), ' ')];
end
delete(boxes);
end
