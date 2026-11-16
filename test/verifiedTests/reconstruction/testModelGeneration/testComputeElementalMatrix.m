% The COBRAToolbox: testComputeElementalMatrix.m
%
% Purpose:
%     - computeElementalMatrix counts the atoms in the formulas of a model's metabolites,
%       either as the six columns [C N O H P Other] or, with generalFormula, one column per
%       element with C, N, O, H and P first. The test uses hand-written formulas whose atom
%       counts are read directly from the formulas: all metabolites and a metabolite list,
%       implicit counts of 1, other elements, an empty formula, an unknown symbol with and
%       without the printed warning, and the general mode with a bracketed formula.
%
% Function under test:
%     src/reconstruction/modelGeneration/massBalance/computeElementalMatrix.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - look-up on a hand-built model structure (mets and metFormulas), no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testComputeElementalMatrix'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the function keeps the elemental weight matrix in a persistent variable; clearing the
% function makes the first call below load it, whatever ran before in this session
clear computeElementalMatrix

model = struct();
model.mets = {'glc[c]'; 'atp[c]'; 'fe2[c]'; 'meoh[c]'; 'x[c]'; 'none[c]'};
model.metFormulas = {'C6H12O6'; 'C10H12N5O13P3'; 'Fe'; 'CH4O'; 'C2Xq'; ''};

%% all metabolites: [C N O H P Other] counts

% atom counts are integers, so the comparisons are exact
[Ematrix, elements] = computeElementalMatrix(model);
assert(isequal(elements, {'C', 'N', 'O', 'H', 'P', 'Other'}));
expectedEmatrix = [6 0 6 12 0 0; ...     % C6H12O6
                   10 5 13 12 3 0; ...   % C10H12N5O13P3
                   0 0 0 0 0 1; ...      % Fe is another element
                   1 0 1 4 0 0; ...      % CH4O: C and O without a number count 1
                   2 0 0 0 0 0; ...      % Xq is not an element: ignored (warning printed)
                   0 0 0 0 0 0];         % empty formula
assert(isequal(Ematrix, expectedEmatrix));

%% a metabolite list selects and orders the rows; no warning printed when disabled

[EmatrixList, elementsList] = computeElementalMatrix(model, {'x[c]', 'atp[c]', 'glc[c]'}, false);
assert(isequal(elementsList, elements));
assert(isequal(EmatrixList, expectedEmatrix([5 2 1], :)));

%% empty metabolite list and warnings: defaults (all metabolites, warnings printed)

assert(isequal(computeElementalMatrix(model, [], [], false), expectedEmatrix));

%% general formulae: one column per element, C N O H P first

modelGeneral = struct();
modelGeneral.mets = {'glc[c]'; 'cuso4[c]'; 'pi[c]'};
modelGeneral.metFormulas = {'C6H12O6'; '[H2O]5CuSO4'; 'HO4P'};
[EmatrixGeneral, elementsGeneral] = computeElementalMatrix(modelGeneral, [], false, true);
% N is absent from every formula, so the first four columns are C O H P
assert(isequal(elementsGeneral(1:4), {'C', 'O', 'H', 'P'}));
assert(isequal(sort(elementsGeneral(5:end)), sort({'Cu', 'S'})));
assert(isequal(size(EmatrixGeneral), [3, 6]));
% [H2O]5CuSO4 = H10 O9 Cu S
expectedCounts = struct('C', [6; 0; 0], 'O', [6; 9; 4], 'H', [12; 10; 1], 'P', [0; 0; 1], ...
    'Cu', [0; 1; 0], 'S', [0; 1; 0]);
for k = 1:numel(elementsGeneral)
    assert(isequal(EmatrixGeneral(:, k), expectedCounts.(elementsGeneral{k})));
end

% change the directory
cd(currentDir)
