function G = createGroupIncidenceMatrix_old(model, gcmOutputFile, gcmMetList, jankowskiGroupData)
% Create a group incidence matrix from group contribution method (GCM) output,
% mapping each metabolite to its structural groups (Jankowski et al. data)
%
% USAGE:
%
%    G = createGroupIncidenceMatrix_old(model, gcmOutputFile, gcmMetList, jankowskiGroupData)
%
% INPUTS:
%    model:                COBRA model structure, read for the fields:
%
%                            * .mets - `m x 1` cell array of metabolite identifiers
%                            * .jankowskiGroupData - struct of group data with a `.groups` field
%                            * .gcmMetList - metabolite identifiers ordered as the GCM output file rows
%                            * .gcmOutputFile - path to the GCM output file to parse
%    gcmOutputFile:        path to the group contribution method output file
%    gcmMetList:           cell array of metabolite identifiers matching the GCM output rows
%    jankowskiGroupData:    struct of Jankowski et al. group data with field:
%
%                            * .groups - cell array of structural group names
%
% OUTPUT:
%    G:                    `m x g` group incidence matrix, one row per metabolite
%                          and one column per structural group

groups = model.jankowskiGroupData.groups;
metList = model.gcmMetList;
fidin = fopen(model.gcmOutputFile, 'r');

tline1 = fgetl(fidin); % Header row

G = zeros(length(model.mets),length(groups));
counter = 0;

while 1
    tline1 = fgetl(fidin);
    counter = counter + 1;

    if ~ischar(tline1)
        break;
    end

    if ~strcmp('NONE;NONE;', tline1(1:10))
        semiColonIdx = strfind(tline1, ';');
        barIdx = strfind(tline1, '|');
        colonIdx = strfind(tline1, ':');

        thisMetGroup = tline1((semiColonIdx(2) + 1):(colonIdx(1) - 1));
        thisMetGroupCount = str2double(tline1((colonIdx(1) + 1):(barIdx(1) - 1)));

        if any(ismember(groups,thisMetGroup))
            G(ismember(model.mets,metList(counter)),ismember(groups,thisMetGroup)) = thisMetGroupCount;
        else
            error([thisMetGroup, ' not in group list from GCM paper.'])
        end

        for n = 1:(length(barIdx)-1)
            thisMetGroup = tline1((barIdx(n) + 1):(colonIdx(n+1) - 1));
            thisMetGroupCount = str2double(tline1((colonIdx(n+1) + 1):(barIdx(n+1) - 1)));
            if any(ismember(groups,thisMetGroup))
                G(ismember(model.mets,metList(counter)),ismember(groups,thisMetGroup)) = thisMetGroupCount;
            else
                error([thisMetGroup, ' not in group list from GCM paper.'])
            end
        end

    end

end

fclose(fidin);
