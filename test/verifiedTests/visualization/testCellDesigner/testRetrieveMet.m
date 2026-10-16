% The COBRAToolbox: testRetrieveMet.m
%
% Purpose:
%     - retrieveMet looks up a species identifier in the species table of parsed CellDesigner data
%     and returns the matching entries with their alias, species identifier and name.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/visualization/cellDesigner/retrieveMet.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 31, the call that loads default parsed data when no parsed structure is given: it needs a
%     data file that is not part of the test.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRetrieveMet'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% species table: alias, species identifier, name
parsed.r_info.species = {'sa1', 'spA', 'nameA'; ...
                         'sa2', 'spB', ''; ...
                         'sa3', '', 'nameC'};

%% lookup by alias

text = evalc("identifier = retrieveMet(parsed, 'sa2');");
assert(strcmp(identifier.keywords, 'sa2') && strcmp(identifier.speciesAlliens, 'sa2'));
assert(isequal(identifier.species, {'spB'}));
% the name is empty because the table holds no name for this alias
assert(isempty(identifier.name));
% the alias is displayed
assert(contains(text, 'sa2'));

%% lookup by species identifier and by name

[~] = evalc("identifier = retrieveMet(parsed, 'spA');");
assert(strcmp(identifier.speciesAlliens, 'sa1') && isequal(identifier.name, {'nameA'}));
[~] = evalc("identifier = retrieveMet(parsed, 'nameC');");
assert(strcmp(identifier.speciesAlliens, 'sa3') && isequal(identifier.name, {'nameC'}) && ~isfield(identifier, 'species') || ...
       isempty(identifier.species));

%% the default identifier is used when no lookup is given

[~] = evalc('identifier = retrieveMet(parsed);');
assert(isempty(identifier.name) && ~isfield(identifier, 'keywords'));

%% no match

[~] = evalc("identifier = retrieveMet(parsed, 'nothing');");
assert(isstruct(identifier) && isempty(identifier.name) && ~isfield(identifier, 'keywords'));

% change the directory
cd(currentDir)
