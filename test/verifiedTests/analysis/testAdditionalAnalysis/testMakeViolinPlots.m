% The COBRAToolbox: testMakeViolinPlots.m
%
% Purpose:
%     - makeViolinPlots draws, for every feature (row) of sampleData whose values do not sum
%       below 1e-4, a violin plot or box plot and prints it to <feature>_<name>.png in the
%       current folder: one plot over all samples when sampleInformation is empty (only when
%       the feature takes more than two distinct values), or one plot per group of the
%       stratification column (column 2 by default) of sampleInformation, only when every
%       group holds at least two distinct values. The plot name is the VMH metabolite name of
%       the feature (prefix EX_ and suffix [fe] removed, also Host_ and _eb without
%       stratification) or the stripped identifier, with blanks and the characters ()-:/
%       replaced by '_', doubled '_' merged and cut to 25 characters, preceded by the
%       plotted feature and, for a named stratification, by its name.
%     - The test writes a small VMH database to a temporary folder and runs the function
%       there (loadVMHDatabase reads the files of the current folder first). Expected file
%       names follow from the rules above applied by hand to the features and groups.
%     - The globals of loadVMHDatabase and the figure visibility are restored at the end.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/makeViolinPlots.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built cell arrays, a hand-written database and
%     invisible figures printed to a temporary folder.
%
% Coverage exemptions:
%     Lines 100, 197: violin plots (the default plot type) need ksdensity from the
%     Statistics and Machine Learning Toolbox (called by external violinplot), not installed
%     on the reference machine; the section that draws them runs only where it is.
%     Lines 68-70, 92, 181: branches for MATLAB releases before R2020a (version-specific;
%     the test machines run R2020a or newer).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Features with negative values are dropped as if they were all zero
%       SEVERITY: limitation
%       TRIGGER: a row of sampleData whose values sum below 1e-4, for example
%         {'EX_glc_D[fe]', -1, -2, -3, -4, -5, -6}
%       OBSERVED: the row is removed (line 63 tests sum(...) < 0.0001) and no plot is drawn;
%         likewise a group whose values sum to zero is overwritten with 1e-7 (lines 188-189)
%       EXPECTED: only features that are all zero removed (code comment "remove fluxes that
%         are all zeros"); data of any sign plotted
%       LINES: 63, 188-189
%     - DEFECT: Box plots print the handle array of every plot
%       SEVERITY: cosmetic
%       TRIGGER: makeViolinPlots(sampleData, {}, 'plotType', 'Boxplot') with a plotted feature
%       OBSERVED: "ans = 7x1 Line array" (7x<groups> with stratification) is printed for
%         every plot: the calls to cobraBoxplot have no semicolon
%       EXPECTED: no console output
%       LINES: 102, 199
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMakeViolinPlots'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% save the global variables read by loadVMHDatabase (no additional reactions in this test)
globalsBefore = who('global');
global additionalSecretionRxns additionalUptakeRxns
savedSecretion = additionalSecretionRxns;
savedUptake = additionalUptakeRxns;
additionalSecretionRxns = [];
additionalUptakeRxns = [];

% figures are drawn invisibly
savedVisibility = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');

% the VMH database of the test (names used: ac Acetate, glc_D D-Glucose, but
% 'Butyrate (C4:0)/x') in a temporary folder that is also the output folder
sandboxDir = tempname;
mkdir(sandboxDir);
writeTestDatabase(sandboxDir);
cd(sandboxDir);

% six samples; Group: A A A B B B; Other: x y z x y z
sampleData = [{'', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6'}
    {'EX_glc_D[fe]'}, num2cell([1 2 3 4 5 6])
    {'Host_EX_but[fe]'}, num2cell([1 2 3 4 5 7])
    {'EX_some_very_long_metabolite_name_x[fe]'}, num2cell([2 2 3 4 5 7])
    {'EX_two[fe]'}, num2cell([1 1 1 2 2 2])
    {'EX_ac[fe]'}, num2cell([0 0 0 1 2 3])
    {'EX_zero[fe]'}, num2cell([0 0 0 0 0 0])];
sampleInformation = {'ID', 'Group', 'Other'; 'S1', 'A', 'x'; 'S2', 'A', 'y'; 'S3', 'A', 'z'; ...
    'S4', 'B', 'x'; 'S5', 'B', 'y'; 'S6', 'B', 'z'};

%% no sample information: one box plot per feature with more than two distinct values

% EX_two has two distinct values and EX_zero is all zero: no plot. Host_ is removed, so
% EX_but is Butyrate (C4:0)/x -> Butyrate_C4_0_x; the identifier
% some_very_long_metabolite_name_x (not in the database) is cut to 25 characters
makeViolinPlots(sampleData, {}, 'plotType', 'Boxplot', 'plottedFeature', 'Net secretion', ...
    'unit', 'mmol/person/day');
assert(isequal(listPlots(sandboxDir), sort({'Net_secretion_D_Glucose.png', 'Net_secretion_Butyrate_C4_0_x.png', ...
    'Net_secretion_some_very_long_metabolite.png', 'Net_secretion_Acetate.png'})));
% the function closes its figures
assert(isempty(findall(0, 'Type', 'figure')));
delete(fullfile(sandboxDir, '*.png'));

%% no sample information, without feature name and unit

makeViolinPlots(sampleData, {}, 'plotType', 'Boxplot');
assert(isequal(listPlots(sandboxDir), sort({'D_Glucose.png', 'Butyrate_C4_0_x.png', ...
    'some_very_long_metabolite.png', 'Acetate.png'})));
delete(fullfile(sandboxDir, '*.png'));

%% named stratification with two groups

% Group A of EX_two holds one value (1) and group A of EX_ac only zeros: no plots. Host_ is
% kept with stratification, so the name of Host_EX_but[fe] is Host_but
makeViolinPlots(sampleData, sampleInformation, 'plotType', 'Boxplot', 'stratification', 'Group', ...
    'plottedFeature', 'Flux', 'unit', 'mmol/person/day');
assert(isequal(listPlots(sandboxDir), sort({'Flux_Group_D_Glucose.png', 'Flux_Group_Host_but.png', ...
    'Flux_Group_some_very_long_metabolite.png'})));
assert(isempty(findall(0, 'Type', 'figure')));
delete(fullfile(sandboxDir, '*.png'));

%% default stratification (second column) without feature name and unit

% the second column is Group, so the same features as above are plotted, without prefix
makeViolinPlots(sampleData, sampleInformation, 'plotType', 'Boxplot');
assert(isequal(listPlots(sandboxDir), sort({'D_Glucose.png', 'Host_but.png', 'some_very_long_metabolite.png'})));
delete(fullfile(sandboxDir, '*.png'));

%% named stratification with three groups

% x = S1, S4; y = S2, S5; z = S3, S6: every group of every non-zero feature holds two
% distinct values, so EX_two (not in the database) and EX_ac (Acetate) are plotted as well
makeViolinPlots(sampleData, sampleInformation, 'plotType', 'Boxplot', 'stratification', 'Other');
assert(isequal(listPlots(sandboxDir), sort({'Other_D_Glucose.png', 'Other_Host_but.png', ...
    'Other_some_very_long_metabolite.png', 'Other_two.png', 'Other_Acetate.png'})));
delete(fullfile(sandboxDir, '*.png'));

%% seven groups (random box colours, smaller font, rotated labels)

% fourteen samples in seven groups of two distinct values each; the colours of more than
% three groups are random, so the seed is fixed
rng(20261115);
sampleIds = arrayfun(@(k) sprintf('T%d', k), 1:14, 'UniformOutput', false);
siteData = [[{''}, sampleIds]; [{'EX_glc_D[fe]'}, num2cell(1:14)]];
siteInformation = [{'ID', 'Site'}; [sampleIds', arrayfun(@(k) sprintf('g%d', ceil(k / 2)), (1:14)', ...
    'UniformOutput', false)]];
makeViolinPlots(siteData, siteInformation, 'plotType', 'Boxplot', 'stratification', 'Site');
assert(isequal(listPlots(sandboxDir), {'Site_D_Glucose.png'}));
delete(fullfile(sandboxDir, '*.png'));

%% violin plots (default plot type), only where the Statistics and Machine Learning Toolbox is installed

if exist('ksdensity', 'file') == 2 && license('test', 'Statistics_Toolbox')
    makeViolinPlots(sampleData, {});
    assert(isequal(listPlots(sandboxDir), sort({'D_Glucose.png', 'Butyrate_C4_0_x.png', ...
        'some_very_long_metabolite.png', 'Acetate.png'})));
    delete(fullfile(sandboxDir, '*.png'));
    makeViolinPlots(sampleData, sampleInformation, 'stratification', 'Group');
    assert(isequal(listPlots(sandboxDir), sort({'Group_D_Glucose.png', 'Group_Host_but.png', ...
        'Group_some_very_long_metabolite.png'})));
    delete(fullfile(sandboxDir, '*.png'));
else
    fprintf('skipped: violin plots need ksdensity (Statistics and Machine Learning Toolbox)\n');
end

%% an unknown plot type raises an error (with and without sample information)

% the error is raised when the first plot is drawn, after its figure was opened
assert(verifyCobraFunctionError('makeViolinPlots', 'inputs', {sampleData, {}, 'plotType', 'Pie'}, ...
    'testMessage', 'Invalid entry for plot type!'));
close all
assert(verifyCobraFunctionError('makeViolinPlots', 'inputs', {sampleData, sampleInformation, ...
    'plotType', 'Pie'}, 'testMessage', 'Invalid entry for plot type!'));
close all
assert(isempty(dir(fullfile(sandboxDir, '*.png'))));

%% clean up

cd(fileDir);
rmdir(sandboxDir, 's');
set(0, 'DefaultFigureVisible', savedVisibility);
additionalSecretionRxns = savedSecretion;
additionalUptakeRxns = savedUptake;
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clearvars('-global', newGlobals{:});
end

% change the directory
cd(currentDir)

function names = listPlots(folder)
% names of the PNG files in folder, sorted
files = dir(fullfile(folder, '*.png'));
names = sort({files.name});
end

function writeTestDatabase(sandboxDir)
% writes MetaboliteDatabase.txt (13 tab-separated columns, no header) and
% ReactionDatabase.txt (12 columns, header) as read by loadVMHDatabase; the reaction
% fields contain no blank, so that readtable detects the tab as in the full database
metaboliteRows = {
    'ac',    'Acetate',    'C2H3O2',        'C2H3O2',        '-1', 'C00033', '176',  '30089', '', '', 'HMDB00042', '19/09/2018', 'Pyruvate metabolism'
    'atp',   'ATP',        'C10H12N5O13P3', 'C10H12N5O13P3', '-4', 'C00002', '5957', '15422', '', '', 'HMDB00538', '19/09/2018', 'Nucleotide'
    'h2o',   'Water',      'H2O',           'H2O',           '0',  'C00001', '962',  '15377', '', '', 'HMDB02111', '19/09/2018', ''
    'glc_D', 'D-Glucose',  '',              'C6H12O6',       '0',  'C00031', '',     '',      '', '', '',          '19/09/2018', 'Glycolysis'
    'lac_L', 'L-Lactate',  '',              'C3H5O3',        '-1', 'C00186', '',     '422',   '', '', '',          '19/09/2018', 'Pyruvate metabolism'
    'but',   'Butyrate (C4:0)/x', '',       'C4H7O2',        '-1', 'C00246', '',     '',      '', '', '',          '19/09/2018', 'Fatty acid'};
reactionHeader = {'ReactionID', 'Description', 'Formula', 'Reversible', 'ConfidenceScore', 'Notes', ...
    'References', 'ECNumber', 'KEGGID', 'LastModified', 'Subsystem', 'Subsystem_general'};
reactionRows = {
    'EX_atp(e)',   'ATP_exchange',        'atp[e]<=>',             '1', '0', '', '', '', '', '19/09/2018', 'Exchange',   'Exchange'
    'EX_lac_L(e)', 'Lactate_exchange',    'lac_L[e]<=>',           '1', '0', '', '', '', '', '19/09/2018', 'Exchange',   'Exchange'
    'ATPM',        'ATP_maintenance',     'atp[c]+h2o[c]->adp[c]', '0', '1', '', '', '', '', '19/09/2018', 'Energy',     'Energy'
    'PGI',         'Glucose_isomerase',   'g6p[c]<=>f6p[c]',       '1', '1', '', '', '', '', '19/09/2018', 'Glycolysis', 'Carbohydrate'
    'PFK',         'Phosphofructokinase', 'f6p[c]->fdp[c]',        '0', '1', '', '', '', '', '19/09/2018', 'Glycolysis', 'Carbohydrate'
    'NOSUB',       'No_subsystem',        'a[c]->b[c]',            '0', '1', '', '', '', '', '19/09/2018', '',           ''};
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
end
