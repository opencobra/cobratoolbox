function [FluxCorrelations, PValues] = correlateFluxWithTaxonAbundance(abundancePath, fluxes, corrMethod)
% Part of the Microbiome Modeling Toolbox. This function calculates and
% plots the correlations between fluxes for one or more reactions of
% interest in a number of microbiome samples and the relative microbe
% abundance on different taxonomical levels in the same samples.
% The function should be used after running mgPipe to identify correlations
% between the computed metabolic profiles and specific taxa in the samples.
%
% USAGE
%
%     [FluxCorrelations, PValues] = correlateFluxWithTaxonAbundance(abundancePath, fluxes, taxonomy, corrMethod)
%
% INPUTS:
%    abundancePath:     Path to the .csv file with the abundance data.
%                       Needs to be in same format as example file
%                       'cobratoolbox/papers/018_microbiomeModelingToolbox/examples/normCoverage.csv'
%     fluxes:           Table of fluxes for reactions of interest with
%                       reaction IDs in microbiome community models as rows
%                       and sample IDs as columns
%
% OPTIONAL INPUTS:
%     corrMethod:       Method to compute the linear correlation
%                       coefficient. Allowed inputs: 'Pearson' (default),
%                       'Kendall', 'Spearman'.
%
% OUTPUTS:
%     FluxCorrelations: Structure with correlations between fluxes for each
%                       reaction and abundances on taxon levels
%     PValues:          p-values corresponding to each calculated
%                       correlation
%
% .. Author: Almut Heinken, 03/2018
%                           10/2018:  changed input to location of the csv file with the
%                                     abundance data

% read the csv file with the abundance data
abundance = readtable(abundancePath, 'ReadVariableNames', false);
abundance = table2cell(abundance);
if isnumeric(abundance{2, 1})
    abundance(:, 1) = [];
end

% Get the taxonomy information
taxonomy = readtable('AGORA_infoFile.xlsx', 'ReadVariableNames', false);
taxonomy = table2cell(taxonomy);

if ~exist('corrMethod', 'var')  % Define correlation coefficient method if not entered
    corrMethod = 'Pearson';
end

% Calculate the abundance in each sample on all taxon levels
TaxonomyLevels = {
    'Phylum'
    'Class'
    'Order'
    'Family'
    'Genus'
    'Species'
};
% extract the list of entries on each taxonomical level and prepare the
% summarized abundance table
fprintf('Calculating the relative abundances on all taxon levels. \n')
for t = 1:size(TaxonomyLevels, 1)
    % find the columns corresponding to each taxonomy level and the list of
    % unique taxa
    taxonCol = find(strcmp(taxonomy(1, :), TaxonomyLevels{t}));
    % find and save all entries
    taxa = unique(taxonomy(2:end, taxonCol));
    % exclude unclassified entries
    taxa(strncmp('unclassified', taxa, taxonCol)) = [];
    TaxonomyLevels{t, 2} = taxa;
    for i = 1:length(taxa)
        SampleAbundance.(TaxonomyLevels{t}){1, i + 1} = taxa{i};
        for j = 2:size(abundance, 2)
            SampleAbundance.(TaxonomyLevels{t}){j, 1} = abundance{1, j};
            SampleAbundance.(TaxonomyLevels{t}){j, i + 1} = 0;
        end
    end
end
% Go through the abundance data and summarize taxon abundances for each
% strain in at least one sample
for i = 2:size(abundance, 2)
    for j = 2:size(abundance, 1)
        for t = 1:size(TaxonomyLevels, 1)
            % find the taxon for the current strain
            taxonCol = find(strcmp(taxonomy(1, :), TaxonomyLevels{t}));
            findTax = taxonomy(find(strcmp(abundance{j, 1}, taxonomy(:, 1))), taxonCol);
            if isempty(strfind(findTax{1}, 'unclassified'))
                % find the taxon for the current strain in the sample abundance
                % variable
                findinSampleAbun = find(strcmp(findTax, SampleAbundance.(TaxonomyLevels{t})(1, :)));
                % sum up the relative abundance
                SampleAbundance.(TaxonomyLevels{t}){i, findinSampleAbun} = SampleAbundance.(TaxonomyLevels{t}){i, findinSampleAbun} + str2double(abundance{j, i});
            end
        end
    end
end
% remove the taxa not present in samples or only present in small abundances
for t = 1:size(TaxonomyLevels, 1)
    delArray = [];
    cnt = 1;
    for i = 2:size(SampleAbundance.(TaxonomyLevels{t}), 2)
        for j = 2:size(SampleAbundance.(TaxonomyLevels{t}), 1)
            abun(j - 1, 1) = SampleAbundance.(TaxonomyLevels{t}){j, i};
        end
        if sum(abun) < 0.005
            delArray(cnt, 1) = i;
            cnt = cnt + 1;
        end
    end
    SampleAbundance.(TaxonomyLevels{t})(:, delArray) = [];
end
% find the flux data for each reaction
fprintf('Calculating the correlations between fluxes and abundances. \n')
for i = 2:size(fluxes, 1)
    data = [];
    for m = 2:size(fluxes, 2)
        data(m - 1, 1) = str2double(string(fluxes{i, m}));
    end
    for t = 1:size(TaxonomyLevels, 1)
        FluxCorrelations.(TaxonomyLevels{t}){1, i} = fluxes{i, 1};
        PValues.(TaxonomyLevels{t}){1, i} = fluxes{i, 1};
        % find the abundance data for each taxon
        for j = 2:size(SampleAbundance.(TaxonomyLevels{t}), 2)
            FluxCorrelations.(TaxonomyLevels{t}){j, 1} = SampleAbundance.(TaxonomyLevels{t}){1, j};
            PValues.(TaxonomyLevels{t}){j, 1} = SampleAbundance.(TaxonomyLevels{t}){1, j};
            % find the abundance data for each sample
            dataTaxa = data;
            for k = 2:size(SampleAbundance.(TaxonomyLevels{t}), 1)
                % match with correct individual in flux table
                sampleInFluxes = find(strcmp(fluxes(1, :), SampleAbundance.(TaxonomyLevels{t}){k, 1}));
                dataTaxa(sampleInFluxes - 1, 2) = SampleAbundance.(TaxonomyLevels{t}){k, j};
            end
            % calculate the correlation with the given correlation coefficient method
            [RHO, PVAL] = corr(dataTaxa(:, 1), dataTaxa(:, 2), 'type', corrMethod);
            if isnan(RHO)
                RHO = 0;
            end
            if abs(RHO) < 0.0000000001
                RHO = 0;
            end
            FluxCorrelations.(TaxonomyLevels{t}){j, i} = RHO;
            PValues.(TaxonomyLevels{t}){j, i} = PVAL;
        end
    end
end

% Plot the calculated correlations.
for t = 1:length(TaxonomyLevels)
    xlabels = FluxCorrelations.(TaxonomyLevels{t})(1, 2:end);
    ylabels = FluxCorrelations.(TaxonomyLevels{t})(2:end, 1);
    data = string(FluxCorrelations.(TaxonomyLevels{t})(2:end, 2:end));
    data = str2double(data);
    figure;
    imagesc(data)
    colormap('cool')
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
    title(TaxonomyLevels{t})
end

end
