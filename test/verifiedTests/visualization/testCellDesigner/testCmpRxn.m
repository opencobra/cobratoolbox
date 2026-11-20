% The COBRAToolbox: testCmpRxn.m
%
% Purpose:
%     - cmpRxn compares the reaction identifiers of a parsed CellDesigner model
%       (parsed.r_info.ID, one row per reaction, one column per identifier form) with the
%       reactions of a COBRA model (case-insensitive substring search), lists the found and
%       not found reactions, the substrates and products of each matched COBRA reaction, and
%       the COBRA reactions absent from the parsed model. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): a parsed model none of
%       whose reactions is in the COBRA model raises an error (defect below); no assertion
%       about the function is made.
%
% Function under test:
%     src/visualization/cellDesigner/cmpRxn.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; a test would use a hand-built model with a
%     3 x 2 S matrix and a hand-built parsed structure.
%
% Coverage exemptions:
%     every line - cmpRxn is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A parsed model with no reaction found in the COBRA model raises an error
%       SEVERITY: error
%       TRIGGER: parsed.r_info.ID = {'re1', 'nomatch'}; model.rxns = {'R1'; 'R2'};
%         model.mets = {'a'; 'b'; 'c'}; model.S = sparse([-1 0; 1 -1; 0 1]);
%         cmpRxn(parsed, model)
%       OBSERVED: (R2025a, 2026-11-16) error MATLAB:UndefinedFunction "Unrecognized function
%         or variable 'rea_M'." at line 217: rea_M is only created when a reaction is found
%       EXPECTED: results with listOfNotFound holding the parsed reaction and
%         list_of_rxns_not_present_in_ReferenceModel holding r1 and r2, as documented
%       LINES: 217
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCmpRxn'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
