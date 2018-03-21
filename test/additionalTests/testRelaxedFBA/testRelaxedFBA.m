if 1
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
    model.ub(6) = 2;
    model.ub(6) = 2.1;
    model.ub(4) = 1;
end



disp('-')
[nMet,nRxn]=size(model.S);

if exist('params','var')
clear params
end

if 0
    %weighting on zero norm of fluxes
    params.gamma0   = 0*1e-6;
    params.gamma1   = 1e-6;
    
    % weighting on relaxation of reaction bounds
    params.alpha0   = 10;
    params.alpha1   = 1;
    
    %weighting on relaxation of steady state constraints S*v = b
    params.lambda0   = 0;
    params.lambda1   = 0;
end

%stopping criterion
params.epsilon = 1e-6;
%capped l0 parameter
params.theta   = 0.5;

sol = relaxedFBA(model,params);


optTol = getCobraSolverParams('LP', 'optTol');
sol.p(abs(sol.p)<optTol*10)=0;
sol.q(abs(sol.q)<optTol*10)=0;

if norm(model.S*sol.v-model.b)>optTol*10
    warning(['relaxedFBA relaxed steady state constraints too much, norm(S*v-b)= ' num2str(norm(model.S*sol.v-model.b))])
end


if sol.stat==1
    fprintf('%-10s%12s%12s%12s%12s%12s\n','rxns{n}','-p','lb','v','ub','q')
    for n=1:nRxn
        fprintf('%-10s%12.4g%12.4g%12.4g%12.4g%12.4g\n',...
            model.rxns{n},sol.p(n),model.lb(n),sol.v(n),model.ub(n),sol.q(n));
    end
end
if norm(sol.r)>0
    disp('Optimal value of r...')
    disp(sol.r)
end
