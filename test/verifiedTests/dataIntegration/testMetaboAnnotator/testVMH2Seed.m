% The COBRAToolbox: testVMH2Seed.m
%
% Purpose:
%     - VMH2Seed reads MetaboliteTranslationTable.xlsx (a column whose header contains 'vmh'
%       and one whose header contains 'seed') from the MATLAB search path and writes the SEED
%       id of every table row whose VMH id equals the VMHId of a metabolite into the seed field
%       of that metabolite, with a dated seed_source 'MetaboliteTranslationTable.xlsx:manual:'.
%       Existing SEED ids are overwritten (documented). Rows without a VMH id and VMH ids not
%       in the structure change nothing.
%     - The test writes a small MetaboliteTranslationTable.xlsx by hand into a temporary
%       folder and runs the function from that folder, where xlsread finds it before the file
%       of the tutorials submodule; expected values are the values written (hand derivation).
%       A last section checks one row of the shipped file (h2o -> cpd00001, read in the shipped
%       table) and is skipped with a message when the tutorials submodule is not checked out.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/connect2resources/VMH2Seed.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, a hand-built metabolite structure and spreadsheet.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A blank SEED cell overwrites the SEED id with NaN and writes a source
%       SEVERITY: cosmetic
%       TRIGGER: MetaboliteTranslationTable.xlsx written with writecell({'VMHmetabolite',
%         'seed'; 'h2o', ''}) and VMH2Seed(struct('VMH_h2o', struct('VMHId', 'h2o', 'metNames',
%         'Water', 'seed', 'cpd00001')))
%       OBSERVED: (R2025a, 2026-11-15) seed = NaN and seed_source =
%         'MetaboliteTranslationTable.xlsx:manual:<date>': xlsread returns NaN for the blank
%         cell and line 39 only tests isempty, which is false for NaN. The shipped table has
%         no blank SEED cell, so the shipped file does not trigger it; the input is skipped
%         below.
%       EXPECTED: a blank SEED cell leaves the metabolite unchanged
%       LINES: 39-41
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testVMH2Seed'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the hand-built translation table, written into a temporary folder that becomes the
% current folder. A row without a VMH id (blank cell, read as NaN) and a VMH id that no
% metabolite carries are ignored
sandboxDir = tempname;
mkdir(sandboxDir);
tableRows = {'VMHmetabolite', 'seed'
    'h2o', 'cpd00001'
    'atp', 'cpd00002'
    '', 'cpd00099'
    'notInStructure', 'cpd00003'};
writecell(tableRows, fullfile(sandboxDir, 'MetaboliteTranslationTable.xlsx'));
cd(sandboxDir);

newMetabolite = @(vmhId, name, seed) struct('VMHId', vmhId, 'metNames', name, 'seed', seed);

%% SEED ids are written for the metabolites listed in the table

metabolites = struct();
metabolites.VMH_h2o = newMetabolite('h2o', 'Water', NaN);         % no SEED id: added
metabolites.VMH_atp = newMetabolite('atp', 'ATP', 'cpdOld');      % SEED id present: overwritten
metabolites.VMH_glc_D = newMetabolite('glc_D', 'Glucose', NaN);   % not in the table: unchanged

annotated = VMH2Seed(metabolites);

% exact text: the SEED ids written in the table
assert(strcmp(annotated.VMH_h2o.seed, 'cpd00001'));
assert(strcmp(annotated.VMH_atp.seed, 'cpd00002'));
assert(startsWith(annotated.VMH_h2o.seed_source, 'MetaboliteTranslationTable.xlsx:manual:'));
assert(startsWith(annotated.VMH_atp.seed_source, 'MetaboliteTranslationTable.xlsx:manual:'));
% the metabolite not listed keeps its NaN and gets no source; no metabolite is added
assert(isnan(annotated.VMH_glc_D.seed) && ~isfield(annotated.VMH_glc_D, 'seed_source'));
assert(isequal(fieldnames(annotated), fieldnames(metabolites)));
% the other fields are kept
assert(strcmp(annotated.VMH_atp.metNames, 'ATP'));

% the hand-built file is no longer needed
cd(currentDir)
rmdir(sandboxDir, 's');

%% the shipped file (only where the tutorials submodule is checked out)

% the shipped table lies in tutorials/dataIntegration/metaboAnnotator/data; it is read from
% an empty temporary folder, so that no other MetaboliteTranslationTable.xlsx shadows it
emptyDir = tempname;
mkdir(emptyDir);
cd(emptyDir);
shippedFile = which('MetaboliteTranslationTable.xlsx');
if ~isempty(shippedFile) && contains(shippedFile, fullfile('metaboAnnotator', 'data'))
    annotated = VMH2Seed(struct('VMH_h2o', newMetabolite('h2o', 'Water', NaN)));
    % the shipped row of h2o lists cpd00001
    assert(strcmp(annotated.VMH_h2o.seed, 'cpd00001'));
else
    fprintf('skipped: MetaboliteTranslationTable.xlsx of the tutorials submodule is not on the path\n');
end

% remove the temporary folder and change the directory
cd(currentDir)
rmdir(emptyDir, 's');
