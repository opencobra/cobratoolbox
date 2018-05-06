if 0
    rxnForms = {' -> A','A -> B','B -> C', 'B -> D','D -> C','C ->'};
    rxnNames = {'Ain','AB','BC','BD','DC', 'Cout'};
    model = createModel(rxnNames, rxnNames,rxnForms);
    model.lb(3) = 2; %BD
    model.lb(4) = 2; 
    model.ub(6) = 2;
else
    rxnForms = {' -> A','A -> B','A -> D','B -> C', 'B -> D','D -> C','C ->'};
    rxnNames = {'Ain','AB','AD','BC','BD','DC', 'Cout'};
    model = createModel(rxnNames, rxnNames,rxnForms);
    model.lb(1) = 5;
    %model.ub(6) = 2;
    model.ub(6) = 2.1;
    model.ub(4) = 1;
end

disp('-')
[nMet,nRxn]=size(model.S);

if exist('param','var')
clear param
end

if 0
    %weighting on zero norm of fluxes
    param.gamma0   = 0*1e-6;
    param.gamma1   = 1e-6;
    
    % weighting on relaxation of reaction bounds
    param.alpha0   = 10;
    param.alpha1   = 1;
    
    %weighting on relaxation of steady state constraints S*v = b
    param.lambda0   = 0;
    param.lambda1   = 0;
end

param.printLevel=2;

%stopping criterion
param.epsilon = 1e-6;
%capped l0 parameter
param.theta0   = 0.5;

sol = relaxedFBA(model,param);

plotRelaxedFBA(sol, model)
