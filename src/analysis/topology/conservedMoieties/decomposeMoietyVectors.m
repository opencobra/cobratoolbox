function D = decomposeMoietyVectors(L, N)
% Decomposes moiety vectors for a metabolic network.
%
% USAGE:
%
%    D = decomposeMoieties(L, N);
%
% INPUTS:
%    L:    The `m x r` moiety matrix with moiety vectors as columns.
%    N:    The `m x u` internal stoichiometric matrix such that :math:`N^T L = 0`.
%
% OUTPUTS:
%    D:    An `m x t` moiety matrix with decomposed moiety vectors as columns :math:`(t \geq r)`.
%
% .. Author: - Hulda S. Haraldsdóttir, June 2015

D = []; % Initialise variables
Lp = L;
rp = size(Lp,2);

% Decompose moiety vectors
while rp > 0 % Iterate since decomposed moiety vectors might themselves be decomposable

    Lpp = [];  % new possibly decomposable moiety vectors
    D2 = [];  % new non-decomposable moiety vectors 
    for k = 1:rp
        l  = full(Lp(:,k)); % Moiety vector k

        % Reduce the size of the problem by eliminating metabolites that do
        % not contain moiety k
        c = l;
        mbool = c ~= 0;
        rbool = any(N(mbool,:),1);
        c = c(mbool);

        % Formulate MILP problem
        P.A = [N(mbool,rbool)'; ...                                       Np' * a = 0
               sparse(ones(numel(c), 1), 1:numel(c), 1, 1, numel(c))];  % sum(a) >= 1 
        P.b = [zeros(sum(rbool), 1); 1];
        P.c = ones(size(c));                                            % min sum(a)
        P.lb = zeros(size(P.A, 2), 1);
        P.ub = c;                                                       % bounded by Lp(:, k)
        P.osense = 1;
        P.csense = [repmat('E', sum(rbool), 1); 'G'];
        P.vartype = repmat('I', size(P.A, 2), 1);
        P.x0 = c;

        % Run MILP
        solution = solveCobraMILP(P);


        % Collect the components of l into a and b.
        a = zeros(size(l));
        b = zeros(size(l));

        if solution.stat == 1
            solution.full = round(solution.full);
            a(mbool) = solution.full(1:length(c));
            b(mbool) = c - a(mbool);
        end

        if any(a) && ~any(N'*a)  % normally must be true
            D2 = [D2, a];  % 'a' must be nondecomposable
        end
        if any(b) && ~any(N'*b)
            Lpp = [Lpp b]; % b is nonzero, may be decomposable
        end
    end

    D = [D D2]; % Nondecomposable moieties
    Lp = Lpp; % New moieties that may be decomposable
    rp = size(Lp,2);
end
D = unique(D','rows','stable')'; % Eliminate duplicates
