function [metabolite_structure] = queryExposomeExplorer(metabolite_structure)
%
% the function will search for metabolite names
% http://exposome-explorer.iarc.fr/search?utf8=%E2%9C%93&query=2-aminophenol+sulfate&button=
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

annotationSource = 'Exposome Explorer website by name search';
annotationType = 'automatic';

for i = startSearch : endSearch
    if isempty(metabolite_structure.(Mets{i}).lipidmaps) || length(find(isnan(metabolite_structure.(Mets{i}).lipidmaps)))>0
        metN = metabolite_structure.(Mets{i}).metNames;
        % make name fit for internet
        metN = regexprep(metN,'"','');
        metInt = regexprep(metN,' ','+') ;
       % http://exposome-explorer.iarc.fr/search?utf8=%E2%9C%93&query=2-aminophenol+sulfate&button=
        url=['http://exposome-explorer.iarc.fr/search?utf8=%E2%9C%93&query=' metInt];
        syst = urlread(url);
        exposomeExplorer = '';
        if exist('syst','var') && ~isempty(strfind(syst,'returned 1 result'))
            tok = split(syst,'a href="/compounds/');
            tok2 = split(tok{2},'>');
            tok3 = regexprep(tok2{1},'"','');
            exposomeExplorer = tok3;
            % no real information on there - could be useful for getting mol
            % files
            if ~isempty(exposomeExplorer)
                metabolite_structure.(Mets{i}).exposomeExplorer = exposomeExplorer;
                metabolite_structure.(Mets{i}).exposomeExplorer_source = [annotationSource,':',annotationType,':',':',datestr(now)];
            end
        end
    end
end