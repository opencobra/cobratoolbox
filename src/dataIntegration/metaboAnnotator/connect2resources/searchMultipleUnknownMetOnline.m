function [metabolite_structure,hit] = searchMultipleUnknownMetOnline(metabolite_structure,metabolite_structure_rBioNet,metab_rBioNet_online,rxn_rBioNet_online,startSearch,endSearch)
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
% Ines Thiele, 2020-2021


if ~exist('metabolite_structure_rBioNet','var')
    load met_strc_rBioNet;
end


if ~exist('metab_rBioNet_online','var') ||  ~exist('rxn_rBioNet_online','var')
    load('data/rxn.mat');
    load('data/metab.mat');
    metab_rBioNet_online = metab;
    rxn_rBioNet_online = rxn;
end

F = fieldnames(metabolite_structure);
cnt = 1;
if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(F);
end

for i = startSearch : endSearch
    clear metabolite_structure_tmp
    metName = metabolite_structure.(F{i}).metNames;
    
    [metabolite_structure_tmp] = searchUnknownMetOnline(metName,metabolite_structure.(F{i}).VMHId,metabolite_structure_rBioNet,metab_rBioNet_online,rxn_rBioNet_online);
    if ~isempty(metabolite_structure_tmp) && ~isempty(metabolite_structure)
        Ftmp = fieldnames(metabolite_structure_tmp);
        for j = 1 : length(Ftmp)
            hit{cnt,1} = metName;
            hit{cnt,2} = Ftmp{j};
            hit{cnt,3} = metabolite_structure_tmp.(Ftmp{j}).hmdb;
            cnt = cnt +1;
            % merge the two structure that have overlapping fieldnames
            FF = fieldnames(metabolite_structure_tmp.(Ftmp{j}));
            for k = 1 : length(FF)
                if ~isempty(metabolite_structure_tmp.(Ftmp{j}).(FF{k})) && length(find(isnan(metabolite_structure_tmp.(Ftmp{j}).(FF{k})))) ==0 ... % entry are not empty
                        && (isempty(metabolite_structure.(Ftmp{j}).(FF{k})) || length(find(isnan(metabolite_structure.(Ftmp{j}).(FF{k})))) >0)      % but are empty in the starting structure
                    metabolite_structure.(Ftmp{j}).(FF{k}) = metabolite_structure_tmp.(Ftmp{j}).(FF{k});
                end
            end
        end
        
    elseif ~isempty(metabolite_structure_tmp) && isempty(metabolite_structure)
        metabolite_structure = metabolite_structure_tmp;
        Ftmp = fieldnames(metabolite_structure_tmp);
        for j = 1 : length(Ftmp)
            hit{cnt,1} = metName;
            hit{cnt,2} = Ftmp{j};
            hit{cnt,3} = metabolite_structure_tmp.(Ftmp{j}).hmdb;
            cnt = cnt +1;
        end
    elseif  ~isempty(metabolite_structure_tmp)
        [metabolite_structure] = catstruct(metabolite_structure,metabolite_structure_tmp);
        Ftmp = fieldnames(metabolite_structure_tmp);
        for j = 1 : length(Ftmp)
            hit{cnt,1} = metName;
            hit{cnt,2} = Ftmp{j};
            hit{cnt,3} = metabolite_structure_tmp.(Ftmp{j}).hmdb;
            cnt = cnt +1;
        end
    elseif isempty(metabolite_structure_tmp)
        hit{cnt,1} = metName;
        cnt = cnt +1;
    end
end
