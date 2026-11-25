% The COBRAToolbox: testFVAOptForce.m
%
% Purpose:
%     - FVAOptForce(model, constrW, constrM) runs flux variability on every reaction of the
%       model under the constraints of the wild-type strain and under those of the mutant
%       strain, and returns the minimum and maximum fluxes of both and two summary tables
%       (reaction, minimum, maximum). The function is quarantined for the defects below: this
%       file asserts nothing about it.
%
% Function under test:
%     src/design/optForce/FVAOptForce.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - flux variability (LP) (quarantined: no solver is used here).
%
% Coverage exemptions:
%     every line - FVAOptForce is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The third column of boundsW and boundsM holds the minimum fluxes instead of the maximum fluxes
%       SEVERITY: wrong-result
%       TRIGGER: any call that requests boundsW or boundsM; reproduction: model = createModel(
%         {'EX_a'; 'EX_b'; 'T'}, {''; ''; ''}, {'a[e] <=> '; 'b[e] <=> '; 'a[e] <=> b[e]'},
%         'printLevel', 0); model.c(:) = 0; model = changeRxnBounds(model, 'T', 0, 'l');
%         [minW, maxW, minM, maxM, boundsW, boundsM] = FVAOptForce(model, struct('rxnList',
%         {{'T'}}, 'rxnValues', 4, 'rxnBoundType', 'u'), struct('rxnList', {{'T'}},
%         'rxnValues', 2, 'rxnBoundType', 'l'))
%       OBSERVED: (R2025a, 2026-11-25, gurobi) maxW = [0; 4; 4] but boundsW(:, 3) = {-4; 0; 0}
%         (equal to boundsW(:, 2) and minW); maxM = [-2; 1000; 1000] but boundsM(:, 3) =
%         {-1000; 2; 2}: lines 145 and 159 put num2cell of the minimum fluxes in both columns
%       EXPECTED: the third column holds the maximum values (help text of boundsW and boundsM)
%       LINES: 145, 159
%     - DEFECT: Constraints for only one strain stop the function although the help asks for at least one
%       SEVERITY: error
%       TRIGGER: constrW or constrM omitted or empty; with the model and structures above:
%         FVAOptForce(model, constrW) or FVAOptForce(model, [], constrM)
%       OBSERVED: (R2025a, 2026-11-25) error "OptForce: You should specify constraints for at
%         least one strain" at line 82 in both calls; the condition of line 81 joins the two
%         tests with || instead of &&, so lines 86 and 109 (the empty defaults) are
%         unreachable
%       EXPECTED: "Constraints should be specified for at least one strain" (help text): a
%         missing constrW or constrM means no constraint for that strain (lines 85-86, 108-109)
%       LINES: 81-82, 86, 109
%     - DEFECT: The help describes maxFluxesM as the minimum values of the wild-type strain
%       SEVERITY: cosmetic
%       TRIGGER: reading the help text of the output maxFluxesM
%       OBSERVED: "maxFluxesM: (double array) minimum values for reactions in the wild-type
%         strain"
%       EXPECTED: maximum values for reactions in the mutant strain (what line 156 returns)
%       LINES: 51-53
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFVAOptForce'));
cd(fileDir);

% FVAOptForce is quarantined: the standard opening only, no requirement is declared because
% nothing is solved
prepareTest();

% change the directory
cd(currentDir)
