% The COBRAToolbox: testBilinearDecomposition.m
%
% Purpose:
%     - bilinearDecomposition rewrites a stoichiometric matrix S in bilinear form S = A*B*C:
%     reactions with more than two substrates or products are split into a chain of reactions with
%     at most two reactants each, using faux species.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/topology/FR/bilinearDecomposition.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 72-73, 80, 83, 120, 123, 160, 285, 291-297, 300-304, 309-312, 317-319 and 325-326 of
%     bilinearDecomposition.m are not reached. Lines 80, 83, 120, 123 and 160 are cases for one or two
%     reactants inside a block that only runs for four or more reactants, so they cannot occur; the
%     others are defensive checks and error messages that only fire if the algorithm were wrong,
%     or in the defect case below, which is not tested.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A lone reaction with one substrate and three products gives inconsistent sizes
%       SEVERITY: error
%       TRIGGER: a stoichiometric matrix whose only reaction with extra reactants has one substrate
%         and three products, for example [-1; 1; 1; 1]
%       OBSERVED: the number of faux species counted for A (one) differs from the number used in B
%         (two), so A*B*C fails with a dimension error and debugging output is printed
%       EXPECTED: the three matrices with consistent sizes and S = A*B*C
%       LINES: 45-53, 124-148, 288-300
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBilinearDecomposition'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% The defining property of the decomposition is S = A*B*C; the tests check it for reactions with every
% combination of 0 to 4 substrates and 0 to 4 products (which reaches every branch of the function),
% together with the structure that makes the form bilinear. The lone reaction with one substrate and
% three products is left out of the single-reaction checks, see the header.

numberOfMetabolites = 8;
maxReactants = 4;

% one reaction per combination: s substrates (coefficient -1, the first s metabolites) and p products
% (coefficient +1, the next p metabolites); the combination without any reactant is not a reaction
S = zeros(numberOfMetabolites, 0);
combinations = zeros(0, 2);
for numSubstrates = 0:maxReactants
    for numProducts = 0:maxReactants
        if numSubstrates + numProducts > 0
            column = zeros(numberOfMetabolites, 1);
            column(1:numSubstrates) = -1;
            column(numSubstrates + (1:numProducts)) = 1;
            S(:, end + 1) = column; %#ok<SAGROW>
            combinations(end + 1, :) = [numSubstrates, numProducts]; %#ok<SAGROW>
        end
    end
end

%% every combination of substrates and products in one matrix

[A, B, C] = bilinearDecomposition(S);
assert(isequal(full(A * B * C), S));
% A selects the original metabolites (identity) followed by empty columns for the faux species
numberOfFaux = size(A, 2) - numberOfMetabolites;
assert(numberOfFaux > 0);
assert(isequal(full(A), [eye(numberOfMetabolites), zeros(numberOfMetabolites, numberOfFaux)]));
% C adds the extra columns to the original reactions (identity on top, 0/1 below)
numberOfReactions = size(S, 2);
assert(isequal(full(C(1:numberOfReactions, :)), eye(numberOfReactions)));
assert(all(all(C(numberOfReactions + 1:end, :) == 0 | C(numberOfReactions + 1:end, :) == 1)));
% the sizes agree with the number of faux species
assert(isequal(size(B), [numberOfMetabolites + numberOfFaux, numberOfReactions + numberOfFaux]));

%% the bilinear form: every column of B has at most three entries (two reactants and one faux species)

[~, B] = bilinearDecomposition(S);
assert(all(sum(B ~= 0, 1) <= 3));

%% each reaction on its own also decomposes exactly

for k = 1:size(S, 2)
    if isequal(combinations(k, :), [1 3])
        continue          % see the header
    end
    [A, B, C] = bilinearDecomposition(S(:, k));
    assert(isequal(full(A * B * C), S(:, k)), sprintf('reaction with %d substrates and %d products', combinations(k, 1), combinations(k, 2)));
end

%% coefficients other than 1 are kept

coefficients = [-2 0; -3 0; -1 0; 1 -4; 5 0; 0 2];      % reaction 1: 3 substrates, 2 products
[A, B, C] = bilinearDecomposition(coefficients);
assert(isequal(full(A * B * C), coefficients));

%% a reaction of at most three reactants needs no faux species

simple = [-1 0; -1 -1; 1 1];
[A, B, C] = bilinearDecomposition(simple);
assert(isequal(full(A), eye(3)) && isequal(full(C), eye(2)));
assert(isequal(full(B), simple));

% change the directory
cd(currentDir)
