% The COBRAToolbox: testDrawSecPot.m
%
% Purpose:
%     - drawSecPot(dietPath, rxnmax, startMet, levels, cutoff) loads a community model from a
%       .mat file, maximises rxnmax with fastFVA (IBM CPLEX), collects the reactions within
%       `levels` steps of startMet (inorder) and draws those whose flux exceeds the cutoff
%       with draw_by_rxn. Quarantined: no behaviour of drawSecPot is asserted until the
%       defect below is fixed.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/drawSecPot.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - fastFVA needs IBM CPLEX; the defects below were reproduced on a hand-built
%     five-reaction model with a stand-in fastFVA (fixed fluxes) in a tempname folder.
%
% Coverage exemptions:
%     every line - drawSecPot is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: No reaction above the cutoff stops with an error instead of drawing
%       SEVERITY: error
%       TRIGGER: drawSecPot(dietPath, rxnmax, startMet, levels, cutoff) with a cutoff at or
%         above the absolute flux of every reaction within levels of startMet, e.g. a model
%         with reactions R1 a[c] -> b[c], R2 b[c] -> c[c] (fluxes 2 and 0.3), startMet 'b[c]',
%         levels 1, cutoff 10
%       OBSERVED: (R2025a, 2026-11-25, stand-in fastFVA) "Conversion to cellstr from double is
%         not possible." from findRxnIDs line 21, called by draw_by_rxn line 181 from line 61:
%         rxngz stays the double [] set at line 46 and is passed as the reaction list, which
%         draw_by_rxn documents as a cell array (with {} draw_by_rxn stops at its line 480,
%         "Unrecognized function or variable 'matrix'")
%       EXPECTED: no reaction drawn (an empty map or a message), since the help allows any
%         cutoff
%       LINES: 46, 61
%     - DEFECT: The help describes the cutoff test differently from the code
%       SEVERITY: cosmetic
%       TRIGGER: a negative cutoff or a negative flux, e.g. the model above with levels 1,
%         cutoff -1
%       OBSERVED: (R2025a, 2026-11-25, stand-in fastFVA) R2 (flux 0.3) is drawn: line 52 keeps
%         abs(flux) > cutoff
%       EXPECTED: the help says "only fluxes>abs(cutoff) are considered", which excludes R2
%         (0.3 < 1) and every negative flux
%       LINES: 52
%     - DEFECT: Unsuppressed console output
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: (R2025a, 2026-11-25) "n = <count>" and one "ans = 'Progress ...'" per
%         reaction are printed (no semicolon at lines 48 and 51)
%       EXPECTED: no output, or output gated behind a printLevel
%       LINES: 48, 51
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDrawSecPot'));
cd(fileDir);

% declare the requirements of this test. The quarantined test calls nothing that needs a
% solver, MATLAB toolbox or particular operating system, so none is listed; the call is the
% standard opening of a COBRA test and the place where requirements are added once the
% defect is fixed
prepareTest();

% change the directory
cd(currentDir)
