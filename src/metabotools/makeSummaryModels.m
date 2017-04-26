function [unionModel,intersectModel, diffRxns, diffExRxns] = makeSummaryModels(ResultsAllCellLines, samples, model, mk_union, mk_intersect, mk_reactionDiff)
% This function generates the union and the intersect model from the `modelPruned` in the `ResultsAllCellLines` structure.
%
% USAGE:
%
%    [unionModel, intersectModel, diffRxns, diffExRxns] = makeSummaryModels(ResultsAllCellLines, samples, model, mk_union, mk_intersect, mk_reactionDiff)
%
% INPUTS:
%    ResultsAllCellLines:                structure containing samples and models for the samples, e.g.,  `ResultsAllCellLines.UACC_257.modelPruned`
%    samples:                            conditions or cell lines, e.g., UACC_257
%
% OPTIONAL INPUTS:
%    mk_union:                           make union model, yes=1, no=0 (Default = 1)
%    mk_intersect:                       make intersect model, yes=1, no=0 (Default = 1)
%    mk_reactionDiff:                    make reactionDiff, yes=1, no=0 (can only be 1 if union and intersect are 1 or []) (Default = 1).
%
% OUTPUTS:
%    unionModel:                         model containing all reactions appearing at least once in the models in the `ResultsAllCellLines.sample.modelPruned`
%    intersectModel:                     model containing all reactions shared by all models in the `ResultsAllCellLines.sample.modelPruned`
%    diffRxns:                           all differential reactions that distinguish `unionModel` and `intersectModel`
%    diffExRxns:                         all differential exchange reactions that distinguish `unionModel` and `intersectModel`
%
% .. Author: - Maike Aurich 02/07/2015


if ~exist('mk_union','var') || isempty(mk_union)
    mk_union = 1;
end

if ~exist('mk_intersect','var') || isempty(mk_intersect)
    mk_intersect = 1;
end

if ~exist('mk_reactionDiff','var') || isempty(mk_reactionDiff)
    mk_reactionDiff = 1;
end

% make the union model (superCancermodel)
if mk_union == 1;
    reaction_vector = {};
    for i=1:length(samples)

        submodel = eval(['ResultsAllCellLines.' samples{i} '.modelPruned']);

        reaction_vector =union(reaction_vector,submodel.rxns);

        unionModel = extractSubNetwork(model,reaction_vector);
    end
else
    unionModel =[];
end
clear reaction_vector submodel

%%%make the intersect model

if mk_intersect == 1;
    reaction_vector = {};
    for i=1:length(samples)

        submodel = eval(['ResultsAllCellLines.' samples{i} '.modelPruned']);
        if i==1;
            reaction_vector = submodel.rxns;

        end
        reaction_vector =intersect(reaction_vector,submodel.rxns);

    end

    intersectModel = extractSubNetwork(model,reaction_vector);
else
    intersectModel =[];
end

clear reaction_vector submodel

%%find the variable exchange reactions between union and intersect model
diffRxns = unionModel.rxns(find(~ismember(unionModel.rxns, intersectModel.rxns)));

cnt=1;
for t=1:length(diffRxns)
    if  strfind(diffRxns{t}, 'EX_')
        diffExRxns(cnt,1) =diffRxns(t); %make exchange reaction list
        cnt=cnt+1;
    elseif  strfind(diffRxns{t}, 'Ex_')
        diffExRxns(cnt,1) =diffRxns(t); %make exchange reaction list
        cnt=cnt+1;
    end
end
end
