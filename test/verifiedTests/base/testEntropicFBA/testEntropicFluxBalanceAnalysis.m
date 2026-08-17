% The COBRAToolbox: testEntropicFluxBalanceAnalysis.m
%
% Purpose:
%     - %testEntropicFluxBalanceAnalysis.m tests the basic functionality of
%     entropicFluxBalanceAnalysis.m
%
%       entropicFluxBalanceAnalysis.m incorporates entropy maximization
%       principles into the framework of tranditional flux balance analysis
%       to  to predict more realistic and biologically plausible intracellular 
%       flux distributions by assuming that, among all feasible flux states, 
%       cells prefer those that are thermodynamically favourable and least ordered.
%       Also characterizes the current (non-GECKO) behaviour for the default
%       'fluxes' method on a stoichiometrically consistent model under both
%       supported backends (mosek, pdco) as the regression baseline for feature
%       010-gecko-entropic-fba; merged in from testCharacterizeEntropicFBA.m per
%       Constitution Principle III-Naming (feature 018-test-naming-convention):
%       one test file per source function.
%
% Usage:
%       [solution, modelOut] = entropicFluxBalanceAnalysis(model,param)
%
% Creator: Yanjun Liu May, 2025
% Characterization: generated for feature 010-gecko-entropic-fba, 2026-07-15;
% merged into this file by feature 018-test-naming-convention, 2026-08-17.

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testEntropicFluxBalanceAnalysis'));
cd(fileDir);

% Testing entropicFluxBalanceAnalysis
solverPkgs = prepareTest('requiredSolvers',{'mosek'}, 'needsEP', true);
fprintf('   Testing entropicFluxBalanceAnalysis using solver %s ... ', solverPkgs.EP{1})

% 1. load model
model = getDistributedModel('Recon3DModel_301.mat');

% Recon3D as distributed carries a few stoichiometrically inconsistent metabolites, which
% entropicFluxBalanceAnalysis rejects (it requires a stoichiometrically consistent model). Restrict
% Recon3D to its stoichiometrically consistent subset before solving.
massBalanceCheck = 0;
[~, ~, ~, ~, ~, ~, model, ~] = findStoichConsistentSubset(model, massBalanceCheck, 0);
model = removeRxns(model, model.rxns(~model.SConsistentRxnBool), 'metRemoveMethod', 'exclusive');
model = rmfield(model, intersect(fieldnames(model), {'SConsistentMetBool', 'SConsistentRxnBool'}));

% 2. set param for entropicFBA
param.solver ='mosek'; % {('pdco'),'mosek'}
param.entropicFBAMethod ='fluxes'; % {('fluxes'),'fluxesConcentrations','fluxTracer')}
param.printLevel = 0;  % {(0),1}
param.debug = 1;
param.feasTol = 1e-8; %[1e-11,1e-6], 1e-11 might be too strict in some cases
param.optTol = param.feasTol*10;
param.problemType = 'EP';

% 3. Run entropicFluxBalanceAnalysis.
solution = entropicFluxBalanceAnalysis(model,param);

% 4. Expected result

if solution.stat ==1
    % output a success message
    fprintf('Done.\n');
else
    assert(solution.stat ~=1)
end

%% Characterization: entropicFluxBalanceAnalysis regression baseline (merged from testCharacterizeEntropicFBA.m)
% PINS the current (non-GECKO) behaviour of entropicFluxBalanceAnalysis for the
% default 'fluxes' method on a stoichiometrically consistent model, under both
% supported backends (mosek, pdco). It is the regression baseline for feature
% 010-gecko-entropic-fba: the additive GECKO change must leave this behaviour
% unchanged (Constitution Principle III characterization mode).

% consistent test model
charD = load('ecoli_core_model.mat');
charModel = charD.(char(fieldnames(charD)));

% pinned references (captured from the CURRENT code, per backend): norm of the
% returned flux vector. Canonical .stat is pinned exactly; the flux magnitude
% within a modest relative tolerance (entropic solutions vary in low-order digits
% across solver builds); mass balance tightly.
charRefNormV = containers.Map({'mosek', 'pdco'}, {13.434743, 13.425614});
charRelTol = 1e-2;      % relative tolerance on ||v|| (cross-build robustness)
charMbTol = 1e-4;       % mass-balance residual tolerance

charBackends = {'mosek', 'pdco'};

for charK = 1:numel(charBackends)
    charBackend = charBackends{charK};

    % skip cleanly if the backend is unavailable (pdco is built-in; mosek needs install)
    if strcmp(charBackend, 'mosek') && ~exist('mosekopt', 'file')
        fprintf('   [skip] mosek not installed\n');
        continue
    end

    fprintf('   Characterizing entropicFluxBalanceAnalysis (fluxes) with %s ... ', charBackend);
    charParam = struct('solver', charBackend, 'printLevel', 0);
    charSolution = entropicFluxBalanceAnalysis(charModel, charParam);

    % canonical optimal status (exact)
    assert(charSolution.stat == 1);

    % steady-state mass balance S*v = b
    assert(norm(charModel.S * charSolution.v - charModel.b) < charMbTol);

    % flux magnitude matches the pinned reference within relative tolerance
    charRef = charRefNormV(charBackend);
    assert(abs(norm(charSolution.v) - charRef) < charRelTol * charRef);

    % the solution still carries the expected primal/dual fields
    assert(isfield(charSolution, 'v') && isfield(charSolution, 'vf') && isfield(charSolution, 'vr'));
    assert(isfield(charSolution, 'y_N'));

    fprintf('Done.\n');
end

% change the directory
cd(currentDir)
