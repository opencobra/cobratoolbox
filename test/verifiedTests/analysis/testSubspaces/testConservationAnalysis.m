% The COBRAToolbox: testConservationAnalysis.m
%
% Purpose:
%     - conservationAnalysis computes the conserved metabolite pools (left null space) and the
%     linked reaction fluxes (null space) of a stoichiometric matrix by QR decomposition, with the
%     permutations and the independent and dependent rows and columns, optionally after removing
%     external or biomass reactions.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/subspaces/conservationAnalysis.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 302 and 310, the messages that report a failed QR consistency check: the check cannot
%     fail for a valid matrix.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConservationAnalysis'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-10;

% four metabolites and four reactions of rank 3: a closed cycle with one conserved pool
S = [1 -1  0  0; ...
     0  1 -1  0; ...
     0  0  1 -1; ...
     1  0  0 -1];
model.S = S;
model.rxns = {'a'; 'b'; 'c'; 'd'};
model.mets = {'m1'; 'm2'; 'm3'; 'm4'};

%% null spaces and rank

text = evalc('[L, N, Lzero, Nzero, Pl, Pn, iR, dR, iC, dC, rankS] = conservationAnalysis(model);');
assert(rankS == 3);
% the left null space is one pool and the null space is one cycle
assert(isequal(size(L), [1 4]) && isequal(size(N), [4 1]));
assert(norm(full(L * S)) < tol);
assert(norm(S * full(N)) < tol);
% the pool and the cycle are scaled so that one coefficient is one
assert(max(abs(L)) > 0 && max(abs(N)) > 0);
% independent and dependent rows and columns partition the metabolites and reactions
assert(nnz(iR) == 3 && nnz(dR) == 1 && all(xor(iR, dR)));
assert(nnz(iC) == 3 && nnz(dC) == 1 && all(xor(iC, dC)));
% the permutations are permutation matrices
assert(isequal(sort(sum(Pl, 1)), ones(1, 4)) && isequal(sort(sum(Pn, 1)), ones(1, 4)));
% the size of the matrices linking dependent to independent rows and columns
assert(isequal(size(Lzero), [1 3]) && isequal(size(Nzero), [3 1]));
% the report
assert(contains(text, '#met        4') && contains(text, '#rxn        4') && contains(text, 'Rank(S)     3'));

%% listing of the pools and correlated fluxes

text = evalc('conservationAnalysis(model, 0, 1);');
assert(contains(text, 'Conserved pools:') && contains(text, 'Correlated fluxes?:'));

%% coefficients above one are printed with the name

% a matrix of rank 2 whose left null space vector has the coefficients -0.75, -1.25 and 1
leftCase.S = [-2 7 -6; 2 -9 10; 1 -6 8];
leftCase.rxns = {'a'; 'b'; 'c'};
leftCase.mets = {'m1'; 'm2'; 'm3'};
text = evalc('conservationAnalysis(leftCase, 0, 1);');
assert(contains(text, '-1.25*m'));
% a matrix of rank 2 whose null space vector has the coefficients -0.75, 1 and -1.25
rightCase.S = [3 -4 -5; 6 -3 -6; 0 5 4];
rightCase.rxns = {'a'; 'b'; 'c'};
rightCase.mets = {'m1'; 'm2'; 'm3'};
text = evalc('conservationAnalysis(rightCase, 0, 1);');
assert(contains(text, '-1*') && contains(text, 'Correlated fluxes?:'));

%% a given tolerance

text = evalc('[~, ~, ~, ~, ~, ~, ~, ~, ~, ~, rankS] = conservationAnalysis(model, 0, 0, 1e-8);');
assert(rankS == 3);
assert(contains(text, '1e-08'));

%% only the internal reactions (mass balanced option 1)

internal = model;
internal.SIntRxnBool = [true; true; true; false];
evalc('[~, N, ~, ~, ~, ~, ~, ~, iC, ~, rankS] = conservationAnalysis(internal, 1);');
% without the last reaction the matrix has full column rank: no cycle remains
assert(rankS == 3 && isempty(N) || size(N, 2) == 0);
assert(numel(iC) == 3);

%% internal reactions found from the identifiers when the model does not say

noFlags = model;
text = evalc('[~, ~, ~, ~, ~, ~, ~, ~, iC] = conservationAnalysis(noFlags, 1, 1);');
assert(numel(iC) >= 1);
assert(contains(text, 'Conserved pools:'));

%% biomass reaction removed (mass balanced option -1)

withBiomass = model;
withBiomass.SIntRxnBool = true(4, 1);
withBiomass.c = [0; 0; 0; 1];
text = evalc('[~, ~, ~, ~, ~, ~, ~, ~, iC] = conservationAnalysis(withBiomass, -1);');
assert(contains(text, 'Assuming biomass reaction is: d'));
assert(numel(iC) == 3);
% the abbreviation of the biomass reaction can be given in the model
withBiomass.biomassRxnAbbr = 'd';
text = evalc('conservationAnalysis(withBiomass, -1);');
assert(contains(text, 'Found biomass reaction: d'));
% no objective: the message asks for the abbreviation and nothing is removed
noBiomass = withBiomass;
noBiomass = rmfield(noBiomass, 'biomassRxnAbbr');
noBiomass.c = zeros(4, 1);
text = evalc('[~, ~, ~, ~, ~, ~, ~, ~, iC] = conservationAnalysis(noBiomass, -1);');
assert(contains(text, 'No model.biomassRxnAbbr?') && numel(iC) == 4);
% a biomass abbreviation shared by two reactions
duplicate = withBiomass;
duplicate.rxns = {'a'; 'd'; 'c'; 'd'};
duplicate.biomassRxnAbbr = 'd';
verifyCobraFunctionError('conservationAnalysis', 'inputs', {duplicate, -1}, 'testMessage', 'More than one biomass reaction?');
% more than one objective reaction
twoBiomass = withBiomass;
twoBiomass = rmfield(twoBiomass, 'biomassRxnAbbr');
twoBiomass.c = [1; 0; 0; 1];
verifyCobraFunctionError('conservationAnalysis', 'inputs', {twoBiomass, -1}, 'testMessage', 'More than one biomass reaction?');

% change the directory
cd(currentDir)
