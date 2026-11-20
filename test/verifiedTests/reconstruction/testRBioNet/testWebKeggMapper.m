% The COBRAToolbox: testWebKeggMapper.m
%
% Purpose:
%     - webKeggMapper opens the KEGG global metabolic map (map 01100) for an EC number
%       ('ec') or a KEGG reaction ID ('kegg') in the system browser; an empty ID or an unknown
%       source shows a message box instead.
%     - No browser is opened and the internet is not used: the test writes a stand-in web.m
%       into a temporary folder made the current folder (the current folder precedes the
%       path), which records its arguments in a file; the expected addresses are the ones of
%       lines 27 and 29 of the source. The message boxes are opened and closed by the test.
%
% Function under test:
%     src/reconstruction/rBioNet/webKeggMapper.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; web is replaced by a stand-in.
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
fileDir = fileparts(which('testWebKeggMapper'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% stand-in for web: appends one line '<argument 1>|<argument 2>|' per call to webCalls.txt
tmpDir = tempname;
mkdir(tmpDir);
cd(tmpDir);
standInLines = {'function web(varargin)', ...
    'fid = fopen(fullfile(fileparts(mfilename(''fullpath'')), ''webCalls.txt''), ''a'');', ...
    'fprintf(fid, ''%s|'', varargin{:});', ...
    'fprintf(fid, ''\n'');', ...
    'fclose(fid);', ...
    'end'};
fid = fopen('web.m', 'w');
fprintf(fid, '%s\n', standInLines{:});
fclose(fid);
% the stand-in, not MATLAB's web, is the one that will be called
assert(strcmp(which('web'), fullfile(pwd, 'web.m')));
callLog = fullfile(pwd, 'webCalls.txt');

%% 'ec' and 'kegg' open map 01100 with the ID highlighted, in the system browser

webKeggMapper('ec', '2.7.1.1');
webKeggMapper('kegg', 'R00299');
% exact text: the addresses are built by concatenation
expectedCalls = sprintf(['http://www.genome.jp/kegg-bin/show_pathway?ec01100+2.7.1.1|-browser|\n', ...
    'http://www.genome.jp/kegg-bin/show_pathway?rn01100+R00299|-browser|\n']);
assert(strcmp(fileread(callLog), expectedCalls));

%% an empty ID shows a help message box and opens nothing

webKeggMapper('ec', '');
helpBoxes = findall(0, 'Type', 'figure', 'Tag', 'Msgbox_Help');
assert(numel(helpBoxes) == 1);
assert(contains(closeMessageBoxes(), 'There is no ec ID available for this metabolite/reaction.'));
assert(strcmp(fileread(callLog), expectedCalls));

%% an unknown source shows a message box and opens nothing

webKeggMapper('chebi', 'CHEBI:16199');
assert(contains(closeMessageBoxes(), 'unknown source'));
assert(strcmp(fileread(callLog), expectedCalls));

% remove the stand-in and the temporary folder
cd(fileDir);
clear('web');
rmdir(tmpDir, 's');

% change the directory
cd(currentDir)

function boxText = closeMessageBoxes()
% Returns the text of the open message boxes and closes them, so that no window stays open.
boxes = findall(0, 'Type', 'figure', '-regexp', 'Tag', '^Msgbox_');
boxText = '';
for iBox = 1:numel(boxes)
    boxLines = cellstr(get(findall(boxes(iBox), 'Type', 'text'), 'String'));
    boxText = [boxText, ' ', strjoin(strtrim(boxLines), ' ')]; %#ok<AGROW>
end
delete(boxes);
end
