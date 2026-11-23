% The COBRAToolbox: testFindRXNFiles.m
%
% Purpose:
%     - findRXNFiles(model, rxnfileDir) returns which metabolites and reactions of a model
%       have an atom-mapped RXN file (<rxn id>.rxn) in a folder, and which reactions are
%       internal (model.SConsistentRxnBool, else model.SIntRxnBool, else findSExRxnInd). The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       its third output is not assigned when every reaction has an RXN file; no assertion
%       about the function is made. findRXNFilesPlain (tested separately) is the copy that
%       always assigns it.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/RXN/findRXNFiles.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built models (createModel) and RXN files written to a tempname folder;
%     no solver.
%
% Coverage exemptions:
%     every line - findRXNFiles is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: internalRxnBool is not assigned when every reaction has an RXN file
%       SEVERITY: error
%       TRIGGER: model = createModel({'R1'}, {''}, {'h2[c] -> 2 h[c]'}, 'printLevel', 0);
%         a folder holding R1.rxn; [metRXNBool, rxnRXNBool, internalRxnBool] =
%         findRXNFiles(model, folder)
%       OBSERVED: (R2025a, 2026-11-23) "Output argument "internalRxnBool" (and possibly
%         others) not assigned a value in the execution with "findRXNFiles" function."
%         (MATLAB:unassignedOutputs): internalRxnBool is set only inside the block of line
%         45, which runs when some reaction has no RXN file; with two outputs the call works
%       EXPECTED: the documented n x 1 internalRxnBool (here true, R1 is internal), as
%         findRXNFilesPlain returns it
%       LINES: 45-73
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindRXNFiles'));
cd(fileDir);

% the function is quarantined: no requirement is declared and nothing calls it
prepareTest();

% change the directory
cd(currentDir)
