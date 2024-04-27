function [geneList] = findGenesFromMets(model, metList, param)
% find the set of genes that correspond to a set of metabolites
%
% USAGE:
%
%    [geneList] = findGenesFromMets(model, metabolites)
%
% INPUTS:
%    model:      COBRA model structure
%    metList:    List of metabolite identifiers in a model to find the corresponding genes for
%
% OUTPUT:
%    geneList:     List of genes corresponding to reactions
%
% .. Author: - Ronan Fleming (11/9/23)

if ~exist('param','var')
    param.minimal=0;
end

[metInex,LOCB] = ismember(model.mets,metList);

missingMet = setdiff(metList,model.mets);
if ~isempty(missingMet)
    for i = 1:length(missingMet)
        fprintf('%s\n',['The metabolite ', missingMet{i},' is not in your model!']);
    end
end

%
metList = model.mets(metInex);

if param.minimal==1
    [rxnList, ~] = findRxnsFromMets(model, metList,'minimalReactionN',1);
else
    [rxnList, ~] = findRxnsFromMets(model, metList);
end

[rxnIndex,LOCB] = ismember(model.rxns,rxnList);

%Create the rxnGeneMat field if not present
if ~isfield(model,'rxnGeneMat')
    model = buildRxnGeneMat(model);
end

colBool=true(size(model.rxnGeneMat,2),1);
mode='inclusive';
geneBool = getCorrespondingCols(model.rxnGeneMat, rxnIndex, colBool, mode);

% N = model.S~=0;
% %zero out non-index metabolites and external reactions
% if isfield(model,'SConsistentRxnBool')
%     N(~index,~model.SConsistentRxnBool)=0;
% else
%     if isfield(model,'SIntRxnBool')
%         N(~index,~model.SIntRxnBool)=0;
%     end
% end
% %setup the problem for optimizeCardinality
% problem.p = true(size(N,2),1);
% problem.q = false(size(N,2),1);
% problem.r = false(size(N,2),1);
% problem.A = N;
% problem.b = ones(size(N,1),1);
% problem.b(~index)=0;
% problem.csense(1:size(N,1),1) = 'G';
% problem.lb = zeros(size(N,2),1);
% problem.ub = 10*ones(size(N,2),1);
% problem.c = zeros(size(N,2),1);
% %find the minimal number of reactions corresponding to those metabolites
% param.printLevel=1;
% solution = optimizeCardinality(problem, param);
% %reaction indices
% totals = solution.x ~=0;

geneList = model.genes(geneBool);


