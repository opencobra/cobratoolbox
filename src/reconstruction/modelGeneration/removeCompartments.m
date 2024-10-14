function [modelDecomp] = removeCompartments(model,comp,newComp)
% function [modelDecomp] = RemoveCompartments(model,comp,NewComp)
%
% Function removes list of compartments in metabolite names. It removes
% duplicates and empty entries.
%
% model         Model structure
% comp          List of compartments to remove or replace (e.g., {'c','n'}
% newComp       New compartment (optional, default: '[c]')
%
% modelDecomp   Decompartementalized model structure
% IT Nov 2009
% SM Feb 2014 - line 31, updated function name "AddReaction" to "addReaction"
% IT April 2024 - updated script

warning('OFF')
if ~exist('newComp','var')
    newComp = '[c]'
end

if ~isfield(model,'rev')
    model.rev = zeros(length(model.rxns),1);
    model.rev(find(model.lb<0))=1;
end
%
modelDecomp.genes = model.genes;
%modelDecomp.genesNumeric = model.genesNumeric;
modelDecomp.rxns = '';
modelDecomp.mets = '';
modelDecomp.metNames = '';
modelDecomp.S = [];
modelDecomp.subSystems = '';
modelDecomp.rev = [];
modelDecomp.lb = [];
modelDecomp.ub = [];
for i = 1 : length(model.rxns)
    i
    Met = find(model.S(:,i));
    MetS = model.S(Met,i);
    Mets = model.mets(Met);
    for j  =  1: length(comp)
        Mets = regexprep(Mets,strcat('\(',comp{j},'\)$'),newComp);
        Mets = regexprep(Mets,strcat('\[',comp{j},'\]$'),newComp);
    end
    modelDecomp = addReaction(modelDecomp,model.rxns{i},Mets,MetS,model.rev(i),model.lb(i),model.ub(i),model.c(i),model.subSystems{i},model.grRules{i});%SM changed "AddReaction" to "addReaction"
end

modelDecomp.b = zeros(length(modelDecomp.mets),1);
modelDecomp.mets = modelDecomp.mets';
modelDecomp.metNames =    modelDecomp.metNames';
modelDecomp.rxns = modelDecomp.rxns';
modelDecomp.lb = modelDecomp.lb';
modelDecomp.ub = modelDecomp.ub';
modelDecomp.rev = modelDecomp.rev';
modelDecomp.c = modelDecomp.c';
modelDecomp.grRules = modelDecomp.grRules';
modelDecomp.rules = modelDecomp.rules';

% find
% need to find duplicate reactions
removeRxn =[];
cntR = 1;
for i = 1 : length(modelDecomp.rxns)
    tmp = length(find(modelDecomp.S(:,i)));
    if tmp == 0
        removeRxn(cntR) = i;
        cntR = cntR +1;
    end
end
if ~isempty(removeRxn)
    modelDecomp.S(:,removeRxn) =[];
    if isfield(modelDecomp,'rxnGeneMat')
        modelDecomp.rxnGeneMat(removeRxn,:) =[];
    end
    modelDecomp.c(removeRxn) =[];
    modelDecomp.lb(removeRxn) =[];
    modelDecomp.ub(removeRxn) =[];
    modelDecomp.rxns(removeRxn) =[];
    if isfield(modelDecomp,'rules')
        modelDecomp.rules(removeRxn) =[];
    end
    if isfield(modelDecomp,'grRules')
        modelDecomp.grRules(removeRxn) =[];
    end
    modelDecomp.subSystems(removeRxn) =[];
    
    modelDecomp=rmfield(modelDecomp,'rev');
end

modelDecomp.mets=columnVector(modelDecomp.mets);
modelDecomp.rxns=columnVector(modelDecomp.rxns);
modelDecomp.lb=columnVector(modelDecomp.lb);
modelDecomp.ub=columnVector(modelDecomp.ub);
modelDecomp.c=columnVector(modelDecomp.c);
if isfield(modelDecomp,'grRules')
    modelDecomp.grRules=columnVector(modelDecomp.grRules);
end

if isfield(modelDecomp,'rules')
    modelDecomp.rules=columnVector(modelDecomp.rules);
end