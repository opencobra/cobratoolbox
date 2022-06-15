function plotFluxesAgainstOrganismAbundances(abundancePath,fluxPath,metabolites)
% Part of the Microbiome Modeling Toolbox. This function plots the 
% relationship between organism abundances and the computed flux profiles
% for metabolites of interest. The function should be used after running 
% mgPipe to identify correlations between metabolites and specific taxa in 
% the samples.
%
% USAGE
%
%     plotFluxesAgainstOrganismAbundances(fluxPath,abundancePath,metabolites)
%
% INPUTS:
%   abundancePath:     Path to the .csv file with the abundance data.
%                      Needs to be in same format as example file
%                      'cobratoolbox/papers/018_microbiomeModelingToolbox/examples/normCoverage.csv'
%   fluxPath:          Path to the .csv file with the fluxes for reactions 
%                      of interest with sample IDs as rows and reaction
%                      IDs in microbiome community models as columns
% OPTIONAL INPUT:
%   metabolites:       Cell array with VMH metabolite IDs of metabolites to 
%                      plot (default: all computed metabolites)
%
% .. Author: Almut Heinken, 02/2021

mkdir('Metabolite_plots')
cd('Metabolite_plots')

% load reaction abundances
abundance = readInputTableForPipeline(abundancePath);

% load fluxes
fluxes = readInputTableForPipeline(fluxPath);
% adapt IDs if neccessary
abundance(1,2:end) = strrep(abundance(1,2:end),'-','_');

% check if data is from same samples
if ~isempty(setdiff(fluxes(1,2:end),abundance(1,2:end)))
    error('Sample IDs in abundance and flux files do not agree!')
end

% load database
database=loadVMHDatabase;

if nargin>2
    [~,IA]=setdiff(fluxes(:,1),metabolites,'stable');
    fluxes(IA(2:end),:)=[];
end

for i=2:size(fluxes,1)
    fluxes{i,1}=database.metabolites{find(strcmp(database.metabolites(:,1),fluxes{i,1})),2};
    data=[];
    for j=2:size(fluxes,2)
        if contains(version,'(R202') % for Matlab R2020a and newer
            data(j-1,1)=fluxes{i,j};
        else
            data(j-1,1)=str2double(fluxes{i,j});
        end
    end
    if abs(sum(data(:,1)))>0.000001
        for j=2:size(abundance,1)
            for k=2:size(fluxes,2)
                if contains(version,'(R202') % for Matlab R2020a and newer
                    data(k-1,2)=abundance{j,find(strcmp(abundance(1,:),fluxes{1,k}))};
                else
                    data(k-1,2)=str2double(abundance{j,find(strcmp(abundance(1,:),fluxes{1,k}))});
                end
            end
            f=figure;
            scatter(data(:,1),data(:,2),'b','filled','o','MarkerEdgeColor','black')
            hold on
            h=xlabel(fluxes{i,1});
            set(h,'interpreter','none')
            orgLabel=strrep(abundance{j,1},'pan','');
            orgLabel=strrep(orgLabel,'_',' ');
            h=ylabel(orgLabel);
            set(h,'interpreter','none')
            set(gca, 'FontSize', 14);
            title('Relative abundances vs. reaction fluxes (mmol*gDW-1*hr-1)')
            f.Renderer='painters';
            print([fluxes{i,1} '_' abundance{j,1}],'-dpng','-r300')
        end
        close all
    end
end

cd ..

end
