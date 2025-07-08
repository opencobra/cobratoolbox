function microbiomeMappingStats(rawPath,marsPath,saveDir,metadataPath)
% Function for obtaining statistics on AGORA2 mapping
% 
% INPUT
% rawPath: path to the unfiltered microbiome data
% marsPath: path to mapped microbiome data
% saveDir: path to folder where the results are saved

% For mapped, unmapped, and total. Obtain the:
% read counts + coverage X
% number of microbes per taxonomic level X
% taxon relative abundances X
% alpha diversity
% beta diversity 


%% PART 0: Initialise table for saving all statistical results
% Create index sheet for saved results
n=7;
tableNames = append("Table ",string(1:n)');
indexTable = table(tableNames,string(zeros(n,1)),'VariableNames',{'Table','Descriptions'});

indexTable.Descriptions(1) = 'FBA solver statistics';
indexTable.Descriptions(2) = 'FBA original solver statistics';
indexTable.Descriptions(3) = 'Number of flux limiting taxa per sample';
indexTable.Descriptions(4) = 'Number of samples containing each flux limiting taxon';
indexTable.Descriptions(5) = 'Summary statistics for flux limiting taxa';
indexTable.Descriptions(6) = 'Distribution statistics of optimised reactions';
indexTable.Descriptions(7) = 'Summary statistics predicted fluxes';

% Add index table to results structure
mapping_stats = struct;
mapping_stats.Index = indexTable;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PART 1: Processing of unmapped data

% Read unfiltered microbiome data
microbiome = readtable(rawPath);
% microbiome.Var1=[];

% Obtain samples of interest by checking the metadata
% Load metadata in memory
metadata = readtable(metadataPath);

% Remove samples not in the metadata
samples = microbiome.Properties.VariableNames(2:end)';
sampRm = setdiff(samples,metadata.ID);
microbiome(:,matches(microbiome.Properties.VariableNames',sampRm))=[];


% Obtain taxa
% disp('Load unfiltered microbiome data')
% taxa = regexprep(microbiome.Taxon,'\|','_');
% 
% % Find names for each taxonomy
% hierarchy = {'k','p','c','o','f','g','s',''};
% taxaTable = repmat("",length(taxa),length(hierarchy)-1);
% for i = 1:width(taxaTable)
%     % Get the name of taxon level hierarchy{i}
%     expression = strcat('(?<=',hierarchy{i},'__)(.*?)(?=_',hierarchy{i+1},'__)');
%     taxon = regexp(taxa,expression,'match');
%     % If the current taxon level is the most precise definition, alter the
%     % regular expression
%     taxon(cellfun(@isempty,taxon)) = regexp(taxa(cellfun(@isempty,taxon)),strcat('(?<=',hierarchy{i},'__).*'),'match');
%     % Save taxa
%     taxaTable(:,i) = string(cellfun(@(x) string(x{:}), taxon,'UniformOutput',false)); 
% end
% 
% % Add taxa to microbiome table
% taxonLevels = {'Kingdom','Phylum','Class','Order','Family','Genus','Species'};
% taxaTable = array2table(taxaTable,'VariableNames',taxonLevels);
% microbiome = [taxaTable microbiome];
% microbiome.Taxon = [];
% 
% % Find the species read coverages
% disp('Find species read coverage')
% kingdom = microbiome(matches(microbiome.Phylum,""),:);
% species = microbiome(~matches(microbiome.Species,""),:);
% taxaVars = find(matches(microbiome.Properties.VariableNames,'Species'))+1;

% Sum the total reads for the species and for the kingdom data. The species
% read coverage is obtained by dividing the kindom level reads by the
% species level reads.
% k_reads = sum(kingdom{:,taxaVars:end});
% s_reads = sum(species{:,taxaVars:end});
% speciesReadCoverage = [k_reads' s_reads' s_reads'./k_reads'];
%speciesReadCoverageTable = array2table(speciesReadCoverage,'VariableNames',{'All reads','Species reads','Coverage'});
%
% Obtain the mean, sd, and non 1 coverage
% speciesCoverageStats = [mean(speciesReadCoverage); std(speciesReadCoverage); min(speciesReadCoverage); max(speciesReadCoverage)];
% speciesCoverageStatsTable = array2table(speciesCoverageStats);
% speciesCoverageStatsTable.Properties.VariableNames = {'Total reads','Species level reads','Coverage'};
% speciesCoverageStatsTable.Properties.RowNames = {'Mean','SD','Min','Max'};
% 
% % Add mapping raw mapping coverage to mapping_stats
% mapping_stats.species_coverage_stats = speciesCoverageStatsTable;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add mapping information
%%
% Change outdated species names
% microbiome.Taxon = regexprep(microbiome.Taxon,"_group","");
% microbiome.Taxon(matches(microbiome.Taxon,"Ruminococcus_gnavus")) = "Blautia_gnavus";
% microbiome.Taxon(matches(microbiome.Taxon,"Ruminococcus_torques")) = "Blautia_torques";
% microbiome.Taxon(matches(microbiome.Taxon,"Clostridium_innocuum")) = "Erysipelatoclostridium_innocuum";
microbiome.Taxon(matches(microbiome.Taxon,{'Ruminococcus champanellensis'})) = {'Ruminococcus chamellensis'};
microbiome.Taxon(matches(microbiome.Taxon,{'Companilactobacillus farciminis'})) = {'Comilactobacillus farciminis'};

% Load mapped species
disp('Adding AGORA2 mapping info')
MARS = readtable(marsPath);
MARS.Taxon = string(erase(MARS.Taxon,'pan'));
MARS = MARS(:,'Taxon');

% Find mapped and unmapped species
sum(matches(microbiome.Taxon,MARS.Taxon))
%mistakes = setdiff(MARS.Taxon, microbiome.Taxon)

microbiome.mapped = matches(microbiome.Taxon,MARS.Taxon);
microbiome = movevars(microbiome,'mapped','After','Taxon');

% Filter on species
species = microbiome(~matches(microbiome.Taxon,""),:);

% Save species microbiome data
%speciesMapped = species(species.mapped==1,:);
%speciesMapped(:,{'Kingdom','Class','Order','Family','Genus'})=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the number of taxa per taxonomic level
% For each data groups
% disp('Find number of unique taxa per taxonomic level')
% dataGroups = {1:length(species.mapped),find(~species.mapped),find(species.mapped)};
% 
% % Preallocate table
% taxaCount = array2table(zeros(length(taxonLevels),length(dataGroups)),...
%     'RowNames',taxonLevels,'VariableNames',{'Total','Unmapped','Mapped'});
% for j = 1:length(dataGroups)
% 
%     % Get total, unmapped, and mapped taxa
%     speciesTaxaCountVar = species(dataGroups{j},:);
% 
%     % Get only the taxa
%     taxaNum = find(matches(speciesTaxaCountVar.Properties.VariableNames,'Taxon'));
%     taxaCountVar= speciesTaxaCountVar(:,1:taxaNum);
%     taxaNames = string(taxaCountVar.Properties.VariableNames);
% 
%     % Find the number of unique taxa per group
%     for i=1:length(taxaNames)
%         taxaCount{i,j} = length(unique(taxaCountVar.(taxaNames(i))));
%     end
% end
% 
% % Save table with the number of unique taxa per group
% mapping_stats.number_of_taxa = taxaCount;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate read coverages  
disp('Calculate read coverage of mapped taxa')

abundanceVars = find(matches(species.Properties.VariableNames,'mapped'))+1;
specAbundances = zeros(length(abundanceVars:width(species)),3);
specAbundances(:,1) = sum(table2array(species(:,abundanceVars:end)),1);
specAbundances(:,2) = sum(table2array(species(~species.mapped,abundanceVars:end)),1);
specAbundances(:,3) = sum(table2array(species(species.mapped,abundanceVars:end)),1);

% Create table with read abundances: total, mapped, unmapped
specAbundances = array2table(specAbundances,'VariableNames',{'total','unmapped','mapped'});
specAbundances.ID = species.Properties.VariableNames(abundanceVars:end)';
specAbundances = movevars(specAbundances,'ID','before','total');

% Calculate read coverages
specAbundances.covered = specAbundances.mapped./specAbundances.total;
specAbundances.notcovered = specAbundances.unmapped./specAbundances.total;

% Save table
specAbunPath = [saveDir filesep 'speciesCoverages.xlsx'];
mapping_stats.mapping_coverage = specAbundances;

% Obtain summary statistics
f = @(x) [mean(x) std(x)];
rowNames = {'Total species read counts','Unmapped species reads','Mapped species reads','Species reads not covered','Species read coverage'}';
statValues = [f(specAbundances.total);f(specAbundances.unmapped);f(specAbundances.mapped);f(specAbundances.covered);f(specAbundances.notcovered)];
stats = table(rowNames,statValues(:,1),statValues(:,2),'VariableNames',{'Statistic','Mean','SD'});
mapping_stats.mapping_coverage_stats = stats;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Obtain species relative abundances for total, mapped, and unmapped
disp('Calculate species relative abundances')
spAbunStatsTotal = getRelAbundanceStats(species);
spAbunStatsUnmapped = getRelAbundanceStats(species(~species.mapped,:));
spAbunStatsMapped = getRelAbundanceStats(species(species.mapped,:));

% Save statistics
specRelAbunPath = [saveDir filesep 'speciesRelAbunStats.xlsx'];
writetable(spAbunStatsTotal,specRelAbunPath,'Sheet','Total')
writetable(spAbunStatsUnmapped,specRelAbunPath,'Sheet','Umapped')
writetable(spAbunStatsMapped,specRelAbunPath,'Sheet','Mapped')
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the number of samples where each species is present 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate alpha diversities
disp('Calculate diversity metrics')
abundanceVars = find(matches(species.Properties.VariableNames,'mapped'))+1;
abundanceArray = species{:,abundanceVars:end};
abundanceArray= abundanceArray./sum(abundanceArray,1);

% Remove counts with relative abundances below the threshold
threshold=1e-6;
abundanceArray(abundanceArray<threshold)=0;
% Get all zero and nonzero reads
abundanceArray(abundanceArray~=0)=1;

% Calculate alpha diversity for total microbes
alphaDiv=[sum(abundanceArray)' sum(abundanceArray(species.mapped==1,:))'];

% Generate table for alpha diversities
IDs = string(species.Properties.VariableNames(abundanceVars:end))';
alphaDivTable = table(IDs,alphaDiv(:,1),alphaDiv(:,2),'VariableNames',{'ID','alpha total','alpha mapped'});

% Save table
alphaDivPath= [saveDir filesep 'alphaDiversities.csv'];
writetable(alphaDivTable,alphaDivPath)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate phylum-level reads
% level = "Phylum";
% disp(strcat("Calculate ",level," relative abundances"))
% taxonAbunTotal = getTaxonLevelReadCounts(species, level);
% taxonAbunUnmapped = getTaxonLevelReadCounts(species(~species.mapped,:), level);
% taxonAbunMapped = getTaxonLevelReadCounts(species(species.mapped,:), level);
% 
% % Obtain phylum-level statistics
% taxonAbunStatsTotal = getRelAbundanceStats(taxonAbunTotal);
% taxonAbunStatsUnmapped = getRelAbundanceStats(taxonAbunUnmapped);
% taxonAbunStatsMapped = getRelAbundanceStats(taxonAbunMapped);
% 
% % Save statistics
% taxonRelAbunPath = [saveDir filesep strcat(char(level),'RelAbunStats.xlsx')];
% writetable(taxonAbunStatsTotal,taxonRelAbunPath,'Sheet','Total')
% writetable(taxonAbunStatsUnmapped,taxonRelAbunPath,'Sheet','Umapped')
% writetable(taxonAbunStatsMapped,taxonRelAbunPath,'Sheet','Mapped')
% 
% 
% % Save phylum microbiome data
% taxonMappedReadsPath = [saveDir filesep strcat(char(level),'MappedProcessed.csv')];
% writetable(taxonAbunMapped, taxonMappedReadsPath);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper functions

function spAbunStats = getRelAbundanceStats(speciesAbundances)

% Get sample variables

abundanceVars = find(matches(speciesAbundances.Properties.VariableNames,'mapped'))+1;
if isempty(abundanceVars)
    abundanceVars = find(matches(speciesAbundances.Properties.VariableNames,'Phylum'))+1;
    level = "Phylum";
else
    level = "Taxon";
end


% Calculate relative abundances
abundanceArray = speciesAbundances{:,abundanceVars:end};
abundanceArray= abundanceArray./sum(abundanceArray,1);

% Remove counts with relative abundances below the threshold
threshold=1e-6;
abundanceArray(abundanceArray<threshold)=0;

% Calculate abundances summary statistics: nonzero, min, max, median, mean, sd
statFun = @(x) [sum(x~=0,2) min(x,[],2) max(x,[],2) median(x,2) mean(x,2) std(x,[],2)];

% Create table with statistics
spAbunStats = array2table(statFun(abundanceArray),...
    'VariableNames',{'Presence in model','minimum','maximum','median','mean','SD'});

spAbunStats.(level) = speciesAbundances.(level);
spAbunStats = movevars(spAbunStats,char(level),'Before','Presence in model');
spAbunStats = sortrows(spAbunStats,'mean','descend');

end

function taxonAbun = getTaxonLevelReadCounts(taxonSummary, level)

% Get sample variables
abundanceVars = find(matches(taxonSummary.Properties.VariableNames,'mapped'))+1;

% Find taxon groups
[group,Taxon] = findgroups(taxonSummary.(level));

% Calculate the total reads per taxonomic group for each sample
taxonAbun = zeros(length(unique(group)),length(abundanceVars:width(taxonSummary.Properties.VariableNames)));
for i = 1:length(unique(group))
    taxonSummaryArray = taxonSummary{:,abundanceVars:end};
    taxonAbun(i,:)=sum(taxonSummaryArray(group==i,:),1);
end

% Create table
taxonAbun = array2table(taxonAbun,...
    'VariableNames',taxonSummary.Properties.VariableNames(abundanceVars:end));
taxonAbun.(level) = Taxon;
taxonAbun = movevars(taxonAbun,char(level),'Before',1);
end


