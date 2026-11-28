% The COBRAToolbox: testRemoveRxns.m
%
% Purpose:
%     - removeRxns(model, rxnRemoveList, ...) removes the listed reactions from every reaction
%       field of the model, the metabolites they leave unused (metFlag, metRemoveMethod), the
%       additional constraints C, d, dsense, ctrs, ctrNames they leave behind
%       (ctrsRemoveMethod 'exclusive', 'inclusive', 'infeasible' with an LP per constraint, or
%       'legacy'), and updates the forward-backward match of an irreversible model (irrevFlag).
%       Quarantined: no behaviour of removeRxns is asserted until the defects below are fixed.
%
% Function under test:
%     src/reconstruction/refinement/removeRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - hand-built models; the 'infeasible' constraint option solves one LP per
%     constraint with solveCobraLP (LP solver).
%
% Coverage exemptions:
%     every line - removeRxns is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: ctrsRemoveMethod 'exclusive' and 'inclusive' are swapped
%       SEVERITY: wrong-result
%       TRIGGER: m.S = sparse([-1 0 0 0; 1 -1 0 0; 0 1 -1 0; 0 0 1 -1]); m.mets = {'A';'B';'C';'D'};
%         m.rxns = {'R1';'R2';'R3';'R4'}; m.lb = zeros(4,1); m.ub = 10*ones(4,1);
%         m.c = [0;0;0;1]; m.b = zeros(4,1); m.csense = repmat('E',4,1);
%         m.C = sparse([1 1 0 0; 0 0 1 1; 1 0 0 0; 0 0 0 0]); m.d = [5;6;7;0];
%         m.dsense = ['L';'L';'L';'L']; m.ctrs = {'mixed12';'mixed34';'only1';'empty'};
%         [o, mr, cr] = removeRxns(m, {'R1'}) (default 'exclusive') and the same call with
%         'ctrsRemoveMethod', 'inclusive'
%       OBSERVED: (R2025a, 2026-11-25) default: o.ctrs = {'mixed34'}, cr = {'mixed12','only1',
%         'empty'} (the constraint shared by the removed R1 and the kept R2 is removed);
%         'inclusive': o.ctrs = {'mixed12';'mixed34'}, cr = {'only1','empty'} (the constraint
%         involving the removed R1 is kept). Lines 169 and 173 pass the kept reactions
%         (selectRxns) as the column set, which inverts the meaning of both modes
%       EXPECTED: 'exclusive' (default) removes only constraints exclusively involved in removed
%         reactions (only1, as 'legacy' does); 'inclusive' removes every constraint involving a
%         removed reaction (mixed12 and only1), as the help states
%       LINES: 167-174
%     - DEFECT: ctrsRemoveMethod 'infeasible' keeps constraints the removal makes infeasible
%       SEVERITY: wrong-result
%       TRIGGER: m as above with m.C = sparse([1 1 0 0; 1 0 0 0; 0 0 1 1]); m.d = [15;7;1];
%         m.dsense = ['G';'G';'L']; m.ctrs = {'mixed12';'only1';'mixed34'};
%         o = removeRxns(m, {'R1'}, 'ctrsRemoveMethod', 'infeasible'); s = optimizeCbModel(o)
%         (glpk)
%       OBSERVED: (R2025a, 2026-11-25) o.ctrs = {'mixed12';'only1';'mixed34'}, cr = {''},
%         s.stat = 0: v2 >= 15 (ub 10) and 0 >= 7 remain. Line 179 tests only constraints that
%         involve no kept reaction (mixed12 is never tested) and line 184 tests feasibility with
%         the removed reactions' coefficients (v1 >= 7, feasible) instead of the kept ones
%       EXPECTED: constraints involving a removed reaction that are infeasible without it
%         (mixed12 and only1) are removed and the reduced model stays feasible
%       LINES: 179-184
%     - DEFECT: ctrsRemoveMethod 'legacy' returns {''} as ctrsRemovedList although it removes
%       constraints
%       SEVERITY: wrong-result
%       TRIGGER: [o, mr, cr] = removeRxns(m, {'R1'}, 'ctrsRemoveMethod', 'legacy') with the
%         four-constraint model of the first entry
%       OBSERVED: (R2025a, 2026-11-25) o.ctrs = {'mixed12';'mixed34'} (only1 and empty
%         removed) but cr = {''}: line 166 sets bool = 0, so line 221 reports nothing removed
%       EXPECTED: cr = {'only1';'empty'}, the model.ctrs that were removed
%       LINES: 161-166, 219-221
%     - DEFECT: ctrsRemoveMethod 'legacy' fails on a model with C but no ctrs
%       SEVERITY: error
%       TRIGGER: m2 = rmfield(m, 'ctrs') with the four-constraint model of the first entry;
%         removeRxns(m2, {'R1'}, 'ctrsRemoveMethod', 'legacy')
%       OBSERVED: (R2025a, 2026-11-25) error "Unrecognized field name "ctrs"." from
%         getEmptyConstraints called at line 164; line 223 would then read selectConstraints,
%         which the 'legacy' branch never defines
%       EXPECTED: the empty constraints are removed and ctrsRemovedList is the logical vector of
%         removed rows, as the help documents ctrs as read if present
%       LINES: 164, 223
%     - DEFECT: metRemovedList is {''} when metFlag is false
%       SEVERITY: cosmetic
%       TRIGGER: [o, mr] = removeRxns(m, {'R1'}, 'metFlag', false)
%       OBSERVED: (R2025a, 2026-11-25) mr = {0x0 char}, a list with one empty identifier
%       EXPECTED: an empty cell array: no metabolite was removed
%       LINES: 154
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveRxns'));
cd(fileDir);

% the standard opening of a COBRA test; the requirements of the full test (an LP solver for
% the 'infeasible' option) are declared here once the defects are fixed
prepareTest();

% change the directory
cd(currentDir)
