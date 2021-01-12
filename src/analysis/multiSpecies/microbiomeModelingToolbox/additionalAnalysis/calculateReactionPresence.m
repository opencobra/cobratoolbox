function [ReactionPresence,ReactionPresenceDifferent]=calculateReactionPresence(abundancePath, modelPath, rxnsList)
% Part of the Microbiome Modeling Toolbox. This function calculates and
% plots the absolute presence of reactions of interest in a given microbiome
% sample based on the strain-level composition. Two outputs are given: the
% reaction presence and absence for all reactions in all microbiomes and
% only the presence/absence of reactions that are different in at least one
% microbiome.
%
% USAGE
%
%    [ReactionPresence,ReactionPresenceDifferent]=calculateReactionPresence(abundancePath, modelPath, rxnsList)
%
% INPUTS:
%    abundancePath:             Path to the .csv file with the abundance data.
%                               Example: 'cobratoolbox/papers/018_microbiomeModelingToolbox/examples/normCoverage.csv'
%    modelPath:                 Folder containing the strain-specific AGORA models
% OPTIONAL INPUTS:
%    rxnsList:                  List of reactions for which the abundance
%                               should be calculated (if left empty: all
%                               reactions in all models)
%
% OUTPUT:
%    ReactionPresence:          Table with absolute reaction presence forl
%                               all reactions in all microbiome samples
%    ReactionPresenceDifferent: Table with absolute reaction presence for
%                               reactions in all microbiome samples that
%                               were different in at least two samples
%
% .. Author: - Almut Heinken, 01/2021

% read the file with the abundance data
abundance = readtable(abundancePath, 'ReadVariableNames', false);
abundance = table2cell(abundance);
if isnumeric(abundance{2, 1})
    abundance(:, 1) = [];
end

% load the models
for i = 2:size(abundance, 1)
    load([modelPath filesep abundance{i, 1} '.mat']);
%     model = readCbModel([modelPath filesep abundance{i, 1} '.mat']);
    modelsList{i, 1} = model;
end

if ~exist('rxnsList', 'var') || isempty(rxnsList)  % define reaction list if not entered
    fprintf('No reaction list entered. Abundances will be calculated for all reactions in all models. \n')
    % get model list from abundance input file
    for i = 2:size(abundance, 1)
        model = modelsList{i, 1};
        rxnsList = vertcat(model.rxns, rxnsList);
    end
    rxnsList = unique(rxnsList);
end

for j=2:length(modelsList)
    model=modelsList{j};
    reactionInModels{1,j}=abundance{j, 1};
    for i=1:length(rxnsList)
        reactionInModels{i+1,1}=rxnsList{i};
        if ~isempty(find(ismember(model.rxns,rxnsList{i})))
            reactionInModels{i+1,j}=1;
        else
            reactionInModels{i+1,j}=0;
        end
    end
end

microbes=abundance(2:end,1);
for i=2:size(abundance,2)
    ReactionPresence{1,i}=abundance{1,i};
    microbesInModels=microbes(find(str2double(abundance(2:end,i))>0),1);
    for j=2:size(reactionInModels,1)
        ReactionPresence{j,1}=reactionInModels{j,1};
        microbesWithReaction=microbes(find(cell2mat(reactionInModels(j,2:end))==1),1);
        [C,IA,IB] = intersect(microbesInModels,microbesWithReaction);
        if ~isempty(C)
            ReactionPresence{j,i}=1;
        else
            ReactionPresence{j,i}=0;
        end
    end
end

% Save only reactions with different presence
ReactionPresenceDifferent=ReactionPresence;
delRows=[];
cnt=1;
for i=2:size(ReactionPresenceDifferent,1)
    % if all entries in row are the same
   if length(unique(cell2mat(ReactionPresenceDifferent(i,2:end))))==1
       delRows(cnt,1)=i;
       cnt=cnt+1;
   end
end
ReactionPresenceDifferent(delRows,:)=[];

end