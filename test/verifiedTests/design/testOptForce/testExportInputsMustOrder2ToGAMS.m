% The COBRAToolbox: testExportInputsMustOrder2ToGAMS.m
%
% Purpose:
%     - exportInputsMustOrder2ToGAMS writes the inputs that the GAMS programs for second order
%       Must sets read into inputFolder: Reactions.txt, Metabolites.txt, Constraints.txt,
%       Excluded.txt and MustSetFirstOrder.txt (through exportSetToGAMS) and MtoG.gdx
%       (through wgdx of GDXMRW, part of GAMS). Quarantined: no behaviour of
%       exportInputsMustOrder2ToGAMS is asserted until the defect below is fixed.
%
% Function under test:
%     src/design/optForceGAMS/exportInputsMustOrder2ToGAMS.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a two-reaction model and files in a temporary folder, no solver (line 133
%     would also need wgdx of GAMS, which is not installed).
%
% Coverage exemptions:
%     every line - exportInputsMustOrder2ToGAMS is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call stops with the error that not all inputs are given
%       SEVERITY: error
%       TRIGGER: model with rxns {'R1'; 'R2'}, mets {'a'; 'b'}, S = sparse([-1 0; 1 -1]), lb =
%         [0; -5], ub = [10; 0]; exportInputsMustOrder2ToGAMS(model, [0; -5], [10; 0],
%         struct('rxnList', {{'R1'}}, 'values', 1), {}, {'R1'}, fullfile(tempname, 'f2')),
%         all seven documented inputs given
%       OBSERVED: error 'Optforce: All inputs must be specified when using
%         exportInputsMustOrder2ToGAMS' and no folder created; the function has seven inputs
%         but line 76 tests nargin < 8, so no call can pass (R2025a, 2026-11-16). Lines 129
%         and 132 would fail next: the constraint names are fixed to {'EX_gluc', 'R75',
%         'EX_suc'} instead of constrOpt.rxnList, and setType is not defined
%       EXPECTED: the five text files and MtoG.gdx written to inputFolder when all seven
%         inputs are given
%       LINES: 76-77, 129, 132
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testExportInputsMustOrder2ToGAMS'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
