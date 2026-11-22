% The COBRAToolbox: testExportInputsOptForceToGAMS.m
%
% Purpose:
%     - exportInputsOptForceToGAMS writes the inputs that the GAMS program of optForce reads
%       into inputFolder: nine text files of sets (through exportSetToGAMS) and MtoGOF.gdx
%       (through wgdx of GDXMRW, part of GAMS) with S, the flux ranges, the bounds, the fixed
%       constraints, k and nSets. Quarantined: no behaviour of exportInputsOptForceToGAMS
%       is asserted until the defect below is fixed.
%
% Function under test:
%     src/design/optForceGAMS/exportInputsOptForceToGAMS.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a two-reaction model and files in a temporary folder, no solver (line 182
%     would also need wgdx of GAMS, which is not installed).
%
% Coverage exemptions:
%     every line - exportInputsOptForceToGAMS is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call stops on the undefined variable nSets and leaves the current folder
%       changed
%       SEVERITY: error
%       TRIGGER: model with rxns {'R1'; 'R2'}, mets {'a'; 'b'}, S = sparse([-1 0; 1 -1]), lb =
%         [0; -5], ub = [10; 0]; exportInputsOptForceToGAMS(model, {'R2'}, {'R1'}, {'R2'}, [0;
%         -5], [10; 0], [1; -5], [10; -1], 3, 2, struct('rxnList', {{'R1'}}, 'values', 1), {},
%         {}, {}, fullfile(tempname, 'f3'))
%       OBSERVED: error MATLAB:UndefinedFunction 'Unrecognized function or variable 'nSets'.'
%         at line 179 (the input is named n_sets); the nine text files are written but
%         MtoGOF.gdx is not, and the current folder stays inputFolder because line 183 is
%         never reached (R2025a, 2026-11-16)
%       EXPECTED: nMax.val = n_sets, MtoGOF.gdx written and the current folder restored
%       LINES: 179, 183
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testExportInputsOptForceToGAMS'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
