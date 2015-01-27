% This file contains code segments for various Odefy functionalities

% Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
% Free for non-commerical use, for more information: see LICENSE.txt
% http://cmb.helmholtz-muenchen.de/odefy


%% Simulation using Odefy functions

% generate model and default simulation structure
model = ExpressionsToOdefy({'a = <>','b = a','c = a && ~b'});
simstruct = CreateSimstruct(model);

% change simulation type, initial values and parameters
simstruct.type = 'hillcubenorm';
simstruct = SetInitialValue(simstruct, 'a', 1);
simstruct = SetParameters(simstruct, 'c', 'b', 'k', 0.9);

% perform simulation, show plots
OdefySimulation(simstruct,1);

%% Phase plane view

% generate model and default simulation structure
model = ExpressionsToOdefy({'a = a || ~b', 'b = b || ~a'});
simstruct = CreateSimstruct(model);

% show phase plane
OdefyPhasePlane(simstruct, 1, 0:0.1:1, 2, 0:0.1:1);

%% Simulation using ode15s

% generate model
model = ExpressionsToOdefy({'a = <>','b = a','c = a && ~b'});
SaveMatlabODE(model, 'myode.m', 'hillcubenorm'); 
rehash;

% set initial value for species a
initial = zeros(3,1);
initial = SetInitialValue(initial, model, 'a', 1);

% reduce influence of b on c
params = DefaultParameters(model);
params = SetParameters(params,model,'c', 'b', 'k', 0.9);
paramvec = ParameterVector(model,params);

% perform simulation
time = 10;
r = ode15s(@(t,y)myode(t,y,paramvec), [0 time], initial);

% show results
Visualize(r.x,r.y,model.species);

%% Transient activation

% set initial value for species a
initial = zeros(3,1);

% reduce influence of b on c
params = DefaultParameters(model);
params = SetParameters(params,model,'c', 'b', 'k', 0.9);
paramvec = ParameterVector(model,params);

% perform simulation
time = 10;
r = ode15s(@(t,y)transient(t,y,paramvec), [0 time], initial);

% show results using Odefy's Visualize function
Visualize(r.x,r.y,model.species);
