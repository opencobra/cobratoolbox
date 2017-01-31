%changeCobraSolver('gurobi6','all');

%Creat the toy example


model.S = [ 1   -1  -1  0   0   0   0   -1  0   0   0;
            0   1   0   1   0   0   0   0   0   0   0;
            0   0   1   0   1   0   0   0   0   0   0;
            0   0   0   -1  0   1   0   0   0   0   0;
            0   0   0   0   -1  -1  -1  0   0   0   -1;
            0   0   0   0   0   0   0   1   1   0   0;
            0   0   0   0   0   0   0   0   -1  1   0;
            0   0   0   0   0   0   0   0   0   -1  1
            ];
[m,n] = size(model.S);
model.c = zeros(n,1);
model.b = zeros(m,1);

model.lb = zeros(n,1);
model.lb(7) = 1;
model.ub = 1000*ones(n,1);

model.SIntRxnBool = true(n,1);
model.SIntRxnBool(1) = false;
model.SIntRxnBool(7) = false;
intRxnBool = model.SIntRxnBool;
exRxnBool = true(size(intRxnBool));
exRxnBool(find(intRxnBool)) = false;

%Relax the model to make it flux conssitent
relaxOption.internalRelax = 2;
relaxOption.exchangeRelax = 0;
relaxOption.steadyStateRelax = 0;
relaxOption.excludedReactions = false(n,1);
% relaxOption.excludedReactions(5) = true;
relaxOption.toBeUnblockedReactions = zeros(n,1);
relaxOption.toBeUnblockedReactions(7) = 1; %Force biomass reaction to be active


relaxOption.nbMaxIteration = 1000;
relaxOption.epsilon = 10e-6;
relaxOption.gamma0  = 0;   %trade-off parameter of l0 part of v
relaxOption.gamma1  = 0;    %trade-off parameter of l1 part of v
relaxOption.lambda0 = 10;   %trade-off parameter of l0 part of r
relaxOption.lambda1 = 0;    %trade-off parameter of l1 part of r
relaxOption.alpha0  = 10;    %trade-off parameter of l0 part of p and q
relaxOption.alpha1  = 1;     %trade-off parameter of l1 part of p and q
relaxOption.theta   = 2;    %parameter of capped l1 approximation

solution = relaxFBA(model,relaxOption);

[v,r,p,q] = deal(solution.v,solution.r,solution.p,solution.q);
if solution.stat == 1
    maxUB = max(model.ub);
    minLB = min(model.lb);

    display(strcat('Number of relaxations on internal reactions:',num2str(size(find(p>0 & intRxnBool),1)+size(find(q>0 & intRxnBool),1))));
    intRxnFiniteBound = ((model.ub < maxUB) & (model.lb > minLB)) & intRxnBool;
    display(strcat('  - Relaxations on internal reactions with finite bounds:',num2str(size(find(p>0 & intRxnFiniteBound),1)+size(find(q>0 & intRxnFiniteBound),1))));

    display(strcat('Number of relaxations on exchange reactions:',num2str(size(find(p>0 & exRxnBool),1)+size(find(q>0 & exRxnBool),1))));
    exRxn00 = ((model.ub == 0) & (model.lb == 0)) & exRxnBool;
    display(strcat('  - Relaxations on exchange reactions of type [0,0]:',num2str(size(find(p>0 & exRxn00),1)+size(find(q>0 & exRxn00),1))));

    display(strcat('Number of relaxations on steady state constraints:',num2str(size(find(abs(r)>0),1))));

%     display(strcat('Reactions unblocked = ',num2str(length(find(abs(v)>1e-4 & ~model.rbool)))));
else
    disp('Can not find any solution');
end
