% The COBRAToolbox: testCompareAllMets.m
%
% Purpose:
%     - compareAllMets scores every pair of metabolites of a compared model (Cmodel) and a
%       template model (Tmodel) by identifier, compartment, name, formula, charge, KEGG and
%       SEED identifiers, normalizes the scores to [0, 1] and plots their distribution. The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): when no pair has a positive score, the normalization calls the undefined
%       function zeroes and stops with an error, so no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/compareAllMets.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; a test would use hand-built metabolite
%     fields and an invisible figure.
%
% Coverage exemptions:
%     every line - compareAllMets is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Models with no positively scored metabolite pair stop with an undefined-function error
%       SEVERITY: error
%       TRIGGER: C.mets = {'a[c]'}; C.metNames = {'alpha'}; C.metFormulas = {'C1'};
%         C.metCharge = 0; C.metKEGGID = {''}; C.metSEEDID = {''}; T.mets = {'b[e]'};
%         T.metID = {'b'}; T.metNames = {'beta'}; T.metFormulas = {'C2'}; T.metCharge = 1;
%         T.metKEGGID = {''}; T.metSEEDID = {''}; compareAllMets(C, T)
%       OBSERVED: "Undefined function 'zeroes' for input arguments of type 'double'." at line
%         165: the only pair scores -1 - 100 - 1 - 5 - 1 < 0, is clipped to 0, and the
%         else branch calls zeroes (R2025a, 2026-11-15)
%       EXPECTED: a zero score matrix of size 1 x 1 (zeros(size(metScores))), as the branch
%         intends
%       LINES: 165
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareAllMets'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
