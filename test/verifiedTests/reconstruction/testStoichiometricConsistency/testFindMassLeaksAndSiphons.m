% The COBRAToolbox: testFindMassLeaksAndSiphons.m
%
% Purpose:
%     - findMassLeaksAndSiphons(model, metBool, rxnBool, modelBoundsFlag, param, printLevel)
%       finds the metabolites that can leak mass (max ||y||_0, S*v - y = 0, y >= 0) or act as
%       a siphon (S*v + y = 0, y >= 0), with or without the model's flux bounds, by
%       cardinality optimisation ('dc') or an LP ('quasiConcave'). The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): its documented default
%       uses the model bounds but the code ignores them, the 'quasiConcave' method swaps leaks
%       and siphons and stops with an error when no metabolite can leak, the status outputs
%       are empty instead of 0 for an infeasible problem, and param.theta has no effect; no
%       assertion about the function is made.
%
% Function under test:
%     src/reconstruction/modelGeneration/stoichConsistency/findMassLeaksAndSiphons.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP and cardinality optimisation; a test would declare prepareTest('needsLP',
%     true) and use hand-built networks (1 x 1, 3 x 4, 5 x 6).
%
% Coverage exemptions:
%     every line - findMassLeaksAndSiphons is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The model bounds are ignored by default although the documented default uses them
%       SEVERITY: wrong-result
%       TRIGGER: model.S = sparse(-1) (EX: A ->), model.lb = 0, model.ub = 10, model.mets,
%         model.rxns, model.metFormulas; [lM, lR, sM, sR, lY, sY] = findMassLeaksAndSiphons(model)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) leakMetBool = 1 and siphonMetBool = 1
%         (leakY = siphonY = 2): line 92 defaults modelBoundsFlag to 0, so the irreversible
%         consumption runs backwards. findMassLeaksAndSiphons(model, true, true, 1) returns
%         leakMetBool = 0, siphonMetBool = 1
%       EXPECTED: the help text gives modelBoundsFlag {0, (1)} and "with (default) or
%         without the bounds on a model": leakMetBool = 0, siphonMetBool = 1
%       LINES: 91-93
%     - DEFECT: The 'quasiConcave' method reports siphons as leaks and leaks as siphons
%       SEVERITY: wrong-result
%       TRIGGER: the model above; findMassLeaksAndSiphons(model, true, true, 1,
%         struct('method', 'quasiConcave'))
%       OBSERVED: (R2025a, gurobi, 2026-11-25) leakMetBool = 1, siphonMetBool = 0
%         (leakY = 10): the leak LP is S*v + p = 0, p >= 0 (line 162), i.e. net consumption,
%         and the siphon LP is S*v - p = 0 (line 201), the opposite of the 'dc' method and of
%         the help text (S*v - y = 0 with y >= 0 is the leak). method 'dc' returns
%         leakMetBool = 0, siphonMetBool = 1
%       EXPECTED: leakMetBool = 0, siphonMetBool = 1 (A can only be consumed)
%       LINES: 162-163, 184, 201-202, 213
%     - DEFECT: The 'quasiConcave' method stops with an error when the leak problem is infeasible
%       SEVERITY: error
%       TRIGGER: model.S = sparse(1) (EX: -> A), model.lb = 1, model.ub = 10;
%         findMassLeaksAndSiphons(model, true, true, 1, struct('method', 'quasiConcave'))
%       OBSERVED: (R2025a, gurobi, 2026-11-25) "Infeasibility while detecting semipositive
%         leaking metabolites." then "length of rowBool must equal size(A,1)" from
%         getCorrespondingCols line 64: line 188 sets leakY = [], so leakMetBool (line 312) is
%         empty; the 'dc' method sets leakY = sparse(nMet, 1) in the same case (line 282)
%       EXPECTED: no leaking metabolite (leakMetBool = false) and the siphon result
%       LINES: 186-190, 312-314
%     - DEFECT: The status outputs are empty instead of 0 when a problem is infeasible
%       SEVERITY: wrong-result
%       TRIGGER: model.S = sparse(-1), model.lb = 1, model.ub = 10; [lM, lR, sM, sR, lY, sY,
%         statp, statn] = findMassLeaksAndSiphons(model, true, true, 1)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) "Infeasibility while detecting semipositive
%         leaking metabolites.", statp = [] (0 x 0) and statn = 1; any status other than 1 of
%         optimizeCardinality or solveCobraLP becomes [] (lines 189, 218, 283, 305), so
%         statp == 0 is empty and an unbounded or invalid problem cannot be told apart
%       EXPECTED: statp = 0 (help text: 0 = Infeasible, 2 = Unbounded, -1 = Invalid input)
%       LINES: 189, 218, 283, 305
%     - DEFECT: param.theta has no effect
%       SEVERITY: unusable-option
%       TRIGGER: model.S = sparse([-1 0 1 -1; 1 -1 0 0; 0 1 -1 2]), lb = -10, ub = 10;
%         findMassLeaksAndSiphons(model, true(3, 1), true(4, 1), 1, struct('theta', 0.5)) and
%         the same with struct('theta', 100), each after rng(0)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) identical leakY: theta is read at line 121
%         and never used; optimizeCardinality is called without a parameter structure
%         (lines 262, 265, 289), so it uses its own default theta
%       EXPECTED: the documented "param.theta - (0.5) parameter of capped l1 approximation"
%         passed to optimizeCardinality
%       LINES: 121, 258-266, 289
%     - DEFECT: The documented default method is 'quasiConcave' but the code uses 'dc'
%       SEVERITY: cosmetic
%       TRIGGER: findMassLeaksAndSiphons(model) or a param without method
%       OBSERVED: (R2025a, gurobi, 2026-11-25) "dc method" is printed with printLevel 1;
%         lines 101 and 114 set method = 'dc' (help text: {('quasiConcave'), 'dc'})
%       EXPECTED: the help text and the code name the same default
%       LINES: 101, 114
%     - DEFECT: The printed list of leaking or siphon metabolites starts with metabolites that do not leak
%       SEVERITY: cosmetic
%       TRIGGER: model.S = sparse([-1 0 1 -1 0 0; 1 -1 0 0 0 0; 0 1 -1 2 0 0; 0 0 0 0 -1 1;
%         0 0 0 0 1 -1]) (A, B, C inconsistent through R4; D, E in a consistent cycle),
%         lb = -10, ub = 10, metFormulas {'C'; 'C'; 'C'; 'H'; 'H'};
%         findMassLeaksAndSiphons(model, true(5, 1), true(6, 1), 1, struct('method', 'dc'), 1)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) leakMetBool = [1 1 1 0 0] but the three
%         metabolites printed are D, E and A: log10(leakY) is sorted in ascending order
%         (lines 334, 377), so the zero entries (-Inf) come first
%       EXPECTED: the leaking (siphon) metabolites printed, largest first
%       LINES: 334, 377
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindMassLeaksAndSiphons'));
cd(fileDir);

% the function is quarantined: no requirement is declared and nothing calls it. When the
% defects are fixed, the test declares prepareTest('needsLP', true)
prepareTest();

% change the directory
cd(currentDir)
