function abcModel = alphabetizeModel(model)
% Sorts the rxns, metabolites, and genes in a model into alphabetical
% order, useful after adding new reactions to a model. This function needs
% to be modified to work on models with different fields than these
% (currently set for `iAF1260c`)
%
% USAGE:
%
%    abcModel = alphabetizeModel(model)
%
% INPUT:
%     model:      COBRA model structure with fields:
%
%                  * .rxns - `n x 1` reaction identifiers, sorted and used
%                    to reorder all reaction-associated fields
%                  * .mets - `m x 1` metabolite identifiers, sorted and
%                    used to reorder all metabolite-associated fields
%                  * .genes - `g x 1` gene identifiers (if present), sorted
%                    and used to reorder all gene-associated fields
%                  * .comps - `c x 1` compartment symbols (if present),
%                    sorted and used to reorder all compartment-associated
%                    fields
%
% OUTPUT:
%    abcModel:    the alphabetized model
%
% .. Authors:
%       - Jeff Orth  11/21/07
%       - Modified to work on basic COBRA model. Richard Que (2/1/10)

[~,iRxns] = sort(model.rxns);
[~,iMets] = sort(model.mets);
model = updateFieldOrderForType(model,'rxns',iRxns);
model = updateFieldOrderForType(model,'mets',iMets);

if isfield(model,'genes')
    [~,iGenes] = sort(model.genes);
    model = updateFieldOrderForType(model,'genes',iGenes);
end
if isfield(model,'comps')
    [~,iComps] = sort(model.comps);
    model = updateFieldOrderForType(model,'comps',iComps);
end
abcModel = model;