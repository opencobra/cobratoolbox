function D = decomposeMoietyVectors(L,N)
% Decompose moiety vectors for a metabolic network.
% 
% D = decomposeMoieties(L,N);
% 
% INPUTS
% L ... The m x r moiety matrix with moiety vectors as columns.
% N ... The m x u internal stoichiometric matrix such that N'*L = 0.
% 
% OUTPUTS
% D ... An m x t moiety matrix with decomposed moiety vectors as columns
%       (t >= r).
% 
% June 2015, Hulda S. Haraldsdóttir

% Initialise variables
D = [];
Lp = L;
rp = size(Lp,2);

% Decompose moiety vectors
while rp > 0 % Iterate since decomposed moiety vectors might themselves be decomposable
    
    Lpp = [];
    cols = [];
    
    for k = 1:rp
        l  = full(Lp(:,k)); % Moiety vector k
        
        % Reduce the size of the problem by eliminating metabolites that do
        % not contain moiety k 
        c = l;
        mbool = c ~= 0;
        rbool = any(N(mbool,:));
        c = c(mbool);
        Np = N(mbool,rbool);
        
        % Formulate MILP problem
        Sigma = [diag(ones(size(c))) diag(ones(size(c)))];
        suma = [ones(size(c)); zeros(size(c))]';
        sumb = [zeros(size(c)); ones(size(c))]';
        
        P.A = sparse([Np' zeros(size(Np')); zeros(size(Np')) Np'; Sigma; sumb; suma; sumb]);
        P.b = [zeros(size(Np,2),1); zeros(size(Np,2),1); c; sum(c) - 1; 1; 1];
        P.c = suma';
        P.lb = zeros(size(P.A,2),1);
        P.ub = inf*ones(size(P.A,2),1);
        P.osense = 1;
        P.csense = [repmat('E', 2*size(Np,2) + length(c), 1); 'L'; 'G'; 'G'];
        P.vartype = repmat('I', size(P.A,2), 1);
        P.x0 = suma*[c; c];
        
        % Run MILP
        solution = solveCobraMILP(P);

        
        % Collect the components of l into a and b.
        a = zeros(size(l));
        b = zeros(size(l));
        
        if solution.stat == 1
            solution.full = round(solution.full);
            a(mbool) = solution.full(1:length(c));
            b(mbool) = solution.full(length(c)+1:end);
        end
        
        if any(a) && ~any(N'*a)
            Lpp = [Lpp a];
            cols = [cols; k];
        end
        if any(b) && ~any(N'*b)
            Lpp = [Lpp b];
            cols = [cols; k];
        end
    end
    
    D = [D Lp(:,setdiff(1:size(Lp,2),cols))]; % Nondecomposable moieties
    Lp = Lpp; % New moieties that may be decomposable
    rp = size(Lp,2);
end

D = unique(D','rows','stable')'; % Eliminate duplicates
