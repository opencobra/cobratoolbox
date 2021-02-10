function [incorrectRxns,incorrectMets] = validateCompartments(model)
% This function checks if there are any reactions with incorrect
% compartments in the refined reconstructions. Appropriate compartments
% include [c], [e], and [p].
%
% USAGE:
%
%    [incorrectRxns,incorrectMets] = validateCompartments(model)
%
% INPUTS
% model             COBRA model structure
%
% OUTPUTS
%
% incorrectRxns     Reactions including metabolites in inappropriate compartments
% incorrectMets     Metabolites located in inappropriate compartments
%
% AUTHOR:
%   Almut Heinken, 10/2020

findIncorrectMets = find(~contains(model.mets,{'[c]','[e]','[p]'}));
if ~isempty(findIncorrectMets)
    incorrectMets = model.mets(findIncorrectMets);
    incorrectRxns = {};
    
    for i=1:length(incorrectMets)
        [Rxns]=findRxnsFromMets(model,incorrectMets{i});
        incorrectRxns=union(incorrectRxns,Rxns);
    end
    
else
    incorrectMets = {};
    incorrectRxns = {};
end

end