function [metabolite_structure] = addMetFormulaCharge(metabolite_structure, startSearch, endSearch)
% Calculates charged formula and neutral formula from the inchiString
%
% Uses `getInchiString2ChargedFormula` to calculate the charge and the
% neutral formula for each metabolite in the metabolite structure.
%
% USAGE:
%
%    [metabolite_structure] = addMetFormulaCharge(metabolite_structure, startSearch, endSearch)
%
% INPUTS:
%    metabolite_structure:    metabolite structure
%
% OPTIONAL INPUTS:
%    startSearch:             numeric index where the search should start in
%                             the metabolite structure (default: 1, all
%                             metabolites in the structure are searched)
%    endSearch:               numeric index where the search should end in the
%                             metabolite structure (default: number of
%                             metabolites in the structure)
%
% OUTPUTS:
%    metabolite_structure:    updated metabolite structure
%
% .. Author: - Ines Thiele, 09/21

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