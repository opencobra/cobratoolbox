% The COBRAToolbox: testSummaryConcentrations.m
%
% Purpose:
%     - summaryConcentrations summarises metabolomics concentrations (mean and SD) per group and
%       perturbation, optionally removing outlier samples and mapping compound names to model
%       metabolites with a model and/or a lookup table. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): the lookup table cannot be
%       used without a model, and the model mapping assigns a metabolite to every compound whose
%       name contains another compound's name, so no assertion about the function is made.
%
% Function under test:
%     src/dataIntegration/XomicsToModel/metabolomics/summaryConcentrations.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no solver; a hand-built table of measurements and a hand-built two-metabolite
%     model structure would suffice.
%
% Coverage exemptions:
%     every line - summaryConcentrations is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: param.metLookupTable without param.model stops with an undefined variable
%       SEVERITY: error
%       TRIGGER: summaryConcentrations(T, param) with param.metLookupTable = table({'citrate'},
%         {'cit'}, {'cit[e]'}, 'VariableNames', {'ChemicalName', 'AlternativeName', 'Mets'})
%         and no param.model; T a table with string columns sample, type, compound,
%         concentration, group, perturbation and compounds "citrate" and "isocitrate"
%       OBSERVED: Unrecognized function or variable 'model'. (line 97; R2025a, 2026-11-15)
%       EXPECTED: the documentation allows the lookup table alone ("either ... or/and"); the
%         compound citrate mapped to cit[e]
%       LINES: 97, 102
%     - DEFECT: A compound whose name contains another compound's name receives that metabolite
%       SEVERITY: wrong-result
%       TRIGGER: the table above with param.model.mets = {'cit[e]'; 'icit[c]'} and
%         param.model.metNames = {'Citrate'; 'Isocitrate'}
%       OBSERVED: summaryConc.avr_A.mets = ["cit[e]"; "cit[e]"] (R2025a, 2026-11-15): line 73
%         selects every compound that contains "citrate", including "isocitrate", and the
%         isocitrate pass does not reset it because Isocitrate has no [e] form
%       EXPECTED: ["cit[e]"; ""] - isocitrate has no extracellular metabolite in the model
%       LINES: 73
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSummaryConcentrations'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
