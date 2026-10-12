% The COBRAToolbox: testMapMediumData2AGORA.m
%
% Purpose:
%     - mapMediumData2AGORA builds, for every strain that can grow, the medium it needs: a medium component is -1 when some medium that the strain can grow on contains it, and 0 otherwise.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/demeter/src/integration/mapMediumData2AGORA.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMapMediumData2AGORA'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% growth of each strain on the media (1 = grows): strain sA grows on m1, sB on nothing, sC on both
strainGrowth = {'Strain', 'm1', 'm2'; 'sA', '1', '0'; 'sB', '0', '0'; 'sC', '1', '1'};
% medium definitions: the rows are media, the columns are medium components (-1 = present)
inputMedia = {'Medium', 'm1', 'm2'; 'm1', '-1', '0'; 'm2', '0', '-1'};

mappedMedia = mapMediumData2AGORA(strainGrowth, inputMedia);

% the header is kept; the strain that cannot grow (sB) is dropped
assert(isequal(mappedMedia(1, :), {'Medium', 'm1', 'm2'}));
assert(isequal(mappedMedia(:, 1), {'Medium'; 'sA'; 'sC'}));
% sA grows only on m1, so it needs only the component present in m1
assert(isequal(mappedMedia(2, :), {'sA', '-1', '0'}));
% sC grows on both, so it needs the components of both
assert(isequal(mappedMedia(3, :), {'sC', '-1', '-1'}));

% change the directory
cd(currentDir)
