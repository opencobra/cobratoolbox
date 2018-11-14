% The COBRA Toolbox: testSetConstraintsOnBiomassReaction
%
% Purpose:
%     - test setConstraintsOnBiomassReaction function
%
% Authors:
%     - Loic Marx, November 2018
%
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testsetConstraintsOnBiomassReaction'));
cd(fileDir);

%define inputs
model = getDistributedModel('ecoli_core_model.mat');
dT = 24
tolerance = 20
of = model.rxns
 
%Calcule the reference value
ub =   0.0347;
lb =   0.0231;
tol = 1e-4;

model_refdata = setConstraintsOnBiomassReaction(model,of, dT, tolerance)

%Test if the upperbound and the lowerbound are the same as the references values
 

for k = 1:length(model.rxns)
assert(norm(model_refdata.ub(k)- ub) < tol);
assert(norm(model_refdata.lb(k)- lb) < tol);
end 

