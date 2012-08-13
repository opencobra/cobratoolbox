function [MILPproblem] = addLoopLawConstraints(LPproblem, model, rxnIndex)
%addLoopLawConstraints adds loop law constraints to LP problem or MILP problem.
%INPUT
% LPproblem Structure containing the following fields
%  A      LHS matrix
%  b      RHS vector
%  c      Objective coeff vector
%  lb     Lower bound vector
%  ub     Upper bound vector
%  osense Objective sense (-1 max, +1 min)
%  csense Constraint senses, a string containting the constraint sense for
%         each row in A ('E', equality, 'G' greater than, 'L' less than).
%  F (optional)  If *QP problem
%  vartype (optional) if MI*P problem
% model     The model for which the loops should be removed
%
%OPTIONAL INPUT
% rxnIndex The index of variables in LPproblem corresponding to fluxes. 
%     default = [1:n]
%
%
%OUTPUT
% Problem structure containing the following fields describing an MILP problem
% A, b, c, lb, ub - same as before but longer
% vartype - variable type of the MILP problem ('C', and 'B')
% x0 = [] Needed for solveMILPproblem
%
% Jan Schellenberger Sep 27, 2009
%
% different ways of doing it.  I'm still playing with this.
method = 2; % methd = 1 - separete af,ar;  method = 2 - only af;  method 3 - same as method 2 except use b_L, b_U instad of b and csense;
reduce_vars = 1; % eliminates additional integer variables.  Should be faster in all cases but in practice may not be for some weird reason.  
combine_vars = 0; % combines flux coupled reactions into one variable.  Should be faster in all cases but in practice may not be.  

if nargin < 3
   if size(LPproblem.A,2) == size(model.S,2); % if the number of variables matches the number of model reactions
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

MILPproblem = LPproblem;

S = model.S;
[m,n] = size(LPproblem.A);
nontransport = (sum(S ~= 0) > 1)'; %reactions which are not transport reactions.
%nnz(nontransport)
nontransport = (nontransport | (model.lb ==0 & model.ub == 0));
%nnz(nontransport)
%pause;
if reduce_vars == 1
    active1 = ~(model.lb ==0 & model.ub == 0);
    S2 = S(:,active1); % exclude rxns with ub/lb ==0
    
    N2 = sparseNull(sparse(S2));
    N = zeros(length(active1), size(N2,2));
    N(active1,:) = N2;
    %size(N)
    active = any(abs(N) > 1e-6, 2); % exclude rxns not in null space
    %size(active)
    %size(nontransport)
    nontransport = nontransport & active;
end

Sn = S(:,nontransport);

Ninternal = sparseNull(sparse(Sn));
%max(max(abs(Ninternal)))
%pause
linternal = size(Ninternal,2);

nint = length(find(nontransport));
temp = sparse(nint, n);
temp(:, rxnIndex(nontransport)) = speye(nint);


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

    MILPproblem.vartype = [];
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
        zeros(linternal,1);];

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

if combine_vars && method == 2
%    MILPproblem
    %pause;
    Ns = N(nontransport,:);
    %full(Ns)
    %pause;
    %Ns = sparseNull(S(:,nontransport));
    %size(Ns)
    Ns2 = Ns;
    for i = 1:size(Ns2,1)
        m = sqrt(Ns2(i,:)*Ns2(i,:)');
        Ns2(i,:) = Ns2(i,:)/m;
    end
    %min(m)
    t = Ns2 * Ns2';
%     size(t)
     %spy(t> .99995 | t < -.99995);
    %full(t)
     %pause;
     %t = corrcoef([Ns, sparse(size(Ns,1),1)]');
     %full(t)
%     size(t)
     %spy(t> .99995 | t < -.99995);
     %pause;
    cutoff = .9999999;
    %[m1, m2] = find(t>.99 & t < .999);
    %for i = 1:length(m1)
%         t(m1(i), m2(i))
%         [m1(i), m2(i)]
%         [Ns(m1(i),:); Ns(m2(i),:)]
%         corr(Ns(m1(i),:)', Ns(m2(i),:)')
%         pause;
    %end
    %pause;
    t2 = sparse(size(t,1), size(t, 2));
    t2(abs(t) > cutoff) = t(abs(t) > cutoff);
    t = t2;
    checkedbefore = zeros(nint,1);    

    for i = 2:nint
        x = find(t(i,1:i-1)>cutoff);
        if ~isempty(x)
            checkedbefore(i) = x(1);
        end
        y = find(t(i,1:i-1)<-cutoff);
        if ~isempty(y)
            checkedbefore(i) = -y(1);
        end
        if ~isempty(x) && ~isempty(y);
            if x(1) < y(1)
                checkedbefore(i) = x(1);
            else
                checkedbefore(i) = -y(1);
            end
        end
    end
    %sum(checkedbefore ~= 0) 
    %pause;
    %[find(nontransport)', (1:length(checkedbefore))', checkedbefore]
    %nint
    %checkedbefore
    %checkedbefore(55) 
    %    t(55,29)

    %pause;
    %checkedbefore(56:end) = 0;
    offset = size(LPproblem.A, 2);
    for i = 1:length(checkedbefore)
        if checkedbefore(i) ==0
            continue;
        end
        pretarget = abs(checkedbefore(i)); % variable that this one points to.
 %       [pretarget,i]
        if checkedbefore(i) > 0
            if any(MILPproblem.A(:,offset+pretarget).*MILPproblem.A(:,offset+i))
                display('trouble combining vars'),pause;
            end
            MILPproblem.A(:,offset+pretarget) = MILPproblem.A(:,offset+pretarget) + MILPproblem.A(:,offset+i);
        else
            MILPproblem.A(:,offset+pretarget) = MILPproblem.A(:,offset+pretarget) - MILPproblem.A(:,offset+i);
            MILPproblem.b = MILPproblem.b - MILPproblem.A(:,offset+i);
        end
    end
    %markedfordeath = offset + find(checkedbefore > .5);
    markedforlife = true(size(MILPproblem.A,2), 1);
    markedforlife(offset + find(checkedbefore > .5)) = false;
%    size(markedforlife)
    MILPproblem.markedforlife = markedforlife;
    MILPproblem.A = MILPproblem.A(:,markedforlife);
    MILPproblem.c = MILPproblem.c(markedforlife);
    MILPproblem.vartype = MILPproblem.vartype(markedforlife);
    MILPproblem.lb = MILPproblem.lb(markedforlife);
    MILPproblem.ub = MILPproblem.ub(markedforlife);
%    MILPproblem.nontransport = full(double(nontransport))';
%    MILPproblem.energies = zeros(size(MILPproblem.A,2), 1);
%    MILPproblem.energies((end-nint+1):end) = 1;
%    MILPproblem.checkedbefore = checkedbefore;
%     MILPproblem.as = zeros(size(MILPproblem.A,2), 1);
%     MILPproblem.as((offset+1):(offset+nint)) = 1;
    %pause;
end
