load('e_coli_core.mat');

%Run FBA
FBAsolution = optimizeCbModel(model,'max','zero', true);

% Index of predicted active reactions
indexVFBA = find(abs(FBAsolution.x)>eps);

% Index of forward reactions
indexForwardRxns = find(model.ub >0 & model.lb==0);
index = intersect(indexVFBA,indexForwardRxns);

% Index of internal and Exchange reactions
model_Ex = findSExRxnInd(model);
intRxnBool = model_Ex.SIntRxnBool;
exRxnBool = true(size(intRxnBool));
exRxnBool(find(intRxnBool)) = false;
indexInternalRxns = find(intRxnBool);

index = intersect(index,indexInternalRxns);

%% Check if the selected set of reactions is minimal
index_selRxns = find(abs(FBAsolution.x)>eps);
nb_selRnxs = length(index_selRxns);
selRxns = false(size(model.rxns));
selRxns(index_selRxns) = true;
selMets = any(model.S(:,selRxns),2);

isInMinnimalSet = true(nb_selRnxs,1);

subModel.S = model.S(selMets,selRxns);
subModel.b = model.b(selMets);
subModel.lb = model.lb(selRxns);
subModel.ub = model.ub(selRxns);
subModel.c = model.c(selRxns);


[mSub,nSub] = size(subModel.S);
A = subModel.S;
b = subModel.b;
csense = repmat('E',mSub,1);

for i=1:nb_selRnxs
    ubSub = subModel.ub;
    lbSub = subModel.lb;
    ubSub(i) = 0;
    lbSub(i) = 0;

    % max c'v
    LPproblem = struct('c',-subModel.c,'osense',1,'A',A,'csense',csense,'b',b,'lb',lbSub,'ub',ubSub);
    LPsolution = solveCobraLP(LPproblem);

    if LPsolution.stat == 1 && abs(LPsolution.obj - -model.c'*FBAsolution.x)<1e-8
        isInMinnimalSet(i) = false;
        subModel.ub(i) = 0;
        subModel.lb(i) = 0;
    end
end

display(strcat('Nb of rxns that one can still remove = ',num2str(nb_selRnxs - length(find(isInMinnimalSet==true)))));


%%Change some forward and predicted active reactions to reverse reactions
nbRxnsToChange = 5;
index(1:nbRxnsToChange)'
model.ub(index(1:nbRxnsToChange)) = 0;
model.lb(index(1:nbRxnsToChange)) = -1000;

% Add the constraint c'v = c'vFBA
[m,n] = size(model.S);
model.S = [model.S ; model.c'];
model.b = [model.b ; model.c'*FBAsolution.x];
% model.csense = repmat('=',m+1,1);

%
FBAsolution2 = optimizeCbModel(model,'max',0, true);

%%Relax the model to make it feasible
relaxOption.internalRelax = 2;
relaxOption.exchangeRelax = 0;
relaxOption.steadyStateRelax = 0;
relaxOption.excludedReactions = false(n,1);

relaxOption.nbMaxIteration = 1000;
relaxOption.epsilon = 10e-6;
relaxOption.gamma0  = 0;   %trade-off parameter of l0 part of v
relaxOption.gamma1  = 0;    %trade-off parameter of l1 part of v
relaxOption.lambda0 = 10;   %trade-off parameter of l0 part of r
relaxOption.lambda1 = 0;    %trade-off parameter of l1 part of r
relaxOption.alpha0  = 10;    %trade-off parameter of l0 part of p and q
relaxOption.alpha1  = 0;     %trade-off parameter of l1 part of p and q
relaxOption.theta   = 2;    %parameter of capped l1 approximation

solution = relaxFBA(model,relaxOption);

[v,r,p,q] = deal(solution.v,solution.r,solution.p,solution.q);
if solution.stat == 1
    maxUB = max(model.ub);
    minLB = min(model.lb);

    display(strcat('Number of relaxations on internal reactions:',num2str(size(find(p>0 & intRxnBool),1)+size(find(q>0 & intRxnBool),1))));
%     intRxnFiniteBound = ((model.ub < maxUB) & (model.lb > minLB)) & intRxnBool;
%     display(strcat('  - Relaxations on internal reactions with finite bounds:',num2str(size(find(p>0 & intRxnFiniteBound),1)+size(find(q>0 & intRxnFiniteBound),1))));

    display(strcat('Number of relaxations on exchange reactions:',num2str(size(find(p>0 & exRxnBool),1)+size(find(q>0 & exRxnBool),1))));
%     exRxn00 = ((model.ub == 0) & (model.lb == 0)) & exRxnBool;
%     display(strcat('  - Relaxations on exchange reactions of type [0,0]:',num2str(size(find(p>0 & exRxn00),1)+size(find(q>0 & exRxn00),1))));

    display(strcat('Number of relaxations on steady state constraints:',num2str(size(find(abs(r)>0),1))));

%     display(strcat('Reactions unblocked = ',num2str(length(find(abs(v)>1e-4 & ~model.rbool)))));
else
    disp('Can not find any solution');
end
