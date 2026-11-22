% The COBRAToolbox: testPlotEssentialRxns.m
%
% Purpose:
%     - plotEssentialRxns selects the reactions whose flux after deletion lies in
%       essentialityRange (and is non-negative) in at least numModelsPresent models of the
%       table returned by essentialRxn4MultipleModels, draws them as a heat map, and returns
%       their identifiers. The function is QUARANTINED (Constitution III-Defects, quarantine in
%       back-fill campaigns): it errors when no reaction is selected (defect below), so no
%       assertion about the function is made.
%
% Function under test:
%     src/analysis/exploration/plotEssentialRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-built table and invisible figures.
%
% Coverage exemptions:
%     every line - plotEssentialRxns is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Errors when no reaction is selected
%       SEVERITY: error
%       TRIGGER: T = cell2table({'R_1'; 'R2'}, 'VariableNames', {'rxn'}); T.m1 = {50; 'NotIncluded'};
%         T.m2 = {NaN; 30}; plotEssentialRxns(T, [0 100], 5)
%       OBSERVED: MATLAB:nonLogicalConditional, Operands to the logical AND (&&) and OR (||)
%         operators must be convertible to logical scalar values. Use the ANY or ALL functions
%         to reduce operands to logical scalar values. (max of an empty matrix is empty)
%       EXPECTED: no heat map, the message 'Attention: All non-essential reactions have flux
%         above the threshold' and an empty list of reactions
%       LINES: 65-85
%     - DEFECT: The output is a cell array of reaction identifiers, not a table of fluxes
%       SEVERITY: wrong-result
%       TRIGGER: plotEssentialRxns(T, [0 100], 1) with the table above
%       OBSERVED: {'R_1'; 'R2'} (class cell), from table2cell of the rxn column
%       EXPECTED: per the OUTPUT section, a table with the fluxes of the reactions of interest
%         (rows) across models (columns); the code and the tutorial use the identifiers, so the
%         header is the likely error. Severity audit 2026-11-15: OUTPUT documents "Table with
%         reaction fluxes ... for reactions of interest (rows) across models (columns)"; a cell
%         array of reaction identifiers is returned (line 52) - a different type and content
%         from the documented result
%       LINES: 52
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotEssentialRxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
