function totalSize = getDirectorySize(dirPath)
%======================================================================================================#
% Title: Directory disk use calculator
% Author: Wiley Barton
% Modified code sources:
%   assistance and reference from a generative AI model [ChatGPT](https://chatgpt.com/)
%       clean-up and improved readability
% Last Modified: 2025.01.29
% Part of: Persephone Pipeline
%
% Description:
%   This function determines the size of a selected directory
%
% Inputs:
%   - repoPathSeqC (char) : Path to the SeqC repository
%   - outputPathSeqC (char) : Path for SeqC output
%   - fileIDSeqC (char) : Unique identifier for file processing
%   - procKeepSeqC (logical) : Keep all files (true/false)
%   - maxMemSeqC (int) : Maximum memory allocation for SeqC
%   - maxCpuSeqC (int) : Maximum CPU allocation for SeqC
%   - maxProcSeqC (int) : Maximum processes for SeqC
%   - debugSeqC (logical) : Enable debug mode (true/false)
%   ...
%
% Dependencies:
%   - MATLAB
%   - Docker installed and accessible in the system path
%======================================================================================================#

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