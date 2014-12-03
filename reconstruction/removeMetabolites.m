function model = removeMetabolites(model,metaboliteList,removeRxnFlag)
%removeMetabolites Remove metabolites from a model
%
% model = removeMetabolites(model,metaboliteList,removeRxnFlag)
%
%INPUTS
% model             COBRA model structure
% metaboliteList    List of metabolites to be removed
%
%OPTIONAL INPUT
% removeRxnFlag     Remove reactions with no metabolites (Default = true)
%
%OUTPUT
% model             COBRA model with removed metabolites
%
% Markus Herrgard 6/5/07

if (nargin < 3)
    removeRxnFlag = true;
end

selMets = ~ismember(model.mets,metaboliteList);

model.S = model.S(selMets,:);
model.mets = model.mets(selMets);
if (isfield(model,'b'))
    model.b = model.b(selMets);
else
    model.b = zeros(length(model.mets),1);
end
if (isfield(model,'metNames'))
    model.metNames = model.metNames(selMets);
end
if (isfield(model,'metFormulas'))
    model.metFormulas = model.metFormulas(selMets);
end
if (isfield(model,'metCharge'))
    model.metCharge = model.metCharge(selMets);
end
if (isfield(model,'metChEBIID'))
    model.metChEBIID = model.metChEBIID(selMets);
end
if (isfield(model,'metKEGGID'))
    model.metKEGGID = model.metKEGGID(selMets);
end
if (isfield(model,'metPubChemID'))
    model.metPubChemID = model.metPubChemID(selMets);
end
if (isfield(model,'metInChIString'))
    model.metInChIString = model.metInChIString(selMets);
end

if removeRxnFlag
    %if S is empty..
    if(isempty(model.S))
        return
    end
    rxnRemoveList = model.rxns(~any(model.S ~= 0));
    if (~isempty(rxnRemoveList))
        model = removeRxns(model,rxnRemoveList,false,false);
    end
end