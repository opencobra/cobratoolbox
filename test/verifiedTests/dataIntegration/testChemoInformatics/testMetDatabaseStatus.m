% The COBRAToolbox: testMetDatabaseStatus.m
%
% Purpose:
%     - metDatabaseStatus compares the metabolites of a COBRA model with a folder of MDL MOL
%       files: which structures are missing, whether the formula and charge of each structure
%       agree with the model, and how many identifiers each metabolite has. Quarantined: no
%       behaviour of metDatabaseStatus is asserted until the defects below are fixed.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/metabolites/metDatabaseStatus.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - reporting on a createModel toy model and MOL files written to a tempname
%     folder, no solver.
%
% Coverage exemptions:
%     every line - metDatabaseStatus is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The labels inconsistentCharge and inconsistentFormula are swapped
%       SEVERITY: wrong-result
%       TRIGGER: model met glc[c] with metFormulas 'C6H12O6' and metCharges 0, and a file
%         glc.mol with one carbon atom and no charge line
%       OBSERVED: status "inconsistentCharge" and summary.inconsistentCharge = 1, although
%         the charges agree (modelCharge 0, structureCharge 0) and the formulas differ
%         (modelFormula "C6H12O6", structureFormula "C"); case 1 (charge equal, formula
%         different) is labelled inconsistentCharge and case 3 inconsistentFormula
%       EXPECTED: status "inconsistentFormula" for a formula mismatch with equal charges
%       LINES: 128-131
%     - DEFECT: A metabolite whose identifier contains mol after another character is
%       reported missing
%       SEVERITY: wrong-result
%       TRIGGER: model met amol[c] and a file amol.mol in metDir
%       OBSERVED: status "missing", structureFormula "missing", structureCharge NaN and
%         summary.missing = 1 - line 33 strips the extension with the regular expression
%         '.mol', whose dot matches any character, so 'amol.mol' becomes '' (MATLAB:
%         regexprep({'amol.mol'; 'glc.mol'}, '.mol', '') returns {''; 'glc'})
%       EXPECTED: the structure found and compared with the model
%       LINES: 33
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMetDatabaseStatus'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
