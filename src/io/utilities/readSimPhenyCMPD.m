function [metInfo,mets] = readSimPhenyCMPD(fileName)
%readSimPhenyCMPD Read SimPheny compound file obtained from admin console
%
% [metInfo,mets] = readSimPhenyCMPD(fileName)
%
%INPUT
% fileName      SimPheny compound file name
%
%OUTPUTS
% metInfo       Structure contaning data on metabolites
% mets          List of metabolites
%
% Markus Herrgard 6/4/07

fid = fopen(fileName,'r');

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
    if (length(fields) == 9)
        cnt = cnt+1;
        mets{cnt} = fields{1};
        metInfo(cnt).ID = fields{1};
        metInfo(cnt).name = fields{2};
        metInfo(cnt).formula = fields{3};
        metInfo(cnt).charge = str2double(fields{5});
        metInfo(cnt).casNumber = fields{6};
        metInfo(cnt).neutralFormula = fields{7};
        metInfo(cnt).altNames = splitString(fields{8},'/');
        for j = 1:length(metInfo(cnt).altNames)
           metInfo(cnt).altNames{j} = deblank(metInfo(cnt).altNames{j});
        end
        metInfo(cnt).KEGGID = fields{9};
    end
end

mets = columnVector(mets);
fclose(fid);