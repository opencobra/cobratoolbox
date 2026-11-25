% The COBRAToolbox: testConvertToReversible.m
%
% Purpose:
%     - convertToReversible(model) converts a model in irreversible format (reactions split
%       into _f/_b pairs and reverse-only reactions tagged _r, as convertToIrreversible writes
%       them) back to reversible format: the _b reactions are removed, the bounds of each _f
%       reaction are widened to cover its _b partner, the S column and bounds of _r reactions
%       are negated, the tags are stripped from the ids, the field match is removed and
%       reversibleModel is set to true. Quarantined: no behaviour of convertToReversible is
%       asserted until the defect below is fixed.
%
% Function under test:
%     src/reconstruction/refinement/convertToReversible.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - a hand-built createModel model converted with convertToIrreversible and back;
%     a test would compare the FBA optima of the original, irreversible and reversible models
%     (LP solver).
%
% Coverage exemptions:
%     every line - convertToReversible is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The objective coefficient of a reverse-only reaction keeps the sign of the irreversible model
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'R1';'R2';'R3';'R4';'R5'}, {'r1';'r2';'r3';'r4';'r5'},
%         {' -> A'; 'A <=> B'; 'B -> '; 'C -> A'; 'C -> '}, [], [0; -10; 0; -4; 0],
%         [10; 10; 10; 0; 10]); model.c = [0; 0; 0; -1; 0]; irr = convertToIrreversible(model);
%         rev = convertToReversible(irr); optimizeCbModel(model), optimizeCbModel(irr),
%         optimizeCbModel(rev) (glpk)
%       OBSERVED: (R2025a, 2026-11-25) objective 4 for model and irr, 0 for rev: the S column and
%         the bounds of R4_r are negated back (rev.S(:,4) = [1; 0; -1], rev.lb(4) = -4,
%         rev.ub(4) = 0, as in model) but rev.c(4) = 1 keeps the sign that convertToIrreversible
%         gave it (model.c(4) = -1), so rev maximises +R4 instead of -R4
%       EXPECTED: rev.c(4) = -1: the model in reversible format describes the same problem as
%         the input (the objective coefficient flipped together with the S column and the
%         bounds, as convertToIrreversible does: "Also flip the objective coefficient, as
%         otherwise the target changes")
%       LINES: 50-53
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertToReversible'));
cd(fileDir);

% the standard opening of a COBRA test; the requirements of the full test (an LP solver) are
% declared here once the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
