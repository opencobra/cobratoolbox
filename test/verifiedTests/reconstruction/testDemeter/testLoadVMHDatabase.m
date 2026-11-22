% The COBRAToolbox: testLoadVMHDatabase.m
%
% Purpose:
%     - loadVMHDatabase reads MetaboliteDatabase.txt (13 columns, no header) and
%       ReactionDatabase.txt (12 columns, header row) from the MATLAB search path and returns
%       them as cell arrays: database.metabolites, with the charge (column 5) and the numeric
%       identifiers of columns 7 and 8 converted to text (empty text for a missing value),
%       and database.reactions, with the header as first row. Exchange reactions named in
%       the global structures additionalSecretionRxns and additionalUptakeRxns (one cell
%       {'EX_<met>(e)'} per field) that are not in the reaction database are appended as
%       transport rows; a metabolite written in another case is replaced by its database
%       spelling (also in the global structure), and an unknown metabolite raises an error.
%     - The test writes a small metabolite and reaction database by hand in a temporary
%       folder and runs the function from that folder, where readtable finds these files
%       before the ones on the path; expected values are the values written and the
%       appended rows as defined in the code (hand derivation). Where the papers submodule
%       is present, the shape of the real database is checked as well.
%     - The two globals are saved before the test and restored (or removed) at the end.
%
% Function under test:
%     src/reconstruction/demeter/src/integration/loadVMHDatabase.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-written database files in a temporary folder.
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
fileDir = fileparts(which('testLoadVMHDatabase'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% save the global variables read and changed by the function
globalsBefore = who('global');
global additionalSecretionRxns additionalUptakeRxns
savedSecretion = additionalSecretionRxns;
savedUptake = additionalUptakeRxns;

% the hand-written database: metabolites (13 tab-separated columns, no header; column 5 is
% the charge, 7 and 8 numeric identifiers, 12 a date) and reactions (12 columns, header).
% readtable detects the delimiter of these files itself: the reaction fields contain no
% blank, so that the tab is detected in this short file as in the full database
sandboxDir = tempname;
mkdir(sandboxDir);
metaboliteRows = {
    'atp',   'ATP',        'C10H12N5O13P3', 'C10H12N5O13P3', '-4', 'C00002', '5957', '15422', '', '', 'HMDB00538', '19/09/2018', 'Nucleotide'
    'h2o',   'Water',      'H2O',           'H2O',           '0',  'C00001', '962',  '15377', '', '', 'HMDB02111', '19/09/2018', ''
    'glc_D', 'D-Glucose',  '',              'C6H12O6',       '0',  'C00031', '',     '',      '', '', '',          '19/09/2018', 'Glycolysis'
    'lac_L', 'L-Lactate',  '',              'C3H5O3',        '-1', 'C00186', '',     '422',   '', '', '',          '19/09/2018', 'Pyruvate metabolism'};
reactionHeader = {'ReactionID', 'Description', 'Formula', 'Reversible', 'ConfidenceScore', 'Notes', ...
    'References', 'ECNumber', 'KEGGID', 'LastModified', 'Subsystem', 'Subsystem_general'};
reactionRows = {
    'EX_atp(e)',   'ATP_exchange',     'atp[e]<=>',           '1', '0', '', '', '', '', '19/09/2018', 'Exchange', 'Exchange'
    'EX_lac_L(e)', 'Lactate_exchange', 'lac_L[e]<=>',         '1', '0', '', '', '', '', '19/09/2018', 'Exchange', 'Exchange'
    'ATPM',        'ATP_maintenance',  'atp[c]+h2o[c]->adp[c]', '0', '1', '', '', '', '', '19/09/2018', 'Energy', 'Energy'};
fid = fopen(fullfile(sandboxDir, 'MetaboliteDatabase.txt'), 'w');
for i = 1:size(metaboliteRows, 1)
    fprintf(fid, '%s\n', strjoin(metaboliteRows(i, :), sprintf('\t')));
end
fclose(fid);
fid = fopen(fullfile(sandboxDir, 'ReactionDatabase.txt'), 'w');
fprintf(fid, '%s\n', strjoin(reactionHeader, sprintf('\t')));
for i = 1:size(reactionRows, 1)
    fprintf(fid, '%s\n', strjoin(reactionRows(i, :), sprintf('\t')));
end
fclose(fid);
cd(sandboxDir);

% the row appended for an exchange reaction of metabolite met (as defined in the code)
addedRow = @(rxn, met) {rxn, [met ' transport, extracellular'], [met '[e]  <=> '], 1, 0, ...
    'Added with mismatching IDs from resource and original VMH database', NaN, NaN, NaN, NaN, ...
    'Transport, extracellular', 'Transport'};

%% no additional reactions: the two databases as written

additionalSecretionRxns = [];
additionalUptakeRxns = [];
database = loadVMHDatabase();
assert(isequal(fieldnames(database), {'metabolites'; 'reactions'}));
% the metabolites of the sandbox are read (not the database on the path)
assert(isequal(size(database.metabolites), [4 13]));
assert(isequal(database.metabolites(:, 1), metaboliteRows(:, 1)));
assert(isequal(database.metabolites(:, 4), metaboliteRows(:, 4)));
% charge and numeric identifiers as text; a missing identifier is an empty text
assert(isequal(database.metabolites(:, 5), {'-4'; '0'; '0'; '-1'}));
assert(isequal(database.metabolites(:, 7), {'5957'; '962'; ''; ''}));
assert(isequal(database.metabolites(:, 8), {'15422'; '15377'; ''; '422'}));
% reactions: the header row, then the reactions
assert(isequal(size(database.reactions), [4 12]));
assert(isequal(database.reactions(1, :), reactionHeader));
assert(isequal(database.reactions(2:end, 1), reactionRows(:, 1)));
assert(isequal(database.reactions(2:end, 4), {1; 1; 0}));
reactionsWritten = database.reactions;

%% additional secretion reactions

% EX_atp(e) exists: nothing is added; EX_h2o(e) is new: a row is added; EX_glc_d(e) is new
% and glc_d is the database metabolite glc_D: a row for EX_glc_D(e) is added; EX_lac_l(e)
% names the existing EX_lac_L(e): nothing is added; the global keeps the database spelling
additionalSecretionRxns = struct('existing', {{'EX_atp(e)'}}, 'newExact', {{'EX_h2o(e)'}}, ...
    'newCase', {{'EX_glc_d(e)'}}, 'existingCase', {{'EX_lac_l(e)'}});
additionalUptakeRxns = [];
database = loadVMHDatabase();
assert(isequal(size(database.reactions), [6 12]));
assert(isequaln(database.reactions(1:4, :), reactionsWritten));
assert(isequaln(database.reactions(5, :), addedRow('EX_h2o(e)', 'h2o')));
assert(isequaln(database.reactions(6, :), addedRow('EX_glc_D(e)', 'glc_D')));
assert(isequal(additionalSecretionRxns.existing, {'EX_atp(e)'}));
assert(isequal(additionalSecretionRxns.newExact, {'EX_h2o(e)'}));
assert(isequal(additionalSecretionRxns.newCase, {'EX_glc_D(e)'}));
assert(isequal(additionalSecretionRxns.existingCase, {'EX_lac_L(e)'}));
% the metabolites are not changed
assert(isequal(size(database.metabolites), [4 13]));

%% additional uptake reactions

additionalSecretionRxns = [];
additionalUptakeRxns = struct('existing', {{'EX_atp(e)'}}, 'newExact', {{'EX_h2o(e)'}}, ...
    'newCase', {{'EX_glc_d(e)'}}, 'existingCase', {{'EX_lac_l(e)'}});
database = loadVMHDatabase();
assert(isequal(size(database.reactions), [6 12]));
assert(isequaln(database.reactions(5, :), addedRow('EX_h2o(e)', 'h2o')));
assert(isequaln(database.reactions(6, :), addedRow('EX_glc_D(e)', 'glc_D')));
assert(isequal(additionalUptakeRxns.newCase, {'EX_glc_D(e)'}));
assert(isequal(additionalUptakeRxns.existingCase, {'EX_lac_L(e)'}));

%% secretion and uptake of the same new reaction: the row is added once

additionalSecretionRxns = struct('water', {{'EX_h2o(e)'}});
additionalUptakeRxns = struct('water', {{'EX_h2o(e)'}});
database = loadVMHDatabase();
assert(isequal(size(database.reactions), [5 12]));
assert(sum(strcmp(database.reactions(:, 1), 'EX_h2o(e)')) == 1);

%% an unknown metabolite raises an error (secretion and uptake)

additionalSecretionRxns = struct('unknown', {{'EX_xyz(e)'}});
additionalUptakeRxns = [];
assert(verifyCobraFunctionError('loadVMHDatabase', 'testMessage', 'Invalid metabolite xyz'));
additionalSecretionRxns = [];
additionalUptakeRxns = struct('unknown', {{'EX_abc(e)'}});
assert(verifyCobraFunctionError('loadVMHDatabase', 'testMessage', 'Invalid metabolite abc'));

%% the real database on the path (only where the papers submodule is present)

% run from the test folder, so that the files on the path are read; only the shape is
% checked, as the content of the database changes with its releases
cd(fileDir);
additionalSecretionRxns = [];
additionalUptakeRxns = [];
if exist('MetaboliteDatabase.txt', 'file') == 2 && exist('ReactionDatabase.txt', 'file') == 2
    database = loadVMHDatabase();
    assert(size(database.metabolites, 2) == 13 && size(database.reactions, 2) == 12);
    assert(strcmp(database.reactions{1, 1}, 'ReactionID'));
    assert(iscellstr(database.metabolites(:, [5 7 8])));
    clear database
else
    fprintf('skipped: the VMH database of the papers submodule is not on the path\n');
end

% restore the globals and remove the ones created by the test
additionalSecretionRxns = savedSecretion;
additionalUptakeRxns = savedUptake;
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clearvars('-global', newGlobals{:});
end
rmdir(sandboxDir, 's');

% change the directory
cd(currentDir)
