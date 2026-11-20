% The COBRAToolbox: testMetaboliteMassBalancePlot.m
%
% Purpose:
%     - metaboliteMassBalancePlot draws two bar charts with the top N reactions that consume and
%       produce a metabolite in a flux vector. A test would check the bars and reaction labels
%       against a hand-built model and flux vector.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       every call with a model that has the documented fields only (S, mets, rxns) and at least one
%       consuming or producing reaction stops with an error (first defect below), so this file makes
%       no assertion about the function.
%
% Function under test:
%     src/analysis/thermo/thermoFBA/metaboliteMassBalancePlot.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a createModel model, a hand-built flux vector, a figure, no solver.
%
% Coverage exemptions:
%     every line - metaboliteMassBalancePlot is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The reaction labels read an undocumented legacy field model.rxn(k).directionality
%       SEVERITY: error
%       TRIGGER: model = createModel({'r1','r2','r3'}, {'r1','r2','r3'}, {'-> A','A ->','A ->
%       B'}); solution.full = [3; 1; 2]; metaboliteMassBalancePlot(model, 'A[c]', solution, 2)
%       OBSERVED: 'Unrecognized field name "rxn".' at line 62 (MATLAB R2025a); the producer labels
%       use the same field at line 82
%       EXPECTED: the documented fields only (S, mets, rxns) are used; the labels are the reaction
%       identifiers of the top consumers and producers
%       LINES: 62-67, 82-87
%     - DEFECT: The empty-producer branch labels the consumer axes
%       SEVERITY: cosmetic
%       TRIGGER: a metabolite with no producing reaction in the flux vector
%       OBSERVED: line 79 sets the YTickLabel of h1 (consumer subplot) to NONE (read from the
%       code)
%       EXPECTED: the producer subplot h2 is labelled NONE, as line 59 does for h1
%       LINES: 79
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMetaboliteMassBalancePlot'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
