function [ solutionsValid ] = validateOptForceSol(model,posOptForceSets,typeRegOptForceSets, target)
relreacs = unique(model.rxns(posOptForceSets(:)));
[minRelFluxes,maxRelFluxes] = fluxVariability(model,0,'max',relreacs);

solutionsValid = true;
sol = optimizeCbModel(model);
tempmodel = model;
tempmodel.lb(find(model.c)) = sol.x(find(model.c));
tempmodel.c = double(ismember(model.rxns,target));
tempmodel.osenseStr = 'min';
sol = optimizeCbModel(tempmodel);
ores = sol.x(ismember(model.rxns,target));

%These changes are extreme, and they should only be used for the actual
%test Case. In general they might not be applicable. 
changes = {'knockout',@(cmodel,treac) changeRxnBounds(cmodel,treac,0,'b');...
           'upregulation',@(cmodel,treac) changeRxnBounds(cmodel,treac,min(sol.x(ismember(cmodel.rxns,treac))+100,maxRelFluxes(ismember(relreacs,treac))),'l');...
           'downregulation',@(cmodel,treac) changeRxnBounds(cmodel,treac,max(sol.x(ismember(cmodel.rxns,treac))-100,minRelFluxes(ismember(relreacs,treac))),'u')};
for i = 1:size(posOptForceSets,1)
    cmodel = model;
    for j = 1:size(posOptForceSets,2)
        if posOptForceSets(i,j) > 0
            cfunc = changes{ismember(changes(:,1),typeRegOptForceSets{i,j}),2};
            cmodel = cfunc(cmodel,cmodel.rxns(posOptForceSets(i,j)));
        end
    end
    csol = optimizeCbModel(cmodel);
    cmodel.lb(find(cmodel.c)) = csol.x(find(cmodel.c));
    cmodel.c = double(ismember(model.rxns,target));
    cmodel.osenseStr = 'min';
    csol = optimizeCbModel(cmodel);
    if ~(csol.x(ismember(model.rxns,target)) > ores)
        solutionsValid = false;
        return
    end    
end

