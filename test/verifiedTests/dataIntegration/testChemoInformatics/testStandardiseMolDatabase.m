% The COBRAToolbox: testStandardiseMolDatabase.m
%
% Purpose:
%     - standardiseMolDatabase copies a folder of MDL MOL files into <standardisedDir>/molFiles,
%       standardises them with Open Babel when it is installed (otherwise only rewrites the
%       three header lines, approach 'basic') and returns a report. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): when no MOL file is
%       selected it stops with an undefined variable instead of returning an empty report, so
%       no assertion about the function is made.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/metabolites/standardiseMolDatabase.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written MOL files in a temporary folder and PATH set to
%     an empty temporary folder (approach 'basic') would suffice. Open Babel and cxcalc cannot
%     be run from MATLAB on the reference machine.
%
% Coverage exemptions:
%     every line - standardiseMolDatabase is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: No selected MOL file stops with an undefined variable standardised
%       SEVERITY: error
%       TRIGGER: standardiseMolDatabase(molDir, {'nothing'}, outDir) where molDir holds
%         met1.mol and met2.mol (or an empty molDir), PATH without obabel and cxcalc
%       OBSERVED: Standardizing 0 MOL files ... then Unrecognized function or variable
%         'standardised'. (line 221; R2025a, 2026-11-15); nonStandardised and InChIs are
%         initialised at lines 108-109 but standardised is not
%       EXPECTED: a report with an empty standardised list
%       LINES: 221
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testStandardiseMolDatabase'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
