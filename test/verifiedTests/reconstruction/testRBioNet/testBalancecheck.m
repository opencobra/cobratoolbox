% The COBRAToolbox: testBalancecheck.m
%
% Purpose:
%     - balancecheck adds up, for the elements C, H, O, P, S, N, Mg, X, Fe, Zn, Co and R, the
%       atoms of the substrates and of the products of one rBioNet reaction (rows of
%       meta_meta: abbreviation, description, coefficient, compartment, side 'Substrate' or
%       anything else for a product, charged formula; atoms counted with
%       numAtomsOfElementInFormula and multiplied by the coefficient). With output 0 (the
%       default) it returns [] for a balanced reaction and the 3 x 12 cell {elements; substrate
%       atoms; product atoms} otherwise; with output 1 it always returns that cell; any other
%       output value raises 'wrong input'. Expected atom counts are added up by hand from the
%       formulae in the comments.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns; severity audit T009a): a reaction unbalanced in an element outside its
%       fixed list is reported balanced (defect below), so no assertion about the function is
%       made; the checks described above are the plan for the test once the defect is
%       resolved.
%
% Function under test:
%     src/reconstruction/rBioNet/balancecheck.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built rBioNet reaction rows.
%
% Coverage exemptions:
%     every line - balancecheck is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Elements outside the fixed list of twelve are not checked
%       SEVERITY: wrong-result
%       TRIGGER: a reaction unbalanced only in an element that is not in the list C, H, O, P,
%         S, N, Mg, X, Fe, Zn, Co, R, for example balancecheck({'na1', 'Sodium', 1, 'c',
%         'Substrate', 'Na'; 'h2o', 'Water', 1, 'c', 'Substrate', 'H2O'; 'h2o', 'Water', 1,
%         'c', 'Product', 'H2O'}) (sodium consumed, nothing produced from it)
%       OBSERVED: [] (balanced), since Na, K, Cl, Ca, Cu, Mn, Se, I and every other element
%         is never counted (R2025a, 2026-11-15)
%       EXPECTED: the reaction reported as unbalanced, or the documentation naming the
%         elements that are checked. Severity audit 2026-11-15: OUTPUT documents "balance: is
%         empty if balance checks out, if unbalanced it returns cell matrix"; a reaction
%         unbalanced in Na, K, Cl or Ca (outside the hard-coded list at line 26, which the
%         header does not mention) returns [] - reported balanced although unbalanced
%       LINES: 26
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15; severity audit
%       2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBalancecheck'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
