function [solution] = relaxFBA_cappedL1(model, param)
% Finds the mimimal set of relaxations on bounds and steady state constraints to make the FBA problem feasible.
% The zero-norm is appproximated by capped-L1 norm
%
% USAGE:
%
%    [solution] = relaxFBA_cappedL1(model, param)
%
% INPUTS:
%    model:          COBRA model structure
%    param:    Structure containing the relaxation options:
%
%                      * excludedReactions - bool vector of size n indicating the reactions to be excluded from relaxation
%                        * excludedReactions(i) = false : allow to relax bounds on reaction i
%                        * excludedReactions(i) = true : do not allow to relax bounds on reaction i
%
%                      * excludedReactionLB - n x 1 bool vector indicating the reactions with lower bounds to be excluded from relaxation
%
%                        * excludedReactionLB(i) = false : allow to relax lower bounds on reaction i (default)
%                        * excludedReactionLB(i) = true : do not allow to relax lower bounds on reaction i 
%
%                      * excludedReactionUB - n x 1 bool vector indicating the reactions with upper bounds to be excluded from relaxation
%
%                        * excludedReactionUB(i) = false : allow to relax upper bounds on reaction i (default)
%                        * excludedReactionUB(i) = true : do not allow to relax upper bounds on reaction i 
%
%                      * excludedMetabolites - bool vector of size m indicating the metabolites to be excluded from relaxation
%                        * excludedMetabolites(i) = false : allow to relax steady state constraint on metabolite i
%                        * excludedMetabolites(i) = true : do not allow to relax steady state constraint on metabolite i
%
%                      * gamma - weight on zero norm of fluxes 
%                      * lamda - weight on relaxation on steady state constraint (overridden by excludedMetabolites)
%                      * alpha - weight on relaxation on bounds (overridden by excludedReactions)
%
% OUTPUT:
%    solution:       Structure containing the following fields:
%
%                      * stat - status
%
%                        * 1  = Solution found
%                        * 0  = Infeasible
%                        * -1 = Invalid input
%                      * r - relaxation on steady state constraints :math:`S*v = b`
%                      * p - relaxation on lower bound of reactions
%                      * q - relaxation on upper bound of reactions
%                      * v - reaction rate
%
% .. math::
%      min  ~&~ c^T v + \gamma_1 ||v||_1 + \gamma_0 ||v||_0 + \lambda_1 ||r||_1 + \lambda_0 ||r||_0 \\
%           ~&~   + \alpha_1 (||p||_1 + ||q||_1) + \alpha_0 (||p||_0 + ||q||_0) \\
%      s.t. ~&~ S v + r = b \\
%           ~&~ l - p \leq v \leq u + q \\
%           ~&~ r \in R^m \\
%           ~&~ p,q \in R_+^n
%
% `m` - number of metabolites,
% `n` - number of reactions
%
% .. Author: - Hoai Minh Le	20/11/2015

[m,n] = size(model.S); %Check inputs

if ~isfield(param,'maxUB')
    param.maxUB = max(max(model.ub),-min(model.lb));
end
if ~isfield(param,'maxLB')
    param.minLB = min(-max(model.ub),min(model.lb));
end
if ~isfield(param,'maxRelaxR')
    param.maxRelaxR = 1000; %TODO - check this for multiscale models
end
if ~isfield(param,'printLevel')
    param.printLevel = 0; %TODO - check this for multiscale models
end

stop = false;
solution.stat = 1;


if exist('param','var')
    if isfield(param,'excludedReactions') == 0
        param.excludedReactions = false(n,1);
    end
    if isfield(param,'excludedReactionLB') == 0
        param.excludedReactionLB = false(n,1);
    end
    if isfield(param,'excludedReactionUB') == 0
        param.excludedReactionUB = false(n,1);
    end
    if isfield(param,'excludedMetabolites') == 0
        param.excludedMetabolites = false(m,1);
    end

    if isfield(param,'nbMaxIteration') == 0
        param.nbMaxIteration = 1000;
    end

    if isfield(param,'epsilon') == 0
        feasTol = getCobraSolverParams('LP', 'feasTol');
        param.epsilon = feasTol*100;
    end

    if isfield(param,'gamma0') == 0
        param.gamma0 = 0;    %trade-off parameter of l0 part v
    end

    if isfield(param,'gamma1') == 0
        %Small positive penalty seems to be important to ensure algorithm
        %is numerically stable for small networks.
        %TODO: why?
        param.gamma1 = 1e-6;     %trade-off parameter of l1 part v
    end

    if isfield(param,'lambda0') == 0
        param.lambda0 = 10;   %trade-off parameter of l0 part of r
    end

    if isfield(param,'lambda1') == 0
        param.lambda1 = 1;    %trade-off parameter of l1 part of r
    end

    if isfield(param,'alpha0') == 0
        param.alpha0 = 10;   %trade-off parameter of l0 part of p and q
    end

    if isfield(param,'alpha1') == 0
        param.alpha1 = 1;    %trade-off parameter of l1 part of p and q
    end

    if isfield(param,'epsilon') == 0
        param.epsilon = 10e-6; %stopping criterion
    end

    if isfield(param,'theta') == 0
        param.theta   = 0.5; %parameter of capped l1 approximation
    end
end

if 0
    param
end

[nbMaxIteration,epsilon,theta]      = deal(param.nbMaxIteration,param.epsilon,param.theta);
[gamma0,gamma1]                     = deal(param.gamma0,param.gamma1);
[lambda0,lambda1]                   = deal(param.lambda0,param.lambda1);
[alpha0,alpha1]                     = deal(param.alpha0,param.alpha1);


if ~isfield(model,'csense')
    % If csense is not declared in the model, assume that all constraints are equalities.
    fprintf('%s\n','csense is not defined. We assume that all constraints are equalities.')
    csense(1:m,1) = 'E';
else
    if length(model.csense)~=m
        warning('Length of csense is invalid! Defaulting to equality constraints.')
        csense(1:m,1) = 'E';
    else
        model.csense = columnVector(model.csense);
        csense = model.csense;
    end
end


%Parameters
nbIteration = 0;
stop = false;
one_over_theta = 1/theta;

% Variable x = (v,r,p,q)
if 0 %Minh
    v   = zeros(n,1);
    r   = zeros(m,1);
    p   = zeros(n,1);
    q   = zeros(n,1);
else %Ronan random starting points
    v   = rand(n,1);
    r   = rand(m,1);
    p   = rand(n,1);
    q   = rand(n,1);
end

obj_old = relaxFBA_cappedL1_obj(model,v,r,p,q,param);

%DCA
while nbIteration < nbMaxIteration && stop ~= true
    
    x_old = [v;r;p;q];
    
    if 1
        %Compute x_bar=(v_bar,r_bar,p_bar,q_bar) which belongs to subgradient of second DC component
        if 0
            %Minh - maximise
            v_bar  = sign(v)*(gamma1 + gamma0*theta);
        else
            %Ronan - minimise
            v_bar  = -sign(v)*gamma1;
            v(abs(v) < one_over_theta) = 0;
            v_bar = v_bar + sign(v)*gamma0*theta;
        end
        
        r_bar  = -sign(r)*lambda1;
        r(abs(r) < one_over_theta) = 0;
        r_bar = r_bar + sign(r)*lambda0*theta;
        
        p_bar  = -sign(p)*alpha1;
        p(p < one_over_theta) = 0;
        p_bar = p_bar + sign(p)*alpha0*theta;
        
        q_bar  = -sign(q)*alpha1;
        q(q < one_over_theta) = 0;
        q_bar = q_bar + sign(q)*alpha0*theta;
    else
        %Ronan - mimics sparseLP_cappedL1
        v_bar  = sign(v)*gamma1;
        v(abs(v) < one_over_theta) = 0;
        v_bar = v_bar + sign(v)*gamma0*theta;

        r_bar  = sign(r)*lambda1;
        r(abs(r) < one_over_theta) = 0;
        r_bar = r_bar + sign(r)*lambda0*theta;
        
        p_bar  = sign(p)*alpha1;
        p(p < one_over_theta) = 0;
        p_bar = p_bar + sign(p)*alpha0*theta;
        
        q_bar  = sign(q)*alpha1;
        q(q < one_over_theta) = 0;
        q_bar = q_bar + sign(q)*alpha0*theta;
    end
    
    %Solve the sub-linear program to obtain new x
    [v,r,p,q,LPsolution] = relaxFBA_cappedL1_solveSubProblem(model,csense,param,v_bar,r_bar,p_bar,q_bar);
    %disp([v,p,q])
    %disp('-')
    %disp(r)
    switch LPsolution.stat
        case 0
            solution.v = [];
            solution.r = [];
            solution.p = [];
            solution.q = [];
            solution.stat = 0;
            warning('Problem infeasible !');
            break
        case 2
            solution.v = [];
            solution.r = [];
            solution.p = [];
            solution.q = [];
            solution.stat = 2;
            error('Problem unbounded !');
        case 1
            %Check stopping criterion
            x = [v;r;p;q];
            error_x = norm(x - x_old);
            obj_new = relaxFBA_cappedL1_obj(model,v,r,p,q,param);
            error_obj = abs(obj_new - obj_old);
            if (error_x < epsilon) || (error_obj < epsilon)
                stop = true;
            else
                obj_old = obj_new;
            end
            if theta < 1000
                  theta = theta * 1.5;
            end
            nbIteration = nbIteration + 1;

            if param.printLevel>0
                if nbIteration==1
                    fprintf('%5s%12.3s%18s%18s%18s%10s%10s%10s%10s\n','itn','obj','err(x)','err(obj)','obj','card(v)','card(r)','card(p)','card(q)');
                end
                    fprintf('%5u%12.3g%12.5g%12.5g%12.5g%10u%10u%10u%10u\n',nbIteration,obj_new,error_x,error_obj,obj_new,nnz(v),nnz(r),nnz(p),nnz(q));
            end
%             disp(strcat('DCA - Iteration: ',num2str(nbIteration)));
%             disp(strcat('Obj:',num2str(obj_new)));
%             disp(strcat('Stopping criteria error: ',num2str(min(error_x,error_obj))));
%             disp('=================================');
        end
end

if solution.stat == 1
    solution.v = v;
    solution.r = r;
    solution.p = p;
    solution.q = q;
end

end

function [v,r,p,q,solution] = relaxFBA_cappedL1_solveSubProblem(model,csense,param,v_bar,r_bar,p_bar,q_bar)

    [S,b,lb,ub,c]                       = deal(model.S,model.b,model.lb,model.ub,model.c);
    [minLB,maxUB]                       = deal(param.minLB,param.maxUB);
    [theta]                             = deal(param.theta);
    [gamma0,gamma1]                     = deal(param.gamma0,param.gamma1);
    [lambda0,lambda1]                   = deal(param.lambda0,param.lambda1);
    [alpha0,alphal1]                    = deal(param.alpha0,param.alpha1);
    excludedReactions                   = deal(param.excludedReactions);
    excludedReactionLB                   = deal(param.excludedReactionLB);
    excludedReactionUB                   = deal(param.excludedReactionUB);
    excludedMetabolites                 = deal(param.excludedMetabolites);
    toBeUnblockedReactions              = deal(param.toBeUnblockedReactions);

    [m,n] = size(S);

    % Define LP
    % Variables [v r p q t w]
    obj = [c-v_bar; -r_bar; alpha0*theta*ones(n,1)-p_bar; alpha0*theta*ones(n,1)-q_bar; gamma0*ones(n,1); lambda0*ones(m,1)];%why no theta for gamma0 and lambda0?

    % Constraints
    %       Sv + r <=> b
    A = [S  speye(m,m)  sparse(m,n) sparse(m,n) sparse(m,n) sparse(m,m)];
    rhs = b;
    sense = csense;


    % Constraint  v + p  >= lb
    A1 = [speye(n,n)    sparse(n,m) speye(n,n)  sparse(n,n) sparse(n,n) sparse(n,m)];
    rhs1 = model.lb;
    sense1 = repmat('G', n, 1);

    A = [A; A1];
    rhs = [rhs; rhs1];
    sense = [sense; sense1];

    % Constraint v - q <= ub
    A2 = [speye(n,n)    sparse(n,m) sparse(n,n) -speye(n,n) sparse(n,n) sparse(n,m)];
    rhs2 = model.ub;
    sense2 = repmat('L', n, 1);

    A = [A; A2];
    rhs = [rhs; rhs2];
    sense = [sense; sense2];

    % Constraint theta*v - t <= 0
    %A3 = [theta*speye(n,n)  sparse(n,m) sparse(n,n) sparse(n,n) -speye(n,n) sparse(n,m)];%Minh
    % Constraint v - t <= 0
    A3 = [speye(n,n)  sparse(n,m) sparse(n,n) sparse(n,n) -speye(n,n) sparse(n,m)];
    rhs3 = zeros(n,1);
    sense3 = repmat('L', n, 1);

    A = [A; A3];
    rhs = [rhs; rhs3];
    sense = [sense; sense3];

    % Constraint -theta*v - t <= 0
    % A4 = [-theta*speye(n,n)  sparse(n,m) sparse(n,n) sparse(n,n) -speye(n,n) sparse(n,m)];%Minh
    % Constraint -*v - t <= 0
    A4 = [-speye(n,n)  sparse(n,m) sparse(n,n) sparse(n,n) -speye(n,n) sparse(n,m)];
    rhs4 = zeros(n,1);
    sense4 = repmat('L', n, 1);

    A = [A; A4];
    rhs = [rhs; rhs4];
    sense = [sense; sense4];

    % Constraint r - w <= 0
    A5 = [sparse(m,n)  speye(m,m) sparse(m,n) sparse(m,n) sparse(m,n)   -speye(m,m) ];
    rhs5 = zeros(m,1);
    sense5 = repmat('L', m, 1);

    A = [A; A5];
    rhs = [rhs; rhs5];
    sense = [sense; sense5];

    % Constraint -r - w <= 0
    A6 = [sparse(m,n)  -speye(m,m) sparse(m,n) sparse(m,n) sparse(m,n)   -speye(m,m) ];
    rhs6 = zeros(m,1);
    sense6 = repmat('L', m, 1);

    A = [A; A6];
    rhs = [rhs; rhs6];
    sense = [sense; sense6];

    %Contraints on toBeUnblockedReactions
    if any(toBeUnblockedReactions) % Only add the constraint if toBeUnblockedReactions is not an all zero vector
        D = sparse(n,n);
        D(1:n+1:end) = (toBeUnblockedReactions ~= 0);

        A7 = [D  sparse(n,m) sparse(n,n) sparse(n,n) sparse(n,n)   sparse(n,m) ];
        rhs7 = zeros(n,1);
        rhs7(toBeUnblockedReactions == 1) = 1e-4;
        rhs7(toBeUnblockedReactions == -1) = -1e-4;
        sense7 = repmat('G', n, 1);
        sense7(toBeUnblockedReactions == -1) = 'L';

        A = [A; A7];
        rhs = [rhs; rhs7];
        sense = [sense; sense7];
    end

    if isfield(model,'C')
        [nIneq,nltC]=size(model.C);
        A8 = [model.C  sparse(nIneq,m) sparse(nIneq,n) sparse(nIneq,n) sparse(nIneq,n)   sparse(nIneq,m) ];
        rhs8 = model.d;
        sense8 = model.dsense;
        
        A = [A; A8];
        rhs = [rhs; rhs8];
        sense = [sense; sense8];
    end
    
    % Variables [v r p q t w]

    lb1 = lb;
    ub1 = ub;
    if 0
        lb1(~excludedReactions) = minLB;
        ub1(~excludedReactions) = maxUB;
    else
        lb1(~excludedReactionLB) = minLB;
        ub1(~excludedReactionUB) = maxUB;
    end
    
    maxRelaxR=param.maxRelaxR;
    
    %Minh - lead to infeasible problems, due to l > u.
    %l = [lb1; -maxRelaxR*ones(m,1);            zeros(n,1);         zeros(n,1);               ones(n,1);          zeros(m,1)];
    %u = [ub1;  maxRelaxR*ones(m,1);   -minLB*ones(n,1)+lb; maxUB*ones(n,1)-ub;  max(abs(lb1),abs(ub1)); maxRelaxR*ones(m,1)];

    %%%%Ronan - make sure problem stays feasible
    %Bounds from sparseLP_cappedL1.m
    % lb <= x <= ub
    % 0  <= t <= max(|lb|,|ub|)
    %Variables [v r p q t w]
    ub3=-minLB*ones(n,1)+lb;
    ub3(ub3<0)=0;
    ub4=maxUB*ones(n,1)-ub;
    ub4(ub4<0)=0;
    l = [lb1; -maxRelaxR*ones(m,1);  zeros(n,1);    zeros(n,1);              zeros(n,1);          zeros(m,1)];
    u = [ub1;  maxRelaxR*ones(m,1);         ub3;           ub4;  max(abs(lb1),abs(ub1)); maxRelaxR*ones(m,1)];
    %%%%%%%
    
    %Exlude metabolites from relaxation (set the upper and lower bound of the relaxation to 0)
    indexExcludedMet = find(excludedMetabolites);

    l(n+indexExcludedMet) = 0;
    u(n+indexExcludedMet) = 0;

    if 0
        %Exlude reactions from relaxation (set the upper and lower bound of the relaxation to 0)
        indexExcludedRxn = find(excludedReactions);
        
        l(n+m+indexExcludedRxn) = 0;
        u(n+m+indexExcludedRxn) = 0;
        l(n+m+n+indexExcludedRxn) = 0;
        u(n+m+n+indexExcludedRxn) = 0;
    else
        %Exclude reactions from relaxation by individually set the upper and/or lower bound of the relaxation to 0
        indexExcludedRxnLB = find(excludedReactionLB);
        indexExcludedRxnUB = find(excludedReactionUB);
        
        % p is for relaxation of lower bounds
        l(n+m+indexExcludedRxnLB) = 0;
        u(n+m+indexExcludedRxnLB) = 0;
        %q is for relaxation of upper bounds
        l(n+m+n+indexExcludedRxnUB) = 0;
        u(n+m+n+indexExcludedRxnUB) = 0;
    end
    
    if any(l>u)
        error('bounds inconsistent')
    end
    
    %Solve the linear problem
    lpProblem = struct('c',obj,'osense',1,'A',A,'csense',sense,'b',rhs,'lb',l,'ub',u);
    solution = solveCobraLP(lpProblem);
    if solution.stat == 1
        v = solution.full(1:n);
        r = solution.full(n+1:n+m);
        p = solution.full(n+m+1:n+m+n);
        q = solution.full(n+m+n+1:n+m+n+n);
        if 0
            disp([v,p,q])
            disp('-')
        end
    else
        disp(param)
        warning(['solveCobraLP solution status is ' num2str(solution.stat) ', and original status is ' num2str(solution.origStat)])
        v = [];
        r = [];
        p = [];
        q = [];
    end
end

function obj = relaxFBA_cappedL1_obj(model,v,r,p,q,param)
    [S,c]                               = deal(model.S,model.c);
    [theta]                             = deal(param.theta);
    [gamma0,gamma1]                     = deal(param.gamma0,param.gamma1);
    [lambda0,lambda1]                   = deal(param.lambda0,param.lambda1);
    [alpha0,alpha1]                     = deal(param.alpha0,param.alpha1);
    [m,n] = size(S);

    part_v = c'*v + gamma1*ones(n,1)'*abs(v) +  gamma0*ones(n,1)'*min(ones(n,1),theta*abs(v));
    part_r =       lambda1*ones(m,1)'*abs(r) + lambda0*ones(m,1)'*min(ones(m,1),theta*abs(r));
    part_p =        alpha1*ones(n,1)'*p      +  alpha0*ones(n,1)'*min(ones(n,1),theta*p);
    part_q =        alpha1*ones(n,1)'*q      +  alpha0*ones(n,1)'*min(ones(n,1),theta*q);
    obj = part_v + part_r + part_p + part_q;

%     disp(strcat('Part v:',num2str(part_v)));
%     disp(strcat('Part r:',num2str(part_r)));
%     disp(strcat('Part p:',num2str(part_p)));
%     disp(strcat('Part q:',num2str(part_q)));
end
