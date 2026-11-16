% The COBRAToolbox: testNormaliseGPRs.m
%
% Purpose:
%     NormaliseGPRs parses every model.rules entry (FormulaParser), converts it to disjunctive
%     normal form, removes repeated clauses and rewrites rules and grRules. The function is
%     QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): the result is not
%     the minimal DNF the documentation promises (defect below), so no assertion about the function
%     is made. It does not call the quarantined Node forms (removeDuplicateLiterals, isequal,
%     deleteLiteral): only parseFormula, reduce, convertToDNF, removeDNFduplicates and toString.
%
% Function under test:
%     src/reconstruction/refinement/GPRLogic/NormaliseGPRs.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation without a solver; a test would use a createModel model with
%     hand-written rules.
%
% Coverage exemptions:
%     every line - NormaliseGPRs is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The rules are not reduced to the minimal DNF form: absorbed clauses are kept
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'R1','R2','EX_A','EX_C'}, {'R1','R2','EX_A','EX_C'}, {'A -> B','B <=> C','A <=> ','C -> '}); model.genes = {'g1';'g2'}; model.rules = {'x(1) | (x(1) & x(2))'; ''; ''; ''}; out = NormaliseGPRs(model)
%       OBSERVED: out.rules{1} = '(x(1) | x(1) & x(2))' and out.grRules{1} = '(g1 or g1 and g2)' (only identical clauses are removed by removeDNFduplicates)
%       EXPECTED: x(1) (g1): x1 or (x1 and x2) = x1 by absorption (header: "reduce them to the minimal DNF Form"; OUTPUTS: "all GPRS in minimal DNF form")
%       LINES: 31-38
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testNormaliseGPRs'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
