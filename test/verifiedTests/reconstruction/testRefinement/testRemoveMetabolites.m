% The COBRAToolbox: testRemoveMetabolites.m
%
% Purpose:
%     - removeMetabolites(model, metRemoveList, removeRxnFlag, rxnRemoveMethod) removes the
%       listed metabolites from every metabolite field of the model and, when removeRxnFlag is
%       true, the reactions they leave behind ('inclusive': every reaction of a removed
%       metabolite; 'exclusive': reactions involving only removed metabolites; 'legacy': every
%       empty column), returning the removed reaction identifiers.
%       Quarantined: no behaviour of removeMetabolites is asserted until the defect below is
%       fixed.
%
% Function under test:
%     src/reconstruction/refinement/removeMetabolites.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation on a hand-built model; no solver (the ledger listed the row as
%     Tier 3; the function calls removeRxns without the 'infeasible' option, so no solver runs).
%
% Coverage exemptions:
%     every line - removeMetabolites is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Removing every metabolite returns the input model unchanged
%       SEVERITY: wrong-result
%       TRIGGER: m.S = sparse([-1 0 0 0; 1 -1 0 0; 0 1 -1 0; 0 0 1 -1]); m.mets = {'A';'B';'C';'D'};
%         m.rxns = {'R1';'R2';'R3';'R4'}; m.lb = zeros(4,1); m.ub = 10*ones(4,1);
%         m.c = [0;0;0;1]; m.b = zeros(4,1); m.csense = repmat('E',4,1);
%         o = removeMetabolites(m, m.mets); [o, list] = removeMetabolites(m, m.mets); the same
%         happens for any removal from a model with no reactions (S of size m x 0)
%       OBSERVED: (R2025a, 2026-11-25) size(o.S) = [4 4] and isequal(o, m) = 1; with two outputs
%         the call errors "Output argument "rxnRemovedList" (and possibly others) not assigned a
%         value"; for a 2 x 0 model with mets {'A';'B'}, removeMetabolites(e0, {'A'}) keeps
%         mets {'A';'B'}. Line 63 returns the input model when the reduced S is empty, before
%         line 91 assigns the reduced model
%       EXPECTED: a model without the removed metabolites (0 x 0 S for the first trigger, with
%         every reaction removed by the default 'inclusive' method) and the list of removed
%         reactions
%       LINES: 62-63
%     - DEFECT: rxnRemovedList is a double [] instead of a cell array when removeRxnFlag is false
%       SEVERITY: cosmetic
%       TRIGGER: [o, list] = removeMetabolites(m, {'A'}, false) with m as above
%       OBSERVED: (R2025a, 2026-11-25) class(list) = 'double'
%       EXPECTED: an empty cell array, as the help documents rxnRemovedList as a cell array of
%         reaction abbreviations (removeRxnFlag true with nothing removed gives a 0 x 1 cell)
%       LINES: 88
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveMetabolites'));
cd(fileDir);

% the standard opening of a COBRA test; the full test needs no requirement
prepareTest();

% change the directory
cd(currentDir)
