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
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the severity audit T009a raised the first defect below (a documented
%       input whose documented result, a plot, is not produced), so this file makes no
%       assertion about the function. The checks described above are those of the wave 04
%       version of this test (git history), to be restored once the defect is fixed.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/makeViolinPlots.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built cell arrays, a hand-written database and
%     invisible figures printed to a temporary folder.
%
% Coverage exemptions:
%     every line - makeViolinPlots is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a). Before the quarantine the
%     test exempted lines 100, 197 (violin plots, the default plot type, need ksdensity from
%     the Statistics and Machine Learning Toolbox, called by external violinplot and not
%     installed on the reference machine) and lines 68-70, 92, 181 (branches for MATLAB
%     releases before R2020a).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Features with negative values are dropped as if they were all zero
%       SEVERITY: wrong-result
%       TRIGGER: a row of sampleData whose values sum below 1e-4, for example
%         {'EX_glc_D[fe]', -1, -2, -3, -4, -5, -6}
%       OBSERVED: the row is removed (line 63 tests sum(...) < 0.0001) and no plot is drawn;
%         likewise a group whose values sum to zero is overwritten with 1e-7 (lines 188-189)
%       EXPECTED: only features that are all zero removed (code comment "remove fluxes that
%         are all zeros"); data of any sign plotted: the header admits any "input data to
%         analyze (e.g., fluxes)" as sampleData, so a feature with negative fluxes is a
%         documented input whose documented result (a plot) is not produced (severity audit
%         T009a)
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
%     - Converted to the quarantine layout after the severity audit 2026-11-15 (T009a).

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMakeViolinPlots'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
