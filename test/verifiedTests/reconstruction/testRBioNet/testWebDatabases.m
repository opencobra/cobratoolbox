% The COBRAToolbox: testWebDatabases.m
%
% Purpose:
%     - webDatabases opens the page of a metabolite or reaction identifier in the system
%       browser (web(url, '-browser')): KEGG compound (type 0, the default) or reaction (type
%       1), the ExplorEnz page of an EC number, PubChem, ChEBI (numeric identifiers are
%       converted to text) and HMDB. An empty identifier or an unknown database gives a
%       message box instead.
%     - Tests never use the internet or open a browser, so the test writes a stand-in web.m,
%       which appends the URL and option it receives to a file, to a temporary folder and runs
%       the function from that folder: MATLAB finds functions of the current folder before
%       those on the path, so the stand-in is used and no path is changed. The test checks that
%       the stand-in is the function found before calling. Expected URLs are the documented
%       patterns written out by hand; message boxes are closed after reading their text.
%
% Function under test:
%     src/reconstruction/rBioNet/webDatabases.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a stand-in for the browser in a temporary folder. Two
%     cases open a message box, which the test closes.
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
fileDir = fileparts(which('testWebDatabases'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

sandboxDir = tempname;
mkdir(sandboxDir);
callLog = fullfile(sandboxDir, 'webCalls.txt');

% stand-in for web: one line '<url>|<option>' per call, in the folder of the stand-in
stubLines = {
    'function web(url, option)'
    '% stand-in for the browser written by testWebDatabases'
    'fid = fopen(fullfile(fileparts(mfilename(''fullpath'')), ''webCalls.txt''), ''a'');'
    'fprintf(fid, ''%s|%s\n'', url, option);'
    'fclose(fid);'
    'end'};
fid = fopen(fullfile(sandboxDir, 'web.m'), 'w');
fprintf(fid, '%s\n', stubLines{:});
fclose(fid);

cd(sandboxDir);
rehash
% the stand-in is the function found, so no browser is opened and no page is read
assert(strcmp(which('web'), fullfile(sandboxDir, 'web.m')));

%% KEGG: compound by default and for type 0, reaction for type 1

webDatabases('kegg', 'C00031');
webDatabases('kegg', 'C00031', 0);
webDatabases('kegg', 'R00299', 1);
expected = {
    'http://www.genome.jp/dbget-bin/www_bget?cpd:C00031|-browser'
    'http://www.genome.jp/dbget-bin/www_bget?cpd:C00031|-browser'
    'http://www.genome.jp/dbget-bin/www_bget?rn:R00299|-browser'};
assert(isequal(readCalls(callLog), expected));

%% EC number: one folder per number of the EC number

webDatabases('ec', '2.7.1.1');
assert(isequal(readCalls(callLog), {'http://www.chem.qmul.ac.uk/iubmb/enzyme/EC2/7/1/1.html|-browser'}));

%% PubChem, ChEBI (text or number) and HMDB

webDatabases('pubchem', '3333');
webDatabases('chebi', '4167');
webDatabases('chebi', 4167);
webDatabases('hmdb', '0000122');
expected = {
    'http://pubchem.ncbi.nlm.nih.gov/summary/summary.cgi?sid=3333|-browser'
    'http://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:4167|-browser'
    'http://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:4167|-browser'
    'http://www.hmdb.ca/metabolites/HMDB0000122|-browser'};
assert(isequal(readCalls(callLog), expected));

%% an empty identifier gives a message box and no page

webDatabases('hmdb', '');
assert(~isfile(callLog));
assert(contains(closeMessageBoxes(), 'There is no hmdb ID available for this metabolite / reaction.'));

%% an unknown database gives a message box and no page

webDatabases('metacyc', 'GLC');
assert(~isfile(callLog));
assert(contains(closeMessageBoxes(), 'unknown source'));

%% clean up

% leave the folder and forget the stand-in, so that web is the MATLAB function again
cd(fileDir);
clear web
rmdir(sandboxDir, 's');
rehash

% change the directory
cd(currentDir)

function calls = readCalls(callLog)
% Returns the lines written by the stand-in since the last call, and deletes the file.
calls = strsplit(strtrim(fileread(callLog)), newline)';
delete(callLog);
end

function boxText = closeMessageBoxes()
% Returns the text of the open message boxes and closes them, so that no window stays open.
boxes = findall(0, 'Type', 'figure', '-regexp', 'Tag', '^Msgbox_');
boxText = '';
for iBox = 1:numel(boxes)
    boxLines = cellstr(get(findall(boxes(iBox), 'Type', 'text'), 'String'));
    boxText = [boxText, ' ', strjoin(strtrim(boxLines), ' ')];
end
delete(boxes);
end
