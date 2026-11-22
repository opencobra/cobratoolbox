% The COBRAToolbox: testParseCD.m
%
% Purpose:
%     - parseCD reads a CellDesigner XML file line by line and returns one field per reaction
%       (named by the reaction metaid) holding its name (id, name), base reactants and products
%       (species, alias), reactant and product links (species, alias), and the width, colour
%       and line number of each 'celldesigner:line width' line; the field r_info holds the same
%       data by property (ID, width, color, number, reactant, product, baseReactant,
%       baseProduct), the species list (id, name, line number in column 5) and every line of
%       the file (XMLtext). A reaction line without metaid is an error.
%     - The test writes a small CellDesigner-like file (two reactions, three species) into a
%       temporary folder; expected values are read off that file by hand, line numbers by
%       counting its lines.
%
% Function under test:
%     src/visualization/cellDesigner/parseCD.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; the XML files are written by the test.
%
% Coverage exemptions:
%     Lines 26-30: the file dialog uigetfile, shown only when fname is omitted or empty (GUI).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Debug output of the keyword table, of every line read and of intermediate
%         values
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: lines 74, 75, 140, 163 and 343 lack a terminating semicolon and line 173
%         calls disp, so toFD, the growing text structure (once per line of the file), ans,
%         the keyword list of every line and ind_rem_color are printed
%       EXPECTED: no output
%       LINES: 74-75, 140, 163, 173, 343
%     - DEFECT: The input file is left open
%       SEVERITY: limitation
%       TRIGGER: any call, e.g. parseCD('<file>.xml')
%       OBSERVED: the identifier opened at line 32 (or 30) still appears in openedFiles()
%         after the call; the function has no fclose
%       EXPECTED: the file closed before the function returns
%       LINES: 30, 32
%     - DEFECT: A reaction written on one line makes the function loop forever
%       SEVERITY: limitation
%       TRIGGER: a file in which a reaction's '<reaction ' and '</reaction>' are on the same
%         line, e.g. '<reaction metaid="re1" id="re1" name="R1"></reaction>' (CellDesigner
%         itself writes one element per line, so its files do not have this form)
%       OBSERVED: (by reading, 2026-11-17; not run, as the call would not return) line 245
%         finds '</reaction>' on the line just read, so the loop of lines 255-482, the only
%         place in the reaction branch (lines 202-492) that reads a new line (line 260), is
%         skipped; the outer loop of line 149 then handles the same line again, adding a
%         reaction each time, without end
%       EXPECTED: the reaction parsed once and the next line read
%       LINES: 149, 245, 255
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testParseCD'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the function leaves its file identifier open (defect above): remember the open files to
% close what it leaves
if exist('openedFiles') > 0 %#ok<EXIST>
    listOpenFiles = @() openedFiles();
else
    listOpenFiles = @() fopen('all');
end
openFilesBefore = listOpenFiles();

tmpDir = tempname;
mkdir(tmpDir);

% a small CellDesigner file; the line numbers are given in the comments
xmlLines = {'<?xml version="1.0" encoding="UTF-8"?>', ...                      % 1
    '<sbml level="2" version="4">', ...                                         % 2
    '<model metaid="untitled" id="untitled">', ...                              % 3
    '<listOfSpecies>', ...                                                      % 4
    '<species metaid="s1" id="s1" name="glc_D" compartment="c">', ...          % 5
    '</species>', ...                                                           % 6
    '<species metaid="s2" id="s2" name="g6p" compartment="c">', ...            % 7
    '</species>', ...                                                           % 8
    '<species metaid="s3" id="s3" compartment="c">', ...                       % 9
    '</species>', ...                                                           % 10
    '</listOfSpecies>', ...                                                     % 11
    '<listOfReactions>', ...                                                    % 12
    '<reaction metaid="re1" id="re1" name="HEX1" reversible="false">', ...      % 13
    '<annotation>', ...                                                         % 14
    '<celldesigner:extension>', ...                                             % 15
    '<celldesigner:baseReactants>', ...                                         % 16
    '<celldesigner:baseReactant species="s1" alias="sa1"/>', ...               % 17
    '</celldesigner:baseReactants>', ...                                        % 18
    '<celldesigner:baseProducts>', ...                                          % 19
    '<celldesigner:baseProduct species="s2" alias="sa2"/>', ...                % 20
    '</celldesigner:baseProducts>', ...                                         % 21
    '<celldesigner:listOfReactantLinks>', ...                                   % 22
    '<celldesigner:reactantLink reactant="s3" alias="sa3" targetLineIndex="-1,0">', ... % 23
    '<celldesigner:line width="2.0" color="ff0000ff" type="Straight"/>', ...   % 24
    '</celldesigner:reactantLink>', ...                                         % 25
    '</celldesigner:listOfReactantLinks>', ...                                  % 26
    '<celldesigner:listOfProductLinks>', ...                                    % 27
    '<celldesigner:productLink product="s3" alias="sa4" targetLineIndex="-1,1">', ...   % 28
    '</celldesigner:productLink>', ...                                          % 29
    '</celldesigner:listOfProductLinks>', ...                                   % 30
    '<celldesigner:line width="1.0" color="ff000000"/>', ...                   % 31
    '</celldesigner:extension>', ...                                            % 32
    '</annotation>', ...                                                        % 33
    '</reaction>', ...                                                          % 34
    '<reaction metaid="re2" id="re2" reversible="true">', ...                   % 35
    '<annotation>', ...                                                         % 36
    '<celldesigner:line width="3.0" color="ffff0000"/>', ...                   % 37
    '</annotation>', ...                                                        % 38
    '</reaction>', ...                                                          % 39
    '</listOfReactions>', ...                                                   % 40
    '</model>', ...                                                             % 41
    '</sbml>'};                                                                 % 42
xmlFile = fullfile(tmpDir, 'model.xml');
writeLines(xmlFile, xmlLines);

parsed = parseCD(xmlFile);

%% one field per reaction (metaid), then r_info

assert(isequal(fieldnames(parsed), {'re1'; 're2'; 'r_info'}));

%% reaction re1: name, base species, links, and width/colour/line number of each line

% text values are compared exactly; line numbers are integers
assert(isequal(fieldnames(parsed.re1), {'name'; 'baseReactant'; 'baseProduct'; 'reactant'; ...
    'width'; 'color'; 'number'; 'product'}));
assert(isequal(parsed.re1.name, {'re1', 'HEX1'}));
assert(isequal(parsed.re1.baseReactant, {'s1', 'sa1'}));
assert(isequal(parsed.re1.baseProduct, {'s2', 'sa2'}));
assert(isequal(parsed.re1.reactant, {'s3', 'sa3'}));
assert(isequal(parsed.re1.product, {'s3', 'sa4'}));
assert(isequal(parsed.re1.width, {'2.0', '1.0'}));
assert(isequal(parsed.re1.color, {'ff0000ff', 'ff000000'}));
assert(isequal(parsed.re1.number, [24 31]));

%% reaction re2 has no name attribute: its name holds the id only

assert(isequal(fieldnames(parsed.re2), {'name'; 'width'; 'color'; 'number'}));
assert(isequal(parsed.re2.name, {'re2'}));
assert(isequal(parsed.re2.width, {'3.0'}));
assert(isequal(parsed.re2.color, {'ffff0000'}));
assert(isequal(parsed.re2.number, 37));

%% r_info: the same data by property, one row per reaction, padded with [] or 0

rInfo = parsed.r_info;
assert(isequal(rInfo.ID, {'re1', 're1', 'HEX1'; 're2', 're2', []}));
assert(isequal(rInfo.width, {'2.0', '1.0'; '3.0', []}));
assert(isequal(rInfo.color, {'ff0000ff', 'ff000000'; 'ffff0000', []}));
assert(isequal(rInfo.number, [24 31; 37 0]));
assert(isequal(rInfo.reactant, {'s3', 'sa3'}));
assert(isequal(rInfo.product, {'s3', 'sa4'}));
assert(isequal(rInfo.baseReactant, {'s1', 'sa1'}));
assert(isequal(rInfo.baseProduct, {'s2', 'sa2'}));

%% r_info.species: id, name (when present) and the line number of each species line

assert(isequal(rInfo.species, {'s1', 'glc_D', [], [], '5'; ...
    's2', 'g6p', [], [], '7'; ...
    's3', [], [], [], '9'}));

%% r_info.XMLtext: every line of the file, each as a cell with one string

assert(isequal(size(rInfo.XMLtext), [1, numel(xmlLines)]));
assert(all(arrayfun(@(t) iscell(t.str), rInfo.XMLtext)));
assert(isequal(arrayfun(@(t) t.str{1}, rInfo.XMLtext, 'UniformOutput', false), xmlLines));

%% a file without reactions and species gives only r_info, with empty lists

emptyFile = fullfile(tmpDir, 'empty.xml');
writeLines(emptyFile, {'<sbml>', '</sbml>'});
parsedEmpty = parseCD(emptyFile);
assert(isequal(fieldnames(parsedEmpty), {'r_info'}));
assert(isempty(parsedEmpty.r_info.ID) && isempty(parsedEmpty.r_info.species));
assert(isequal(arrayfun(@(t) t.str{1}, parsedEmpty.r_info.XMLtext, 'UniformOutput', false), ...
    {'<sbml>', '</sbml>'}));

%% a reaction line without metaid is an error

badFile = fullfile(tmpDir, 'bad.xml');
writeLines(badFile, {'<sbml>', '<reaction id="re9">', '</reaction>', '</sbml>'});
assert(verifyCobraFunctionError('parseCD', 'inputs', {badFile}, ...
    'testMessage', 'cannot find the Keyword in the the line'));

% close the files the function left open and remove the temporary folder
openFilesLeft = setdiff(listOpenFiles(), openFilesBefore);
for k = 1:numel(openFilesLeft)
    fclose(openFilesLeft(k));
end
rmdir(tmpDir, 's');

% change the directory
cd(currentDir)

function writeLines(fileName, textLines)
% Writes the lines of text to a file.
fid = fopen(fileName, 'w');
fprintf(fid, '%s\n', textLines{:});
fclose(fid);
end
