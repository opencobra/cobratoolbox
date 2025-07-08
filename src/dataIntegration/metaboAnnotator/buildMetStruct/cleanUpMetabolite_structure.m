function  [metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure,startSearch,endSearch)
% This function aims at removing the most commonly occuring issues with the
% data obtained from different resources.
%
% INPUT
% metabolite_structure  Metabolite structure
%
% OUTPUT
% metabolite_structure  Updated metabolite structure
%
% IT Oct 2020

Mets = fieldnames(metabolite_structure);

if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(Mets);
end


for i = startSearch : endSearch
    i
    
    % remove spaces in keggIds
    if isempty(find(isnan(metabolite_structure.(Mets{i}).keggId))) && ~isnumeric(metabolite_structure.(Mets{i}).keggId)
        metabolite_structure.(Mets{i}).keggId = regexprep(metabolite_structure.(Mets{i}).keggId,'\s','');
    end
    if isempty(find(isnan(metabolite_structure.(Mets{i}).cheBIId)))  && ~isnumeric(metabolite_structure.(Mets{i}).cheBIId)
        if ~isempty(regexp(metabolite_structure.(Mets{i}).cheBIId,'CHEBI'))
            % make sure that cheBIId's has no CHEBI: in fron
            metabolite_structure.(Mets{i}).cheBIId = regexprep(metabolite_structure.(Mets{i}).cheBIId,'CHEBI','');
            metabolite_structure.(Mets{i}).cheBIId = regexprep(metabolite_structure.(Mets{i}).cheBIId,':','');
        end
        % make sure that cheBIId's are numeric - I don't do it, so that we
        % can have multiple entries
        % metabolite_structure.(Mets{i}).cheBIId = str2double(metabolite_structure.(Mets{i}).cheBIId);
    end
    % remove spaces from drugbank ID's
    if isfield(metabolite_structure.(Mets{i}),'drugbank') && isempty(find(isnan(metabolite_structure.(Mets{i}).drugbank)))
        metabolite_structure.(Mets{i}).drugbank = regexprep(metabolite_structure.(Mets{i}).drugbank,'\s','');
    end
    % fix misspelling of InChI
    if isempty(find(isnan(metabolite_structure.(Mets{i}).inchiString))) && ~isempty(regexp(metabolite_structure.(Mets{i}).inchiString,'^InChi='))
        metabolite_structure.(Mets{i}).inchiString = regexprep(metabolite_structure.(Mets{i}).inchiString,'InChi','InChI');
    end
    if isempty(find(isnan(metabolite_structure.(Mets{i}).pubChemId)))  && ~isnumeric(metabolite_structure.(Mets{i}).pubChemId)
        % make sure that pubChemId's are numeric
        metabolite_structure.(Mets{i}).pubChemId = str2double(metabolite_structure.(Mets{i}).pubChemId);
    end
    if isempty(find(isnan(metabolite_structure.(Mets{i}).charge)))  && ~isnumeric(metabolite_structure.(Mets{i}).charge)
        % make sure that charges are numeric
        metabolite_structure.(Mets{i}).charge = str2double(metabolite_structure.(Mets{i}).charge);
    end
    if isfield(metabolite_structure.(Mets{i}),'avgmolweight')&& ~isempty((metabolite_structure.(Mets{i}).avgmolweight)) && isempty(find(isnan(metabolite_structure.(Mets{i}).avgmolweight)))  && ~isnumeric(metabolite_structure.(Mets{i}).avgmolweight)
        % make sure that avgmolweight are numeric
        metabolite_structure.(Mets{i}).avgmolweight = str2double(metabolite_structure.(Mets{i}).avgmolweight);
    end
    if isfield(metabolite_structure.(Mets{i}),'avgmolweight')&& ~isempty((metabolite_structure.(Mets{i}).monoisotopicweight)) && isempty(find(isnan(metabolite_structure.(Mets{i}).avgmolweight)))  && ~isnumeric(metabolite_structure.(Mets{i}).monoisotopicweight)
        % make sure that monoisotopicweight are numeric
        metabolite_structure.(Mets{i}).monoisotopicweight = str2double(metabolite_structure.(Mets{i}).monoisotopicweight);
    end
    if  isfield(metabolite_structure.(Mets{i}),'chemspider')&& isempty(find(isnan(metabolite_structure.(Mets{i}).chemspider)))  && ~isnumeric(metabolite_structure.(Mets{i}).chemspider)
        % make sure that charges are numeric
        metabolite_structure.(Mets{i}).chemspider = str2double(metabolite_structure.(Mets{i}).chemspider);
    end
    if  isfield(metabolite_structure.(Mets{i}),'metlin')&& isempty(find(isnan(metabolite_structure.(Mets{i}).metlin)))  && ~isnumeric(metabolite_structure.(Mets{i}).metlin)
        % make sure that metlin are numeric
        metabolite_structure.(Mets{i}).metlin = str2double(metabolite_structure.(Mets{i}).metlin);
    end
    if  isfield(metabolite_structure.(Mets{i}),'pubChemId')&&metabolite_structure.(Mets{i}).pubChemId==0
        % make sure that pubChemId is not 0
        metabolite_structure.(Mets{i}).pubChemId = NaN;
    end
end
