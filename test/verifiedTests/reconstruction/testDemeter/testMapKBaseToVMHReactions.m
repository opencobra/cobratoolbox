% The COBRAToolbox: testMapKBaseToVMHReactions.m
%
% Purpose:
%     - mapKBaseToVMHReactions rewrites the formulas of the VMH reaction database
%       (loadVMHDatabase) and of KBase reactions with translated metabolite identifiers in
%       one normalized form, and returns the KBase reactions whose formula equals a VMH
%       formula: as the same reaction when the reversibility agrees, as a similar reaction
%       when it does not (documented: "irreversible in VMH and reversible in KBase (or vice
%       versa)"). The function is QUARANTINED (Constitution III-Defects, quarantine in
%       back-fill campaigns): a KBase reaction that is irreversible while the VMH reaction is
%       reversible is never found, so no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/demeter/src/integration/mapKBaseToVMHReactions.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write a small VMH database by hand in a
%     temporary folder.
%
% Coverage exemptions:
%     every line - mapKBaseToVMHReactions is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A KBase reaction irreversible where the VMH reaction is reversible is not reported as similar
%       SEVERITY: wrong-result
%       TRIGGER: current folder d holding MetaboliteDatabase.txt (one 13-column row) and
%         ReactionDatabase.txt (12-column header and the rows RXNA 'a[c] + g[c] <=> b[c]'
%         reversible 1, RXNB 'c[c] -> d[c]' reversible 0, RXNC 'e[c] <=> f[c] + h[c]'
%         reversible 1); kb = {'k1', 'x', 'a[c] + g[c] -> b[c]'; 'k2', 'x', 'c[c] <=> d[c]';
%         'k3', 'x', 'f[c] + h[c] <=> e[c]'}; [same, similar] = mapKBaseToVMHReactions(kb)
%       OBSERVED: same holds k3/RXNC and similar holds k2/RXNB (reversible in KBase,
%         irreversible in VMH), but k1/RXNA is in neither table: a reversible VMH reaction is
%         written only with '<=>' (lines 80-87) and an irreversible KBase reaction only with
%         '->', so the two strings never meet in the intersect of line 154 (R2025a,
%         2026-11-15)
%       EXPECTED: k1/RXNA in similarReactions (irreversible in KBase, reversible in VMH: the
%         documented "or vice versa" case)
%       LINES: 80-87, 138-149
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMapKBaseToVMHReactions'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
