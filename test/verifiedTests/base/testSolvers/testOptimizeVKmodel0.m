% The COBRAToolbox: testOptimizeVKmodel0.m
%
% Purpose:
%     - optimizeVKmodel0 computes a steady state of a kinetic model given by its forward and
%       reverse stoichiometric matrices F and R and the kinetic parameters parms.kin: it
%       minimises psi(x) = 1/2 ||h(x)||^2 with h(x) = [F - R, R - F] * exp(kin + [F, R]' * x),
%       or, when the model has a moiety basis L, with h(x) extended by L * exp(x) - l0 and only
%       the linearly independent rows of F - R kept. It checks its inputs, copies the given
%       parameters into an options structure, calls the chosen Levenberg-Marquardt solver (LLM_YF,
%       LLM_FY, LLM_F, LLM, GLM_YF, GLM_FY, LevMar, LMLS, LMTR; LMTR by default) or, without L,
%       a derivative-free solver (BDF, CSDF, DBDF), and returns their results. It calls no COBRA
%       solver; the iterations run in MATLAB code and are deterministic.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Inputs: the kinetic model is built from ecoli_core_model: F and R are the negative and
%       positive parts of S without the biomass reaction (its coefficients near 60 make exp
%       overflow in the derivative-free solvers), all kinetic parameters are 0 (rate constants
%       1), so x = 0 is a steady state, and the start point is 0.1 * cos(1:m). The moiety basis
%       L is an orthonormal basis of the left null space of R - F and l0 = L * exp(0).
%     - Reference values: the iteration and evaluation counts and the merit values of the
%       derivative-free solvers, which stop at the iteration limit, were recorded from the first run on 2026-11-03
%       with ecoli_core_model (no COBRA solver; MATLAB R2025a). They were not derived
%       independently, so they guard consistency, not independent correctness (Tier 5). The
%       merit value of every result is also recomputed independently from h(x_best), and every
%       converged result is checked against the stopping rule ||h|| <= epsilon.
%     - The function switches the display format to long E (defect below) and the solvers it
%       calls switch it to long G; every section restores the display format saved before the
%       first section, so that the test leaves no global state behind. The solvers print their
%       progress (and, in some solvers, the iteration count and status); this output is not
%       suppressed.
%
% Function under test:
%     src/base/solvers/varKin/optimizeVKmodel0.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - no COBRA solver (the nonlinear solvers are MATLAB code of the toolbox);
%     ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     Line 157: unreachable, MATLAB rejects a fifth input before the function body runs.
%     Line 163: unreachable, MATLAB rejects a second output before the function body runs.
%     Line 179: unreachable, the solver name would have to equal five names at the same time.
%     Lines 226-228: defective input skipped, F equal to R with L returns no output (defect below).
%     Line 589: defective input skipped, parms.flag_psi_error = 1 stops every solver (defect below).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The display format is switched to long E and never restored
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: format longE at the start, a debugging leftover, changes how every number is
%         displayed in the MATLAB session after the call
%       EXPECTED: the display format of the session left unchanged
%       LINES: 153
%     - DEFECT: F equal to R with a moiety basis returns without the output
%       SEVERITY: error
%       TRIGGER: a model with the field L whose F - R has no nonzero entry
%       OBSERVED: the function returns after setting Xsub and idx, so the call stops with
%         "Output argument "output" (and possibly others) not assigned a value"
%       EXPECTED: an output (for example x0 with its merit value) or an explicit error message
%       LINES: 225-229
%     - DEFECT: The steady state is dropped when the QR factor is a vector with a negative entry
%       SEVERITY: wrong-result
%       TRIGGER: a model with the field L whose F - R has one reaction (or one metabolite) and a
%         negative first pivot entry, for example ATPM of ecoli_core_model alone with its
%         metabolites in model order (adp[c] first)
%       OBSERVED: the rank estimate uses S(1) without abs, so -1 >= tol * -1 is false, no row of
%         F - R is kept and only the moiety conservation is solved: LMTR reports "a solution is
%         found." with psi_best 4.5e-11 while the forward and reverse rates differ by 0.16
%       EXPECTED: abs(S(1)), as for the matrix case, so that the independent row is kept
%       LINES: 234
%     - DEFECT: The option flag_psi_error cannot be used
%       SEVERITY: unusable-option
%       TRIGGER: parms.flag_psi_error = 1 (with psi_opt given) for any solver
%       OBSERVED: the option is passed on, but none of the solvers (LLM, GLM_YF, GLM_FY, LevMar,
%         LMLS, LMTR, BDF, CSDF, DBDF) reads options.psi_opt, so the first iteration stops with
%         "Unrecognized function or variable 'psi_opt'"
%       EXPECTED: output.psi_error, the relative error of the merit value in each iteration
%       LINES: 293-298, 442-447, 588-590
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptimizeVKmodel0'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% the display format of the session, restored after every call (the function changes it)
originalFormat = format;

% load the model once and build the kinetic model from S without the biomass reaction
% (72 metabolites, 94 reactions); the model itself is not needed afterwards
model = getDistributedModel('ecoli_core_model.mat');
S = full(model.S(:, ~strncmp(model.rxns, 'Biomass', 7)));
atpmColumn = full(model.S(:, strcmp(model.rxns, 'ATPM')));
clear model
[nMets, nRxns] = size(S);
kineticModel = struct('F', -min(S, 0), 'R', max(S, 0));

% the same model with a moiety basis: L spans the left null space of R - F (orthonormal rows)
% and l0 = L * exp(0), the moiety totals of the steady state x = 0
L = null((kineticModel.R - kineticModel.F)')';
moietyModel = kineticModel;
moietyModel.L = L;
moietyModel.l0 = L * ones(nMets, 1);

% parameters: all kinetic parameters 0 and at most 50 iterations; the start point
parms = struct('kin', zeros(2 * nRxns, 1), 'MaxNumIter', 50);
x0 = 0.1 * cos((1:nMets)');

% the merit function, computed independently of the solvers; h of the moiety model also
% contains the conservation residual (with all rows of F - R)
rateFunction = @(x) [kineticModel.F - kineticModel.R, kineticModel.R - kineticModel.F] * ...
    exp(parms.kin + [kineticModel.F, kineticModel.R]' * x);
meritFunction = @(x) 0.5 * norm(rateFunction(x))^2;
moietyResidual = @(x) norm([rateFunction(x); L * exp(x) - moietyModel.l0]);
psi0 = meritFunction(x0);

% the Levenberg-Marquardt and the derivative-free solvers
lmSolvers = {'LLM_YF', 'LLM_FY', 'LLM_F', 'LLM', 'GLM_YF', 'GLM_FY', 'LevMar', 'LMLS', 'LMTR'};
dfSolvers = {'BDF', 'CSDF', 'DBDF'};
lmFields = sort({'x_best'; 'psi_best'; 'T'; 'merit_func'; 'Niter'; 'Nmap'; 'Ngmap'; 'Status'});
dfFields = sort({'x_best'; 'psi_best'; 'T'; 'merit_func'; 'Niter'; 'Nmap'; 'Status'});
solvedStatus = 'a solution is found.';
maxIterStatus = 'Maximum number of iterations is reached.';

% a merit value is recomputed from x_best with a relative tolerance of 1e-9: the solvers
% compute the same expression, in another order of the floating-point operations
meritTol = 1e-9;

%% input checks

% the number of inputs and outputs (a fifth input or a second output is rejected by MATLAB)
assert(verifyCobraFunctionError('optimizeVKmodel0', 'inputs', {kineticModel, 'LMTR', x0}, ...
    'outputArgCount', 1, 'testMessage', 'The number of input arguments is not enough.'));
assert(verifyCobraFunctionError('optimizeVKmodel0', 'inputs', {kineticModel, 'LMTR', x0, parms}, ...
    'testMessage', 'The number of output arguments is not enough.'));

% the model must be given and have F and R; parms must not be empty
assert(verifyCobraFunctionError('optimizeVKmodel0', 'inputs', {struct([]), 'LMTR', x0, parms}, ...
    'outputArgCount', 1, 'testMessage', 'the structure model has to be defined.'));
assert(verifyCobraFunctionError('optimizeVKmodel0', 'inputs', {rmfield(kineticModel, 'R'), 'LMTR', x0, parms}, ...
    'outputArgCount', 1, 'testMessage', 'the fields F and R has to be filled.'));
assert(verifyCobraFunctionError('optimizeVKmodel0', 'inputs', {kineticModel, 'LMTR', x0, struct([])}, ...
    'outputArgCount', 1, 'testMessage', 'the structure parms should not be empty.'));

% with a moiety basis only the Levenberg-Marquardt solvers are accepted
assert(verifyCobraFunctionError('optimizeVKmodel0', 'inputs', {moietyModel, 'BDF', x0, parms}, ...
    'outputArgCount', 1, 'testMessage', 'Wrong solver is used.'));

% restore the display format
format(originalFormat);

%% defaults: an empty solver is LMTR and an empty start point is zero

% the default solver gives the result of LMTR (all fields but the running time)
defaultOutput = optimizeVKmodel0(kineticModel, '', x0, parms);
lmtrOutput = optimizeVKmodel0(kineticModel, 'LMTR', x0, parms);
assert(isequal(rmfield(defaultOutput, 'T'), rmfield(lmtrOutput, 'T')));

% the default start point is the zero vector, which is a steady state here (all rate
% constants 1): the solver stops with a merit value at rounding level
zeroStartOutput = optimizeVKmodel0(kineticModel, 'LMTR', [], parms);
assert(isequal(rmfield(zeroStartOutput, 'T'), rmfield(optimizeVKmodel0(kineticModel, 'LMTR', zeros(nMets, 1), parms), 'T')));
assert(strcmp(zeroStartOutput.Status, solvedStatus));
assert(zeroStartOutput.psi_best < 1e-20);

% restore the display format
format(originalFormat);

%% Levenberg-Marquardt solvers without moiety basis

% Tier-5 iteration and evaluation counts (first run 2026-11-03), in the order of lmSolvers
expectedNiter = [7, 21, 15, 13, 7, 21, 23, 13, 6];
expectedNmap = [7, 21, 15, 13, 19, 49, 45, 25, 11];

for k = 1:numel(lmSolvers)
    output = optimizeVKmodel0(kineticModel, lmSolvers{k}, x0, parms);

    % the output has the documented fields, x_best has one entry per metabolite and psi_best
    % is the merit value of x_best
    assert(isequal(sort(fieldnames(output)), lmFields), lmSolvers{k});
    assert(isequal(size(output.x_best), [nMets, 1]), lmSolvers{k});
    assert(abs(output.psi_best - meritFunction(output.x_best)) <= meritTol * output.psi_best, lmSolvers{k});

    % every solver converges (stopping rule 9: ||h|| <= 1e-5 before the iteration limit) from
    % the merit value psi0 of the start point
    assert(strcmp(output.Status, solvedStatus), lmSolvers{k});
    assert(norm(rateFunction(output.x_best)) <= 1e-5 && output.psi_best < psi0, lmSolvers{k});
    assert(output.Niter < parms.MaxNumIter && output.Nmap >= output.Niter, lmSolvers{k});
    assert(output.merit_func(end) == output.psi_best, lmSolvers{k});

    % Tier-5 counts
    assert(output.Niter == expectedNiter(k) && output.Nmap == expectedNmap(k), lmSolvers{k});
end

% restore the display format
format(originalFormat);

%% derivative-free solvers without moiety basis

% Tier-5 evaluation counts and merit values after 50 iterations (first run 2026-11-03), in the
% order of dfSolvers; the merit values are compared with a relative tolerance of 1e-6, which
% allows for a different order of floating-point operations over the 50 iterations
expectedNmap = [461, 50, 322];
expectedPsi = [0.0135510742109576, 0.0368488438298046, 0.0018636171855364];

for k = 1:numel(dfSolvers)
    output = optimizeVKmodel0(kineticModel, dfSolvers{k}, x0, parms);

    % the output has the documented fields (no gradient count) and psi_best is the merit value
    % of x_best
    assert(isequal(sort(fieldnames(output)), dfFields), dfSolvers{k});
    assert(isequal(size(output.x_best), [nMets, 1]), dfSolvers{k});
    assert(abs(output.psi_best - meritFunction(output.x_best)) <= meritTol * output.psi_best, dfSolvers{k});

    % the solvers decrease the merit value but stop at the iteration limit
    assert(strcmp(output.Status, maxIterStatus) && output.Niter == parms.MaxNumIter, dfSolvers{k});
    assert(output.psi_best < psi0, dfSolvers{k});

    % Tier-5 values
    assert(output.Nmap == expectedNmap(k), dfSolvers{k});
    assert(abs(output.psi_best - expectedPsi(k)) <= 1e-6 * expectedPsi(k), dfSolvers{k});
end

% restore the display format
format(originalFormat);

%% DC programming solvers DCA and BDCA (subproblems solved by cobraFminunc)

% The strongly convex subproblem of each DC iteration is minimized by cobraFminunc (trust-region
% Newton; feature 20261111-152503-toolbox-free-remaining). Tier-5 evaluation counts and merit
% values after 50 iterations (first run 2026-11-11, MATLAB R2025a), in the order of dcSolvers;
% the merit values are compared with a relative tolerance of 1e-6, which allows for the
% subproblem tolerance (1e-8) accumulated over the 50 iterations
dcSolvers = {'DCA', 'BDCA'};
expectedNmap = [50, 240];
expectedPsi = [0.09428740835999998, 0.01775869375191672];
for k = 1:numel(dcSolvers)
    output = optimizeVKmodel0(kineticModel, dcSolvers{k}, x0, parms);

    % the output has the documented fields (no gradient count) and psi_best is the merit value
    % of x_best
    assert(isequal(sort(fieldnames(output)), dfFields), dcSolvers{k});
    assert(isequal(size(output.x_best), [nMets, 1]), dcSolvers{k});
    assert(abs(output.psi_best - meritFunction(output.x_best)) <= meritTol * output.psi_best, dcSolvers{k});

    % the solvers decrease the merit value but stop at the iteration limit
    assert(strcmp(output.Status, maxIterStatus) && output.Niter == parms.MaxNumIter, dcSolvers{k});
    assert(output.psi_best < psi0, dcSolvers{k});

    % Tier-5 values
    assert(output.Nmap == expectedNmap(k), dcSolvers{k});
    assert(abs(output.psi_best - expectedPsi(k)) <= 1e-6 * expectedPsi(k), dcSolvers{k});
end

% restore the display format
format(originalFormat);

%% Levenberg-Marquardt solvers with moiety basis

% Tier-5 iteration and evaluation counts (first run 2026-11-03), in the order of lmSolvers
expectedNiter = [7, 22, 17, 13, 7, 22, 23, 13, 6];
expectedNmap = [7, 22, 17, 13, 19, 53, 45, 25, 11];

for k = 1:numel(lmSolvers)
    output = optimizeVKmodel0(moietyModel, lmSolvers{k}, x0, parms);
    assert(isequal(sort(fieldnames(output)), lmFields), lmSolvers{k});
    assert(isequal(size(output.x_best), [nMets, 1]), lmSolvers{k});
    assert(output.psi_best < psi0 && output.merit_func(end) == output.psi_best, lmSolvers{k});

    % every solver converges: the stopping rule holds on the reduced system (||h|| <= 1e-5,
    % psi_best <= 0.5e-10), and recomputed with all rows of F - R, the steady state and the
    % moiety conservation hold to the same order (the dropped rows are linear combinations of
    % the kept ones; 1e-4 allows for their coefficients)
    assert(strcmp(output.Status, solvedStatus) && output.Niter < parms.MaxNumIter, lmSolvers{k});
    assert(output.psi_best <= 0.5 * 1e-10, lmSolvers{k});
    assert(moietyResidual(output.x_best) <= 1e-4, lmSolvers{k});

    % Tier-5 counts
    assert(output.Niter == expectedNiter(k) && output.Nmap == expectedNmap(k), lmSolvers{k});
end

% restore the display format
format(originalFormat);

%% one reaction with moiety basis: the rank estimate of a single row

% ATPM alone (atp + h2o -> adp + h + pi): F - R has one row after transposition, whose QR
% factor is a vector. The substrates are listed first, so that the pivot entry of the QR factor
% is positive; with a product first the steady state is dropped (defect in the header)
metIdx = [find(atpmColumn < 0); find(atpmColumn > 0)];
singleModel.F = -min(atpmColumn(metIdx), 0);
singleModel.R = max(atpmColumn(metIdx), 0);
singleModel.L = null((singleModel.R - singleModel.F)')';
singleModel.l0 = singleModel.L * ones(numel(metIdx), 1);
singleX0 = 0.1 * cos((1:numel(metIdx))');
output = optimizeVKmodel0(singleModel, 'LMTR', singleX0, struct('kin', [0; 0], 'MaxNumIter', 50));

% the steady state (equal forward and reverse rate) and the four moiety totals hold to the
% stopping tolerance (Tier-5 count, first run 2026-11-03)
assert(strcmp(output.Status, solvedStatus));
rates = exp([singleModel.F, singleModel.R]' * output.x_best);
assert(abs(rates(1) - rates(2)) <= 1e-5);
assert(norm(singleModel.L * exp(output.x_best) - singleModel.l0) <= 1e-5);
assert(output.Niter == 4 && output.Nmap == 7);

% restore the display format
format(originalFormat);

%% all parameters given: they reach the solver

% the parameters of the Levenberg-Marquardt solvers, with the relative error of x and the
% time of every iteration recorded, and a smaller accuracy epsilon
lmParms = parms;
lmParms.MaxNumMapEval = 1000;
lmParms.MaxNumGmapEval = 1000;
lmParms.TimeLimit = 1000;
lmParms.epsilon = 1e-8;
lmParms.x_opt = zeros(nMets, 1) + 0.01;
lmParms.psi_opt = 0;
lmParms.eta = 1.5;
lmParms.adaptive = 0;
lmParms.flag_x_error = 1;
lmParms.flag_psi_error = 0;
lmParms.flag_time = 1;
lmParms.Stopping_Crit = 9;

for model = {kineticModel, moietyModel}
    output = optimizeVKmodel0(model{1}, 'LLM_YF', x0, lmParms);

    % the documented fields plus x_error and Time; the first relative error is that of x0
    assert(isequal(sort(fieldnames(output)), sort([lmFields; {'x_error'}; {'Time'}])));
    assert(abs(output.x_error(1) - norm(x0 - lmParms.x_opt) / norm(lmParms.x_opt)) <= 1e-12);
    assert(output.Time(1) == 0 && all(diff(output.Time) >= 0));

    % the smaller accuracy is used by the stopping rule
    assert(strcmp(output.Status, solvedStatus));
    assert(output.psi_best <= 0.5 * lmParms.epsilon^2);
end

% the parameters of the derivative-free solvers, with stopping rule 3: stop after 20 mapping
% evaluations
dfParms = lmParms;
dfParms.MaxNumMapEval = 20;
dfParms.Stopping_Crit = 3;
dfParms.alpha = 0.1;
dfParms.beta = 0.5;
dfParms.rho = 100;
dfParms.lambda_bar = 50;
dfParms.lambda_min = 1e-4;
dfParms.lambda_max = 1;
dfParms.flag_line_search = 'Armijo';
output = optimizeVKmodel0(kineticModel, 'BDF', x0, dfParms);
assert(isequal(sort(fieldnames(output)), sort([dfFields; {'x_error'}; {'Time'}])));
assert(abs(output.x_error(1) - norm(x0 - lmParms.x_opt) / norm(lmParms.x_opt)) <= 1e-12);

% the stopping rule and the evaluation limit are used: the solver stops on the evaluation
% count before the iteration limit
assert(strcmp(output.Status, 'Maximum number of mapping evaluations is reached.'));
assert(output.Nmap >= dfParms.MaxNumMapEval && output.Niter < dfParms.MaxNumIter);

% restore the display format
format(originalFormat);

% change the directory
cd(currentDir)
