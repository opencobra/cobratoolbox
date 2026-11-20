% The COBRAToolbox: testCreateRBioNetDBFromVMHDB.m
%
% Purpose:
%     - createRBioNetDBFromVMHDB reads MetaboliteDatabase.txt (13 tab-separated columns, no
%       header) and ReactionDatabase.txt (12 columns, header row) from the MATLAB search path,
%       converts them to rBioNet cell arrays (metabolites: charge as text, date as datestr;
%       reactions: date as datestr or NaT when missing, empty KEGG text as an empty double,
%       last column removed), saves metab.mat, rxn.mat, compartments.mat (copied from the
%       compartments.mat on the path) and rBioNetSettingsDB.mat (the three paths) into
%       rBioNetDBFolder (default: the current folder), adds that folder to the path and calls
%       savepath.
%     - The test writes a small database by hand into a temporary folder and runs the function
%       from there, where readtable finds these files before the database of the papers
%       submodule. savepath is replaced by a stand-in in a temporary folder, which records the
%       call in a file, so that the user's pathdef.m is not written; the path is restored at the
%       end. Expected values are the values written (hand derivation).
%
% Function under test:
%     src/reconstruction/demeter/src/integration/createRBioNetDBFromVMHDB.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-written database files in a temporary folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A metabolite without time stamp stops the conversion with an error
%       SEVERITY: limitation
%       TRIGGER: MetaboliteDatabase.txt with a row whose 12th column is empty, e.g. the rows
%         'atp ATP C C -4 C00002 5957 15422 . . H 19/09/2018 N' and 'h2o W H2O H2O 0 C00001
%         962 15377 . . H . .' (tab-separated, '.' an empty field), then
%         createRBioNetDBFromVMHDB('rBioNetDBFolder', tempname-folder)
%       OBSERVED: Failed to convert date number to date vector. Date number out of range.
%         (datestr of NaT at line 26; R2025a, 2026-11-15). The shipped database has a time
%         stamp on every row read, so it does not trigger it; the input is skipped below.
%       EXPECTED: the missing time stamp kept, as lines 37-41 do for reactions
%       LINES: 26
%     - DEFECT: The call saves the whole MATLAB path to pathdef.m
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: savepath is called after addpath(rBioNetDBFolder) (line 61), so every folder
%         on the path of the session is written to the user's pathdef.m; the help does not
%         mention it
%       EXPECTED: the documented outputs only, or the side effect documented
%       LINES: 61
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateRBioNetDBFromVMHDB'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the function adds its output folder to the path: the path is restored at the end
savedPath = path;

% stand-in for savepath: it writes a marker file next to itself instead of pathdef.m
standInDir = tempname;
mkdir(standInDir);
savepathMarker = fullfile(standInDir, 'savepathCalled.txt');
fid = fopen(fullfile(standInDir, 'savepath.m'), 'w');
fprintf(fid, 'function savepath(varargin)\n');
fprintf(fid, 'fid = fopen(fullfile(fileparts(mfilename(''fullpath'')), ''savepathCalled.txt''), ''w'');\n');
fprintf(fid, 'fclose(fid);\nend\n');
fclose(fid);
addpath(standInDir);

% the hand-written database. Metabolites: 13 columns, no header, column 5 the charge and 12
% the date. Reactions: 12 columns with header; the second reaction has neither KEGG id nor
% date
sandboxDir = tempname;
mkdir(sandboxDir);
metaboliteRows = {
    'atp', 'ATP',   'C10H12N5O13P3', 'C10H12N5O13P3', '-4', 'C00002', '5957', '15422', '', '', 'HMDB00538', '19/09/2018', 'Nucleotide'
    'h2o', 'Water', 'H2O',           'H2O',           '0',  'C00001', '962',  '15377', '', '', 'HMDB02111', '20/09/2018', 'Water'};
reactionHeader = {'ReactionID', 'Description', 'Formula', 'Reversible', 'ConfidenceScore', 'Notes', ...
    'References', 'ECNumber', 'KEGGID', 'LastModified', 'Subsystem', 'Subsystem_general'};
reactionRows = {
    'EX_atp(e)', 'ATP_exchange',    'atp[e]<=>',             '1', '0', '', '', '', 'R00001', '19/09/2018', 'Exchange', 'Exchange'
    'ATPM',      'ATP_maintenance', 'atp[c]+h2o[c]->adp[c]', '0', '1', '', '', '', '',       '',           'Energy',   'Energy'};
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

% the compartments.mat the function copies is the first one on the path
compartmentsOnPath = load(which('compartments.mat'));

%% an explicit output folder

outputDir = tempname;
mkdir(outputDir);
createRBioNetDBFromVMHDB('rBioNetDBFolder', outputDir);

% the four files are written
for fileName = {'metab.mat', 'rxn.mat', 'compartments.mat', 'rBioNetSettingsDB.mat'}
    assert(exist(fullfile(outputDir, fileName{1}), 'file') == 2);
end
% metabolites: all 13 columns; charge as text, date as datestr text
saved = load(fullfile(outputDir, 'metab.mat'));
assert(isequal(size(saved.metab), [2 13]));
assert(isequal(saved.metab(:, 1), metaboliteRows(:, 1)));
assert(isequal(saved.metab(:, 5), {'-4'; '0'}));
assert(isequal(saved.metab(:, 12), {'19-Sep-2018'; '20-Sep-2018'}));
% reactions: no header row, the last column (Subsystem_general) removed
saved = load(fullfile(outputDir, 'rxn.mat'));
assert(isequal(size(saved.rxn), [2 11]));
assert(isequal(saved.rxn(:, 1), reactionRows(:, 1)));
assert(isequal(saved.rxn(:, 11), reactionRows(:, 11)));
assert(isequal(saved.rxn(:, 4), {1; 0}));
% KEGG id: kept, or an empty text turned into an empty double
assert(strcmp(saved.rxn{1, 9}, 'R00001'));
assert(isempty(saved.rxn{2, 9}) && isa(saved.rxn{2, 9}, 'double'));
% date: datestr text, or NaT kept when the time stamp is missing
assert(strcmp(saved.rxn{1, 10}, '19-Sep-2018'));
assert(isnat(saved.rxn{2, 10}));
% compartments copied from the path, settings hold the three paths
saved = load(fullfile(outputDir, 'compartments.mat'));
assert(isequal(saved.compartments, compartmentsOnPath.compartments));
saved = load(fullfile(outputDir, 'rBioNetSettingsDB.mat'));
assert(strcmp(saved.met_path, [outputDir filesep 'metab.mat']));
assert(strcmp(saved.rxn_path, [outputDir filesep 'rxn.mat']));
assert(strcmp(saved.comp_path, [outputDir filesep 'compartments.mat']));
% the folder is added to the path and savepath is called (the stand-in)
assert(ismember(outputDir, strsplit(path, pathsep)));
assert(exist(savepathMarker, 'file') == 2);
delete(savepathMarker);

%% the default folder: the current folder

createRBioNetDBFromVMHDB();
for fileName = {'metab.mat', 'rxn.mat', 'compartments.mat', 'rBioNetSettingsDB.mat'}
    assert(exist(fullfile(sandboxDir, fileName{1}), 'file') == 2);
end
saved = load(fullfile(sandboxDir, 'rBioNetSettingsDB.mat'));
assert(strcmp(saved.met_path, [pwd filesep 'metab.mat']));
assert(exist(savepathMarker, 'file') == 2);

%% a folder that is not text is rejected by the input parser

assert(verifyCobraFunctionError('createRBioNetDBFromVMHDB', 'inputs', {'rBioNetDBFolder', 5}));

% restore the path, remove the temporary folders and change the directory
cd(currentDir)
path(savedPath);
clear savepath
rmdir(standInDir, 's');
rmdir(outputDir, 's');
rmdir(sandboxDir, 's');
