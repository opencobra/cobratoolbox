% The COBRAToolbox: testSingleMetaboliteSpeciesReaction.m
%
% Purpose:
%     - singleMetaboliteSpeciesReaction flags the internal reactions in which every metabolite has
%     exactly one species and prints the reaction identifier and equation of each flagged reaction.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/thermo/reactantContribution/singleMetaboliteSpeciesReaction.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSingleMetaboliteSpeciesReaction'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% three metabolites (number of species 1, 2, 1) and three reactions; the last one is an exchange
model.S = [-1  1  0; ...
            0 -1  1; ...
            0  0 -1];
model.rxns = {'a'; 'b'; 'c'};
model.met(1).mf = 1;
model.met(2).mf = [1 2];
model.met(3).mf = 1;
model.SExRxnInd = 3;
model.rxn(1).equation = 'A -> B';
model.rxn(2).equation = 'B -> C';
model.rxn(3).equation = 'C ->';

%% only reactions with single-species metabolites are flagged and printed

text = evalc('[rxnBool, nSpecies] = singleMetaboliteSpeciesReaction(model);');
% reaction a involves only the first metabolite; reaction b involves metabolite 2 (two species)
assert(isequal(rxnBool, [true; false; false]));
assert(isequal(nSpecies, [1; 2; 1]));
assert(strcmp(text, sprintf('a\t\t\tA -> B\n')));

%% exchange reactions are never flagged

model.SExRxnInd = [1 3];
text = evalc('rxnBool = singleMetaboliteSpeciesReaction(model);');
assert(~any(rxnBool) && isempty(text));

% change the directory
cd(currentDir)
