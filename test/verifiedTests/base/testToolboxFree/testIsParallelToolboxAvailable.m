% The COBRAToolbox: testIsParallelToolboxAvailable.m
%
% Purpose:
%     - isParallelToolboxAvailable tells whether the Parallel Computing Toolbox is installed and
%       licensed. The test checks that it returns a logical scalar, that it agrees with the
%       installation and licence checks it is defined by, and that a true answer means the
%       toolbox functions gcp and parpool can be found.
%
% Function under test:
%     src/base/utilities/toolboxFree/isParallelToolboxAvailable.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, no parallel pool is opened.
%
% Coverage exemptions:
%     None. The function is a single line, reached whether or not the toolbox is installed.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIsParallelToolboxAvailable'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% the answer is a logical scalar

available = isParallelToolboxAvailable();
assert(islogical(available) && isscalar(available));

%% the answer is the installation check combined with the licence check

isInstalled = ~isempty(ver('parallel'));
isLicensed = license('test', 'Distrib_Computing_Toolbox') == 1;
assert(isParallelToolboxAvailable() == (isInstalled && isLicensed));

%% when the toolbox is reported available, its pool functions exist

% a true answer is what lets the other helpers call gcp and parpool safely
if isParallelToolboxAvailable()
    assert(exist('gcp', 'file') ~= 0 && exist('parpool', 'file') ~= 0);
else
    fprintf('skipped: Parallel Computing Toolbox not installed or not licensed\n');
end

% change the directory
cd(currentDir)
