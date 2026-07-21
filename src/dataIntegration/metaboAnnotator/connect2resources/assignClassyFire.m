function [metabolite_structure] = assignClassyFire(metabolite_structure, startSearch, endSearch)
% Get the metabolite taxonomic classification from ClassyFire (online), based
% on each metabolite InChIKey, and store the Kingdom, Superclass, Class,
% Subclass and Level 5 assignments as `classyFire_*` fields.
%
% USAGE:
%
%    [metabolite_structure] = assignClassyFire(metabolite_structure, startSearch, endSearch)
%
% INPUT:
%    metabolite_structure:    metabolite structure whose fields are VMH
%                             metabolite IDs
%
% OPTIONAL INPUTS:
%    startSearch:             numeric index of where the search should start in
%                             the metabolite structure (default: 1)
%    endSearch:               numeric index of where the search should end in
%                             the metabolite structure (default: last metabolite)
%
% OUTPUT:
%    metabolite_structure:    metabolite structure updated with the ClassyFire
%                             classification fields
%
% .. Author: - Ines Thiele, 09/2021


annotationSource = 'ClassyFire search based on inchiKey';
annotationType = 'automatic';

taxLevel = {'Kingdom'
    'Superclass'
    'Class'
    'Subclass'
    'Level 5'
    };

F = fieldnames(metabolite_structure);
if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(F);
end

for i = startSearch : endSearch

    if ~isempty( metabolite_structure.(F{i}).inchiKey) && length(find(isnan( metabolite_structure.(F{i}).inchiKey))) == 0
        inchiKey = metabolite_structure.(F{i}).inchiKey;
        try
            url =['http://classyfire.wishartlab.com/entities/' inchiKey];
            syst = urlread(url);
            
            for k = 1 : length(taxLevel)
                [levelOut] = getData(syst,taxLevel{k});
                metabolite_structure.(F{i}).(['classyFire_' regexprep(taxLevel{k},' ','')]) = levelOut;
                metabolite_structure.(F{i}).(['classyFire_' regexprep(taxLevel{k},' ','') '_source']) = [annotationSource,':',annotationType,':',datestr(now)];
            end
        end
    end
end
function [levelOut] = getData(syst,levelIn)
tok0 = split(syst,'Taxonomic Classification');
tok = split(tok0{2},levelIn);
tok2 = split(tok{2},'<abbr title=');
tok3 = split(tok2{2},'">');
tok4 = split(tok3{2},'</');
levelOut = tok4{1};