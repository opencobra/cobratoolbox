% The COBRAToolbox: testGetStatsMetStruct.m
%
% Purpose:
%     - getStatsMetStruct lists the fields (identifiers) of a metabolite structure, as found on
%       its first metabolite, counts for each field the metabolites whose value is neither empty
%       nor NaN, and returns a table with one row per metabolite (empty values shown as NaN).
%       This test checks a hand-built structure with text, numeric, NaN and empty values.
%       Expected counts and table entries are listed by hand.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/analyseMetStruct/getStatsMetStruct.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
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
fileDir = fileparts(which('testGetStatsMetStruct'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% three metabolites with the same three fields; keggId: text, text, NaN; pubChemId: numeric,
% NaN, empty; hmdb: empty everywhere
metaboliteStructure = struct();
metaboliteStructure.VMH_glc_D = struct('keggId', 'C00031', 'pubChemId', 5793, 'hmdb', '');
metaboliteStructure.VMH_atp = struct('keggId', 'C00002', 'pubChemId', NaN, 'hmdb', []);
metaboliteStructure.VMH_h2o = struct('keggId', NaN, 'pubChemId', [], 'hmdb', '');

%% field names, counts of present values and the table

[IDs, IDcount, Table] = getStatsMetStruct(metaboliteStructure);
% the fields of the first metabolite, in their order
assert(isequal(IDs, {'keggId'; 'pubChemId'; 'hmdb'}));
% present = neither empty nor NaN: keggId 2, pubChemId 1, hmdb 0 (exact counts)
assert(isequal(IDcount, [2; 1; 0]));
% header row and one row per metabolite; empty values appear as NaN
assert(isequal(size(Table), [4, 4]));
assert(isequal(Table(1, :), {'MetStrctID', 'keggId', 'pubChemId', 'hmdb'}));
assert(isequal(Table(:, 1), {'MetStrctID'; 'VMH_glc_D'; 'VMH_atp'; 'VMH_h2o'}));
assert(isequal(Table(2, 2:3), {'C00031', 5793}) && isnan(Table{2, 4}));
assert(isequal(Table{3, 2}, 'C00002') && isnan(Table{3, 3}) && isnan(Table{3, 4}));
assert(all(cellfun(@(value) isnumeric(value) && isnan(value), Table(4, 2:4))));

% change the directory
cd(currentDir)
