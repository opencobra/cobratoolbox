if 0
    load('ecoli_core_model.mat');
    %objective
    model.biomassRxnAbbr='Biomass_Ecoli_core_N(w/GAM)-Nmet2';
    model = changeObjective(model,model.biomassRxnAbbr,1);
    osenseStr = 'max';
    model.osenseStr = osenseStr;
    
    if ~isfield(model,'SConsistentRxnBool')  || ~isfield(model,'SConsistentMetBool')
        massBalanceCheck=1;
        printLevel=2;
        [SConsistentMetBool, SConsistentRxnBool, SInConsistentMetBool, SInConsistentRxnBool, unknownSConsistencyMetBool, unknownSConsistencyRxnBool, model]...
            = findStoichConsistentSubset(model, massBalanceCheck, printLevel);
    end
else
    modelToLoad='circularToy';
    modelToLoad='ecoli_core';
    modelToLoad='modelRecon3MitoOpen';
    modelToLoad='Recon3DModel';
    driver_thermoModelLoad
end

param.fbaOptimal = 1;
param.printLevel = 1;

[nMet,nRxn]=size(model.S);
nIntRxn = nnz(model.SConsistentRxnBool);

%compute a normalised random vector of conductances
q1=rand(nIntRxn,1);
q1 = q1/sum(q1);

%compute a thermodynamically feasible flux vector using randomBoundThermoFeasible
model.q=q1;
[model, vRandThermo,yRandThermo, qRandThermo] = randomBoundThermoFeasible(model,param);
v = vRandThermo(model.SConsistentRxnBool);
g1 = model.S(:,model.SConsistentRxnBool)'*yRandThermo;

model = rmfield(model,'q');

% %compute a thermodynamically feasible flux vector using thermoQP
% sol = thermoQP(model,qRandThermo,param.printLevel);
% vRandThermo = sol.v;
% yRandThermo = sol.y;

solutionThermo.v = vRandThermo;
[qRecovered,gRecovered] = thermoFlux2QNty(model,solutionThermo,param);
q3 = qRecovered(model.SConsistentRxnBool);
g3 = gRecovered(model.SConsistentRxnBool);

rxns=model.rxns(model.SConsistentRxnBool);

%compare the initial and recovered q and g
T=table(rxns,v,q1,q3,g1,g3);

feasTol = getCobraSolverParams('LP', 'feasTol');
param.eta = feasTol*10;
g1(abs(g1)<param.eta)=0;
g3(abs(g1)<param.eta)=0;
nDifferentSigns = nnz(sign(g1)~=sign(g3));
assert(nDifferentSigns==0)
