function [model,untGF] = untargetedGapFilling(model,biomassReaction,database)
% Only perform this script if model cannot grow, otherwise no additional gap-filling
% needed.
% Will be performed only if targeted gap-filling failed. Will add
% reaction(s) derived from the complete database that can restore growth.

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end
solver = CBT_LP_SOLVER;
environment = getEnvironment();

untGF = {};

% remove human reactions from database
humanComp = {'[m]','[l]','[x]','[r]','[g]','[u]','[ev]','[eb]','[ep]'};
database.reactions(contains(database.reactions(:,3),humanComp),:)=[];

% remove reactions already in model from database
[C,IA,IC] = intersect(database.reactions(:,1),model.rxns);
database.reactions(IA,:) = [];

tol=0.00001;

model=changeObjective(model,biomassReaction);
FBA = optimizeCbModel(model);
if FBA.f < tol
    % find reaction(s) from the complete reaction database that can enable
    % growth
    growthTmp=[];
    
    parfor i=1:size(database.reactions,1)
        restoreEnvironment(environment);
        changeCobraSolver(solver, 'LP', 0, -1);
        
        modelTmp = addReaction(model, database.reactions{i,1}, database.reactions{i,3});
        FBA = optimizeCbModel(modelTmp);
        growthTmp(i) = FBA.f;
    end
    
    % get first successfull gapfilling reaction if any
    gfInd = find(growthTmp > tol);
    
    if ~isempty(gfInd)
        model = addReaction(model, database.reactions{gfInd(1),1}, database.reactions{gfInd(1),3});
        untGF = database.reactions{gfInd(1),1};
    end
end

end