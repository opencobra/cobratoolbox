% The COBRAToolbox: testCleanTmodel.m
%
% Purpose:
%     - cleanTmodel reorganizes a template model (Tmodel) of modelBorgifier: it lengthens the
%       per-model bound and objective arrays and the membership arrays to the number of
%       reactions and metabolites, merges reactions with identical stoichiometry from
%       different models, replaces cryptic reaction and metabolite names by alternatives found
%       in rxnID/metID, sorts reactions and metabolites alphabetically, shares annotations
%       between the same metabolite in different compartments and removes leftover fields.
%       The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): lengthening a bound or objective array that is shorter than the reaction
%       list overwrites its last value with 0, so no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/cleanTmodel.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; a test would use a hand-built template model.
%
% Coverage exemptions:
%     every line - cleanTmodel is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Lengthening a short lb, ub or c array overwrites its last value with 0
%       SEVERITY: wrong-result
%       TRIGGER: a template model with one model m1, rxns {'R1'; 'R2'; 'R3'}, mets {'a[c]';
%         'b[c]'; 'd[c]'}, S = sparse([-1 0 -1; 1 -1 0; 0 1 1]), lb.m1 = [-10; -20] (one value
%         short, as for the "old models" the code comment names), ub.m1 = [10; 20; 30], c.m1 =
%         [0; 0; 1], Models.m1.rxns = true(3, 1), Models.m1.mets = true(3, 1), the other
%         TmodelFields fields as empty texts, rxnID = rxns, metID = mets, metNames = {'A'; 'B';
%         'D'}, metCharge = zeros(3, 1); out = cleanTmodel(T)
%       OBSERVED: out.lb.m1 = [-10; 0; 0]: the lower bound -20 of R2 is replaced by 0, because
%         line 97 assigns nowArray(end:nRxns) = 0 instead of nowArray(end + 1:nRxns) = 0 (the
%         membership arrays use end + 1, lines 108 and 115) (R2025a, 2026-11-15)
%       EXPECTED: out.lb.m1 = [-10; -20; 0]: the existing values kept and only the missing
%         reaction padded with 0
%       LINES: 97
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCleanTmodel'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
