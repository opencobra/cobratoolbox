% Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
% Free for non-commerical use, for more information: see LICENSE.txt
% http://cmb.helmholtz-muenchen.de/odefy

%% Simulation of feed-forward loop by SB toolbox

% generate model
model = ExpressionsToOdefy({'a = <>','b = a','c = a && ~b'});
sbmodel = CreateSBToolboxModel(model,'hillcubenorm',1);

% set some parameters
sbmodel = SBparameters(sbmodel,'c_k_b',0.9);

% set initial conditions
sbmodel = SBinitialconditions(sbmodel, [1 0 0]);

% simulate
SBsimulate(sbmodel);
 

%% Compilation of a model by SB toolbox

% generate model
model = ExpressionsToOdefy({'a = <>','b = a','c = a && ~b'});
sbmodel = CreateSBToolboxModel(model,'hillcubenorm',1);

% compile model
SBPDmakeMEXmodel(sbmodel, 'model_compiled.mex');

% perform simulation
output = model_compiled(0:0.1:20, [1 0 0]);
plot(output.time, output.statevalues);