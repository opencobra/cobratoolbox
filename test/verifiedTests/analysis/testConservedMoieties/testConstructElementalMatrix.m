% The COBRAToolbox: testConstructElementalMatrix.m
%
% Purpose:
%     - constructElementalMatrix counts, for each metabolite formula, the atoms of every
%       element (numAtomsOfElementInFormula) and, when charges are given, the electrons
%       (sum of atomic numbers minus charge), and returns the elemental matrix restricted to
%       the elements present, in alphabetical order. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): the data file
%       atomicNumbers.mat it loads is no longer in the repository, so every call stops with
%       an error (defect below); no assertion about the function is made.
%
% Function under test:
%     src/analysis/topology/conservedMoieties/constructElementalMatrix.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built formulas and charges whose
%     atom and electron counts are computed by hand.
%
% Coverage exemptions:
%     every line - constructElementalMatrix is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call stops because atomicNumbers.mat is missing
%       SEVERITY: error
%       TRIGGER: constructElementalMatrix({'H2O'; 'CO2'; 'HO'}, [0; 0; -1]) (any input)
%       OBSERVED: 'Error using load: Unable to find file or directory
%         'atomicNumbers.mat'.' at line 30 (MATLAB R2025a, after initCobraToolbox); the file
%         src/analysis/topology/conservedMoieties/atomicNumbers.mat was deleted by commit
%         008e0e4f51 (2020-10-31) and no copy exists anywhere in the repository.
%       EXPECTED: the element symbols and atomic numbers are loaded and the elemental matrix
%         is returned, e.g. H2O -> H 2, O 1, e 10
%       LINES: 30
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConstructElementalMatrix'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
