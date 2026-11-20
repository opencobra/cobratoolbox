% The COBRAToolbox: testTmodelStats.m
%
% Purpose:
%     - TmodelStats summarizes a template model (Tmodel) of modelBorgifier, or a plain model:
%       the number and share of reactions and metabolites with each annotation field of
%       TmodelFields, the number and share of metabolites per compartment and in total, the
%       exchange reactions, the number of metabolites ignoring the compartment and, for a
%       Tmodel of two or more models, the reactions and metabolites unique to each model and
%       shared between each pair of models.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T027/T028) showed that the share in the 'Total'
%       row of metsByComp is inverted, which is visible for a plain model with metabolites
%       without a compartment suffix, so this file makes no assertion about the function.
%       The wave version of this test (git history) built a two-model Tmodel of four
%       metabolites in three compartments by hand and checked every count and share, the
%       extension of an existing Stats structure, a one-model Tmodel and a plain model; it is
%       the starting point once the defect is fixed.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/TmodelStats.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     every line - TmodelStats is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, independent review T027/T028). Before the
%     quarantine the test reached every executable line.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The share of metabolites with a compartment ('Total' row) is inverted
%       SEVERITY: wrong-result
%       TRIGGER: a plain model in which some metabolite identifiers have no '[x]' compartment
%         suffix, for example Stats = TmodelStats(struct('rxns', {{'R1'}}, 'mets',
%         {{'a[c]'; 'b[c]'; 'glc'}}, 'S', sparse([1; -1; 0])))
%       OBSERVED: (R2025a, 2026-11-17) Stats.metsByComp{end, 2} = [2 1.5]: line 123 computes
%         count \ nMets (left division, nMets / count = 3 / 2) instead of count / nMets. For
%         identifiers such as {'a_c'; 'b_c'} (no '[x]' suffix at all) it is [0 Inf]. When
%         every identifier has a suffix, count = nMets and both give 1, which hides the defect
%       EXPECTED: [2 0.6667] (2/3) and [0 0]: the comment of line 112 ("Total metabolite with
%         compartment (should be 100%)") and line 120, which computes each compartment's
%         share as nMetsInComp / nMets, give the intent; the header (line 2) says the
%         function "Can also be used on a normal model"
%       LINES: 123
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Quarantined after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTmodelStats'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
