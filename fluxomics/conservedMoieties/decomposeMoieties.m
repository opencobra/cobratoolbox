function D = decomposeMoieties(L,S,intRxnBool)
% Decompose conserved metabolic moieties represented as nonnegative integer
% vectors in the left null space of S.
% 
% D = decomposeMoieties(L,S,intRxnBool);
% 
% INPUTS
% L          ... An o x m matrix where each row represents a moiety.
% S          ... An m x n stoichiometric matrix.
% intRxnBool ... An n x 1 logical array indicating which reactions in S
%                are internal. If omitted, all reactions involving more
%                than one metabolite will be considered internal.
% 
% OUTPUTS
% D          ... A u x m matrix, with u >= o, where each row represents a
%                decomposed moiety. 

% Format inputs
if nargin < 3 || isempty(intRxnBool)
    intRxnBool = (sum(full(S) ~= 0) > 1)'; % Only single metabolite exchanges considered external
end

S0 = S(:,intRxnBool);
D0 = L;
D = [];

% Decompose moieties
while ~isempty(D0) % Iterate since decomposed moieties might themselves be decomposable
    
    N = [];
    rows = [];
    
    for i = 1:size(D0,1)
        l  = full(D0(i,:))'; % Moiety i
        
        % Reduce size of problem by eliminating metabolites that are not
        % included in the moiety
        c = l;
        mbool = c ~= 0;
        rbool = any(S0(mbool,:))';
        c = c(mbool);
        S = S0(mbool,rbool);
        Sigma = [diag(ones(size(c))) diag(ones(size(c)))];
        suma = [ones(size(c')) zeros(size(c'))];
        sumb = [zeros(size(c')) ones(size(c'))];
        
        % Formulate MILP problem
        Sigma = [diag(ones(size(c))) diag(ones(size(c)))];
        suma = [ones(size(c')) zeros(size(c'))];
        sumb = [zeros(size(c')) ones(size(c'))];
        
        milpModel.A = sparse([S' zeros(size(S')); zeros(size(S')) S'; Sigma; sumb; suma; sumb]);
        milpModel.sense = [repmat('=', 2*size(S,2) + length(c), 1); '<'; '>'; '>'];
        milpModel.vtype = 'I';
        milpModel.rhs = [zeros(size(S,2),1); zeros(size(S,2),1); c; sum(c) - 1; 1; 1];
        milpModel.obj = suma';
        milpModel.modelsense = 'min';
        
        params.outputflag = 0;
        
        % Run MILP
        result = gurobi(milpModel,params);
        
        % Collect the components of l into a and b.
        a = zeros(size(l'));
        b = zeros(size(l'));
        
        if strcmp(result.status,'OPTIMAL')
            a(mbool) = result.x(1:length(c));
            b(mbool) = result.x(length(c)+1:end);
        elseif ~strcmp(result.status,'INFEASIBLE')
            fprintf('%s\n',result.status);
        end
        
        if any(a)
            N = [N; a];
            rows = [rows; i];
        end
        if any(b)
            N = [N; b];
            rows = [rows; i];
        end
    end
    
    D = [D; D0(setdiff(1:size(D0,1),rows),:)]; % Nondecomposable moieties
    D0 = N; % New moieties that may be decomposable
end

% Eliminate duplicates and scalar multiples
D = unique(D,'rows');

for i = fliplr(1:(size(D,1)))
    
    l = D(i,:);
    D_diff = D(setdiff(1:size(D,1),i),:);
    
    if ~all(any(mod(D_diff,repmat(l,size(D_diff,1),1)),2))
        D = D_diff;
    end
end
