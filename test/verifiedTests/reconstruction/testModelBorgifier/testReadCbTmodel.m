% The COBRAToolbox: testReadCbTmodel.m
%
% Purpose:
%     - readCbTmodel extracts one model from a modelBorgifier template model (Tmodel): the
%       reactions and metabolites marked in Tmodel.Models.<modelName>, their bounds and
%       objective, S, the grRules, rxnID and metID entries of that model with the
%       '<modelName>:' prefix removed, rebuilt reaction equations and the genes; empty cell
%       arrays are removed on 'y'. Quarantined: no behaviour of readCbTmodel is asserted
%       until the defect below is fixed.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/readCbTmodel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a hand-built three-reaction model passed through verifyModelBorg and
%     buildTmodel, no solver.
%
% Coverage exemptions:
%     every line - readCbTmodel is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: rxnID and metID entries are shifted when an entry has no ID of the model
%       SEVERITY: wrong-result
%       TRIGGER: m with rxns {'R1'; 'R2'; 'EX_a'}, mets {'a[c]'; 'B'; 'c[c]'}, S = sparse([-1
%         0 -1; 1 -1 0; 0 1 0]), lb = [0; -10; -10], ub = [10; 0; 10], c = [0; 1; 0],
%         rxnNames, metNames {'A'; 'B[e]'; 'C'}, grRules {'g1 or g2'; ''; 'g3'}, genes {'g1';
%         'g2'; 'g3'}, description 'modelA'; T = buildTmodel(verifyModelBorg(m, 'keepName'));
%         T.rxnID{1} = ''; R = readCbTmodel('modelA', T, 'n')
%       OBSERVED: R.rxnID = {''; ''; 'r2'}: line 161 writes IDs{iRxn} to entry IDIndexes(iRxn),
%         so the ID of the second reaction goes to the third and the second is blanked; line
%         188 does the same for metID (T.metID{1} = '' gives {''; ''; 'b[e]'} instead of {'';
%         'b[e]'; 'c[c]'}) (R2025a, 2026-11-16). buildTmodel keeps empty rxnID and metID
%         entries (its line 46), so such a Tmodel is a valid input
%       EXPECTED: R.rxnID = {''; 'r2'; 'ex_a'} (IDs{IDIndexes(iRxn)})
%       LINES: 161, 188
%     - DEFECT: rules and rxnGeneMat are never built
%       SEVERITY: limitation
%       TRIGGER: any Tmodel whose model has genes, for example T above without the change of
%         rxnID
%       OBSERVED: R has genes but neither rules nor rxnGeneMat: line 219 tests sum of the
%         all-zero matrix made at line 216, so lines 220-242 never run (R2025a, 2026-11-16)
%       EXPECTED: rules and rxnGeneMat built from grRules and genes
%       LINES: 216, 219-242
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadCbTmodel'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
