% The COBRAToolbox: testForwardTransportQuantReverseFigures.m
%
% Purpose:
%     - forwardTransportQuantReverseFigures draws a horizontal errorbar figure (DrGt and
%       DrGt0 ranges, forward probability) of the qualitatively forward transport reactions
%       that are quantitatively reversible and are ABC transporters or involve protons
%       (h[c], h[e]), labelled with their names and formulas, and saves it as
%       forwardTransportQuantReverseBoolSetToForward.fig in the current folder. The function
%       is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): a model
%       without such a reaction stops with an error (defect below), so no assertion about
%       the function is made.
%
% Function under test:
%     src/analysis/thermo/directionalityReport/forwardTransportQuantReverseFigures.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a test would use a hand-built five-reaction createModel model with the
%     thermodynamic fields, invisible figures and a temporary folder; no solver.
%
% Coverage exemptions:
%     every line - forwardTransportQuantReverseFigures is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A model without a qualifying transport reaction stops with an error
%       SEVERITY: error
%       TRIGGER: model = createModel({'glc_abc'; 'ACt2r'; 'R3'; 'Bt'; 'Ht'}, {'glc abc';
%         'acetate symport'; 'internal'; 'B transport'; 'proton'}, {'A[e] -> A[c]'; 'A[e] +
%         h[e] -> A[c] + h[c]'; 'A[c] -> B[c]'; 'B[c] -> B[e]'; 'h[e] -> h[c]'}, [], zeros(5,
%         1), 10 * ones(5, 1)) with transportRxnBool = [1; 1; 0; 1; 1], DrGt0Min = [-10; -3;
%         -5; -2; 2], DrGt0Max = [4; -3; 1; 6; 2], DrGt0Mean = (DrGt0Min + DrGt0Max) / 2,
%         DrGtMin = [-20; -12; -9; -8; -6], DrGtMax = [9; 5; 4; 12; 10], DrGtMean = (DrGtMin
%         + DrGtMax) / 2, directions.forwardProbability = [0.8; NaN; 0.6; 0.4; NaN] and
%         directions.forwardReversible = false(5, 1): forwardTransportQuantReverseFigures(model)
%       OBSERVED: MATLAB R2025a: "Error setting property 'BaseValue' of class 'Bar': Value not
%         a numeric scalar" from barh at line 126: with no selected reaction minX (line 119)
%         is empty; read from the code, line 185 (max of the never assigned textLen) would
%         stop next. With
%         directions.forwardReversible = true(5, 1) the same model draws the figure with the
%         three selected reactions (ACt2r, glc_abc, Ht).
%       EXPECTED: an empty figure, or no figure, when no qualitatively forward transport
%         reaction is quantitatively reversible (a valid model)
%       LINES: 119-126, 185
%     - DEFECT: The fields transportRxnBool and directions.forwardProbability are required but not documented
%       SEVERITY: limitation
%       TRIGGER: the model above without transportRxnBool (or without
%         directions.forwardProbability)
%       OBSERVED: read from the code: line 38 reads model.transportRxnBool and line 67
%         directions.forwardProbability, neither listed under INPUT; the header lists
%         DrdGtMin, used only in the disabled branch of line 53
%       EXPECTED: the header lists the fields the function reads
%       LINES: 38, 67
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testForwardTransportQuantReverseFigures'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
