function [modelResultsTable,modelResults]=makeModelPropertiesTable(modelResults,resultsDirectory,resultsFileName,modelMetaData,tableFilename)
%makes a table of model property results
%
%INPUT
% modelResults             output of checkModelProperties
%
%OPTIONAL INPUT
% resultsDirectory      directory where output of checkModelProperties has been saved
% filename              filename where output of checkModelProperties has been saved
% modelMetaData         Cell array, where each row is metadata for one model
%                       with five columns: species, version, fileName, PMID, doi.
%                       See function modelMetaData=modelCitations()
% tableFilename         If provided, a the table of results is written out
%                       to a csv file, with specified filename
%
%OUTPUT
% modelResultsTable        table displaying the results of checkModelProperties
% modelResults             output of checkModelProperties


if isempty(modelResults)
    if ~exist('resultsFileName','var')
        %resultsFileName='FRresults_20150128T225813';
        resultsFileName='FRresults_20150130T011200';
    end
    %results directory
    if ~exist('resultsDirectory','var')
        resultsDirectory='/home/rfleming/Dropbox/modelling/results/modelResults/';
    end
    cd(resultsDirectory)
    load([resultsDirectory resultsFileName])

    nResults=length(modelResults);
    %filename order of results structure
    for k=1:nResults
        tmp=modelResults(k).modelFilename;
        modelResults(k).modelID=tmp(1:end-4);%take off .mat
    end
else
    nResults=length(modelResults);
end

%extra column and extra row for headings
modelResultsTable=cell(29,nResults+1); %todo, come back and set correct number

if exist('modelMetaData','var')
    if isempty(modelMetaData)
        clear modelMetaData;
    end
end

firstColumn=1;
k=1;
while k<=nResults
    if ~firstColumn %&& 0
        disp(modelResults(k).modelID)
    end
    i=1;
    %the results may not be in alphabetical order but the table should be
    %so find the alphabetical position in the table for result(k)
    %modelMetaData is sorted alphabetically by species
    %Each row of modelMetaData: species, modelID, PMID, doi;
    if ~firstColumn
        %search against the filename specific to each model
        if exist('modelMetaData','var')
            bool=strcmp(modelResults(k).modelID,modelMetaData(:,3));
            if any(bool)
                n=find(bool);
            end
        else
            n=k;
            warning('no metadata found for for model')
        end
    end

    if firstColumn
        modelResultsTable{i,1}='Species';
    else
        if exist('modelMetaData','var')
            modelResultsTable{i,n+1}=modelMetaData{bool,1};
        else
            modelResultsTable{i,n+1}='';
        end
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Version';
    else
        if exist('modelMetaData','var')
            modelResultsTable{i,n+1}=modelMetaData{bool,2};
        else
            modelResultsTable{i,n+1}='';
        end
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='modelID';
    else
        if exist('modelMetaData','var')
            modelResultsTable{i,n+1}=modelMetaData{bool,3};
        else
            modelResultsTable{i,n+1}=modelResults(k).modelID;
        end
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='PMID or DOI';
    else
        if exist('modelMetaData','var')
            if ~isempty(modelMetaData{bool,4})
                %pubmed id
                modelResultsTable{i,n+1}=modelMetaData{bool,4};
            else
                %doi
                modelResultsTable{i,n+1}=modelMetaData{bool,5};
            end
        else
            modelResultsTable{i,n+1}='';
        end
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Reactants = # Rows of [S S_e]';
    else
        disp(k)
        modelResultsTable{i,n+1}=size(modelResults(k).model.S,1);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Rank of reconstruction [F,R]';
    else
        modelResultsTable{i,n+1}=modelResults(k).rankFRvanilla;
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Rank [S S_e]';
    else
        modelResultsTable{i,n+1}=modelResults(k).rankS;
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='min coefficient magnitude [S S_e]';
    else
        bool=modelResults(k).model.S~=0;
        A=abs(modelResults(k).model.S);
        modelResultsTable{i,n+1}=min(min(A(A~=0)));
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='max coefficient magnitude [S S_e]';
    else
        bool=modelResults(k).model.S~=0;
        A=abs(modelResults(k).model.S);
        modelResultsTable{i,n+1}=max(max(A(A~=0)));
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='min/max coefficient magnitude [S S_e]';
    else
        bool=modelResults(k).model.S~=0;
        A=abs(modelResults(k).model.S);
        modelResultsTable{i,n+1}=min(min(A(A~=0)))/max(max(A(A~=0)));
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Elementally balanced rows (given formulae)';
    else
        if isfield(modelResults(k).model,'balancedMetBool')
            modelResultsTable{i,n+1}=nnz(modelResults(k).model.balancedMetBool);
        else
            modelResultsTable{i,n+1}=NaN;
        end
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Stoich. consistent rows';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentMetBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Nontrivial stoich. consistent rows';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentMetBool & modelResults(k).model.FRuniqueRowBool & modelResults(k).model.FRnonZeroRowBool1);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Nontrivial stoich. and flux consistent rows of [F,R]';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentMetBool & modelResults(k).model.FRuniqueRowBool & modelResults(k).model.FRnonZeroRowBool1 & modelResults(k).model.fluxConsistentMetBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Unique stoich. and nontrivial flux consistent rows of [F,R]';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentMetBool & modelResults(k).model.FRuniqueRowBool & modelResults(k).model.FRnonZeroRowBool1 & modelResults(k).model.fluxConsistentMetBool & modelResults(k).model.FRnonZeroRowBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Rows of proper [F,R]';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.FRrows);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='  Rank of nontrivial stoich. and flux consistent [F,R]';
    else
        modelResultsTable{i,n+1}=modelResults(k).rankFR;
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Rows of bilinear [F,R]';
    else
        modelResultsTable{i,n+1}=size(modelResults(k).model.Frb,1);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Rank of bilinear [F,R]';
    else
        modelResultsTable{i,n+1}=modelResults(k).model.rankBilinearFrRr;
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Largest connected rows of [F,R]';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.largestConnectedRowsFRBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Exchange rows = # Rows exclusive to S_e';
    else
        modelResultsTable{i,n+1}=nnz(~modelResults(k).model.SIntMetBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Reactions = # Cols of [S S_e]';
    else
        modelResultsTable{i,n+1}=size(modelResults(k).model.S,2);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Exchange cols = # Cols of S_e';
    else
        modelResultsTable{i,n+1}=nnz(~modelResults(k).model.SIntRxnBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Elementally balanced cols';
    else
        if isfield(modelResults(k).model,'balancedRxnBool')
            modelResultsTable{i,n+1}=nnz(modelResults(k).model.balancedRxnBool);
        else
            modelResultsTable{i,n+1}=NaN;
        end
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Stoichiometrially consistent cols';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentRxnBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Unique and stoichiometrially consistent cols';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentRxnBool & modelResults(k).model.FRuniqueColBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Unique stoich. and flux consistent cols of [F;R]';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentRxnBool & modelResults(k).model.FRuniqueColBool & modelResults(k).model.fluxConsistentRxnBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Nontrivial stoich. and flux consistent cols of [F;R]';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentRxnBool & modelResults(k).model.FRuniqueColBool & modelResults(k).model.fluxConsistentRxnBool & modelResults(k).model.FRnonZeroColBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Largest connected cols of [F;R]';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.largestConnectedColsFRVBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Cols of proper [F;R]';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.FRVcols);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Rank of proper [F;R]';
    else
        modelResultsTable{i,n+1}=modelResults(k).rankFRV;
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='# Rank of vanilla [F;R]';
    else
        modelResultsTable{i,n+1}=modelResults(k).rankFRVvanilla;
    end
    i=i+1;
%     if firstColumn
%         modelResultsTable{i,1}='Coherence of S';
%     else
%         modelResultsTable{i,n+1}=modelResults(k).coherenceS;
%     end

    %now move to columns for results
    if firstColumn
        firstColumn=0;
    else
        k=k+1;
    end
end

modelResultsTable=cell2table(modelResultsTable);

if exist('tableFilename','var')
    writetable(modelResultsTable,tableFilename,'Delimiter','\t')
end
