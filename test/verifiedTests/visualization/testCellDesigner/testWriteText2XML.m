% The COBRAToolbox: testWriteText2XML.m
%
% Purpose:
%     - writeText2XML writes the lines held in text(d).str (a cell with one string, as
%       parseCD stores them in r_info.XMLtext, or a char row) to a file, one line each,
%       followed by a newline; an existing file is overwritten.
%     - Expected file contents are written by hand from the hand-built text structures.
%
% Function under test:
%     src/visualization/cellDesigner/writeText2XML.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; files are written in a temporary folder.
%
% Coverage exemptions:
%     Lines 18-22: the file dialog uiputfile, shown only when fname_out is omitted or empty
%     (GUI).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWriteText2XML'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

tmpDir = tempname;
mkdir(tmpDir);
outFile = fullfile(tmpDir, 'out.xml');

%% each entry becomes one line; cell and char entries, an empty line, text kept literally

text = struct('str', {{'<?xml version="1.0" encoding="UTF-8"?>'}, '<sbml>', {''}, ...
    {'<note>50% done \n not escaped</note>'}, {'</sbml>'}});
writeText2XML(text, outFile);
% exact text: '%' and '\n' inside an entry are written as they are
expectedText = ['<?xml version="1.0" encoding="UTF-8"?>', newline, '<sbml>', newline, ...
    newline, '<note>50% done \n not escaped</note>', newline, '</sbml>', newline];
assert(strcmp(fileread(outFile), expectedText));

%% an existing file is overwritten; an empty structure gives an empty file

writeText2XML(struct('str', {{'<a/>'}}), outFile);
assert(strcmp(fileread(outFile), ['<a/>', newline]));
writeText2XML(struct('str', {}), outFile);
assert(isempty(fileread(outFile)));

% remove the temporary folder
rmdir(tmpDir, 's');

% change the directory
cd(currentDir)
