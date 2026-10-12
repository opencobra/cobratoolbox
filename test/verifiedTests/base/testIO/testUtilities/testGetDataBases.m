% The COBRAToolbox: testGetDataBases.m
%
% Purpose:
%     - getDataBases extracts the database names and IDs from a list of identifiers.org / urn:miriam resource strings and repeats a given qualifier for each.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/io/utilities/SBML/getDataBases.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None for line coverage: the catch blocks are reached through resource lists that do not match the pattern.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Third output unassigned when nothing matches
%       SEVERITY: error
%       TRIGGER: three outputs requested when no resource matches either pattern
%       OBSERVED: qualifiers is only assigned inside the block that runs for matches, so the call
%         errors
%       EXPECTED: an empty qualifiers output
%       LINES: 46
%     - DEFECT: Mixed matching and non-matching resources return nothing
%       SEVERITY: wrong-result
%       TRIGGER: a list that contains both matching identifiers and strings that match neither
%         pattern
%       OBSERVED: the cellfun over the whole list fails, so databases and ids are empty for all
%         entries
%       EXPECTED: the matching entries returned
%       LINES: 29-44
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetDataBases'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

qualifier = 'bqbiol:is';

%% identifiers.org resources (http and https)

[databases, ids, qualifiers] = getDataBases({'https://identifiers.org/chebi/CHEBI:123'; 'http://identifiers.org/kegg.compound/C00001'}, qualifier);
assert(isequal(databases, {'chebi'; 'kegg.compound'}));
assert(isequal(ids, {'CHEBI:123'; 'C00001'}));
% the qualifier is repeated for every resource
assert(isequal(qualifiers, {qualifier; qualifier}));

%% urn:miriam resources (used when no identifiers.org resource matches)

[databases, ids, qualifiers] = getDataBases({'urn:miriam:chebi:CHEBI%3A123'; 'urn:miriam:hmdb:HMDB1'}, qualifier);
assert(isequal(databases, {'chebi'; 'hmdb'}));
assert(isequal(ids, {'CHEBI%3A123'; 'HMDB1'}));
assert(isequal(qualifiers, {qualifier; qualifier}));

%% resources that match neither pattern: empty database and ID lists

[databases, ids] = getDataBases({'something else'}, qualifier);
assert(isempty(databases) && isempty(ids));

% change the directory
cd(currentDir)
