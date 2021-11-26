function [metabolite_structure] = queryLipidMaps(metabolite_structure,startSearch,endSearch)
%
% the function will search for metabolite names
%https://www.lipidmaps.org/search/quicksearch.php?Name=2-methyl-dodecanedioic+acid
%
%
% INPUT
% metabolite_structure  metabolite structure
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
%
% Ines Thiele, 09/2021


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