function model = untargetedGapFilling(model,osenseStr,database)
% This script is part of the DEMETER pipeline and attemps to find a
% reaction from the complete reaction database that could enable flux 
% through the objective function. This function will be performed only if 
% targeted gap-filling failed.
%
% USAGE:
%
%   model = untargetedGapFilling(model,osenseStr,database)
%
% INPUTS
% model:              COBRA model structure
% osenseStr:          Maximize ('max')/minimize ('min')linear part of the 
%                     objective.
% database:           rBioNet reaction database containing min. 3 columns:
%                     Column 1: reaction abbreviation, Column 2: reaction
%                     name, Column 3: reaction formula.
%
% OUTPUT
% model:               Gapfilled COBRA model structure
%
% .. Authors:
%       - Almut Heinken, 2016-2020

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
    
    % get first successfull gapfilling reactions if any
    gfInd = find(abs(growth) > tol);
    
    if ~isempty(gfInd)
        for i=1:length(gfInd)
            model = addReaction(model, [database.reactions{gfInd(i),1} '_untGF'], database.reactions{gfInd(1),3});
        end
    end
end

end