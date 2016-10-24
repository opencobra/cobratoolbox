changeCobraSolver('gurobi6','all');
%Load data

% Load the stoichiometrically consistent par of Recon2
% load 'Recon2.v04_sc.mat';


load 2016_05_10_MinhModel;
model = modelOrganAllCoupledFeasible;
model.S = model.A;


% m = min(size(model.S,1),length(model.metFormulas));
% model.S = model.S(1:m,:);
% model.b = model.b(1:m);
% model.csense = model.csense(1:m);
% model.mets = model.mets(1:m);
% model.metFormulas = model.metFormulas(1:m);

[m,n] = size(model.S);
model_Ex = findSExRxnInd(model);
intRxnBool = model_Ex.SIntRxnBool;
exRxnBool = true(size(intRxnBool));
exRxnBool(find(intRxnBool)) = false; 

%Relax the model to make it flux conssitent
relaxOption.internalRelax = 2;
relaxOption.exchangeRelax = 2;
relaxOption.steadyStateRelax = 0;

relaxOption.excludedReactions = false(n,1); % Do no exclude any reaction from relaxtion
relaxOption.toBeUnblockedReactions = zeros(n,1);
relaxOption.toBeUnblockedReactions(find(model.c)) = 1; %Force biomass reaction to be active

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

eps = 1e-6;
p(find(p<eps)) = 0;
q(find(q<eps)) = 0;
r(find(r<eps)) = 0;

if solution.stat == 1
    
    maxUB = max(max(model.ub),-min(model.lb));
    minLB = min(-max(model.ub),min(model.lb));
    
    display(strcat('Number of relaxations on internal reactions:',num2str(size(find(p>eps & intRxnBool),1)+size(find(q>eps & intRxnBool),1))));
    intRxnFiniteBound = ((model.ub < maxUB) & (model.lb > minLB)) & intRxnBool;
    display(strcat('  - Relaxations on internal reactions with finite bounds:',num2str(size(find(p>eps & intRxnFiniteBound),1)+size(find(q>eps & intRxnFiniteBound),1))));
    
    display(strcat('Number of relaxations on exchange reactions:',num2str(size(find(p>eps & exRxnBool),1)+size(find(q>eps & exRxnBool),1))));
    exRxn00 = ((model.ub == 0) & (model.lb == 0)) & exRxnBool;
    display(strcat('  - Relaxations on exchange reactions of type [0,0]:',num2str(size(find(p>eps & exRxn00),1)+size(find(q>eps & exRxn00),1))));
    
    display(strcat('Number of relaxations on steady state constraints:',num2str(size(find(abs(r)>0),1))));
    
    
    % Check if the relaxed model is realy feasible
    % Relax bounds
    model.ub = model.ub + q;
    model.lb = model.lb - p;
    model.b  = model.b  - r;
        
    FBAsolution = optimizeCbModel(model,'max', 0, true);
    if FBAsolution.stat == 1 
        display('Relaxed model is feasible');
    else
        display('Relaxed model is infeasible');
    end
else
    disp('Can not find any solution');
end

