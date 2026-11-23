% The COBRAToolbox: testConvertToIrreversible.m
%
% Purpose:
%     - convertToIrreversible(model, ...) splits reversible reactions into forward (_f) and
%       backward (_b) reactions, flips reactions that can only carry negative flux (_r), and
%       extends or reorders every field associated with the reactions. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): the
%       coupling-constraint matrix C keeps its sign for flipped reactions, and orderReactions
%       errors for a model with C; no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/refinement/convertToIrreversible.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a hand-built model of three reactions (createModel) with one coupling
%     constraint; no solver.
%
% Coverage exemptions:
%     every line - convertToIrreversible is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Coupling constraints keep their sign for flipped (_r) reactions
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'R1', 'R2', 'R3'}, {'', '', ''}, {'a[c] <=> b[c]',
%         'b[c] <=> c[c]', 'c[c] <=> a[c]'}, 'lowerBoundList', [-10 -10 -10],
%         'upperBoundList', [10 0 10], 'printLevel', 0); model.C = sparse([1 2 3]);
%         model.d = 5; model.dsense = 'L'; model.ctrs = {'k1'}; model.ctrNames = {'k1'};
%         irrev = convertToIrreversible(model)
%       OBSERVED: (R2025a, 2026-11-23) irrev.rxns = {R1_f, R2_r, R3_f, R1_b, R3_b} and
%         full(irrev.C) = [1 2 3 -1 -3]: lines 83-88 negate S(:, R2), c and the bounds of the
%         flipped R2 but not C(:, R2), so the constraint v1 + 2*v2 + 3*v3 <= 5 becomes
%         v1 - 2*v2 + 3*v3 <= 5 in the original fluxes
%       EXPECTED: C = [1 -2 3 -1 -3]; the split backward reactions are negated (line 127),
%         and C must be negated in the same way for flipped reactions
%       LINES: 82-89
%     - DEFECT: orderReactions errors for a model with coupling constraints
%       SEVERITY: error
%       TRIGGER: the model above; convertToIrreversible(model, 'orderReactions', true)
%       OBSERVED: (R2025a, 2026-11-23) "Unable to perform assignment because the indices on
%         the left side are not compatible with the size of the right side." at line 182:
%         C (1 x 5) .* reacdir (5 x 1) expands to 5 x 5; with k constraints, k ~= 1 and k ~=
%         n, the product errors at line 181; the new columns were already negated at line 127,
%         so multiplying by reacdir would negate them a second time
%       EXPECTED: C with columns reordered as the reactions (backward after forward), signs
%         as after line 127
%       LINES: 180-182
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertToIrreversible'));
cd(fileDir);

% the function is quarantined: no requirement is declared and nothing calls it
prepareTest();

% change the directory
cd(currentDir)
