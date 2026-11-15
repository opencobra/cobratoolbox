% The COBRAToolbox: testWrite4ti2.m
%
% Purpose:
%     - write4ti2(SeFull, filename, uni) integerises a stoichiometric matrix and writes it as
%       a 4ti2 input file (<filename>_Bi.4ti2in, or <filename>_Uni.4ti2in with every second
%       reaction when uni = 1). The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): it fails on every input before writing anything;
%       no assertion about the function is made.
%
% Function under test:
%     src/base/io/utilities/write4ti2.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write a hand-built matrix to a temporary
%     folder and read the file back.
%
% Coverage exemptions:
%     every line - write4ti2 is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: integerizeS is called with a matrix but needs a model structure
%       SEVERITY: error
%       TRIGGER: write4ti2([1 -1; 0 1], 'x', 0) (also with uni = 1)
%       OBSERVED: (R2025a, 2026-11-15) error "Dot indexing is not supported for variables of
%         this type." raised in integerizeS line 39 (size(model.S)); line 17 passes the matrix
%         SeFull, and the comment there says integerizeS is not defined in the toolbox, while
%         src/analysis/topology/integerizeS.m now takes a model and returns a model
%       EXPECTED: the documented input "SeFull: full stoichiometric matrix" is integerised and
%         written, e.g. integerizeS(struct('S', SeFull), 0, 0) and its .S field
%       LINES: 17
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWrite4ti2'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
