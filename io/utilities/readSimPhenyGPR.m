function [rxnInfo,rxns,allGenes] = readSimPhenyGPR(fileName)
%readSimPhenyGPR Read SimPheny gene-protein-reaction association file obtained from admin console
%
% [rxnInfo,rxns] = readSimPhenyGPR(fileName)
%
%INPUT
% fileName      SimPheny GPR file
%
%OUTPUTS
% rxnInfo       Structure containing data for each reaction
% rxns          List of reactions
% allGenes      List of all genes
% Markus Herrgard 6/4/07

fid = fopen(fileName,'r');

allGenes = [];
cnt = 0;
while 1
    line = fgetl(fid);
    if ~ischar(line),   break,   end
    fields = splitString(line,'","');
    for j = 1:length(fields)
        fields{j} = strrep(fields{j},',"','');
        fields{j} = strrep(fields{j},'",','');
        fields{j} = strrep(fields{j},'"','');
    end
    if (length(fields) == 8)
        cnt = cnt+1;
        rxns{cnt} = fields{1};
        rxnInfo(cnt).ID = fields{1};
        rxnInfo(cnt).name = fields{2};
        rxnInfo(cnt).subSystem = fields{4};
        rxnInfo(cnt).EC = fields{5};
        rxnInfo(cnt).gra = fields{7};
        [genes,rule] = parseBoolean(rxnInfo(cnt).gra);
        rxnInfo(cnt).rule = rule;
        rxnInfo(cnt).genes = genes;
        allGenes = [allGenes genes];
        rxnInfo(cnt).gpa = fields{8};
    end
end

allGenes = unique(allGenes);
rxns = columnVector(rxns);
fclose(fid);