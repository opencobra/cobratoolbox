% The COBRAToolbox: testExpa.m
%
% Purpose:
%     - expa computes the extreme pathways of a model (Schilling, Letscher and Palsson
%       2000): reversible internal reactions are split into a forward and a '_rev' reaction,
%       reactions are sorted (internal first, then by name), exchange reactions open in both
%       directions are taken out of the elimination and added back at the end, and the
%       pathways are returned as the rows of P in the decomposed model (fullmodel) and in the
%       collapsed model (model).
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T021) showed that the collapsed model does not
%       match the input as documented (the objective is lost and the reactions are reordered),
%       so this file makes no assertion about the function. The wave 23 version of this test
%       (git history) checked hand-derived extreme pathways of two three-metabolite models
%       (each row verified with S * p' = 0) and is the starting point once the defect is fixed;
%       its collapsed-P expectation followed the code's net formula, which the help now documents.
%
% Function under test:
%     src/visualization/SAMMIM/expa.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation and exact integer elimination, no solver; hand-built models.
%
% Coverage exemptions:
%     every line - expa is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, independent review T021). Before the quarantine the
%     test exempted lines 340, 352-353, 360-379, 390-391, 398-416 (interactive prompts after
%     15 s of elimination), 470 (keyboard) and 560-579 (askinput, interactive input).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The collapsed model does not match the input model: its objective is zero and its reactions are reordered
%       SEVERITY: wrong-result
%       TRIGGER: [model, fullmodel] = expa(m) with m.c nonzero, or with reactions not already
%         internal-first in name order; for example m.S = sparse([-1 0 -1 0 0; 1 -1 0 0 -1;
%         0 1 0 -1 0]), m.rxns = {'R1'; 'R2'; 'EX_A'; 'EX_C'; 'EX_B'}, m.mets = {'A'; 'B';
%         'C'}, m.lb = [-10; 0; -10; 0; -10], m.ub = [10; 10; 0; 10; 10], m.rev = [1; 0; 0;
%         0; 1], m.c = [0; 1; 0; 0; 0]
%       OBSERVED: (R2025a, 2026-11-17) model.c is [0 0 0 0 0]' for the input c [0 1 0 0 0]',
%         and model.rxns is {'R1'; 'R2'; 'EX_A'; 'EX_B'; 'EX_C'} for the input order {'R1';
%         'R2'; 'EX_A'; 'EX_C'; 'EX_B'} (S, bounds, P and the optional reaction fields follow
%         the new order); fullmodel.c is also all zero. A caller that indexes the output by
%         the input's reaction order, or reads its objective, gets other values
%       EXPECTED: "The model output matches the original model input" (OUTPUTS): the input's
%         reaction order and objective, with only P added
%       LINES: 184-198, 207
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Converted to the quarantine layout after the independent review (T021), 2026-11-17.
%     - Help text of expa corrected to match the code (feature 20261120-151023-doc-matches-code), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testExpa'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
