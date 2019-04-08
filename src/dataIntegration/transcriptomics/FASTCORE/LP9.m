function V = LP9(K, P, model, LPproblem, epsilon)
% CPLEX implementation of LP-9 for input sets K, P (see FASTCORE paper)
%
% USAGE:
%
%    V = LP9(K, P, model, epsilon)
%
% .. Authors: -  Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%             LCSB / LSRU, University of Luxembourg
%   2019/04/08: Agnieszka Wegrzyn - updated the function to work with models with coupling constraints

    scalingfactor = 1e5;

    V = [];
    if isempty(P) || isempty(K)
        return;
    end

    np = numel(P);
    nk = numel(K);
    [m,n] = size(model.S);
    [m2,n2] = size(LPproblem.A);

    % objective
    f = [zeros(n2,1); ones(np,1)];

    % equalities
    Aeq = [LPproblem.A, sparse(m2,np)]; %changed the size of sparse() to match the size of LPproblem.A
    beq = LPproblem.b;

    % inequalities
    Ip = sparse(np,n2); Ip(sub2ind(size(Ip),(1:np)',P(:))) = 1;
    Ik = sparse(nk,n2); Ik(sub2ind(size(Ik),(1:nk)',K(:))) = 1;
    Aineq = sparse([[Ip, -speye(np)]; ...
                    [-Ip, -speye(np)]; ...
                    [-Ik, sparse(nk,np)]]);
    bineq = [zeros(2*np,1); -ones(nk,1)*epsilon*scalingfactor];

    % bounds
    lb = [LPproblem.lb; zeros(np,1)] * scalingfactor;
    ub = [LPproblem.ub; max(abs(model.ub(P)),abs(model.lb(P)))] * scalingfactor;

    % Set up LP problem
    LP9problem.A=[Aeq;Aineq];
    LP9problem.b=[beq;bineq];
    LP9problem.lb=lb;
    LP9problem.ub=ub;
    LP9problem.c=f;
    LP9problem.osense=1;%minimise
    LP9problem.csense = [LPproblem.csense; repmat('L',2*np + nk,1)];
    

    solution = solveCobraLP(LP9problem);

    if solution.stat~=1
        fprintf('\n%s%s\n',num2str(solution.stat),' = sol.stat')
        fprintf('%s%s\n',num2str(solution.origStat),' = sol.origStat')
        warning('LP solution may not be optimal')
    end

    x=solution.full;

    if ~isempty(x)
        V = x(1:n);
    else
        V=ones(n,1)*NaN;
    end
