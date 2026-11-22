% The COBRAToolbox: testFindCarbonRxns.m
%
% Purpose:
%     - findCarbonRxns counts the carbons of every metabolite from its formula, lists the
%       reactions that act on a non-currency metabolite with at least nCarbonThr carbons, and
%       the reactions whose metabolites all have no carbon.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T027/T028) showed that the carbon count, a
%       documented output, is wrong for every formula with a two-letter element symbol that
%       begins with C (Cl, Ca, Co, Cu, ...), so this file makes no assertion about the
%       function. The wave version of this test (git history) built a model of eight
%       metabolites and six reactions by hand and checked the carbon counts of the three formula
%       cases, the currency exclusion, thresholds that select none, some and all metabolites,
%       and the zero-carbon list; it is the starting point once the defect is fixed.
%
% Function under test:
%     src/analysis/exploration/findCarbonRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-ups on a hand-built model, no solver.
%
% Coverage exemptions:
%     every line - findCarbonRxns is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, independent review T027/T028). Before the
%     quarantine the test reached every executable line.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Two-letter element symbols beginning with C are counted as carbon
%       SEVERITY: wrong-result
%       TRIGGER: a metabolite whose formula contains Ca, Cl, Co, Cu, Cr, Cd, Ce or Cs; for
%         example model.mets = {'cl[c]'; 'ca2[c]'; 'caox[c]'}, model.metFormulas = {'Cl';
%         'Ca'; 'CaC2O4'}, model.S = sparse([-1; -1; 1]), model.rxns = {'R1'};
%         [hiCarbonRxns, zeroCarbonRxns, nCarbon] = findCarbonRxns(model, 1)
%       OBSERVED: (R2025a, 2026-11-17) nCarbon = [1 1 1], hiCarbonRxns = {'R1'} and
%         zeroCarbonRxns empty: the regular expression C(\d*) of line 42 matches the C of the
%         element symbol, only the first match is used (line 47) and an empty digit group
%         counts as one carbon (line 50); calcium oxalate counts 1 carbon instead of 2
%       EXPECTED: nCarbon = [0 0 2] (the header: "The number of carbons in each metabolite",
%         from the "metabolite elemental formulas"); a reaction that acts only on chloride
%         or calcium belongs in zeroCarbonRxns, not in hiCarbonRxns
%       LINES: 42, 47-50
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Converted to the quarantine layout after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindCarbonRxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
