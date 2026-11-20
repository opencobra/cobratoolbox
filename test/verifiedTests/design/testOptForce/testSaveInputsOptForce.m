% The COBRAToolbox: testSaveInputsOptForce.m
%
% Purpose:
%     - saveInputsOptForce writes the inputs of an optForce run (model, target reaction, Must
%       sets, wild-type and mutant flux ranges, k, nSets, constraints and excluded reactions)
%       to inputFolder, one .mat file per input, after checking that all fifteen inputs are
%       given and the required ones are not empty. Quarantined: no behaviour of
%       saveInputsOptForce is asserted until the defect below is fixed.
%
% Function under test:
%     src/design/optForce/saveInputsOptForce.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - file writing of a small model built with createModel, no solver.
%
% Coverage exemptions:
%     every line - saveInputsOptForce is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: k.mat and nSets.mat are not written
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'R1'; 'R2'}, {'first'; 'second'}, {'a -> b'; 'b <=> '},
%         'printLevel', 0); saveInputsOptForce(model, {'R2'}, {'R1'}, {'R2'}, [0;-5], [10;0],
%         [1;-5], [10;-1], 3, 2, struct('rxnList', {{'R1'}}, 'values', 1), {}, {}, {}, folder)
%       OBSERVED: folder holds constrOpt, excludedKRxns, excludedLRxns, excludedURxns,
%         maxFluxesM, maxFluxesW, minFluxesM, minFluxesW, model, mustL, mustU and targetRxn
%         .mat; k.mat and nSets.mat do not exist (lines 136-147 never save k or nSets)
%       EXPECTED: k.mat and nSets.mat written, as the OUTPUTS section documents, so that the
%         kept inputs of an optForce run are complete
%       LINES: 136-147
%     - DEFECT: The wild-type maximum fluxes are written to maxFluxesW.mat, not maxFluxes.mat as documented
%       SEVERITY: cosmetic
%       TRIGGER: the call of the entry above
%       OBSERVED: (R2025a, 2026-11-17) the folder holds maxFluxesW.mat (line 141) and no
%         maxFluxes.mat; the call succeeds, and every other file is named after its variable,
%         so the code's name is the consistent one and the OUTPUTS line misdescribes it
%       EXPECTED: the OUTPUTS section (line 86) names the file maxFluxesW.mat
%       LINES: 86, 141
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSaveInputsOptForce'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
