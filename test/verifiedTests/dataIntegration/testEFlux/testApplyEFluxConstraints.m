% The COBRAToolbox: testApplyEFluxConstraints.m
%
% Purpose:
%     - applyEFluxConstraints(model, expression, ...) rescales the flux bounds of a model by
%       the expression of its reactions (E-Flux, Colijn et al. 2009): the expression values,
%       given for reactions or mapped from genes, are divided by their maximum and become the
%       bounds; with softBounds, flexibility variables and constraints are added instead. The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       every call with reaction targets (preprocessed true, also the code's default) stops with
%       an error, and the soft forward bounds are not soft; no assertion about the function is
%       made.
%
% Function under test:
%     src/dataIntegration/transcriptomics/eFlux/applyEFluxConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a small hand-built model (createModel), no solver.
%
% Coverage exemptions:
%     every line - applyEFluxConstraints is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call with reaction targets stops with an error
%       SEVERITY: error
%       TRIGGER: model = createModel({'R1','R2','R3'}, {'R1','R2','R3'}, {'A <=> B','B -> C',
%         'C -> '}, 'printLevel', 0, 'grRuleList', {'g1','g2 or g3','g1 and g2'});
%         applyEFluxConstraints(model, struct('target', {{'R1';'R2'}}, 'value', [2; 4],
%         'preprocessed', true))
%       OBSERVED: (R2025a, 2026-11-23) "Conversion to double from cell is not possible." at line
%         82, which assigns expression.target (the names) instead of expression.value; the same
%         error occurs when no target is a reaction of the model
%       EXPECTED: per the help text (.value is the value of each target), lb = [-0.5; 0; 0] and
%         ub = [0.5; 1; 1]: R1 and R2 get 2/4 and 4/4, R3 has no value and stays unconstrained
%         (bound 1)
%       LINES: 82
%     - DEFECT: The documented default preprocessed = false (gene targets) is implemented as true
%       SEVERITY: wrong-result
%       TRIGGER: model as above; applyEFluxConstraints(model, struct('target',
%         {{'g1';'g2';'g3'}}, 'value', [2; 4; 1])) (no preprocessed field)
%       OBSERVED: (R2025a, 2026-11-23) "Conversion to double from cell is not possible." at line
%         82: lines 51-53 set preprocessed = true, so the gene targets are read as reactions
%       EXPECTED: the help text gives "Default: false", so the genes are mapped to reactions as
%         with 'preprocessed', false, which gives lb = [-0.4; 0; 0] and ub = [0.4; 1; 0.4]
%       LINES: 51-53
%     - DEFECT: With softBounds the forward bounds are not softened
%       SEVERITY: wrong-result
%       TRIGGER: model as above; applyEFluxConstraints(model, struct('target',
%         {{'g1';'g2';'g3'}}, 'value', [2; 4; 1], 'preprocessed', false), 'softBounds', true)
%       OBSERVED: (R2025a, 2026-11-23) evars {'Alpha_R1','Beta_R1','Beta_R2','Beta_R3'},
%         full(C) = [1 0 0; 1 0 0; 0 1 0; 0 0 1], full(D) = eye(4), d = [-0.4 0.4 1 0.4],
%         dsense 'GLLL', evarlb 0: the forward rows read v + beta <= e with beta >= 0, so beta
%         can only tighten the bound and a forward flux can never exceed e (the backward rows
%         v + alpha >= -e are softened as intended)
%       EXPECTED: flexibility variables that relax the forward bounds, v - beta <= e (D
%         coefficient -1), penalised by weightFactor as the backward ones are
%       LINES: 113, 117
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testApplyEFluxConstraints'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
