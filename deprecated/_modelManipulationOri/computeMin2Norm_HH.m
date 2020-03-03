function [solution2] = computeMin2Norm_HH(model,QPSolver)
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
% Note that this function has been only tested and tuned for 'ILOGcomplex'
% and 'tomlab_cplex'
%
% INPUT
% model      model structure (whole-body metabolic model)
% QPSolver   Quadratic prorgamming solver (default: 'ILOGcomplex'; option: tomlab_cplex)
% OUTPUT
% solution2  optimal min2Norm solution
%
% Ines Thiele 01/2018
% Ines Thiele 10/2019 - expended for Ilog Cplex

if ~exist('QPSolver','var')
    QPSolver = 'ILOGcomplex';
end

model.c = zeros(length(model.c),1);

% First QP on vanilla model
[solution,LPProblem]=solveCobraLPCPLEX(model,0,0,0,[],1e-6,QPSolver);

if ~isfield(solution,'full')
    %display for debugging as it is going to crash next
    solution
end

% Prepare 2nd QP
model2=model;
if strcmp(QPSolver,'ILOGcomplex')
    % all high flux values in the solution vectore of the first QP retain a high bound
    model2.lb(find(solution.full<-1e4))=-abs(max(solution.full));
    model2.ub(find(solution.full>1e4))=abs(max(solution.full));
elseif strcmp(QPSolver,'tomlab_cplex')
    % all high flux values in the solution vectore of the first QP retain a high bound
    model2.lb(find(solution.full<-1e4))=-500000;
    model2.ub(find(solution.full>1e4))=500000;
end

% reduced the "infinity" bounds on all other reactions.
% note this step does not affect any non-infinity bounds set on the
% whole-body metabolic model
model2.lb(find(model2.lb==-1000000))=-10000; % reduce the effective unbound constraints to lower number, representing inf
model2.ub(find(model2.ub==1000000))=10000;% reduce the effective unbound constraints to lower number, representing inf

% we then rescale all bounds on the model reactions by a factor of 1/1000,
% which proven to result in an optimal QP solution
if strcmp(QPSolver,'ILOGcomplex')
    model2.lb=model2.lb/100000;
    model2.ub=model2.ub/100000;
elseif strcmp(QPSolver,'tomlab_cplex')
    model2.lb=model2.lb/1000;
    model2.ub=model2.ub/1000;
end

%       1 (S,B) Optimal solution found
%       2 (S,B) Model has an unbounded ray
%       3 (S,B) Model has been proved infeasible
%       4 (S,B) Model has been proved either infeasible or unbounded
%       5 (S,B) Optimal solution is available, but with infeasibilities after unscaling
%       6 (S,B) Solution is available, but not proved optimal, due to numeric difficulties
if solution.origStat == 6 || solution.origStat == 1 || solution.origStat == 5
    % we solve the 2nd QP
    if strcmp(QPSolver,'ILOGcomplex')
        [solution2,LPProblem]=solveCobraLPCPLEX(model2,0,0,0,[],1e-6,QPSolver);
        
        % we resale the computed solution by the factor of 1000
        solution2.full = solution2.full*100000; % rescale solution by the factor of 100000
        solution2.obj = solution2.obj*100000; % rescale solution by the factor of 100000
    elseif strcmp(QPSolver,'tomlab_cplex')
        
        [solution2,LPProblem]=solveCobraLPCPLEX(model2,0,0,0,[],1e-6,QPSolver);
        
        % we resale the computed solution by the factor of 1000
        solution2.full = solution2.full*1000; % rescale solution by the factor of 1000
        solution2.obj = solution2.obj*1000; % rescale solution by the factor of 1000
    end
    %added for compatibility with optimiseWBModel
    solution2.v=solution2.full;
else
    %added for compatibility with optimiseWBModel
    solution.v=solution.full;
    solution2 = solution;
end

