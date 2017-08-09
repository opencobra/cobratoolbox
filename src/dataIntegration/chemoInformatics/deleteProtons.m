function modelNew = deleteProtons(model)
% Function to delete the protons in the metabolic network
%
% USAGE:
%
%    newModel = deleteProtons(model)
%
% INPUTS:
%    model:         COBRA model.
%
% OUTPUTS:
%    newModel:      COBRA model without protons nor protons trasport
%                   reactions.
%
% EXAMPLE:
%
%    newModel = deleteProtons(model)
%
% .. Author: - German A. Preciat Gonzalez 07/08/2017

modelNew = model;
S = full(modelNew.S);

if isfield(modelNew, 'rxnGeneMat')
    rxnGeneMat = full(modelNew.rxnGeneMat)';
end

% Identify all the protons in the metabolic network
hToDelete = ismember(modelNew.metFormulas, 'H');

% Delete in metabolites
S(hToDelete, :) = [];
fields = fieldnames(modelNew);
metabolites=length(modelNew.mets);
for i =1:length(fields)
    if length(modelNew.(fields{i})) == metabolites
        modelNew.(fields{i})(hToDelete) = [];
    end
end

% Delete in reactions
hydrogenCols = all(S == 0, 1);
S(:, hydrogenCols) = [];
if isfield(modelNew, 'rxnGeneMat')
    rxnGeneMat(:, hydrogenCols) = [];
end
reactions=length(modelNew.rxns);
for i =1:length(fields)
    if length(modelNew.(fields{i}))==reactions && isvector(modelNew.(fields{i}))
        modelNew.(fields{i})(hydrogenCols)=[];
    end
end

modelNew.S=sparse(S);
if isfield(modelNew, 'rxnGeneMat')
    modelNew.rxnGeneMat=sparse(rxnGeneMat');
end
