changeCobraSolver('gurobi6','all');
%Load data

% Load the stoichiometrically consistent par of Recon2
load 'Recon2.v04_sc.mat';

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
