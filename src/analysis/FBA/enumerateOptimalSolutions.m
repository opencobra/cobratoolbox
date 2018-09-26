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


[m,n] = size(model.S);

solution.fluxes = zeros(n,0);
solution.nonzero = zeros(n,0);

%sol = optimizeCbModel(model);
LPproblem = buildLPproblemFromModel(model);

sol = solveCobraLP(LPproblem);

maxObjective = sol.f;

% Add a Line to keep the objective value
LPproblem.A = [LPproblem.A;LPproblem.c'];
LPproblem.b = [LPproblem.b;maxObjective];
if LPproblem.osense == 1
    sense = 'L';
else
    sense = 'G';
end
LPproblem.csense = [LPproblem.csense;sense];

% add the indicator variables to the LP:
[nMets,nRxns] = size(model.S);
[nCtrs,nVars] = size(LPproblem.A];
% v_+ / v_-
LPproblem.A = [LPproblem.A,sparse(nCtrs,nRxns*2);...
               speye(nRxns,nVars), -diag(model.ub), sparse(nRxns);... %v - v_+*ub <= 0
               speye(nRxns,nVars+nRxns), -diag(model.lb);....%v - v_-*lb >= 0
               sparse(nRxns,nVars),speye(nRxns,nRxns), speye(nRxns,nRxns)]; % v_i+ + v_i- <= 1
LPproblem.vartype = [repmat('C',nVars,1);repmat('B',2*nRxns,1)];
LPproblem.csense = [LPproblem.csense;...
                    repmat('L',nRxns,1);...
                    repmat('G',nRxns,1);...
                    repmat('L',nRxns,1)];
LPproblem.b = [LPproblem.b;...
               zeros(2*nRxns,1);...                    
               ones(nRxns,1)];           
while 1
    %add the Non-Zero constraint
    prevNZ = abs(sol.x(1:nRxns)) > .0001;
    NZ = prevNZ;
    solution.fluxes = sol.x(1:nRxns);
    solution.nonzero = prevNZ;    
    LPproblem.A = [LPproblem.A;
                   zeros(1,nVars), 
    % constrain with previous zero results
    A = [A;
        zeros(1,n), prevNZ', zeros(1,n) ];
    b = [b;
        1];
    csense(end+1) = 'G';

    % constrain with previous results (altbases)
    for i = 1:size(NZ,2)
        A = [A;
            [zeros(1,n), zeros(1,n) NZ(:,i)']];
        b(end+1) = sum(NZ(:,i))-1;
        csense(end+1) = 'L';
    end

    % vartype
    vartype = char();
    for i = 1:n
        vartype(i,1) = 'C';
    end
    for i = 1:2*n
        vartype(end+1,1) = 'B';
    end

    % lb,ub
    lb = [model.lb; zeros(2*n,1)];
    ub = [model.ub; ones(2*n,1)];
    % c
    c = [model.c; zeros(2*n,1)];


    % create structure
    MILPproblem.A = A;
    MILPproblem.b = b;
    MILPproblem.c = c;
    MILPproblem.csense = csense;
    MILPproblem.lb = lb;
    MILPproblem.ub = ub;
    MILPproblem.osense = -1;
    MILPproblem.vartype = vartype;
    MILPproblem.x0 = [];%zeros(2*n,1);
    %MILPproblem.intSolInd = [];
    %MILPproblem.contSolInd = [];

%    pause;
    MILPsol = solveCobraMILP(MILPproblem);
%    MILPsol.full
    NZ(:,end+1) = abs(MILPsol.full(1:n))>.000000001;
    PrevNZ = NZ(:,end);


    if (abs(MILPsol.full - maxObjective) > .001)
        'done';
        return;
    end
    solution.fluxes = [solution.fluxes,MILPsol.full(1:n)];
    solution.nonzero = [solution.nonzero, NZ(:,end)];
    solution
end

return;
