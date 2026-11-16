% The COBRAToolbox: testChangeRxnMets.m
%
% Purpose:
%     - changeRxnMets swaps metabolites in named reactions, or in a given number of randomly chosen
%       reactions that contain them, keeping or replacing their coefficients. A test would check the
%       modified columns of S and the list of modified reactions on a createModel model with a fixed
%       seed.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       the random selection (Rxn a number) changes the wrong reactions or fewer reactions than
%       requested (defects below), so this file makes no assertion about the function.
%
% Function under test:
%     src/reconstruction/refinement/changeRxnMets.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a createModel model, a fixed seed, no solver.
%
% Coverage exemptions:
%     every line - changeRxnMets is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: With one metabolite to change, the random selection reduces the S row to a scalar
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'r1','r2','r3'}, {'r1','r2','r3'}, {'A -> B','A + C -> D','E
%       -> F'}) plus metabolite Z[c]; changeRxnMets(model, {'A[c]'}, {'Z[c]'}, 2)
%       OBSERVED: ModifiedRxns = {'r1'} and two warnings that fewer reactions contain the
%       metabolite (MATLAB R2025a): all() and any() of the 1 x n row at lines 63-64 return a
%       scalar, so the indices found are 1 or empty instead of the reactions r1 and r2 that
%       contain A[c]
%       EXPECTED: ModifiedRxns = {'r1'; 'r2'} (both reactions containing A[c]), no warning
%       LINES: 63-64
%     - DEFECT: The extra reactions are drawn from a set that already contains the selected ones
%       SEVERITY: wrong-result
%       TRIGGER: the model above; rng(3); changeRxnMets(model, {'A[c]', 'C[c]'}, {'Z[c]', 'E[c]'},
%       2)
%       OBSERVED: ModifiedRxns = {'r2'} only (MATLAB R2025a, seeds 3 and 4; seeds 1, 2 and 5 give
%       r1 and r2): line 72 draws Rxn - numel(RxnsIndAll) reactions from RxnsIndAny, which
%       includes RxnsIndAll, and the union drops repeats; line 67 adds the two counts, which
%       double counts the same reactions
%       EXPECTED: 2 reactions modified (r1 and r2, the only reactions containing A[c] or C[c])
%       LINES: 67-72
%     - DEFECT: A partly unknown reaction list is not reported
%       SEVERITY: cosmetic
%       TRIGGER: Rxn = {'r1', 'missing'}
%       OBSERVED: line 54 min(RxnsInd == 0) is true only when every reaction is missing, so the
%       documented error is skipped and an indexing error follows (read from the code)
%       EXPECTED: the error 'A reaction wasn't found in your model!'
%       LINES: 54
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testChangeRxnMets'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
