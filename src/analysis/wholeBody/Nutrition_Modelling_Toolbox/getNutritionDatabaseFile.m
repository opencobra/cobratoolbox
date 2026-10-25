function [filePath, edition] = getNutritionDatabaseFile(database, fileType, edition)
% Obtain the path to a USDA or Frida nutrition database file of a specific
% database edition. If no edition is given, the latest edition available in
% papers/2025_nutritionToolbox of the COBRA Toolbox is used.
%
% USAGE:
%
%    [filePath, edition] = getNutritionDatabaseFile(database, fileType, edition)
%
% INPUTS:
%    database:        Char, the database to use: 'usda', 'frida' or 'bls'
%    fileType:        Char, the database file to obtain: '100gFluxValue',
%                     '100gMacros', 'infoFile', 'foodItems' (usda) or
%                     'foodIdDictionary' (frida and bls)
%
% OPTIONAL INPUTS:
%    edition:         Char or numeric, four-digit year of the database
%                     edition, e.g., '2024'. If empty the latest edition
%                     found in papers/2025_nutritionToolbox is used
%                     (default '')
%
% OUTPUTS:
%    filePath:        Char, full path to the requested .mat file
%    edition:         Char, the database edition that is used
%
% EXAMPLE:
%
%    fluxTableUsda = load(getNutritionDatabaseFile('usda', '100gFluxValue')).fluxTableUsda;
%
% .. Author: - Bram Nap, 10-2026

if nargin < 3
    edition = '';
end

% Convert the edition to a char, e.g., 2024 -> '2024'
edition = char(string(edition));
if ~isempty(edition) && isempty(regexp(edition, '^\d{4}$', 'once'))
    error('The database edition should be a four-digit year, e.g., ''2024''. Given: %s', edition)
end

% Directory where the nutrition toolbox databases are stored
toolboxRoot = fileparts(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))));
databaseRoot = fullfile(toolboxRoot, 'papers', '2025_nutritionToolbox');

% Set the database folder and the file prefix. Note that the USDA info file
% uses a lowercase prefix (usda<YEAR>_infoFile.mat)
switch lower(database)
    case 'usda'
        databaseDir = fullfile(databaseRoot, 'usdaDatabase');
        fluxPrefix = 'USDA';
        if strcmp(fileType, 'infoFile')
            prefix = 'usda';
        else
            prefix = 'USDA';
        end
    case 'frida'
        databaseDir = fullfile(databaseRoot, 'fridaDatabase');
        fluxPrefix = 'frida';
        prefix = 'frida';
    case 'bls'
        databaseDir = fullfile(databaseRoot, 'blsDatabase');
        fluxPrefix = 'BLS';
        prefix = 'BLS';
    otherwise
        error('Unknown database "%s". Please use usda, frida or bls.', database)
end

% If no edition is given, use the latest edition for which a flux table is
% present. The flux table is used so that all files of a run come from the
% same edition.
if isempty(edition)
    allFiles = dir(databaseDir);
    tokens = regexp({allFiles.name}, ['^', fluxPrefix, '(\d{4})_100gFluxValue\.mat$'], 'tokens', 'once');
    tokens = tokens(~cellfun(@isempty, tokens));
    if isempty(tokens)
        error('No %s database could be found in %s', database, databaseDir)
    end
    years = cellfun(@(x) str2double(x{1}), tokens);
    edition = num2str(max(years));
end

% Build the file name and find the file. First look in the toolbox
% database folder, otherwise look on the MATLAB path
fileName = [prefix, edition, '_', fileType, '.mat'];
filePath = fullfile(databaseDir, fileName);
if ~isfile(filePath)
    filePath = which(fileName);
    if isempty(filePath)
        error('Could not find %s in %s or on the MATLAB path.', fileName, databaseDir)
    end
end
end
