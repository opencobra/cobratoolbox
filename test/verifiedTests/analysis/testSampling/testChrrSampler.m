% The COBRAToolbox: testChrrSampler.m
%
% Purpose:
%     - chrrSampler draws uniform flux samples with coordinate hit-and-run after rounding
%       the flux polytope: it parses the model (chrrParseModel), pre-processes and rounds the
%       polytope (preprocess, which runs a flux variability analysis and the maximum volume
%       ellipsoid) and then samples (genSamples). The sampler is stochastic, so this test
%       fixes the seed and asserts invariants, not sample values: the sizes, S v = b, the
%       bounds, the flux minima and maxima (worked out by hand for a six-reaction network) and
%       the samples lying within them, the reuse of a rounded polytope with the default number
%       of steps, the default number of samples, optPercentage, a coupling constraint, and
%       the two guards on the parsed polytope (a model without reactions and bounds given as
%       rows). It runs for every available LP solver among gurobi and glpk.
%     - Quarantined: the body asserts nothing about the function (the checks above describe
%       the test written before the quarantine).
%
% Function under test:
%     src/analysis/sampling/CHRR/chrrSampler.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - the pre-processing needs an LP solver (flux variability analysis, Chebyshev
%     centre and maximum volume ellipsoid in preprocess); hand-built six-reaction network.
%
% Coverage exemptions:
%     every line - chrrSampler is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: minFlux and maxFlux cannot be requested together with a rounded polytope
%       SEVERITY: error
%       TRIGGER: [samples, P, minFlux, maxFlux] = chrrSampler(model, [], 5, [], P) with P the
%                roundedPolytope of a previous call
%       OBSERVED: MATLAB R2025a: error 'Output argument "minFlux" (and possibly others) not
%                 assigned a value in the execution with "chrrSampler" function.' The two
%                 outputs are only assigned when the polytope is pre-processed in the call
%                 (lines 154-155), although the rounded polytope carries them as fields
%                 (.minFlux, .maxFlux). The documented USAGE with a roundedPolytope requests
%                 two outputs and works.
%       EXPECTED: the flux minima and maxima stored in roundedPolytope
%       LINES: 65-69
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testChrrSampler'));
cd(fileDir);

% declare the requirements of this test; the quarantined test calls nothing that needs a
% solver, so none is listed
prepareTest();

% change the directory
cd(currentDir)
