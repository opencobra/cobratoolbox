% The COBRAToolbox: testAddFluxFromFileWidthAndColor.m
%
% Purpose:
%     - addFluxFromFileWidthAndColor reads reaction IDs and fluxes from a CSV file (header
%       row first) and sets the line width of the map reactions from the flux relative to
%       the largest absolute flux (bands 0, (0, 0.2], (0.2, 0.5], (0.5, 0.8], (0.8, 1] give
%       1, 2, 5, 8, 10; reactions without flux data get 1), colours reactions with positive
%       flux in red and negative flux in indigo shades (darker for wider lines), zero-flux
%       reactions in light grey, and colours the molecules of each reaction carrying flux
%       (all other molecules white). Expected widths and colours are derived by hand from
%       the documented bands and shade lists. CSV files are written to a tempname folder.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns; severity audit T009a): numeric reaction IDs of different lengths are not
%       matched to the map (defect below), so no assertion about the function is made; the
%       checks described above are the plan for the test once the defect is resolved.
%
% Function under test:
%     src/visualization/metabolicCartography/addFluxFromFileWidthAndColor.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built map and CSV files.
%
% Coverage exemptions:
%     every line - addFluxFromFileWidthAndColor is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Numeric reaction IDs of different lengths do not match the map
%       SEVERITY: wrong-result
%       TRIGGER: CSV file 'rxnID,flux' / '1,5' / '10,10'; map.rxnName = {'1'; '10'} (aliases
%         a -> b, b -> c); [map2, flux2, fluxMap] = addFluxFromFileWidthAndColor(map, csvFile)
%       OBSERVED: MATLAB R2025a: flux2 = {' 1', 5, 5; '10', 10, 10} (cellstr(num2str([1; 10]))
%         keeps the leading blank of ' 1'), so map reaction '1' is not matched: fluxMap
%         = {'1', 1; '10', 10} and its colour is unchanged.
%       EXPECTED: reaction '1' gets width 5 and colour 'FFff8787', and flux2 lists it as '1'.
%         Severity audit 2026-11-15: csvFilePath documents "reaction IDs in the first column"
%         and lines 44-45 convert numeric IDs on purpose; num2str pads " 1" so reaction "1" is
%         never matched and keeps its width and colour - the documented result ("Rxn line
%         width is proportional to flux magnitude") is not produced for it
%       LINES: 45
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15; severity audit
%       2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddFluxFromFileWidthAndColor'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
