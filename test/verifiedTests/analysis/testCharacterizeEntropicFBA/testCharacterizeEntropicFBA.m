% The COBRAToolbox: testCharacterizeEntropicFBA.m
%
% Purpose:
%     - Characterization test that PINS the current (non-GECKO) behaviour of
%       entropicFluxBalanceAnalysis for the default 'fluxes' method on a
%       stoichiometrically consistent model, under both supported backends
%       (mosek, pdco). It is the regression baseline for feature
%       010-gecko-entropic-fba: the additive GECKO change must leave this
%       behaviour unchanged (Constitution Principle III characterization mode).
%       It must not change entropicFluxBalanceAnalysis.
%
% Authors:
%     - Generated for feature 010-gecko-entropic-fba, 2026-07-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCharacterizeEntropicFBA'));
cd(fileDir);

% consistent test model
d = load('ecoli_core_model.mat');
model = d.(char(fieldnames(d)));

% pinned references (captured from the CURRENT code, per backend): norm of the
% returned flux vector. Canonical .stat is pinned exactly; the flux magnitude
% within a modest relative tolerance (entropic solutions vary in low-order digits
% across solver builds); mass balance tightly.
refNormV = containers.Map({'mosek', 'pdco'}, {13.434743, 13.425614});
relTol = 1e-2;      % relative tolerance on ||v|| (cross-build robustness)
mbTol = 1e-4;       % mass-balance residual tolerance

backends = {'mosek', 'pdco'};

for k = 1:numel(backends)
    backend = backends{k};

    % skip cleanly if the backend is unavailable (pdco is built-in; mosek needs install)
    if strcmp(backend, 'mosek') && ~exist('mosekopt', 'file')
        fprintf('   [skip] mosek not installed\n');
        continue
    end

    fprintf('   Characterizing entropicFluxBalanceAnalysis (fluxes) with %s ... ', backend);
    param = struct('solver', backend, 'printLevel', 0);
    solution = entropicFluxBalanceAnalysis(model, param);

    % canonical optimal status (exact)
    assert(solution.stat == 1);

    % steady-state mass balance S*v = b
    assert(norm(model.S * solution.v - model.b) < mbTol);

    % flux magnitude matches the pinned reference within relative tolerance
    ref = refNormV(backend);
    assert(abs(norm(solution.v) - ref) < relTol * ref);

    % the solution still carries the expected primal/dual fields
    assert(isfield(solution, 'v') && isfield(solution, 'vf') && isfield(solution, 'vr'));
    assert(isfield(solution, 'y_N'));

    fprintf('Done.\n');
end

% change the directory back
cd(currentDir);
