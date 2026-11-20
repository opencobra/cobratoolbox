% The COBRAToolbox: testCreateColorsMap.m
%
% Purpose:
%     - createColorsMap returns a containers.Map from upper-case HTML colour names to their
%       colour codes in the CellDesigner ARGB form 'FF' + RRGGBB. The test checks the type,
%       the number of names, the code format and a set of names whose codes are taken from
%       the CSS Color Module Level 4 list of named colours (independent of the source).
%
% Function under test:
%     src/visualization/metabolicCartography/createColorsMap.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, no input.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Help text of createColorsMap corrected to match the code (feature 20261120-151023-doc-matches-code), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateColorsMap'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

colors = createColorsMap();

%% a containers.Map from char names to char codes

assert(isa(colors, 'containers.Map'));
assert(strcmp(colors.KeyType, 'char'));
% the source lists 142 names, MEDIUMSLATEBLUE twice with the same code, so the map holds 141
assert(colors.Count == 141);

%% every name is upper case and every code is 'FF' (opaque alpha) followed by six hex digits

colourNames = keys(colors);
colourCodes = values(colors);
assert(all(cellfun(@(name) strcmp(name, upper(name)), colourNames)));
assert(all(~cellfun(@isempty, regexp(colourCodes, '^FF[0-9A-F]{6}$', 'once'))));

%% named colours checked against the CSS named-colour table (#RRGGBB)

cssColours = {'RED', 'FF0000'; 'BLUE', '0000FF'; 'BLACK', '000000'; 'WHITE', 'FFFFFF'; ...
    'INDIANRED', 'CD5C5C'; 'CRIMSON', 'DC143C'; 'GOLD', 'FFD700'; 'NAVY', '000080'; ...
    'TEAL', '008080'; 'OLIVE', '808000'; 'SILVER', 'C0C0C0'; 'GRAY', '808080'; ...
    'MAROON', '800000'; 'PURPLE', '800080'; 'LIME', '00FF00'; 'GREEN', '008000'; ...
    'AQUA', '00FFFF'; 'CYAN', '00FFFF'; 'FUCHSIA', 'FF00FF'; 'MAGENTA', 'FF00FF'; ...
    'REBECCAPURPLE', '663399'; 'YELLOW', 'FFFF00'; 'ORANGE', 'FFA500'; ...
    'DARKGREEN', '006400'; 'MEDIUMSLATEBLUE', '7B68EE'; 'LIGHTGRAY', 'D3D3D3'};
for k = 1:size(cssColours, 1)
    % codes are strings, so the comparison is exact
    assert(strcmp(colors(cssColours{k, 1}), ['FF' cssColours{k, 2}]), ...
        'createColorsMap: wrong code for %s', cssColours{k, 1});
end

%% lower-case or unknown names are not keys of the map

assert(~isKey(colors, 'red'));
assert(~isKey(colors, 'NOTACOLOUR'));

% change the directory
cd(currentDir)
