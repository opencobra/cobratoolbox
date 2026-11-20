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
%     - DEFECT: With uni = 0 the file is closed twice and the call stops after writing it
%       SEVERITY: error
%       TRIGGER: write4ti2([1 -1; 0 1], fullfile(<tempname folder>, 'x'), 0), reached once line
%         17 passes the matrix (the real integerizeS stops the call at line 17 first)
%       OBSERVED: (R2025a, 2026-11-17, with a stand-in integerizeS on a temporary path that
%         returns its matrix input) x_Bi.4ti2in is written completely ("2 2", "1 -1 ", "0 1 ")
%         and the call then stops with "Invalid file identifier.  Use fopen to generate a valid
%         file identifier." at line 45: line 32 closes fid inside the uni == 0 branch and line
%         45, after the if/else, closes it again; with uni = 1 the same call returns normally
%       EXPECTED: the file written and the call returning, as for uni = 1
%       LINES: 32, 45
%     - DEFECT: The optional input uni has no default, so it cannot be omitted
%       SEVERITY: error
%       TRIGGER: write4ti2([1 -1; 0 1], fullfile(<tempname folder>, 'y')), reached once line 17
%         passes the matrix (the real integerizeS stops the call at line 17 first)
%       OBSERVED: (R2025a, 2026-11-17, same stand-in integerizeS) "Not enough input arguments."
%         (MATLAB:minrhs) at line 21 (if uni == 0); no file is written
%       EXPECTED: OPTIONAL INPUT documents "uni: {(0),1}", i.e. a default of 0: the matrix is
%         written to <filename>_Bi.4ti2in
%       LINES: 21
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
