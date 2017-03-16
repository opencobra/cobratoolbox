% test that the pairwise models created by script BuildPairwiseModels have 
% all reactions of the respective microbe reconstructions that were joined.

load pairedModelsList;
for i=2:size(pairedModelsList,1)
    load(pairedModelsList{i,1});
    load(pairedModelsList{i,2});
    assert(length(model.mets) == length(strmatch(pairedModelsList{i,2},pairedModel.mets)))
    assert(length(model.rxns) == length(strmatch(pairedModelsList{i,2},pairedModel.rxns)))
    load(pairedModelsList{i,5});
    assert(length(model.mets) == length(strmatch(pairedModelsList{i,5},pairedModel.mets)))
    assert(length(model.rxns) == length(strmatch(pairedModelsList{i,5},pairedModel.rxns)))
end
