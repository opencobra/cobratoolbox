if 0
    rxnForms = {' -> A','A -> B','B -> C', 'B -> D','D -> C','C ->'};
    rxnNames = {'Ain','AB','BC','BD','DC', 'Cout'};
    model = createModel(rxnNames, rxnNames,rxnForms);
    model.lb(3) = 1;
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




[nMet,nRxn]=size(model.S);

if 0
%weighting on zero norm of fluxes
params.gamma   = 1;

% weighting on relaxation of reaction bounds
params.alpha   = 10;
if 1
    params.alpha0   = 10;
    params.alpha1   = 1;
else
    params.alpha0   = 0;
    params.alpha1   = 10;
end

%weighting on relaxation of relaxation on steady state constraints S*v = b
params.lambda   = 10;
end

%stopping criterion
params.epsilon = 1e-6;
%capped l0 parameter
params.theta   = 0.5;

sol = relaxedFBA(model,params);


feasTol = getCobraSolverParams('LP', 'feasTol');
sol.p(abs(sol.p)<feasTol*10)=0;
sol.q(abs(sol.q)<feasTol*10)=0;

if norm(model.S*sol.v-model.b)>feasTol*1000
    warning(['relaxedFBA relaxed steady state constraints too much, norm(S*v-b)= ' num2str(norm(model.S*sol.v-model.b))])
end


if sol.stat==1
    fprintf('%-10s%12s%12s%12s%12s%12s\n','rxns{n}','-p','lb','v','ub','q')
    for n=1:nRxn
        fprintf('%-10s%12.4g%12.4g%12.4g%12.4g%12.4g\n',...
            model.rxns{n},sol.p(n),model.lb(n),sol.v(n),model.ub(n),sol.q(n));
    end
end
disp('Optimal value of r...')
disp(sol.r)
