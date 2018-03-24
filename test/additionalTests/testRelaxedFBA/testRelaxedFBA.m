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
param.theta   = 0.5;

sol = relaxedFBA(model,param);

optTol = getCobraSolverParams('LP', 'optTol');
sol.p(abs(sol.p)<optTol*10)=0;
sol.q(abs(sol.q)<optTol*10)=0;

if norm(model.S*sol.v-model.b)>optTol*10
    warning(['relaxedFBA relaxed steady state constraints too much, norm(S*v-b)= ' num2str(norm(model.S*sol.v-model.b))])
end

fprintf('\n')
if sol.stat==1
    fprintf('%-10s%12s%12s%12s%12s%12s\n','rxns{n}','-p','lb','v','ub','q')
    for n=1:nRxn
        fprintf('%-10s%12.4g%12.4g%12.4g%12.4g%12.4g\n',...
            model.rxns{n},sol.p(n),model.lb(n),sol.v(n),model.ub(n),sol.q(n));
    end
end
fprintf('\n')
if sol.stat==1
    fprintf('%-20s%12s%12s\n','mets{n}','r','dxdt')
    for n=1:nMet
        if dxdt(n)~=0 || relaxedSol.r(n)~=0
            fprintf('%-20s%12.4g%12.4g\n',...
                model.mets{n},relaxedSol.r(n),dxdt(n));
        end
    end
end
