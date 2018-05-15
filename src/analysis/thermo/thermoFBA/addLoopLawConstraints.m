function [MILPproblem] = addLoopLawConstraints(LPproblem, model, rxnIndex, method, reduce_vars)
% Adds loop law constraints to LP problem or MILP problem.
%
% USAGE:
%
%    [MILPproblem] = addLoopLawConstraints(LPproblem, model, rxnIndex)
%
% INPUTS:
%    LPproblem:      Structure containing the following fields:
%
%                      * A - LHS matrix
%                      * b - RHS vector
%                      * c - Objective coeff vector
%                      * lb - Lower bound vector
%                      * ub - Upper bound vector
%                      * osense - Objective sense (-1 max, +1 min)
%                      * csense - Constraint senses, a string containting the constraint sense for
%                        each row in A ('E', equality, 'G' greater than, 'L' less than).
%                      * F - (optional) If `*QP` problem
%                      * vartype - (optional) if `MI*P` problem
%    model:          The model for which the loops should be removed
%
% OPTIONAL INPUT:
%    rxnIndex:       The index of variables in LPproblem corresponding to fluxes. Default = `[1:n]`
%    method:         Indicator which method to use:
%                    * 1 - Two variables for each reaction af, ar
%                    * 2 - One variable for each reaction af (default)
%    reduce_vars:    eliminates additional integer variables.  Should be faster in all cases but in practice may not be for some weird reason (default : true).
%
% OUTPUT:
%    MILPproblem:    Problem structure containing the following fields describing an MILP problem:
%
%                      * A, b, c, lb, ub - same as before but longer
%                      * vartype - variable type of the MILP problem ('C', and 'B')
%                      * `x0 = []` - Needed for `solveMILPproblem`
%
% .. Author: - Jan Schellenberger Sep 27, 2009

if ~exist('method','var')
    method = 2;
end
if ~exist('reduce_vars','var')
    reduce_vars = 1;
end


% different ways of doing it.  I'm still playing with this.
if nargin < 3
    if size(LPproblem.A,2) == size(model.S,2) % if the number of variables matches the number of model reactions
        rxnIndex = 1:size(model.S,2);
    elseif size(LPproblem.A,2) > size(model.S,2)
        display('warning:  extra variables in LPproblem.  will assume first n correspond to v')
        rxnIndex = 1:size(model.S,2);
    else
        display('LPproblem must have at least as many variables as model has reactions');
        return;
    end
elseif length(find(rxnIndex)) ~= size(model.S,2)
    display('rxnIndex must contain exactly n entries');
    return;
end
if any(rxnIndex > size(LPproblem.A,2))
    display('rxnIndex out of bounds');
    return;
end

% Perhaps this should be moved before the "different ways of doing this" -
% line 47, so the function will not crash retuning an undefined value?
% Either that, or change the display/return to error?
MILPproblem = LPproblem;

S = model.S;
[m,n] = size(LPproblem.A);

if ~isfield(model,'SIntRxnBool')
    model = findSExRxnInd(model);
end
isInternal = model.SIntRxnBool; % internal, presumably mass balanced reactions

if reduce_vars == 1
    active = ~(model.lb ==0 & model.ub == 0);
    S2 = S(:,active); % exclude rxns with ub/lb ==0
    
    N2 = sparseNull(sparse(S2));
    N = zeros(length(active), size(N2,2));
    N(active,:) = N2;
    %size(N)
    active = active & any(abs(N) > 1e-6, 2); % exclude rxns not in null space
    %size(active)
    %size(nontransport)
    isInternal = isInternal & active;
end

Sn = S(:,isInternal);

Ninternal = sparseNull(sparse(Sn));
%max(max(abs(Ninternal)))
%pause
linternal = size(Ninternal,2);

nint = length(find(isInternal));
temp = sparse(nint, n);
temp(:, rxnIndex(isInternal)) = speye(nint);


if method == 1 % two variables (ar, af)
    MILPproblem.A = [LPproblem.A, sparse(m,3*nint);   % Ax = b (from original LPproblem)
        temp, -10000*speye(nint), sparse(nint, 2*nint); % v < 10000*af
        temp, sparse(nint, nint), 10000*speye(nint), sparse(nint, nint); % v > -10000ar
        sparse(nint, n), speye(nint), speye(nint), sparse(nint, nint);  % ar + af <= 1
        sparse(nint, n), -100*speye(nint), 1*speye(nint), speye(nint);  % E < 100 af - ar
        sparse(nint, n), -1*speye(nint), 100*speye(nint), speye(nint);  % E > af - 100 ar
        sparse(linternal, n+2*nint), Ninternal']; % N*E = 0
    
    MILPproblem.b = [LPproblem.b;
        zeros(2*nint,1);
        ones(nint,1);
        zeros(2*nint + linternal,1);];
    
    MILPproblem.c = [LPproblem.c;
        zeros(3*nint,1)];
    
    MILPproblem.csense = LPproblem.csense;
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'L';end   % v < 1000*af
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'G';end  % v > -1000ar
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'L';end  % ar + af < 1
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'L';end  % E <
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'G';end  % E >
    for i = 1:linternal, MILPproblem.csense(end+1,1) = 'E';end % N*E = 0
    
    MILPproblem.vartype = '';
    if isfield(LPproblem, 'vartype')
        MILPproblem.vartype = LPproblem.vartype;  % keep variables same as previously.
    else
        for i = 1:n, MILPproblem.vartype(end+1,1) = 'C';end; %otherwise define as continuous (used for all LP problems)
    end
    for i = 1:2*nint, MILPproblem.vartype(end+1,1) = 'B';end;
    for i = 1:nint, MILPproblem.vartype(end+1,1) = 'C';end;
    
    if isfield(LPproblem, 'F') % used in QP problems
        MILPproblem.F = sparse(size(MILPproblem.A,2),   size(MILPproblem.A,2));
        MILPproblem.F(1:size(LPproblem.F,1), 1:size(LPproblem.F,1)) = LPproblem.F;
    end
    
    
    MILPproblem.lb = [LPproblem.lb;
        zeros(nint*2,1);
        -1000*ones(nint,1);];
    MILPproblem.ub = [LPproblem.ub;
        ones(nint*2,1);
        1000*ones(nint,1);];
    
    MILPproblem.x0 = [];
    
elseif method == 2 % One variables (a)
    MILPproblem.A = [LPproblem.A, sparse(m,2*nint);   % Ax = b (from original LPproblem)
        temp, -10000*speye(nint), sparse(nint, nint); % v < 10000*af
        temp, -10000*speye(nint), sparse(nint, nint); % v > -10000 + 10000*af
        sparse(nint, n), -101*speye(nint), speye(nint);  % E < 100 af - ar
        sparse(nint, n), -101*speye(nint), speye(nint);  % E > af - 100 ar
        sparse(linternal, n + nint), Ninternal']; % N*E = 0
    
    MILPproblem.b = [LPproblem.b; % Ax = b (from original problem)
        zeros(nint,1); % v < 10000*af
        -10000*ones(nint, 1); % v > -10000 + 10000*af
        -ones(nint,1); % e<
        -100*ones(nint, 1); % e>
        zeros(linternal,1)];
    
    MILPproblem.c = [LPproblem.c;
        zeros(2*nint,1)];
    
    MILPproblem.csense = LPproblem.csense;
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'L';end   % v < 1000*af
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'G';end  % v > -1000ar
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'L';end  % E <
    for i = 1:nint, MILPproblem.csense(end+1,1) = 'G';end  % E >
    for i = 1:linternal, MILPproblem.csense(end+1,1) = 'E';end % N*E = 0
    
    MILPproblem.vartype = '';
    if isfield(LPproblem, 'vartype')
        MILPproblem.vartype = LPproblem.vartype;  % keep variables same as previously.
    else
        for i = 1:n, MILPproblem.vartype(end+1,1) = 'C';end; %otherwise define as continuous (used for all LP problems)
    end
    for i = 1:nint, MILPproblem.vartype(end+1,1) = 'B';end; % a variables
    for i = 1:nint, MILPproblem.vartype(end+1,1) = 'C';end; % G variables
    
    if isfield(LPproblem, 'F') % used in QP problems
        MILPproblem.F = sparse(size(MILPproblem.A,2),   size(MILPproblem.A,2));
        MILPproblem.F(1:size(LPproblem.F,1), 1:size(LPproblem.F,1)) = LPproblem.F;
    end
    
    
    MILPproblem.lb = [LPproblem.lb;
        zeros(nint,1);
        -1000*ones(nint,1);];
    MILPproblem.ub = [LPproblem.ub;
        ones(nint,1);
        1000*ones(nint,1);];
    
    MILPproblem.x0 = [];
elseif method == 3 % like method 3 except reduced constraints.
    MILPproblem.A = [LPproblem.A, sparse(m,2*nint);   % Ax = b (from original LPproblem)
        temp, -10000*speye(nint), sparse(nint, nint); % -10000 < v -10000*af < 0
        %temp, -10000*speye(nint), sparse(nint, nint); % v > -10000 + 10000*af
        sparse(nint, n), -101*speye(nint), speye(nint);  %  -100 < E - 101 af < -1
        %sparse(nint, n), -101*speye(nint), speye(nint);  % E > af - 100 ar
        sparse(linternal, n + nint), Ninternal']; % N*E = 0
    
    MILPproblem.b_L = [LPproblem.b; % Ax = b (from original problem)
        %zeros(nint,1); % v < 10000*af
        -10000*ones(nint, 1); % v > -10000 + 10000*af
        %-ones(nint,1); % e<
        -100*ones(nint, 1); % e>
        zeros(linternal,1);];
    MILPproblem.b_U = [LPproblem.b; % Ax = b (from original problem)
        zeros(nint,1); % v < 10000*af
        %-10000*ones(nint, 1); % v > -10000 + 10000*af
        -ones(nint,1); % e<
        %-100*ones(nint, 1); % e>
        zeros(linternal,1);];
    
    MILPproblem.b_L(find(LPproblem.csense == 'E')) = LPproblem.b(LPproblem.csense == 'E');
    MILPproblem.b_U(find(LPproblem.csense == 'E')) = LPproblem.b(LPproblem.csense == 'E');
    MILPproblem.b_L(find(LPproblem.csense == 'G')) = LPproblem.b(LPproblem.csense == 'G');
    MILPproblem.b_U(find(LPproblem.csense == 'G')) = inf;
    MILPproblem.b_L(find(LPproblem.csense == 'L')) = -inf;
    MILPproblem.b_U(find(LPproblem.csense == 'L')) = LPproblem.b(LPproblem.csense == 'L');
    
    MILPproblem.c = [LPproblem.c;
        zeros(2*nint,1)];
    
    MILPproblem.csense = [];
    
    MILPproblem.vartype = [];
    if isfield(LPproblem, 'vartype')
        MILPproblem.vartype = LPproblem.vartype;  % keep variables same as previously.
    else
        for i = 1:n, MILPproblem.vartype(end+1,1) = 'C';end; %otherwise define as continuous (used for all LP problems)
    end
    for i = 1:nint, MILPproblem.vartype(end+1,1) = 'B';end; % a variables
    for i = 1:nint, MILPproblem.vartype(end+1,1) = 'C';end; % G variables
    
    if isfield(LPproblem, 'F') % used in QP problems
        MILPproblem.F = sparse(size(MILPproblem.A,2),   size(MILPproblem.A,2));
        MILPproblem.F(1:size(LPproblem.F,1), 1:size(LPproblem.F,1)) = LPproblem.F;
    end
    
    
    MILPproblem.lb = [LPproblem.lb;
        zeros(nint,1);
        -1000*ones(nint,1);];
    MILPproblem.ub = [LPproblem.ub;
        ones(nint,1);
        1000*ones(nint,1);];
    
    MILPproblem.x0 = [];
else
    display('method not found')
    method
    pause;
end

end
