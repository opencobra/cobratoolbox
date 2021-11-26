function [metabolite_structure] = getMissingDrugMolForm(metabolite_structure,molFileDirectory,startSearch,endSearch)
% This function trys to retrieve mol files from drug bank using drugbank
% id's. It relies on getMolFileFromDrugbank.m.
%
% INPUT
% metabolite_structure  metabolite structure
% molFileDirectory      directory where mol files should be stored
% startSearch           specify where the search should start in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
% endSearch             specify where the search should end in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
%
% OUTPUT
% metabolite_structure  updated metabolite structure
%
% Ines Thiele 09/21

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