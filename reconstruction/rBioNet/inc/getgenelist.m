% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function out = getgenelist(input_dir)
%Read gene-list text file and return data.
%Default SIZE for GENELIST.txt is 7 columns! Each column is separated with
%a tab.
% Thorleifsson

fid = fopen(input_dir);
line = fgetl(fid);
cnt = 0;
Column = 7; %default
data = cell(1,Column);
while line ~= -1
    cnt = cnt + 1;
    data_line=regexp(line, '\t','split');
    % If mistakes are made when creating genelist, then this removes empty
    % cells.
    if isempty(data_line{1}) || strcmp(line(1),'*') %Lines that start with a star are comments
        %add nothing
        cnt = cnt - 1;
    else
        Sd = size(data_line,2);
        if Sd < Column
            missing = Column-Sd;

            data_line(1,Sd+1:Sd+missing+1) = {'No data'};
        end
        data(cnt,1:Column) = data_line(1:Column);
    end
    
    line = fgetl(fid);
end

out = data;
fclose(fid);
