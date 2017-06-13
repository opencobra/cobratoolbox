function [modelResultsTable,modelResults]=makeModelPropertiesTable(modelResults,modelMetaData,resultsDirectory,resultsFileName,tableFilename)
%makes a table of model property results
%
%INPUT
% modelResults             output of checkModelProperties
%
%OPTIONAL INPUT
% modelMetaData         Cell array, where each row is metadata for one model
%                       with five columns: species, modelID, fileName, PMID, doi.
%                       See function modelMetaData=modelCitations() for
%                       example. Table columns ordered by order of rows in
%                       modelMetaData.
% resultsDirectory      directory where output of checkModelProperties has been saved
% filename              filename where output of checkModelProperties has been saved

% tableFilename         If provided, a the table of results is written out
%                       to a csv file, with specified filename
%
%OUTPUT
% modelResultsTable        table displaying the results of checkModelProperties
% modelResults             output of checkModelProperties


if isempty(modelResults)
    if ~exist('resultsFileName','var')
        resultsFileName='FRresults';
    end
    %results directory
    if ~exist('resultsDirectory','var')
        resultsDirectory='~/results/modelResults/';
        mkdir(resultsDirectory)
    end
    cd(resultsDirectory)
    load([resultsDirectory resultsFileName])

    nResults=length(modelResults);
    %modelID order of results structure
    for k=1:nResults
        tmp=modelResults(k).model.modelFilename;
        modelResults(k).model.modelID=tmp(1:end-4);%take off .mat
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
        fprintf('%\n',modelResults(k).model.modelID)
    end
    i=1;
    %the results may not be in alphabetical order but the table should be
    %so find the alphabetical position in the table for result(k)
    %modelMetaData is sorted alphabetically by species
    %Each row of modelMetaData: species, modelID, fileName, PMID, doi;
    if ~firstColumn
        %search against the modelID specific to each model
        if exist('modelMetaData','var')
            bool=strcmp(modelResults(k).model.modelID,modelMetaData(:,2));
            if any(bool)
                n=find(bool);
            else
                n=k;
                error(['no metadata found for for model: ' modelResults(k).model.modelID])
            end
        else
            n=k;
            warning(['no metadata found for for model: ' modelResults(k).model.modelID])
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
        modelResultsTable{i,1}='modelID';
    else
        if exist('modelMetaData','var')
            modelResultsTable{i,n+1}=modelMetaData{bool,2};
        else
            modelResultsTable{i,n+1}=modelResults(k).model.modelID;
        end
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='filename';
    else
        if exist('modelMetaData','var')
            modelResultsTable{i,n+1}=modelMetaData{bool,3};
        else
            modelResultsTable{i,n+1}=modelResults(k).model.modelID;
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
    %rank
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='rank [N B]';
    else
        modelResultsTable{i,n+1}=modelResults(k).model.rankS;
    end
    %separate rows from columns
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Reactions = Cols of [N B]';
    else
        modelResultsTable{i,n+1}=size(modelResults(k).model.S,2);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Internal reactions = Cols of N';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SIntRxnBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Stoichiometrically consistent reactions';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentRxnBool);
    end
    if 0
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Reactions minus stoich. consistent reactions';
        else
            modelResultsTable{i,n+1}=size(modelResults(k).model.S,2)-nnz(modelResults(k).model.SConsistentRxnBool);
        end
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Internal, stoich. inconsistent reactions';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SInConsistentRxnBool & modelResults(k).model.SIntRxnBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Elementally balanced reactions';
    else
        if isfield(modelResults(k).model,'balancedRxnBool')
            modelResultsTable{i,n+1}=nnz(modelResults(k).model.balancedRxnBool);
        else
            modelResultsTable{i,n+1}=NaN;
        end
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Internal, stoich. inconsistent, elementally balanced reactions';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SInConsistentRxnBool & modelResults(k).model.balancedRxnBool & modelResults(k).model.SIntRxnBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Omitted reactions';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.rxnUnknownInconsistentRemoveBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Stoich. and flux consistent reactions';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentRxnBool & modelResults(k).model.fluxConsistentRxnBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Internal reactions minus stoich. and flux consistent reactions';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SIntRxnBool) - nnz(modelResults(k).model.SConsistentRxnBool & modelResults(k).model.fluxConsistentRxnBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Reactions exclusive to leaks';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.leakRxnBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Reactions exclusive to siphons';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.siphonRxnBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='External reactions = Cols of B';
    else
        modelResultsTable{i,n+1}=nnz(~modelResults(k).model.SIntRxnBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='External flux consistent reactions';
    else
        modelResultsTable{i,n+1}=nnz(~modelResults(k).model.SIntRxnBool & modelResults(k).model.fluxConsistentRxnBool);
    end
    if 0
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Unique and Stoichiometrically consistent cols';
        else
            modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentRxnBool & modelResults(k).model.FRuniqueColBool);
        end
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Unique stoich. and flux consistent cols of [F;R]';
        else
            modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentRxnBool & modelResults(k).model.FRuniqueColBool & modelResults(k).model.fluxConsistentRxnBool);
        end
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Nontrivial stoich. and flux consistent cols of [F;R]';
        else
            modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentRxnBool & modelResults(k).model.FRuniqueColBool & modelResults(k).model.fluxConsistentRxnBool & modelResults(k).model.FRnonZeroColBool);
        end
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Largest connected cols of [F;R]';
        else
            modelResultsTable{i,n+1}=nnz(modelResults(k).model.largestConnectedColsFRVBool);
        end
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Cols of proper [F;R]';
        else
            modelResultsTable{i,n+1}=nnz(modelResults(k).model.FRVcols);
        end
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Rank of proper [F;R]';
        else
            modelResultsTable{i,n+1}=modelResults(k).model.rankFRV;
        end
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Rank of vanilla [F;R]';
        else
            modelResultsTable{i,n+1}=modelResults(k).model.rankFRVvanilla;
        end
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Coherence of S';
        else
            modelResultsTable{i,n+1}=modelResults(k).coherenceS;
        end
    end
    %% separate rows from columns
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Species = Rows of [N B]';
    else
        modelResultsTable{i,n+1}=size(modelResults(k).model.S,1);
    end
    if 0
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Rank of reconstruction [F,R]';
        else
            modelResultsTable{i,n+1}=modelResults(k).model.rankFRvanilla;
        end
    end

    if 0
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='min coefficient magnitude [N B]';
        else
            bool=modelResults(k).model.S~=0;
            A=abs(modelResults(k).model.S);
            modelResultsTable{i,n+1}=min(min(A(A~=0)));
        end
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='max coefficient magnitude [N B]';
        else
            bool=modelResults(k).model.S~=0;
            A=abs(modelResults(k).model.S);
            modelResultsTable{i,n+1}=max(max(A(A~=0)));
        end
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='min/max coefficient magnitude [N B]';
        else
            bool=modelResults(k).model.S~=0;
            A=abs(modelResults(k).model.S);
            modelResultsTable{i,n+1}=min(min(A(A~=0)))/max(max(A(A~=0)));
        end
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Stoichiometrically consistent rows';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentMetBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Stoichiometrically inconsistent rows';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SInConsistentMetBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Elementally balanced rows';
    else
        if isfield(modelResults(k).model,'balancedMetBool')
            modelResultsTable{i,n+1}=nnz(modelResults(k).model.balancedMetBool);
        else
            modelResultsTable{i,n+1}=NaN;
        end
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Species minus stoich. consistent rows';
    else
        modelResultsTable{i,n+1}=size(modelResults(k).model.S,1)-nnz(modelResults(k).model.SConsistentMetBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Omitted rows';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.rxnUnknownInconsistentRemoveBool);
    end
    if 0
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Unknown Stoichiometrically consistent rows';
        else
            modelResultsTable{i,n+1}=nnz(modelResults(k).model.unknownSConsistencyMetBool);
        end
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Stoich. and flux consistent rows';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentMetBool & modelResults(k).model.fluxConsistentMetBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Internal species minus stoich. and flux consistent rows';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.SIntMetBool)- nnz(modelResults(k).model.SConsistentMetBool & modelResults(k).model.fluxConsistentMetBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Leak species';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.leakMetBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='Siphon species';
    else
        modelResultsTable{i,n+1}=nnz(modelResults(k).model.siphonMetBool);
    end
    i=i+1;
    if firstColumn
        modelResultsTable{i,1}='External species = Rows exclusive to B';
    else
        modelResultsTable{i,n+1}=nnz(~modelResults(k).model.SIntMetBool);
    end
      if 0
          i=i+1;
          if firstColumn
              modelResultsTable{i,1}='External flux consistent species';
          else
              modelResultsTable{i,n+1}=nnz(~modelResults(k).model.SIntMetBool & modelResults(k).model.fluxConsistentMetBool);
          end
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Nontrivial stoich. consistent rows';
        else
            modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentMetBool & modelResults(k).model.FRuniqueRowBool & modelResults(k).model.FRnonZeroRowBool1);
        end
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Nontrivial stoich. and flux consistent rows of [F,R]';
        else
            modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentMetBool & modelResults(k).model.FRuniqueRowBool & modelResults(k).model.FRnonZeroRowBool1 & modelResults(k).model.fluxConsistentMetBool);
        end
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Unique stoich. and nontrivial flux consistent rows of [F,R]';
        else
            modelResultsTable{i,n+1}=nnz(modelResults(k).model.SConsistentMetBool & modelResults(k).model.FRuniqueRowBool & modelResults(k).model.FRnonZeroRowBool1 & modelResults(k).model.fluxConsistentMetBool & modelResults(k).model.FRnonZeroRowBool);
        end
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Rows of proper [F,R]';
        else
            modelResultsTable{i,n+1}=nnz(modelResults(k).model.FRrows);
        end
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='  Rank of nontrivial stoich. and flux consistent [F,R]';
        else
            modelResultsTable{i,n+1}=modelResults(k).model.rankFR;
        end
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Rows of bilinear [F,R]';
        else
            modelResultsTable{i,n+1}=size(modelResults(k).model.Frb,1);
        end
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Rank of bilinear [F,R]';
        else
            modelResultsTable{i,n+1}=modelResults(k).model.rankBilinearFrRr;
        end
        i=i+1;
        if firstColumn
            modelResultsTable{i,1}='Largest connected rows of [F,R]';
        else
            modelResultsTable{i,n+1}=nnz(modelResults(k).model.largestConnectedRowsFRBool);
        end
    end
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
