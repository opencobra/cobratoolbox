function [FRresultsTable,FRresults]=makeFRresultsTable(FRresults,resultsDirectory,resultsFileName,modelMetaData,tableFilename)
%makes a table of FR results
%
%INPUT
% FRresults             output of checkRankFRdriver
%
%OPTIONAL INPUT
% resultsDirectory      directory where output of checkRankFRdriver has been saved
% filename              filename where output of checkRankFRdriver has been saved
% modelMetaData         Cell array, where each row is metadata for one model
%                       with five columns: species, version, fileName, PMID, doi.
%                       See function modelMetaData=modelCitations()
% tableFilename         If provided, a the table of results is written out
%                       to a csv file, with specified filename
%
%OUTPUT
% FRresultsTable        table displaying the results of checkRankFRdriver 
% FRresults             output of checkRankFRdriver

%'Conditions for duality between fluxes and concentrations in biochemical networks
%Ronan M.T. Fleming

if isempty(FRresults)
    if ~exist('resultsFileName','var')
        %resultsFileName='FRresults_20150128T225813';
        resultsFileName='FRresults_20150130T011200';
    end
    %results directory
    if ~exist('resultsDirectory','var')
        resultsDirectory='/home/rfleming/Dropbox/modelling/results/FRresults/';
    end
    cd(resultsDirectory)
    load([resultsDirectory resultsFileName])
    
    nResults=length(FRresults);
    if 1
        %filename order of results structure
        for k=1:nResults
            tmp=FRresults(k).modelFilename;
            FRresults(k).modelID=tmp(1:end-4);%take off .mat
        end
    end
else
    nResults=length(FRresults);
end

%extra column and extra row for headings
FRresultsTable=cell(29,nResults+1); %todo, come back and set correct number

if exist('modelMetaData','var')
    if isempty(modelMetaData)
        clear modelMetaData;
    end
end

firstColumn=1;
k=1;
while k<=nResults
    if ~firstColumn %&& 0
        disp(FRresults(k).modelID)
    end
    i=1;
    %the results may not be in alphabetical order but the table should be
    %so find the alphabetical position in the table for result(k)
    %modelMetaData is sorted alphabetically by species
    %Each row of modelMetaData: species, modelID, PMID, doi;
    if ~firstColumn
        %search against the filename specific to each model
        if exist('modelMetaData','var')
            bool=strcmp(FRresults(k).modelID,modelMetaData(:,3));
            if any(bool)
                n=find(bool);
            end
        else
            n=k;
            warning('no metadata found for for model')
        end
    end
    
    if firstColumn
        FRresultsTable{i,1}='Species';
    else
        if exist('modelMetaData','var')
            FRresultsTable{i,n+1}=modelMetaData{bool,1};
        else
            FRresultsTable{i,n+1}='';
        end
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='Version';
    else
        if exist('modelMetaData','var')
            FRresultsTable{i,n+1}=modelMetaData{bool,2};
        else
            FRresultsTable{i,n+1}='';
        end
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='modelID';
    else
        if exist('modelMetaData','var')
            FRresultsTable{i,n+1}=modelMetaData{bool,3};
        else
            FRresultsTable{i,n+1}=FRresults(k).modelID;
        end
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='PMID or DOI';
    else
        if exist('modelMetaData','var')
            if ~isempty(modelMetaData{bool,4})
                %pubmed id
                FRresultsTable{i,n+1}=modelMetaData{bool,4};
            else
                %doi
                FRresultsTable{i,n+1}=modelMetaData{bool,5};
            end
        else
            FRresultsTable{i,n+1}='';
        end
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Reactants = # Rows of [S S_e]';
    else
        disp(k)
        FRresultsTable{i,n+1}=size(FRresults(k).model.S,1);
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Rank of reconstruction [F,R]';
    else
        FRresultsTable{i,n+1}=FRresults(k).rankFRvanilla;
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Rank [S S_e]';
    else
        FRresultsTable{i,n+1}=FRresults(k).rankS;
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='min coefficient magnitude [S S_e]';
    else
        bool=FRresults(k).model.S~=0;
        A=abs(FRresults(k).model.S);
        FRresultsTable{i,n+1}=min(min(A(A~=0)));
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='max coefficient magnitude [S S_e]';
    else
        bool=FRresults(k).model.S~=0;
        A=abs(FRresults(k).model.S);
        FRresultsTable{i,n+1}=max(max(A(A~=0)));
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='min/max coefficient magnitude [S S_e]';
    else
        bool=FRresults(k).model.S~=0;
        A=abs(FRresults(k).model.S);
        FRresultsTable{i,n+1}=min(min(A(A~=0)))/max(max(A(A~=0)));
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Elementally balanced rows (given formulae)';
    else
        if isfield(FRresults(k).model,'balancedMetBool')
            FRresultsTable{i,n+1}=nnz(FRresults(k).model.balancedMetBool);
        else
            FRresultsTable{i,n+1}=NaN;
        end
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Stoich. consistent rows';
    else
        FRresultsTable{i,n+1}=nnz(FRresults(k).model.SConsistentMetBool);
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Nontrivial stoich. consistent rows';
    else
        FRresultsTable{i,n+1}=nnz(FRresults(k).model.SConsistentMetBool & FRresults(k).model.FRuniqueRowBool & FRresults(k).model.FRnonZeroRowBool1);
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Nontrivial stoich. and flux consistent rows of [F,R]';
    else
        FRresultsTable{i,n+1}=nnz(FRresults(k).model.SConsistentMetBool & FRresults(k).model.FRuniqueRowBool & FRresults(k).model.FRnonZeroRowBool1 & FRresults(k).model.fluxConsistentMetBool);
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Unique stoich. and nontrivial flux consistent rows of [F,R]';
    else
        FRresultsTable{i,n+1}=nnz(FRresults(k).model.SConsistentMetBool & FRresults(k).model.FRuniqueRowBool & FRresults(k).model.FRnonZeroRowBool1 & FRresults(k).model.fluxConsistentMetBool & FRresults(k).model.FRnonZeroRowBool);
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Rows of proper [F,R]';
    else
        FRresultsTable{i,n+1}=nnz(FRresults(k).model.FRrows);
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='  Rank of nontrivial stoich. and flux consistent [F,R]';
    else
        FRresultsTable{i,n+1}=FRresults(k).rankFR;
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Rows of bilinear [F,R]';
    else
        FRresultsTable{i,n+1}=size(FRresults(k).model.Frb,1);
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Rank of bilinear [F,R]';
    else
        FRresultsTable{i,n+1}=FRresults(k).model.rankBilinearFrRr;
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Largest connected rows of [F,R]';
    else
        FRresultsTable{i,n+1}=nnz(FRresults(k).model.largestConnectedRowsFRBool);
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Exchange rows = # Rows exclusive to S_e';
    else
        FRresultsTable{i,n+1}=nnz(~FRresults(k).model.SIntMetBool);
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Reactions = # Cols of [S S_e]';
    else
        FRresultsTable{i,n+1}=size(FRresults(k).model.S,2);
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Exchange cols = # Cols of S_e';
    else
        FRresultsTable{i,n+1}=nnz(~FRresults(k).model.SIntRxnBool);
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Elementally balanced cols';
    else
        if isfield(FRresults(k).model,'balancedRxnBool')
            FRresultsTable{i,n+1}=nnz(FRresults(k).model.balancedRxnBool);
        else
            FRresultsTable{i,n+1}=NaN;
        end
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Stoichiometrially consistent cols';
    else
        FRresultsTable{i,n+1}=nnz(FRresults(k).model.SConsistentRxnBool);
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Unique and stoichiometrially consistent cols';
    else
        FRresultsTable{i,n+1}=nnz(FRresults(k).model.SConsistentRxnBool & FRresults(k).model.FRuniqueColBool); 
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Unique stoich. and flux consistent cols of [F;R]';
    else
        FRresultsTable{i,n+1}=nnz(FRresults(k).model.SConsistentRxnBool & FRresults(k).model.FRuniqueColBool & FRresults(k).model.fluxConsistentRxnBool);
    end
    i=i+1;    
    if firstColumn
        FRresultsTable{i,1}='# Nontrivial stoich. and flux consistent cols of [F;R]';
    else
        FRresultsTable{i,n+1}=nnz(FRresults(k).model.SConsistentRxnBool & FRresults(k).model.FRuniqueColBool & FRresults(k).model.fluxConsistentRxnBool & FRresults(k).model.FRnonZeroColBool);
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Largest connected cols of [F;R]';
    else
        FRresultsTable{i,n+1}=nnz(FRresults(k).model.largestConnectedColsFRVBool);
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Cols of proper [F;R]';
    else
        FRresultsTable{i,n+1}=nnz(FRresults(k).model.FRVcols);
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Rank of proper [F;R]';
    else
        FRresultsTable{i,n+1}=FRresults(k).rankFRV;
    end
    i=i+1;
    if firstColumn
        FRresultsTable{i,1}='# Rank of vanilla [F;R]';
    else
        FRresultsTable{i,n+1}=FRresults(k).rankFRVvanilla;
    end
    i=i+1;
%     if firstColumn
%         FRresultsTable{i,1}='Coherence of S';
%     else
%         FRresultsTable{i,n+1}=FRresults(k).coherenceS;
%     end
    
    %now move to columns for results
    if firstColumn
        firstColumn=0;
    else
        k=k+1;
    end
end

FRresultsTable=cell2table(FRresultsTable);

if exist('tableFilename','var')
    writetable(FRresultsTable,tableFilename,'Delimiter','\t')
end