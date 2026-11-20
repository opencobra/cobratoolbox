% The COBRAToolbox: testChangeCbMapOutput.m
%
% Purpose:
%     - changeCbMapOutput sets the global CB_MAP_OUTPUT (render format of drawCbMap) to
%       'matlab' or 'svg' (case-insensitive, stored as given) and returns 1; an unsupported
%       format gives a warning, returns 0 and leaves the global unchanged; without input it
%       prints the current format and returns 0. Expected values follow from the
%       documentation. The global is saved first and restored at the end.
%
% Function under test:
%     src/visualization/maps/ReconMap/changeCbMapOutput.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testChangeCbMapOutput'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% save the global render format (it may not exist yet) to restore it at the end
globalsBefore = who('global');
global CB_MAP_OUTPUT
savedOutput = CB_MAP_OUTPUT;

%% supported formats are set and acknowledged with 1

isSet = changeCbMapOutput('svg');
assert(isSet == 1);
assert(strcmp(CB_MAP_OUTPUT, 'svg'));
% the comparison ignores case and the format is stored as given
isSet = changeCbMapOutput('MATLAB');
assert(isSet == 1);
assert(strcmp(CB_MAP_OUTPUT, 'MATLAB'));
isSet = changeCbMapOutput('matlab');
assert(isSet == 1);
assert(strcmp(CB_MAP_OUTPUT, 'matlab'));

%% an unsupported format ('java' is documented as not implemented) warns and returns 0

lastwarn('');
isSet = changeCbMapOutput('java');
assert(isSet == 0);
assert(strcmp(lastwarn, 'java is not a supported render format.'));
% the previous format is kept
assert(strcmp(CB_MAP_OUTPUT, 'matlab'));

%% without input the current format is printed and 0 is returned

isSet = changeCbMapOutput();
assert(isSet == 0);
assert(strcmp(CB_MAP_OUTPUT, 'matlab'));

% restore the global render format, or remove the global if the test created it
if ismember('CB_MAP_OUTPUT', globalsBefore)
    CB_MAP_OUTPUT = savedOutput;
else
    clearvars -global CB_MAP_OUTPUT
end
clear CB_MAP_OUTPUT

% change the directory
cd(currentDir)
