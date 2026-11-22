% The COBRAToolbox: testChrrExpSampler.m
%
% Purpose:
%     - chrrExpSampler draws flux samples from the exponential density exp(-<lambda, v>)
%       restricted to the flux polytope with coordinate hit-and-run after rounding: it parses
%       the model (chrrParseModel), pre-processes and rounds the polytope (preprocess, which
%       runs a flux variability analysis with the objective set to zero) and samples with
%       genSamplesExp, or with genSamples (uniform) when the bias projected onto the rounded
%       polytope is below 1e-8. The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): the documented flux minima and maxima are not
%       returned when a rounded polytope is given (defect below, the same as in
%       chrrSampler), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/sampling/CHRR/chrrExpSampler.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - the pre-processing needs an LP solver (flux variability analysis, Chebyshev
%     centre and maximum volume ellipsoid in preprocess); a test would use a hand-built
%     six-reaction network. The exponential sampling (line 131) also needs exprnd of the
%     Statistics and Machine Learning Toolbox (rand_exponential_range_coord, called by
%     genSamplesExp in external/analysis/Volume-and-Sampling).
%
% Coverage exemptions:
%     every line - chrrExpSampler is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: minFlux and maxFlux cannot be requested together with a rounded polytope
%       SEVERITY: error
%       TRIGGER: model = createModel({'R_in'; 'R1'; 'R2'; 'R3'; 'R_outB'; 'R_outC'}, {'in';
%         'r1'; 'r2'; 'r3'; 'ob'; 'oc'}, {' -> A'; 'A -> B'; 'A -> C'; 'B -> C'; 'B -> '; 'C
%         -> '}, [], zeros(6, 1), 10 * ones(6, 1)); model.c = full(model.S(1, :))'; [~, P] =
%         chrrExpSampler(model, 5, 10); [s, P2, minFlux, maxFlux] = chrrExpSampler(model, [],
%         5, model.c, 1, P)
%       OBSERVED: MATLAB R2025a (gurobi): error 'Output argument "minFlux" (and
%         possibly others) not assigned a value in the execution with "chrrExpSampler"
%         function.' The two outputs are only assigned when the polytope is pre-processed in
%         the call (lines 119-120), although the rounded polytope carries them as fields
%         (.minFlux, .maxFlux). The documented USAGE requests all four outputs.
%       EXPECTED: the flux minima and maxima stored in roundedPolytope
%       LINES: 119-120
%     - DEFECT: A model without metabolites and a reaction of zero width stops in preprocess
%       SEVERITY: limitation
%       TRIGGER: the model above with S = zeros(0, 6), b = zeros(0, 1), mets = cell(0, 1),
%         csense = char(zeros(0, 1)) and lb(1) = ub(1) = 5 (gurobi): chrrExpSampler(box, 5,
%         10, [1; 0; 0; 0; 0; 0])
%       OBSERVED: MATLAB R2025a: preprocess prints 'Found 1 degenerate reactions' and stops
%         at its line 173 (P.A = P.A*N) with 'Incorrect dimensions for matrix
%         multiplication.' Line 105 replaces the empty 0 x 6 equality matrix with a 0 x 0
%         one, so preprocess builds the equality row of the fixed reaction with the wrong
%         number of columns. chrrSampler has the same lines.
%       EXPECTED: the fixed reaction is added as an equality and the remaining box sampled
%       LINES: 105-106
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testChrrExpSampler'));
cd(fileDir);

% declare the requirements of this test. The quarantined test calls nothing that needs a
% solver, so none is listed; the full test would declare prepareTest('needsLP', true)
prepareTest();

% change the directory
cd(currentDir)
