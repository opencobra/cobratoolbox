function ReactionAbundance = calculateReactionAbundance(abundancePath, modelPath, rxnsList, numWorkers)
% Part of the Microbiome Modeling Toolbox. This function calculates and
% plots the total abundance of reactions of interest in a given microbiome
% sample based on the strain-level composition.
% Reaction presence or absence in each strain is derived from the reaction content
% of the respective AGORA model. Two outputs are given: the total abundance,
% and the abundance on different taxonomical levels.
%
% USAGE
%
%    ReactionAbundance =calculateReactionAbundance(abundancePath, modelPath, rxnsList, numWorkers)
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
%    ReactionAbundance       Structure with abundance for each microbiome
%                            and reaction in total and on taxon levels
%
% .. Author: - Almut Heinken, 03/2018
%                             10/2018:  changed input to location of the csv file with the
%                                       abundance data

% read the csv file with the abundance data
abundance = readtable(abundancePath, 'ReadVariableNames', false);
abundance = table2cell(abundance);
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

% Get the taxonomy information
taxonomy = readtable('AGORA_infoFile.xlsx', 'ReadVariableNames', false);
taxonomy = table2cell(taxonomy);

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

for i = 2:size(abundance, 2)
    %% calculate reaction abundance for the samples one by one
    fprintf(['Calculating reaction abundance for sample ', num2str(i - 1), ' of ' num2str(size(abundance, 2) - 1) '.. \n'])
    ReactionAbundance.('Total'){i, 1} = abundance{1, i};
    if ~isempty(taxonomy)
        for t = 1:size(TaxonomyLevels, 1)
            ReactionAbundance.(TaxonomyLevels{t, 1}){i, 1} = abundance{1, i};
        end
    end
    % use parallel pool if workers specified as input
    if exist('numWorkers', 'var') && numWorkers > 0
        poolobj = gcp('nocreate');
        if isempty(poolobj)
            parpool(numWorkers)
        end
        % create tables in which abundances for each individual for
        % all reactions/taxa are stored
        totalAbun = zeros(length(rxnsList), 1);
        if ~isempty(taxonomy)
            phylumAbun = zeros(length(rxnsList), length(TaxonomyLevels{1, 2}));
            classAbun = zeros(length(rxnsList), length(TaxonomyLevels{2, 2}));
            orderAbun = zeros(length(rxnsList), length(TaxonomyLevels{3, 2}));
            familyAbun = zeros(length(rxnsList), length(TaxonomyLevels{4, 2}));
            genusAbun = zeros(length(rxnsList), length(TaxonomyLevels{5, 2}));
            speciesAbun = zeros(length(rxnsList), length(TaxonomyLevels{6, 2}));
        end
        parfor j = 1:length(rxnsList)
        % store the abundance for each reaction and taxon separately in a
        % temporary file to enable parallellization
            if ~isempty(taxonomy)
                tmpPhyl = zeros(length(rxnsList), length(TaxonomyLevels{1, 2}));
                tmpClass = zeros(length(rxnsList), length(TaxonomyLevels{2, 2}));
                tmpOrder = zeros(length(rxnsList), length(TaxonomyLevels{3, 2}));
                tmpFamily = zeros(length(rxnsList), length(TaxonomyLevels{4, 2}));
                tmpGenus = zeros(length(rxnsList), length(TaxonomyLevels{5, 2}));
                tmpSpecies = zeros(length(rxnsList), length(TaxonomyLevels{6, 2}));
            end
            for k = 2:size(abundance, 1)
                % check if the reaction is present in the strain
                if ReactionPresence{k, j + 1} == 1
                    % calculate total abundance
                    totalAbun(j) = totalAbun(j) + str2double(abundance{k, i});
                    if ~isempty(taxonomy)
                        % calculate phylum abundance
                        t = 1;
                        findTax = taxonomy(find(strcmp(abundance{k, 1}, taxonomy(:, 1))), TaxonomyLevels{t, 3});
                        if any(strcmp(findTax, TaxonomyLevels{t, 2}))
                            taxonCol = find(strcmp(findTax, TaxonomyLevels{t, 2}));
                            tmpPhyl(1, taxonCol) = tmpPhyl(1, taxonCol) + str2double(abundance{k, i});
                        end
                        % calculate class abundance
                        t = 2;
                        findTax = taxonomy(find(strcmp(abundance{k, 1}, taxonomy(:, 1))), TaxonomyLevels{t, 3});
                        if any(strcmp(findTax, TaxonomyLevels{t, 2}))
                            taxonCol = find(strcmp(findTax, TaxonomyLevels{t, 2}));
                            tmpClass(1, taxonCol) = tmpClass(1, taxonCol) + str2double(abundance{k, i});
                        end
                        % calculate order abundance
                        t = 3;
                        findTax = taxonomy(find(strcmp(abundance{k, 1}, taxonomy(:, 1))), TaxonomyLevels{t, 3});
                        if any(strcmp(findTax, TaxonomyLevels{t, 2}))
                            taxonCol = find(strcmp(findTax, TaxonomyLevels{t, 2}));
                            tmpOrder(1, taxonCol) = tmpOrder(1, taxonCol) + str2double(abundance{k, i});
                        end
                        % calculate family abundance
                        t = 4;
                        findTax = taxonomy(find(strcmp(abundance{k, 1}, taxonomy(:, 1))), TaxonomyLevels{t, 3});
                        if any(strcmp(findTax, TaxonomyLevels{t, 2}))
                            taxonCol = find(strcmp(findTax, TaxonomyLevels{t, 2}));
                            tmpFamily(1, taxonCol) = tmpFamily(1, taxonCol) + str2double(abundance{k, i});
                        end
                        % calculate genus abundance
                        t = 5;
                        findTax = taxonomy(find(strcmp(abundance{k, 1}, taxonomy(:, 1))), TaxonomyLevels{t, 3});
                        if any(strcmp(findTax, TaxonomyLevels{t, 2}))
                            taxonCol = find(strcmp(findTax, TaxonomyLevels{t, 2}));
                            tmpGenus(1, taxonCol) = tmpGenus(1, taxonCol) + str2double(abundance{k, i});
                        end
                        % calculate species abundance
                        t = 6;
                        findTax = taxonomy(find(strcmp(abundance{k, 1}, taxonomy(:, 1))), TaxonomyLevels{t, 3});
                        if any(strcmp(findTax, TaxonomyLevels{t, 2}))
                            taxonCol = find(strcmp(findTax, TaxonomyLevels{t, 2}));
                            tmpSpecies(1, taxonCol) = tmpSpecies(1, taxonCol) + str2double(abundance{k, i});
                        end
                    end
                end
            end
            if ~isempty(taxonomy)
                phylumAbun(j, :) = tmpPhyl(1, :);
                classAbun(j, :) = tmpClass(1, :);
                orderAbun(j, :) = tmpOrder(1, :);
                familyAbun(j, :) = tmpFamily(1, :);
                genusAbun(j, :) = tmpGenus(1, :);
                speciesAbun(j, :) = tmpSpecies(1, :);
            end
        end
    else
        % create tables in which abundances for each individual for
        % all reactions/taxa are stored
        % no parallellization-takes longer
        totalAbun = zeros(length(rxnsList), 1);
        if ~isempty(taxonomy)
            phylumAbun = zeros(length(rxnsList), length(TaxonomyLevels{1, 2}));
            classAbun = zeros(length(rxnsList), length(TaxonomyLevels{2, 2}));
            orderAbun = zeros(length(rxnsList), length(TaxonomyLevels{3, 2}));
            familyAbun = zeros(length(rxnsList), length(TaxonomyLevels{4, 2}));
            genusAbun = zeros(length(rxnsList), length(TaxonomyLevels{5, 2}));
            speciesAbun = zeros(length(rxnsList), length(TaxonomyLevels{6, 2}));
        end
        for j = 1:length(rxnsList)
            for k = 2:size(abundance, 1)
                % check if the reaction is present in the strain
                if ReactionPresence{k, j + 1} == 1
                    % calculate total abundance
                    totalAbun(j) = totalAbun(j) + str2double(abundance{k, i});
                    if ~isempty(taxonomy)
                        % calculate phylum abundance
                        t = 1;
                        findTax = taxonomy(find(strcmp(abundance{k, 1}, taxonomy(:, 1))), TaxonomyLevels{t, 3});
                        if any(strcmp(findTax, TaxonomyLevels{t, 2}))
                            taxonCol = find(strcmp(findTax, TaxonomyLevels{t, 2}));
                            phylumAbun(j, taxonCol) = phylumAbun(j, taxonCol) + str2double(abundance{k, i});
                        end
                        % calculate class abundance
                        t = 2;
                        findTax = taxonomy(find(strcmp(abundance{k, 1}, taxonomy(:, 1))), TaxonomyLevels{t, 3});
                        if any(strcmp(findTax, TaxonomyLevels{t, 2}))
                            taxonCol = find(strcmp(findTax, TaxonomyLevels{t, 2}));
                            classAbun(j, taxonCol) = classAbun(j, taxonCol) + str2double(abundance{k, i});
                        end
                        % calculate order abundance
                        t = 3;
                        findTax = taxonomy(find(strcmp(abundance{k, 1}, taxonomy(:, 1))), TaxonomyLevels{t, 3});
                        if any(strcmp(findTax, TaxonomyLevels{t, 2}))
                            taxonCol = find(strcmp(findTax, TaxonomyLevels{t, 2}));
                            orderAbun(j, taxonCol) = orderAbun(j, taxonCol) + str2double(abundance{k, i});
                        end
                        % calculate family abundance
                        t = 4;
                        findTax = taxonomy(find(strcmp(abundance{k, 1}, taxonomy(:, 1))), TaxonomyLevels{t, 3});
                        if any(strcmp(findTax, TaxonomyLevels{t, 2}))
                            taxonCol = find(strcmp(findTax, TaxonomyLevels{t, 2}));
                            familyAbun(j, taxonCol) = familyAbun(j, taxonCol) + str2double(abundance{k, i});
                        end
                        % calculate genus abundance
                        t = 5;
                        findTax = taxonomy(find(strcmp(abundance{k, 1}, taxonomy(:, 1))), TaxonomyLevels{t, 3});
                        if any(strcmp(findTax, TaxonomyLevels{t, 2}))
                            taxonCol = find(strcmp(findTax, TaxonomyLevels{t, 2}));
                            genusAbun(j, taxonCol) = genusAbun(j, taxonCol) + str2double(abundance{k, i});
                        end
                        % calculate species abundance
                        t = 6;
                        findTax = taxonomy(find(strcmp(abundance{k, 1}, taxonomy(:, 1))), TaxonomyLevels{t, 3});
                        if any(strcmp(findTax, TaxonomyLevels{t, 2}))
                            taxonCol = find(strcmp(findTax, TaxonomyLevels{t, 2}));
                            speciesAbun(j, taxonCol) = speciesAbun(j, taxonCol) + str2double(abundance{k, i});
                        end
                    end
                end
            end
        end
    end
    %% store the abundances total and on taxonomic levels calculated for the individual in the output structure
    for j = 1:length(rxnsList)
        ReactionAbundance.('Total'){i, j + 1} = totalAbun(j);
        % abundance on taxon levels
    end
    if ~isempty(taxonomy)
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
end

% finally, delete empty columns to avoid unneccessarily big file sizes
fprintf('Finalizing the output file... \n')

fNames = fieldnames(ReactionAbundance);
for i = 1:length(fNames)
    cnt = 1;
    delArray = [];
    for j = 2:size(ReactionAbundance.(fNames{i}), 2)
        cValues = string(ReactionAbundance.(fNames{i})(2:end, j));
        cTotal = sum(str2double(cValues));
        if cTotal < 0.000000001
            delArray(1, cnt) = j;
            cnt = cnt + 1;
        end
    end
    if ~isempty(delArray)
        ReactionAbundance.(fNames{i})(:, delArray) = [];
    end
end

% Plot the calculated reaction abundances.
for i = 1:length(fNames)
    xlabels = ReactionAbundance.(fNames{i})(1, 2:end);
    ylabels = ReactionAbundance.(fNames{i})(2:end, 1);
    data = string(ReactionAbundance.(fNames{i})(2:end, 2:end));
    data = str2double(data);
    figure;
    imagesc(data)
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
