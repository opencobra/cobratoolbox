function x=testFASTCORE()
%test FASTCORE algorithm and returns 1 for correct, else 0
%

% Ronan Fleming, August 2015
% Modified by Thomas Pfau, May 2016


ibm = changeCobraSolver('ibm_cplex');
if ~ibm
    gurobi = changeCobraSolver('gurobi6');
    if ~gurobi
        tomlab = changeCobraSolver('tomlab_cplex');
        if ~tomlab
            %Those are the allowed solvers for FASTCORE. Others can be
            %used, but likely lead to numeric issues.
            x = 0;
            return
        end    
    end
end

%load a model
load('FastCoreTest.mat')
model=ConsistentRecon2;

%randomly pick some reactions
epsilon=1e-4;
printLevel=0;
A = fastcore(coreInd, model, epsilon, printLevel);

%test, whether all of the core fluxes can carry flux
reducedmodel = removeRxns(model,setdiff(model.rxns,model.rxns(A)));
corereacs = intersect(reducedmodel.rxns,model.rxns(coreInd));
reducedmodel.csense(1:numel(reducedmodel.mets)) = 'E';
reducedmodel.c(:) = 0;
[minFlux,maxFlux] = fluxVariability(reducedmodel,[],[],corereacs);

if all(minFlux < epsilon | maxFlux > epsilon)
    x = 1;
else
    x = 0;
end