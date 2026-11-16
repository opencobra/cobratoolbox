% The COBRAToolbox: testCalcdGHT.m
%
% Purpose:
%     - calcdGHT returns the standard transformed Gibbs energy of formation of a reactant (a
%       group of pseudoisomer species) at a given real pH, ionic strength and temperature, with
%       the mole fraction, average bound protons, average charge and activity coefficient of each
%       species (Alberty 2003). This test checks one and two species, the Legendre transformation
%       for pH switched on and off, the (no-op) electrical potential option, the van't Hoff
%       adjustment when standard enthalpies are given, numerically large energies (log-sum-exp),
%       the pH-range warning and the temperature and ionic-strength errors.
%     - Expected values come from Alberty's equations written out independently here (Eq. 3.6-3,
%       3.7-4, 4.4-9/10 of Alberty 2003): RTalpha = 9.20483e-3 T - 1.284668e-5 T^2
%       + 4.95199e-8 T^3, the extended Debye-Hueckel term RTalpha (z^2 - nH) sqrt(I) / (1 + 1.6
%       sqrt(I)), the pH term nH R T ln(10^-pH) and the partition function of the pseudoisomers.
%       Two literature anchors are checked as well: RTalpha = 2.91482 kJ/mol at 298.15 K (the
%       value Alberty 2003 uses at 298.15 K) and the pKa of acetic acid (4.76) obtained from
%       Alberty's species values (dGf0 acetic acid -396.46, acetate -369.31 kJ/mol).
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the severity audit T009a raised the defect below (a documented input is
%       ignored and a documented output is always NaN), so this file makes no assertion about
%       the function. The checks described above are those of the wave 05 version of this test
%       (git history), to be restored once the defect is fixed.
%
% Function under test:
%     src/analysis/thermo/reactantContribution/calcdGHT.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     every line - calcdGHT is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a). Before the quarantine the
%     test exempted line 69 and line 151 (inside "if 0", dead code), lines 197-408 (the
%     enthalpy branch "if ~isempty(dHzero)" directly follows "dHzero=[]" on line 195, so it is
%     unreachable by any input; the defect below), lines 414-636 (the multiple precision
%     toolbox branch; the condition on line 89 ends in "|| 1", so the else branch is
%     unreachable) and lines 687, 697-700, 711-747 (the local helper maxstar is called only as
%     maxstar(x) on line 173, so its argument-count error, its two- and three-argument forms
%     and its weighted sum are unreachable through calcdGHT).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The standard transformed enthalpy dHf0 is always NaN
%       SEVERITY: wrong-result
%       TRIGGER: any call, e.g. calcdGHT(-100, -50, -1, 3, 7, 0.25, 298.15)
%       OBSERVED: dHf0 = NaN; line 195 sets dHzero = [] before the enthalpy branch ("makes
%       script faster to leave this out for now")
%       EXPECTED: the documented output "reactant standard transformed enthalpy of formation";
%       dHzero is a documented OPTIONAL INPUT ("`p x 1` standard enthalpy of formation at
%       298.15 K") and dHf0 a documented OUTPUT, so the documented input is ignored and the
%       documented output is always NaN (severity audit T009a)
%       LINES: 195-196, 411
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Converted to the quarantine layout after the severity audit 2026-11-15 (T009a).

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalcdGHT'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
