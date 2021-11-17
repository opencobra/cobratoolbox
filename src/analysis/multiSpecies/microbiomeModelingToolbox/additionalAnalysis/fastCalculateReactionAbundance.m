function [ReactionAbundance,ReactionPresence] = fastCalculateReactionAbundance(abundancePath, modelPath, rxnsList, numWorkers)
% Part of the Microbiome Modeling Toolbox. This function calculates and
% plots the total abundance of reactions of interest in a given microbiome
% sample based on the strain-level composition.
% Reaction presence or absence in each strain is derived from the reaction content
% of the respective AGORA model.
%
% USAGE
%
%    ReactionAbundance = fastCalculateReactionAbundance(abundancePath, modelPath, rxnsList, numWorkers)
%
% INPUTS:
%    abundancePath:          Path to the .csv file with the abundance data.
%                            Example: 'cobratoolbox/papers/018_microbiomeModelingToolbox/examples/normCoverage.csv'
%    modelPath:              Folder containing the strain-specific AGORA models
% OPTIONAL INPUTS:
%    rxnsList:               List of reactions for which the abundance
%                            should be calculated (if left empty: all
%                            reactions in all models)
%    numWorkers:             Number of workers used for parallel pool. If
%                            left empty, the parallel pool will not be
%                            started. Parallellization is recommended if
%                            all reactions are computed.
%
% OUTPUT:
%    ReactionAbundance       Table with total abundance for each microbiome
%                            and reaction
%    ReactionPresence:       Table with absolute reaction presence for
%                            all reactions in all microbiome samples
%
% .. Author: - Almut Heinken, 04/2021

% read the csv file with the abundance data
abundance = readInputTableForPipeline(abundancePath);
if isnumeric(abundance{2, 1})
    abundance(:, 1) = [];
end

% load the models
for i = 2:size(abundance, 1)
    model = readCbModel([modelPath filesep abundance{i, 1} '.mat']);
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

% load the models found in the individuals and extract which reactions are
% in which model
for i = 2:size(abundance, 1)
    model = modelsList{i, 1};
    ReactionPresenceInModels{i, 1} = abundance{i, 1};
    for j = 1:length(rxnsList)
        ReactionPresenceInModels{1, j + 1} = rxnsList{j};
        if ~isempty(find(ismember(model.rxns, rxnsList{j})))
            ReactionPresenceInModels{i, j + 1} = '1';
        else
            ReactionPresenceInModels{i, j + 1} = '0';
        end
    end
end
ReactionPresenceInModels{1,1}='Strains';

% prepare table for the total abundance
ReactionAbundance = {};
for i = 2:size(abundance, 2)
    ReactionAbundance{i, 1} = abundance{1, i};
end

% use parallel pool if workers specified as input
if exist('numWorkers', 'var') && numWorkers > 0
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end

clear abundance
clear modelsList

totalAbun={};
parfor i = 2:size(ReactionAbundance, 1)
    % reload the file to avoid running out of memory
    abundance = readInputTableForPipeline(abundancePath);
    if isnumeric(abundance{2, 1})
        abundance(:, 1) = [];
    end
    
    % temporarily store reaction abundances
    totalAbun{i} = zeros(length(rxnsList), 1);
    
    for j = 2:size(abundance, 1)
        % find all reactions present in the strain
        presentRxns = find(strcmp(ReactionPresenceInModels(j,2:end),'1'));
        
        for k = 1:length(presentRxns)
            % summarize total abundance
            if contains(version,'(R202') % for Matlab R2020a and newer
                totalAbun{i}(presentRxns(k),1) = totalAbun{i}(presentRxns(k),1) + abundance{j,i};
            else
                totalAbun{i}(presentRxns(k),1) = totalAbun{i}(presentRxns(k),1) + str2double(abundance{j,i});
            end
        end
    end
end

for i = 1:length(rxnsList)
    ReactionAbundance{1, i + 1} = rxnsList{i};
end

% collect the temporarily stored abundances to put together the table
for i = 2:size(ReactionAbundance, 1)
    ReactionAbundance(i,2:end) = num2cell(totalAbun{i});
end

% export the absolute reaction presence
tol=0.0000001;

ReactionPresence = ReactionAbundance;
for i=2:size(ReactionPresence,1)
    for j=2:size(ReactionPresence,2)
        if contains(version,'(R202') % for Matlab R2020a and newer
            val = ReactionPresence{i,j};
        else
            val = str2double(ReactionPresence{i,j});
        end
        if val > tol
            ReactionPresence{i,j} = 1;
        else
            ReactionPresence{i,j} = 0;
        end
    end
end

end