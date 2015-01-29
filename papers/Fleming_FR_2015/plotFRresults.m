%displays the results saved from checkRankFRdriver.m
clear all
close all
path='~/Dropbox/graphStoich/results/FRresults/';
%filename='FRresults_20141216T224334';
%filename='FRresults_20141218T165109';
%filename='FRresults_20141219T111956';
%filename='FRresults_20150127T201551';
filename='FRresults_20150128T225813';

%number of rows and columns of the figure
nRows=6;
nCols=5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load([path filename])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%model citations
modelMetaData=modelCitations();

%sort the models alphabetically by the species
[tmp,indicies]=sort(modelMetaData(:,1));
modelMetaData=modelMetaData(indicies,:);

if 1
    %sort the FRtable alphabetically by the species
    [mlt,nlt]=size(FRtable);
    FRtableXLSa=cell(mlt+1,nlt);
    FRtableXLSa{1,1}='Species';
    FRtableXLSa(2:mlt+1,1)=FRtable(:,1);
    FRtableXLSa{2,1}='ModelID';
    for i=1:size(modelMetaData,1)
        FRtableXLSa{1,i+1}=modelMetaData{i,1};
        bool=strcmp([modelMetaData{i,2} '.mat'],FRtable(1,:));
        %disp(modelMetaData{i,2})
        %find(bool)
        FRtableXLSa(2:mlt+1,i+1)=FRtable(:,bool);
        tmp=FRtableXLSa{2,i+1};
        FRtableXLSa{2,i+1}=tmp(1:end-4);
    end
    
    %select the rows to show
    rowsToShow={
        'Species';
        'ModelID';
        '# Rank [S S_e]';
        '# Reactants = # Rows of [S S_e]';
        '# Exchange reactions = # Rows exclusive to S_e';
        '# Elementally balanced rows (formulae exist)';
        '# Stoichiometrially consistent rows';
        '# Unique and stoichiometrially consistent rows';
        '# Unique stoich. and flux consistent rows of [F,R]';
        '# Unique stoich. and flux consistent nonzero rows of [F,R]';
        '# Rank of proper [F,R]';'# Rank of vanilla [F,R]';
        '# Rows of [Fb,Rb]';'# Rank of [Fb,Rb]';
        '# Reactions = # Cols of [S S_e]';
        '# Exchange cols = # Cols of S_e';
        '# Elementally balanced cols';
        '# Stoichiometrially consistent cols';
        '# Unique and stoichiometrially consistent cols';
        '# Unique stoich. and flux consistent cols of [F;R]';
        '# Unique stoich. and flux consistent nonzero rows of [F;R]'};
    
    boolToShow=false(size(FRtableXLSa,1),1);
    for j=1:length(boolToShow)
        if any(strmatch(FRtableXLSa{j,1},rowsToShow))
            %disp(FRtableXLSa{j,1})
            boolToShow(j)=1;
        end
    end
    FRtableXLS=FRtableXLSa(boolToShow,:);
end

% [nProperties,nModels]=size(FRtable);
% nProperties=nProperties-1;
% nModels=nModels-1;
% FRtable(:,2:nModels+1)=FRtable(:,indicies);


% RGB Value  Short Name  Long Name
% [1 1 0] y yellow
% [1 0 1] m magenta 
% [0 1 1] c cyan
% [1 0 0] r red
% [0 1 0] g green
% [0 0 1] b blue
% [1 1 1] w white
% [0 0 0] k black

nReconstructions=size(FRtable,2)-1;

%flag models with [F,R] that is row rank deficient
fprintf('%s\n','[F,R] does not have full row rank for:')
fprintf('%s%s%s\n','Model                ','Rows([F,R]) ', 'Rank([F,R])')
for j=1:nReconstructions
    bool1=strcmp('# Rows of proper [F,R]',FRtable(:,1));
    bool2=strcmp('# Rank of proper [F,R]',FRtable(:,1));
    if FRtable{bool1,j+1}~=FRtable{bool2,j+1}
        fprintf('%20s\t%u\t%u\n',FRtable{1,j+1},FRtable{bool1,j+1},FRtable{bool2,j+1})
    end
end
fprintf('\n')

%flag models with [Fb,Rb] that is row rank deficient
fprintf('%s\n','[Fb,Rb] does not have full row rank for...')
fprintf('%20s%s%s\n','Model           ','Rows([Fb,Rb]) ', 'Rank([Fb,Rb])')
for j=nReconstructions
    bool1=strcmp('# Rows of [Fb,Rb]',FRtable(:,1));
    bool2=strcmp('# Rank of [Fb,Rb]',FRtable(:,1));
    if FRtable{bool1,j+1}~=FRtable{bool2,j+1}
        fprintf('%20s\t%u\t%u\n',FRtable{1,j+1},FRtable{bool1,j+1},FRtable{bool2,j+1})
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
    bool1=strcmp('# Reactants = # Rows of [S S_e]',FRtable(:,1));
    bool2=strcmp('# Stoich. consistent rows',FRtable(:,1));
    stochConsistentFraction(j)=FRtable{bool2,j+1}/FRtable{bool1,j+1};
    if stochConsistentFraction(j)<tol
        sufficientlyStochConsistent(j)=0;
        fprintf('%20s\t%u\t%u\n',FRtable{1,j+1},FRtable{bool1,j+1},FRtable{bool2,j+1})
        %fprintf('%s ',FRtable{1,j+1})
    end
end
fprintf('%u%s\n',nnz(sufficientlyStochConsistent), ' models that are sufficiently stochiometrically consistent for plotting.')

if 0
    %flag models with a high fraction of stoichiometrically consistent rows
    fprintf('\n%s\n',['Reconstructions with more than ' num2str(tol*100) '% stoichiometrically inconsistent rows...'])
    fprintf('%%s%s%s\n','Organism      ','Model                 ','Reactants ', 'Stoic. consistent')
    for j=1:nReconstructions
        if sufficientlyStochConsistent(j)
            fprintf('%s%s%s%s\n','''''',FRtable{1,j+1}(1:end-4),','''',',''''';')
        end
    end
end

if 0
    figure;
    hist(stochConsistentFraction,100)
    fprintf('\n')
end

h=figure;
k=1;%first plot is for legend
subplot(nRows,nCols,k)
hold on;
ylabel('# Molecules','FontSize',13)
title('Species, modelID','FontWeight','normal','FontSize',11)
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
fill(X,Y,[153 153 255]/255,'EdgeColor','none')

k=k+1;
%start at the second subplot as the first is for the example
while k <= nRows*nCols && k<= nReconstructions+1
    %subplots in order given by sorted metadata
    bool=strncmp(modelMetaData{k-1,2},FRtable(1,:),length(modelMetaData{k-1,2}));
    %first column in FRtable is for labels
    bool=bool(2:end);
    
    %only plot the reconstructions that are sufficiently
    %stoichiometrically consisitent
    if ~sufficientlyStochConsistent(bool)
        warning('Not sufficiently stoichiometrically consistent. Exchange reactions correctly identified?')
    end
    
    model=results(bool).model;
    
    subplot(nRows,nCols,k)
    %model IDs the same as the names of the files whence they came
    modelID=results(bool).modelFilename(1:end-4);
    %replace odd names
    modelID=strrep(modelID,'Ecoli_core','core');
    modelID=strrep(modelID,'K_pneumonieae_rBioNet','');
    modelID=strrep(modelID,'L_lactis_MG1363','');
    modelID=strrep(modelID,'Recon2betaModel_121114','Recon2.03');
    modelID=strrep(modelID,'Sc_thermophilis_rBioNet','');
    modelID=strrep(modelID,'T_Maritima','v1');
    modelID=strrep(modelID,'iTZ479_v2','iTZ479v2');
    modelID=strrep(modelID,'','');

    if isempty(modelID)
        title([modelMetaData{k-1,1}],'FontWeight','normal','FontSize',11)
    else
        title([modelMetaData{k-1,1} ', ' modelID],'FontWeight','normal','FontSize',11)
    end
    
    %lable first column in each row
    if mod(k,nCols)==1
        ylabel('# Molecules','FontSize',13)
    end
    if k>(nRows-1)*nCols
        xlabel('# Reactions','FontSize',13)
    end
    
    hold on;
    
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
    
    %Stoichiometrically consistent & flux consistent (non-exchange and
    %exchange reactions, unique & nonzero
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
        fill(X,Y,[153 153 255]/255,'EdgeColor','none')
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
%legend('Original','Stoichiometrically consistent','+ Flux consistent','+ non-zero','+ unique','full rank([F R])');
%legend('Reconstruction','Stoich. consistent','Nontrivial, stoich. & flux consistent','[F R] full row rank');
%legend('Reconstruction','Stoich. consistent','Stoich. consistent, flux consistent, unique & nonzero.');

%table for paper
rowHeadings={'Species';
'Model identifier';
'Citation';
'# Molecular species';
'Rank of reconstruction [F,R]';
'# Rows exclusive to S_e';
'# Elementally balanced rows (formulae exist)';
'# Stoichiometrially consistent rows';
'# Unique and stoichiometrially consistent rows';
'# Unique stoich. and flux consistent rows of [F,R]';
'# Unique stoich. and flux consistent nonzero rows of [F,R]';
'# Rows of model [F,R]';
'Rank of model [F,R]';
'# Rows of [Fb,Rb]';
'Rank of [Fb,Rb]'};

tableForPaper=cell(length(rowHeadings),length(nReconstructions));

tableForPaper(:,1)=rowHeadings;

for n=1:nReconstructions
    %table in alphabetical order, so find the correct model in the FRtable
    bool=strncmp(modelMetaData{n,2},FRtable(1,:),length(modelMetaData{n,2}));
    %first column in FRtable is for labels
    bool=bool(2:end);
    %k is the index of the model corresponding to the alphabetically
    %selected model
    k=find(bool);
    model=results(k).model;
    
    i=1;
    %Species
    tableForPaper{i,n+1}=modelMetaData{n,1};
    i=i+1;
    
    %model IDs 
    %the same as the names of the files whence they came
    modelID=results(k).modelFilename(1:end-4);
    %replace odd names
    modelID=strrep(modelID,'Ecoli_core','core');
    modelID=strrep(modelID,'K_pneumonieae_rBioNet','');
    modelID=strrep(modelID,'L_lactis_MG1363','');
    modelID=strrep(modelID,'Recon2betaModel_121114','Recon2.03');
    modelID=strrep(modelID,'Sc_thermophilis_rBioNet','');
    modelID=strrep(modelID,'T_Maritima','v1');
    modelID=strrep(modelID,'iTZ479_v2','iTZ479v2');
    modelID=strrep(modelID,'','');
    tableForPaper{i,n+1}=modelID;
    i=i+1;
    
    %citation
    tableForPaper{3,n+1}=[modelMetaData{n,3} modelMetaData{n,4}];
    i=i+1;
    %data
    tableForPaper{i,n+1}=size(results(k).model.S,1);
    i=i+1;
    tableForPaper{i,n+1}=results(k).rankFRvanilla;
    i=i+1;
    tableForPaper{i,n+1}=nnz(~results(k).model.SIntMetBool);
    i=i+1;
    if isfield(results(k).model,'balancedMetBool')
        tableForPaper{i,n+1}=nnz(results(k).model.balancedMetBool);
    else
        tableForPaper{i,n+1}=NaN;
    end
    i=i+1;
    tableForPaper{i,n+1}=nnz(results(k).model.SConsistentMetBool);
    i=i+1;
    tableForPaper{i,n+1}=nnz((results(k).model.SConsistentMetBool | ~results(k).model.SIntMetBool) & results(k).model.FRuniqueRowBool);
    i=i+1;
    tableForPaper{i,n+1}=nnz((results(k).model.SConsistentMetBool | ~results(k).model.SIntMetBool) & results(k).model.FRuniqueRowBool & results(k).model.fluxConsistentMetBool);
    i=i+1;
    tableForPaper{i,n+1}=nnz((results(k).model.SConsistentMetBool | ~results(k).model.SIntMetBool) & results(k).model.FRuniqueRowBool & results(k).model.fluxConsistentMetBool & results(k).model.FRnonZeroRowBool);
    i=i+1;
    tableForPaper{i,n+1}=nnz(results(k).model.FRrows);
    i=i+1;
    tableForPaper{i,n+1}=results(k).rankFR;
    i=i+1;
    tableForPaper{i,n+1}=size(results(k).model.Frb,1);
    i=i+1;
    tableForPaper{i,n+1}=results(k).model.rankBilinearFrRr;
    i=i+1;
end

