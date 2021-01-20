function model = untargetedGapFilling(model,osenseStr,database)
% Only perform this script if model cannot grow, otherwise no additional gap-filling
% needed.
% Will be performed only if targeted gap-filling failed. Will add
% reaction(s) derived from the complete database that can restore growth.

% remove human reactions from database
humanComp = {'[m]','[l]','[x]','[r]','[g]','[u]','[ev]','[eb]','[ep]'};
database.reactions(contains(database.reactions(:,3),humanComp),:)=[];

% remove reactions already in model from database
[C,IA,IC] = intersect(database.reactions(:,1),model.rxns);
database.reactions(IA,:) = [];

tol=0.00001;

FBA = optimizeCbModel(model,osenseStr);
if abs(FBA.f) < tol
    % find reaction(s) from the complete reaction database that can enable
    % growth
    while abs(FBA.f) < tol
        growth=[];
        modelOld=model;
        
        for i=1:size(database.reactions,1)
            model = addReaction(model, [database.reactions{i,1} '_untGF'], database.reactions{i,3});
            FBA = optimizeCbModel(model,osenseStr);
            growth(i) = FBA.f;
            if abs(FBA.f) > tol
                modelOld=addReaction(modelOld, [database.reactions{i,1} '_untGF'], database.reactions{i,3});
                model=modelOld;
                break
            end
        end
        FBA = optimizeCbModel(model,osenseStr);
    end
    % get first successfull gapfilling reactions if any
    gfInd = find(abs(growthTmp) > tol);
    
    if ~isempty(gfInd)
        for i=1:length(gfInd)
            model = addReaction(model, [database.reactions{gfInd(i),1} '_untGF'], database.reactions{gfInd(1),3});
        end
    end
end

end