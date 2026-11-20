% The COBRAToolbox: testCheckChemoinformaticDependencies.m
%
% Purpose:
%     - checkChemoinformaticDependencies reports whether the external programs cxcalc
%       (ChemAxon), obabel (Open Babel) and java can be run from the system path. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): when java
%       cannot be run it reads a variable options that it never defines and stops with an
%       error, so no assertion about the function is made.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/checkChemoinformaticDependencies.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would set the PATH environment variable to a
%     temporary folder (with or without stand-in scripts) to reach each branch.
%
% Coverage exemptions:
%     every line - checkChemoinformaticDependencies is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A system without java stops with an undefined variable options
%       SEVERITY: error
%       TRIGGER: checkChemoinformaticDependencies() when java is not on the system path
%         (reproduced with setenv('PATH', <empty temporary folder>))
%       OBSERVED: Unable to resolve the name 'options.atomMapping'. (line 39; R2025a,
%         2026-11-15), after the messages cxcalc is not installed and obabel is not installed
%       EXPECTED: javaInstalled = false and the message java is not installed
%       LINES: 39-41
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckChemoinformaticDependencies'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
