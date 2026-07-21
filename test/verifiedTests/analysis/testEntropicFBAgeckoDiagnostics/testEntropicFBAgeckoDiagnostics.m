% The COBRAToolbox: testEntropicFBAgeckoDiagnostics.m
%
% Purpose:
%     - Feature 012-gecko-diagnostics-docs. Two things are verified:
%       (1) CHARACTERIZATION (Principle III): for a NON-enzyme model the
%           printLevel>1 KKT/thermodynamic diagnostic blocks of
%           entropicFluxBalanceAnalysis are unaffected by the enzyme-aware
%           additions - no enzyme line leaks into the output and the returned
%           solution is unchanged (FR-004/SC-004/SC-006).
%       (2) GECKO enzyme-aware diagnostics: for an enzyme-constrained model the
%           enzyme-column KKT stationarity  evarc + E'*y_N + D'*y_C + z_e  is
%           printed and its residual is small on a well-conditioned backend
%           (FR-003/FR-008/SC-003). The change is print-only (FR-005/SC-006).
%       Verified under both supported backends (mosek, pdco).
%
% Authors:
%     - Generated for feature 012-gecko-diagnostics-docs, 2026-07-17.

% save the current path
currentDir = pwd;
fileDir = fileparts(which('testEntropicFBAgeckoDiagnostics'));
cd(fileDir);

kcat = 2;
tol = 1e-4;           % pdco enzyme-KKT residual tolerance
solTol = 1e-6;        % print-only: solution unchanged across printLevel

% non-enzyme reference model (stoichiometrically consistent)
dd = load('ecoli_core_model.mat');
neModel = dd.(char(fieldnames(dd)));

backends = {'mosek', 'pdco'};

for k = 1:numel(backends)
    backend = backends{k};
    if strcmp(backend, 'mosek') && ~exist('mosekopt', 'file')
        fprintf('   [skip] mosek not installed\n');
        continue
    end
    paramDiag = struct('solver', backend, 'printLevel', 2, 'entropicFBAMethod', 'fluxes');
    paramQuiet = struct('solver', backend, 'printLevel', 0, 'entropicFBAMethod', 'fluxes');

    % --- (1) CHARACTERIZATION: non-enzyme diagnostics carry no enzyme terms (FR-004) ---
    fprintf('   [%s] non-enzyme diagnostics carry no enzyme line ... ', backend);
    outNE = evalc('solNE = entropicFluxBalanceAnalysis(neModel, paramDiag);');
    assert(solNE.stat == 1);                                   % feasible/optimal
    assert(contains(outNE, 'Optimality conditions'));          % the diagnostic blocks actually ran
    assert(~contains(outNE, 'evarc'));                         % NO enzyme stationarity line for a non-enzyme model
    assert(~isfield(solNE, 'e'));                              % no enzyme-usage field for a non-enzyme model
    % print-only: the diagnostic printLevel must not change the returned solution
    solNEq = entropicFluxBalanceAnalysis(neModel, paramQuiet);
    assert(norm(solNE.v - solNEq.v, inf) < solTol);
    fprintf('Done.\n');

    % --- (2) GECKO: enzyme-column KKT stationarity is printed and small (FR-003/SC-003) ---
    fprintf('   [%s] GECKO enzyme KKT stationarity printed + residual ... ', backend);
    gm = buildEnzymeToy(1, kcat);                                  % binding case (e=1, v_R2 = kcat*e = 2)
    outG = evalc('solG = entropicFluxBalanceAnalysis(gm, paramDiag);');
    assert(solG.stat == 1);
    assert(isfield(solG, 'e') && isfield(solG, 'z_e'));
    assert(contains(outG, 'evarc + E'));                          % enzyme stationarity line now printed
    % recompute the enzyme-column stationarity: evarc + E'*y_N + D'*y_C + z_e (same +z_e both backends)
    enzStat = gm.evarc(:) + gm.E' * solG.y_N(:) + gm.D' * solG.y_C(:) + solG.z_e(:);
    assert(all(isfinite(enzStat)));
    if strcmp(backend, 'pdco')
        assert(norm(enzStat, inf) < tol);                        % well-conditioned backend: KKT holds tightly
    end
    % print-only: the diagnostic printLevel must not change the returned solution
    solGq = entropicFluxBalanceAnalysis(gm, paramQuiet);
    assert(norm(solG.v - solGq.v, inf) < solTol);
    assert(abs(solG.e - solGq.e) < solTol);
    fprintf('Done.\n');
end

% change the directory back
cd(currentDir);


function model = buildEnzymeToy(eMax, kcat)
    % Minimal enzyme-constrained fixture (shared with testEntropicFBAgecko):
    %   A ->(R1) -> [R2, enzyme-catalysed] -> B ->(R3); enzyme caps R2 <= kcat*e.
    model = struct();
    model.rxns = {'R1'; 'R2'; 'R3'};
    model.mets = {'A'; 'B'};
    model.S = [1, -1, 0; 0, 1, -1];
    model.lb = [0; 0; 2];
    model.ub = [10; 10; 10];
    model.c = [0; 0; 1];
    model.b = [0; 0];
    model.csense = ['E'; 'E'];
    model.osenseStr = 'max';
    model.SConsistentMetBool = [true; true];
    model.SConsistentRxnBool = [false; true; false];
    model.C = [0, 1, 0];
    model.d = 0;
    model.dsense = 'L';
    model.D = -kcat;
    model.E = sparse(2, 1);
    model.evarlb = 0;
    model.evarub = eMax;
    model.evarc = 0;
    model.evars = {'e_R2'};
end
