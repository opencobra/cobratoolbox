% The COBRAToolbox: testGeneratePanDatabase.m
%
% Purpose:
%     - generatePanDatabase loads every model of inputDir, merges their stoichiometric
%       matrices into one pan S matrix (union of metabolites and reactions), records which
%       model holds which reaction and metabolite, and saves the result as
%       panModel_lookupFile_PD_recreated.mat in the current folder. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): the merge
%       writes the coefficients of new metabolites and reactions to the wrong rows and
%       columns (defects below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/persephone/additionalFunctions/generatePanDatabase.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; a test would use a temporary folder of tiny
%     hand-built models (and a parallel pool when the machine has more than five cores).
%
% Coverage exemptions:
%     every line - generatePanDatabase is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Coefficients of new metabolites are written to the wrong rows
%       SEVERITY: wrong-result
%       TRIGGER: folder d with mA.mat (struct model, rxns = {'r1'}, mets = {'x'}, S = sparse(1))
%         and mB.mat (rxns = {'r1'}, mets = {'x'; 'z'; 'y'}, S = sparse([1; 2; 3]));
%         p = generatePanDatabase(d); s = load(p)
%       OBSERVED: s.panModel.mets = {'x'; 'y'; 'z'} and full(s.panModel.S) = [1; 2; 3]. The new
%         metabolites are appended in sorted order (setdiff, line 159) but their rows are
%         taken from model 2 in its own order (matches, line 179).
%       EXPECTED: [1; 3; 2] (y has the coefficient 3 and z the coefficient 2 in mB)
%       LINES: 176-181
%     - DEFECT: Coefficients of new reactions are written to the wrong columns
%       SEVERITY: wrong-result
%       TRIGGER: as above with mB.mat (rxns = {'r1'; 'r3'; 'r2'}, mets = {'x'},
%         S = sparse([1 3 2]))
%       OBSERVED: s.panModel.rxns = {'r1' 'r2' 'r3'} and full(s.panModel.S) = [1 3 2] (setdiff on
%         line 186 sorts, matches on line 207 keeps the order of model 2)
%       EXPECTED: [1 2 3] (r2 has the coefficient 2 and r3 the coefficient 3 in mB)
%       LINES: 203-208
%     - DEFECT: The documented default inputDir needs an explicit empty argument
%       SEVERITY: limitation
%       TRIGGER: generatePanDatabase()
%       OBSERVED: MATLAB:minrhs, Not enough input arguments. (line 18 reads inputDir);
%         generatePanDatabase([]) uses the default 'AGORA2'
%       EXPECTED: the call without argument uses the default 'AGORA2' given in the header
%       LINES: 18
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGeneratePanDatabase'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
