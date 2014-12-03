function renameDreamOutputFiles(path)
%rename .rxn files to have the name of the second line
%
%OPTIONAL INPUT
% path  name of the directory with .rxn files to rename

if ~exist('path','var')
    path=pwd;
end
cd(path)

%get filenames
fileNames = dir(path);
bool=false(size(fileNames));
for n=1:length(fileNames)
    if strcmp(fileNames(n).name(1),'.')
        bool(n,1)=1;
    end
end
fileNames=fileNames(~bool);

for n=3:length(fileNames)
    fid=fopen(fileNames(n).name,'r');
    tline=fgetl(fid);
    %second line should have reaction name
    tline = fgetl(fid);
    rxnNames{n,1}=tline;
end

for n=3:length(fileNames)
    movefile(fileNames(n).name,[rxnNames{n} '.rxn']);
end