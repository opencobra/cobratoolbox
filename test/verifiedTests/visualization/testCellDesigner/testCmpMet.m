% The COBRAToolbox: testCmpMet.m
%
% Purpose:
%     - cmpMet compares the metabolites of a parsed CellDesigner model
%       (parsed.r_info.species, one row per species, one column per identifier form) with the
%       metabolites of a COBRA model. A parsed row is 'found' as soon as one of its entries,
%       trimmed and in lower case, is a substring of a model metabolite ID in lower case
%       (strfind); otherwise it is listed as not found with its row number. Model metabolites
%       (in lower case) that match no parsed entry exactly (strcmpi) are listed separately.
%       Expected values are worked out by hand from the inputs below.
%
% Function under test:
%     src/visualization/cellDesigner/cmpMet.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model comparison on a hand-built model structure (mets, metNames) and parsed
%     structure; no solver.
%
% Coverage exemptions:
%     Lines 56-57: unreachable. strtrim at line 52 raises "Input should be a string, character
%     array, or a cell array of character arrays." for any entry that is not text, so the
%     entry is always text when line 55 tests ~ischar.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every comparison prints the searched name
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: line 53 has no semicolon, so 'met = 1x1 cell array {...}' is printed for
%         every parsed entry compared
%       EXPECTED: no output, or output gated by a print level
%       LINES: 53
%     - DEFECT: Model metabolites absent from the parsed model are returned in lower case
%       SEVERITY: cosmetic
%       TRIGGER: a model metabolite ID with capital letters that is not in the parsed model,
%         for example model.mets = {'A[c]'}
%       OBSERVED: list_of_mets_not_present_in_ReferenceModel holds 'a[c]' (the IDs are
%         lowered at line 42 for the search and returned as lowered); the header calls the
%         output field list_of_rxns_not_present_in_ReferenceModel and speaks of reactions
%       EXPECTED: the model's own IDs, in a field named as documented
%       LINES: 42, 101
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCmpMet'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a model with three metabolites; IDs in lower case so that the reported IDs are the model's
% own (the lower-case defect above is skipped)
model.mets = {'glc_d[c]'; 'atp[c]'; 'h2o[c]'};
model.metNames = {'Glucose'; 'ATP'; 'Water'};

% three parsed species (alias, ID, name):
%   row 1: found by its second entry, a substring of glc_d[c]
%   row 2: found by its first entry, 'ATP[c]' in lower case
%   row 3: found by no entry
parsed.r_info.species = {'sa1', 'glc_d', 'Glucose'; 'ATP[c]', 'sa2', 'ATP'; 'sa3', 'foo', 'bar'};

results = cmpMet(parsed, model);

%% found and not found parsed species

% the found rows are copied with the label in column 5 (column 4 stays empty)
assert(isequal(results.listOfFound, ...
    {'sa1', 'glc_d', 'Glucose', [], 'Present in the Reference mode'; ...
     'ATP[c]', 'sa2', 'ATP', [], 'Present in the Reference mode'}));
% the not found row also gets its row number in parsed.r_info.species in column 6
assert(isequal(results.listOfNotFound, {'sa3', 'foo', 'bar', [], 'Not Present in the Reference mode', 3}));
% the parsed list is returned with 'found' in column 5 of the found rows
assert(isequal(results.main, [parsed.r_info.species, cell(3, 1), {'found'; 'found'; []}]));

%% model metabolites that no parsed entry names exactly

% glc_d[c] is not an exact parsed entry (only the substring glc_d is), atp[c] equals 'ATP[c]'
% without regard to case, h2o[c] is not in the parsed model
assert(isequal(results.list_of_mets_not_present_in_ReferenceModel, {'glc_d[c]'; 'h2o[c]'}));

%% everything matches: only the fields that received entries exist

parsedAll.r_info.species = {'atp[c]'};
modelAll.mets = {'atp[c]'};
modelAll.metNames = {'ATP'};
resultsAll = cmpMet(parsedAll, modelAll);
assert(isequal(sort(fieldnames(resultsAll)), {'listOfFound'; 'main'}));
assert(isequal(resultsAll.listOfFound, {'atp[c]', [], 'Present in the Reference mode'}));
assert(isequal(resultsAll.main, {'atp[c]', [], 'found'}));

% change the directory
cd(currentDir)
