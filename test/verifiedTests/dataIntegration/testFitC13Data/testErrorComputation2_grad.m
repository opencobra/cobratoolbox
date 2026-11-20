% The COBRAToolbox: testErrorComputation2_grad.m
%
% Purpose:
%     - errorComputation2_grad is the gradient function of the C13 fit (fitC13Data): it returns
%       the forward finite-difference gradient of errorComputation2. When x has fewer entries
%       than model.lb (null-space coordinates alpha, flux = model.N * alpha) entry i is
%       (f(x + t_i e_i) - f(x)) / t_i with t_i = diff_interval / norm(model.N(:, i))
%       (diff_interval = Prob.user.diff_interval, default 1e-5), computed in a for loop or, when
%       Prob.user.useparfor is true, in a parfor loop. When x is a full flux vector it returns
%       0 for the reactions without an isotopomer map (the C13 error does not depend on them)
%       and NaN for the others, the TOMLAB convention for gradient entries the solver must
%       estimate itself (Prob.CheckNaN, set by solveCobraNLP). The test uses the fixtures of
%       this folder (flux vector v0 of point.mat, isotopomer model.mat, expdata.mat), as
%       testErrorComputation2 does, and derives every expected value independently: the forward
%       differences are recomputed by hand from errorComputation2 (tested by
%       testErrorComputation2), they are compared with central differences (a mathematical
%       property of a gradient), and the zero entries of the full-flux branch are confirmed by
%       perturbing those fluxes.
%
% Function under test:
%     src/dataIntegration/fluxomics/c13solver/errorComputation2_grad.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - the EMU solver the function calls is written in the test by
%     generateIsotopomerSolver, whose flux variability step needs an LP solver and whose scripts
%     need Perl (declared with prepareTest). The input carries a model structure (the
%     335-reaction isotopomer model of this folder, the smallest model the EMU solver is
%     generated for); the function itself uses no optimisation solver.
%
% Coverage exemptions:
%     Lines 67-68: unreachable (dead code); they run when length(x) ~= length(model.lb) inside
%     the branch method == 1, which is entered only when length(x) == length(model.lb), and x is
%     not changed in between.
%     Lines 74-75: unreachable (dead code); method is set to 1 or 2 by the if/else at the top,
%     so the final else is never entered.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Generates the solver files it tests itself, as the CI run has none (T035), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testErrorComputation2_grad'));
cd(fileDir);

% declare the requirements of this test: an LP solver and Perl, both used only to generate
% the solver files below
solvers = prepareTest('needsLP', true, 'requiredSoftwares', {'perl'});

% the solver files (slvr*.m, convertCarbonInput.m) are written by generateIsotopomerSolver for
% a given model and are not kept in the repository (.gitignore); generate them here for
% model.mat of this folder, as testFitC13Data does. Solver files present now (perhaps generated
% for another model) are copied to a temporary folder and put back at the end
c13Dir = fileparts(which('generateIsotopomerSolver'));
c13Files = {'IsotopomerModel.txt'; 'convertCarbonInput.m'; 'slvrCumomer.m'; 'slvrCumomer_fast.m'; ...
    'slvrEMU.m'; 'slvrEMU_fast.m'};
c13Existed = cellfun(@(f) exist(fullfile(c13Dir, f), 'file') == 2, c13Files);
c13Backup = tempname;
mkdir(c13Backup);
for k = find(c13Existed)'
    copyfile(fullfile(c13Dir, c13Files{k}), c13Backup);
end
changeCobraSolver(solvers.LP{1}, 'LP', 0);
c13Fixtures = load('model.mat', 'model');
c13Fixtures.expdata = getfield(load('expdata.mat', 'expdata'), 'expdata');
% true: leave out the reactions that carry no flux in any steady state (flux variability), as
% testFitC13Data does
generateIsotopomerSolver(c13Fixtures.model, 'xglcDe', c13Fixtures.expdata, true);
clear c13Fixtures
% make MATLAB read the new files, not versions of them it may hold in memory
rehash;
clear convertCarbonInput slvrCumomer slvrCumomer_fast slvrEMU slvrEMU_fast

% solveLin (called through slvrEMU_fast) turns the warning MATLAB:nearlySingularMatrix off and
% does not turn it on again; save its state to restore it at the end
nearlySingularState = warning('query', 'MATLAB:nearlySingularMatrix');

% cdv2idv and idv2cdv (used by convertCarbonInput) cache matrices in global variables; note the
% globals that exist now to remove the new ones at the end
globalsBefore = who('global');

% fixtures of this folder: flux vector, isotopomer model and experimental data; the EMU solver
% reads the glucose label input as fragment MDVs (expdata.inputfrag)
load('point.mat', 'v0');
load('model.mat', 'model');
load('expdata.mat', 'expdata');
expdata.inputfrag = convertCarbonInput(expdata.input);

Prob = struct();
Prob.user.expdata = expdata;
Prob.user.model = model;

% null-space coordinates of v0 (139 entries, fewer than the 335 reactions)
alpha = model.N \ v0;
nAlpha = numel(alpha);
assert(nAlpha < numel(model.lb));

% forward differences by hand from errorComputation2, with the step of the documentation
f0 = errorComputation2(alpha, Prob);
handForward = @(step) arrayfun(@(i) (errorComputation2(alpha + ...
    (step / norm(model.N(:, i))) * ((1:nAlpha)' == i), Prob) - f0) / (step / norm(model.N(:, i))), ...
    (1:nAlpha)');
expectedDefault = handForward(1e-5);

% the hand computation repeats the same floating-point operations, so the results agree up to
% rounding of the error difference (error ~ 400, eps * 400 / step ~ 1e-8 at step 1e-5)
absTol = 1e-8;

%% null-space coordinates, defaults: forward differences with step 1e-5 / norm(N(:, i))

out = errorComputation2_grad(alpha, Prob);
assert(isequal(size(out), size(alpha)));
assert(max(abs(out - expectedDefault)) <= absTol);
assert(all(isfinite(out)));
assert(norm(out) > 1);

% the output is a gradient: central differences with a larger step agree to first order; the
% forward difference has an error of order step * second derivative (relative 2.6e-4 observed),
% so a relative tolerance of 1e-2 separates a gradient from a wrong vector
central = zeros(nAlpha, 1);
for i = 1:nAlpha
    step = 1e-4 / norm(model.N(:, i));
    e = zeros(nAlpha, 1);
    e(i) = step;
    central(i) = (errorComputation2(alpha + e, Prob) - errorComputation2(alpha - e, Prob)) / (2 * step);
end
assert(norm(out - central) <= 1e-2 * norm(central));

%% null-space coordinates, Prob.user.diff_interval sets the step

% step 1e-3: the hand forward differences with that step (rounding eps * 400 / 1e-3 is far
% below absTol); the result differs from the default step, so the field is read
ProbStep = Prob;
ProbStep.user.diff_interval = 1e-3;
outStep = errorComputation2_grad(alpha, ProbStep);
expectedStep = handForward(1e-3);
assert(max(abs(outStep - expectedStep)) <= absTol);
assert(max(abs(outStep - expectedDefault)) > 1e3 * absTol);

%% null-space coordinates, Prob.user.useparfor: the parfor loop gives the same gradient

% a pool is not started for this test (memory): automatic pool creation is switched off for this
% session only (temporary setting value), so parfor runs its iterations in this MATLAB; the
% iterations are independent, so the result equals the for loop's up to rounding. Without the
% Parallel Computing Toolbox parfor always runs here and there is no setting to change
hasAutoCreate = ~isempty(ver('parallel'));
if hasAutoCreate
    parallelSettings = settings;
    autoCreate = parallelSettings.parallel.client.pool.AutoCreate;
    hadTemporary = hasTemporaryValue(autoCreate);
    if hadTemporary
        savedTemporary = autoCreate.TemporaryValue;
    end
    autoCreate.TemporaryValue = false;
end
ProbParfor = Prob;
ProbParfor.user.useparfor = true;
outParfor = errorComputation2_grad(alpha, ProbParfor);
assert(max(abs(outParfor - expectedDefault)) <= absTol);
% useparfor = false selects the for loop explicitly
ProbParfor.user.useparfor = false;
outFor = errorComputation2_grad(alpha, ProbParfor);
assert(max(abs(outFor - expectedDefault)) <= absTol);
if hasAutoCreate
    if hadTemporary
        autoCreate.TemporaryValue = savedTemporary;
    else
        clearTemporaryValue(autoCreate);
    end
end

%% full flux vector: 0 for reactions without an isotopomer map, NaN (estimate) for the others

% x has as many entries as model.lb, so x is a flux vector; the output is a column of that
% length with exact zeros where model.isotopomer is empty and NaN elsewhere
out = errorComputation2_grad(v0, Prob);
noMap = cellfun(@isempty, model.isotopomer(:));
assert(isequal(size(out), [numel(v0), 1]));
assert(any(noMap) && any(~noMap));
assert(all(out(noMap) == 0));
assert(all(isnan(out(~noMap))));

% independent check of the zeros: the C13 error does not change when the flux of a reaction
% without an isotopomer map changes (exact: those fluxes do not enter the EMU equations)
fv0 = errorComputation2(v0, Prob);
for i = find(noMap)'
    vPerturbed = v0;
    vPerturbed(i) = vPerturbed(i) + 1;
    assert(errorComputation2(vPerturbed, Prob) == fv0);
end

% restore the warning state and remove the globals created by the callees
warning(nearlySingularState.state, 'MATLAB:nearlySingularMatrix');
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clearvars('-global', newGlobals{k});
end

% put back the solver files present before the test and remove the ones it generated
for k = 1:numel(c13Files)
    if c13Existed(k)
        copyfile(fullfile(c13Backup, c13Files{k}), c13Dir);
    elseif exist(fullfile(c13Dir, c13Files{k}), 'file') == 2
        delete(fullfile(c13Dir, c13Files{k}));
    end
end
rmdir(c13Backup, 's');
rehash;
clear convertCarbonInput slvrCumomer slvrCumomer_fast slvrEMU slvrEMU_fast

% change the directory
cd(currentDir)
