% The COBRAToolbox: testComputeMW.m
%
% Purpose:
%     - computeMW returns the molecular weights of the metabolite formulae of a model (all
%       metabolites or a list). By default it adds the mass numbers of a table of common
%       elements (H 1, C 12, O 16, ...), gives NaN to formulae with an R group or X, counts an
%       element missing from the table as 0 (with a displayed warning unless warnings = false)
%       and returns the elemental matrix of computeElementalMatrix ([C N O H P Other]). With
%       generalFormula = true it returns the masses of getMolecularMass with standard atomic
%       weights (isotopeAbundance = false) or monoisotopic masses (true), NaN for unknown
%       elements, the masses of the known part and the unknown elements.
%     - Expected values are hand calculations: mass numbers (glucose C6H12O6 = 6*12 + 12*1 +
%       6*16 = 180); IUPAC standard atomic weights (C 12.011, H 1.008, O 15.999, Mo 95.95);
%       monoisotopic masses of 1H 1.0078250, 12C 12, 16O 15.9949146 (NIST).
%
% Function under test:
%     src/dataIntegration/chemoInformatics/molecularWeight/computeMW.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - look-up on a model built with createModel; no solver.
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
fileDir = fileparts(which('testComputeMW'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% five metabolites (createModel orders them glc, r, x, y, z) with a plain formula, an R group,
% an X, a formula with an element without count (O in H2O) and an element missing from the
% mass-number table (Mo)
model = createModel({'R1', 'R2'}, {'R1', 'R2'}, {'glc -> x + y + r', 'z -> '});
model.metFormulas = {'C6H12O6'; 'CH3R'; 'C6H12O6X'; 'H2O'; 'C2H4Mo'};
assert(isequal(model.mets, {'glc[c]'; 'r[c]'; 'x[c]'; 'y[c]'; 'z[c]'}));

%% default: mass numbers for all metabolites

% the unknown element Mo makes the function display a warning (warnings defaults to true)
[MW, Ematrix, elements, knownWeights, unknownElements] = computeMW(model);
% integer sums of mass numbers: exact. glc 180, R group NaN, X NaN, H2O 2 + 16 = 18,
% C2H4Mo 24 + 4 = 28 (Mo has no entry and counts 0)
assert(isequal(MW(~isnan(MW)), [180; 18; 28]) && isequal(isnan(MW), [false; true; true; false; false]));
% elemental matrix [C N O H P Other] of computeElementalMatrix: R and X are not elements and
% are not counted, Mo is counted under Other
assert(isequal(elements, {'C', 'N', 'O', 'H', 'P', 'Other'}));
assert(isequal(Ematrix, [6 0 6 12 0 0; 1 0 0 3 0 0; 6 0 6 12 0 0; 0 0 1 2 0 0; 2 0 0 4 0 1]));
assert(isempty(knownWeights) && iscell(unknownElements) && isempty(unknownElements));

%% empty optional inputs take the defaults; a list selects metabolites; warnings off

[MW, Ematrix] = computeMW(model, [], [], []);
assert(isequal(MW([1 4 5]), [180; 18; 28]));
% the list order is kept; warnings = false skips the warning for Mo, the weight is the same
[MW, Ematrix] = computeMW(model, {'z[c]'; 'glc[c]'}, false);
assert(isequal(MW, [28; 180]));
assert(isequal(Ematrix, [2 0 0 4 0 1; 6 0 6 12 0 0]));

%% generalFormula: standard atomic weights

[MW, Ematrix, elements, knownWeights, unknownElements] = computeMW(model, [], false, true);
% IUPAC standard atomic weights: glucose 6*12.011 + 12*1.008 + 6*15.999 = 180.156,
% CH3 12.011 + 3*1.008 = 15.035, H2O 18.015, C2H4Mo 28.054 + 95.95 = 124.004. The weight tables
% of the toolbox and the abridged values above differ by up to about 0.01 (Mo), hence 0.02
tolWeight = 0.02;
assert(all(abs(MW([1 4 5]) - [180.156; 18.015; 124.004]) < tolWeight));
% formulae with an element of unknown weight (R, X) get NaN, their known part is returned
assert(all(isnan(MW([2 3]))));
assert(all(abs(knownWeights - [180.156; 15.035; 180.156; 18.015; 124.004]) < tolWeight));
assert(isequal(sort(unknownElements), {'R', 'X'}));
% one column per element found in the formulae; counts are integers
assert(isequal(sort(elements), sort({'C', 'H', 'O', 'X', 'R', 'Mo'})));
expectedCounts = [6 12 6 0 0 0; 1 3 0 0 1 0; 6 12 6 1 0 0; 0 2 1 0 0 0; 2 4 0 0 0 1];
[~, order] = ismember({'C', 'H', 'O', 'X', 'R', 'Mo'}, elements);
assert(isequal(Ematrix(:, order), expectedCounts));

%% generalFormula with the predominant isotopes (monoisotopic masses)

[MW, Ematrix, elements, knownWeights, unknownElements] = computeMW(model, {'glc[c]'; 'y[c]'}, false, true, true);
% 6*12 + 12*1.0078250 + 6*15.9949146 = 180.063388 and 2*1.0078250 + 15.9949146 = 18.010565;
% isotope masses are known to better than 1e-6, so 1e-4 covers rounding of the table
tolMono = 1e-4;
assert(all(abs(MW - [180.063388; 18.010565]) < tolMono));
assert(all(abs(knownWeights - MW) < tolMono) && isempty(unknownElements));
assert(isequal(elements, {'C', 'H', 'O'}) && isequal(Ematrix, [6 12 6; 0 2 1]));

% change the directory
cd(currentDir)
