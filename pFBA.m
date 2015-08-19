function [GeneClasses RxnClasses modelIrrevFM] = pFBA(model, varargin)

% Parsimoneous enzyme usage Flux Balance Analysis - method that optimizes
% the user's objective function and then minimizes the flux through the
% model and subsequently classifies each gene by how it contributes to the
% optimal solution. See Lewis, et al. Mol Syst Bio doi:10.1038/msb.2010.47
%
% Inputs:
% model                 COBRA model
%
% varargin:
% 'geneoption'          1 = only minimize the sum of the flux through
%                       gene-associated fluxes (default), 0 = minimize the
%                       sum of all fluxes in the network
% 'tol'                 tolerance (default = 1e-6)
% 'map'                 map structure from readCbMap.m (no map written if empty
% 'mapoutname'          File Name for map 
% 'skipclass'           1 = Don't classify genes and reactions. Only return
%                       model with the minimium flux set as upper bound.
%                       0 = classify genes and reactions (default). 
%
% Output:
% GeneClasses           Structure with fields for each gene class
% RxnsClasses           Structure with fields for each reaction class
% modelIrrevFM          Irreversible model used for minimizing flux with
%                       the minimum flux set as a flux upper bound
%
% 
% 
% ** note on maps: Red (6) = Essential reactions, Orange (5) = pFBA optima
%       reaction, Yellow (4) = ELE reactions, Green (3) = MLE reactions,
%       blue (2) = zero flux reactions, purple (1) = blocked reactions,
%       black (0) = not classified
% 
% Example:
% [GeneClasses RxnClasses modelIrrevFM] = pFBA(model, 'geneoption',0, 'tol',1e-7)
%
% by Nathan Lewis Aug 25, 2010

%
if nargin < 2
    tol = 1e-6;
    GeneOption = 1;
    map = []; % no map
    mapOutName = 'pFBA_map.svg';
    skipclass = 0; 
end
if mod(length(varargin),2)==0
    for i=1:2:length(varargin)-1
        switch lower(varargin{i})
            case 'geneoption', GeneOption = varargin{i+1};
            case 'tol', tol = varargin{i+1};
            case 'map', map = varargin{i+1};
            case 'mapoutname', mapOutName = varargin{i+1};
            case 'skipclass', skipclass = varargin{i+1};
            otherwise, options.(varargin{i}) = varargin{i+1};
        end
    end
else
    error('Invalid number of parameters/values');
end
if ~exist('GeneOption','var'), GeneOption = 1;              end
if ~exist('tol','var'), tol = 1e-6;                         end
if ~exist('map','var'), map = [];                           end
if ~exist('mapOutName','var'), mapOutName = 'pFBA_map.svg'; end
if ~exist('skipclass','var'), skipclass = 0;                end
if skipclass % skip the model reduction and gene/rxn classification
    % minimize the network flux
FBAsoln = optimizeCbModel(model);
model.lb(model.c==1) = FBAsoln.f;
[ MinimizedFlux modelIrrevFM]= minimizeModelFlux_local(model,GeneOption);
modelIrrevFM = changeRxnBounds(modelIrrevFM,'netFlux',MinimizedFlux.f,'b');
GeneClasses = [];
RxnClasses = [];
else
% save a copy of the inputted model
model_sav = model;
% Remove all blocked reactions
[selExc,selUpt] = findExcRxns(model,0,0); % find and open up all exchanges
tempmodel = changeRxnBounds(model,model.rxns(selExc),-1000,'l');
tempmodel = changeRxnBounds(tempmodel,model.rxns(selExc),1000,'u');
[maxF minF] = fluxVariability(tempmodel,.001);
Blocked_Rxns = model.rxns(and(abs(maxF)<tol,abs(minF)<tol));
% tempmodel = reduceModel(tempmodel,tol); % reduce the model to find blocked reactions
% Blocked_Rxns_old = setdiff(model.rxns,regexprep(tempmodel.rxns,'_r$',''));
% model_old = removeRxns(model,setdiff(model.rxns,regexprep(tempmodel.rxns,'_r$',''))); % remove blocked reactions
% Ind2Remove_old  = find(~and(sum(full(model.rxnGeneMat),1),1));
% Blocked_genes_old  = model.genes(Ind2Remove_old );
% % Ind2Remove = find(~and(sum(full(model_sav.rxnGeneMat),1),1));
% % Blocked_genes = model_sav.genes(Ind2Remove);
model = removeRxns(model,Blocked_Rxns); % remove blocked reactions
Ind2Remove = find(~and(sum(full(model.rxnGeneMat),1),1));
Blocked_genes = model.genes(Ind2Remove);
model.genes(Ind2Remove)={'dead_end'}; % make sure genes that are unique to blocked reactions are tagged for removal
% find essential genes
grRatio = singleGeneDeletion(model);
grRatio(isnan(grRatio))=0;
pFBAEssential = model.genes(grRatio<tol);
if nargout > 1
    % find essential reactions
RxnRatio = singleRxnDeletion(model);
RxnRatio(isnan(RxnRatio))=0;
pFBAEssentialRxns = model.rxns(RxnRatio<tol);
end
   
% remove zero flux rxns
[maxF,minF] = fluxVariability(model,.001);
% tempmodel = reduceModel(model,tol);
% ZeroFluxRxns = setdiff(model.rxns,regexprep(tempmodel.rxns,'_r$',''));
ZeroFluxRxns = model.rxns(and(abs(maxF)<tol,abs(minF)<tol));
model = removeRxns(model,ZeroFluxRxns);
% find MLE reactions
FBAsoln = optimizeCbModel(model);
model.lb(model.c==1) = FBAsoln.f;
[minFlux,maxFlux] = fluxVariability(model,100);
for i = 1:length(minFlux)
    tmp(i,1) = max([abs(minFlux(i)) abs(maxFlux(i))])<tol;
end
MLE_Rxns = setdiff(model.rxns(tmp),ZeroFluxRxns);
% minimize the network flux
[ MinimizedFlux,modelIrrevFM]= minimizeModelFlux_local(model,GeneOption);
% separate pFBA optima rxns from ELE rxns
modelIrrevFM = changeRxnBounds(modelIrrevFM,'netFlux',MinimizedFlux.f,'b');
[minFlux,maxFlux] = fluxVariability(modelIrrevFM,100); 
pFBAopt_Rxns = modelIrrevFM.rxns((abs(minFlux)+abs(maxFlux))>=tol);
ELE_Rxns = modelIrrevFM.rxns((abs(minFlux)+abs(maxFlux))<=tol);
pFBAopt_Rxns = unique(regexprep(pFBAopt_Rxns,'_[f|b]$',''));
pFBAopt_Rxns(ismember(pFBAopt_Rxns,MLE_Rxns))=[]; %%% removes non-gene associated reversible reactions that are only in the list because there is no constraint on them looping with the reverse reaction
ELE_Rxns = unique(regexprep(ELE_Rxns,'_[f|b]$',''));
ELE_Rxns = ELE_Rxns(~ismember(ELE_Rxns,pFBAopt_Rxns));
ELE_Rxns = ELE_Rxns(~ismember(ELE_Rxns,MLE_Rxns));
% determine pFBA optima genes
pFBAopt_Rxns(ismember(pFBAopt_Rxns,'netFlux'))=[];
[geneList]=findGenesFromRxns(model,pFBAopt_Rxns);
geneList2 = {};
for i = 1:length(geneList),
    geneList2(end+1:end+length(geneList{i}),1) = columnVector( geneList{i});
end
pFBAOptima = unique(geneList2);
% determine Zero Flux genes
Ind2Remove = find(~and(sum(full(model.rxnGeneMat),1),1));
ZeroFluxGenes = unique(model.genes(Ind2Remove));
% determine ELE genes
[geneList]=findGenesFromRxns(model,ELE_Rxns);
geneList2 = {};
for i = 1:length(geneList)
    geneList2(end+1:end+length(geneList{i}),1) = columnVector( geneList{i});
end
ELEGenes = unique(geneList2);
ELEGenes = setdiff(ELEGenes,[pFBAOptima;ZeroFluxGenes]);
% determine Met ineff genes
MLEGenes = setdiff(model.genes, [pFBAOptima;ZeroFluxGenes;ELEGenes]);
% clean up lists by removing non-genes
pFBAOptima(~cellfun('isempty',regexp(pFBAOptima,'dead_end')))=[];
ELEGenes(~cellfun('isempty',regexp(ELEGenes ,'dead_end')))=[];
MLEGenes(~cellfun('isempty',regexp(MLEGenes,'dead_end')))=[];
ZeroFluxGenes(~cellfun('isempty',regexp(ZeroFluxGenes,'dead_end')))=[];
pFBAOptima(cellfun('isempty',pFBAOptima))=[];
ELEGenes(cellfun('isempty',ELEGenes ))=[];
MLEGenes(cellfun('isempty',MLEGenes))=[];
ZeroFluxGenes(cellfun('isempty',ZeroFluxGenes))=[];
% filter out essential genes from pFBA optima
pFBAOptima(ismember(pFBAOptima,pFBAEssential))=[];
if nargout > 1
% filter out essential Rxns from pFBA optima
pFBAopt_Rxns(ismember(pFBAopt_Rxns,pFBAEssentialRxns))=[];
end
% prepare output variables
GeneClasses.pFBAEssential =pFBAEssential;
GeneClasses.pFBAoptima = pFBAOptima;
GeneClasses.ELEGenes = ELEGenes;
GeneClasses.MLEGenes = MLEGenes;
GeneClasses.ZeroFluxGenes = ZeroFluxGenes;
GeneClasses.Blockedgenes = Blocked_genes;
RxnClasses.Essential_Rxns = pFBAEssentialRxns;
RxnClasses.pFBAOpt_Rxns = pFBAopt_Rxns;
RxnClasses.ELE_Rxns = ELE_Rxns;
RxnClasses.MLE_Rxns = MLE_Rxns;
RxnClasses.ZeroFlux_Rxns = ZeroFluxRxns;
RxnClasses.Blocked_Rxns = Blocked_Rxns;
if ~isempty(map)
    MapVector = zeros(length(model_sav.rxns),1);
    MapVector(ismember(model_sav.rxns,Blocked_Rxns))= 1;
    MapVector(ismember(model_sav.rxns,ZeroFluxRxns))= 2;
    MapVector(ismember(model_sav.rxns,MLE_Rxns))= 3;
    MapVector(ismember(model_sav.rxns,ELE_Rxns))= 4;
    MapVector(ismember(model_sav.rxns,pFBAopt_Rxns))= 5;
    MapVector(ismember(model_sav.rxns,pFBAEssentialRxns))= 6;
    
    options.lb = 0;
    options.ub = 6;
    tmpCmap = hsv(18);
    tmpCmap = [tmpCmap([1,3,4,6,11,14],:); 0 0 0;];
    options.fileName = mapOutName;
    options.colorScale = flipud(round(tmpCmap*255));
    
    global CB_MAP_OUTPUT
    if ~exist('CB_MAP_OUTPUT', 'var') || isempty(CB_MAP_OUTPUT)
        changeCbMapOutput('svg');
    end
    drawFlux(map, model_sav, MapVector, options);
end
end
end
function [ MinimizedFlux modelIrrev]= minimizeModelFlux_local(model,GeneOption)
% This function finds the minimum flux through the network and returns the
% minimized flux and an irreversible model
% convert model to irrev
modelIrrev = convertToIrreversible(model);
% add pseudo-metabolite to measure flux through network
if nargin==1,GeneOption=0;
end
if GeneOption==0, % signal that you want to minimize the sum of all gene and non-gene associated fluxes
    modelIrrev.S(end+1,:) = ones(size(modelIrrev.S(1,:)));
elseif GeneOption==1, % signal that you want to minimize the sum of only gene-associated fluxes
    %find all reactions which are gene associated
    Ind=find(sum(modelIrrev.rxnGeneMat,2)>0);
    modelIrrev.S(end+1,:) = zeros(size(modelIrrev.S(1,:)));
    modelIrrev.S(end,Ind) = 1;
end
modelIrrev.b(end+1) = 0;
modelIrrev.mets{end+1} = 'fluxMeasure';
% add a pseudo reaction that measures the flux through the network
modelIrrev = addReaction(modelIrrev,'netFlux',{'fluxMeasure'},[-1],false,0,inf,0,'','');
% set the flux measuring demand as the objective
modelIrrev.c = zeros(length(modelIrrev.rxns),1);
modelIrrev = changeObjective(modelIrrev, 'netFlux');
% minimize the flux measuring demand (netFlux)
MinimizedFlux = optimizeCbModel(modelIrrev,'min');
end