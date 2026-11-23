% The COBRAToolbox: testQuanQualAcc.m
%
% Purpose:
%     - quanQualAcc(validationData, predictedFlux, param) classifies measured exchange fluxes
%       as uptake, secretion or unchanged, compares the sign of the predicted fluxes with them
%       and returns a per-reaction report with statistics (weighted Euclidean norm, qualitative
%       accuracy, Spearman correlation). The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): a predicted flux below boundPrecisionLimit is not
%       treated as zero, so the predicted direction and the agreement are wrong for it; no
%       assertion about the function is made.
%
% Function under test:
%     src/dataIntegration/XomicsToModel/analysis/quanQualAcc.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no solver; a test would use hand-built tables. The function loads Recon3_3.mat
%     from the MATLAB path (found in the papers submodule) and uses only its reaction list.
%
% Coverage exemptions:
%     every line - quanQualAcc is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A predicted flux below boundPrecisionLimit is not treated as zero
%       SEVERITY: wrong-result
%       TRIGGER: validationData = table({'EX_glc_D[e]'; 'EX_lac_L[e]'; 'EX_ala_L[e]'},
%         [-1; 2; 0], [0.1; 0.5; 0.2], 'VariableNames', {'rxns', 'mean', 'SD'});
%         predicted = table({'EX_glc_D[e]'; 'EX_lac_L[e]'; 'EX_ala_L[e]'}, [-0.8; 1e-9; 1e-9],
%         'VariableNames', {'rxns', 'v'}); c = quanQualAcc(validationData, predicted)
%       OBSERVED: (R2025a, 2026-11-23, feasTol 1e-6 so boundPrecisionLimit 1e-5) the row of
%         EX_ala_L[e] has target 0, v 1e-09, predict 1, agree false; EX_lac_L[e] has v 1e-09,
%         predict 1, agree true - line 104 compares abs(sign(v)), which is 0 or 1, with the
%         limit instead of abs(v)
%       EXPECTED: predict 0 for both (the header: boundPrecisionLimit is the "flux magnitude
%         below which a value is treated as zero"; the comment at lines 102-103: "if the
%         predicted flux magnitude is below fluxEpsilon, the predicted flux is considered
%         zero"), so agree true for EX_ala_L[e] and false for EX_lac_L[e]
%       LINES: 104
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testQuanQualAcc'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
