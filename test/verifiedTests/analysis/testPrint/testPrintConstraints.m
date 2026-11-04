% The COBRAToolbox: testPrintConstraints.m
%
% Purpose:
%     - testPrint tests the functionality of printConstraints
%       and compares it to expected data.
%
% Function under test:
%     src/analysis/exploration/printConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model through getDistributedModel for the
%     reference output, a hand-written toy model with one reaction of each kind for the branches.
%
% Coverage exemptions:
%     Line 87: unreachable, closedRxnBool, fwdRxnBool0b and revRxnBool0b exclude each other by
%       their definition and a forward and reverse reaction with zero bounds would be closed.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Lemmer El Assal March 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintConstraints'));
cd(fileDir);

% this test needs no solver, toolbox or particular operating system
prepareTest();

model = getDistributedModel('ecoli_core_model.mat');

% remove old generated file
delete('printConstraints.txt');

diary('printConstraints.txt');
minInf = 0;% [-Inf,-1000,-100,0]try different combination to test the function
maxInf = 1000; % [0,100,1000,+Inf]
printConstraints(model, minInf, maxInf);
diary off
text1 = readMixedData('refData_printConstraints.txt');
text2 = readMixedData('printConstraints.txt');

% Remove formatting difference
text1 = regexprep(text1, '<strong>|</strong>', '');  % Remove HTML tags
text2 = regexprep(text2, '<strong>|</strong>', '');  % Just in case
assert(isequal(text1, text2));

% remove the generated file
delete('printConstraints.txt');

%% toy model with one reaction of each kind; every printout below is read back
kinds = {'closed'; 'revZero'; 'fwdBound'; 'revBound'; 'reversible'; 'fwdZero'};
toyModel = struct('S', sparse(ones(1, 6)), 'mets', {{'A'}}, 'rxns', {kinds}, 'csense', 'E');
toyModel.lb = [0; -5; 1; -5; -3; 0];
toyModel.ub = [0; 0; 5; -1; 4; 9];

%% without limits, and without rxnNames, all six kinds are listed with their headings
printed = evalc('printConstraints(toyModel, [], [], true(6, 1), [], 1)');
headings = {'...closed reaction constraints:', 'Closed_reaction', ...
    '...forward reactions with non-[0, Inf] constraints:', 'Forward_Reaction, 0 bound', ...
    '...reverse reactions with non-[-Inf, 0]  constraints:', 'Reverse_Reaction, 0 bound', ...
    'Forward_Reaction, non-0 bound', 'Reverse_Reaction, non-0 bound', ...
    '...reversible reactions with non-[-Inf, Inf]  constraints:', 'Reversible_Reaction'};
assert(all(cellfun(@(x) contains(printed, x), [headings, kinds'])));

%% default limits and default selection print the same reactions
printed = evalc('printConstraints(toyModel)');
assert(all(cellfun(@(x) contains(printed, x), kinds)));

%% a second model adds the bounds after the perturbation to every table
toyModelAfter = toyModel;
toyModelAfter.ub = toyModel.ub + 0.5;
printed = evalc('printConstraints(toyModel, [], [], true(6, 1), toyModelAfter)');
assert(numel(strfind(printed, 'ub_after')) == 6);
assert(all(cellfun(@(x) contains(printed, x), kinds)));

%% an empty second model is the same as no second model
printed = evalc('printConstraints(toyModel, [], [], true(6, 1), [])');
assert(~contains(printed, 'ub_after'));

%% selecting one kind by name reports the other kinds as absent
toyModel.rxnNames = strcat(kinds, 'Name');
printed = evalc('printConstraints(toyModel, [], [], {''reversible''}, [], 1)');
assert(contains(printed, 'reversibleName'));
assert(contains(printed, 'No closed reactions with non-default constraints.'));
assert(contains(printed, 'No forward reactions with non-default constraints.'));
assert(contains(printed, 'No reverse reactions with non-default constraints.'));
assert(~contains(printed, 'closedName'));

printed = evalc('printConstraints(toyModel, [], [], {''closed''}, [], 1)');
assert(contains(printed, 'closedName'));
assert(contains(printed, 'No reversible reactions with non-default constraints.'));

%% one reaction identifier given as a character array is accepted
printed = evalc('printConstraints(toyModel, [], [], ''fwdZero'')');
assert(contains(printed, 'fwdZeroName') && ~contains(printed, 'closedName'));

%% a selection that matches no reaction prints nothing
assert(isempty(evalc('printConstraints(toyModel, [], [], {''notInModel''})')));

%% bounds beyond the limits fall in no group: a warning, and the reactions are listed apart
toyModel.lb(:) = -1000;
toyModel.ub(:) = 1000;
lastwarn('');
printed = evalc('printConstraints(toyModel, -1, 1, true(6, 1), [], 1)');
assert(contains(lastwarn, 'no subset with bounds between [minInf maxInf]'));
assert(contains(printed, '...reversible reactions with non-[-1, 1]  constraints:'));
assert(all(cellfun(@(x) contains(printed, x), kinds)));
printed = evalc('printConstraints(toyModel, -1, 1, true(6, 1), toyModel)');
assert(contains(printed, 'ub_after') && all(cellfun(@(x) contains(printed, x), kinds)));

%% without S the stoichiometric part is taken from A, and without A the function refuses to run
toyModelA = rmfield(toyModel, 'S');
toyModelA.A = sparse([ones(1, 6); 1, zeros(1, 5)]);
toyModelA.csense = ['E'; 'L'];
printed = evalc('printConstraints(toyModelA)');
assert(all(cellfun(@(x) contains(printed, x), kinds)));
assert(verifyCobraFunctionError('printConstraints', 'inputs', {rmfield(toyModelA, 'A')}, ...
    'testMessage', 'model.S missing'));

% change the directory
cd(currentDir)
