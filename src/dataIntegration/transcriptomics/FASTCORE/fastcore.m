function [tissueModel,coreRxnBool,coreMetBool,coreCtrsBool] = fastcore(model, coreRxnInd, epsilon, printLevel)
% Use the FASTCORE algorithm ('Vlassis et al, 2014') to extract a context
% specific model. FASTCORE algorithm defines one set of core
% reactions that is guaranteed to be active in the extracted model and find
% the minimum of reactions possible to support the core.
%
% USAGE:
%
%    tissueModel = fastcore(model, coreRxnInd)
%
% INPUTS:
%    model:             (the following fields are required - others can be supplied)
%                         * S  - `m x 1` Stoichiometric matrix
%                         * lb - `n x 1` Lower bounds
%                         * ub - `n x 1` Upper bounds
%                         * rxns   - `n x 1` cell array of reaction abbreviations
%
%   coreRxnInd:          indices of reactions in cobra model that are part of the
%                        core set of reactions (called 'C' in 'Vlassis et al,
%                        2014')
%
% OPTIONAL INPUTS:
%   epsilon:             smallest flux value that is considered nonzero
%                        (default getCobraSolverParams('LP', 'feasTol')*100)
%   printLevel:          0 = silent, 1 = summary, 2 = debug (default - 0)
%
% OUTPUT:
%
%   tissueModel:         extracted model
%
%   coreRxnBool:         n x 1 boolean vector indicating core reactions
% 
% 'Vlassis, Pacheco, Sauter (2014). Fast reconstruction of compact
% context-specific metbolic network models. PLoS Comput. Biol. 10,
% e1003424.'
%
% .. Authors:
%       - Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013 LCSB / LSRU, University of Luxembourg
%       - Ronan Fleming, commenting of code and inputs/outputs
%       - Anne Richelle, code adaptation to fit with createTissueSpecificModel

if nargin < 4 || ~exist('printLevel','var')
    printLevel = 0;
end
if nargin < 3 || isempty(epsilon)
    epsilon=getCobraSolverParams('LP', 'feasTol')*100;
end

if printLevel > 1
    tic
end

model_orig = model;

[nMets,nRxns] = size(model.S);

LPproblem = buildOptProblemFromModel(model);

%reactions irreversible in the reverse direction
Ir = model.lb < 0 & model.ub<=0;

%flip direction of reactions irreversible in the reverse direction
LPproblem.A(:,Ir) = -LPproblem.A(:,Ir);
tmp = LPproblem.ub(Ir);
LPproblem.ub(Ir) = -LPproblem.lb(Ir);
LPproblem.lb(Ir) = -tmp;

%Find irreversible reactions
irrevRxns = find(model.lb>=0);
    
A = [];
flipped = false;
singleton = false;

% Find irreversible core reactions
J = intersect(coreRxnInd, irrevRxns);

if printLevel > 0
    fprintf('|J|=%d  ', length(J));
end

%Find all the reactions that are not in the core
nbRxns = 1:nRxns;
% Non Core reactions (penalized)
P = setdiff(nbRxns, coreRxnInd);

% Find the minimum of set reactions from P that need to be included to
% support the irreversible core set of reactions
[Supp, basis] = findSparseMode(J, P, singleton, model, LPproblem, epsilon);

if ~isempty(setdiff(J, Supp))
    warning('fastcore.m Error: Global network is not flux consistent, ignoring the following irreversible core reactions:\n');
    model.rxns(setdiff(J, Supp))
    coreRxnInd = setdiff(coreRxnInd,setdiff(J, Supp));
    %error ('fastcore.m Error: Inconsistent irreversible core reactions.\n');
end

A = Supp;
if printLevel > 0
    fprintf('|A|=%d\n', length(A));
end

% J is the set of core reactions not already in the extracted model
J = setdiff(coreRxnInd, A);
if printLevel > 0
    fprintf('|J|=%d  ', length(J));
end

% Main loop that reduce at each iteration the number of reactions from P that need to be included to
% support the complete core set of reactions
while ~isempty(J)
    
    P = setdiff(P, A);
    
    %reuse the basis from the previous solve if it exists
    [Supp, basis] = findSparseMode(J, P, singleton, model, LPproblem, epsilon, basis);
    
    A = union(A, Supp);
    if printLevel > 0
        fprintf('|A|=%d\n', length(A));
    end
    
    if ~isempty( intersect(J, A))
        J = setdiff(J, A);
        if printLevel > 0
            fprintf('|J|=%d  ', length(J));
        end
        flipped = false;
    else
        if singleton
            JiRev = setdiff(J(1),irrevRxns);
        else
            JiRev = setdiff(J,irrevRxns);
        end
        if flipped || isempty(JiRev)
            if singleton
                warning('\n fastcore.m: Global network is not flux consistent, ignoring corresponding core reaction:\n');
                disp(model.rxns(J))
                J = [];
                %error('\n fastcore.m Error: Global network is not consistent.\n');
            else
                flipped = false;
                singleton = true;
            end
        else
            LPproblem.A(:,JiRev) = -LPproblem.A(:,JiRev);
            tmp = LPproblem.ub(JiRev);
            LPproblem.ub(JiRev) = -LPproblem.lb(JiRev);
            LPproblem.lb(JiRev) = -tmp;
            flipped = true;
            
            if printLevel > 0
                fprintf('(flip)  ');
            end
        end
    end
end
if printLevel > 0
    fprintf('|A|=%d\n', length(A)); % A : indices of reactions in the new model
end

if printLevel > 1
    toc
end

coreRxnBool=false(size(model.S,2),1);
coreRxnBool(A)=1;

rxnRemoveList = setdiff(model.rxns,model.rxns(A));

dummyMetBool = contains(model.mets,'dummy_Met_');
dummyRxnBool = contains(model.rxns,'dummy_Rxn_');
dummyRxnList = model.rxns(dummyRxnBool);
if any(dummyMetBool) || any(dummyRxnBool)
    model = destroyDummyModel(model,dummyMetBool,dummyRxnBool);
    rxnRemoveList = setdiff(rxnRemoveList,dummyRxnList);
end
        
%removes any infeasible coupling constraints also
[tissueModel, metRemoveList, ctrsRemoveList] = removeRxns(model, rxnRemoveList,'metRemoveMethod','exclusive','ctrsRemoveMethod','infeasible');

coreMetBool=~ismember(model_orig.mets,metRemoveList);
if isfield(model,'ctrs')
    coreCtrsBool = ~ismember(model_orig.ctrs,ctrsRemoveList);
else
    coreCtrsBool = ctrsRemoveList;
end

%coreGeneBool
tissueModel = removeUnusedGenes(tissueModel);