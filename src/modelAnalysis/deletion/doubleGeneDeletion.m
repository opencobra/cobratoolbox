function [grRatioDble,grRateKO,grRateWT] = doubleGeneDeletion(model,method,geneList1,geneList2,verbFlag)
%doubleGeneDeletion Performs double gene deletion analysis using FBA, MOMA,
%or linear MOMA
%
% [grRatioDble,grRateKO,grRateWT] =
%     doubleGeneDeletion(model,method,geneList1,geneList2,verbFlag)
%
%INPUT
% model         COBRA model structure
%
%OPTIONAL INPUTS
% method        Either 'FBA' (default) 'MOMA', or 'lMOMA'
% geneList1     List of query genes to be deleted (default = all genes)
% geneList2     List of target genes to be deleted (default = geneList1)
% verbFlag      Verbose output (default = false)
%
%OUTPUTS
% grRatioDble   Computed growth rate ratio between double deletion strain
%               and wild type
% grRateKO      Double deletion strain growth rates (1/h)
% grRateWT      Wild type growth rate (1/h)
%
% Markus Herrgard 8/8/06

if (nargin < 2)
    method = 'FBA';
end
if (nargin < 3)
    geneList1 = model.genes;
    differentSetsFlag = false;
else
    if (isempty(geneList1))
        geneList1 = model.genes;
    end
end

if (nargin < 4)
    geneList2 = geneList1;
    differentSetsFlag = false;
else
    if (isempty(geneList2))
        geneList2 = geneList1;
        differentSetsFlag = false;
    else
        differentSetsFlag = true;
    end
end
if (nargin < 5)
    verbFlag = false;
end

nGenes = length(model.genes);

% Run single gene deletions first to figure out lethal genes
fprintf('Single deletion analysis to remove lethal genes\n');
[singleRatio1,singleRate1,grRateWT] = singleGeneDeletion(model,method,geneList1,verbFlag);
singleLethal1 = (singleRatio1 < 1e-9);
geneListOrig1 = geneList1;
geneListOrig2 = geneList1;
geneList1 = geneList1(~singleLethal1);
singleRate = singleRate1(~singleLethal1);
[tmp,listMap1] = ismember(geneListOrig1,geneList1);
fprintf('%d non-lethal genes\n',length(geneList1));

% Repeat the analysis for the second set of genes
if (differentSetsFlag)
    fprintf('Single deletion analysis to remove lethal genes from gene set 2\n');
    [singleRatio2,singleRate2,grRateWT] = singleGeneDeletion(model,method,geneList2,verbFlag);
    singleLethal2 = (singleRatio2 < 1e-9);
    geneListOrig2 = geneList2;
    geneList2 = geneList2(~singleLethal2);
    [tmp,listMap2] = ismember(geneListOrig2,geneList2);
    fprintf('%d non-lethal genes\n',length(geneList2));
else
    geneList2 = geneList1;
    listMap2 = listMap1;
end

nDelGenes1 = length(geneList1);
nDelGenes2 = length(geneList2);

grRateKO = ones(nDelGenes1,nDelGenes2)*grRateWT;
grRatioDble = ones(nDelGenes1,nDelGenes2);

if (differentSetsFlag)
    nTotalPairs = nDelGenes1*nDelGenes2;
else
    nTotalPairs = nDelGenes1*(nDelGenes1-1)/2;
end

% Run double deletion analysis
delCounter = 0;
fprintf('Double gene deletion analysis\n');
fprintf('Total of %d pairs to analyze\n',nTotalPairs);
showprogress(0,'Double gene deletion analysis in progress ...');
t = cputime;
fprintf('Perc complete\tCPU time\n');
for geneNo1 = 1:nDelGenes1

    % Find gene index
    [isInModel,geneID1] = ismember(geneList1{geneNo1},model.genes);
    if (~differentSetsFlag)
        grRateKO(geneNo1,geneNo1) = singleRate(geneNo1);
        initID = geneNo1+1;
    else
        initID = 1;
    end
    for geneNo2 = initID:nDelGenes2
        delCounter = delCounter + 1;
        if (mod(delCounter,10) == 0)
            showprogress(delCounter/nTotalPairs);
        end
        if (mod(delCounter,100) == 0)
            fprintf('%5.2f\t%8.1f\n',100*delCounter/nTotalPairs,cputime-t);
        end
        % Save results every 1000 steps
        if (mod(delCounter,1000) == 0)
            save doubleGeneDeletionTmp.mat grRateKO
        end
        [isInModel,geneID2] = ismember(geneList2{geneNo2},model.genes);
        % Find rxns associated with this gene
        rxnInd = find(any(model.rxnGeneMat(:,[geneID1 geneID2]),2));
        if (~isempty(rxnInd))
            % Initialize the state of all genes
            x = true(nGenes,1);
            x(geneID1) = false;
            x(geneID2) = false;
            constrainRxn = false(length(rxnInd),1);
            % Figure out if any of the reaction states is changed
            for rxnNo = 1:length(rxnInd)
                if (~eval(model.rules{rxnInd(rxnNo)}))
                    constrainRxn(rxnNo) = true;
                end
            end
            % Use FBA/MOMA/lMOMA to calculate deletion strain growth rate
            if (any(constrainRxn))
                constrRxnInd = rxnInd(constrainRxn);
                modelTmp = model;
                modelTmp.lb(constrRxnInd) = 0;
                modelTmp.ub(constrRxnInd) = 0;
                % Get double deletion growth rate
                switch method
                    case 'lMOMA'
                        solKO = linearMOMA(model,modelTmp,'max');
                    case 'MOMA'
                        solKO = MOMA(model,modelTmp,'max',false,true);
                    otherwise
                        solKO = optimizeCbModel(modelTmp,'max');
                end
                %solKO = optimizeCbModel(modelTmp,'max');
                if (solKO.stat > 0)
                    grRateKO(geneNo1,geneNo2) = solKO.f;
                    grRateKO(geneNo2,geneNo1) = solKO.f;
                else
                    grRateKO(geneNo1,geneNo2) = 0;
                    grRateKO(geneNo2,geneNo1) = 0;
                end
            end
        end
        if (verbFlag)
            fprintf('%4d\t%4.1f\t%10s\t%10s\t%9.3f\t%9.3f\n',delCounter,100*delCounter/nTotalPairs,geneList1{geneNo1},...
                geneList2{geneNo2},grRateKO(geneNo1,geneNo2),grRateKO(geneNo1,geneNo2)/grRateWT*100);
        end
        if (differentSetsFlag)
            grRateKO(geneNo2,geneNo1) = grRateKO(geneNo1,geneNo2);
        end
    end
end

% Reconstruct the entire matrix
for i = 1:length(geneListOrig1)
    for j = 1:length(geneListOrig2)
        if (listMap1(i) > 0 & listMap2(j) > 0)
            allGrRateKO(i,j) = grRateKO(listMap1(i),listMap2(j));
        else
            allGrRateKO(i,j) = 0;
        end
    end
end

grRatioDble = allGrRateKO/grRateWT;

grRateKO = allGrRateKO;
