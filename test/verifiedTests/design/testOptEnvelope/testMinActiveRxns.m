% The COBRAToolbox: testMinActiveRxns.m
%
% Purpose:
%     - minActiveRxns(model, matchRev, K, minP, toDel, timeLimit, midPoints, printLevel) solves
%       a MILP for the smallest set of active reactions (toDel 0), genes (toDel 1) or enzymes
%       (toDel 2) that keeps the best production envelope, for the main point and midPoints mid
%       points, and returns them with the reduced models in data. Helper of optEnvelope. The
%       function is quarantined for the defects below: this file asserts nothing about it.
%
% Function under test:
%     src/design/optEnvelope/minActiveRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves MILPs and LPs (quarantined: no solver is used here).
%
% Coverage exemptions:
%     every line - minActiveRxns is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented options toDel = 1 (genes) and toDel = 2 (enzymes) always stop
%       with an error
%       SEVERITY: unusable-option
%       TRIGGER: m = createModel({'EX_a','R1','R2','BIO','EX_p'}, {'','','','',''}, {' -> a[c]',
%         'a[c] -> b[c]','a[c] -> p[c]','b[c] -> ','p[c] -> '}, 'lowerBoundList', [0 0 0 0 0],
%         'upperBoundList', [10 1000 1000 1000 1000], 'grRuleList', {'','g1','g2','',''},
%         'printLevel', 0); m = changeObjective(m, 'BIO'); minP = struct('bioID', 4, 'bioMin',
%         0.1, 'bioMax', 10, 'proID', 5, 'proMin', 0.1, 'proMax', 10);
%         data = minActiveRxns(m, zeros(5,1), [1 4 5], minP, 1) (or toDel 2)
%       OBSERVED: (R2025a, 2026-11-25, gurobi) 'Output argument "data" (and possibly others) not
%         assigned a value in the execution with "minActiveRxns" function.' for toDel 1 and 2:
%         the gene branch computes ActiveRxns and never assigns data; the enzyme branch is empty
%       EXPECTED: data with the active genes (toDel 1), or an error that says the option is not
%         available, as optEnvelope does
%       LINES: 188-237
%     - DEFECT: A protected biomass reaction stops the reaction branch with an error
%       SEVERITY: error
%       TRIGGER: the model and minP above with toDel 0: minActiveRxns(m, zeros(5,1), [1 4 5], minP),
%         K containing minP.bioID (the biomass reaction protected from knockout)
%       OBSERVED: (R2025a, 2026-11-25, gurobi) "Unrecognized function or variable 'ActiveRxns'."
%         at line 174. Lines 120 and 126 address the binary variable of the biomass and the
%         product as column nRxnsR + bioID (+ proID), but the binary variables exist only for
%         the reactions not in K (numbered in that order), so the column is wrong or beyond the
%         problem; the solver call fails inside try, and the catch block reads ActiveRxns, which
%         is not yet assigned. With the inputs optEnvelope builds (ecoli_core_model made
%         irreversible, product EX_ac(e), K = its 27 exchanges) no error occurs, but the product
%         constraint of line 126 acts on the binary variable of FBA_f, since the product
%         exchange is in K and has no binary variable of its own
%       EXPECTED: the binary variable of the reaction itself is used (or none when it is in K),
%         and data is returned
%       LINES: 119-120, 125-126, 173-176
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMinActiveRxns'));
cd(fileDir);

% minActiveRxns is quarantined: the standard opening only, no requirement is declared because
% nothing is solved
prepareTest();

% change the directory
cd(currentDir)
