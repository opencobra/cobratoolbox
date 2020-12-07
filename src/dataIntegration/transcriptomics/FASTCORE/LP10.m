function V = LP10(K, P, v, LPproblem, epsilon)
% Implementation of LP-10 for input sets K, P (see FASTCORE paper)
%
% USAGE:
%
%    V = LP10(K, P, v, epsilon)
%

% .. Authors: -  Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%             LCSB / LSRU, University of Luxembourg
%   2019/04/08: Agnieszka Wegrzyn - updated the function to work with models with coupling constraints
% 2020 Ronan Fleming - adaptive scaling prototype

V = [];
if isempty(P) || isempty(K)
    return;
end
[m2,n2] = size(LPproblem.A);
    
scalingFactorFixed=1;
if scalingFactorFixed
    scalingfactor = 1e4;
    
    np = numel(P);
    nk = numel(K);

    
    % objective
    f = [zeros(n2,1); ones(np,1)];
    
    % S*v = b and C *v<= d if present
    Aeq = [LPproblem.A, sparse(m2,np)]; %changed the size of sparse() to match the size of LPproblem.A
    beq = LPproblem.b;
    
    % inequalities
    Ip = sparse(np,n2); Ip(sub2ind(size(Ip),(1:np)',P(:))) = 1;
    Ik = sparse(nk,n2); Ik(sub2ind(size(Ik),(1:nk)',K(:))) = 1;
    Aineq = sparse([[Ip, -speye(np)]; ...
        [-Ip, -speye(np)]; ...
        [-Ik, sparse(nk,np)]]);
    bineq = [zeros(2*np,1); -ones(nk,1)*epsilon];
    
    % bounds
    lb = [LPproblem.lb; zeros(np,1)];
    ub = [LPproblem.ub; max(abs(LPproblem.ub(P)),abs(LPproblem.lb(P)))] ;
    
    % Set up LP problem
    LP10problem.A=[Aeq;Aineq];
    %scaling factor must be multiplied by vector on rhs of A*x<= b
    LP10problem.b=[beq;bineq]*scalingfactor;
    %scaling factor must be multiplied by lb and ub of lb <= x <= ub
    LP10problem.lb=lb*scalingfactor;
    LP10problem.ub=ub*scalingfactor;
    LP10problem.c=f;
    LP10problem.osense=1;%minimise
    LP10problem.csense = [LPproblem.csense; repmat('L',2*np + nk,1)];
    
    
    solution = solveCobraLP(LP10problem);
    if solution.stat~=1
        disp(solution)
        warning(['solution.stat~=1. Scaling factor in LP10 is ' num2str(scalingfactor) ', which may cause numerical instability for solveCobraLP. Try scalingFactorFixed=0 in LP10.m'])
    end
    
else
    
    minIrrevCoreSetBound = min(v(K));
    %disp(minIrrevCoreSetBound);
    
    np = numel(P);
    nk = numel(K);
    %[m,n] = size(model.S);
    [m2,n2] = size(LPproblem.A);
    
    % objective
    c = [zeros(n2,1); ones(np,1)];
    
    % S*v = b and C *v<= d if present
    Aeq = [LPproblem.A, sparse(m2,np)]; %changed the size of sparse() to match the size of LPproblem.A
    beq = LPproblem.b;
    
    % inequalities
    Ip = sparse(np,n2); Ip(sub2ind(size(Ip),(1:np)',P(:))) = 1;
    Ik = sparse(nk,n2); Ik(sub2ind(size(Ik),(1:nk)',K(:))) = 1;
    Aineq = sparse(...
        [[Ip, -speye(np)]; ...  %  v - z <= 0                         v \in P
        [-Ip, -speye(np)]; ...  % -v - z <= 0                         v \in P
        [-Ik, sparse(nk,np)]]); % -v     <= -minIrrevCoreSetBound     v \in K
    bineq = [zeros(2*np,1); -ones(nk,1)*minIrrevCoreSetBound];
    
    
    % bounds
    vlb = LPproblem.lb;
    %vlb(K)=minIrrevCoreSetBound;
    lb = [vlb; zeros(np,1)];
    ub = [LPproblem.ub; max(abs(LPproblem.ub(P)),abs(LPproblem.lb(P)))];
    
    % Set up LP problem
    LP10problem.A=[Aeq;Aineq];
    LP10problem.b=[beq;bineq];
    LP10problem.lb=lb;
    LP10problem.ub=ub;
    LP10problem.c=c;
    LP10problem.osense=1;%minimise
    LP10problem.csense = [LPproblem.csense; repmat('L',2*np + nk,1)];
    
    
    solution = solveCobraLP(LP10problem);
    
end

if solution.stat~=1
    fprintf('\n%s%s\n',num2str(solution.stat),' = sol.stat')
    fprintf('%s%s\n',num2str(solution.origStat),' = sol.origStat')
    warning('LP solution may not be optimal')
end

x=solution.full;

if ~isempty(x)
    V = x(1:n2);
else
    V=ones(n2,1)*NaN;
end
