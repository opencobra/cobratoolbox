%make the figures and supplementary table summarising FR results for AGORA manuscript
%Ronan Fleming, 321 first version, March 2016.
%               773 second version, June 2016

nReconstructions=773;

if ~exist('FRresultsTableBefore','var')
    %% Before
    finalFolder='/Seed773';
    %
    FRresultDirectory=['~/work' finalFolder];
    FRresultsDirectory=['~/work/ownCloud/programReconstruction/projects/AGORA/results' finalFolder];
    if ~exist(FRresultsDirectory,'dir')
        mkdir(FRresultsDirectory)
    end
    
    %find the names of each FRresult .mat file
    FRmatFiles=dir(FRresultDirectory);
    FRmatFiles.name;
    %get rid of entries that do not have a .mat suffix
    bool=false(length(FRmatFiles),1);
    for k=3:length(FRmatFiles)
        if strcmp(FRmatFiles(k).name(end-3:end),'.mat')
            bool(k)=1;
        end
    end
    FRmatFiles=FRmatFiles(bool);
    
    %merge a batch of FRresult_model_name.mat in a directory into a FRresults
    %each FRresult_model_name.mat should contain one FRresult structure for one
    %model

    %FR results structure
    FRresults=struct();
    for k=1:length(FRmatFiles)
        load([FRresultDirectory filesep FRmatFiles(k).name])
        tmp=strrep(FRmatFiles(k).name,'FRresult_','');
        fprintf('%u\t%s\n',k,tmp(1:end-4))
        FRresults(k).matFile=FRresult.matFile;
        FRresults(k).modelFilename=FRresult.modelFilename;
        FRresults(k).modelID=FRresults(k).modelFilename(1:end-4);%take off .mat
        FRresults(k).rankFR=FRresult.rankFR;
        FRresults(k).rankFRV=FRresult.rankFRV;
        FRresults(k).rankS=FRresult.rankS;
        FRresults(k).model=FRresult.model;
        FRresults(k).rankFRvanilla=FRresult.rankFRvanilla;
        FRresults(k).rankFRVvanilla=FRresult.rankFRVvanilla;
        FRresults(k).maxSij=FRresult.maxSij;
        FRresults(k).minSij=FRresult.minSij;
    end
    %before
    [FRresultsTableBefore,FRresultsBefore]=makeFRresultsTable(FRresults);
    
    
    %%AFTER
    finalFolder='/AGORA773';
    %
    FRresultDirectory=['~/work' finalFolder];
    FRresultsDirectory=['~/work/ownCloud/programReconstruction/projects/AGORA/results' finalFolder];
    if ~exist(FRresultsDirectory,'dir')
        mkdir(FRresultsDirectory)
    end
    
    %find the names of each FRresult .mat file
    FRmatFiles=dir(FRresultDirectory);
    FRmatFiles.name;
    %get rid of entries that do not have a .mat suffix
    bool=false(length(FRmatFiles),1);
    for k=3:length(FRmatFiles)
        if strcmp(FRmatFiles(k).name(end-3:end),'.mat')
            bool(k)=1;
        end
    end
    FRmatFiles=FRmatFiles(bool);
    
    %merge a batch of FRresult_model_name.mat in a directory into a FRresults
    %each FRresult_model_name.mat should contain one FRresult structure for one
    %model
    %FR results structure
    FRresults=struct();
    for k=1:length(FRmatFiles)
        load([FRresultDirectory filesep FRmatFiles(k).name])
        tmp=strrep(FRmatFiles(k).name,'FRresult_','');
        fprintf('%u\t%s\n',k,tmp(1:end-4))
        FRresults(k).matFile=FRresult.matFile;
        FRresults(k).modelFilename=FRresult.modelFilename;
        FRresults(k).modelID=FRresults(k).modelFilename(1:end-4);%take off .mat
        FRresults(k).rankFR=FRresult.rankFR;
        FRresults(k).rankFRV=FRresult.rankFRV;
        FRresults(k).rankS=FRresult.rankS;
        FRresults(k).model=FRresult.model;
        FRresults(k).rankFRvanilla=FRresult.rankFRvanilla;
        FRresults(k).rankFRVvanilla=FRresult.rankFRVvanilla;
        FRresults(k).maxSij=FRresult.maxSij;
        FRresults(k).minSij=FRresult.minSij;
    end
    %after
    [FRresultsTableAfter,FRresultsAfter]=makeFRresultsTable(FRresults);
end


if ~exist('T','var')
    %merge cell arrays into a proper table
    [mlt,nlt]=size(FRresultsTableAfter);
    
    propertyNames=FRresultsTableBefore{[5:32],1};
    propertyNamesOrig=propertyNames;
    %property names can only be certain strings
    for z=1:length(propertyNames)
        propertyNames{z}=strrep(propertyNames{z},'#','Num');
        propertyNames{z}=strrep(propertyNames{z},' ','_');
        propertyNames{z}=strrep(propertyNames{z},'[','');
        propertyNames{z}=strrep(propertyNames{z},']','');
        propertyNames{z}=strrep(propertyNames{z},'.','');
        propertyNames{z}=strrep(propertyNames{z},'F,R','FcatR');
        propertyNames{z}=strrep(propertyNames{z},'F;R','FvcatR');
        propertyNames{z}=strrep(propertyNames{z},'=','eq');
        propertyNames{z}=strrep(propertyNames{z},'__R','R');
        propertyNames{z}=strrep(propertyNames{z},'(','');
        propertyNames{z}=strrep(propertyNames{z},')','');
        propertyNames{z}=strrep(propertyNames{z},'/','_div_');
    end
    
    modelNames=cell(2*nReconstructions,1);
    for z=1:nReconstructions
        tmp=FRresultsTableBefore{3,z+1};
        modelNames{2*z-1,1}=[tmp{1} '_B'];
        tmp=FRresultsTableAfter{3,z+1};
        modelNames{2*z,1}=[tmp{1} '_A'];
    end
    
    %decide orientation of the table
    rowNames=modelNames;
    variableNames=propertyNames;
    
    %check that each variable name is legit
    for k=1:length(variableNames)
        if ~isvarname(variableNames{k})
            warning([variableNames{k} ' is not valid'])
        else
            %disp('...')
            %disp(variableNames{k})
        end
    end
    %preallocate and name the rows
    FRresultsTableBeforeAfter=array2table(NaN*ones(2*(nlt-1),mlt-4),'RowNames',rowNames,'VariableNames',variableNames);
    
    %join the data from the before and after tables
    for n=2:nlt
        for m=5:mlt
            tmp=FRresultsTableBefore{m,n};
            FRresultsTableBeforeAfter{2*(n-1)-1,m-4}=tmp{1};
            tmp=FRresultsTableAfter{m,n};
            FRresultsTableBeforeAfter{2*(n-1),m-4}=tmp{1};
        end
    end
    
    %T for Table
    T=FRresultsTableBeforeAfter;
end


if 1
    load('~/work/ownCloud/programReconstruction/projects/AGORA/data/Agora1Boolean')
    modelNames=T.Properties.RowNames(1:2*nReconstructions);
    modelNameLengths=zeros(2*nReconstructions,1);
    for n=1:2*nReconstructions
        modelNameLengths(n,1)=length(modelNames{n,1});
    end
    T321=table(false(2*nReconstructions,1),'VariableNames',{'AGORA321'},'RowNames',modelNames);
     
    nlt=length(agora.models);
    for n=1:nlt
        modelName=agora.models{n,1};
        bool=strncmp(modelName,modelNames,length(modelName)) & (length(modelName)+2)==modelNameLengths;
        if any(bool)
            if nnz(bool)>2
                T321(bool,1)
                error([modelName,' : more than two matches in FRresultsTableBeforeAfter'])
            end
            if agora.boolean(n)==1
                %only set to true those reconstructions part of the
                %original Agora 321
                T321(bool,1)={1};
            end
        else
            fprintf('%s%s\n',modelName,' : no match in FRresultsTableBeforeAfter')
        end
    end
end
agora1Bool=table2array(T321);
if nnz(agora1Bool)~=2*321
    error('problem matching Agora 321 boolean vector')
end


% if 0
% propertyNames = 
%     'Num_Reactants_eq_Num_Rows_of_S_S_e'
%     'Num_Rank_of_reconstruction_FcatR'
%     'Num_Rank_S_S_e'
%     'min_coefficient_magnitude_S_S_e'
%     'max_coefficient_magnitude_S_S_e'
%     'min_div_max_coefficient_magnitude_S_S_e'
%     'Num_Elementally_balanced_rows_given_formulae'
%     'Num_Stoich_consistent_rows'
%     'Num_Nontrivial_stoich_consistent_rows'
%     'Num_Nontrivial_stoich_and_flux_consistent_rows_of_FcatR'
%     'Num_Unique_stoich_and_nontrivial_flux_consistent_rows_of_FcatR'
%     'Num_Rows_of_proper_FcatR'
%     'Rank_of_nontrivial_stoich_and_flux_consistent_FcatR'
%     'Num_Rows_of_bilinear_FcatR'
%     'Num_Rank_of_bilinear_FcatR'
%     'Num_Largest_connected_rows_of_FcatR'
%     'Num_Exchange_rows_eq_Num_Rows_exclusive_to_S_e'
%     'Num_Reactions_eq_Num_Cols_of_S_S_e'
%     'Num_Exchange_cols_eq_Num_Cols_of_S_e'
%     'Num_Elementally_balanced_cols'
%     'Num_Stoichiometrially_consistent_cols'
%     'Num_Unique_and_stoichiometrially_consistent_cols'
%     'Num_Unique_stoich_and_flux_consistent_cols_of_FvcatR'
%     'Num_Nontrivial_stoich_and_flux_consistent_cols_of_FvcatR'
%     'Num_Largest_connected_cols_of_FvcatR'
%     'Num_Cols_of_proper_FvcatR'
%     'Num_Rank_of_proper_FvcatR'
%     'Num_Rank_of_vanilla_FvcatR'
% end

Agora1BoolHalf=agora1Bool(1:2:2*nReconstructions,1);
% Agora1beforeBool=agora1Bool(1:2:2*nReconstructions,1);
% Agora1beforeInd=find(Agora1beforeBool);
% Agora2beforeInd=find(~Agora1beforeBool);
% 
% Agora1afterBool=agora1Bool(2:2:2*nReconstructions,1);
% Agora1afteroreInd=find(Agora1afterBool);
% Agora2afterInd=find(~Agora1afterBool);

beforeInd=[1:2:2*nReconstructions]';
afterInd=[2:2:2*nReconstructions]';

close all

%plot the before vs after
if 0
    X=T{beforeInd,'Num_Reactants_eq_Num_Rows_of_S_S_e'};
    Y=T{afterInd,'Num_Reactants_eq_Num_Rows_of_S_S_e'};
    figure;
    hold on;
    plot(X,Y,'LineStyle','none','Marker','.')
    plot([min([X;Y]),max([X;Y])],[min([X;Y]),max([X;Y])],'LineStyle','-','LineWidth',2,'Color','r')
    xlabel('# Reactants before')
    ylabel('# Reactants after')
end

if 0
    X=T{beforeInd,'Num_Exchange_rows_eq_Num_Rows_exclusive_to_S_e'};
    Y=T{afterInd,'Num_Exchange_rows_eq_Num_Rows_exclusive_to_S_e'};
    figure;
    hold on;
    plot(X,Y,'LineStyle','none','Marker','.')
    plot([min([X;Y]),max([X;Y])],[min([X;Y]),max([X;Y])],'LineStyle','-','LineWidth',2,'Color','r')
    xlabel('# Orphan exchanges before')
    ylabel('# Orphan exchanges after')
end


if 0
    indicesToPlot=[1,2,3,8,9,10,13,18,19,21,22,23];
    klt=length(indicesToPlot);
    figure;
    for k=1:klt
        X=T{beforeInd,T.Properties.VariableNames{indicesToPlot(k)}};
        Y=T{afterInd,T.Properties.VariableNames{indicesToPlot(k)}};
        subplot(3,4,k)
        hold on;
        tmp=propertyNamesOrig{indicesToPlot(k)};
        tmp=strrep(tmp,'#','');
        title(tmp,'FontSize',14)
        xlabel(['Before'],'FontSize',14)
        ylabel(['After'],'FontSize',14)
        if any(isnan([X;Y]))
            disp(tmp)
        end
        plot(X,Y,'LineStyle','none','Marker','.')
        plot([min([X;Y]),max([X;Y])],[min([X;Y]),max([X;Y])],'LineStyle','-','LineWidth',2,'Color','r')
        xlim([min([X;Y]),max([X;Y])])
        ylim([min([X;Y]),max([X;Y])])
    end
end

%nRows
nRowsBefore=T{beforeInd,T.Properties.VariableNames{1}};
nRowsAfter=T{afterInd,T.Properties.VariableNames{1}};
%nCols
nColsBefore=T{beforeInd,T.Properties.VariableNames{18}};
nColsAfter=T{afterInd,T.Properties.VariableNames{18}};
%nExchangeCols
nExColsBefore=T{beforeInd,T.Properties.VariableNames{19}};
nExColsAfter=T{afterInd,T.Properties.VariableNames{19}};
%nInternalCols
nIntColsBefore=nColsBefore-nExColsBefore;
nIntColsAfter=nColsAfter-nExColsAfter;
%nStoichConsistentCols
nStoichConsistentColsBefore=T{beforeInd,T.Properties.VariableNames{21}};
nStoichConsistentColsAfter=T{afterInd,T.Properties.VariableNames{21}};

subPlotTitles=propertyNamesOrig;

%Supplementary Figure 1
indicesToPlot=[1,3,8,10];
allIndicesForTable=indicesToPlot;
if 1
    klt=length(indicesToPlot);
    figure;
    for k=1:klt
        X=T{beforeInd,T.Properties.VariableNames{indicesToPlot(k)}};
        Y=T{afterInd,T.Properties.VariableNames{indicesToPlot(k)}};
        switch T.Properties.VariableNames{indicesToPlot(k)}
            case 'Num_Reactants_eq_Num_Rows_of_S_S_e' %1
                subPlotTitles{indicesToPlot(k)}='# metabolites';
            case 'Num_Rank_S_S_e'%3
                if 0
                    %normalise by number of metabolites
                    X=X./nRowsBefore;
                    Y=Y./nRowsAfter;
                    subPlotTitles{indicesToPlot(k)}='# rank(S)/(# metabolites)';
                else
                    subPlotTitles{indicesToPlot(k)}='# rank(S)';
                end
            case 'Num_Stoich_consistent_rows'%8
                if 0
                    %normalise by number of metabolites
                    X=X./nRowsBefore;
                    Y=Y./nRowsAfter;
                    subPlotTitles{indicesToPlot(k)}='(# stoichiometrically consistent metabolites)/(# metabolites)';
                else
                    subPlotTitles{indicesToPlot(k)}='# stoichiometrically consistent metabolites';
                end
            case 'Num_Nontrivial_stoich_and_flux_consistent_rows_of_FcatR' %10
                if 0
                    %normalise by number of metabolites
                    X=X./nRowsBefore;
                    Y=Y./nRowsAfter;
                    subPlotTitles{indicesToPlot(k)}='(# stoich. & flux consistent metabolites)/(# metabolites)';
                else
                    subPlotTitles{indicesToPlot(k)}='# stoich. & flux consistent metabolites';
                end
        end
        subplot(4,2,2*k-1)
        hold on;
        tmp=subPlotTitles{indicesToPlot(k)};
        title(tmp,'FontSize',12,'FontWeight','normal')
        xlabel('Draft','FontSize',12)
        ylabel('AGORA','FontSize',12)
        if any(isnan([X;Y]))
            disp(tmp)
        end
        plot(X(Agora1BoolHalf),Y(Agora1BoolHalf),'LineStyle','none','Marker','.')
        plot(X(~Agora1BoolHalf),Y(~Agora1BoolHalf),'LineStyle','none','Marker','.','Color','k')
        plot([min([X;Y]),max([X;Y])],[min([X;Y]),max([X;Y])],'LineStyle','-','LineWidth',2,'Color','r')
        if 1
            if indicesToPlot(k)==8 & 0
                xlim([0.74,max([X;Y])])
                ylim([0.975,max([X;Y])])
            else
                xlim([min([X;Y]),max([X;Y])])
                ylim([min([X;Y]),max([X;Y])])
            end
        else
            xlim([min(X),max(X)])
            ylim([min(Y),max(Y)])
        end
        ax=gca;
        ax.FontSize=12;
        %axis square

        if 0
        h=subplot(4,3,3*k-1);
        xlabel('Draft','FontSize',12)
        ylabel('AGORA','FontSize',12)
        if any(isnan([X;Y]))
            disp(tmp)
        end
        boxplot([X,Y],'jitter',0.25,'symbol','.','notch','on','positions',[0.5,1],'labels',{'Draft','AGORA'});
        tmp=subPlotTitles{indicesToPlot(k)};
        title(h,tmp,'FontSize',12,'FontWeight','normal')
        h.FontSize=12;
        end
        
        h=subplot(4,2,2*k);
        hold on
        xlabel(['Draft'],'FontSize',12)
        ylabel(['AGORA'],'FontSize',12)
        if any(isnan([X;Y]))
            disp(tmp)
        end
        histogram(Y(Agora1BoolHalf)-X(Agora1BoolHalf),20,'FaceAlpha',0.4,'FaceColor','b')
        histogram(Y(~Agora1BoolHalf)-X(~Agora1BoolHalf),20,'FaceAlpha',0.4,'FaceColor','k')
        axis(h,'tight')
        tmp=subPlotTitles{indicesToPlot(k)};
        mn1 = mean(Y(Agora1BoolHalf)-X(Agora1BoolHalf));    %%% Calculate the mean
        stdv1 = std(Y(Agora1BoolHalf)-X(Agora1BoolHalf));     %%% Calculate the standard deviation
        mn0 = mean(Y(~Agora1BoolHalf)-X(~Agora1BoolHalf));    %%% Calculate the mean
        stdv0 = std(Y(~Agora1BoolHalf)-X(~Agora1BoolHalf));     %%% Calculate the standard deviation
        tmp=strrep(tmp,'#','\Delta');
        text(0.67,0.8,{'Mean\pms.d. ', [num2str(round(mn1)) '\pm' num2str(round(stdv1))]},'Units','normalized','FontSize',12);
        text(0.17,0.8,{'Mean\pms.d. ', [num2str(round(mn0)) '\pm' num2str(round(stdv0))]},'Units','normalized','FontSize',12);
        xlabel(h,tmp,'FontSize',12,'interpreter','tex','FontWeight','normal')
        ylabel(h,'# models','FontSize',12,'FontWeight','normal')
        h.FontSize=12;
    end
    saveas(h,['FRresults_Supp_Figure1_' datestr(now,30)],'fig')
    %saveas(h,['FRresults_Supp_Figure2' datestr(now,30)],'eps')
end

%Supplementary Figure 2
indicesToPlot=[18,19,21,23];
allIndicesForTable=[allIndicesForTable,indicesToPlot];
if 1
    klt=length(indicesToPlot);
    figure;
    for k=1:klt
        X=T{beforeInd,T.Properties.VariableNames{indicesToPlot(k)}};
        Y=T{afterInd,T.Properties.VariableNames{indicesToPlot(k)}};
        switch T.Properties.VariableNames{indicesToPlot(k)}
%             case 'Rank_of_nontrivial_stoich_and_flux_consistent_FcatR' %13
%                 %normalise by number of metabolites
%                 X=X./nRowsBefore;
%                 Y=Y./nRowsAfter;
%                 subPlotTitles{indicesToPlot(k)}='rank([F,R])/(# Metabolites)';
            case 'Num_Reactions_eq_Num_Cols_of_S_S_e'%18
                subPlotTitles{indicesToPlot(k)}='# reactions';
            case 'Num_Exchange_cols_eq_Num_Cols_of_S_e' %19
                if 0
                    %normalise by number of reactions
                    X=X./nColsBefore;
                    Y=Y./nColsAfter;
                    subPlotTitles{indicesToPlot(k)}='(# exchange reactions)/(# reactions)';
                else
                    subPlotTitles{indicesToPlot(k)}='# exchange reactions';
                end
            case 'Num_Stoichiometrially_consistent_cols'%21
%                 %don't normalise to show increased size of functional
%                 %model
%                 X=X./nColsBefore;
%                 Y=Y./nColsAfter;
                subPlotTitles{indicesToPlot(k)}='# stoichiometrically consistent reactions';
            case 'Num_Unique_stoich_and_flux_consistent_cols_of_FvcatR'%23
                if 0
                    %normalise by number of stoich consistent reactions
                    X=X./nStoichConsistentColsBefore;
                    Y=Y./nStoichConsistentColsAfter;
                    subPlotTitles{indicesToPlot(k)}='(# stoich. & flux consistent reactions)/(# stoich. consistent reactions)';
                    %subPlotTitles{indicesToPlot(k)}='Fraction of Mass balanced reactions that are also flux consistent)';
                else
                    subPlotTitles{indicesToPlot(k)}='# stoich. & flux consistent reactions';
                    %subPlotTitles{indicesToPlot(k)}='Fraction of Mass balanced reactions that are also flux consistent)';
                end
        end
        h=subplot(4,2,2*k-1);
        hold on;
        xlabel('Draft','FontSize',12)
        ylabel('AGORA','FontSize',12)
        if any(isnan([X;Y]))
            disp(tmp)
        end
        %plot(X,Y,'LineStyle','none','Marker','.')
        plot(X(Agora1BoolHalf),Y(Agora1BoolHalf),'LineStyle','none','Marker','.')
        plot(X(~Agora1BoolHalf),Y(~Agora1BoolHalf),'LineStyle','none','Marker','.','Color','k')
        plot([min([X;Y]),max([X;Y])],[min([X;Y]),max([X;Y])],'LineStyle','-','LineWidth',2,'Color','r')
        if 1
            xlim([min([X;Y]),max([X;Y])])
            ylim([min([X;Y]),max([X;Y])])
        else
            xlim([min(X),max(X)])
            ylim([min(Y),max(Y)])
        end
        tmp=subPlotTitles{indicesToPlot(k)};
        title(h,tmp,'FontSize',12,'FontWeight','normal')
        h.FontSize=12;
        %axis square
        
        if 0
        h=subplot(4,3,3*k-1);
        xlabel(['Draft'],'FontSize',12)
        ylabel(['AGORA'],'FontSize',12)
        if any(isnan([X;Y]))
            disp(tmp)
        end
        boxplot([X,Y],'jitter',0.25,'symbol','.','notch','on','positions',[0.5,1],'labels',{'Draft','AGORA'});
        tmp=subPlotTitles{indicesToPlot(k)};
        title(h,tmp,'FontSize',12,'FontWeight','normal')
        h.FontSize=12;
        end
        
        h=subplot(4,2,2*k);
        xlabel('Draft','FontSize',12)
        ylabel('AGORA','FontSize',12)
        if any(isnan([X;Y]))
            disp(tmp)
        end
        hold on
        histogram(h,Y(Agora1BoolHalf)-X(Agora1BoolHalf),20,'FaceAlpha',0.4,'FaceColor','b')
        histogram(h,Y(~Agora1BoolHalf)-X(~Agora1BoolHalf),20,'FaceAlpha',0.4,'FaceColor','k')
        axis(h,'tight')
        mn1 = mean(Y(Agora1BoolHalf)-X(Agora1BoolHalf));    %%% Calculate the mean
        stdv1 = std(Y(Agora1BoolHalf)-X(Agora1BoolHalf));     %%% Calculate the standard deviation
        mn0 = mean(Y(~Agora1BoolHalf)-X(~Agora1BoolHalf));    %%% Calculate the mean
        stdv0 = std(Y(~Agora1BoolHalf)-X(~Agora1BoolHalf));     %%% Calculate the standard deviation
        text(0.67,0.8,{'Mean\pms.d. ', [num2str(round(mn1)) '\pm' num2str(round(stdv1))]},'Units','normalized','FontSize',12);
        text(0.17,0.8,{'Mean\pms.d. ', [num2str(round(mn0)) '\pm' num2str(round(stdv0))]},'Units','normalized','FontSize',12);
        tmp=subPlotTitles{indicesToPlot(k)};
        %title(h,tmp,'FontSize',12,'FontWeight','normal')
        tmp=strrep(tmp,'#','\Delta');
        xlabel(h,tmp,'FontSize',12,'interpreter','tex','FontWeight','normal')
        ylabel(h,'# models','FontSize',12,'FontWeight','normal')
        h.FontSize=12;
    end
    saveas(h,['FRresults_Supp_Figure2_' datestr(now,30)],'fig')
    %saveas(h,['FRresults_Supp_Figure2_' datestr(now,30)],'eps')
end

%Panel for main Figure 1
if 1
    indicesToPlot=23;
    klt=length(indicesToPlot);
    h=figure;
    for k=1:klt
        X=T{beforeInd,T.Properties.VariableNames{indicesToPlot(k)}};
        Y=T{afterInd,T.Properties.VariableNames{indicesToPlot(k)}};
        h=subplot(1,2,2*k-1);
        hold on;
        xlabel('Number of draft reconstruction reactions','FontSize',14)
        ylabel('Number of AGORA reconstruction reactions','FontSize',14)
        if any(isnan([X;Y]))
            disp(tmp)
        end
        if 0
            plot(X(Agora1BoolHalf),Y(Agora1BoolHalf),'LineStyle','none','Marker','.')
            plot(X(~Agora1BoolHalf),Y(~Agora1BoolHalf),'LineStyle','none','Marker','.','Color','k')
        else
            plot(X,Y,'LineStyle','none','Marker','.')
        end
        plot([min([X;Y]),max([X;Y])],[min([X;Y]),max([X;Y])],'LineStyle','-','LineWidth',2,'Color','r')
        if 1
            xlim([min([X;Y]),max([X;Y])])
            ylim([min([X;Y]),max([X;Y])])
        else
            xlim([min(X),max(X)])
            ylim([min(Y),max(Y)])
        end
        h.FontSize=14;
        box on;
        
        h=subplot(1,2,2*k);
        xlabel('Draft','FontSize',14)
        ylabel('AGORA','FontSize',14)
        if any(isnan([X;Y]))
            disp(tmp)
        end
        if 0
            %split into Agora321 vs Agora773-321
            hold on
            histogram(h,Y(Agora1BoolHalf)-X(Agora1BoolHalf),20,'FaceAlpha',0.4,'FaceColor','b')
            histogram(h,Y(~Agora1BoolHalf)-X(~Agora1BoolHalf),20,'FaceAlpha',0.4,'FaceColor','k')
            axis(h,'tight')
            mn1 = mean(Y(Agora1BoolHalf)-X(Agora1BoolHalf));    %%% Calculate the mean
            stdv1 = std(Y(Agora1BoolHalf)-X(Agora1BoolHalf));     %%% Calculate the standard deviation
            mn0 = mean(Y(~Agora1BoolHalf)-X(~Agora1BoolHalf));    %%% Calculate the mean
            stdv0 = std(Y(~Agora1BoolHalf)-X(~Agora1BoolHalf));     %%% Calculate the standard deviation
            text(0.67,0.8,{'Mean\pms.d. ', [num2str(round(mn1)) '\pm' num2str(round(stdv1))]},'Units','normalized','FontSize',12);
            text(0.17,0.8,{'Mean\pms.d. ', [num2str(round(mn0)) '\pm' num2str(round(stdv0))]},'Units','normalized','FontSize',12);
        else
            histogram(h,Y-X,20)
            axis(h,'tight')
            mn = mean(Y-X);    %%% Calculate the mean
            stdv = std(Y-X);     %%% Calculate the standard deviation
            text(0.67,0.8,{'Mean\pms.d. ', [num2str(round(mn)) '\pm' num2str(round(stdv))]},'Units','normalized','FontSize',14);
        end
        xlabel(h,'Change in number of stoich. and flux consistent reactions','FontSize',14,'interpreter','tex','FontWeight','normal')
        ylabel(h,'Number of reconstructions','FontSize',14,'FontWeight','normal')
        h.FontSize=14;
    end
    %title('Comparison of the number of stoichiometrically and flux consistent reactions in draft and AGORA reconstructions','FontSize',12,'FontWeight','normal')
    saveas(h,['FRresults_Figure1_Panel_' datestr(now,30)],'fig')
    %saveas(h,['FRresults_Figure1_Panel' datestr(now,30)],'eps')
end
save('ModelsBeforeAfterTable','T','propertyNamesOrig')
writetable(T(:,allIndicesForTable),'ModelsBeforeAfter_Supplementary_Table_Original_Column_Headings.csv','WriteRowNames',true)