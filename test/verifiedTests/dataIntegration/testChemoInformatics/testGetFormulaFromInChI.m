% The COBRAToolbox: testGetFormulaFromInChI.m
%
% Purpose:
%     - getFormulaFromInChI(InChI) returns the chemical formula in the formula layer of an
%       InChI, corrected for the protonation layer (/p) and combined over the parts of a
%       composite formula, and the number of hydrogen atoms. Quarantined: no behaviour of
%       getFormulaFromInChI is asserted until the defects below are fixed.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/inchi/getFormulaFromInChI.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written InChI strings.
%
% Coverage exemptions:
%     every line - getFormulaFromInChI is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Element counts are assigned to the wrong elements on the combining path
%       SEVERITY: wrong-result
%       TRIGGER: getFormulaFromInChI('InChI=1S/C2H3Cl/c1-2-3/h2H,1H2/p+1') (any InChI with a /p
%         layer or a composite or multiplied formula whose element order differs from
%         alphabetical order, e.g. one containing Cl, Co, Br, Ca)
%       OBSERVED: formula 'C2Cl3H2', protons = 2; line 50 sorts the new elements alphabetically
%         (setdiff) but line 55 adds the coefficients in the order of the formula layer, so
%         Cl receives the 3 of H and H the 1 of Cl (plus the proton)
%       EXPECTED: C2, H4, Cl1 (e.g. 'C2H4Cl') and protons = 4
%       LINES: 50-55
%     - DEFECT: A formula that loses all its hydrogen atoms keeps one H
%       SEVERITY: wrong-result
%       TRIGGER: getFormulaFromInChI('InChI=1S/H2O4S/c1-5(2,3)4/h(H2,1,2,3,4)/p-2') (sulfate;
%         also phosphate 'InChI=1S/H3O4P/c1-5(2,3)4/h(H3,1,2,3,4)/p-3' and carbonate
%         'InChI=1S/CH2O3/c2-1(3)4/h(H2,2,3,4)/p-2')
%       OBSERVED: formula 'HO4S', protons = 0 (phosphate 'HO4P', carbonate 'CHO3'); the H
%         coefficient 0 is written as 'H0' (lines 59-64) and lines 72-79 replace 'H0' by 'H'
%       EXPECTED: 'O4S' (phosphate 'O4P', carbonate 'CO3'), protons = 0
%       LINES: 59-64, 72-79
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetFormulaFromInChI'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
