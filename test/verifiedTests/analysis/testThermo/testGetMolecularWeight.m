% The COBRAToolbox: testGetMolecularWeight.m
%
% Purpose:
%     - getMolecularWeight computes the molecular weight, the element counts (H, C, N, O, P, S and
%     the number of electrons) of metabolites given as InChI strings, and reports empty InChI
%     strings and unknown elements.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/thermo/inchi/getMolecularWeight.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Hydrogens are lost for an InChI whose formula starts with H
%       SEVERITY: wrong-result
%       TRIGGER: an InChI whose formula layer begins with hydrogen, for example water,
%         InChI=1S/H2O/h1H2
%       OBSERVED: the formula returned by getFormulaAndChargeFromInChI is O and the hydrogen count
%         is returned separately, but only the formula is used, so water gets a molecular weight of
%         16 and 0 hydrogens
%       EXPECTED: a molecular weight of 18 and 2 hydrogens for water
%       LINES: 41-61
%     - DEFECT: Warnings are printed without a line break
%       SEVERITY: cosmetic
%       TRIGGER: an empty InChI or an element that is not in the table, with warnings switched on
%       OBSERVED: the warning text is printed with fprintf and no trailing newline, so consecutive
%         warnings run together on one line
%       EXPECTED: each warning on its own line
%       LINES: 37, 54
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetMolecularWeight'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

glucose = 'InChI=1S/C6H12O6/c7-1-2-3(8)4(9)5(10)6(11)12-2/h2-11H,1H2/t2-,3-,4+,5-,6?/m1/s1';
iron = 'InChI=1S/Fe/q+2/p0';
ethylBromide = 'InChI=1S/C2H5Br/c1-2-3/h2H2,1H3';
inchis = {glucose; ''; ethylBromide};

%% molecular weight and element counts of glucose

[MW, E] = getMolecularWeight({glucose});
% atomic masses in the function are integers: 6 C (12), 12 H (1), 6 O (16)
assert(MW == 6 * 12 + 12 * 1 + 6 * 16);
% columns: H, C, N, O, P, S and electrons (protons minus charge)
assert(isequal(E, [12 6 0 6 0 0 96]));

%% several metabolites, an empty InChI and an element with a charge

[MW, E] = getMolecularWeight({glucose; ''; iron}, false);
assert(MW(1) == 180 && isnan(MW(2)) && MW(3) == 56);
assert(all(isnan(E(2, :))));
% the iron ion has a charge of +2 and none of the six counted elements
assert(isequal(E(3, :), [0 0 0 0 0 0 -2]));

%% warnings

% the empty InChI warning (printed without a line break) and the unknown element warning
text = evalc('[MW, E] = getMolecularWeight(inchis);');
assert(contains(text, 'Warning: InChI no. 2 is empty'));
assert(contains(text, 'Warning: C2H5Br, Br'));
% the unknown element (Br) is ignored in the weight: 5 H + 2 C
assert(MW(3) == 5 + 24);
assert(isequal(E(3, 1:2), [5 2]));

%% warnings can be switched off

text = evalc('getMolecularWeight(inchis, false);');
assert(isempty(text));

% change the directory
cd(currentDir)
