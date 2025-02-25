function outputFilePath = validateDietPath(Diet, resPath)
% validateDietPath checks if 'Diet' is a valid COBRA Toolbox diet or file path
% and either loads the corresponding data or saves it to a text file.

% INPUTS:
% - Diet: A string or character array. Can be:
%     1. A COBRA Toolbox diet name (e.g., 'EUAverageDiet', 'HighFiberDiet').
%     2. A file path to a '.txt' or '.m' file containing diet data.
% - resPath: Folder path where the diet data will be saved as a text file.

% OUTPUT:
% - outputFilePath: The path to the saved text file or the input file path if no saving is needed.

% SCENARIOS:
% 1. If 'Diet' is a COBRA Toolbox diet name, the corresponding data is loaded.
% 2. If 'Diet' is a file path, it checks if it's a '.txt' or '.m' file:
%    - '.txt' files are skipped.
%    - '.m' files are executed to load the diet data.
% 3. If no valid input is provided, an error is thrown.
% Author: Anna Sheehy January 2025
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
        writecell(Diet, outputFilePath, 'Delimiter', '\t');
    else
        outputFilePath = diet;
    end
end
