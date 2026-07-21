function outputFilePath = validateDietPath(Diet, resPath)
% validateDietPath checks if 'Diet' is a valid COBRA Toolbox diet or file path
% and either loads the corresponding data or saves it to a text file.
%
% USAGE:
%
%    outputFilePath = validateDietPath(Diet, resPath)
%
% INPUTS:
%    Diet:              a string or character array; either a COBRA Toolbox diet name
%                       (e.g. 'EUAverageDiet', 'HighFiberDiet') or a file path to a
%                       '.txt' or '.m' file containing diet data
%    resPath:           folder path where the diet data is saved as a text file
%
% OUTPUT:
%    outputFilePath:    path to the saved text file, or the input file path if no saving
%                       is needed
%
% NOTE:
%    If 'Diet' is a COBRA Toolbox diet name, the corresponding data is loaded. If 'Diet'
%    is a file path, '.txt' files are skipped and '.m' files are executed to load the
%    diet data. If no valid input is provided, an error is thrown.
%
% .. Author: - Anna Sheehy, January 2025
%
loaded = 0; 
skip = 0;
% Check diet exists
if ~exist('Diet','var')
    EUAverageDietNew;
    loaded = 1;
    % Check if diet provided is the name of any cobratoolbox diet
elseif strcmp(Diet,'EUAverageDiet') || strcmp(Diet,'EUAverageDietNew')
    EUAverageDietNew;
    loaded = 1;
elseif strcmp(Diet,'HighFiberDiet')
    HighFiberDiet;
    loaded = 1;
elseif strcmp(Diet,'HighProteinDiet')
    HighProteinDiet;
    loaded = 1;
elseif strcmp(Diet,'UnhealthyDiet')
    UnhealthyDiet;
    loaded = 1;
elseif strcmp(Diet,'VegetarianDiet')
    VegetarianDiet;
    loaded = 1;
    % Check if diet is file path to a .txt file or a .m file
elseif isfile(Diet)
    if contains(diet, 'txt')
        skip = 1;
    elseif contains(diet, '.m')
        load(diet)
    end
else 
    error('No valid diet provided')
end
    if loaded == 1 && skip == 0
        fileName = 'diet.txt';
        outputFilePath = fullfile(resPath, fileName);
        % Remove Diet_ to be applicable for MgPipe diet setting function
        Diet(:,1) = strrep(Diet(:,1), 'Diet_EX_', 'EX_');
        writecell(Diet, outputFilePath, 'Delimiter', '\t');
    else
        outputFilePath = diet;
    end
end
