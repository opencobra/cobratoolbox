function editCobraToolboxPath(basePath,folderPattern,method)
%recursively finds all the folders within a given basePath that contains a
%given folderPattern and either adds or removes that folder from the matlab
%path

if ~exist('basePath','var') || isempty(basePath)
    aPath = which('initVonBertalanffy');
    basePath = strrep(aPath,'vonBertalanffy/initVonBertalanffy.m','');
end
if ~exist('folderPattern','var') || isempty(folderPattern)
    folderPattern=[filesep 'new'];
end
if ~exist('method','var') || isempty(method)
    method = 'remove';
end


folderlist = dir(fullfile(basePath, ['**' filesep '*.*']));  %get list of files and folders in any subfolder
folderlist = folderlist([folderlist.isdir]);  %remove files from list

folderlistOnly=cell(length(folderlist),1);
for i=1:length(folderlist)
    folderlistOnly{i,1} = folderlist(i).folder;
end
folderlistOnly = unique(folderlistOnly);

for i=1:length(folderlistOnly)
    if contains(folderlistOnly{i,1},folderPattern)
        switch method
            case 'add'
                disp(['adding: ' folderlistOnly{i,1}])
                addpath(folderlistOnly{i,1})
            case 'remove'
                disp(['removing: ' folderlistOnly{i,1}])
                rmpath(folderlistOnly{i,1})
            otherwise
                error([method ' is not a recognised method'])
        end
    end
end