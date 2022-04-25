function [ReactionAbundance,TaxonomyInfo] = calculateReactionAbundance(abundancePath, modelPath, taxonomyPath, rxnsList, numWorkers)
% Part of the Microbiome Modeling Toolbox. This function calculates and
% plots the total abundance of reactions of interest in a given microbiome
% sample based on the strain-level composition.
% Reaction presence or absence in each strain is derived from the reaction content
% of the respective AGORA model. Two results are given: the total abundance,
% and the abundance on different taxonomical levels.
%
% USAGE
%
%    [ReactionAbundance,TaxonomyInfo] = calculateReactionAbundance(abundancePath, modelPath, taxonomyPath, rxnsList, numWorkers)
%
% INPUTS:
%    abundancePath:          Path to the .csv file with the abundance data.
%                            Example: 'cobratoolbox/papers/018_microbiomeModelingToolbox/examples/normCoverage.csv'
%    modelPath:              Folder containing the strain-specific AGORA models
% OPTIONAL INPUTS:
%    taxonomyPath:           Path to the spreadsheet with the taxonomy
%                            information on organisms (default:
%                            AGORA_infoFile.xlsx)
%    rxnsList:               List of reactions for which the abundance
%                            should be calculated (if left empty: all
%                            reactions in all models)
%    numWorkers:             Number of workers used for parallel pool. If
%                            left empty, the parallel pool will not be
%                            started. Parallellization is recommended if
%                            all reactions are computed.
%
% OUTPUT:
%    ReactionAbundance       Structure with abundance for each microbiome
%                            and reaction in total and on taxon levels
%     TaxonomyInfo:          Taxonomical information on each taxon level
%
% .. Author: - Almut Heinken, 03/2018
%                             10/2018:  changed input to location of the csv file with the
%                                       abundance data
%                           01/2020:    adapted to be suitable for pan-models

% read the csv file with the abundance data
abundance = readInputTableForPipeline(abundancePath);
if isnumeric(abundance{2, 1})
    abundance(:, 1) = [];
end
% adapt IDs if neccessary
abundance(1,2:end) = strrep(abundance(1,2:end),'-','_');

%

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

% Get the taxonomy information
if exist('taxonomyPath','var') && ~isempty(taxonomyPath)
    taxonomy = readInputTableForPipeline(taxonomyPath);
else
    taxonomy = readInputTableForPipeline('AGORA_infoFile.xlsx');
end

% load the models found in the individuals and extract which reactions are
% in which model
for i = 2:size(abundance, 1)
    model = modelsList{i, 1};
    ReactionPresence{i, 1} = abundance{i, 1};
    for j = 1:length(rxnsList)
        ReactionPresence{1, j + 1} = rxnsList{j};
        if ~isempty(find(ismember(model.rxns, rxnsList{j})))
            ReactionPresence{i, j + 1} = 1;
        else
            ReactionPresence{i, j + 1} = 0;
        end
    end
end

% put together a Matlab structure of the results
ReactionAbundance = struct;

% prepare table for the total abundance
for j = 1:length(rxnsList)
    ReactionAbundance.('Total'){1, j + 1} = rxnsList{j};
end

TaxonomyLevels = {
    'Phylum'
    'Class'
    'Order'
    'Family'
    'Genus'
    'Species'
    };
% extract the list of entries on each taxonomical level
for t = 1:size(TaxonomyLevels, 1)
    % find the columns corresponding to each taxonomy level and the list of
    % unique taxa
    taxonCol = find(strcmp(taxonomy(1, :), TaxonomyLevels{t}));
    % find and save all entries
    taxa = unique(taxonomy(2:end, taxonCol));
    % exclude unclassified entries
    taxa(strncmp('unclassified', taxa, taxonCol)) = [];
    TaxonomyLevels{t, 2} = taxa;
    % define the correct columns in taxonomy table
    TaxonomyLevels{t, 3} = taxonCol;
    % prepare table for the abundance on taxon levels
    cnt = 2;
    for j = 1:length(rxnsList)
        for l = 1:length(TaxonomyLevels{t, 2})
            ReactionAbundance.(TaxonomyLevels{t, 1}){1, cnt} = strcat(TaxonomyLevels{t, 2}{l}, '_', rxnsList{j});
            cnt = cnt + 1;
        end
    end
end

% Find the right column for the input data (strains, species,..)
taxa=taxonomy(2:end,1);
if length(intersect(abundance(2:end,1),taxa))==size(abundance,1)-1
    inputTaxa=taxa;
    inputCol=1;
else
    abundance(:,1)=regexprep(abundance(:,1),'pan','','once');
    inputTaxa={};
    for i=2:size(taxonomy,2)
        taxa=strrep(taxonomy(:,i),' ','_');
        taxa=strrep(taxa,'.','_');
        taxa=strrep(taxa,'/','_');
        taxa=strrep(taxa,'-','_');
        taxa=strrep(taxa,'__','_');
        if length(intersect(abundance(2:end,1),taxa))==size(abundance,1)-1
            inputTaxa=taxa;
            inputCol=i;
        end
    end
end
if isempty(inputTaxa)
    error('Some taxa in the abundance file are not found in the taxonomy file!')
end

for i = 2:size(abundance, 2)
    %% calculate reaction abundance for the samples one by one
    fprintf(['Calculating reaction abundance for sample ', num2str(i - 1), ' of ' num2str(size(abundance, 2) - 1) '.. \n'])
    ReactionAbundance.('Total'){i, 1} = abundance{1, i};
    for t = 1:size(TaxonomyLevels, 1)
        ReactionAbundance.(TaxonomyLevels{t, 1}){i, 1} = abundance{1, i};
    end
    % use parallel pool if workers specified as input
    if exist('numWorkers', 'var') && numWorkers > 0
        poolobj = gcp('nocreate');
        if isempty(poolobj)
            parpool(numWorkers)
        end
    end
    % create tables in which abundances for each individual for
    % all reactions/taxa are stored
    totalAbun = zeros(length(rxnsList), 1);
    phylumAbun = zeros(length(rxnsList), length(TaxonomyLevels{1, 2}));
    classAbun = zeros(length(rxnsList), length(TaxonomyLevels{2, 2}));
    orderAbun = zeros(length(rxnsList), length(TaxonomyLevels{3, 2}));
    familyAbun = zeros(length(rxnsList), length(TaxonomyLevels{4, 2}));
    genusAbun = zeros(length(rxnsList), length(TaxonomyLevels{5, 2}));
    speciesAbun = zeros(length(rxnsList), length(TaxonomyLevels{6, 2}));
    
    parfor j = 1:length(rxnsList)
        
        % store the abundance for each reaction and taxon separately in a
        % temporary file to enable parallellization
        tmpPhyl = zeros(length(rxnsList), length(TaxonomyLevels{1, 2}));
        tmpClass = zeros(length(rxnsList), length(TaxonomyLevels{2, 2}));
        tmpOrder = zeros(length(rxnsList), length(TaxonomyLevels{3, 2}));
        tmpFamily = zeros(length(rxnsList), length(TaxonomyLevels{4, 2}));
        tmpGenus = zeros(length(rxnsList), length(TaxonomyLevels{5, 2}));
        tmpSpecies = zeros(length(rxnsList), length(TaxonomyLevels{6, 2}));
        
        for k = 2:size(abundance, 1)
            % check if the reaction is present in the strain
            if ReactionPresence{k, j + 1} == 1
                % calculate total abundance
                if contains(version,'(R202') % for Matlab R2020a and newer
                    totalAbun(j) = totalAbun(j) + abundance{k, i};
                else
                    totalAbun(j) = totalAbun(j) + str2double(abundance{k, i});
                end
                % calculate phylum abundance
                t = 1;
                findTax = taxonomy(find(strcmp(abundance{k, 1}, inputTaxa)), TaxonomyLevels{t, 3});
                if any(strcmp(findTax{1}, TaxonomyLevels{t, 2}))
                    taxonCol = find(strcmp(findTax{1}, TaxonomyLevels{t, 2}));
                    if contains(version,'(R202') % for Matlab R2020a and newer
                        tmpPhyl(1, taxonCol) = tmpPhyl(1, taxonCol) + abundance{k, i};
                    else
                        tmpPhyl(1, taxonCol) = tmpPhyl(1, taxonCol) + str2double(abundance{k, i});
                    end
                end
                % calculate class abundance
                t = 2;
                findTax = taxonomy(find(strcmp(abundance{k, 1}, inputTaxa)), TaxonomyLevels{t, 3});
                if any(strcmp(findTax{1}, TaxonomyLevels{t, 2}))
                    taxonCol = find(strcmp(findTax{1}, TaxonomyLevels{t, 2}));
                    if contains(version,'(R202') % for Matlab R2020a and newer
                        tmpClass(1, taxonCol) = tmpClass(1, taxonCol) + abundance{k, i};
                    else
                        tmpClass(1, taxonCol) = tmpClass(1, taxonCol) + str2double(abundance{k, i});
                    end
                end
                % calculate order abundance
                t = 3;
                findTax = taxonomy(find(strcmp(abundance{k, 1}, inputTaxa)), TaxonomyLevels{t, 3});
                if any(strcmp(findTax{1}, TaxonomyLevels{t, 2}))
                    taxonCol = find(strcmp(findTax{1}, TaxonomyLevels{t, 2}));
                    if contains(version,'(R202') % for Matlab R2020a and newer
                        tmpOrder(1, taxonCol) = tmpOrder(1, taxonCol) + abundance{k, i};
                    else
                        tmpOrder(1, taxonCol) = tmpOrder(1, taxonCol) + str2double(abundance{k, i});
                    end
                end
                % calculate family abundance
                t = 4;
                findTax = taxonomy(find(strcmp(abundance{k, 1}, inputTaxa)), TaxonomyLevels{t, 3});
                if any(strcmp(findTax{1}, TaxonomyLevels{t, 2}))
                    taxonCol = find(strcmp(findTax{1}, TaxonomyLevels{t, 2}));
                    if contains(version,'(R202') % for Matlab R2020a and newer
                        tmpFamily(1, taxonCol) = tmpFamily(1, taxonCol) + abundance{k, i};
                    else
                        tmpFamily(1, taxonCol) = tmpFamily(1, taxonCol) + str2double(abundance{k, i});
                    end
                end
                % calculate genus abundance
                t = 5;
                findTax = taxonomy(find(strcmp(abundance{k, 1}, inputTaxa)), TaxonomyLevels{t, 3});
                if any(strcmp(findTax{1}, TaxonomyLevels{t, 2}))
                    taxonCol = find(strcmp(findTax{1}, TaxonomyLevels{t, 2}));
                    if contains(version,'(R202') % for Matlab R2020a and newer
                        tmpGenus(1, taxonCol) = tmpGenus(1, taxonCol) + abundance{k, i};
                    else
                        tmpGenus(1, taxonCol) = tmpGenus(1, taxonCol) + str2double(abundance{k, i});
                    end
                end
                % calculate species abundance
                t = 6;
                findTax = taxonomy(find(strcmp(abundance{k, 1}, inputTaxa)), TaxonomyLevels{t, 3});
                if any(strcmp(findTax{1}, TaxonomyLevels{t, 2}))
                    taxonCol = find(strcmp(findTax{1}, TaxonomyLevels{t, 2}));
                    if contains(version,'(R202') % for Matlab R2020a and newer
                        tmpSpecies(1, taxonCol) = tmpSpecies(1, taxonCol) + abundance{k, i};
                    else
                        tmpSpecies(1, taxonCol) = tmpSpecies(1, taxonCol) + str2double(abundance{k, i});
                    end
                end
            end
        end
        phylumAbun(j, :) = tmpPhyl(1, :);
        classAbun(j, :) = tmpClass(1, :);
        orderAbun(j, :) = tmpOrder(1, :);
        familyAbun(j, :) = tmpFamily(1, :);
        genusAbun(j, :) = tmpGenus(1, :);
        speciesAbun(j, :) = tmpSpecies(1, :);
    end
    %% store the abundances total and on taxonomic levels calculated for the individual in the output structure
    for j = 1:length(rxnsList)
        ReactionAbundance.('Total'){i, j + 1} = totalAbun(j);
        % abundance on taxon levels
    end
    % phylum abundance
    t = 1;
    cnt = 2;
    for j = 1:length(rxnsList)
        for l = 1:length(TaxonomyLevels{t, 2})
            ReactionAbundance.(TaxonomyLevels{t}){i, cnt} = phylumAbun(j, l);
            cnt = cnt + 1;
        end
    end
    % class abundance
    t = 2;
    cnt = 2;
    for j = 1:length(rxnsList)
        for l = 1:length(TaxonomyLevels{t, 2})
            ReactionAbundance.(TaxonomyLevels{t}){i, cnt} = classAbun(j, l);
            cnt = cnt + 1;
        end
    end
    % order abundance
    t = 3;
    cnt = 2;
    for j = 1:length(rxnsList)
        for l = 1:length(TaxonomyLevels{t, 2})
            ReactionAbundance.(TaxonomyLevels{t}){i, cnt} = orderAbun(j, l);
            cnt = cnt + 1;
        end
    end
    % family abundance
    t = 4;
    cnt = 2;
    for j = 1:length(rxnsList)
        for l = 1:length(TaxonomyLevels{t, 2})
            ReactionAbundance.(TaxonomyLevels{t}){i, cnt} = familyAbun(j, l);
            cnt = cnt + 1;
        end
    end
    % genus abundance
    t = 5;
    cnt = 2;
    for j = 1:length(rxnsList)
        for l = 1:length(TaxonomyLevels{t, 2})
            ReactionAbundance.(TaxonomyLevels{t}){i, cnt} = genusAbun(j, l);
            cnt = cnt + 1;
        end
    end
    % species abundance
    t = 6;
    cnt = 2;
    for j = 1:length(rxnsList)
        for l = 1:length(TaxonomyLevels{t, 2})
            ReactionAbundance.(TaxonomyLevels{t}){i, cnt} = speciesAbun(j, l);
            cnt = cnt + 1;
        end
    end
end

% finally, delete empty columns to avoid unneccessarily big file sizes
fprintf('Finalizing the output file... \n')

fNames = fieldnames(ReactionAbundance);
for i = 1:length(fNames)
    cValues = string(ReactionAbundance.(fNames{i})(2:end, 2:end));
    rownames=ReactionAbundance.(fNames{i})(:,1);
    ReactionAbundance.(fNames{i})(:,1)=[];
    cTotal = sum(str2double(cValues),1);
    ReactionAbundance.(fNames{i})(:,find(cTotal<0.000000001))=[];
    ReactionAbundance.(fNames{i})=[rownames,ReactionAbundance.(fNames{i})];
    ReactionAbundance.(fNames{i}){1,1}='Samples';
end

% export taxonomical information
taxonCol = 'Phylum';
% remove unnecessary columns
taxonomy(:,taxonCol+1:end)=[];

for t = 2:size(TaxonomyLevels, 1)
    taxa=ReactionAbundance.(TaxonomyLevels{t})(2:end,1);
    TaxonomyReduced=taxonomy;
    taxonCol = find(strcmp(taxonomy(1, :), TaxonomyLevels{t}));
    TaxonomyReduced(:,1:taxonCol-1)=[];
    % remove duplicate entries
    [C,IA] = unique(TaxonomyReduced(:,1),'stable');
    % remove unclassified taxa
    findUncl=find(contains(C,'unclassified'));
    IA(findUncl,:)=[];
    TaxonomyInfo.(TaxonomyLevels{t})=TaxonomyReduced(IA,:);
end

% Plot the calculated reaction abundances.
for i = 1:length(fNames)
    xlabels = ReactionAbundance.(fNames{i})(2:end,1);
    ylabels = ReactionAbundance.(fNames{i})(1,2:end);
    data = string(ReactionAbundance.(fNames{i})(2:end, 2:end));
    data = str2double(data);
    figure;
    imagesc(data')
    colormap('hot')
    colorbar
    if length(xlabels) < 50
        set(gca, 'xtick', 1:length(xlabels));
        xticklabels(xlabels);
        xtickangle(90)
    end
    if length(ylabels) < 50
        set(gca, 'ytick', 1:length(ylabels));
        yticklabels(ylabels);
    end
    set(gca, 'TickLabelInterpreter', 'none');
    title(fNames{i})
end

end