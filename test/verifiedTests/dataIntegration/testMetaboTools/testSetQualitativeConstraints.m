% The COBRAToolbox: testSetQualitativeConstraints.m
%
% Purpose:
%     - setQualitativeConstraints closes every exchange reaction (identifier containing 'EX_')
%       that is not listed as uptake, secretion, basis medium or ambiguous metabolite, and
%       enforces the listed uptakes (upper bound -LOD flux) and secretions (lower bound +LOD
%       flux), the LOD fluxes being conc2Rate(LOD, cellConc, t, cellWeight) =
%       LOD / (cellConc * cellWeight * t * 1000). The test uses a model built by createModel
%       with one internal and six exchange reactions; the expected bounds are worked out by hand.
%
% Function under test:
%     src/dataIntegration/metabotools/setQualitativeConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - bound manipulation on a small createModel model; no solver.
%
% Coverage exemptions:
%     Lines 50 and 55: executed by the first section (the uptake and secretion bounds asserted
%     there are computed only by these two lines, from conc2Rate), but recorded with 0 hits by
%     MATLAB's code-coverage plugin (R2025a, 2026-11-16, two runs); a reduced copy of the loop
%     in a scratch function is recorded normally, the cause was not found.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetQualitativeConstraints'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% one internal reaction and six reversible exchanges (bounds -1000 and 1000)
rxnIds = {'R1', 'EX_a', 'EX_b', 'EX_c', 'EX_d', 'EX_e', 'EX_f'};
model = createModel(rxnIds, rxnIds, {'a + b -> c + d + e + f', 'a <=> ', 'b <=> ', 'c <=> ', 'd <=> ', 'e <=> ', 'f <=> '});
model.lb(2:end) = -1000;
idx = @(ids) findRxnIDs(model, ids);

% experiment: 1e6 cells per ml, 10 h, 1e-9 gDW per cell, so 1 mM gives
% 1 / (1e6 * 1e-9 * 10 * 1000) = 0.1 mmol/gDW/h
cellConc = 1e6;
t = 10;
cellWeight = 1e-9;
uptake = {'EX_a'; 'EX_b'};
uptakeLODs = [0.01; 0.03];
secretion = {'EX_c'};
secretionLODs = 0.02;
basisMedium = {'EX_d'};
ambiguous = {'EX_e'};

%% bounds after the qualitative constraints

modelLOD = setQualitativeConstraints(model, uptake, uptakeLODs, secretion, secretionLODs, ...
    cellConc, t, cellWeight, ambiguous, basisMedium);

% hand-derived bounds: uptake forced (ub = -0.001 and -0.003, lb kept), secretion forced
% (lb = 0.002, ub kept), basis medium and ambiguous exchanges unchanged, EX_f (not listed)
% closed, the internal reaction R1 unchanged. The LOD fluxes are one division of decimal
% numbers, so 1e-12 bounds the rounding
tol = 1e-12;
assert(all(abs(modelLOD.ub(idx(uptake)) - [-0.001; -0.003]) < tol));
assert(isequal(modelLOD.lb(idx(uptake)), [-1000; -1000]));
assert(abs(modelLOD.lb(idx('EX_c')) - 0.002) < tol && modelLOD.ub(idx('EX_c')) == 1000);
assert(isequal([modelLOD.lb(idx({'EX_d'; 'EX_e'})), modelLOD.ub(idx({'EX_d'; 'EX_e'}))], [-1000 1000; -1000 1000]));
assert(modelLOD.lb(idx('EX_f')) == 0 && modelLOD.ub(idx('EX_f')) == 0);
assert(modelLOD.lb(idx('R1')) == model.lb(idx('R1')) && modelLOD.ub(idx('R1')) == model.ub(idx('R1')));

% only bounds change: the network and the other fields are those of the input model
assert(isequal(rmfield(modelLOD, {'lb', 'ub'}), rmfield(model, {'lb', 'ub'})));

%% with every list empty, every exchange reaction is closed

modelClosed = setQualitativeConstraints(model, {}, [], {}, [], cellConc, t, cellWeight, {}, {});
exchangeIdx = idx(rxnIds(2:end));
assert(all(modelClosed.lb(exchangeIdx) == 0) && all(modelClosed.ub(exchangeIdx) == 0));
assert(modelClosed.lb(idx('R1')) == model.lb(idx('R1')) && modelClosed.ub(idx('R1')) == model.ub(idx('R1')));

% change the directory
cd(currentDir)
