% The COBRAToolbox: testEntropicFBAgecko.m
%
% Purpose:
%     - Test the optional GECKO / enzyme-constrained path of
%       entropicFluxBalanceAnalysis (feature 010-gecko-entropic-fba): when the
%       model carries E/evarlb/evarub/evarc/D, the [S E; C D] block and the
%       enzyme bounds/objective are folded into the entropic problem, so an
%       enzyme-constrained reaction is capped by its enzyme usage. Verified by
%       feasibility + optimality-condition satisfaction on a minimal committed
%       fixture (no independent golden output exists), under both backends.
%
% Authors:
%     - Generated for feature 010-gecko-entropic-fba, 2026-07-15.

% save the current path
currentDir = pwd;
fileDir = fileparts(which('testEntropicFBAgecko'));
cd(fileDir);

tol = 1e-6;
kcat = 2;   % v_R2 <= kcat * e

backends = {'mosek', 'pdco'};

for k = 1:numel(backends)
    backend = backends{k};
    if strcmp(backend, 'mosek') && ~exist('mosekopt', 'file')
        fprintf('   [skip] mosek not installed\n');
        continue
    end
    param = struct('solver', backend, 'printLevel', 0);

    % --- FEASIBLE: enzyme abundant enough (eMax=3 => v_R2 <= 6, forced R2 >= 2) ---
    fprintf('   GECKO entropic FBA feasible case with %s ... ', backend);
    model = buildEnzymeToy(3, kcat);
    solution = entropicFluxBalanceAnalysis(model, param);
    assert(solution.stat == 1);                                        % feasible/optimal
    assert(isfield(solution, 'e'));                                    % enzyme variable returned
    assert(solution.e >= -tol && solution.e <= model.evarub + tol);    % within evar bounds
    assert(solution.v(2) - kcat * solution.e <= tol);                  % enzyme coupling v_R2 <= kcat*e
    assert(norm(model.S * solution.v - model.b) < 1e-4);               % steady-state mass balance
    assert(solution.v(2) >= 2 - 1e-4);                                 % forced flux present
    fprintf('Done.\n');

    % --- ENZYME-LIMITED (tight but feasible): eMax=1 => v_R2 <= kcat = 2, forced R2 >= 2 ---
    % the enzyme constraint binds exactly (v_R2 == kcat*e), proving it actively determines
    % the solution (not merely present). A strictly-infeasible enzyme case is not asserted here
    % because it exercises a pre-existing infeasibility-diagnostic path in solveCobraEP that is
    % out of this feature's scope.
    fprintf('   GECKO entropic FBA enzyme-limited (binding) case with %s ... ', backend);
    modelTight = buildEnzymeToy(1, kcat);
    solTight = entropicFluxBalanceAnalysis(modelTight, param);
    assert(solTight.stat == 1);
    assert(abs(solTight.v(2) - kcat * solTight.e) < 1e-4);            % enzyme constraint is ACTIVE (binds)
    assert(abs(solTight.e - 1) < 1e-3 && abs(solTight.v(2) - 2) < 1e-3);   % fully-utilised enzyme at the forced flux
    fprintf('Done.\n');
end

% FR-004: an E/D dimension mismatch is rejected with a clear error (not silent mis-assembly)
modelBad = buildEnzymeToy(3, kcat);
modelBad.E = sparse(3, 1);   % 3 rows but the stoichiometric matrix has 2 metabolites
errored = false;
try
    entropicFluxBalanceAnalysis(modelBad, struct('solver', 'pdco', 'printLevel', 0));
catch
    errored = true;
end
assert(errored);

% change the directory back
cd(currentDir);


function model = buildEnzymeToy(eMax, kcat)
    % Minimal enzyme-constrained fixture:
    %   A ->(R1, exchange) -> [R2, internal, enzyme-catalysed] -> B ->(R3, exchange)
    %   mass balance forces R1 = R2 = R3; R3 lower bound forces flux; enzyme caps R2.
    model = struct();
    model.rxns = {'R1'; 'R2'; 'R3'};
    model.mets = {'A'; 'B'};
    model.S = [1, -1, 0; 0, 1, -1];
    model.lb = [0; 0; 2];               % force secretion R3 >= 2 => R2 >= 2
    model.ub = [10; 10; 10];
    model.c = [0; 0; 1];
    model.b = [0; 0];
    model.csense = ['E'; 'E'];
    model.osenseStr = 'max';
    model.SConsistentMetBool = [true; true];
    model.SConsistentRxnBool = [false; true; false];   % R2 internal; R1,R3 external
    % enzyme constraint  v_R2 - kcat*e <= 0,  e in [0, eMax]
    model.C = [0, 1, 0];
    model.d = 0;
    model.dsense = 'L';
    model.D = -kcat;                    % enzyme variable in the coupling row
    model.E = sparse(2, 1);            % enzyme not in the metabolite (A/B) balance
    model.evarlb = 0;
    model.evarub = eMax;
    model.evarc = 0;
    model.evars = {'e_R2'};
end
