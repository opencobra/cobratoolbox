% The COBRAToolbox: testGetElementalWeightMatrix.m
%
% Purpose:
%     - getElementalWeightMatrix returns a #elements x 2 cell array of chemical element symbols
%       and atomic weights, read from the NIST table "Atomic Weights and Isotopic Compositions
%       for All Elements" shipped with the toolbox (parsed by
%       parse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elements). The test checks
%         * the default (no input, [] or false): 114 elements (the distinct symbols of the table
%           without the isotopes D and T and the placeholder XYZ), unique, elements with a
%           standard atomic weight first in alphabetical order, then the 30 elements without one
%           (NaN), also in alphabetical order; the standard weights of H, C, N, O, Ag, Zn and I
%           are the values printed in the table (1.00794, 12.0107, 14.0067, 15.9994, 107.8682,
%           65.409, 126.90447);
%         * true: the 16 biological elements get the relative atomic mass of their predominant
%           isotope as printed in the table (e.g. C-12 12, H-1 1.0078250321, Mo-98 97.9054078,
%           I-127 126.904468), the other elements keep the default;
%         * a user-defined isotope abundance cell array: each element gets the
%           abundance-weighted mean of its isotope masses (hand calculation from the printed
%           masses), D counts as H, the other elements keep the default;
%         * the six input errors (wrong width, unknown element - the help says it raises an
%           error -, non-positive mass number, abundance outside [0, 1], unknown isotope,
%           abundances not summing to 1).
%       The counts 114, 84 and 30, the 30 symbols without a standard weight and every expected
%       weight were read independently from the data file with a short Python script
%       (distinct "Atomic Symbol" values; weights given only as a mass number in brackets have
%       no standard atomic weight), not from this function.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/molecularWeight/basicPhysicochemicalData/getElementalWeightMatrix.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; the input is the data file shipped with the toolbox.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Full test after the help text was corrected (feature 20261120-151023-doc-matches-code), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetElementalWeightMatrix'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% weights are compared with an absolute tolerance of 1e-9: the expected values are the
% decimal numbers printed in the data file (read by textscan into doubles) or weighted
% means of two of them, so only rounding of double arithmetic (about 1e-14 at 100) differs
tol = 1e-9;

%% default: standard atomic weights of the 114 elements
% no input (nargin == 0, line 22), an empty input (isempty) and false give the same result
defaultMatrix = getElementalWeightMatrix();
assert(isequaln(getElementalWeightMatrix([]), defaultMatrix));
assert(isequaln(getElementalWeightMatrix(false), defaultMatrix));
assert(iscell(defaultMatrix) && isequal(size(defaultMatrix), [114, 2]));
symbols = defaultMatrix(:, 1);
weights = cell2mat(defaultMatrix(:, 2));
% the symbols are unique and exclude the isotopes D and T and the placeholder XYZ
assert(numel(unique(symbols)) == 114);
assert(~any(ismember({'D', 'T', 'XYZ'}, symbols)));
% the 84 elements with a standard weight come first, sorted alphabetically
assert(all(~isnan(weights(1:84))));
assert(issorted(symbols(1:84)));
assert(strcmp(symbols{1}, 'Ag') && strcmp(symbols{84}, 'Zr'));
% then the 30 elements without a standard weight (NaN), sorted alphabetically
symbolsWithoutWeight = {'Ac'; 'Am'; 'At'; 'Bh'; 'Bk'; 'Cf'; 'Cm'; 'Db'; 'Es'; 'Fm'; 'Fr'; ...
    'Hs'; 'Lr'; 'Md'; 'Mt'; 'No'; 'Np'; 'Pm'; 'Po'; 'Pu'; 'Ra'; 'Rf'; 'Rn'; 'Sg'; 'Tc'; ...
    'Uub'; 'Uuh'; 'Uun'; 'Uuq'; 'Uuu'};
assert(isequal(symbols(85:114), symbolsWithoutWeight));
assert(all(isnan(weights(85:114))));
% standard atomic weights printed in the data file
standardSymbols = {'H', 'C', 'N', 'O', 'Ag', 'Zn', 'I'};
standardWeights = [1.00794; 12.0107; 14.0067; 15.9994; 107.8682; 65.409; 126.90447];
[isListed, standardRows] = ismember(standardSymbols, symbols);
assert(all(isListed));
assert(all(abs(weights(standardRows) - standardWeights) < tol));

%% true: biological elements weigh as their predominant isotope (lines 37-127)
% the 16 elements and isotopes of lines 43-60 with the relative atomic masses printed in the
% data file; all other elements keep their standard weight (or NaN)
isotopeMatrix = getElementalWeightMatrix(true);
assert(isequal(isotopeMatrix(:, 1), symbols));
isotopeWeights = cell2mat(isotopeMatrix(:, 2));
biologicalSymbols = {'C', 'H', 'O', 'N', 'S', 'Mg', 'K', 'Cl', 'Ca', 'Zn', 'Cu', 'Mo', ...
    'P', 'Na', 'Fe', 'I'};
isotopeMasses = [12; 1.0078250321; 15.9949146221; 14.0030740052; 31.97207069; ...
    23.98504190; 38.9637069; 34.96885271; 39.9625912; 63.9291466; 62.9296011; ...
    97.9054078; 30.97376151; 22.98976967; 55.9349421; 126.904468];
[~, biologicalRows] = ismember(biologicalSymbols, symbols);
assert(all(abs(isotopeWeights(biologicalRows) - isotopeMasses) < tol));
otherRows = setdiff((1:114)', biologicalRows);
assert(isequaln(isotopeWeights(otherRows), weights(otherRows)));

%% user-defined isotope abundance: abundance-weighted mean of the isotope masses
% hand calculation from the printed masses: C = 0.5 * 12 + 0.5 * 13.0033548378;
% Cl = 0.75 * 34.96885271 + 0.25 * 36.96590260; H = 0.5 * 1.0078250321 + 0.5 * 2.0141017780,
% where the row of D (mass number 2) is counted as H (lines 67-69). Elements that are not
% listed keep their standard weight
isotopeAbundance = {'C', 12, 0.5; 'C', 13, 0.5; 'Cl', 35, 0.75; 'Cl', 37, 0.25; ...
    'H', 1, 0.5; 'D', 2, 0.5};
userMatrix = getElementalWeightMatrix(isotopeAbundance);
assert(isequal(userMatrix(:, 1), symbols));
userWeights = cell2mat(userMatrix(:, 2));
[~, userRows] = ismember({'C', 'Cl', 'H'}, symbols);
assert(all(abs(userWeights(userRows) - [12.5016774189; 35.4681151825; 1.51096340505]) < tol));
otherRows = setdiff((1:114)', userRows);
assert(isequaln(userWeights(otherRows), weights(otherRows)));

%% invalid isotope abundances raise errors
% a cell array that is not n-by-3 (line 76)
assert(verifyCobraFunctionError('getElementalWeightMatrix', 'inputs', {{'C', 12}}, ...
    'testMessage', 'Incorrect size. IsotopeAbundance must be a n-by-3 cell array.'));
% unknown elements raise an error, as the help text says (line 79); they are listed sorted
assert(verifyCobraFunctionError('getElementalWeightMatrix', 'inputs', ...
    {{'C', 12, 1; 'Xx', 1, 1; 'Qq', 2, 1}}, 'testMessage', ...
    'Qq, Xx in the supplied isotope abundance profile is/are not standard chemical elements.'));
% non-positive mass numbers (line 85), with the rows that hold them
assert(verifyCobraFunctionError('getElementalWeightMatrix', 'inputs', ...
    {{'C', 0, 1; 'O', 16, 1; 'N', -1, 1}}, 'testMessage', ...
    'Non-positive isotope mass in row(s) 1, 3.'));
% an abundance outside [0, 1] (line 87)
assert(verifyCobraFunctionError('getElementalWeightMatrix', 'inputs', {{'C', 12, 1.5}}, ...
    'testMessage', 'Invalid isotope abundance in row(s) 1. Must lie between 0 and 1.'));
% isotopes that are not in the data file (lines 100-107): one line per unmatched row,
% with its row number, symbol and mass number separated by tabs
unknownIsotopeMessage = sprintf(['The following isotopes could not be identified:', ...
    '\n#2\tC\t99\n#3\tO\t99']);
assert(verifyCobraFunctionError('getElementalWeightMatrix', 'inputs', ...
    {{'C', 12, 1; 'C', 99, 0; 'O', 99, 1}}, 'testMessage', unknownIsotopeMessage));
% abundances of an element that do not sum to 1 (line 121)
assert(verifyCobraFunctionError('getElementalWeightMatrix', 'inputs', ...
    {{'C', 12, 0.5; 'O', 16, 1}}, 'testMessage', ['Invalid isotope abundances for ', ...
    'element(s) C. The sum of isotope abundances for each element must be equal to 1.']));

% change the directory
cd(currentDir)
