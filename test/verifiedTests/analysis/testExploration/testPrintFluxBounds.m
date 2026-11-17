% The COBRAToolbox: testPrintFluxBounds.m
%
% Purpose:
%     - printFluxBounds prints a table of reaction identifiers with their lower and upper
%       flux bounds, for all reactions or for a given list, optionally with the reaction
%       names. The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the documented calls without the third input stop with an error (defect
%       below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/exploration/printFluxBounds.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a test would use a hand-built model (createModel), no solver.
%
% Coverage exemptions:
%     every line - printFluxBounds is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented calls without rxnNameFlag stop with an error
%       SEVERITY: error
%       TRIGGER: printFluxBounds(model) or printFluxBounds(model, {'R1'}) for any model (the
%         usage line is printFluxBounds(model, rxns) and rxnNameFlag is listed as optional)
%       OBSERVED: after the header line 'Reaction ID  Lower Bound  Upper Bound', "Not enough
%         input arguments." at line 36 (MATLAB R2025a; model with two reactions R1, R2 built
%         with createModel): rxnNameFlag has no default value
%       EXPECTED: the bounds printed without reaction names, as with rxnNameFlag false
%       LINES: 36
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintFluxBounds'));
cd(fileDir);

% declare the requirements of this test: a Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system; the function is quarantined, so nothing below calls it
prepareTest();

% change the directory
cd(currentDir)
