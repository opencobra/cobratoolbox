% The COBRAToolbox: testConvertCbModelToCNAModel.m
%
% Purpose:
%     - convertCbModelToCNAModel checks the CellNetAnalyzer installation and, when it is found,
%       converts a COBRA model to a CellNetAnalyzer mass-flow project with CNAcobra2cna of the
%       interface submodule external/analysis/CnaCobraInterface (checkCNAinstallation puts
%       that copy on the path).
%     - Once the defects below are fixed, the test should check the call without
%       CellNetAnalyzer (message only, nothing converted) and the conversion with the two
%       CellNetAnalyzer pieces the interface needs (startcna and CNAgenerateMFNetwork) replaced
%       by test doubles in a temporary folder, on a model with ordinary metabolite names (longer
%       than the number of metabolites, some with whitespace), against project fields worked
%       out from the model: species and reaction identifiers as char matrices, the long names
%       with whitespace replaced by underscores in every row, the full stoichiometric matrix,
%       the bounds, and the objective with the sign of a minimisation (-c for a
%       maximisation).
%       Quarantined: no behaviour of convertCbModelToCNAModel is asserted until the error and
%       wrong-result defects below are fixed; this file only opens the test.
%
% Function under test:
%     src/base/io/convertCbModelToCNAModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model conversion on a hand-built model, no solver.
%
% Coverage exemptions:
%     every line - convertCbModelToCNAModel is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Ordinary metabolite names stop the conversion with an index error
%       SEVERITY: error
%       TRIGGER: with the CellNetAnalyzer stand-ins startcna and CNAgenerateMFNetwork (empty
%         functions) on the path: model = createModel({'R1'; 'R2'}, {'first'; 'second'},
%         {'a -> b'; 'b <=> '}); model.metNames = {'glucose'; 'fructose'};
%         convertCbModelToCNAModel(model, 0)
%       OBSERVED: (R2025a, 2026-11-17) 'Index in position 1 exceeds array bounds. Index must not
%         exceed 2.' in external/analysis/CnaCobraInterface/CNAcobra2cna.m line 37, called from
%         line 32: the loop of CNAcobra2cna.m lines 36-43 runs i = 1:size(cnap.specLongName, 2)
%         (8, the longest name) over the rows specLongName(i, :) (2 metabolites); the fault is
%         in the read-only interface submodule
%       EXPECTED: the project of the documented COBRA model input (metNames of any length)
%       LINES: 32
%     - DEFECT: Whitespace in metabolite names is replaced only in the first rows
%       SEVERITY: wrong-result
%       TRIGGER: with the same stand-ins: model = createModel({'R1'; 'R2'; 'R3'}, {'R1'; 'R2';
%         'R3'}, {'a -> b'; 'b -> c + d'; 'c + d <=> '}); model.metNames = {'x y'; 'u v'; 'p';
%         'q r'}; convertCbModelToCNAModel(model, 0)
%       OBSERVED: (R2025a, 2026-11-17) specLongName rows 'x_y', 'u_v', 'p', 'q r': the same loop
%         (CNAcobra2cna.m lines 36-43, reached from line 32) visits only as many rows as the
%         longest name has characters (3 of 4), so the fourth name keeps its space
%       EXPECTED: 'q_r' as well, as the warning and replacement of CNAcobra2cna.m lines 38-41
%         intend for every metabolite name
%       LINES: 32
%     - DEFECT: without CellNetAnalyzer a call with an output stops with an unassigned-output error
%       SEVERITY: cosmetic
%       TRIGGER: cnaModel = convertCbModelToCNAModel(model) when startcna is not on the path
%       OBSERVED: MATLAB R2025a: 'Output argument "cnaModel" (and possibly others) not assigned
%         a value in the execution with "convertCbModelToCNAModel" function.' after the message
%         of checkCNAinstallation; the call cannot succeed without CellNetAnalyzer, only the
%         message is unhelpful
%       EXPECTED: an error that says CellNetAnalyzer is needed
%       LINES: 31-33
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Quarantined after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertCbModelToCNAModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
