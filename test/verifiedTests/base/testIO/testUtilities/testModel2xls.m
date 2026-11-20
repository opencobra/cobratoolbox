% The COBRAToolbox: testModel2xls.m
%
% Purpose:
%     - model2xls writes a model to an Excel workbook with a 'Reaction List' sheet (one column
%       per reaction field present: identifiers, names, formulas, GPR rules, bounds as text,
%       objective, subsystems) and a 'Metabolite List' sheet (identifiers, names, formulas,
%       charges, compartment names).
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T027/T028) showed that the documented optional
%       input compNames cannot be omitted when compSymbols is given, so this file makes no
%       assertion about the function. The wave version of this test (git history) wrote
%       hand-built models and read the sheets back (formulas of printRxnFormula, GPR rules of
%       creategrRulesField, negated objective for a minimisation, joined nested subsystems,
%       5000-character cut, [u] for metabolites without compartment, compartment names from
%       the model, the given symbols or getDefaultCompartments); it is the starting point once
%       the defect is fixed.
%
% Function under test:
%     src/base/io/utilities/model2xls.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - file output for hand-built models of two or three reactions, no solver.
%
% Coverage exemptions:
%     every line - model2xls is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, independent review T027/T028). Before the
%     quarantine the test reached every executable line.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: compSymbols without compNames stops the call
%       SEVERITY: error
%       TRIGGER: model2xls(model, fileName, compSymbols) with compSymbols given and compNames
%         omitted; for example model2xls(createModel({'R1'}, {''}, {'a[c] -> b[c]'}),
%         [tempname '.xls'], {'c'})
%       OBSERVED: (R2025a, 2026-11-17) "Not enough input arguments." (MATLAB:minrhs) at line
%         173: the defaults of lines 87-94 are set only when compSymbols is missing, so
%         compNames is never defined when compSymbols alone is given, and line 173 reads it
%       EXPECTED: the call to succeed, as the header lists compSymbols and compNames as two
%         separate entries under OPTIONAL INPUT (lines 31-34), for example with compNames
%         defaulting to compSymbols (as writeCbModel does)
%       LINES: 87-94, 171, 173
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Converted to the quarantine layout after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testModel2xls'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
