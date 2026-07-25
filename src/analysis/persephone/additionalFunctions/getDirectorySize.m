function totalSize = getDirectorySize(dirPath)
% Determine the total size on disk of a selected directory
%
% USAGE:
%
%    totalSize = getDirectorySize(dirPath)
%
% INPUT:
%    dirPath:      path to the directory whose size is calculated
%
% OUTPUT:
%    totalSize:    total size of the directory contents in bytes
%
% .. Author: - Wiley Barton, 2025.01.29

    % Ensure the directory path is valid
    if ~isfolder(dirPath)
        error('Directory does not exist: %s', dirPath);
    end

    % Get all files and folders in the directory
    dirInfo = dir(dirPath);
    
    % Initialize total size
    totalSize = 0;

    % Loop through directory contents
    for i = 1:length(dirInfo)
        % Skip '.' and '..' entries
        if strcmp(dirInfo(i).name, '.') || strcmp(dirInfo(i).name, '..')
            continue;
        end
        
        % Full path of the file/folder
        fullPath = fullfile(dirPath, dirInfo(i).name);
        
        % If it's a file, add its size
        if ~dirInfo(i).isdir
            totalSize = totalSize + dirInfo(i).bytes;
        else
            % If it's a folder, recursively add its size
            totalSize = totalSize + getDirectorySize(fullPath);
        end
    end
end