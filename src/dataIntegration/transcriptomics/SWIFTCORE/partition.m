function component = partition(model, solver, algorithm)
% swiftcc++ and fastcc++ augment swiftcc and fastcc by this preprocess
%
% USAGE:
%
%    component = partition(model, solver, algorithm)
%
% INPUTS:
%    model:        the metabolic network reconstruction
%                    * .S - the associated sparse stoichiometric matrix
%                    * .lb - feasible flux distribution lower bound
%                    * .ub - feasible flux distribution uppper bound
%                    * .rxns - cell array of reaction abbreviations
%                    * .rev - the 0-1 indicator vector of the reversible reactions
%    solver:       the LP solver to be used; the currently available options 
%                  are 'gurobi', 'linprog', and 'cplex' with the default value 
%                  of 'linprog'. It fallbacks to the COBRA LP solver interface 
%                  if another supported solver is called.
%    algorithm:    the backend algorithm to be utilized between 'swift' and 'fast'
%
% OUTPUT:
%    component:    the index set of the reactions constituting the maximum  
%                  flux consistent metabolic subnetwork
%
% NOTE:
%
%    requires bioinformatics toolbox
%
% .. Authors:
%       - Mojtaba Tefagh, Stephen P. Boyd, 2019, Stanford University

    assert(license('test', 'bioinformatics_toolbox') == 1, ...
        'The required Bioinformatics toolbox is not available!');
    S = model.S;
    rev = model.rev;
    lb = model.lb;
    ub = model.ub;
    c = model.c;
    rxns = model.rxns;
    [m, n] = size(S);
    
    %% constructing the directed graph
    DG = zeros(m+1);
    for i = 1:n
        head = S(:, i) > 0;
        if ~any(head)
            head = m+1;
        end
        tail = S(:, i) < 0;
        if ~any(tail)
            tail = m+1;
        end
        DG(head, tail) = 1;
        if rev(i)
            DG(tail, head) = 1;
        end
    end
    
    %% finding strongly or weakly connected components in the graph
    DG = sparse(DG);
    [~, C] = graphconncomp(DG, 'Directed', true);
    C = C(1:end-1);
    
    %% finding weakly connected components in the graph
    if range(C) == 0
        [~, C] = graphconncomp(max(DG, DG.'), 'Directed', false);
        C = C(1:end-1);
    end
    
    %% partitioning the metabolic network
    component = zeros(n, 1);
    for i = 1:n
        v = C(S(:, i) ~= 0);
        component(i) = all(v == v(1))*v(1);
    end
    if range(component) == 0
        component = zeros(n, 1);
        if strcmp(algorithm, 'fast')
            component(fastcc(model, 1e-4)) = 1;
        elseif strcmp(algorithm, 'swift')
            component(swiftcc(S, rev, solver)) = 1;
        end
    else
        newcomponent = zeros(n, 1);
        for i = unique(component).'
            core = component == i;
            if sum(core) > 1
                model.S = S(:, core);
                model.rev = rev(core);
                model.lb = lb(core);
                model.ub = ub(core);
                model.c = c(core);
                model.rxns = rxns(core);
                newcomponent(core) = partition(model, solver, algorithm);
            end
        end
        component = newcomponent;
    end
end