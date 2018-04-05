% The COBRAToolbox: testMinSpan.m
%
% Purpose:
%     - test the uFBA algorithm for integrating exo- and endo-
%       metabolomics data into a constraint-based metabolic model
%
% Authors:
%     - Original test file: James Yurkovich, 5/12/2017
%     - CI integration: Sylvain Arreckx, June 2017

global CBTDIR

%Test presence of required Toolboxes
requiredToolboxes = {'statistics_toolbox'};
requiredSolvers = {'gurobi'}; %This probably should work with any MILP and any LP solver...
prepareTest('requiredSolvers',requiredSolvers,'toolboxes',requiredToolboxes);

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testuFBA'));
cd(fileDir);

% Load in data and model
% This data is quantified and volume adjusted. The following
% variables will be loaded into your workspace:
%   met_data        exo- and endo-metabolomics data
%   met_IDs         BiGG IDs for the measured metabolites
%   model           modified iAB-RBC-283 COBRA model structure
%   time            time points (in days)
%   uFBAvariables   input for uFBA algorithm
load([CBTDIR filesep 'tutorials' filesep 'dataIntegration' filesep 'uFBA' filesep 'sample_data.mat']);
%Explicitly load the model to ensure it is compatible.
model = readCbModel([CBTDIR filesep 'tutorials' filesep 'dataIntegration' filesep 'uFBA' filesep 'sample_data.mat'], 'modelName','model');

% test that data is loaded correctly
assert(size(met_data, 1) == 80 & size(met_data, 2) == 102, ...
       'Data loaded incorrectly.')
assert(size(met_IDs, 1) == 102 & size(met_IDs, 2) == 1, ...
       'Data loaded incorrectly.')

assert(size(model.S, 1) == 216 & size(model.S, 2) == 271, ...
       'Data loaded incorrectly.')

assert(size(time, 1) == 80 & size(time, 2) == 1, ...
       'Data loaded incorrectly.')

assert(length(fieldnames(uFBAvariables)) == 15, ...
       'Data loaded incorrectly.')

solverLPOk = changeCobraSolver('gurobi', 'LP', 0);
solverMILPOk = changeCobraSolver('gurobi', 'MILP', 0);

if solverMILPOk & solverLPOk
    % Linear regression
    % Find the rate of change of each metabolite concentration
    changeSlopes = zeros(length(met_IDs), 1);
    changeIntervals = zeros(length(met_IDs), 1);
    for i = 1:length(met_IDs)
        % IF STATISTICS TOOLBOX IS NOT INSTALLED,
        % PERFORM LINEAR REGRESSION MANUALLY:
        tmp1 = [time ones(length(time), 1)] \ met_data(:, i);

        % compute 95% confidence intervals
        [Q, R] = qr([time ones(length(time), 1)], 0);
        yint = R \ (Q' * met_data(:, i));
        rmse = norm(met_data(:, i) - [time ones(length(time), 1)] * yint) / sqrt(78);
        tval = tinv((1 - 0.05 / 2), 78);
        err = rmse * sqrt(sum(abs(R \ eye(2)) .^ 2, 2));
        tmp2 = [yint - tval * err, yint + tval * err];

        % IF STATISTICS TOOLBOX INSTALLED,
        % USE THE REGRESS COMMAND:
    %     [tmp1, tmp2] = regress(met_data(:, i), [time ones(length(time), 1)], 0.05);

        changeSlopes(i, 1) = tmp1(1);
        changeIntervals(i, 1) = abs(changeSlopes(i, 1) - tmp2(1));
    end

    % Run uFBA algorithm
    % Determine which changes in metabolite concentration are siginificant
    % (based on 95% confidence):
    tmp1 = changeSlopes - changeIntervals;
    tmp2 = changeSlopes + changeIntervals;
    ignoreSlopes = double(tmp1 < 0 & tmp2 > 0);

    % Set inputs to uFBA function
    uFBAvariables.metNames = met_IDs;
    uFBAvariables.changeSlopes = changeSlopes;
    uFBAvariables.changeIntervals = changeIntervals;
    uFBAvariables.ignoreSlopes = ignoreSlopes;

    uFBAoutput = buildUFBAmodel(model, uFBAvariables);

    % Test output
    sol = optimizeCbModel(uFBAoutput.model);

    assert(sol.f > 0.225 & sol.f < 0.235, 'Solution incorrect to 2 decimals.')
else
    fprintf('This test requires Gurobi to run properly')
end
