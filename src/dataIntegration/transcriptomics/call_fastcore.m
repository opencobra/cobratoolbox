function tissueModel = call_fastcore(model, expressionRxns, threshold, tol, core, scaling) 
%Use the FASTCORE algorithm (Vlassis et al, 2014*) to extract a context
%specific model using data. FASTCORE algorithm defines one set of core
%reactions that is guaranteed to be active in the extracted model and find
%the minimum of reactions possible to support the core.
%
%INPUTS
%
%   model               input model (COBRA model structure)   
%   expressionRxns      expression data, corresponding to model.rxns (see
%                       mapGeneToRxn.m)
%   threshold           expression threshold (reactions with expression
%                       above this threshold are put in the set of core
%                       reactions
%   tol                 tolerance by which reactions are defined inactive after model extraction
%                       (recommended lowest value 1e-8 since solver
%                       tolerance is 1e-9)%% TO SET -defaut value
%   core                cell array with reaction names (strings) that are manually put in
%                       the core %% TO SET -(default: objective function)                      
%   scaling             scaling constant %% TO SET -(default 1e3)
%
%OUTPUTS
%
%   tissueModel         extracted model
%
%* Vlassis, Pacheco, Sauter (2014). Fast reconstruction of compact
%context-specific metbolic network models. PLoS Comput. Biol. 10, e1003424.
%
%Originally written by Vlassis et al,
%Adapted by S. Opdam and A. Richelle - May 2017

    model_orig = model;
    
    %Define the set of core reactions
    coreSetRxn = find(expressionRxns >= threshold);
    coreSetRxn = union(coreSetRxn, find(ismember(model.rxns, core)));

    %Find irreversible reactions
    irrevRxns = find(model.rev==0);

    A = [];
    flipped = false;
    singleton = false;  

    % Find irreversible core reactions
    J = intersect(coreSetRxn, irrevRxns);
    nbRxns = 1:numel(model.rxns);
    
    %Find all the reactions that are not in the core
    P = setdiff(nbRxns, coreSetRxn);
    
    % Find the minimum of reactions from P that need to be included to
    % support the irreversible core set of reactions
    Supp = findSparseMode(J, P, singleton, model, tol, scaling);
    
    if ~isempty(setdiff(J, Supp)) 
      fprintf ('Error: Inconsistent irreversible core reactions.\n');
      return;
    end
    A = Supp; 
    J = setdiff(coreSetRxn, A);

    % Main loop that reduce at each iteration the number of reactions from P that need to be included to
    % support the complete core set of reactions    
    while ~isempty(J)
        P = setdiff(P, A);
        Supp = findSparseMode(J, P, singleton, model, tol, scaling);
        A = union(A, Supp);
        if ~isempty(intersect(J, A))
            J = setdiff(J, A);
            flipped = false;
        else
            if singleton
                JiRev = setdiff(J(1),irrevRxns);
            else
                JiRev = setdiff(J,irrevRxns);
            end
            if flipped || isempty(JiRev)
                if singleton
                    fprintf('\nError: Global network is not consistent.\n');
                    return
                else
                  flipped = false;
                  singleton = true;
                end
            else
                model.S(:,JiRev) = -model.S(:,JiRev);
                tmp = model.ub(JiRev);
                model.ub(JiRev) = -model.lb(JiRev);
                model.lb(JiRev) = -tmp;
                flipped = true;
            end
        end
    end
    
    toRemove = setdiff(model.rxns,model.rxns(A));
    tissueModel = removeRxns(model_orig, toRemove);
    tissueModel = removeNonUsedGenes(tissueModel);

end

function Supp = findSparseMode(J, P, singleton, model, tol, scaling)
% Finds a mode that contains as many reactions from J and as few from P
% Returns its support, or [] if no reaction from J can get flux above tol
%* Vlassis, Pacheco, Sauter (2014). Fast reconstruction of compact
%context-specific metbolic network models. PLoS Comput. Biol. 10, e1003424.

    Supp = [];
    if isempty(J) 
      return;
    end

    if singleton
      V = LP7(J(1), model, tol);
    else
      V = LP7(J, model, tol);
    end

    K = intersect(J, find(V >= 0.99*tol));   
    if isempty(K) 
      return;
    end

    V = LP9(K, P, model, tol, scaling);
    Supp = find(abs(V) >= 0.99*tol);
end

function V = LP7(J, model, tol) %% TO DO, check that it works for the different available solver in cobra, if not fix the potential solver 
% CPLEX implementation of LP-7 for input set J (see FASTCORE paper)
% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg

    nj = numel(J);
    [m,n] = size(model.S);

    % x = [v;z]

    % objective
    f = -[zeros(1,n), ones(1,nj)];

    % equalities
    Aeq = [model.S, sparse(m,nj)];
    beq = zeros(m,1);

    % inequalities
    Ij = sparse(nj,n); 
    Ij(sub2ind(size(Ij),(1:nj)',J(:))) = -1;
    Aineq = sparse([Ij, speye(nj)]);
    bineq = zeros(nj,1);

    % bounds
    lb = [model.lb; zeros(nj,1)];
    ub = [model.ub; ones(nj,1)*tol];

    % Set up problem
    LPproblem.A = [Aeq;Aineq];
    LPproblem.b = [beq;bineq];
    LPproblem.c = f;
    LPproblem.lb = lb;
    LPproblem.ub = ub;
    LPproblem.osense = 1;
    LPproblem.csense(1:m,1) = 'E';
    LPproblem.csense(m+1:length(bineq)+m,1) = 'L';
    
    sol = solveCobraLP(LPproblem);
    if sol.stat == 1
        x = sol.full;    
        %x = cplexlp(f,Aineq,bineq,Aeq,beq,lb,ub);
        V = x(1:n);
    else
        V = zeros(n,1);
    end
end

function V = LP9(K, P, model, tol, scaling)%% TO DO, check that it works for the different available solver in cobra, if not fix the potential solver 
% CPLEX implementation of LP-9 for input sets K, P (see FASTCORE paper)
%* Vlassis, Pacheco, Sauter (2014). Fast reconstruction of compact
%context-specific metbolic network models. PLoS Comput. Biol. 10, e1003424.

    scalingfactor = scaling; %FIX: used to be 1e5, but since tol is smaller, different value

    V = [];
    if isempty(P) || isempty(K)
        return;
    end

    np = numel(P);
    nk = numel(K);
    [m,n] = size(model.S);

    % x = [v;z]

    % objective
    f = [zeros(1,n), ones(1,np)];

    % equalities
    Aeq = [model.S, sparse(m,np)];
    beq = zeros(m,1);

    % inequalities
    Ip = sparse(np,n); Ip(sub2ind(size(Ip),(1:np)',P(:))) = 1;
    Ik = sparse(nk,n); Ik(sub2ind(size(Ik),(1:nk)',K(:))) = 1;
    Aineq = sparse([[Ip, -speye(np)]; ...
                    [-Ip, -speye(np)]; ...
                    [-Ik, sparse(nk,np)]]);
    bineq = [zeros(2*np,1); -ones(nk,1)*tol*scalingfactor];

    % bounds
    lb = [model.lb; zeros(np,1)] * scalingfactor;
    ub = [model.ub; max(abs(model.ub(P)),abs(model.lb(P)))] * scalingfactor;

    % Set up problem
    LPproblem.A = [Aeq;Aineq];
    LPproblem.b = [beq;bineq];
    LPproblem.c = f;
    LPproblem.lb = lb;
    LPproblem.ub = ub;
    LPproblem.osense = 1;
    LPproblem.csense(1:m,1) = 'E';
    LPproblem.csense(m+1:length(bineq)+m,1) = 'L';
    
    %FIX: use gurobi as solver
    sol = solveCobraLP(LPproblem);
    if sol.stat == 1
        x = sol.full;    
        %x = cplexlp(f,Aineq,bineq,Aeq,beq,lb,ub);
        V = x(1:n);
    else
        V = zeros(n,1);
    end
end


