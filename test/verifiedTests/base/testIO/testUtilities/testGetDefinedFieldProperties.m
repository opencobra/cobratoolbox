% The COBRAToolbox: testGetDefinedFieldProperties.m
%
% Purpose:
%     - getDefinedFieldProperties reads the definition of the COBRA model fields
%       (src/base/io/definitions/COBRA_structure_fields.tab) and returns, depending on the
%       options, the programmatic properties of each field (8 columns), the human-readable
%       descriptions (4 columns) or the database relations (6 columns), each cached in a
%       persistent variable. This test checks the three tables, the cache, the selection of
%       specific fields (in the requested order) and the error for incompatible options.
%     - Expected values come from the definition file itself, read independently here with
%       fileread and a tab split (row counts, field order, evaluators, database id and
%       qualifier combinations), and from hand-picked rows of that file (S, mets, osenseStr,
%       metKEGGID, geneEntrezID) whose conversions follow from the documentation.
%
% Function under test:
%     src/base/io/utilities/getDefinedFieldProperties.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; the only input is the definition file shipped with the
%     toolbox.
%
% Coverage exemptions:
%     Lines 174, 175, 177, 178: inside the `if 0 %debug` block, which can never run (dead
%     code).
%     Line 193: the error for a requested field without definition; skipped for the
%     limitation below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A requested field without definition raises an error instead of being left out
%       SEVERITY: limitation
%       TRIGGER: getDefinedFieldProperties('SpecificFields', {'lb', 'notAField'})
%       OBSERVED: error "The following requesteds fields have no Specifications: notAField"
%       EXPECTED: the documented OUTPUTS: "if fields without definitions are requested, they
%                 will not be contained in the result" (i.e. only the row of lb)
%       LINES: 192-194
%     - DEFECT: SpecificFields is ignored together with Descriptions or DataBaseFields
%       SEVERITY: limitation
%       TRIGGER: getDefinedFieldProperties('Descriptions', true, 'SpecificFields', {'lb'})
%       OBSERVED: all 82 description rows are returned
%       EXPECTED: only the row of lb (SpecificFields: "only obtain definitions for a specific
%                 set of fields"); both branches return before the selection of lines 190-196
%       LINES: 102-103, 135-136
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetDefinedFieldProperties'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% independent reading of the definition file: one row per line, columns split at tabs
% (empty columns kept), the first line holds the column names; trailing blanks are removed
% (deblank), as the function reads the text through cellstr
definitionText = fileread(which('COBRA_structure_fields.tab'));
definitionLines = regexp(strtrim(definitionText), '\r?\n', 'split');
columnNames = regexp(definitionLines{1}, '\t', 'split');
definitionRows = cellfun(@(x) regexp(x, '\t', 'split'), definitionLines(2:end), 'UniformOutput', false);
definitionRows = vertcat(definitionRows{:});
column = @(name) deblank(definitionRows(:, strcmp(columnNames, name)));
modelFieldNames = column('Model Field');
modelFieldNames = modelFieldNames(~cellfun(@isempty, modelFieldNames));
evaluators = column('Evaluator');

% the cached tables were possibly filled by earlier calls (e.g. initCobraToolbox): clearing
% the function empties its persistent variables so that the file is read again below
clear getDefinedFieldProperties

%% default: programmatic properties of every field (8 columns), in the order of the file

fields = getDefinedFieldProperties();
% one row per field with a name; names and evaluators are the text of the file
assert(isequal(size(fields), [numel(modelFieldNames), 8]));
assert(isequal(fields(:, 1), modelFieldNames));
assert(isequal(fields(:, 4), evaluators(~cellfun(@isempty, column('Model Field')))));
% S: dimensions given by field names, numeric default 0, basic, sparse, FBA field
rowS = fields(strcmp(fields(:, 1), 'S'), :);
assert(isequal(rowS, {'S', 'mets', 'rxns', 'isnumeric(x) || issparse(x)', 0, true, 'sparse', true}));
% mets: the dimension '1' becomes the number 1; the default is an expression and stays text
rowMets = fields(strcmp(fields(:, 1), 'mets'), :);
assert(isequal(rowMets([2 3 5 6 7 8]), {'mets', 1, '[''M'' num2str(i)]', true, 'cell', false}));
% osenseStr: dimensions 'NaN' become NaN, the default 'max' stays text
rowOsense = fields(strcmp(fields(:, 1), 'osenseStr'), :);
assert(isnan(rowOsense{2}) && isnan(rowOsense{3}));
assert(isequal(rowOsense([5 6 7 8]), {'max', false, 'char', true}));
% basic and FBA flags are logical scalars for every field
assert(all(cellfun(@(x) islogical(x) && isscalar(x), fields(:, 6))));
assert(all(cellfun(@(x) islogical(x) && isscalar(x), fields(:, 8))));

% a second call returns the cached table unchanged (isequaln: the dimensions of osenseStr
% are NaN)
assert(isequaln(getDefinedFieldProperties(), fields));

%% SpecificFields: only the requested fields, in the requested order

specificFields = getDefinedFieldProperties('SpecificFields', {'lb', 'S'});
assert(isequal(specificFields, [fields(strcmp(fields(:, 1), 'lb'), :); rowS]));
% an empty request returns an empty table
assert(isempty(getDefinedFieldProperties('SpecificFields', {})));

%% Descriptions: field name, dimensions with short symbols, property and field descriptions

descriptions = getDefinedFieldProperties('Descriptions', true);
assert(isequal(size(descriptions), [numel(modelFieldNames), 4]));
assert(isequal(descriptions(:, 1), modelFieldNames));
% rxns -> n, mets -> m, genes -> g, comps -> c; 'NaN x NaN' becomes empty
assert(strcmp(descriptions{strcmp(modelFieldNames, 'S'), 2}, 'm x n'));
assert(strcmp(descriptions{strcmp(modelFieldNames, 'mets'), 2}, 'm x 1'));
assert(strcmp(descriptions{strcmp(modelFieldNames, 'lb'), 2}, 'n x 1'));
assert(strcmp(descriptions{strcmp(modelFieldNames, 'genes'), 2}, 'g x 1'));
assert(strcmp(descriptions{strcmp(modelFieldNames, 'comps'), 2}, 'c x 1'));
assert(isempty(descriptions{strcmp(modelFieldNames, 'osenseStr'), 2}));
% the description columns are the text of the file
propertyDescriptions = column('Property Description');
fieldDescriptions = column('Field Description');
hasName = ~cellfun(@isempty, column('Model Field'));
assert(isequal(descriptions(:, 3), propertyDescriptions(hasName)));
assert(isequal(descriptions(:, 4), fieldDescriptions(hasName)));
% numeric flags 1 and 0 are accepted for the options; the cached table is returned
assert(isequal(getDefinedFieldProperties('Descriptions', 1), descriptions));

%% DataBaseFields: one row per combination of database id and qualifier

databaseFields = getDefinedFieldProperties('DataBaseFields', true);
% expected count: for every row with a database id, (#ids separated by ;) x (#qualifiers)
databaseIds = column('databaseid');
qualifiers = column('qualifier');
hasDatabase = ~cellfun(@isempty, databaseIds);
expectedRows = sum(cellfun(@(d, q) numel(strsplit(d, ';')) * numel(strsplit(q, ';')), ...
    databaseIds(hasDatabase), qualifiers(hasDatabase)));
assert(isequal(size(databaseFields), [expectedRows, 6]));
% metKEGGID has two database ids (kegg.compound;kegg), one qualifier; the reference field
% 'mets' loses its final s
keggRows = databaseFields(strcmp(databaseFields(:, 3), 'metKEGGID'), :);
assert(isequal(keggRows, {'kegg.compound', 'is', 'metKEGGID', 'met', '^C\d+$', 'bioQualifier'; ...
    'kegg', 'is', 'metKEGGID', 'met', '^C\d+$', 'bioQualifier'}));
% geneEntrezID has one database id and two qualifiers (is;isEncodedBy)
entrezRows = databaseFields(strcmp(databaseFields(:, 3), 'geneEntrezID'), :);
assert(isequal(entrezRows(:, 1:4), {'ncbigene', 'is', 'geneEntrezID', 'gene'; ...
    'ncbigene', 'isEncodedBy', 'geneEntrezID', 'gene'}));
% the cached table is returned by the next call
assert(isequal(getDefinedFieldProperties('DataBaseFields', true), databaseFields));

%% errors by design: database and description fields together, invalid option values

assert(verifyCobraFunctionError('getDefinedFieldProperties', 'inputs', {'DataBaseFields', true, 'Descriptions', true}, ...
    'testMessage', 'Cannot simultaneously return database and Description fields'));
assert(verifyCobraFunctionError('getDefinedFieldProperties', 'inputs', {'SpecificFields', 'S'}));
assert(verifyCobraFunctionError('getDefinedFieldProperties', 'inputs', {'Descriptions', 'yes'}));

% change the directory
cd(currentDir)
