% The COBRAToolbox: testRMTAsaveInExcel.m
%
% Purpose:
%     - rMTAsaveInExcel writes the rMTA transformation scores (bTS, mTS, wTS, rTS) of each
%       knock-out to an Excel file: one sheet per alpha value sorted by rTS, the sheet
%       TOP_GENES_ID, optionally the differential expression of the deleted genes and the
%       ranking of one gene (SUMMARY). The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): the documented default of alpha_values cannot be
%       used (defect below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/rMTA/rMTAsaveInExcel.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built score tables and a
%     temporary folder.
%
% Coverage exemptions:
%     every line - rMTAsaveInExcel is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented default of alpha_values cannot be used
%       SEVERITY: unusable-option
%       TRIGGER: TS.bTS = [1 2; 3 4]; TS.mTS = [1; 1]; TS.wTS = TS.bTS; TS.rTS = TS.bTS;
%         rMTAsaveInExcel(fullfile(tmpDir, 'r.xlsx'), TS, {'g1'; 'g2'}), then the same call
%         with alpha_values = -1
%       OBSERVED: without alpha_values: error 'Not enough input arguments.'
%         (rMTAsaveInExcel:47; alpha_values is a named argument of the signature, so the
%         addOptional default -1 is never used); with -1: the file has only the sheet
%         'alpha = 1', because num_alphas = numel(-1) = 1 is set on line 51 before line 53
%         replaces alpha_values by 1:2
%       EXPECTED: the documented default alpha_1, alpha_2, ...: one sheet per column of
%         TSscore.bTS ('alpha = 1' and 'alpha = 2')
%       LINES: 41, 47, 51-53
%     - DEFECT: The sheets written with xlswrite need Microsoft Excel
%       SEVERITY: unusable-option
%       TRIGGER: on Linux: genes = {'g1'; 'g2'; 'g3'; 'g4'}; TS.bTS = [3 2; 1 4; -Inf -Inf;
%         2 1]; TS.mTS = [0.5; 0.7; -Inf; -0.2]; TS.wTS = [1 1; -2 0.5; -Inf -Inf; 0 1];
%         TS.rTS = [2 -1; 1 3; -Inf -Inf; -0.5 0.5]; gi = table(genes, {'A'; 'B'; 'C'; 'D'},
%         'VariableNames', {'gene', 'name'}); dg = table({'g2'; 'g4'; 'g9'; ''; 'g2'}, [1.5;
%         -0.3; 2; 0; 1.5], 'VariableNames', {'gene', 'logFC'});
%         rMTAsaveInExcel(fullfile(tmpDir, 'res.xlsx'), TS, genes, [0.5 1], 'gene_info', gi,
%         'differ_genes', dg, 'RankingGeneID', 'g2')
%       OBSERVED: every xlswrite call warns 'Unable to write to Excel format, attempting to
%         write file to CSV format.' (the ranking cells, TOP_GENES_ID and TOP_GENES_diff_expr
%         go to CSV files, not to sheets of res.xlsx) and the SUMMARY write stops with 'An
%         error occurred while writing file to CSV format. To write to an Excel file, convert
%         your data to a table and use writetable.' (xlswrite:112, called on line 199)
%       EXPECTED: all sheets in res.xlsx on every platform (writetable, as used for the
%         alpha sheets), or a documented Windows/Excel requirement
%       LINES: 98-103, 116-117, 133-134, 199
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRMTAsaveInExcel'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
