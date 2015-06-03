%check the rank of FR for the human model after preprocessing

clear
load ~/work/graphStoich/data/modelCollection/121114_Recon2betaModel.mat
model=modelRecon2beta121114;
printLevel=0;
model=findSExRxnInd(model);
if 0
    [inform,m,model]=checkStoichiometricConsistency(model,printLevel);
    nnz(model.SConsistentBool)
    return
end

printLevel=0;
[rankFR,rankFRV,model] = checkRankFR(model,printLevel);
[rankS,p,q]= getRankLUSOL(model.S);

[nMet,nRxn]=size(model.S);
%forward and reverse half stoichiometric matrices 
F       = -model.S;
F(F<0)  =    0;
R       =  model.S;
R(R<0)  =    0;

%indices of rows
dR=find(model.FRdrows);
wR=find(model.FRwrows);
iR=find(model.FRirows);

%matrix of dependencies
W=model.FRW;

if 0
    %display the rows
    FRdisplay=[F(:,model.FRVcols), R(:,model.FRVcols)];
    FRdisplay=FRdisplay([wR;dR],:);
    FRdisplay=FRdisplay(:,sum(FRdisplay,1)~=0);
    FRdisplay=full(FRdisplay);
    %disp(FRdisplay)
    
    fprintf('%s%d%s%d%s%d%s\n','FR subset of dimension ',size(FRdisplay,1),' x ', size(FRdisplay,2), ', of rank ', rank(FRdisplay),'.')
    fprintf('%d%s\n', length(wR), ' independent rows:')
    disp(FRdisplay(1:length(wR),:))
    fprintf('%d%s\n',length(dR),' dependent rows:')
    disp(FRdisplay(length(wR)+1:end,:))
    
    %example for table
    %independent metabolites from reactions where other metabolites are in complexes that are combinatorially dpendenent
    oRmets={'h[l]','nadph[l]','h2o[l]'};
    %independent metabolites in complexes that are combinatorially dependent
    wRmets={'estrone[l]','CE2180[l]','C05298[l]','C06199[l]'};
    %dependent metabolites in complexes that are combinatorially dependent
    dRmets={'nadp[l]','o2[l]'};
    
    for i=1:length(oRmets)
        oRmetsInd(i,1)=find(strcmp(oRmets{i},model.mets));
    end
    for i=1:length(wRmets)
        wRmetsInd(i,1)=find(strcmp(wRmets{i},model.mets));
    end
    for i=1:length(dRmets)
        dRmetsInd(i,1)=find(strcmp(dRmets{i},model.mets));
    end
    
    %display the rows
    Sbar=model.S~=0;
    displayCols=sum(Sbar([wRmetsInd;dRmetsInd],:),1)~=0;
    displayCols=displayCols &  model.FRVcols';
    FRdisplay=full([F([oRmetsInd;wRmetsInd;dRmetsInd],displayCols), R([oRmetsInd;wRmetsInd;dRmetsInd],displayCols)]);
    disp(FRdisplay)
    
    cellFRdisplay=cell(size(FRdisplay)+1);
    %headings
    rowInds=[oRmetsInd;wRmetsInd;dRmetsInd];
    colInds=find(displayCols);
    for i=1:size(FRdisplay,1)
        cellFRdisplay{i+1,1}=model.mets{rowInds(i)};
        for j=1:size(FRdisplay,2)
            if i==1 && j<=length(colInds)
                cellFRdisplay{1,j+1}=model.rxns{colInds(j)};
                cellFRdisplay{1,j+length(colInds)+1}=model.rxns{colInds(j)};
            end
            cellFRdisplay{i+1,j+1}=FRdisplay(i,j);
        end
    end
end


%OUTPUT
% rankFR                    rank of [F R], when using only FRrows
% rankFRV                   rank of [F;R], when using only FRVcols
% model.SIntRxnBool         n x 1 boolean vector indicating the reactions that are
%                           thought to be mass balanced.
% model.SConsistentBool     m x 1 boolean vector indicating metabolites involved
%                           in the maximal consistent vector
% model.FRrows              m x 1 boolean of rows of [F R] that are nonzero,
%                           unique upto positive scaling and part of the
%                           maximal conservation vector
% model.FRVcols             n x 1 boolean of cols of [F;R] that are nonzero,
%                           unique upto positive scaling and part of the
%                           maximal conservation vector
% model.FRdrows             m x 1 boolean of rows of [F R] that are dependent
% model.FRVdcols            n x 1 boolean of cols of [F;R]that are dependent
% model.SConsistentBool     m x 1 boolean vector indicating metabolites involved
%                           in the maximal consistent vector
% model.FRnonZeroBool       m x 1 boolean vector indicating metabolites involved
%                           in at least one internal reaction
% model.FRuniqueBool        m x 1 boolean vector indicating metabolites with
%                           reaction stoichiometry unique upto scalar multiplication
% model.SIntRxnBool         n x 1 boolean vector indicating the non exchange
%                           reactions
% model.FRVnonZeroBool      n x 1 boolean vector indicating non exchange reactions
%                           with at least one metabolite involved
% model.FRVuniqueBool       n x 1 boolean vector indicating non exchange reactions
%                           with stoichiometry unique upto scalar multiplication
% model.connectedRowsFRBool     m x 1 boolean vector indicating metabolites in connected rows of [F,R]
% model.connectedRowsFRVBool    n x 1 boolean vector indicating complexes in connected columns of [F;R]

%hist(sum(model.connectedRowsFRBool,1))

if 1
    %table with summary of results
    %headings
    FRtable=cell(12,2);
    i=1;
    %model
    FRtable{i,1}='';
    i=i+1;
    FRtable{i,1}='# Rank S';
    %rows
    i=i+1;
    FRtable{i,1}='# Reactants in S';
    i=i+1;
    FRtable{i,1}='# Stoichiometrially consistent';
    i=i+1;
    FRtable{i,1}='# Nonzero rows of [F,R]';
    i=i+1;
    FRtable{i,1}='# Unique  rows of [F,R]';
    i=i+1;
    FRtable{i,1}='# Largest connected rows of [F,R]';
    i=i+1;
    FRtable{i,1}='# Rows of proper [F,R]';
    i=i+1;
    FRtable{i,1}='# Rank of proper [F,R]';
    i=i+1;
    %cols
    FRtable{i,1}='# Reactions in S';
    i=i+1;
    FRtable{i,1}='# Flux consistent';
    i=i+1;
    FRtable{i,1}='# Non exchange';
    i=i+1;
    FRtable{i,1}='# Nonzero cols of [F;R]';
    i=i+1;
    FRtable{i,1}='# Unique  cols of [F;R]';
    i=i+1;
    FRtable{i,1}='# Connected cols of [F;R]';
    i=i+1;
    FRtable{i,1}='# Cols of proper [F;R]';
    i=i+1;
    FRtable{i,1}='# Rank of proper [F;R]';
    i=i+1;
    
    k=1;
    i=1;
    %model
    FRtable{i,k+1}='testModel';
    i=i+1;
    FRtable{i,k+1}=rankS;
    i=i+1;
    %rows
    FRtable{i,k+1}=size(model.S,1);
    i=i+1;
    FRtable{i,k+1}=nnz(model.SConsistentBool);
    i=i+1;
    FRtable{i,k+1}=nnz(model.FRnonZeroBool);
    i=i+1;
    FRtable{i,k+1}=nnz(model.FRuniqueBool);
    i=i+1;
    FRtable{i,k+1}=nnz(model.largestConnectedRowsFRBool);
    i=i+1;
    FRtable{i,k+1}=nnz(model.FRrows);
    i=i+1;
    FRtable{i,k+1}=rankFR;
    i=i+1;
    %columns
    FRtable{i,k+1}=size(model.S,2);
    i=i+1;
    FRtable{i,k+1}=nnz(model.fluxConsistentBool);
    i=i+1;
    FRtable{i,k+1}=nnz(model.SIntRxnBool);
    i=i+1;
    FRtable{i,k+1}=nnz(model.FRVnonZeroBool);
    i=i+1;
    FRtable{i,k+1}=nnz(model.FRVuniqueBool);
    i=i+1;
    FRtable{i,k+1}=nnz(model.connectedColsFRVBool);
    i=i+1;
    FRtable{i,k+1}=nnz(model.FRVcols);
    i=i+1;
    FRtable{i,k+1}=rankFRV;
    i=i+1;
end
save('~/work/graphStoich/data/FRresults/checkRankFRHumanDriver.mat')


