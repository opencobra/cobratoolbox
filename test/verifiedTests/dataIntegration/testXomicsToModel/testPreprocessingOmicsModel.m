% The COBRAToolbox: testPreprocessingOmicsModel.m
%
% Purpose:
%     - preprocessingOmicsModel(inputData, setMinActiveFlux, setMaxActiveFlux, specificData,
%       TolMaxBoundary) reads every sheet of an Excel workbook into the fields of specificData,
%       optionally sets the bounds of the "Force activity" constraints, and converts medium
%       concentrations into maximal uptake fluxes. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): it lists the sheets with xlsfinfo,
%       which cannot read a workbook written by MATLAB's writetable, and the call is then an
%       error; no assertion about the function is made.
%
% Function under test:
%     src/dataIntegration/XomicsToModel/prepareData/preprocessingOmicsModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write small workbooks into a tempname folder.
%
% Coverage exemptions:
%     every line - preprocessingOmicsModel is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A workbook written by MATLAB writetable is an error
%       SEVERITY: error
%       TRIGGER: f = fullfile(tempname, 'in.xlsx'), its folder made with mkdir;
%         writetable(table({'g1'; 'g2'}, 'VariableNames', {'genes'}), f, 'Sheet', 'activeGenes');
%         preprocessingOmicsModel(f, 1, 1)
%       OBSERVED: (R2025a, Linux, 2026-11-23) error "Brace indexing is not supported for
%         variables of this type." - xlsfinfo returns, instead of the sheet names, the text
%         "Unreadable Excel file: Could not open file .../docProps/app.xml. No such file or
%         directory." (the workbook has no docProps/app.xml), and line 61 indexes that text
%         with braces; with a docProps/app.xml added, xlsfinfo lists no sheet (it does not
%         recognise the worksheet relations MATLAB writes) and only specificData.inputData is
%         returned; readtable reads the same workbook
%       EXPECTED: specificData.activeGenes = {'g1'; 'g2'} (the header: every sheet of the file
%         is read; sheetnames, the replacement of xlsfinfo, lists the sheets of such a file)
%       LINES: 57, 60-62
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPreprocessingOmicsModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
