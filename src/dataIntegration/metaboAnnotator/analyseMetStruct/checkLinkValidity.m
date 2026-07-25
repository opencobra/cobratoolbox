function [metabolite_structure, removed] = checkLinkValidity(metabolite_structure, startSearch, endSearch)
% Checks the validity of collected metabolite identifier hyperlinks
%
% Takes each of the collected metabolite identifiers (currently HMDB IDs) and
% tests whether the identifier still resolves. Identifiers whose links are
% dead or have been revoked are removed from the metabolite structure.
%
% USAGE:
%
%    [metabolite_structure, removed] = checkLinkValidity(metabolite_structure, startSearch, endSearch)
%
% INPUTS:
%    metabolite_structure:    metabolite structure
%
% OPTIONAL INPUTS:
%    startSearch:             numeric index where the search should start in
%                             the metabolite structure (default: 1)
%    endSearch:               numeric index where the search should end in the
%                             metabolite structure (default: number of
%                             metabolites in the structure)
%
% OUTPUTS:
%    metabolite_structure:    updated metabolite structure with invalid
%                             identifiers removed
%    removed:                 list of identifiers that were removed

F = fieldnames(metabolite_structure);

if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(F);
end
IdList = fieldnames(metabolite_structure.(F{1}));
cnt =1;
for i = startSearch : endSearch

    for k = 1 : length(IdList)
        id = metabolite_structure.(F{i}).(IdList{k});
        if ~isempty(id) && length(find(isnan(id))) ==0 % id is there
            if strcmp(IdList{k},'hmdb')
                try
                    url=strcat('https://hmdb.ca/metabolites/',id);
                    syst = urlread(url);
                catch
                    % invalid ID
                    % remove ID from field
                    metabolite_structure.(F{i}).(IdList{k})= NaN;
                    metabolite_structure.(F{i}).([IdList{k} ,'_source']) = [   metabolite_structure.(F{i}).(IdList{k}) ': Id has been removed as it was a deadlink'];
                    removed{cnt,1} = id; cnt = cnt +1;
                end
                if contains(syst,'has been revoked') % not valid ID anymore
                    % remove
                    metabolite_structure.(F{i}).(IdList{k})= NaN;
                    metabolite_structure.(F{i}).([IdList{k} ,'_source']) = [   metabolite_structure.(F{i}).(IdList{k}) ': Id has been removed as it was revoked by HMDB'];
                    removed{cnt,1} = id; cnt = cnt +1;
                end
            end
        end
    end
end
