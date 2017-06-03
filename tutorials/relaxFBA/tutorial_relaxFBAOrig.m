%

%initialise the cobra toolbox
if 0
    initCobraToolbox
    changeCobraSolver('gurobi6','all');
end

% Load Recon3.0model
filename='Recon3.0model';
directory='~/work/sbgCloud/programReconstruction/projects/recon2models/data/reconXComparisonModels';
model = loadIdentifiedModel(filename,directory);

%  
[m,n] = size(model.S);
model_Ex = findSExRxnInd(model);
intRxnBool = model_Ex.SIntRxnBool;
exRxnBool = true(size(intRxnBool));
exRxnBool(find(intRxnBool)) = false;
model.csense(1:m,1)='E';

%close exchange reactions
model.lb(~SIntRxnBool)=0;
model.ub(~SIntRxnBool)=0;

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

%Call
solution = relaxFBA(model,relaxOption);

[v,r,p,q] = deal(solution.v,solution.r,solution.p,solution.q);

eps = 1e-6;
p(find(p<eps)) = 0;
q(find(q<eps)) = 0;
r(find(r<eps)) = 0;

if solution.stat == 1
    
    maxUB = max(max(model.ub),-min(model.lb));
    minLB = min(-max(model.ub),min(model.lb));
    
    disp(strcat('Number of relaxations on internal reactions:',num2str(size(find(p>eps & intRxnBool),1)+size(find(q>eps & intRxnBool),1))));
    intRxnFiniteBound = ((model.ub < maxUB) & (model.lb > minLB)) & intRxnBool;
    display(strcat('  - Relaxations on internal reactions with finite bounds:',num2str(size(find(p>eps & intRxnFiniteBound),1)+size(find(q>eps & intRxnFiniteBound),1))));
    
    disp(strcat('Number of relaxations on exchange reactions:',num2str(size(find(p>eps & exRxnBool),1)+size(find(q>eps & exRxnBool),1))));
    exRxn00 = ((model.ub == 0) & (model.lb == 0)) & exRxnBool;
    display(strcat('  - Relaxations on exchange reactions of type [0,0]:',num2str(size(find(p>eps & exRxn00),1)+size(find(q>eps & exRxn00),1))));
    
    disp(strcat('Number of relaxations on steady state constraints:',num2str(size(find(abs(r)>0),1))));
    
    
    % Check if the relaxed model is realy feasible
    % Relax bounds
    model.ub = model.ub + q;
    model.lb = model.lb - p;
    model.b  = model.b  - r;
        
    FBAsolution = optimizeCbModel(model,'max', 0, true);
    if FBAsolution.stat == 1 
        disp('Relaxed model is feasible');
    else
        disp('Relaxed model is infeasible');
    end
else
    disp('Can not find any solution');
end

%%
return
[m,n] = size(model.S);
model_Ex = findSExRxnInd(model);
intRxnBool = model_Ex.SIntRxnBool;
exRxnBool = true(size(intRxnBool));
exRxnBool(find(intRxnBool)) = false; 

relaxOption.nbMaxIteration = 1000;
relaxOption.epsilon = 10e-6;
relaxOption.gamma0  = 0;   %trade-off parameter of l0 part of v   
relaxOption.gamma1  = 0;   %trade-off parameter of l1 part of v       
relaxOption.lambda0 = 10;  %trade-off parameter of l0 part of r
relaxOption.lambda1 = 0;   %trade-off parameter of l1 part of r
relaxOption.alpha0  = 10;  %trade-off parameter of l0 part of p and q
relaxOption.alpha1  = 0;   %trade-off parameter of l1 part of p and q    
relaxOption.theta   = 2;   %parameter of capped l1 approximation  

blocledReactionBool = ~model.rbool;
indexblocledReaction = find(blocledReactionBool);
nbBlockedReaction = length(indexblocledReaction);


for i=1:nbBlockedReaction    
    disp(strcat('Reaction ',num2str(i)));
    minNbRelaxation = n+n+m;    
    
    %Impose v of the blocked reaction to be positive
    relaxSS = true;
    relaxOption.toBeUnblockedReactions = zeros(n,1);
    relaxOption.toBeUnblockedReactions(indexblocledReaction(i)) = 1;
    
    %Allow only relaxation on bounds
    relaxOption.internalRelax = 2;
    relaxOption.exchangeRelax = 2;
    relaxOption.steadyStateRelax = 0;    
    %Relax the model to unblock the reaction
    disp(' - v positive - relax bounds')
    solution = relaxFBA(model,relaxOption);
    [v,r,p,q] = deal(solution.v,solution.r,solution.p,solution.q);
    
    if solution.stat == 1
        nbRelaxations = length(find(p>0)) + length(find(q>0)) + length(find(abs(r)>0));
        disp(strcat('    - Relax:',num2str(length(find(p>0))),' - ',num2str(length(find(q>0))),' - ',num2str(length(find(abs(r)>0)))));
        relaxSS = false;
        if nbRelaxations < minNbRelaxation
            minNbRelaxation = nbRelaxations;
            result.V(:,i) = v;
            result.R(:,i) = r;
            result.P(:,i) = p;
            result.Q(:,i) = q;           
        end
    end
    
    if relaxSS == true
        %Allow only relaxation on bounds
        relaxOption.internalRelax = 2;
        relaxOption.exchangeRelax = 2;
        relaxOption.steadyStateRelax = 1;    
        %Relax the model to unblock the reaction
        disp(' - v positive - relax bounds & steady state')
        solution = relaxFBA(model,relaxOption);
        [v,r,p,q] = deal(solution.v,solution.r,solution.p,solution.q);

        if solution.stat == 1
            nbRelaxations = length(find(p>0)) + length(find(q>0)) + length(find(abs(r)>0));
            disp(strcat('    - Relax:',num2str(length(find(p>0))),' - ',num2str(length(find(q>0))),' - ',num2str(length(find(abs(r)>0)))));
            if nbRelaxations < minNbRelaxation
                minNbRelaxation = nbRelaxations;
                result.V(:,i) = v;
                result.R(:,i) = r;
                result.P(:,i) = p;
                result.Q(:,i) = q;           
            end
        end    
    end
    
    %Impose v of the blocked reaction to be negative
    relaxSS = true;
    relaxOption.toBeUnblockedReactions = zeros(n,1);
    relaxOption.toBeUnblockedReactions(indexblocledReaction(i)) = -1;
    
    %Allow only relaxation on bounds
    relaxOption.internalRelax = 2;
    relaxOption.exchangeRelax = 2;
    relaxOption.steadyStateRelax = 0;    
    %Relax the model to unblock the reaction
    disp(' - v negative - relax bounds')
    solution = relaxFBA(model,relaxOption);
    [v,r,p,q] = deal(solution.v,solution.r,solution.p,solution.q);
    
    if solution.stat == 1
        nbRelaxations = length(find(p>0)) + length(find(q>0)) + length(find(abs(r)>0));
        disp(strcat('    - Relax:',num2str(length(find(p>0))),' - ',num2str(length(find(q>0))),' - ',num2str(length(find(abs(r)>0)))));
        relaxSS = false;
        if nbRelaxations < minNbRelaxation
            minNbRelaxation = nbRelaxations;
            result.V(:,i) = v;
            result.R(:,i) = r;
            result.P(:,i) = p;
            result.Q(:,i) = q;            
        end
    end
    
    if relaxSS == true
        %Allow only relaxation on bounds
        relaxOption.internalRelax = 2;
        relaxOption.exchangeRelax = 2;
        relaxOption.steadyStateRelax = 1;    
        %Relax the model to unblock the reaction
        disp(' - v negative - relax bounds & steady state')
        solution = relaxFBA(model,relaxOption);
        [v,r,p,q] = deal(solution.v,solution.r,solution.p,solution.q);

        if solution.stat == 1
            nbRelaxations = length(find(p>0)) + length(find(q>0)) + length(find(abs(r)>0));
            disp(strcat('    - Relax:',num2str(length(find(p>0))),' - ',num2str(length(find(q>0))),' - ',num2str(length(find(abs(r)>0)))));
            if nbRelaxations < minNbRelaxation
                minNbRelaxation = nbRelaxations;
                result.V(:,i) = v;
                result.R(:,i) = r;
                result.P(:,i) = p;
                result.Q(:,i) = q;            
            end
        end    
    end
    
    % Update bounds and steady state
    model.lb = model.lb - result.P(:,i);
    model.ub = model.ub + result.Q(:,i);
    model.b  = model.b  - result.R(:,i);
    
    %Save the results
    save 'Recon2.v04_RelaxResult.mat' result;
end