% The COBRAToolbox: testGetChargeFromInChI.m
%
% Purpose:
%     - getChargeFromInChI(InChI) returns the charge encoded in an InChI string, from its charge
%       (/q) and proton (/p) layers, with and without the protonation. Quarantined: no
%       behaviour of getChargeFromInChI is asserted until the defect below is fixed.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/inchi/getChargeFromInChI.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-written InChI strings.
%
% Coverage exemptions:
%     every line - getChargeFromInChI is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An empty component of a multi-component charge layer stops with an error
%       SEVERITY: error
%       TRIGGER: getChargeFromInChI('InChI=1S/Na.H2O/h;1H2/q+1;/p-1') (sodium hydroxide);
%         getChargeFromInChI('InChI=1S/2C2H4O2.Ca/c2*1-2(3)4;/h2*1H3,(H,3,4);/q;+2/p-2')
%         (calcium acetate); standard InChI leaves the charge of an uncharged component empty
%       OBSERVED: "Error: This statement is incomplete." raised by eval('') in the anonymous
%         function on line 43 (strsplit of '+1;' or ';+2' gives an empty component)
%       EXPECTED: an empty component counts as 0: sodium hydroxide charge 0 and
%         chargeWithoutProtons +1; calcium acetate charge 0 and chargeWithoutProtons +2
%       LINES: 41-46, 52-53
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetChargeFromInChI'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
