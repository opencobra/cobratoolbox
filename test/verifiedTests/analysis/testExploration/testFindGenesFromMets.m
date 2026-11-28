% The COBRAToolbox: testFindGenesFromMets.m
%
% Purpose:
%     - findGenesFromMets returns the genes of the reactions in which the given metabolites
%       take part (all such reactions, or a minimal set found by cardinality optimisation
%       with param.minimal = 1), reporting metabolites that are not in the model.
%       Quarantined: no behaviour of findGenesFromMets is asserted until the defect below is
%       fixed.
%
% Function under test:
%     src/analysis/exploration/findGenesFromMets.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - cardinality optimisation (param.minimal = 1) on a toy model.
%
% Coverage exemptions:
%     every line - findGenesFromMets is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A param structure without the field minimal stops with an error
%       SEVERITY: error
%       TRIGGER: findGenesFromMets(model, {'A[c]'}, struct('printLevel', 0)) (or param =
%         struct()) with model = createModel({'R1'; 'R2'}, {'R1'; 'R2'}, {'A -> B'; 'B -> C'},
%         'grRuleList', {'g1'; 'g2 or g3'})
%       OBSERVED: (R2025a, 2026-11-25) MATLAB:nonExistentField "Unrecognized field name
%         "minimal"." at line 44: the default param.minimal = 0 is set only when param is
%         omitted (lines 28-29)
%       EXPECTED: the documented default 0 for the field minimal of a given param, as for an
%         omitted param
%       LINES: 28-29, 44
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindGenesFromMets'));
cd(fileDir);

% declare the requirements of this test; nothing that calls findGenesFromMets runs while it
% is quarantined, so no solver is required yet
prepareTest();

% change the directory
cd(currentDir)
