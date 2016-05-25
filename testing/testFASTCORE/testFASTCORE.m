function x=testFASTCORE()
%test FASTCORE algorithm and returns 1 for correct, else 0
%

% Ronan Fleming, August 2015
% Modified by Thomas Pfau, May 2016


ibm = changeCobraSolver('ibm_cplex');
if ~ibm
    gurobi = changeCobraSolver('gurobi6');
    if ~gurobi
        tomlab = changeCobraSolver('tomlab_cplex')
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
reducedmodel = removeRxns(model,setdiff(model.rxns,model.rxns(A)));
%test, whether all of the core fluxes can carry flux
corereacs = find(ismember(reducedmodel.rxns,model.rxns(coreInd)));
x = 1;
reducedmodel.csense(1:numel(reducedmodel.mets)) = 'E';
reducedmodel.c(:) = 0;
for i=1:numel(corereacs)
    reducedmodel.c(corereacs(i)) = 1;
    solmax = optimizeCbModel(reducedmodel,'max');
    solmin = optimizeCbModel(reducedmodel,'min');
    if (abs(solmax.x(corereacs(i))) < epsilon) && (abs(solmin.x(corereacs(i))) < epsilon)
        x = 0;
        break
    end
    reducedmodel.c(corereacs(i)) = 0;
end
    