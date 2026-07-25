function uniqueMets = uniqueMetabolites(model)
% Identifies unique metabolites by ignoring compartment tags
%
% USAGE:
%
%    uniqueMets = uniqueMetabolites(model)
%
% INPUT:
%    model:         COBRA model structure with fields:
%
%                     * .mets - `m x 1` cell array of metabolite identifiers
%                       (e.g. `metabolite[c]`)
%
% OUTPUT:
%    uniqueMets:    Cell array of unique metabolite names, excluding compartment tags
%
% .. Authors:
%    Cyrille Thinnes, University of Galway, 25/10/2024

mets = model.mets;

% Remove compartment tags, e.g., 'metabolite[c]' -> 'metabolite'
metsNoCompartment = regexprep(mets, '\[.*?\]', '');

% Identify unique metabolites
uniqueMets = unique(metsNoCompartment);
end
