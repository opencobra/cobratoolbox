function plotFRresults(FRresults,nRows,nCols,resultsDirectory,resultsFileName,schematicFlag,modelMetaData)
%plots FR results in the same order as the FRresultsTable using FRresults 
%structure or by loading the FRresults structure
%
%INPUT
% FRresults             output of checkRankFRdriver
% nRows                 number of rows in the subplot
% nCols                 number of rows in the subplot (nRows*nCols >= length(FRresults)
% 
%OPTIONAL INPUT
% resultsDirectory      directory where output of checkRankFRdriver has been saved
% resultsFileName       filename where output of checkRankFRdriver has been saved

%number of rows and columns of the figure
if ~exist('nRows','var')
    nRows=6;
end
if ~exist('nCols','var')
    nCols=5;
end
if isempty(FRresults)
    if ~exist('resultsFileName','var')
        %filename='FRresults_20150128T225813';
        resultsFileName='FRresults_20150130T011200';
    end
    %results directory
    if ~exist('resultsDirectory','var')
        resultsDirectory='/home/rfleming/Dropbox/graphStoich/results/FRresults/';
    end
    cd(resultsDirectory)
    load([resultsDirectory resultsFileName])
end
if ~exist('schematicFlag','var')
    schematicFlag=1;
end

%used for merged metadata and results
FRresultsTable=makeFRresultsTable(FRresults,[],[],modelMetaData);

% RGB Value  Short Name  Long Name
% [1 1 0] y yellow
% [1 0 1] m magenta 
% [0 1 1] c cyan
% [1 0 0] r red
% [0 1 0] g green
% [0 0 1] b blue
% [1 1 1] w white
% [0 0 0] k black

nReconstructions=length(FRresults);

resultsModelID=cell(nReconstructions,1);
for n=1:nReconstructions
    resultsModelID{n}=FRresults(n).modelID;
end

%flag models with [F,R] that is row rank deficient
fprintf('%s\n','[F,R] does not have full row rank for:')
fprintf('%s%s%s\n','Model                ','Rows([F,R]) ', 'Rank([F,R])')
for k=1:nReconstructions
    if nnz(FRresults(k).model.FRrows)~=nnz(FRresults(k).rankFR)
        fprintf('%20s\t%u\t%u\n',FRresults(k).modelID,full(FRresults(k).model.FRrows),FRresults(k).rankFR)
    end
end
fprintf('\n')

%flag models with [Fb,Rb] that is row rank deficient
fprintf('%s\n','[Fb,Rb] does not have full row rank for...')
fprintf('%20s%s%s\n','Model           ','Rows([Fb,Rb]) ', 'Rank([Fb,Rb])')
for k=nReconstructions
    if size(FRresults(k).model.Frb,1)~=FRresults(k).model.rankBilinearFrRr
        fprintf('%20s\t%u\t%u\n',FRresults(k).modelID,size(FRresults(k).model.Frb,1),FRresults(k).model.rankBilinearFrRr)
    end
end
fprintf('\n')

%flag models with a low fraction of stoichiometrically consistent rows
tol=0.90;
fprintf('%s\n',['Reconstructions with less than ' num2str(tol*100) '% stoichiometrically inconsistent rows...'])
fprintf('%s%s%s\n','Model                 ','Reactants ', 'Stoic. consistent')
stochConsistentFraction=zeros(nReconstructions,1);
sufficientlyStochConsistent=true(nReconstructions,1);
for j=1:nReconstructions
    stochConsistentFraction(j)=size(FRresults(k).model.S,1)/nnz(FRresults(k).model.SConsistentMetBool);
    if stochConsistentFraction(j)<tol
        sufficientlyStochConsistent(j)=0;
        fprintf('%20s\t%u\t%u\n',FRresults(j).modelID,size(FRresults(k).model.S,1),nnz(FRresults(k).model.SConsistentMetBool))
        %fprintf('%s ',FRtable{1,j+1})
    end
end
fprintf('%u%s\n',nnz(sufficientlyStochConsistent), ' models that are sufficiently stochiometrically consistent for plotting.')

close all
if 0
    figure;
    hist(stochConsistentFraction,100)
    fprintf('\n')
end

if schematicFlag %top left plot is a schematic
    h=figure('units','normalized','outerposition',[0 0 1 1]);
    k=1;%first plot is for legend
    subplot(nRows,nCols,k)
    hold on;
    ylabel('# Molec.','FontSize',13)
    title('Species, Version','FontWeight','normal','FontSize',11)
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

%start at the second subplot as the first is for the example
for n=1:nReconstructions
    %dont' go over the size of the number of subplots (minus one for the
    %template)
    if k<=nRows*nCols
        Species=FRresultsTable{1,n+1};
        Species=strrep(Species,'_',' ');
        Version=FRresultsTable{2,n+1};
        modelID=FRresultsTable{3,n+1};
        
        %subplots in order given by FRresultsTable
        %bool gives correct index in FRresults structure
        ind=find(strncmp(modelID,resultsModelID,length(modelID)));
        
        %only plot the reconstructions that are sufficiently
        %stoichiometrically consisitent
        if ~sufficientlyStochConsistent(ind)
            warning('Not sufficiently stoichiometrically consistent. Exchange reactions correctly identified?')
            break
        end
        
        %new subplot
        subplot(nRows,nCols,k);
        
        if isempty(modelID)
            title(Species,'FontWeight','normal','FontSize',11)
        else
            title([Species ', ' Version],'FontWeight','normal','FontSize',11)
        end
        
        %lable first column in each row
        if mod(k,nCols)==1
            ylabel('# Molec.','FontSize',13)
        end
        if k>(nRows-1)*nCols
            xlabel('# Reactions','FontSize',13)
        end
        hold on;
        
        %disp(ind)
        model=FRresults(ind).model;
        
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
        if 0
            X=[0,0,nnz(model.FRVcols),nnz(model.FRVcols)];
            Y=[0,nnz(model.FRrows),nnz(model.FRrows),0];
            fill(X,Y,[153 153 255]/255,'EdgeColor','none')
        else
            %distinguish flux consistent internal and exchange reactions
            X=[0,0,nnz(model.FRVcols & model.SIntRxnBool),nnz(model.FRVcols & model.SIntRxnBool)];
            Y=[0,nnz(model.FRrows),nnz(model.FRrows),0];
            fill(X,Y,[153 153 255]/255,'EdgeColor','none')
            %exchange reactions
            X=[0,0,nnz(model.FRVcols & ~model.SIntRxnBool),nnz(model.FRVcols & ~model.SIntRxnBool)];
            X=[size(model.S,2)-nnz(model.FRVcols & ~model.SIntRxnBool)-1,size(model.S,2)-nnz(model.FRVcols & ~model.SIntRxnBool)-1,size(model.S,2),size(model.S,2)];
            Y=[0,nnz(model.FRrows),nnz(model.FRrows),0];
            %fill(X,Y,[54 149 60]/255,'EdgeColor','none')
            fill(X,Y,[192 192 192]/255,'EdgeColor','none')
        end
        
        if 0
            X=[0,0,nnz(model.fluxConsistentRxnBool),nnz(model.fluxConsistentRxnBool)];
            Y=[0,nnz(model.fluxConsistentMetBool),nnz(model.fluxConsistentMetBool),0];
            fill(X,Y,[102 153 255]/255,'EdgeColor','none')
        end
        
        if 0
            X=[0,0,nnz(model.fluxConsistentRxnBool),nnz(model.fluxConsistentRxnBool)];
            Y=[0,nnz(model.FRnonZeroBool),nnz(model.FRnonZeroBool),0];
            fill(X,Y,'k','EdgeColor','none')
            
            X=[0,0,nnz(model.fluxConsistentRxnBool),nnz(model.fluxConsistentRxnBool)];
            Y=[0,nnz(model.FRuniqueBool),nnz(model.FRuniqueBool),0];
            fill(X,Y,'w','EdgeColor','none')
        end
        
        if 0
            X=[0,0,nnz(model.fluxConsistentRxnBool),nnz(model.fluxConsistentRxnBool)];
            Y=[0,nnz(model.FRrows),nnz(model.FRrows),0];
            fill(X,Y,[153 153 255]/255,'EdgeColor','none')
        end
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
