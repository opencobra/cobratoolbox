changeCobraSolver('gurobi6','all');
%Load data

% Load the stoichiometrically consistent par of Recon2
load 'Recon2.v04_sc.mat';

[m,n] = size(model.S);
model_Ex = findSExRxnInd(model);
intRxnBool = model_Ex.SIntRxnBool;
exRxnBool = true(size(intRxnBool));
exRxnBool(find(intRxnBool)) = false; 

%Relax the model to make it flux conssitent
relaxOption.internalRelax = 2;
relaxOption.exchangeRelax = 2;
relaxOption.steadyStateRelax = 1;

relaxOption.nbMaxIteration = 1000;
relaxOption.epsilon = 10e-6;
relaxOption.gamma0  = 100;   %trade-off parameter of l0 part of v   
relaxOption.gamma1  = 10;    %trade-off parameter of l1 part of v       
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
    intRxnFiniteBound = ((model.ub < maxUB) & (model.lb > minLB)) & intRxnBool;
    display(strcat('  - Relaxations on internal reactions with finite bounds:',num2str(size(find(p>0 & intRxnFiniteBound),1)+size(find(q>0 & intRxnFiniteBound),1))));
    
    display(strcat('Number of relaxations on exchange reactions:',num2str(size(find(p>0 & exRxnBool),1)+size(find(q>0 & exRxnBool),1))));
    exRxn00 = ((model.ub == 0) & (model.lb == 0)) & exRxnBool;
    display(strcat('  - Relaxations on exchange reactions of type [0,0]:',num2str(size(find(p>0 & exRxn00),1)+size(find(q>0 & exRxn00),1))));
    
    display(strcat('Number of relaxations on steady state constraints:',num2str(size(find(abs(r)>0),1))));
    
    display(strcat('Reactions unblocked = ',num2str(length(find(abs(v)>1e-4 & ~model.rbool)))));
else
    disp('Can not find any solution');
end