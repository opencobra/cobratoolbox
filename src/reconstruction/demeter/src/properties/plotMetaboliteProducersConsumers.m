function plotMetaboliteProducersConsumers(propertiesFolder,infoFilePath,reconVersion,varargin)
% This function creates plots of strains that can consume or secrete a
% given list of metabolites. Plots are created on the strain level (each
% reconstruction separately) and, if taxonomical information is provided,
% on the species, genus, family, order, class, and phylum level.
%
% USAGE
%   plotMetaboliteProducersConsumers(propertiesFolder,infoFilePath,reconVersion,varargin)
% INPUTS
% propertiesFolder      Folder where computed uptake and secretion profiles
%                       are stored
% infoFilePath          Path to spreadsheet with taxonomical information of
%                       the refined strains
% reconVersion          Name assigned to the reconstruction resource
% OPTIONAL INPUTS
% metsToAnalyze         Table with list of metabolites that should be
%                       analyzed (default: all computed metabolites)
% metCategory           Name for type of metabolites to analyze that should
%                       be in the plots (Default: 'Metabolites')
%
%   - AUTHOR
%   Almut Heinken, 07/2020

parser = inputParser();
parser.addRequired('propertiesFolder',@ischar);
parser.addRequired('infoFilePath', @ischar);
parser.addRequired('reconVersion', @ischar);
parser.addParameter('metsToAnalyze', {}, @iscell);
parser.addParameter('metCategory', 'Reconstructions', @ischar);

parser.parse(propertiesFolder,infoFilePath,reconVersion,varargin{:});

propertiesFolder = parser.Results.propertiesFolder;
infoFilePath = parser.Results.infoFilePath;
reconVersion = parser.Results.reconVersion;
metsToAnalyze = parser.Results.metsToAnalyze;
metCategory = parser.Results.metCategory;

files={
    [propertiesFolder filesep 'ComputedFluxes' filesep 'uptakeFluxes_' reconVersion '.txt']
    [propertiesFolder filesep 'ComputedFluxes' filesep 'secretionFluxes_' reconVersion '.txt']
    [propertiesFolder filesep 'ComputedFluxes' filesep 'internalProduction_' reconVersion '.txt']
    };

infoFile = readtable(infoFilePath, 'ReadVariableNames', false);
infoFile = table2cell(infoFile);

currentDir=pwd;
fileDir = fileparts(which('ReactionTranslationTable.txt'));
cd(fileDir);
metaboliteDatabase = readtable('MetaboliteDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
metaboliteDatabase=table2cell(metaboliteDatabase);
cd(currentDir)

if ~exist('metCategory','var')
    metCategory='Metabolites';
end

taxa={'Species','Genus','Family','Order','Class','Phylum'};

tol=0.00001;

currentDir=pwd;
cd(propertiesFolder)

mkdir(['Figures_' strrep(metCategory,' ','_')])
cd(['Figures_' strrep(metCategory,' ','_')])

for i=1:length(files)
    folderName = strrep(files{i},[propertiesFolder filesep 'ComputedFluxes' filesep],'');
    folderName = strrep(folderName,['_' reconVersion '.txt'],'');
    
    mkdir(folderName)
    cd(folderName)

    data = readtable(files{i}, 'ReadVariableNames', false);
    data = table2cell(data);
    [C,I]=setdiff(infoFile(:,1),data(:,1),'stable');
    infoFileReduced=infoFile;
    infoFileReduced(I(2:end),:)=[];
    data(1,:)=strrep(data(1,:),'EX_','');
    data(1,:)=strrep(data(1,:),'(e)','');
    data(1,:)=strrep(data(1,:),'[e]','');
    
    [C,IA]=setdiff(data(1,:),metsToAnalyze,'stable');
    data(:,IA(2:end))=[];
    for j=2:size(data,2)
        data{1,j}=metaboliteDatabase{find(strcmp(metaboliteDatabase(:,1),data{1,j})),2};
    end
    data(1,:)=strrep(data(1,:),',',' ');
    % remove empty rows and columns
    delArray=[];
    cnt=1;
    for k=2:size(data,1)
        if abs(sum(str2double(data(k,2:end)))) < tol
            delArray(cnt,1)=k;
            cnt=cnt+1;
        end
    end
    data(delArray,:)=[];
    delArray=[];
    cnt=1;
    for k=2:size(data,2)
        if abs(sum(str2double(data(2:end,k)))) < tol
            delArray(cnt,1)=k;
            cnt=cnt+1;
        end
    end
    data(:,delArray)=[];
    
    % if there was any production/consumption
    if size(data,2)>1
        
        % get all consumers/producers in list format
        org_list={};
        for j=2:size(data,2)
            j
            org_list{1,j-1}=data{1,j};
            cnt=2;
            for k=2:size(data,1)
                if abs(str2double(data{k,j})) > tol
                    org_list{cnt,j-1}=data{k,1};
                    cnt=cnt+1;
                end
            end
        end
        org_list_old=org_list;
        org_list=cell2table(org_list);
        
        if contains(files{i},'secretion')
            writetable(org_list,[metCategory '_secretion'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
        elseif contains(files{i},'uptake')
            writetable(org_list,[metCategory '_uptake'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
        elseif contains(files{i},'internal')
            writetable(org_list,[metCategory '_internalProduction'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
        end

        if length(metsToAnalyze)>5
            % get strains most enriched in metabolite uptake/production
            all_strains={};
            org_list=org_list_old;
            org_list(1,:)=[];
            for j=1:size(org_list,2)
                all_strains=vertcat(all_strains,org_list(find(~cellfun(@isempty,org_list(:,j))),j));
            end
            [strains, ~, J]=unique(all_strains);
            cnt_strains = histc(J, 1:numel(strains));
            
            % workaround if there are too many entries
            if length(cnt_strains)>30
                [B,I]=sort(cnt_strains,'descend');
                strains=strains(I);
                sumall=sum(B(31:end));
                B(31:end)=[];
                strains(31:end)=[];
                [B,I]=sort(B,'ascend');
                strains=strains(I);
                
            else
                [B,I]=sort(cnt_strains,'ascend');
                strains=strains(I);
            end
            
            f = figure;
            aHand = axes('parent', f);
            hold(aHand, 'on')
            colors = hsv(numel(B));
            for b = 1:numel(B)
                barh(b, B(b), 'parent', aHand, 'facecolor', colors(b,:));
            end
            set(gca, 'YTick', 1:numel(B), 'YTickLabel', strains)
            set(gca,'TickLabelInterpreter','none')
            if length(B)<30
                set(gca, 'FontSize', 12)
            else
                set(gca, 'FontSize', 10)
            end
            if contains(files{i},'secretion')
                xlabel(['Number of secreted ' metCategory])
            elseif contains(files{i},'uptake')
                xlabel(['Number of consumed ' metCategory])
            end
            if contains(files{i},'secretion')
                title(['Strains enriched in ' lower(lower(metCategory)) ' secretion'], 'FontSize', 16, 'FontWeight', 'bold')
            elseif contains(files{i},'uptake')
                title(['Strains enriched in ' lower(lower(metCategory)) ' uptake'], 'FontSize', 16, 'FontWeight', 'bold')
            end
            f.Renderer='painters';
            if contains(files{i},'secretion')
                print([metCategory '_secretion_enriched_strains'],'-dpng','-r300')
            elseif contains(files{i},'uptake')
                print([metCategory '_uptake_enriched_strains'],'-dpng','-r300')
            end
            
            % plot organisms enriched in metabolism by taxon
            all_strains={};
            for j=1:size(org_list,2)
                all_strains=vertcat(all_strains,org_list(find(~cellfun(@isempty,org_list(:,j))),j));
            end
            [strains, ~, J]=unique(all_strains);
            cnt_strains = histc(J, 1:numel(strains));
            % add any strains not in the list
            not_in_list=setdiff(infoFileReduced(2:end,1),strains);
            if ~isempty(not_in_list)
                for j=1:length(not_in_list)
                    strains{length(strains)+1,1}=not_in_list{j};
                    cnt_strains(length(strains)+1,1)=0;
                end
            end
            
            for t=1:length(taxa)
                taxCol=find(strcmp(infoFileReduced(1,:),taxa{t}));
                org_taxa=strains;
                cnt_taxa=cnt_strains;
                for j=1:size(org_taxa,1)
                    org_taxa{j}=infoFileReduced{find(strcmp(infoFileReduced(:,1),org_taxa{j})),taxCol};
                end
                % remove unclassified taxa
                find_uncl=contains(org_taxa,'unclassified');
                org_taxa(find_uncl,:)=[];
                cnt_taxa(find_uncl,:)=[];
                
                [find_tax, ~, J]=unique(org_taxa);
                find_avs=[];
                for j=1:length(find_tax)
                    find_all=cnt_taxa(J==j);
                    find_avs(j,1)=mean(find_all);
                end
                
                % workaround if there are too many entries
                if length(find_tax)>30
                    [B,I]=sort(find_avs,'descend');
                    find_tax=find_tax(I);
                    B(31:end)=[];
                    find_tax(31:end)=[];
                    [B,I]=sort(B,'ascend');
                    find_tax=find_tax(I);
                else
                    [B,I]=sort(find_avs,'ascend');
                    find_tax=find_tax(I);
                end
                
                f = figure;
                aHand = axes('parent', f);
                hold(aHand, 'on')
                colors = hsv(numel(B));
                for b = 1:numel(B)
                    barh(b, B(b), 'parent', aHand, 'facecolor', colors(b,:));
                end
                set(gca, 'YTick', 1:numel(B), 'YTickLabel', find_tax)
                set(gca,'TickLabelInterpreter','none')
                if length(B)<15
                    set(gca, 'FontSize', 12)
                else
                    set(gca, 'FontSize', 9)
                end
                if contains(files{i},'secretion')
                    xlabel(['Average number of secreted ' lower(metCategory)])
                elseif contains(files{i},'uptake')
                    xlabel(['Average number of consumed ' lower(metCategory)])
                elseif contains(files{i},'internal')
                    xlabel(['Average number of internally produced ' lower(metCategory)])
                    
                end
                if contains(files{i},'secretion')
                    h=title(['Enrichment in ' lower(metCategory) ' secretion by ' lower(taxa{t})], 'FontSize', 16, 'FontWeight', 'bold');
                    set(h,'interpreter','none')
                elseif contains(files{i},'uptake')
                    h=title(['Enrichment in ' lower(metCategory) ' uptake by ' lower(taxa{t})], 'FontSize', 16, 'FontWeight', 'bold');
                    set(h,'interpreter','none')
                elseif contains(files{i},'internal')
                    h=title(['Enrichment in ' lower(metCategory) ' internal production by ' lower(taxa{t})], 'FontSize', 16, 'FontWeight', 'bold');
                    set(h,'interpreter','none')
                end
                f.Renderer='painters';
                if contains(files{i},'secretion')
                    print([strrep(metCategory,' ','_') '_secretion_enriched_' taxa{t}],'-dpng','-r300')
                elseif contains(files{i},'uptake')
                    print([strrep(metCategory,' ','_') '_uptake_enriched_' taxa{t}],'-dpng','-r300')
                elseif contains(files{i},'internal')
                    print([strrep(metCategory,' ','_') '_internal_production_enriched_' taxa{t}],'-dpng','-r300')
                end
            end
        end
        close all
        org_list=org_list_old;
        
        % plot taxa most enriched separately for each metabolite
        for t=1:length(taxa)
            taxCol=find(strcmp(infoFileReduced(1,:),taxa{t}));
            org_taxa=org_list;
            for k=2:size(org_taxa,1)
                for j=1:size(org_taxa,2)
                    if ~isempty(org_taxa{k,j})
                        org_taxa{k,j}=infoFileReduced{find(strcmp(infoFileReduced(:,1),org_taxa{k,j})),taxCol};
                    end
                end
            end
            for j=1:size(org_taxa,2)
                % create pie chart plot
                find_nonempty=find(~cellfun(@isempty,org_taxa(:,j)));
                all_orgs=org_taxa(find_nonempty(2:end),j);
                % remove unclassified taxa unless that removes all
                % organisms
                all_orgs(contains(all_orgs,'unclassified'))=[];
                if isempty(all_orgs)
                    all_orgs=org_taxa(find_nonempty(2:end),j);
                end
                [orgs, ~, J]=unique(all_orgs);
                cnt_orgs = histc(J, 1:numel(orgs));
                % workaround if there are too many entries
                if length(cnt_orgs)>20
                    [B,I]=sort(cnt_orgs,'descend');
                    orgs=orgs(I);
                    sumall=sum(B(21:end));
                    B(21:end)=[];
                    orgs(21:end)=[];
                    [B,I]=sort(B,'ascend');
                    orgs=orgs(I);
                    B(length(B)+1)=sumall;
                    orgs{length(orgs)+1}='Others';
                else
                    % find the total number of strains for these taxa to reduce
                    % reconstruction bias
                    [B,I]=sort(cnt_orgs,'ascend');
                    orgs=orgs(I);
                end
                
                f = figure;
                h=pie(B,cellstr(num2str(B)));
                if length(B)<10
                    set(findobj(h,'type','text'),'fontsize',12);
                elseif length(B)<20
                    set(findobj(h,'type','text'),'fontsize',9);
                else
                    set(findobj(h,'type','text'),'fontsize',6);
                end
                if contains(files{i},'secretion')
                    h=title([org_taxa{1,j} '-secreting strains by ' lower(taxa{t})], 'FontSize', 16, 'FontWeight', 'bold');
                    set(h,'interpreter','none')
                    xlabel('Producing strains')
                elseif contains(files{i},'uptake')
                    h=title([org_taxa{1,j} '-consuming strains by ' lower(taxa{t})], 'FontSize', 16, 'FontWeight', 'bold');
                    set(h,'interpreter','none')
                    xlabel('Consuming strains')
                elseif contains(files{i},'internal')
                    h=title(['Strains internally producing ' lower(org_taxa{1,j}) ' by ' lower(taxa{t})], 'FontSize', 16, 'FontWeight', 'bold');
                    set(h,'interpreter','none')
                    xlabel('Producing strains')
                end
                h=legend(orgs,'Location','eastoutside','Orientation','vertical');
                set(h,'interpreter','none')
                f.Renderer='painters';
                org_taxa{1,j}=strrep(org_taxa{1,j},':','_');
                org_taxa{1,j}=strrep(org_taxa{1,j},'-','_');
                if contains(files{i},'secretion')
                    print([org_taxa{1,j} '_secretion_' lower(taxa{t})],'-dpng','-r300')
                    print('-bestfit',[org_taxa{1,j} '_secretion_' lower(taxa{t})],'-dpdf','-r300')
                    append_pdfs('Metabolite_Production.pdf',[org_taxa{1,j} '_secretion_' lower(taxa{t}) '.pdf']);
                elseif contains(files{i},'uptake')
                    print([org_taxa{1,j} '_uptake_' lower(taxa{t})],'-dpng','-r300')
                elseif contains(files{i},'internal')
                    print([org_taxa{1,j} '_internal_production_' lower(taxa{t})],'-dpng','-r300')
                end
            end
            close all
        end  
    end
    cd ..
end

cd(currentDir)

end
