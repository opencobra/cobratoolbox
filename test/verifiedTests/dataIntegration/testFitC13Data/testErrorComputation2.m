% The COBRAToolbox: testErrorComputation2.m
%
% Purpose:
%     - errorComputation2 is the objective function of the C13 fit: it returns the C13 data-fit
%       error of a flux vector (scoreC13Fit with the EMU solver), summed over the data sets
%       when Prob.user.expdata is a cell array; when Prob.user.objective is set it returns the
%       linear objective objective' * x instead, plus multiplier * (max_error - error)^2 when
%       the error exceeds max_error; when the result is NaN it saves x and Prob to errorFile.mat
%       in the current folder. The test uses the fixtures of this folder (flux vector v0 of
%       point.mat, isotopomer model.mat, expdata.mat) and derives every expected value
%       independently: the error is recomputed from the MDVs of slvrEMU_fast (tested by
%       testSlvrEMU_fast) as sum((theory - data).^2) / std2^2, as the documentation of
%       scoreC13Fit defines it, and the other branches follow by hand from that number.
%
% Function under test:
%     src/dataIntegration/fluxomics/c13solver/errorComputation2.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - the EMU solver the function calls is written in the test by
%     generateIsotopomerSolver, whose flux variability step needs an LP solver and whose scripts
%     need Perl (declared with prepareTest). The input carries a model structure (the
%     335-reaction isotopomer model of this folder, the smallest model the EMU solver is
%     generated for); the function itself uses no optimisation solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
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
fileDir = fileparts(which('testErrorComputation2'));
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

% independent value of the error at v0: concatenate the theoretical MDVs of the measured
% fragments (slvrEMU_fast) and the measured data, then sum((t - e).^2) / std2^2
mdvs = slvrEMU_fast(v0, expdata.inputfrag);
fragmentNames = fieldnames(expdata.fragments);
theory = zeros(0, 1);
measured = zeros(0, 1);
for k = 1:numel(fragmentNames)
    fragment = expdata.fragments.(fragmentNames{k});
    theory = [theory; mdvs.(fragment.metfrag)];
    measured = [measured; fragment.data];
end
expectedError = sum((theory - measured) .^ 2) / expdata.std2 ^ 2;

% the error is a sum of a few dozen squared differences of MDV entries computed by sparse linear
% solves (rounding below 1e-12 in testSlvrEMU_fast); its value is a few hundred, so a relative
% tolerance of 1e-10 separates rounding from a real change
relTol = 1e-10;

Prob = struct();
Prob.user.expdata = expdata;
Prob.user.model = model;

%% one data set: the output is the C13 data-fit error of x

out = errorComputation2(v0, Prob);
assert(isscalar(out));
assert(abs(out - expectedError) <= relTol * expectedError);
assert(expectedError > 0);

%% several data sets (cell array): the errors are summed

% three copies of the same data give three times the error
ProbCell = Prob;
ProbCell.user.expdata = {expdata, expdata, expdata};
out = errorComputation2(v0, ProbCell);
assert(abs(out - 3 * expectedError) <= relTol * 3 * expectedError);

%% null-space coordinates: x is mapped to fluxes by model.N before the error is computed

% alpha has fewer entries than model.lb, so the flux vector is model.N * alpha; the expected
% error is recomputed from the MDVs of that flux vector
alpha = model.N \ v0;
vAlpha = model.N * alpha;
mdvsAlpha = slvrEMU_fast(vAlpha, expdata.inputfrag);
theoryAlpha = zeros(0, 1);
for k = 1:numel(fragmentNames)
    theoryAlpha = [theoryAlpha; mdvsAlpha.(expdata.fragments.(fragmentNames{k}).metfrag)];
end
expectedErrorAlpha = sum((theoryAlpha - measured) .^ 2) / expdata.std2 ^ 2;
out = errorComputation2(alpha, Prob);
assert(abs(out - expectedErrorAlpha) <= relTol * expectedErrorAlpha);

%% objective set, error not above max_error: the linear objective is returned unchanged

% objective' * x of a hand-chosen objective (the first two coordinates); max_error above the
% error, so no penalty is added. Relative tolerance: the products are exact up to rounding
ProbObjective = Prob;
ProbObjective.user.objective = zeros(numel(v0), 1);
ProbObjective.user.objective(1:2) = [1; 2];
ProbObjective.user.max_error = expectedError + 1;
ProbObjective.user.multiplier = 1000;
expectedObjective = v0(1) + 2 * v0(2);
out = errorComputation2(v0, ProbObjective);
assert(abs(out - expectedObjective) <= 1e-12 * max(1, abs(expectedObjective)));

%% objective set, error above max_error: the quadratic penalty is added

% max_error is 10 below the error, so the penalty is multiplier * 10^2 = 1000 * 100; the
% absolute tolerance covers the error's rounding (relTol * error) times the derivative
% 2 * multiplier * 10 of the penalty
ProbObjective.user.max_error = expectedError - 10;
out = errorComputation2(v0, ProbObjective);
expectedPenalised = expectedObjective + 1000 * 10 ^ 2;
assert(abs(out - expectedPenalised) <= 2 * 1000 * 10 * relTol * expectedError + 1e-9);

%% NaN result: x and Prob are saved to errorFile.mat in the current folder

% std2 = NaN makes the error NaN; the function saves in the current folder, so the call is
% made from a temporary folder that is removed afterwards
ProbNaN = Prob;
ProbNaN.user.expdata.std2 = NaN;
tmpDir = tempname;
mkdir(tmpDir);
cd(tmpDir);
out = errorComputation2(v0, ProbNaN);
cd(fileDir);
assert(isnan(out));
savedFile = [tmpDir filesep 'errorFile.mat'];
assert(exist(savedFile, 'file') == 2);
saved = load(savedFile);
assert(isequal(sort(fieldnames(saved)), {'Prob'; 'x'}));
assert(isequal(saved.x, v0));
assert(isnan(saved.Prob.user.expdata.std2));
rmdir(tmpDir, 's');

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
