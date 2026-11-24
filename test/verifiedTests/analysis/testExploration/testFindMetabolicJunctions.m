% The COBRAToolbox: testFindMetabolicJunctions.m
%
% Purpose:
%     - findMetabolicJunctions lists the metabolites (one compartment only) that take part in
%       at least nRxnsJnc reactions outside the objective, keeping those whose reactions,
%       exactly nRxnsJnc of them, all have genes and pairwise different gene sets.
%       Quarantined: no behaviour of findMetabolicJunctions is asserted until the defect below
%       is fixed.
%
% Function under test:
%     src/analysis/exploration/findMetabolicJunctions.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation on a hand-built model, no solver.
%
% Coverage exemptions:
%     every line - findMetabolicJunctions is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call that finds a junction stops on an undefined variable
%       SEVERITY: error
%       TRIGGER: model = struct('rxns', {{'A'; 'B'; 'C'}}, 'mets', {{'x[c]'}}, 'S',
%         sparse([1 -1 -1]), 'c', [0; 0; 0], 'genes', {{'g1'; 'g2'; 'g3'}}, 'rules',
%         {{'x(1)'; 'x(2)'; 'x(3)'}}); findMetabolicJunctions(model, 3)
%       OBSERVED: (R2025a, 2026-11-23) error "Unrecognized function or variable 'verbFlag'."
%         (line 56): verbFlag is neither an input nor defined in the function, so the first
%         valid junction found always ends the call; only calls that find no junction (for
%         example the same model with nRxnsJnc = 4) return, with an empty list
%       EXPECTED: the list of junction metabolites ({'x(c)'} here, as lines 55 and 75-77
%         build it), with the verbose listing of lines 56-69 behind an optional flag
%       LINES: 56-69
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindMetabolicJunctions'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
