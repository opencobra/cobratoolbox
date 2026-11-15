% The COBRAToolbox: testRepresentativeMoiety.m
%
% Purpose:
%     - representativeMoiety(MMN) picks, for each moiety (row of MMN.L), the metabolite of
%       minimal mass among the metabolites that contain it (MMN.mol.Mass, MMN.mol.Mets), counts
%       the metabolites that share that minimal mass, computes a minimal mass fraction, and adds
%       the three columns MinimalMassMol, minimalMassFraction and NumMinimalMassMol to the moiety
%       table MMN.moi. (The file's function line names representativeMolecule; MATLAB calls it
%       by the file name.) The function is QUARANTINED (Constitution III-Defects, quarantine in
%       back-fill campaigns): minimalMassFraction is the minimal mass divided by itself, so it is
%       1 for every moiety; no assertion about the function is made.
%
% Function under test:
%     src/analysis/topology/conservedMoieties/representativeMoiety.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-built moiety-molecule network
%     structure (L, mol and moi tables).
%
% Coverage exemptions:
%     every line - representativeMoiety is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: minimalMassFraction is always 1
%       SEVERITY: wrong-result
%       TRIGGER: MMN.L = [1 1 0; 0 1 1]; MMN.mol = table({'a'; 'b'; 'c'}, [16; 32; 16],
%         'VariableNames', {'Mets', 'Mass'}); MMN.moi = table([12; 14], 'VariableNames',
%         {'Mass'}); out = representativeMoiety(MMN)
%       OBSERVED: out.moi.minimalMassFraction = [1; 1] (R2025a, 2026-11-15); MinimalMassMol =
%         {'a'; 'c'} and NumMinimalMassMol = [1; 1] are right. Line 35 divides minimumMass by
%         MMN.mol.Mass(ind(1)), which is minimumMass by construction of ind (line 30)
%       EXPECTED: the moiety/metabolite mass fraction, here [12/16; 14/16] = [0.75; 0.875]: the
%         sibling representativeMolecule.m computes moietyMasses(i)/minimumMass and documents
%         minimalMassFraction as "the moiety/metabolite mass fraction"; MMN.moi carries the
%         moiety Mass column (old/generateMoietyMoleculeNetwork.m, line 72); the tutorials
%         filter moieties on minimalMassFraction > 0.1, which is meaningless for a constant 1
%       LINES: 35
%     - DEFECT: MMN.moi is required but not documented
%       SEVERITY: limitation
%       TRIGGER: representativeMoiety(rmfield(MMN, 'moi')) with MMN as above
%       OBSERVED: error 'Unrecognized field name "moi".' (line 39)
%       EXPECTED: INPUT lists only .L and .mol and OUTPUT calls .moi an "added or updated
%         field"; either the input documentation names .moi (a table with one row per moiety)
%         or the field is created when absent
%       LINES: 39
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRepresentativeMoiety'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
