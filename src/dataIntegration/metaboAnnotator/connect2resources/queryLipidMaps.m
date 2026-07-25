function [metabolite_structure] = queryLipidMaps(metabolite_structure, startSearch, endSearch)
% Search the LipidMaps website (https://www.lipidmaps.org) by metabolite name
% and add the matched LipidMaps identifier to the metabolite structure for
% metabolites that lack a LipidMaps id.
%
% USAGE:
%
%    [metabolite_structure] = queryLipidMaps(metabolite_structure, startSearch, endSearch)
%
% INPUT:
%    metabolite_structure:    metabolite structure whose fields are VMH
%                             metabolite IDs, each holding `metNames` and
%                             `lipidmaps` fields
%
% OPTIONAL INPUTS:
%    startSearch:             numeric index of where the search should start in
%                             the metabolite structure (default: 1)
%    endSearch:               numeric index of where the search should end in
%                             the metabolite structure (default: last metabolite)
%
% OUTPUT:
%    metabolite_structure:    updated metabolite structure
%
% .. Author: - Ines Thiele, 09/2021


Mets = fieldnames(metabolite_structure);

if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(Mets);
end

annotationSource = 'Lipid Maps website by name search';
annotationType = 'automatic';

for i = startSearch : endSearch
    if isempty(metabolite_structure.(Mets{i}).lipidmaps) || length(find(isnan(metabolite_structure.(Mets{i}).lipidmaps)))>0
        metN = metabolite_structure.(Mets{i}).metNames;
        % make name fit for internet
        metN = regexprep(metN,'"','');
        metInt = regexprep(metN,' ','+') ;
        
        url=['https://www.lipidmaps.org/search/quicksearch.php?Name=' metInt];
        syst = urlread(url);
        lipidmaps = '';
        if exist('syst','var') && ~isempty(strfind(syst,'1 matches'))
            tok = split(syst,'/data/LMSDRecord.php');
            tok2 = split(tok{2},'>');
            tok3 = split(tok2{2},'<');
            lipidmaps = tok3{1};
            % no real information on there - could be useful for getting mol
            % files
            %url = ['https://www.lipidmaps.org/databases/lmsd/' lipidmaps];
            if ~isempty(lipidmaps)
                metabolite_structure.(Mets{i}).lipidmaps = lipidmaps;
                metabolite_structure.(Mets{i}).lipidmaps_source = [annotationSource,':',annotationType,':',':',datestr(now)];
            end
        end
    end
end