function [metabolite_structure] = addMetFormulaCharge(metabolite_structure,startSearch,endSearch)
% This function uses getInchiString2ChargedFormula.m to calculate charge
% and neutral formula.
%
% INPUT
% metabolite_structure  metabolite structure
% startSearch           specify where the search should start in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
% endSearch             specify where the search should end in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
% OUTPUT
% metabolite_structure  updated metabolite structure
%
% Ines Thiele 09/21
annotationSource = 'Calculated using metaboAnnotator and inchiString';
annotationType = 'automatic';

F = fieldnames(metabolite_structure);
if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(F);
end

for i = startSearch : endSearch
    if (isempty(metabolite_structure.(F{i}).chargedFormula) || ~isempty(find(isnan(metabolite_structure.(F{i}).chargedFormula)))) && ...
            ~isempty(metabolite_structure.(F{i}).inchiString) && isempty(find(isnan(metabolite_structure.(F{i}).inchiString)))
        % compute charged formula for each entry from inchiString
        inchiString = metabolite_structure.(F{i}).inchiString;
        [metFormulaNeutral,metFormulaCharged,metCharge] = getInchiString2ChargedFormula({metabolite_structure.(F{i}).VMHId},cellstr(inchiString));
        if ~isempty(metFormulaCharged)
            metabolite_structure.(F{i}).chargedFormula = metFormulaCharged;
            metabolite_structure.(F{i}).chargedFormula_source = [annotationSource,':',annotationType,':',datestr(now)];
            metabolite_structure.(F{i}).charge = metCharge;
            metabolite_structure.(F{i}).charge_source = [annotationSource,':',annotationType,':',datestr(now)];
        end
        metabolite_structure.(F{i}).neutralFormula = metFormulaNeutral;
        metabolite_structure.(F{i}).neutralFormula_source = [annotationSource,':',annotationType,':',datestr(now)];
    end
end