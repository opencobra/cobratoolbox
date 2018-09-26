function [solution] = enumerateOptimalSolutions(model)
% Returns a set of optimal flux distributions
% spanning the optimal set
%
% USAGE:
%
%    [solution] = enumerateOptimalSolution(model)
%
% INPUT:
%    model:       COBRA model structure
%
% OUTPUT:
%    solution:    solution structure
%
%                   * fluxes - Flux distribution for each iteration
%                   * nonzero - Boolean matrix denoting which fluxes are nonzero for each iteration
%
% .. Authors:
%       - Jan Schellenberger, August 2008 - Based on code by Jennie Reed
%       - Reed, J.L. and Palsson, B.O., "Genome-scale in silico models of ''E. coli'' have multiple equivalent phenotypic states: assessment of correlated reaction subsets that comprise network states" , Genome Research, 14:1797-1805(2004).


[nMets,nRxns] = size(model.S);

solution.fluxes = zeros(nRxns,0);
solution.nonzero = zeros(nRxns,0);

%sol = optimizeCbModel(model);
LPproblem = buildLPproblemFromModel(model);
NZ = zeros(nRxns,0);
sol = solveCobraLP(LPproblem);
tol = getCobraSolverParams('LP','feasTol');
NZ(:,end+1) = abs(sol.full(1:nRxns))>tol;
PrevNZ = NZ(:,end);
PrevFW = sol.full(1:nRxns) > tol;
solution.fluxes(:,end+1) = sol.full(1:nRxns);

maxObjective = sol.obj;
MILPproblem = LPproblem;
% Add a Line to keep the objective value
MILPproblem.A = [MILPproblem.A;LPproblem.c'];
MILPproblem.b = [MILPproblem.b;maxObjective];
if MILPproblem.osense == 1
    sense = 'L';
else
    sense = 'G';
end
MILPproblem.csense = [MILPproblem.csense;sense];

% add the indicator variables to the LP:

[nCtrs,nVars] = size(MILPproblem.A);
% v_+ / v_-
MILPproblem.A = [MILPproblem.A,sparse(nCtrs,nRxns*2);...
               speye(nRxns,nVars), -diag(model.ub), sparse(nRxns,nRxns);... %v - v_+*ub <= 0
               speye(nRxns,nVars+nRxns), -diag(model.lb);....%v - v_-*lb >= 0
               sparse(nRxns,nVars),speye(nRxns,nRxns), speye(nRxns,nRxns)];%;...% v_i+ + v_i- <= 1
               %sparse(1,nVars),~(PrevFW & PrevNZ)',~(~PrevFW & PrevNZ)']; %At least one reaction that was not yet active has to be active now!
MILPproblem.vartype = [repmat('C',nVars,1);repmat('B',2*nRxns,1)];
MILPproblem.lb = [MILPproblem.lb;zeros(2*nRxns,1)];
MILPproblem.ub = [MILPproblem.ub;ones(2*nRxns,1)];
MILPproblem.csense = [MILPproblem.csense;...
                    repmat('L',nRxns,1);...
                    repmat('G',nRxns,1);...
                    repmat('L',nRxns,1)];
MILPproblem.b = [MILPproblem.b;...
               zeros(2*nRxns,1);...                    
               ones(nRxns,1)]; 
           
MILPproblem.c = [LPproblem.c; zeros(2*nRxns,1)];

NonZeroConstPos = size(MILPproblem.A,1);
while 1
    % modify the "At least one new reaction" constraint
    %MILPproblem.A(NonZeroConstPos,:) = [sparse(1,nVars),~PrevNZ',~PrevNZ'];
    % add the "this solution is no longer allowed constraint
    MILPproblem.A = [MILPproblem.A;...
                   sparse(1,nVars), (PrevFW & PrevNZ)', (~PrevFW & PrevNZ)'];
    MILPproblem.csense = [MILPproblem.csense; 'L'];
    MILPproblem.b = [MILPproblem.b; sum(PrevNZ)-1];
    solMILP = solveCobraMILP(MILPproblem);
    if solMILP.stat ~= 1
        % No more solutions can be found
        solution.nonzero = NZ;
        return;
    end        
    NZ(:,end+1) = abs(solMILP.full(1:nRxns))>tol;
    PrevNZ = NZ(:,end);
    PrevFW = solMILP.full(1:nRxns) > tol;
    solution.fluxes(:,end+1) = solMILP.full(1:nRxns);   
end

