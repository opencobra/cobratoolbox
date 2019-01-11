% The COBRA Toolbox: testSetMediumConstraints.m
%
% Purpose:
%     - test the setMediumConstraints function
%
% Author:
%     - Loic Marx, December 2018

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which(mfilename));
cd(fileDir);

% load reference data 
load('refData_setMediumConstraints.mat');

% define input
model = getDistributedModel('Recon2.v04.mat'); 
set_inf = 1000;
current_inf = 500; 
medium_composition = {'EX_ala_L(e)';'EX_arg_L(e)'} % related to the RPMI composition
met_Conc_mM = [1;2]; %Change in metabolite concentration (mM)
cellConc = 1; 
t = 1; % Time in hours
cellWeight = 500 * 1e-12; 
mediumCompounds = {'EX_co2(e)';'EX_h(e)'}; %metabolites that are uptake from the medium but not captured by the measured data
mediumCompounds_lb = -10;
customizedConstraints = {'EX_o2(e)'}; %limit the model behaviour to the secretion of oxygen
customizedConstraints_lb = 1;
customizedConstraints_ub = 2;
close_exchanges = 1; % 1 : close exchange , 0: open exchange 

% set up the tolerance
tol = 1e-4;

% generate data
[modelMedium, basisMedium] = setMediumConstraints(model, set_inf, current_inf, medium_composition, met_Conc_mM, cellConc, t, cellWeight, mediumCompounds, mediumCompounds_lb, customizedConstraints, customizedConstraints_ub, customizedConstraints_lb, close_exchanges);

% if customizedConstraints, customizedConstraints_ub, customizedConstraints_lb close_exchanges are not defined 
[modelMedium_noCustomizedConstraints, basisMedium_noCustomizedConstraints] = setMediumConstraints(model, set_inf, current_inf, medium_composition, met_Conc_mM, cellConc, t, cellWeight, mediumCompounds, mediumCompounds_lb);

% comparison between refData and generated data 
assert(norm(modelMedium_ref.lb - modelMedium.lb) < tol) %lowerband
assert(norm(modelMedium_ref.ub - modelMedium.ub) < tol) %upperband
assert(isequal(basisMedium_ref, basisMedium))

% comparison between refData without constraint and generated data without constraints inputs
assert(norm(modelMedium_Ref_noCustomizedConstraints.lb - modelMedium_noCustomizedConstraints.lb) < tol) %lowerband
assert(norm(modelMedium_Ref_noCustomizedConstraints.ub - modelMedium_noCustomizedConstraints.ub) < tol) %upperband
assert(isequal(basisMedium_Ref_noCustomizedConstraints, basisMedium_noCustomizedConstraints))
