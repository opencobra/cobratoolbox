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
    lastwarn('');                                                      % clear (only reads; does not suppress, VII-B)
    solution = entropicFluxBalanceAnalysis(model, param);
    assert(solution.stat == 1);                                        % feasible/optimal
    assert(isfield(solution, 'e'));                                    % enzyme variable returned
    assert(solution.e >= -tol && solution.e <= model.evarub + tol);    % within evar bounds
    assert(solution.v(2) - kcat * solution.e <= tol);                  % enzyme coupling v_R2 <= kcat*e
    assert(norm(model.S * solution.v - model.b) < 1e-4);               % steady-state mass balance
    assert(solution.v(2) >= 2 - 1e-4);                                 % forced flux present
    assertNoDualWarning(backend);                                      % FR-006: dual residual within optTol
    fprintf('Done.\n');

    % --- ENZYME-LIMITED (tight but feasible): eMax=1 => v_R2 <= kcat = 2, forced R2 >= 2 ---
    % the enzyme constraint binds exactly (v_R2 == kcat*e), proving it actively determines
    % the solution (not merely present). The strictly-infeasible enzyme case is asserted below
    % (feature 011 hardens the infeasibility-diagnostic path that feature 010 left out of scope).
    fprintf('   GECKO entropic FBA enzyme-limited (binding) case with %s ... ', backend);
    modelTight = buildEnzymeToy(1, kcat);
    lastwarn('');
    solTight = entropicFluxBalanceAnalysis(modelTight, param);
    assert(solTight.stat == 1);
    assert(abs(solTight.v(2) - kcat * solTight.e) < 1e-4);            % enzyme constraint is ACTIVE (binds)
    assert(abs(solTight.e - 1) < 1e-3 && abs(solTight.v(2) - 2) < 1e-3);   % fully-utilised enzyme at the forced flux
    assertNoDualWarning(backend);                                      % FR-006: dual residual within optTol
    fprintf('Done.\n');
end

% FR-001/002/003 (feature 011): a strictly-infeasible enzyme-constrained EP (enzyme cap below the
% forced flux) must return a clean stat=0 with a populated message, not crash on an undefined
% `message` (entropicFluxBalanceAnalysis) or a mosek err_argument_dimension in the debug
% infeasibility diagnostic. Asserted under mosek only: pdco does not detect this infeasibility
% (it returns stat=1 with a primal-residual warning), a separate pre-existing pdco limitation.
if exist('mosekopt', 'file')
    fprintf('   GECKO entropic FBA strictly-infeasible (enzyme cap) case with mosek ... ');
    modelInfeas = buildEnzymeToy(0.5, kcat);           % eMax=0.5 => v_R2 <= 1 < 2 (forced) => infeasible
    errored = false;
    try
        solInfeas = entropicFluxBalanceAnalysis(modelInfeas, struct('solver', 'mosek', 'printLevel', 0));
    catch ME
        errored = true;
        fprintf('\n   unexpected error: %s (%s line %d)\n', ME.message, ME.stack(1).name, ME.stack(1).line);
    end
    assert(~errored);                                                   % no undefined-message / err_argument_dimension crash
    assert(solInfeas.stat == 0);                                        % clean infeasible status
    assert(isfield(solInfeas, 'messages') && ~isempty(solInfeas.messages));   % informative message populated
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


function assertNoDualWarning(backend)
    % feature 011 (FR-006): after the reduced-cost sign fix in solveCobraEP, the mosek
    % dual-optimality (KKT stationarity) residual is within optTol, so no
    % "Dual optimality condition ... not satisfied" warning is emitted. Reads the last
    % warning only; it does not suppress any warning (warnings stay visible, Principle VII-B).
    if strcmp(backend, 'mosek')
        assert(isempty(regexp(lastwarn, 'Dual\s+optimality condition in solveCobraEP not satisfied', 'once')), ...
            'unexpected mosek dual-optimality warning: KKT stationarity residual exceeds optTol');
    end
end

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
    % name the coupling constraint so the mosek debug-path constraint-name array
    % (buildOptProblemFromModel names.con = [mets; ctrs]) matches the [S E; C D] row
    % count; without ctrs it is sized from mets only and mosek raises err_argument_dimension
    model.ctrs = {'enzymeCap'};
end
