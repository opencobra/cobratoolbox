% The COBRAToolbox: testOpenBabelConverter.m
%
% Purpose:
%     - openBabelConverter converts a molecule or reaction between SMILES, InChI, MDL MOL/RXN,
%       InChIKey and RInChI by calling the Open Babel program obabel. The test checks the only
%       behaviour that does not need Open Babel: when obabel cannot be found on the system path
%       (exit status 127), the function stops with the documented installation message, with
%       and without the optional output file argument. The system path is set to an empty
%       temporary folder for these calls and restored afterwards.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/openBabelConverter.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, no external program.
%
% Coverage exemptions:
%     Line 50: unreachable - isunix || ispc is true on every platform MATLAB supports (macOS
%     is unix), so the command name openbabel.obabel is never chosen.
%     Lines 58-125: need the external program Open Babel (obabel), which cannot be run from
%     MATLAB on the reference machine, so it is treated as not installed: input detection,
%     conversion, output parsing and saving.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOpenBabelConverter'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% make obabel unreachable: the system path holds only an empty temporary folder, so the shell
% answers "command not found" (status 127) whether or not Open Babel is installed
originalPath = getenv('PATH');
emptyFolder = tempname;
mkdir(emptyFolder);
setenv('PATH', emptyFolder);

installMessage = ['To use this function, Open Babel must be installed; follow the installation ' ...
    'instructions in https://openbabel.org/wiki/Category:Installation'];

%% without Open Babel the function stops with the installation message

% SMILES of L-alanine (example 3 of the help text), without an output file
assert(verifyCobraFunctionError('openBabelConverter', 'inputs', {'C[C@@H](C(=O)O)N', 'mol'}, ...
    'testMessage', installMessage));
% with an output file: the same message, and nothing is written
outputFile = [emptyFolder filesep 'alanine.mol'];
assert(verifyCobraFunctionError('openBabelConverter', ...
    'inputs', {'InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1', 'smiles', outputFile}, ...
    'testMessage', installMessage));
assert(~isfile(outputFile));

% restore the system path and remove the temporary folder
setenv('PATH', originalPath);
rmdir(emptyFolder, 's');

% change the directory
cd(currentDir)
