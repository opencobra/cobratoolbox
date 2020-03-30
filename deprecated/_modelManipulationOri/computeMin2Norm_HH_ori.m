function [solution2] = computeMin2Norm_HH(model)
% This function computes the min2Norm for the whole-body metabolic model.
% As the underlying quadratic programming problem may not be proven to
% yield an optiomal solution due to numercial difficulties, we compute the
% min2Norm twice.
% In the first QP, we take the input model as is, and compute the feasible
% but not necessarily optimal flux distribution. In a second step, we
% rescale the bounds on the model's reaction to ensure numerical stability.
% The computed solution from the second QP is rescaled accordingly
% afterwards.
% Note that this function assumes that the infinity constraints are represented by -1,000,000 or 1,000,000.
%
% INPUT
% model      model structure (whole-body metabolic model)
%
% OUTPUT
% solution2  optimal min2Norm solution
%
% Ines Thiele 01/2018

model.c = zeros(length(model.c),1);

% First QP on vanilla model
[solution,LPProblem]=solveCobraLPCPLEX(model,0,0,0,[],1e-6,'tomlab_cplex');

% Prepare 2nd QP
model2=model;
% all high flux values in the solution vectore of the first QP retain a high bound
model2.lb(find(solution.full<-1e4))=-500000;
model2.ub(find(solution.full>1e4))=500000;

% reduced the "infinity" bounds on all other reactions.
% note this step does not affect any non-infinity bounds set on the
% whole-body metabolic model
model2.lb(find(model2.lb==-1000000))=-10000; % reduce the effective unbound constraints to lower number, representing inf
model2.ub(find(model2.ub==1000000))=10000;% reduce the effective unbound constraints to lower number, representing inf

% we then rescale all bounds on the model reactions by a factor of 1/1000,
% which proven to result in an optimal QP solution
model2.lb=model2.lb/1000;
model2.ub=model2.ub/1000;

if solution.origStat == 6
    % we solve the 2nd QP
    [solution2,LPProblem]=solveCobraLPCPLEX(model2,1,0,0,[],1e-6,'tomlab_cplex');
    
    % we resale the computed solution by the factor of 1000
    solution2.full = solution2.full*1000; % rescale solution by the factor of 1000
    solution2.obj = solution2.obj*1000; % rescale solution by the factor of 1000
else 
    solution2 = solution;
end