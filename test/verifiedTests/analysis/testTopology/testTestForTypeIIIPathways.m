% The COBRAToolbox: testTestForTypeIIIPathways.m
%
% Purpose:
%     - testForTypeIIIPathways closes the exchange reactions, runs a flux variability loop
%       (optimizeCbModel max and min of each reaction) to find blocked reactions, writes the
%       network in the expa format (convertModelToEX), runs the external program X3 on it and
%       prints whether X3 found Type III pathways (internal loops). The function is quarantined
%       for the defects below (an X3 answer of zero pathways is reported as pathways found; a
%       model without blocked reactions stops with an error). This file only opens the test; it
%       asserts nothing about the function.
%
% Function under test:
%     src/analysis/topology/testForTypeIIIPathways.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - FBA on a hand-built model; needs the external program X3 (expa), which is not
%     installed on the reference machine (the evidence below used a stand-in shell script).
%
% Coverage exemptions:
%     every line - testForTypeIIIPathways is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An X3 answer of zero Type III pathways is reported as pathways found
%       SEVERITY: wrong-result
%       TRIGGER: m = createModel({'EX_a','R1','R2','R3','R4','EX_b'}, {'','','','','',''},
%         {' -> a[c]','a[c] -> b[c]','b[c] <=> c[c]','c[c] <=> d[c]','d[c] <=> b[c]','b[c] -> '},
%         'printLevel', 0); m.lb(1) = 0; m.ub(1) = 10; m = changeObjective(m, 'EX_b');
%         testForTypeIIIPathways(m, [1; 6], fullfile(tempname, 'toy')) with a stand-in X3 first
%         on the PATH that prints "There are 0 Type III pathways"
%       OBSERVED: (R2025a, gurobi, 2026-11-25) "Type III pathways were found in model. A table
%         of Type III pathways can be found in .../toy_myT3.txt": line 64 compares the
%         character after 'There are ' with 0, and every character code is above 0, so the
%         branch of lines 69-71 is reached only when the text is absent
%       EXPECTED: "No Type III pathways can be found in model." when X3 counts zero pathways
%         (the digit, not its character code, is compared)
%       LINES: 64
%     - DEFECT: A model without blocked reactions stops with an error
%       SEVERITY: error
%       TRIGGER: ml = createModel({'R2','R3','R4'}, {'','',''}, {'b[c] <=> c[c]',
%         'c[c] <=> d[c]', 'd[c] <=> b[c]'}, 'printLevel', 0);
%         testForTypeIIIPathways(ml, [], fullfile(tempname, 'toy'))
%       OBSERVED: (R2025a, gurobi, 2026-11-25) error "Unrecognized function or variable
%         'rxnzero'." at line 54: rxnzero is assigned only inside the loop (line 42) when a
%         reaction is blocked
%       EXPECTED: an empty list of blocked reactions is passed to convertModelToEX
%       LINES: 41-43, 54
%     - DEFECT: All warnings are switched off and left off
%       SEVERITY: cosmetic
%       TRIGGER: any call, e.g. the first trigger above
%       OBSERVED: (R2025a, 2026-11-25) after the call warning('query', 'all').state is 'off':
%         line 22 runs "warning off all" and nothing restores the state of the caller
%       EXPECTED: warnings of the caller's session stay visible (Constitution VII-B)
%       LINES: 22
%     - DEFECT: The clean-up commands name files that cannot exist
%       SEVERITY: cosmetic
%       TRIGGER: the first trigger above with a stand-in X3 that prints neither ERROR nor
%         'There are '
%       OBSERVED: (R2025a, Linux, 2026-11-25) "rm: cannot remove '<f>_myT3_Sprs.txt<f>_myT3.txt
%         <f>_myRxnMet.txt': No such file or directory" (the three names are joined without
%         spaces, line 71) and "del: command not found" (line 74 uses the Windows command)
%       EXPECTED: the result files of X3 are removed on every platform
%       LINES: 71, 74
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTestForTypeIIIPathways'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file runs no
% solver and no external program; the call is the standard opening of a COBRA test and the
% place where the requirements (an LP solver, the program X3) are added when the test is
% written
prepareTest();

% change the directory
cd(currentDir)
