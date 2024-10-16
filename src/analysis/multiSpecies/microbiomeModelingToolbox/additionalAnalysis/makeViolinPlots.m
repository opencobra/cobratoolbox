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
% plotType             Type of plot to be created: violin plot (default) or
%                      boxplot. Allowed entries: "ViolinPlot","Boxplot"
% plottedFeature       Name of the feature to plot that will be displayed
%                      as the plot title (e.g., 'Flux"es')
% unit                 Unit of the plotted data that will be displayed as
%                      the y axis label (e.g., mmol/person/day)
%
% AUTHOR
%       - Almut Heinken, 12/2020

parser = inputParser();
parser.addRequired('sampleData', @iscell);
parser.addRequired('sampleInformation', @iscell);
parser.addParameter('plotType', 'ViolinPlot', @ischar);
parser.addParameter('stratification', '', @ischar);
parser.addParameter('plottedFeature', '', @ischar);
parser.addParameter('unit', '', @ischar);

parser.parse(sampleData, sampleInformation, varargin{:});

sampleData = parser.Results.sampleData;
sampleInformation = parser.Results.sampleInformation;
plotType = parser.Results.plotType;
stratification = parser.Results.stratification;
plottedFeature = parser.Results.plottedFeature;
unit = parser.Results.unit;

% read metabolite database
database = loadVMHDatabase;

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
    if contains(version,'R202') % for MATLAB 2020a or newer
        if sum(cell2mat(sampleData(i,2:end)))<0.0001
            delArray(cnt,1)=i;
            cnt=cnt+1;
        end
    else
        if sum(str2double(sampleData(i,2:end)))<0.0001
            delArray(cnt,1)=i;
            cnt=cnt+1;
        end
    end
end
sampleData(delArray,:)=[];

sampleStratification = {};
for i=2:size(sampleData,2)
    sampleStratification{i-1,1}=sampleInformation{find(strcmp(sampleInformation(:,1),sampleData{1,i})),stratCol};
end

% define colors for boxplots
if strcmp(plotType,'Boxplot')
    groups = unique(sampleStratification);
    if length(groups)==2
        cols =[1 0 0
            0 0 1];
    elseif length(groups)==3
        cols =[0 1 0
            1 0 0
            0 0 1];
    else
        cols = [];
        for j=1:length(groups)
            cols(j,:)=[rand rand rand];
        end
    end
end

for i=2:size(sampleData,1)
    % get the predicted metabolite
    varname=strrep(sampleData{i,1},'EX_','');
    varname=strrep(varname,'[fe]','');
    if ~isempty(find(strcmp(database.metabolites(:,1),varname)))
        varname=database.metabolites{find(strcmp(database.metabolites(:,1),varname)),2};
    end
    % create plots
    % if there are nonzero values in each stratification group and the
    % values aren't all the same
    strats=unique(sampleStratification);
    
    if contains(version,'(R202') % for Matlab R2020a and newer
        plotdata=cell2mat(sampleData(i,2:end))';
    else
        plotdata=str2double(sampleData(i,2:end))';
    end
    
    for j=1:length(strats)
        valsinstrat(j)=sum(plotdata(find(strcmp(sampleStratification,strats{j}))));
        uniquevals(j)=numel(unique(plotdata(find(strcmp(sampleStratification,strats{j})))));
        % workaround if all values in one category are zero
        if abs(valsinstrat(j))<0.0000001
            plotdata(find(strcmp(sampleStratification,strats{j}))) = 0.0000001;
        end
    end
        
    if ~any(uniquevals<2)
        figure
        hold on
        if strcmp(plotType,'ViolinPlot')
            violinplot(plotdata,sampleStratification);
        elseif strcmp(plotType,'Boxplot')
            boxplot(plotdata,sampleStratification)
            h = findobj(gca,'Tag','Box');
            for j=1:length(h)
                patch(get(h(j),'XData'),get(h(j),'YData'),cols(j,:),'FaceAlpha',.5);
            end
        else
            error('Invalid entry for plot type!')
        end
        if length(strats) > 3
            set(gca, 'FontSize', 10)
        else
            set(gca, 'FontSize', 16)
        end
        if length(strats) > 6
            xtickangle(45)
        end
        
        ylim([min(plotdata) max(plotdata)])
        
        if ~isempty(unit)
            h=ylabel(unit);
            set(h,'interpreter','none')
        end
        h=title(varname,'FontSize',16,'FontWeight','bold');
        set(h,'interpreter','none')
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

        % some filenames may be too long
        if length(filename)>25
            filename=filename(1:25);
        end

        if ~isempty(plottedFeature)
            featName=[strrep(plottedFeature,' ','_') '_'];
        else
            featName='';
        end

        if ~isempty(stratification)

            print([featName stratification '_' filename],'-dpng','-r300')
            % print('-bestfit',[featName stratification '_' filename],'-dpdf','-r300')
            % append_pdfs([featName stratification '_' 'All_plots.pdf'],[featName stratification '_' filename '.pdf']);
        else
            print([featName filename],'-dpng','-r300')
            % print('-bestfit',[featName filename],'-dpdf','-r300')
            % append_pdfs([featName 'All_plots.pdf'],[featName filename '.pdf']);
        end
        close all
    end
end

end
