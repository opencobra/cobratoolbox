function makeViolinPlots(sampleData, sampleInformation, varargin)
% This function creates violin plots of input data (e.g., community model
% fluxes) while separating the data into two or more violins based on
% available sample stratification information.
%
% REQUIRED INPUTS
% sampleData           Table with input data to analyze (e.g., fluxes) with
%                      computed features as rows and sample IDs as columns
% sampleInformation    Table with information on analyzed samples including
%                      group classification with sample IDs as rows
%
% OPTIONAL INPUTS
% stratification       Column header containing the desired group
%                      classification in sampleInformation table. If not
%                      provided, the second column will be used.
% plottedFeature       Name of the feature to plot that will be displayed
%                      as the plot title (e.g., 'Fluxes')
% unit                 Unit of the plotted data that will be displayed as
%                      the y axis label (e.g., mmol/person/day)
%
% AUTHOR
%       - Almut Heinken, 12/2020

parser = inputParser();
parser.addRequired('sampleData', @iscell);
parser.addRequired('sampleInformation', @iscell);
parser.addParameter('stratification', '', @ischar);
parser.addParameter('plottedFeature', '', @ischar);
parser.addParameter('unit', '', @ischar);

parser.parse(sampleData, sampleInformation, varargin{:});

sampleData = parser.Results.sampleData;
sampleInformation = parser.Results.sampleInformation;
stratification = parser.Results.stratification;
plottedFeature = parser.Results.plottedFeature;
unit = parser.Results.unit;

% read metabolite database
metaboliteDatabase = readtable('MetaboliteDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
metaboliteDatabase=table2cell(metaboliteDatabase);

% find the column with the sample information to split the samples by
if ~isempty(stratification)
stratCol=find(strcmp(sampleInformation(1,:),stratification));
else
    stratCol=2;
end

% remove fluxes that are all zeros
cnt=1;
delArray=[];
for i=2:size(sampleData,1)
    if sum(str2double(sampleData(i,2:end)))<0.0001
        delArray(cnt,1)=i;
        cnt=cnt+1;
    end
end
sampleData(delArray,:)=[];

% use for violin plots
for i=2:size(sampleData,2)
    sampleStratification{i-1,1}=sampleInformation{find(strcmp(sampleInformation(:,1),sampleData{1,i})),stratCol};
end
for i=2:size(sampleData,1)
    % get the predicted metabolite
    varname=strrep(sampleData{i,1},'EX_','');
    varname=strrep(varname,'[fe]','');
    if ~isempty(find(strcmp(metaboliteDatabase(:,1),varname)))
        varname=metaboliteDatabase{find(strcmp(metaboliteDatabase(:,1),varname)),2};
    end
    figure;
    % plot the violins
    % if there are nonzero values in each stratification group and the
    % values aren't all the same
    strats=unique(sampleStratification);
    plotdata=str2double(sampleData(i,2:end))';
    for j=1:length(strats)
        valsinstrat(j)=sum(plotdata(find(strcmp(sampleStratification,strats{j}))));
        uniquevals(j)=numel(unique(plotdata(find(strcmp(sampleStratification,strats{j})))));
    end
    if ~any(valsinstrat<0.0000001) && ~any(uniquevals<2)
        hold on
        violinplot(plotdata,sampleStratification);
        if length(strats) > 3
            set(gca, 'FontSize', 12)
        else
            set(gca, 'FontSize', 14)
        end
        box on
        ylim([0 max(max(str2double(sampleData(i,2:end))))])
        if ~isempty(unit)
            h=ylabel(unit);
            set(h,'interpreter','none')
        end
        h=title(varname,'FontSize',16);
        set(h,'interpreter','none')
        if ~isempty(plottedFeature)
            h=suptitle(plottedFeature);
            set(h,'interpreter','none')
        end
        set(gca,'TickLabelInterpreter','none')
        filename=strrep(varname,' ','_');
        filename=strrep(filename,'(','_');
        filename=strrep(filename,')','_');
        filename=strrep(filename,'(','_');
        filename=strrep(filename,'-','_');
        filename=strrep(filename,':','_');
        filename=strrep(filename,'/','_');
        filename=strrep(filename,'___','_');
        filename=strrep(filename,'__','_');
        if ~isempty(plottedFeature)
        featName=[strrep(plottedFeature,' ','_') '_'];
        else
            featName='';
        end
        if ~isempty(stratification)
            print([featName stratification '_' filename],'-dpng','-r300')
            print('-bestfit',[featName stratification '_' filename],'-dpdf','-r300')
            append_pdfs([featName stratification '_' 'All_plots.pdf'],[featName stratification '_' filename '.pdf']);
        else
            print([featName filename],'-dpng','-r300')
            print('-bestfit',[featName filename],'-dpdf','-r300')
            append_pdfs([featName 'All_plots.pdf'],[plottedFeature '_' filename '.pdf']);
        end
        close all
    end
end

end
