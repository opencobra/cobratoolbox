% The COBRAToolbox: testGetElementalWeightMatrix.m
%
% Purpose:
%     - getElementalWeightMatrix returns a #elements x 2 cell array of chemical element symbols
%       and atomic weights, read from the NIST table "Atomic Weights and Isotopic Compositions
%       for All Elements" shipped with the toolbox (parsed by
%       parse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elements). Once the defect is
%       fixed, the test should check
%         * the default (no input, [] or false): 114 elements (the distinct symbols of the table
%           without the isotopes D and T and the placeholders XYZ), unique, elements with a
%           standard atomic weight first in alphabetical order, then the 30 elements without one
%           (NaN); the standard weights of H, C, O and Ag are the IUPAC values printed in the
%           table (1.00794, 12.0107, 15.9994, 107.8682);
%         * true: the 16 biological elements get the mass of their predominant isotope (C-12,
%           H-1, O-16, Mo-98, I-127 as printed in the table), the others keep the default;
%         * a user-defined isotope abundance cell array: each element gets the
%           abundance-weighted mean of its isotope masses (hand calculation), D counts as H;
%         * the six input errors (wrong width, unknown element, non-positive mass number,
%           abundance outside [0, 1], unknown isotope, abundances not summing to 1).
%       The 114 and 30 were counted independently from the data file with a short Python
%       script (distinct "Atomic Symbol" values; weights given only as a mass number in
%       brackets have no standard atomic weight).
%       Quarantined: no behaviour of getElementalWeightMatrix is asserted until the
%       unusable-option defect below is fixed; this file only opens the test.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/molecularWeight/basicPhysicochemicalData/getElementalWeightMatrix.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; the input is the data file shipped with the toolbox.
%
% Coverage exemptions:
%     every line - getElementalWeightMatrix is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The help text documents an optional input printWarning that the function does
%         not have
%       SEVERITY: unusable-option
%       TRIGGER: getElementalWeightMatrix(true, true), the second documented optional input
%       OBSERVED: (R2025a, 2026-11-15) "Too many input arguments." (MATLAB:TooManyInputs); the
%         signature has one input, and unknown elements in isotopeAbundance always raise an
%         error (there is no warning to switch)
%       EXPECTED: the documented optional input printWarning accepted (a warning instead of an
%         error for unknown elements), or a help text that lists only isotopeAbundance
%       LINES: 16
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetElementalWeightMatrix'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
