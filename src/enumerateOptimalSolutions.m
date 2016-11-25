function [solution] = enumerateOptimalSolutions(model)
%enumerateOptimalSolution returns a set of optimal flux distributions
%spanning the optimal set
%
%[solution] enumerateOptimalSolution(model) 
%
%INPUT
% model         COBRA model structure
%
%OUTPUT
% solution      solution strcture
%   fluxes      Flux distribution for each iteration
%   nonzero     Boolean matrix denoting which fluxes are nonzero for each
%               iteration
%
% Author:  Jan Schellenberger, August 2008
% Based on code by Jennie Reed 
% Reed, J.L. and Palsson, B.O., "Genome-scale in silico models of ''E. coli'' have multiple equivalent phenotypic states: assessment of correlated reaction subsets that comprise network states" , Genome Research, 14:1797-1805(2004). 


[m,n] = size(model.S);

solution.fluxes = zeros(n,0);
solution.nonzero = zeros(n,0);

sol = optimizeCbModel(model);
maxObjective = sol.f;


prevNZ = abs(sol.x) > .0001;
NZ = prevNZ;
solution.fluxes = sol.x;
solution.nonzero = prevNZ;

while 1
    % variables:
    %    v's (n), y's (n) w's (n)  3n total variables
    
    % constriants:
    %    m mass balance constraints
    A = [model.S, zeros(m,2*n)];
    b = zeros(m,1);
    csense = '';
    for i = 1:m
        csense(end+1) = 'E';
    end
    % constrain UB fluxes w/ integer constraints
    A = [A; 
        [eye(n,2*n), -diag(model.ub)] ];
    b = [b;
        zeros(n,1)];
    for i = 1:n
        csense(end+1) = 'L';
    end    
    % constrain LB fluxes w/ integer constraints
    A = [A; 
        eye(n,2*n), -diag(model.lb) ];
    b = [b;
        zeros(n,1)];
    for i = 1:n
        csense(end+1) = 'G';
    end    
    

    % constrain w+y <=1 
    A = [A; 
        zeros(n,n), eye(n,n), eye(n,n) ];
    b = [b;
        ones(n,1)];
    for i = 1:n
        csense(end+1) = 'L';
    end    

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
    vartype = [];
    for i = 1:n
        vartype(i) = 'C';
    end
    for i = 1:2*n
        vartype(end+1) = 'B';
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
    MILPsol = solveCobraMILP(MILPproblem)
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