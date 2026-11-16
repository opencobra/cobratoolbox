% The COBRAToolbox: testSetSemiQuantConstraints.m
%
% Purpose:
%     - setSemiQuantConstraints rescales the lower bounds of exchange reactions of two models
%       (condition 1: modelA, condition 2: modelB) by the relative differences of signal
%       intensities, in the formats produced by calculateQuantitativeDiffs:
%         * cond2_upt_higher {rxn, d} (d a fraction): modelB.lb = lbB * (1 - d), or lbB / d
%           when d > 1;
%         * cond1_upt_higher {rxn, p} (p in percent): modelA.lb = (1 - p/100) * lbB;
%         * cond2_secr_higher {rxn, p}: modelA.lb = (1 + p/100) * lbB;
%         * cond1_secr_higher {rxn, p}: modelB.lb = (1 + p/100) * lbB, or lbB * p/100 when
%           p/100 > 1;
%       where lbB is the lower bound in the input modelB. The test builds two models with
%       createModel and different bounds; the expected bounds are worked out by hand from these
%       formulas. It pins the existing behaviour (III-Characterization), including that
%       condition 1 bounds are computed from the bounds of modelB.
%
% Function under test:
%     src/dataIntegration/metabotools/setSemiQuantConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - bound manipulation on small createModel models; no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An empty cond1_upt_higher list stops with an error
%       SEVERITY: limitation
%       TRIGGER: setSemiQuantConstraints(m, m, cell(0, 2), {'EX_a', 0.5}, {'EX_b', 10},
%         {'EX_b', 10}) with m = createModel({'EX_a', 'EX_b'}, {'EX_a', 'EX_b'}, {'a <=> ',
%         'b <=> '})
%       OBSERVED: (R2025a, 2026-11-16) "Unrecognized function or variable 'c'." at line 76: the
%         row counter c is first set inside the loop over cond1_upt_higher; calculateQuantitativeDiffs
%         never returns an empty list (it leaves the output undefined instead)
%       EXPECTED: no bound changed for an empty list, the other lists applied
%       LINES: 76
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetSemiQuantConstraints'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% two models with the same exchanges and different lower bounds (uptake < 0, secretion > 0)
rxnIds = {'EX_a', 'EX_b', 'EX_c', 'EX_d', 'EX_e', 'EX_f', 'EX_g'};
modelA = createModel(rxnIds, rxnIds, {'a <=> ', 'b <=> ', 'c <=> ', 'd <=> ', 'e <=> ', 'f <=> ', 'g <=> '});
modelB = modelA;
modelA.lb = [-20; -16; -8; 4; 2; 4; -7];
modelB.lb = [-10; -8; -4; 2; 1; 2; -5];

% relative differences; the first entry of a list may be a 1-by-1 cell, as written by
% calculateQuantitativeDiffs
cond2UptHigher = {{'EX_a'}, 0.5; 'EX_b', 2};
cond1UptHigher = {{'EX_c'}, 25};
cond2SecrHigher = {'EX_d', 50};
cond1SecrHigher = {'EX_e', 50; 'EX_f', 250};

%% lower bounds after the semi-quantitative constraints

[modelAQuant, modelBQuant] = setSemiQuantConstraints(modelA, modelB, cond1UptHigher, cond2UptHigher, cond2SecrHigher, cond1SecrHigher);

% hand-derived lower bounds (lbB = lower bound of the input modelB):
%   EX_a in B: -10 * (1 - 0.5) = -5;   EX_b in B: d = 2 > 1, -8 / 2 = -4
%   EX_c in A: (1 - 25/100) * -4 = -3; EX_d in A: (1 + 50/100) * 2 = 3
%   EX_e in B: (1 + 50/100) * 1 = 1.5; EX_f in B: 250/100 > 1, 2 * 2.5 = 5
%   EX_g is in no list and keeps its bounds in both models
% products of short decimal numbers: 1e-12 bounds the rounding
tol = 1e-12;
assert(all(abs(modelAQuant.lb - [-20; -16; -3; 3; 2; 4; -7]) < tol));
assert(all(abs(modelBQuant.lb - [-5; -4; -4; 2; 1.5; 5; -5]) < tol));

% only lower bounds change
assert(isequal(rmfield(modelAQuant, 'lb'), rmfield(modelA, 'lb')));
assert(isequal(rmfield(modelBQuant, 'lb'), rmfield(modelB, 'lb')));

%% an empty cond2_upt_higher list leaves modelB unchanged for uptakes

[modelAQuant, modelBQuant] = setSemiQuantConstraints(modelA, modelB, cond1UptHigher, cell(0, 2), cond2SecrHigher, {'EX_e', 50});
assert(all(abs(modelAQuant.lb - [-20; -16; -3; 3; 2; 4; -7]) < tol));
assert(all(abs(modelBQuant.lb - [-10; -8; -4; 2; 1.5; 2; -5]) < tol));

% change the directory
cd(currentDir)
