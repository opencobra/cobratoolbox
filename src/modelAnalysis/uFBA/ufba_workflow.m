% -------------------------------------------------------------------------
% ufba_workflow.m
%
% This script provides a sample workflow for using unsteady-state flux
% balance analysis (uFBA) to integrate quantitative exo- and/or endo-
% metabolomics data: 
% Bordbar and Yurkovich et al. (2017), doi:10.1038/srep46249
% 
% The data provided for this sample workflow is for human erythrocytes 
% under cold storage:
% Bordbar et al. (2016), doi:10.1111/trf.13460
% 
% The model provided for the workflow is a metabolic reconstruction of the
% human eyrthrocyte metabolic network:
% Bordbar et al. (2015), doi:10.1016/j.cels.2015.10.003
%
% Running this method requires the installation of a mixed-integer linear
% progamming solver. We have used Gurobi 5
% (http://www.gurobi.com/downloads/download-center) which is freely
% available for academic use.
% 
% James Yurkovich 5/08/2017
% -------------------------------------------------------------------------
clear;clc

%% Load in data and model, and initialize
% This data is quantified and volume adjusted. The following 
% variables will be loaded into your workspace:
%   met_data        exo- and endo-metabolomics data
%   met_IDs         BiGG IDs for the measured metabolites
%   model           modified iAB-RBC-283 COBRA model structure
%   time            time points (in days)
%   uFBAvariables   input for uFBA algorithm
initCobraToolbox();
load sample_data;

changeCobraSolver('gurobi', 'LP');
changeCobraSolver('gurobi', 'MILP');


%% Linear regression
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


%% Run uFBA algorithm
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


%% Test output
model_ufba = optimizeCbModel(uFBAoutput.model)


