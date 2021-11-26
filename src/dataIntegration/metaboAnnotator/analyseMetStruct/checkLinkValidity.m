function [metabolite_structure,removed] = checkLinkValidity(metabolite_structure,startSearch,endSearch)
% the aim of this script is go take each of the id's collected and test
% whether

% also I should greb from each resource the formula or inchi to compare and
% establish consistency

% check hmdb IDs -- I found a few Bridge derived hmdb ID's that are not
% valid anymore

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
