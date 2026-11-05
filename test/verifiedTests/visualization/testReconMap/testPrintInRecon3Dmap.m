% The COBRAToolbox: testPrintInRecon3Dmap.m
%
% Purpose:
%     - tests the printInRecon3Dmap function using the Recon3D network
%
% Function under test:
%     src/visualization/maps/ReconMap/printInRecon3Dmap.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - no solver; the reaction list of Recon2.v05 and hand-written reaction lists.
%
% Coverage exemptions:
%     Line 46: unreachable, it repeats the lineWidth check of line 36, which errors first and
%     lineWidth does not change in between.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The line width is written with a stray digit
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: the format %f4 prints a six-decimal number followed by the character 4, so a
%         line width of 8 is written as 8.0000004
%       EXPECTED: the line width alone (a format such as %.4f)
%       LINES: 87
%
% Authors:
%     - German Preciat -- December 2019
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR
fileName = 'Recon2.v05.mat';
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'mat' filesep fileName]);

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which('testPrintInRecon3Dmap')));

% Load reference data
testMap = regexp( fileread('testMap.txt'), '\n', 'split')';

% Generate new data
printInRecon3Dmap(model.rxns);
fileName = 'C__fakepath_data4ReconMap3_1.txt';
newMap = regexp( fileread(fileName), '\n', 'split')';
if exist(fileName, 'file') == 2
    delete(fileName);
end

% Test the data
L = length(testMap{2})-1;
for i=1:length(testMap)
    if length(testMap{i}) > L
    	assert(isequal(testMap{i}(1:L), newMap{i}(1:L)))
    end
end
%% A line width that is not numeric is rejected
assert(verifyCobraFunctionError('printInRecon3Dmap', 'inputs', {{'R1'}, 1, tempdir, 'thick'}, ...
                                'testMessage', 'lineWidth needs to be numeric'));

%% Output folder, line width, file name and the colour of a zero value
% A value of zero has no position on the colour scale and takes the first colour; the largest
% value takes the last one. The apostrophe of a reaction identifier is removed.
outputDir = tempname;
mkdir(outputDir);
printInRecon3Dmap({'R1'; 'R''2'}, [0, 64], outputDir, 3, "myMap_");
outputFile = [outputDir filesep 'myMap_1.txt'];
writtenLines = regexp(strtrim(fileread(outputFile)), '\n', 'split')';
rmdir(outputDir, 's');
assert(numel(writtenLines) == 3);
assert(strcmp(strtrim(writtenLines{1}), sprintf('name\treactionIdentifier\tlineWidth\tcolor')));
assert(startsWith(strtrim(writtenLines{2}), sprintf('R_R1\t3.000000')));
assert(endsWith(writtenLines{2}, '#00008F'));
assert(startsWith(strtrim(writtenLines{3}), sprintf('R_R2\t3.000000')));
assert(endsWith(writtenLines{3}, '#800000'));

% change the directory
cd(currentDir)



 