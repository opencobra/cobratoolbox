function solution=relaxedFBAL1(model,relaxOption)
%      min  ||p||_1,||q||_1,||r||_1
%      s.t. S v + r <=> b 
%           l - p < v < u + q
%Marouen Ben Guebila - 21/07/2017

[m,n]=size(model.S);
if ~isfield(model,'csense')
    fprintf('Csense does not exist, we assume equalities \n');
    model.csense = repmat('E',m,1);
end
if nargin <2
    relaxOption.options=0;
end
%set the tolerance to eliminate nuemrical inconsistencies
feasTol = getCobraSolverParams('LP', 'feasTol')*100;

[S,lb,ub,b,csense]=deal(model.S,model.lb,model.ub,model.b,model.csense);

%Variables v,p,q,r
%Constraints
%       S*v + r <=> b
A     = [S          sparse(m,n) sparse(m,n) speye(m,m)];
rhs   = b;
sense = csense;

% Constraint  v + p >= lb
A1     = [speye(n,n) speye(n,n) sparse(n,n) sparse(n,m)];
sense1 = repmat('G', n, 1);
A      = [A; A1];
rhs    = [rhs; lb];
sense  = [sense; sense1];

% Constraint v - q <= ub
A2     = [speye(n,n) sparse(n,n) -speye(n,n) sparse(n,m)];
sense2 = repmat('L', n, 1);
A      = [A; A2];
rhs    = [rhs; ub];
sense  = [sense; sense2];

maxUB = max(max(model.ub),-min(model.lb));
minLB = min(-max(model.ub),min(model.lb));
%    v                      p                       q                      r 
l = [minLB*ones(n,1);      minLB*ones(n,1)-lb; -maxUB*ones(n,1)+ub ;     -100*ones(m,1)      ];
u = [maxUB*ones(n,1);     -minLB*ones(n,1)+lb;  maxUB*ones(n,1)-ub ;      100*ones(m,1)      ];

%options
%excluded metabolites
if isfield(relaxOption,'excludedMetabolites')
    indexExcludedMet = find(relaxOption.excludedMetabolites);
    l(3*n+indexExcludedMet) = 0;
    u(3*n+indexExcludedMet) = 0;
end
%excluded reactions
if isfield(relaxOption,'excludedReactions')
    indexExcludedRxn = find(relaxOption.excludedReactions);
    l(n+indexExcludedRxn) = 0;
    u(n+indexExcludedRxn) = 0;
    l(n+n+indexExcludedRxn) = 0;
    u(n+n+indexExcludedRxn) = 0;
end

%construct objective
obj=[zeros(n+n+n+m,1)];

%construct the problem
lpProblem     = struct('c',obj,'osense',1,'S',A,'csense',sense,'b',rhs,'lb',l,'ub',u);
relaxProbdim  = 1:n+n+n+m;
lpProblem.rxns= cellstr(strcat(repmat('r',n+n+n+m,1),int2str(relaxProbdim')));

%divide all variables into positive and negative counterparts
[modelIrrev,matchRev,rev2irrev,irrev2rev] = convertToIrreversible(lpProblem,'sRxns',lpProblem.rxns(n+1:end));
modelIrrev.c(1:end)=1;
modelIrrev.c(1:n)  =0;

%solve
sol1 = solveCobraLP(modelIrrev);

%aggregate results
sol1.full = cell2mat(cellfun(@(x) sum([1 -1*(length(x)==2)]*sol1.full(x)),...
    rev2irrev,'UniformOutput',false));

%ceil to eliminate numerical infeasiblities
sol1.full(n+1:end)=ceil(sol1.full(n+1:end)/feasTol)*feasTol;

%report results
if sol1.stat == 1
    v   = sol1.full(1:n);
    p   = sol1.full(n+1:n+n);
    q   = sol1.full(n+n+1:n+n+n);
    r   = sol1.full(n+n+n+1:n+n+n+m);
else
    warning(['solveCobraLP solution status is ' num2str(sol1.stat)])
    v   = [];
    p   = [];
    q   = [];
    r   = [];
end

[solution.v,solution.r,solution.p,solution.q]=deal(v,r,p,q);

end