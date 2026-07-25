function [metabolite_structure] = getMissingDrugMolForm(metabolite_structure, molFileDirectory, startSearch, endSearch)
% Retrieves mol files from DrugBank using DrugBank IDs
%
% It relies on getMolFileFromDrugbank.m and updates the metabolite structure to
% record which entries have an associated mol file.
%
% USAGE:
%
%    [metabolite_structure] = getMissingDrugMolForm(metabolite_structure, molFileDirectory, startSearch, endSearch)
%
% INPUTS:
%    metabolite_structure:    Metabolite structure
%    molFileDirectory:        Directory where the mol files should be stored
%
% OPTIONAL INPUTS:
%    startSearch:             Numeric index where the search starts in the
%                             metabolite structure (default: 1)
%    endSearch:               Numeric index where the search ends in the
%                             metabolite structure (default: all metabolites)
%
% OUTPUTS:
%    metabolite_structure:    Updated metabolite structure
%
% .. Author: - Ines Thiele 09/21

annotationSource = 'Drugbank';
annotationType = 'automatic';
F = fieldnames(metabolite_structure);
if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(F);
end

for i = startSearch : endSearch
    % check that drugbank id is defined
    if ~isempty(metabolite_structure.(F{i}).drugbank) && length(find(isnan(metabolite_structure.(F{i}).drugbank)))==0
        % get mol files for each entry
        if isempty(metabolite_structure.(F{i}).hasmolfile) || length(find(isnan(metabolite_structure.(F{i}).hasmolfile)))>0 ...
                || strcmp(metabolite_structure.(F{i}).hasmolfile,'0')
            [outFile] = getMolFileFromDrugbank(metabolite_structure.(F{i}).VMHId, metabolite_structure.(F{i}).drugbank,molFileDirectory);
            if ~isempty(outFile)
                metabolite_structure.(F{i}).hasmolfile = num2str(1);
                metabolite_structure.(F{i}).hasmolfile_source = [annotationSource,':',annotationType,':',datestr(now)];
            end
        end
        
    end
end
% calculate metabolite formula and charge 
[metabolite_structure] = addMetFormulaCharge(metabolite_structure,startSearch,endSearch);