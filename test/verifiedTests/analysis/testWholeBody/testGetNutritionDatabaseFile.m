% The COBRAToolbox: testGetNutritionDatabaseFile.m
%
% Purpose:
%     - getNutritionDatabaseFile(database, fileType, edition) returns the path of a USDA, Frida
%       or BLS nutrition database file (<prefix><edition>_<fileType>.mat): from
%       papers/2025_nutritionToolbox/<database>Database when it is there, otherwise from the
%       MATLAB path, and with the latest edition that has a flux table when no edition is given.
%       This test checks the default edition against an independent listing of the shipped
%       database folders (the papers submodule), the lookup on the MATLAB path with hand-made
%       files of a fictitious edition 1999 in a tempname folder (numeric, string and mixed-case
%       inputs, the lowercase prefix of the USDA info file), and every error message.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/getNutritionDatabaseFile.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; reads only folder listings (no database is loaded).
%
% Coverage exemptions:
%     None. Every executable line is reached below (lines 73-80 use the shipped Frida and USDA
%     folders of the papers submodule, line 77 the missing BLS folder; the sections check
%     whichever case the checkout holds).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The shipped USDA food items file is not found
%       SEVERITY: limitation
%       TRIGGER: getNutritionDatabaseFile('usda', 'foodItems') with the papers submodule
%       OBSERVED: error "Could not find USDA2024_foodItems.mat in
%         <toolbox>/papers/2025_nutritionToolbox/usdaDatabase or on the MATLAB path." - the
%         shipped file is named USDAFoodItems.mat (also on the submodule's origin/master);
%         createUSDAdatabase writes USDA<YEAR>_foodItems.mat, the name this function builds
%       EXPECTED: the path of the shipped USDA food items file, as the help text lists
%         'foodItems' (usda) as a file type
%       LINES: 85-90
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetNutritionDatabaseFile'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the shipped database folders, located from the toolbox root independently of the function
toolboxRoot = fileparts(which('initCobraToolbox'));
databaseRoot = fullfile(toolboxRoot, 'papers', '2025_nutritionToolbox');

%% default edition: the latest year with a flux table in the shipped folder, or an error

databases = {'frida', 'fridaDatabase', 'frida', 'frida', '100gMacros'; ...
             'usda', 'usdaDatabase', 'USDA', 'usda', 'infoFile'; ...
             'bls', 'blsDatabase', 'BLS', 'BLS', '100gMacros'};
for i = 1:size(databases, 1)
    folder = fullfile(databaseRoot, databases{i, 2});
    % years of the files <fluxPrefix><YEAR>_100gFluxValue.mat in the folder
    listing = dir(fullfile(folder, [databases{i, 3} '*_100gFluxValue.mat']));
    years = regexp({listing.name}, ['^' databases{i, 3} '(\d{4})_100gFluxValue\.mat$'], 'tokens', 'once');
    years = years(~cellfun(@isempty, years));
    if isempty(years)
        assert(verifyCobraFunctionError('getNutritionDatabaseFile', 'inputs', {databases{i, 1}, '100gFluxValue'}, ...
            'testMessage', sprintf('No %s database could be found in %s', databases{i, 1}, folder)));
    else
        latest = num2str(max(cellfun(@(x) str2double(x{1}), years)));
        % the two-argument call returns the flux table of the latest edition
        [filePath, edition] = getNutritionDatabaseFile(databases{i, 1}, '100gFluxValue');
        assert(strcmp(edition, latest));
        assert(strcmp(filePath, fullfile(folder, [databases{i, 3} latest '_100gFluxValue.mat'])));
        % an empty edition is the default too; the file prefix of the second file type (the
        % USDA info file is the only one with a lowercase prefix)
        expectedFile = fullfile(folder, [databases{i, 4} latest '_' databases{i, 5} '.mat']);
        if isfile(expectedFile)
            [filePath, edition] = getNutritionDatabaseFile(databases{i, 1}, databases{i, 5}, '');
            assert(strcmp(filePath, expectedFile) && strcmp(edition, latest));
        end
    end
end

%% a file that is not in the database folder is looked up on the MATLAB path

% files of the fictitious edition 1999 in a temporary folder on the MATLAB path
pathBefore = path;
tempFolder = tempname;
mkdir(tempFolder);
fileNames = {'BLS1999_foodIdDictionary.mat', 'usda1999_infoFile.mat', ...
    'USDA1999_100gMacros.mat', 'frida1999_100gFluxValue.mat'};
placeholder = 1;
for i = 1:numel(fileNames)
    save(fullfile(tempFolder, fileNames{i}), 'placeholder');
end
addpath(tempFolder);

% a numeric edition is converted to text; the database name is not case sensitive
[filePath, edition] = getNutritionDatabaseFile('BLS', 'foodIdDictionary', 1999);
assert(strcmp(filePath, fullfile(tempFolder, 'BLS1999_foodIdDictionary.mat')) && strcmp(edition, '1999'));
% the USDA info file has the lowercase prefix usda, the other USDA files USDA
[filePath, edition] = getNutritionDatabaseFile('usda', 'infoFile', '1999');
assert(strcmp(filePath, fullfile(tempFolder, 'usda1999_infoFile.mat')) && strcmp(edition, '1999'));
filePath = getNutritionDatabaseFile('Usda', '100gMacros', "1999");
assert(strcmp(filePath, fullfile(tempFolder, 'USDA1999_100gMacros.mat')));
filePath = getNutritionDatabaseFile('frida', '100gFluxValue', '1999');
assert(strcmp(filePath, fullfile(tempFolder, 'frida1999_100gFluxValue.mat')));

% a file that is neither in the database folder nor on the path is an error
assert(verifyCobraFunctionError('getNutritionDatabaseFile', 'inputs', {'frida', 'noSuchFile', '1999'}, ...
    'testMessage', sprintf('Could not find frida1999_noSuchFile.mat in %s or on the MATLAB path.', ...
    fullfile(databaseRoot, 'fridaDatabase'))));

path(pathBefore);
rmdir(tempFolder, 's');

%% errors: an edition that is not a four-digit year and an unknown database

assert(verifyCobraFunctionError('getNutritionDatabaseFile', 'inputs', {'usda', '100gFluxValue', '24'}, ...
    'testMessage', 'The database edition should be a four-digit year, e.g., ''2024''. Given: 24'));
assert(verifyCobraFunctionError('getNutritionDatabaseFile', 'inputs', {'usda', '100gFluxValue', 20245}, ...
    'testMessage', 'The database edition should be a four-digit year, e.g., ''2024''. Given: 20245'));
assert(verifyCobraFunctionError('getNutritionDatabaseFile', 'inputs', {'ciqual', '100gFluxValue', '2024'}, ...
    'testMessage', 'Unknown database "ciqual". Please use usda, frida or bls.'));

% change the directory
cd(currentDir)
