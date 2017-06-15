function plotModelConsistency(modelResults,modelMetaData,schematicFlag,nRows,nCols,resultsDirectory,figureFileName,resultsFileName)
%plots stoichoiometric and flux consistency figures, given a modelResults
%structure or by loading the modelResults structure from a specified
%location
%
%INPUT
% modelResults          output of checkModelProperties.m
% modelMetaData         Cell array, where each row is metadata for one model
%                       with five columns: species, modelID, fileName, PMID, doi.
% schematicFlag         top corner plot illustrating the different colours
% nRows                 number of rows in the subplot
% nCols                 number of rows in the subplot (nRows*nCols >= length(modelResults)
%
%OPTIONAL INPUT
% resultsDirectory      directory where output of checkModelProperties.m has been saved
%                       same directory where the figure will be saved
% figureFileName        filename of the figure (without the directory)
% resultsFileName       filename where output of checkModelProperties.m has been saved

%number of rows and columns of the figure
if ~exist('nRows','var')
    nRows=6;
end
if ~exist('nCols','var')
    nCols=5;
end
if isempty(modelResults)
    if ~exist('resultsFileName','var')
        resultsFileName='checkModelPropertiesResults';
    end
    if ~exist('figureFileName','var')
        figureFileName='checkModelPropertiesResults';
    end
    %results directory
    if ~exist('resultsDirectory','var')
        resultsDirectory=pwd;
    end
    
    cd(resultsDirectory)
    load([resultsDirectory resultsFileName])
end
if ~exist('schematicFlag','var')
    schematicFlag=1;
end

% RGB Value  Short Name  Long Name
% [1 1 0] y yellow
% [1 0 1] m magenta
% [0 1 1] c cyan
% [1 0 0] r red
% [0 1 0] g green
% [0 0 1] b blue
% [1 1 1] w white
% [0 0 0] k black

nReconstructions=length(modelResults);

resultsModelID=cell(nReconstructions,1);
for n=1:nReconstructions
    resultsModelID{n}=modelResults(n).model.modelID;
end

%flag models with a low fraction of stoichiometrically consistent rows
tol=0.60;

fprintf('%s\n',['Reconstructions with less than ' num2str(tol*100) '% stoichiometrically inconsistent rows...'])
fprintf('%s%s%s\n','Model                 ','Species ', 'Stoic. consistent')
stochConsistentFraction=zeros(nReconstructions,1);
sufficientlyStochConsistent=true(nReconstructions,1);
for j=1:nReconstructions
    stochConsistentFraction(j)=size(modelResults(j).model.S,1)/nnz(modelResults(j).model.SConsistentMetBool);
    if stochConsistentFraction(j)<tol
        sufficientlyStochConsistent(j)=0;
        fprintf('%20s\t%u\t%u\n',modelResults(j).modelID,size(modelResults(j).model.S,1),nnz(modelResults(j).model.SConsistentMetBool))
        %fprintf('%s ',FRtable{1,j+1})
    end
end
fprintf('%u%s\n',nnz(sufficientlyStochConsistent), ' models that are sufficiently stochiometrically consistent for plotting.')

close all
% figure;
% hist(stochConsistentFraction,100)
% fprintf('\n')

fontSizeTitle=14;
fontSizeLabel=16;
if schematicFlag %top left plot is a schematic
    h=figure('units','normalized','outerposition',[0 0 1 1]);
    k=1;%first plot is for legend
    subplot(nRows,nCols,k)
    hold on;
    ylabel('# Molecular species','FontSize',fontSizeLabel)
    title('Network','FontWeight','normal','FontSize',fontSizeTitle)
    %Reconstruction
    X=[0,0,100,100];
    Y=[0,100,100,0];
    fill(X,Y,[55 55 55]/255,'EdgeColor',[55 55 55]/255)
    xlim([0 100])
    ylim([0 100-1])
    %Stoichiometrically consistent
    X=[0,0,66,66];
    Y=[0,80,80,0];
    fill(X,Y,[204 102 102]/255,'EdgeColor','none')
    %Stoichiometrically consistent & flux consistent (non-exchange reactions,
    %unique & nonzero)
    X=[0,0,50,50];
    Y=[0,45,45,0];
    fill(X,Y,[153 153 255]/255,'EdgeColor','none')

    %Stoichiometrically consistent & flux consistent (exchange reactions, unique & nonzero)
    X=[80,80,100,100];
    Y=[0,45,45,0];
    fill(X,Y,[192 192 192]/255,'EdgeColor','none')

    k=k+1;
else
    h=figure('units','normalized','outerposition',[0 0 1 1]);
    k=1;
end

if nReconstructions~=size(modelMetaData,1)
    error('Metadata must be provided for each model')
end

%start at the second subplot as the first is for the example
for n=1:nReconstructions
    %dont' go over the size of the number of subplots (minus one for the
    %template)
    if k<=nRows*nCols
        
        modelID=modelMetaData{n,2};
        bool=strcmp(modelID,resultsModelID);
        if ~any(bool)
            error(['Metadata mismatch for model ' modelID])
        end
        ind=find(bool);
        
        Species=modelMetaData{n,1};
        Species=strrep(Species,'_',' ');

        %only plot the reconstructions that are sufficiently
        %stoichiometrically consisitent
        if ~sufficientlyStochConsistent(ind)
            warning('Not sufficiently stoichiometrically consistent. Exchange reactions correctly identified?')
            break
        end

        %new subplot
        subplot(nRows,nCols,k);

        if isempty(modelID)
            title(Species,'FontWeight','normal','FontSize',fontSizeTitle)
        else
            if 0
            title([Species ', ' modelID],'FontWeight','normal','FontSize',fontSizeTitle)
            else
                        title(modelID,'FontWeight','normal','FontSize',fontSizeTitle)
            end

        end

        %lable first column in each row
        if mod(k,nCols)==1
            ylabel('# Molecular species','FontSize',fontSizeLabel)
        end
        if k>(nRows-1)*nCols
            xlabel('# Reactions','FontSize',fontSizeLabel)
        end
        hold on;

        %disp(ind)
        model=modelResults(ind).model;

        %Reconstruction
        X=[0,0,size(model.S,2),size(model.S,2)];
        Y=[0,size(model.S,1),size(model.S,1),0];
        %fill(X,Y,[153 153 153]/255,'EdgeColor',[153 153 153]/255)
        %fill(X,Y,[55 55 55]/255,'EdgeColor',[55 55 55]/255)
        fill(X,Y,[55 55 55]/255,'EdgeColor','none')
        xlim([0 size(model.S,2)])
        ylim([0 size(model.S,1)-1])

        %Stoichiometrically consistent
        X=[0,0,nnz(model.SConsistentRxnBool),nnz(model.SConsistentRxnBool)];
        Y=[0,nnz(model.SConsistentMetBool),nnz(model.SConsistentMetBool),0];
        fill(X,Y,[204 102 102]/255,'EdgeColor','none')

        %Stoichiometrically consistent & flux consistent (non-exchange and exchange reactions, unique & nonzero
        %model.FRnonZeroRowBool & model.FRuniqueRowBool & (model.SConsistentMetBool | ~model.SIntMetBool) & model.fluxConsistentMetBool
        %Stoichiometrically consistent

        % distinguish flux consistent internal and exchange reactions
        rxnBool=model.SConsistentRxnBool & model.fluxConsistentRxnBool;
        metBool=model.SConsistentMetBool & model.fluxConsistentMetBool;
        X=[0,0,nnz(rxnBool),nnz(rxnBool)];
        Y=[0,nnz(metBool),nnz(metBool),0];
        fill(X,Y,[153 153 255]/255,'EdgeColor','none')
        % exchange reactions
        rxnBool=~model.SIntRxnBool & model.fluxConsistentRxnBool;
        X=[0,0,nnz(rxnBool),nnz(rxnBool)];
        X=[size(model.S,2)-nnz(rxnBool)-1,size(model.S,2)-nnz(rxnBool)-1,size(model.S,2),size(model.S,2)];
        Y=[0,nnz(metBool),nnz(metBool),0];
        %fill(X,Y,[54 149 60]/255,'EdgeColor','none')
        fill(X,Y,[192 192 192]/255,'EdgeColor','none')
        
%         % distinguish flux consistent internal and exchange reactions
%         X=[0,0,nnz(model.FRVcols & model.SIntRxnBool),nnz(model.FRVcols & model.SIntRxnBool)];
%         Y=[0,nnz(model.FRrows),nnz(model.FRrows),0];
%         fill(X,Y,[153 153 255]/255,'EdgeColor','none')
%         % exchange reactions
%         X=[0,0,nnz(model.FRVcols & ~model.SIntRxnBool),nnz(model.FRVcols & ~model.SIntRxnBool)];
%         X=[size(model.S,2)-nnz(model.FRVcols & ~model.SIntRxnBool)-1,size(model.S,2)-nnz(model.FRVcols & ~model.SIntRxnBool)-1,size(model.S,2),size(model.S,2)];
%         Y=[0,nnz(model.FRrows),nnz(model.FRrows),0];
%         %fill(X,Y,[54 149 60]/255,'EdgeColor','none')
%         fill(X,Y,[192 192 192]/255,'EdgeColor','none')

        % X=[0,0,nnz(model.FRVcols),nnz(model.FRVcols)];
        % Y=[0,nnz(model.FRrows),nnz(model.FRrows),0];
        % fill(X,Y,[153 153 255]/255,'EdgeColor','none')
        %
        % X=[0,0,nnz(model.fluxConsistentRxnBool),nnz(model.fluxConsistentRxnBool)];
        % Y=[0,nnz(model.fluxConsistentMetBool),nnz(model.fluxConsistentMetBool),0];
        % fill(X,Y,[102 153 255]/255,'EdgeColor','none')
        %
        % X=[0,0,nnz(model.fluxConsistentRxnBool),nnz(model.fluxConsistentRxnBool)];
        % Y=[0,nnz(model.FRnonZeroBool),nnz(model.FRnonZeroBool),0];
        % fill(X,Y,'k','EdgeColor','none')
        %
        % X=[0,0,nnz(model.fluxConsistentRxnBool),nnz(model.fluxConsistentRxnBool)];
        % Y=[0,nnz(model.FRuniqueBool),nnz(model.FRuniqueBool),0];
        % fill(X,Y,'w','EdgeColor','none')
        %
        % X=[0,0,nnz(model.fluxConsistentRxnBool),nnz(model.fluxConsistentRxnBool)];
        % Y=[0,nnz(model.FRrows),nnz(model.FRrows),0];
        % fill(X,Y,[153 153 255]/255,'EdgeColor','none')

        %move to next subplot
         k=k+1;
    end
end
if nRows*nCols<nReconstructions
    warning('not all results could be plotted with the nRows and nCols given')
end

%legend('Original','Stoichiometrically consistent','+ Flux consistent','+ non-zero','+ unique','full rank([F R])');
%legend('Reconstruction','Stoich. consistent','Nontrivial, stoich. & flux consistent','[F R] full row rank');
%legend('Reconstruction','Stoich. consistent','Stoich. consistent, flux consistent, unique & nonzero.');

if 0
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
end

fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

if exist('figureFileName','var')
    saveas(fig,[resultsDirectory filesep figureFileName]);
    print(fig,[resultsDirectory filesep figureFileName],'-dpng');
end
