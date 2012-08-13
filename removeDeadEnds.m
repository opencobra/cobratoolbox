function [model,removedMets,removedRxns] = removeDeadEnds(model)
%removeDeadEnds Remove all dead end metabolites and reactions from the
%model
%
% [model,removedMets,removedRxns] = removeDeadEnds(model)
%
%INPUT
% model         COBRA model structure
%
%OUTPUTS
% model         COBRA model structure w/o dead end metabolites and
%               reactions
% removedMets   List of removed metabolites
% removedRxns   List of removed reactions
%
% Markus Herrgard 8/29/06

removedMets = {};
removedRxns = {};

while (1)
    
    deadEnd = detectDeadEnds(model);
    
    if (length(deadEnd) == 0)
        break;
    end
    
    removedMets = union(removedMets,model.mets(deadEnd));
    if (length(deadEnd) > 1)
        deadRxns = model.rxns(find(sum(model.S(deadEnd,:) ~= 0) > 0));
    else
        deadRxns = model.rxns(find(model.S(deadEnd,:) ~= 0));
    end
    
    model = removeRxns(model,deadRxns);
    
    
    removedRxns = union(removedRxns,deadRxns);
    
end