function [FluxCorrelations]=correlateFluxWithTaxonAbundance(abundance,fluxes,taxonomy,corrMethod,rxnsList)
% This function calculates the total abundance of reactions of interest in
% a given microbiome sample based on the strain-level composition.
%
% USAGE
% [FluxCorrelations]=calculateFluxCorrelations(abundance,modelFolder,taxonomy,rxnsList,numWorkers)
%
% Reaction presence or absence in each strain is derived from the reaction content
% of the respective AGORA model. Two outputs are given: the total abundance,
% and optionally the abundance on different taxonomical levels.
%
% INPUTS
% abundance            Table of relative abundances with AGORA model IDs
%                      of the strains as rows and sample IDs as columns
% fluxes               Table with reaction IDs in microbiome 
%                      community models as rows and sample IDs as columns
% taxonomy             Table with information on the taxonomy of each
%                      AGORA model strain
% OPTIONAL INPUTS
% corrMethod           String of method to compute the linear correlation
%                      coefficient. Allowed inputs: Pearson (default),
%                      Kendall, Spearman.
% rxnsList             List of reactions in the flux table for which
%                      correlations with taxon abundance should be
%                      calculated (if left empty: all fluxes in table)
%
% OUTPUT
% FluxCorrelations     Structure with correlations between fluxes for each
%                      reaction and abundances on taxon levels

% define reaction list if not entered
if ~exist(rxnsList,'var')
    % get reaction ID list from fluxes input file
    rxnsList=fluxes(2:end,1);
end

% Define correlation coefficient method if not entered
if ~exist(corrMethod,'var')
    corrMethod='Pearson';
end

% Calculate the abundance in each sample on all taxon levels
TaxonomyLevels={
    'Phylum'
    'Class'
    'Order'
    'Family'
    'Genus'
    'Species'
    };
% extract the list of entries on each taxonomical level
for t=1:size(TaxonomyLevels,1)
    % find the columns corresponding to each taxonomy level and the list of
    % unique taxa
    taxonCol=find(strcmp(taxonomy(1,:),TaxonomyLevels{t}));
    % find and save all entries
    taxa=unique(taxonomy(2:end,taxonCol));
    % exclude unclassified entries
    taxa(strncmp('unclassified',taxa,taxonCol))=[];
    for i=1:length(taxa)
        SampleAbundance.(TaxonomyLevels{t}){1,i+1}=taxa{i};
        for j=2:size(abundance,2)
            SampleAbundance.(TaxonomyLevels{t}){j,1}=abundance{1,j};
            SampleAbundance.(TaxonomyLevels{t}){j,i+1}=0;
            % summarize the abundances of all strains belonging to the
            % respective taxon
            for k=2:size(abundance,1)
                if strcmp(taxa{i},taxonomy(find(strcmp(abundance{k,1},taxonomy(:,1)))),taxonCol)
                    SampleAbundance.(TaxonomyLevels{t}){j,i+1}=SampleAbundance.(TaxonomyLevels{t}){j,i+1}+abundance{k,j};
                end
            end
        end
    end
    % remove the taxa not present in samples or only present in small abundances
    delArray=[];
    cnt=1;
    for i=2:size(SampleAbundance.(TaxonomyLevels{t}),2)
        for j=2:size(SampleAbundance.(TaxonomyLevels{t}),1)
            abun(j-1,1)=SampleAbundance.(TaxonomyLevels{t}){j,i};
        end
        if sum(abun) <0.005
            delArray(cnt)=i;
            cnt=cnt+1;
        end
    end
    SampleAbundance.(TaxonomyLevels{t})(delArray)=[];
end

% find the flux data for each reaction
for i=2:size(fluxes,1)
    data=[];
    for j=2:size(fluxes,2)
        data(j,1)=str2double(string(fluxes{i,j}));
    end
    for t=1:size(TaxonomyLevels,1)
        FluxCorrelations.(TaxonomyLevels{t}){1,i}=fluxes{i,1};
        % find the abundance data for each taxon
        for j=2:size(SampleAbundance.(TaxonomyLevels{t}),2)
            FluxCorrelations.(TaxonomyLevels{t}){j,1}=SampleAbundance.(TaxonomyLevels{t}){1,j};
            % find the abundance data for each sample
            for k=2:size(SampleAbundance.(TaxonomyLevels{t}),1)
                % match with correct individual in flux table
                sampleInFluxes=find(strcmp(fluxes(1,:),SampleAbundance.(TaxonomyLevels{t}){k,1}));
                data(j,sampleInFluxes)=str2double(string(SampleAbundance.(TaxonomyLevels{t}){k,1}));
            end
            % first row is empty
            data(1,:)=[];
            % calculate the correlation with the given correlation coefficient method
            [RHO,PVAL] = corr(data(:,1),data(:,2),'type',corrMethod);
            FluxCorrelations.(TaxonomyLevels{t}){j,i}=RHO;
        end
    end
end

end
