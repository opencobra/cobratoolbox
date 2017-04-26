function [wtRes,delRes] = simpleOptKnock(model,targetRxn,deletions,geneDelFlag,minGrowth,doubleDelFlag)
% Simple `OptKnock` is used to check all one gene or reaction deletions for
% growth-coupled metabolite production
%
% USAGE:
%
%    [wtRes, delRes] = simpleOptKnock(model, targetRxn, deletions, geneDelFlag, minGrowth, doubleDelFlag)
%
% INPUTS:
%    model:           COBRA model structure
%    targetRxn:       Target metabolite production reaction
%
% OPTIONAL INPUTS:
%    deletions:       Set of gene or reaction deletions to consider for `KO`
%                     (Default = all reactions)
%    geneDelFlag:     Gene deletion flag (Default = false)
%    minGrowth:       Minimum `KO` growth rate (Default = 0.05)
%    doubleDelFlag:   Double deletions (Default = false)
%
% OUTPUTS:
%    wtRes:           Wild type results
%    delRes:          Deletion strain results
%
% .. Author: - Markus Herrgard 2/14/07
%
% The results structures have fields:
%
%    * `growth` - Growth rate of strain
%    * `minProd` - Minimum prod rate of target metabolite
%    * `maxProd` - Maximum prod rate of target metabolite

if (nargin < 3)
    deletions = model.rxns;
end
if (nargin < 4)
    geneDelFlag = false;
end
if (nargin < 5)
    minGrowth = 0.05;
end
if (nargin < 6)
    doubleDelFlag = false;
end

tol = 1e-7;

% Number of deletions
nDel = length(deletions);

% Wild type values
solWT = optimizeCbModel(model);
grRounded = floor(solWT.f/tol)*tol;
modelWT = changeRxnBounds(model,model.rxns(model.c==1),grRounded,'l');
modelWT = changeObjective(modelWT,targetRxn,1);
solMax = optimizeCbModel(modelWT);
solMin = optimizeCbModel(modelWT);

wtRes.growth = solWT.f;
wtRes.maxProd = solMax.f;
wtRes.minProd = solMin.f;

if (doubleDelFlag)
    growthRate = sparse(nDel,nDel);
    maxProd = sparse(nDel,nDel);
    minProd = sparse(nDel,nDel);
else
    growthRate = zeros(nDel,1);
    maxProd = zeros(nDel,1);
    minProd = zeros(nDel,1);
end


if (~doubleDelFlag)
    showprogress(0,'Simple OptKnock in progress ...');
end
t0 = cputime;
delCounter = 0;
for i = 1:nDel
    if (~doubleDelFlag)
        if mod(i,10) == 0
            showprogress(i/nDel);
        end
    end
    if (geneDelFlag)
        % Gene deletion
        modelKO = deleteModelGenes(model,deletions{i});
    else
        % Reaction deletion
        modelKO = changeRxnBounds(model,deletions{i},0,'b');
    end
    % Calculate optimal growth rate
    solKO = optimizeCbModel(modelKO);
    %fprintf('Single %s %f\n',deletions{i},solKO.f);
    growthRate(i,1) = solKO.f;
    if (solKO.f > minGrowth && solKO.stat == 1)
        % Max & min production of the metabolite at the optimal growth rate
        grRounded = floor(solKO.f/tol)*tol;
        modelKO = changeRxnBounds(modelKO,modelKO.rxns(modelKO.c==1),grRounded,'l');
        modelKO = changeObjective(modelKO,targetRxn,1);
        solMax = optimizeCbModel(modelKO,'max');
        solMin = optimizeCbModel(modelKO,'min');
        if (~doubleDelFlag)
            maxProd(i,1) = solMax.f;
            minProd(i,1) = solMin.f;
        %fprintf('%f %f\n',solMax.f,solMin.f);
        else
            maxProd(i,i) = solMax.f;
            minProd(i,i) = solMin.f;
            for j = i+1:nDel
                delCounter = delCounter+1;
                if mod(j,50) == 0
                    fComp = delCounter/(nDel*(nDel-1)/2);
                    fprintf('%d\t%f\t%f\n',delCounter,100*fComp,(cputime-t0)/60);
                end
                if (geneDelFlag)
                    % Gene deletion
                    modelKO2 = deleteModelGenes(model,deletions{i});
                    modelKO2 = deleteModelGenes(modelKO2,deletions{j});
                else
                    modelKO2 = changeRxnBounds(model,deletions{i},0,'b');
                    modelKO2 = changeRxnBounds(modelKO2,deletions{j},0,'b');
                end
                % Calculate optimal growth rate
                solKO2 = optimizeCbModel(modelKO2);
                growthRate(i,j) = solKO2.f;
                %fprintf('Double %s %s %f\n',deletions{i},deletions{j},solKO2.f);
                if (solKO2.f > minGrowth && solKO2.stat == 1)
                    grRounded2 = floor(solKO2.f/tol)*tol;
                    modelKO2 = changeRxnBounds(modelKO2,modelKO2.rxns(modelKO2.c==1),grRounded2,'l');
                    modelKO2 = changeObjective(modelKO2,targetRxn,1);
                    solMax2 = optimizeCbModel(modelKO2,'max');
                    solMin2 = optimizeCbModel(modelKO2,'min');
                    if (solMin2.f > 0)
                        fprintf('%s %s %f %f %f\n',deletions{i},deletions{j},solKO2.f,solMax2.f,solMin2.f);
                    end
                    maxProd(i,j) = solMax2.f;
                    minProd(i,j) = solMin2.f;
                end
            end
        end
    end
end

% Store results
delRes.maxProd = maxProd;
delRes.minProd = minProd;
delRes.growth = growthRate;
