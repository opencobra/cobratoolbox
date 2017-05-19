function V = LP3(J, model)
% CPLEX implementation of LP-3 for input set J (see FASTCORE paper)
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg

    [m,n] = size(model.S);

    % objective
    f = zeros(1,n);
    f(J) = -1;

    % equalities
    Aeq = model.S;
    beq = zeros(m,1);

    % bounds
    lb = model.lb;
    ub = model.ub;
    
    % Set up problem
    LPproblem.A = Aeq;
    LPproblem.b = beq;
    LPproblem.c = f;
    LPproblem.lb = lb;
    LPproblem.ub = ub;
    LPproblem.osense = 1;
    LPproblem.csense(1:m,1) = 'E';

    %V = cplexlp(f,[],[],Aeq,beq,lb,ub);
    sol = solveCobraLP(LPproblem);
    V = sol.full;
end