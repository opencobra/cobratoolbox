function [tissueModel,coreRxnBool] = fastcore(model, core, epsilon, printlevel)
% Use the FASTCORE algorithm ('Vlassis et al, 2014') to extract a context
% specific model. FASTCORE algorithm defines one set of core
% reactions that is guaranteed to be active in the extracted model and find
% the minimum of reactions possible to support the core.
%
% USAGE:
%
%    tissueModel = fastcore(model, core)
%
% INPUTS:
%
%   model:               input model (COBRA model structure)
%   core:                indices of reactions in cobra model that are part of the
%                        core set of reactions (called 'C' in 'Vlassis et al,
%                        2014')
%
% OPTIONAL INPUTS:
%   epsilon:             smallest flux value that is considered nonzero
%                        (default 1e-4)
%   printLevel:          0 = silent, 1 = summary, 2 = debug (default - 0)
%
% OUTPUT:
%
%   tissueModel:         extracted model
%
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
    printlevel = 0;
end
if nargin < 3 || isempty(epsilon)
    epsilon=1e-4;
end

coreSetRxn = core;
model_orig = model;

if 1
    %reactions irreversible in the reverse direction
    Ir = find(model.ub<=0);
    %flip direction of reactions irreversible in the reverse direction
    model.S(:,Ir) = -model.S(:,Ir);
    tmp = model.ub(Ir);
    model.ub(Ir) = -model.lb(Ir);
    model.lb(Ir) = -tmp;
end

%Find irreversible reactions
irrevRxns = find(model.lb>=0);
    
A = [];
flipped = false;
singleton = false;

% Find irreversible core reactions
J = intersect(coreSetRxn, irrevRxns);

if printlevel > 0
    fprintf('|J|=%d  ', length(J));
end

%Find all the reactions that are not in the core
nbRxns = 1:numel(model.rxns);
P = setdiff(nbRxns, coreSetRxn);

% Find the minimum of reactions from P that need to be included to
% support the irreversible core set of reactions
[Supp, basis] = findSparseMode(J, P, singleton, model, epsilon);

if ~isempty(setdiff(J, Supp))
    error ('fastcore.m Error: Inconsistent irreversible core reactions.\n');
end

A = Supp;
if printlevel > 0
    fprintf('|A|=%d\n', length(A));
end

% J is the set of irreversible reactions
J = setdiff(coreSetRxn, A);
if printlevel > 0
    fprintf('|J|=%d  ', length(J));
end

% Main loop that reduce at each iteration the number of reactions from P that need to be included to
% support the complete core set of reactions
while ~isempty(J)
    
    P = setdiff(P, A);
    
    %reuse the basis from the previous solve if it exists
    [Supp, basis] = findSparseMode(J, P, singleton, model, epsilon, basis);
    
    A = union(A, Supp);
    if printlevel > 0
        fprintf('|A|=%d\n', length(A));
    end
    
    if ~isempty( intersect(J, A))
        J = setdiff(J, A);
        if printlevel > 0
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
                error('\n fastcore.m Error: Global network is not consistent.\n');
            else
                flipped = false;
                singleton = true;
            end
        else
            model.S(:,JiRev) = -model.S(:,JiRev);
            tmp = model.ub(JiRev);
            model.ub(JiRev) = -model.lb(JiRev);
            model.lb(JiRev) = -tmp;
            flipped = true;
            
            if printlevel > 0
                fprintf('(flip)  ');
            end
        end
    end
end
if printlevel > 0
    fprintf('|A|=%d\n', length(A)); % A : indices of reactions in the new model
end

if printlevel > 1
    toc
end

coreRxnBool=false(size(model.S,2),1);
coreRxnBool(A)=1;

toRemove = setdiff(model.rxns,model.rxns(A));
tissueModel = removeRxns(model_orig, toRemove);
tissueModel = removeUnusedGenes(tissueModel);
