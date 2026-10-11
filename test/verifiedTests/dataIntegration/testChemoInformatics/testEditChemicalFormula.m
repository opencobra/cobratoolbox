% The COBRAToolbox: testEditChemicalFormula.m
%
% Purpose:
%     - editChemicalFormula normalises a chemical formula (elements sorted alphabetically, repeated elements merged) and can add or remove atoms of given elements; X, Y, * and FULLR are written as R.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/editChemicalFormula.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     Removing all atoms of an element leaves the element with a zero count (for example C2H5OH minus one O gives "C2H6O0"). This cosmetic behaviour is documented and NOT tested.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testEditChemicalFormula'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% normalisation: sorting and merging repeated elements

% elements are sorted alphabetically; a count of 1 is not written
assert(strcmp(editChemicalFormula('C6H12O6'), 'C6H12O6'));
assert(strcmp(editChemicalFormula('MgCl2'), 'Cl2Mg'));
% the same element in several places is added up: CH3CH2OH has 2 C, 6 H, 1 O
assert(strcmp(editChemicalFormula('CH3CH2OH'), 'C2H6O'));
% text given as a string is accepted
assert(strcmp(editChemicalFormula("H2O"), 'H2O'));

%% generic side chains X, Y, * and FULLR become R

assert(strcmp(editChemicalFormula('CH3X'), 'CH3R'));
assert(strcmp(editChemicalFormula('C6H12O6R'), 'C6H12O6R'));

%% adding and removing atoms

% an empty edit changes nothing
assert(strcmp(editChemicalFormula('C6H12O6', []), 'C6H12O6'));
% remove one H from the existing 12 and add 2 N that are not in the formula yet
edit.elements = {'H', 'N'};
edit.times = [-1 2];
assert(strcmp(editChemicalFormula('C6H12O6', edit), 'C6H11N2O6'));

% change the directory
cd(currentDir)
