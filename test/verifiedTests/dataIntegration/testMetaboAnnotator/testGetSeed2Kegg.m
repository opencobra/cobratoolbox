% The COBRAToolbox: testGetSeed2Kegg.m
%
% Purpose:
%     - getSeed2Kegg reads compounds.xlsx (KBase compounds: column 1 the SEED id, column 5 the
%       KEGG ids separated by '|') from the MATLAB search path and writes the first KEGG id into
%       the keggId field of every metabolite whose seed matches exactly and whose keggId is
%       empty or NaN. Each assignment is logged in IDsAdded (metabolite, 'keggId', id) and dated
%       in keggId_source; a KEGG cell that holds no id after the split adds nothing.
%     - The test writes a small compounds.xlsx by hand into a temporary folder and runs the
%       function from that folder, where xlsread finds it before the file of the tutorials
%       submodule; expected values are the values written (hand derivation). A last section
%       checks one row of the shipped file (cpd00001, KEGG ids C00001|C01328) and is skipped
%       with a message when the tutorials submodule is not checked out.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/connect2resources/getSeed2Kegg.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, a hand-built metabolite structure and spreadsheet.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A blank KEGG cell read as NaN stops the mapping with an error
%       SEVERITY: limitation
%       TRIGGER: compounds.xlsx written with writecell({'DATABASE', 'PRIMARY NAME',
%         'ABBREVIATION', 'NAMES', 'KEGG ID(S)'; 'cpd3', 'c', 'c', 'c', ''}) and
%         getSeed2Kegg(struct('m3', struct('keggId', NaN, 'seed', 'cpd3')))
%       OBSERVED: First argument must be text. (line 43; R2025a, 2026-11-15): xlsread returns
%         NaN for the blank cell and contains is called on it before the emptiness check of
%         line 46. The shipped compounds.xlsx stores its 1743 blank KEGG cells as empty text,
%         so the shipped file does not trigger it; the input is skipped below.
%       EXPECTED: the metabolite is left without KEGG id, as for an empty text cell
%       LINES: 43
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetSeed2Kegg'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the hand-built compounds file, written into a temporary folder that becomes the current
% folder. cpd3 holds only the separator, so that no KEGG id is left after the split
sandboxDir = tempname;
mkdir(sandboxDir);
compoundRows = {'DATABASE', 'PRIMARY NAME', 'ABBREVIATION', 'NAMES', 'KEGG ID(S)'
    'cpd1', 'H2O', 'h2o', 'Water', 'C00001|C01328'
    'cpd2', 'ATP', 'atp', 'ATP', 'C00002'
    'cpd3', 'X', 'x', 'X', '|'};
writecell(compoundRows, fullfile(sandboxDir, 'compounds.xlsx'));
cd(sandboxDir);

newMetabolite = @(seed, kegg) struct('seed', seed, 'keggId', kegg);

%% KEGG ids are added for matching SEED ids without a KEGG id

metabolites = struct();
metabolites.water = newMetabolite('cpd1', NaN);    % several KEGG ids: the first is taken
metabolites.atp = newMetabolite('cpd2', '');       % empty KEGG id: added
metabolites.sepOnly = newMetabolite('cpd3', NaN);  % no KEGG id after the split: nothing added
metabolites.kept = newMetabolite('cpd2', 'C99999'); % KEGG id present: kept
metabolites.nanSeed = newMetabolite(NaN, NaN);     % no SEED id: no match
metabolites.unknown = newMetabolite('cpdX', NaN);  % SEED id not listed: no match

[annotated, IDsAdded] = getSeed2Kegg(metabolites);

% the log lists the two assignments in field order (exact text)
assert(isequal(IDsAdded, {'water', 'keggId', 'C00001'; 'atp', 'keggId', 'C00002'}));
assert(strcmp(annotated.water.keggId, 'C00001'));
assert(strcmp(annotated.atp.keggId, 'C00002'));
assert(startsWith(annotated.water.keggId_source, 'Seed mapping to Kegg:automatic:'));
% unchanged metabolites: no KEGG id and no source added
assert(isnan(annotated.sepOnly.keggId) && ~isfield(annotated.sepOnly, 'keggId_source'));
assert(strcmp(annotated.kept.keggId, 'C99999') && ~isfield(annotated.kept, 'keggId_source'));
assert(isnan(annotated.nanSeed.keggId) && isnan(annotated.unknown.keggId));

%% nothing to add: the log stays an empty text

[annotated, IDsAdded] = getSeed2Kegg(struct('none', newMetabolite('cpdX', NaN)));
assert(ischar(IDsAdded) && isempty(IDsAdded));
assert(isnan(annotated.none.keggId));

% the hand-built file is no longer needed
cd(currentDir)
rmdir(sandboxDir, 's');

%% the shipped file (only where the tutorials submodule is checked out)

% the shipped compounds.xlsx lies in tutorials/dataIntegration/metaboAnnotator/data; it is
% read from an empty temporary folder, so that no other compounds.xlsx shadows it
emptyDir = tempname;
mkdir(emptyDir);
cd(emptyDir);
shippedFile = which('compounds.xlsx');
if ~isempty(shippedFile) && contains(shippedFile, fullfile('metaboAnnotator', 'data'))
    [annotated, IDsAdded] = getSeed2Kegg(struct('water', newMetabolite('cpd00001', NaN)));
    % the shipped row of cpd00001 lists C00001|C01328: the first id is taken
    assert(strcmp(annotated.water.keggId, 'C00001'));
    assert(isequal(IDsAdded, {'water', 'keggId', 'C00001'}));
else
    fprintf('skipped: compounds.xlsx of the tutorials submodule is not on the path\n');
end

% remove the temporary folder and change the directory
cd(currentDir)
rmdir(emptyDir, 's');
