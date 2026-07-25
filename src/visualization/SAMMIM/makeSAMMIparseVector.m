function parsevec = makeSAMMIparseVector(dat)
% Converts a struct array describing SAMMI subgraphs into the array-string
% format used by the SAMMI front-end to filter the model into subgraphs
%
% USAGE:
%
%    parsevec = makeSAMMIparseVector(dat)
%
% INPUT:
%    dat:         Struct array, one element per subgraph, with fields:
%
%                   * .name - name of the subgraph
%                   * .rxns - cell array of reaction identifiers included
%                     in the subgraph
%                   * .flux - optional numeric vector, one value per
%                     reaction in `.rxns`, mapped as reaction color; if
%                     `dat` has a `flux` field, empty entries are filled
%                     with `NaN`
%
% OUTPUT:
%    parsevec:    Character array encoding `dat` as the nested array
%                 string `[[name,[rxn,flux],...],...]` used by the SAMMI
%                 front-end

    if ismember('flux',fields(dat))
        for i = 1:length(dat)
            if isempty(dat(i).flux)
                dat(i).flux = NaN(length(dat(i).rxns),1);
            end
        end
        tmp = arrayfun(@(x) strcat('["',x.name,'",',strjoin(strcat('["',x.rxns,'","',sprintfc('%g',x.flux),'"]'),','),']'),dat,'UniformOutput',false);
    else
        tmp = arrayfun(@(x) strcat('["',x.name,'",',strjoin(strcat('["',x.rxns,'"]'),','),']'),dat,'UniformOutput',false);
    end
    %Finalize
    tmp = strjoin(tmp,',');
    parsevec = strcat('[',tmp,']');
end
























