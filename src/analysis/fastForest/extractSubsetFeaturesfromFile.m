function extractSubsetFeaturesfromFile(fileName, featureList)
% This function takes a tab delimited file of features (colums) and samples
% (rows) as input and extracts a desired subset of features and their
% corresponding value for each sample.
%
% INPUT
% fileName      file name
% featureList   list of features (must be overlapping with the feature
%               names given in the first row of the file)
%
% OUTPUT
% an output file will be written containing only the subset - the data will
% be comma separated
%
% Ines Thiele, July '22


clear keep colW tline rows fid

fid=fopen(fileName);
tline = fgetl(fid);

cnt = 1;
while ischar(tline)
    %disp(tline);
    % split line
    if cnt == 1 % header
        col = split(tline,'	');
        % get the wanted colum numbers
        colW = find(ismember(col,featureList));
        colW = [1;colW]; % add the first col with data point name
        keep{cnt,1} = col{colW(1)};
        s = ',';
        for i = 2 : length(colW)
            keep{cnt} = strcat(keep{cnt},s,col{colW(i)});
        end
        cnt = cnt + 1;
    else
        %now get only the wanted cols
        rows = split(tline,'	');
        keep{cnt,1} = rows{colW(1)};
        s = ',';
        for i = 2 : length(colW)
            keep{cnt} = strcat(keep{cnt},s,rows{colW(i)});
        end
        cnt = cnt + 1;
    end
    tline = fgetl(fid);
    if mod(cnt,1000)==1
        cnt
    end
end
fclose(fid);


fid =fopen([fileName '_subset' '.txt'], 'w');
for j = 1 : length(keep)-1
    fprintf(fid,strcat(keep{j},'\n'));
end