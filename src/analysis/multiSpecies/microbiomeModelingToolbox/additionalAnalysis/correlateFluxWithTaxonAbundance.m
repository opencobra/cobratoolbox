function [FluxCorrelations, PValues, TaxonomyInfo] = correlateFluxWithTaxonAbundance(abundancePath, fluxPath, infoFilePath, corrMethod)
% Part of the Microbiome Modeling Toolbox. This function calculates and
% plots the correlations between fluxes for one or more reactions of
% interest in a number of microbiome samples and the relative microbe
% abundance on different taxonomical levels in the same samples.
% The function should be used after running mgPipe to identify correlations
% between the computed metabolic profiles and specific taxa in the samples.
%
% USAGE
%
%     [FluxCorrelations, PValues, TaxonomyInfo] = correlateFluxWithTaxonAbundance(abundancePath, fluxPath, taxonomy, corrMethod)
%
% INPUTS:
%    abundancePath:     Path to the .csv file with the abundance data.
%                       Needs to be in same format as example file
%                       'cobratoolbox/papers/018_microbiomeModelingToolbox/examples/normCoverage.csv'
%     fluxPath:         Path to the .csv file with the fluxes for reactions 
%                       of interest with sample IDs as rows and reaction
%                       IDs in microbiome community models as columns
%
% OPTIONAL INPUTS:
%    infoFilePath:      Path to the spreadsheet with the taxonomy information
%                       on organisms (default: AGORA_infoFile.xlsx)
%     corrMethod:       Method to compute the linear correlation
%                       coefficient. Allowed inputs: 'Pearson' (default),
%                       'Kendall', 'Spearman'.
%
% OUTPUTS:
%     FluxCorrelations: Structure with correlations between fluxes for each
%                       reaction and abundances on taxon levels
%     PValues:          p-values corresponding to each calculated
%                       correlation
%     TaxonomyInfo:     Taxonomical information on each taxon level 
%
% .. Author: Almut Heinken, 03/2018
%                           10/2018:  changed input to location of the csv file with the
%                                     abundance data
%                           01/2020:  adapted to be suitable for pan-models, and
%                                     changed flux input to a csv file.

% read the csv file with the abundance data
abundance = readInputTableForPipeline(abundancePath);
if isnumeric(abundance{2, 1})
    abundance(:, 1) = [];
end
% adapt IDs if neccessary
abundance(1,2:end) = strrep(abundance(1,2:end),'-','_');

fluxes = readInputTableForPipeline(fluxPath);

% check if data is from same samples
if ~isempty(setdiff(fluxes(1,2:end),abundance(1,2:end)))
    error('Sample IDs in abundance and flux files do not agree!')
end

% load database
database=loadVMHDatabase;

fluxes(:,1)=strrep(fluxes(:,1),'EX_','');
fluxes(:,1)=strrep(fluxes(:,1),'(e)','');
fluxes(:,1)=strrep(fluxes(:,1),'[fe]','');
% for i=2:size(fluxes,1)
% fluxes{i,1}=database.metabolites{find(strcmp(database.metabolites(:,1),fluxes{i,1})),2};
% end

% Get the taxonomy information
if exist('infoFilePath','var')
    taxonomy = readInputTableForPipeline(infoFilePath);
else
    taxonomy = readInputTableForPipeline('AGORA_infoFile.xlsx');
end

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

% Find the right column for the input data (strains, species,..)
if sum(strncmp(abundance(:,1),'pan',3))==size(abundance,1)-1
abundance(:,1)=regexprep(abundance(:,1),'pan','','once');
end
inputTaxa={};
for i=1:size(taxonomy,2)
    taxa=strrep(taxonomy(:,i),' ','_');
    taxa=strrep(taxa,'.','_');
    taxa=strrep(taxa,'/','_');
    taxa=strrep(taxa,'-','_');
    taxa=strrep(taxa,'__','_');
    if length(intersect(abundance(2:end,1),taxa))==size(abundance,1)-1
        inputTaxa=taxa;
        inputCol=i;
        break
    end
end
if isempty(inputTaxa)
    error('Some taxa in the abundance file are not found in the taxonomy file!')
end

for i = 2:size(abundance, 2)
    for j = 2:size(abundance, 1)
        for t = 1:size(TaxonomyLevels, 1)
            % find the taxon for the current strain
            taxonCol = find(strcmp(taxonomy(1, :), TaxonomyLevels{t}));
            if taxonCol >= inputCol
            findTax = taxonomy(find(strcmp(abundance{j, 1}, inputTaxa)), taxonCol);
            if isempty(strfind(findTax{1}, 'unclassified'))
                % find the taxon for the current strain in the sample abundance
                % variable
                findinSampleAbun = find(strcmp(findTax{1}, SampleAbundance.(TaxonomyLevels{t})(1, :)));
                % sum up the relative abundance
                if contains(version,'(R202') % for Matlab R2020a and newer
                    SampleAbundance.(TaxonomyLevels{t}){i, findinSampleAbun} = SampleAbundance.(TaxonomyLevels{t}){i, findinSampleAbun} + abundance{j, i};
                else
                    SampleAbundance.(TaxonomyLevels{t}){i, findinSampleAbun} = SampleAbundance.(TaxonomyLevels{t}){i, findinSampleAbun} + str2double(abundance{j, i});
                end
            end
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

% remove entries that are only weak correlations and empty taxonomy entries
for t = 1:size(TaxonomyLevels, 1)
    cnt=1;
    delArray=[];
    for j=2:size(FluxCorrelations.(TaxonomyLevels{t}),2)
        if ~any(abs(cell2mat(FluxCorrelations.(TaxonomyLevels{t})(2:end,j))) > 0.6)
            delArray(cnt,1)=j;
            cnt=cnt+1;
        end
    end
    FluxCorrelations.(TaxonomyLevels{t})(:,delArray)=[];
    
    cnt=1;
    delArray=[];
    for j=2:size(FluxCorrelations.(TaxonomyLevels{t}),1)
        if ~any(abs(cell2mat(FluxCorrelations.(TaxonomyLevels{t})(j,2:end))) > 0.6)
            delArray(cnt,1)=j;
            cnt=cnt+1;
        end
    end
    FluxCorrelations.(TaxonomyLevels{t})(delArray,:)=[];

    FluxCorrelations.(TaxonomyLevels{t})(find(strcmp(FluxCorrelations.(TaxonomyLevels{t})(:,1),'')),:)=[];
end

% translate to metabolite descriptions
for t = 2:size(TaxonomyLevels, 1)
    for i=2:size(FluxCorrelations.(TaxonomyLevels{t}),2)
        FluxCorrelations.(TaxonomyLevels{t}){1,i}=database.metabolites{find(strcmp(database.metabolites(:,1),FluxCorrelations.(TaxonomyLevels{t}){1,i})),2};
    end
end

% export taxonomical information
taxonCol = 'Phylum';
% remove unnecessary columns
taxonomy(:,taxonCol+1:end)=[];

for t = 2:size(TaxonomyLevels, 1)
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

set(0, 'DefaultTextInterpreter', 'none')

% Plot the calculated correlations.
for t = 1:length(TaxonomyLevels)
    data = string(FluxCorrelations.(TaxonomyLevels{t})(2:end, 2:end));
    data = str2double(data);

    if size(FluxCorrelations.(TaxonomyLevels{t}),2) < 50
        cgo = clustergram(data,...
            'RowLabels', FluxCorrelations.(TaxonomyLevels{t})(2:end,1),...
            'ColumnLabels', FluxCorrelations.(TaxonomyLevels{t})(1,2:end),...
            'ColumnLabelsRotate', 45, ...
            'Cluster', 'all', ...
            'ShowDendrogram','True', ...
            'symmetric','False', ...
            'colormap', 'turbo' ...
            );
    else
        cgo = clustergram(data,...
            'RowLabels', FluxCorrelations.(TaxonomyLevels{t})(2:end,1),...
            'Cluster', 'all', ...
            'ShowDendrogram','True', ...
            'symmetric','False', ...
            'colormap', 'turbo' ...
            );
    end
    h = plot(cgo);
    set(h,'TickLabelInterpreter','none');
    colorbar(h)
end

end
