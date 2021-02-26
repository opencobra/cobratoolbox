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
abundance = table2cell(readtable(abundancePath, 'ReadVariableNames', false));

% load fluxes
fluxes = table2cell(readtable(fluxPath, 'ReadVariableNames', false));

metaboliteDatabase = readtable('MetaboliteDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
metaboliteDatabase=table2cell(metaboliteDatabase);

fluxes(:,1)=strrep(fluxes(:,1),'EX_','');
fluxes(:,1)=strrep(fluxes(:,1),'(e)','');
fluxes(:,1)=strrep(fluxes(:,1),'[fe]','');

if nargin>2
    [~,IA]=setdiff(fluxes(:,1),metabolites,'stable');
    fluxes(IA(2:end),:)=[];
end

for i=2:size(fluxes,1)
    fluxes{i,1}=metaboliteDatabase{find(strcmp(metaboliteDatabase(:,1),fluxes{i,1})),2};
    data=[];
    for j=2:size(fluxes,2)
    data(j-1,1)=str2double(fluxes{i,j});
    end
    if abs(sum(data(:,1)))>0.000001
    for j=2:size(abundance,1)
        for k=2:size(fluxes,2)
            data(k-1,2)=str2double(abundance{j,find(strcmp(abundance(1,:),fluxes{1,k}))});
        end
        f=figure;
        scatter(data(:,1),data(:,2),'b','filled','o','MarkerEdgeColor','black')
        hold on
        box on
        h=xlabel(fluxes{i,1});
        set(h,'interpreter','none')
        orgLabel=strrep(abundance{j,1},'pan','');
        orgLabel=strrep(orgLabel,'_',' ');
        h=ylabel(orgLabel);
        set(h,'interpreter','none')
        set(gca, 'FontSize', 9);
        title('Relative abundances vs. reaction fluxes (mmol*gDW-1*hr-1)')
        f.Renderer='painters';
        print([fluxes{i,1} '_' abundance{j,1}],'-dpng','-r300')
    end
    close all
    end
end

cd ..

end
