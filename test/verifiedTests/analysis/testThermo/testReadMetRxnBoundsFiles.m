% The COBRAToolbox: testReadMetRxnBoundsFiles.m
%
% Purpose:
%     - readMetRxnBoundsFiles sets default concentration bounds (concMin, concMax) and
%       reversible flux bounds [-1000, 1000], overwrites them with the bounds read from
%       optional tab-delimited metabolite and reaction files (warning for identifiers not in
%       the model) and stops with an error on a non-finite bound. A test would check the
%       resulting bounds against the files written in a tempname folder.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the documented optional printLevel cannot be omitted when a metabolite file
%       is given (first defect below), so this file makes no assertion about the function.
%
% Function under test:
%     src/analysis/thermo/experimentalData/readMetRxnBoundsFiles.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built model and bounds files, no solver.
%
% Coverage exemptions:
%     every line - readMetRxnBoundsFiles is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Omitting the optional printLevel fails when a metabolite file is read
%       SEVERITY: error
%       TRIGGER: readMetRxnBoundsFiles(model, 1, 1, 1e-5, 0.02, 'met.txt') with model.S = [-1 0;
%       1 -1], mets {'a[c]'; 'b[c]'}, rxns {'R1'; 'R2'} and met.txt holding the line
%       "a[c]<TAB>0.001<TAB>0.01"
%       OBSERVED: "Not enough input arguments." at line 87 (MATLAB R2025a): printLevel has no
%       default although metBoundsFile and rxnBoundsFile get one (lines 45-50)
%       EXPECTED: the bounds read silently, printLevel documented as an OPTIONAL INPUT
%       LINES: 87
%     - DEFECT: The concMax error message says Minimum
%       SEVERITY: cosmetic
%       TRIGGER: a model whose concMax holds Inf, with setDefaultConc = 0
%       OBSERVED: line 136 raises "<met> :Minimum concentration bound is not finite" for a
%       non-finite maximum (read from the code)
%       EXPECTED: "... :Maximum concentration bound is not finite"
%       LINES: 136
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadMetRxnBoundsFiles'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
