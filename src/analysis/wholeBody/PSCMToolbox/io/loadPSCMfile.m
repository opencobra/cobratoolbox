function variable = loadPSCMfile(fileName, searchDirectory)
% Loads a .mat file into the workspace, given a nickname or a full filename.
% If a nickname is given, i.e., "Harvey", "Harvetta", or Recon3D (legacy feature), the latest
% available version in the cobratoolbox is loaded. By specifiying the
% searchDirectory variable, .mat files are only searched in the given user defined 
% directory. By default, all files within the MATLAB path variable are
% searched. If the full filename is given, the exact specified file is loaded. 
%
% USAGE:
%       variable = loadPSCMfile(fileName, searchDirectory)
%
% INPUTS:
% fileName:             Nickname of .mat file to load or full name of .mat file to load
%
% OPTIONAL INPUTS
% searchDirectory:      User specified directory with .mat file to load. 
%
% OUTPUT:
% variable:             Matlab variable returned
%
% EXAMPLE: 
%               % Giving only WBM nickname loads the latest available WBM:
%               male = loadPSCMfile('Harvey');
%               % Giving the exact name of the .mat file loads the exact
%               specified mode:
%               female = loadPSCMfile('Harvetta_1_03d'); 
%               % Also specifiying the search directory loads the .mat file
%               within that directory:
%               male = loadPSCMfile('Harvetta','MYDIRECTORY')
%
% AUTHORS:
%   - Ines Thiele, 2020
%   - Tim Hensen, July 2024: Removed hardcoding of WBMs names and added
%   option for searching a user defined directories.

if ~ischar(fileName)
    error('fileName must be a character array')
end

if nargin < 2
    searchDirectory = '';
end

if nargin > 2
    error('Too many input arguments.')
end

% Legacy code support
if matches(fileName,'Recon3D') % Load Recon3D Harvey
        load Recon3D_Harvey_Used_in_Script_120502
        variable = modelConsistent;
        return % exit function
end

% Find the WBM version to load
if matches(fileName,'Harvey','IgnoreCase',true) || matches(fileName,'Harvetta','IgnoreCase',true)
    nameOfWBM = findLatestWBM(fileName, searchDirectory);
else
    nameOfWBM = fileName;
end

% Check if .mat file is included in the fileName and add if missing
if ~contains(nameOfWBM,'.mat')
    nameOfWBM = append(nameOfWBM,'.mat');
end

% Check if fileName can be found
if isempty(which(nameOfWBM))
    % Find .mat files that can be loaded in prespecified directory
    if ~isempty(searchDirectory)
        availableWBMs = what(searchDirectory).mat;
        disp('The specified file could not be found in the directory. The following WBMs are avaialble in the specified directory:')
        disp(availableWBMs)
    end
    error('File cannot be found. Please check if the name is spelled correctly and if the folder is include in the path variable.')
end

% Legacy support for loading 1.01 versions of WBMs
if matches(nameOfWBM,{'Harvey_1_01c','Harvetta_1_01d','Harvetta_1_01c'})
    variable = legacyLoadWBM101(nameOfWBM);
    return % Exit function
end


% Load WBMs in the COBRA v3 format
try % Try to load WBM
    model = load(nameOfWBM);
    if isscalar(fieldnames(model))
        % Loading the model in a variable might make it nested. Unnest variable
        model = model.(string(fieldnames(model)));
    end
catch ME
    disp(ME.message)
    warning('Could not load file. Now trying to load using readCbModel')
    % Set useReadCbModel to 1 for debugging (legacy code)
    if contains(fileName,'Harvey')
        model = readCbModel(nameOfWBM, 'fileType','Matlab', 'modelName', 'male');
    elseif contains(fileName,'Harvetta')
        model = readCbModel(nameOfWBM, 'fileType','Matlab', 'modelName', 'female');
    else
        model = readCbModel(nameOfWBM, 'fileType','Matlab');
    end
end

% Correct model fields where needed.
if contains(fileName,'Harvey')
    model = correctWBMfields(model,'male');
elseif contains(fileName,'Harvetta')
    model = correctWBMfields(model,'female');
end

% Set output
variable = model;

end

function nameOfWBM = findLatestWBM(filename, searchDirectory, excludeVersion)
% Function for finding the name of the latest version of WBM models in the directory.
%
% USAGE:
%                   nameOfWBM = findLatestWBM(filename, searchDirectory, excludeVersion)
%
% INPUT:
% fileName:         Nickname of .mat file to load (Harvey or Harvetta)
%
% OPTIONAL INPUT
% searchDirectory   Character array to directory with WBM models.
% ExcludeVersion    Name of version to exclude
%
% OUTPUT:
% nameOfWBM:        Name of latest version of WBM model (character array).
%
% Author: 
%         - Tim Hensen, August 2024

if isempty(searchDirectory)
    searchDirectory = what(['2020_WholeBodyModelling' filesep 'Data']).path;
end

if nargin<3
    excludeVersion = '';
end

% Find latest harvery/harvetta models
WBMs = what(searchDirectory).mat;

% Check if any WBMs can be found
if isempty(WBMs)
    error('No WBM .mat files found in folder.')
end

% Remove .mat
WBMs = erase(WBMs,'.mat');

% Exclude WBMs if needed
if ~isempty(excludeVersion)
    WBMs(excludeVersion)=[];
end

% Filter on Harvey or Harvetta
WBMs(~contains(WBMs,filename))=[];

% Find version numbers in reconstruction names
modelNumbers = regexp(WBMs,'[0-9]','match');

% Produce 2 column numerical array with the major version in the first
% column and the minor version in the second column.
modelNumbers = string(vertcat(modelNumbers{:}));
modelNumbers = str2double(horzcat(modelNumbers(:,1), strcat(modelNumbers(:,2), modelNumbers(:,3))));

% Add the version letter
letterVersions = string(regexp(WBMs,'(?<=\d)[a-zA-Z]','match'));
% Convert lettes to numbers using ascii table
modelNumbers = [modelNumbers double(char(letterVersions))-96]; % https://www.asciitable.com/

% Find latest version
checkLatest = @(x) max(x) == x;

% Find versions with the latest major release
latestMajor = checkLatest(modelNumbers(:,1));
if sum(latestMajor)==1
    % Select model if only one entry has the highest major release
    nameOfWBM = WBMs(latestMajor);
else
    % Remove all entries without the latest major release
    modelNumbers(~latestMajor,:)=[];
    WBMs(~latestMajor)=[];
    % Find entries with the latest minor release
    latestMinor = checkLatest(modelNumbers(:,2));
    if sum(latestMinor)==1
            % Select model if only one entry has the highest major release
            nameOfWBM = WBMs(latestMinor);
    else
            % Remove all entries without the latest minor release
            modelNumbers(~latestMinor,:)=[];
            WBMs(~latestMinor)=[];
            % Find entries with the latest letter release
            latestLetter = checkLatest(modelNumbers(:,3));
            if sum(latestLetter)==1
                nameOfWBM = WBMs(latestLetter);
            else
                error('No single latest model could be found')
            end
    end
end
nameOfWBM = char(string(nameOfWBM));
end

function variable = legacyLoadWBM101(fileName)
% This function contains legacy support for loading
% Harvetta_1_01d, Harvetta_1_01c, and Harvey_1_01c.
%
% USAGE:
%                   variable = legacyLoadWBM101(fileName)
%
% INPUT:
% fileName:         Nickname of .mat file to load (Harvey or Harvetta)
%
% OUTPUT:
% variable:     matlab variable returned
%
% Author: 
%         - Tim Hensen, August 2024

% If loading Harvetta_1_01d returns an error, Harvetta_1_01c is loaded.
if matches(fileName,'Harvetta_1_01d')
    try
        % Load model
        model = load('Harvetta_1_01d');
    catch
        model = load('Harvetta_1_01c');
    end
else
    % Load model
    model = load(fileName);
end

% Unnest variable
if isscalar(fieldnames(model))
    % Loading the model in a variable might make it nested. Unnest variable
    model = model.(string(fieldnames(model)));
end

% Change subsystem names
model.subSystems(strmatch('Transport, endoplasmic reticular',model.subSystems,'exact'))={'Transport, endoplasmic reticulum'};
model.subSystems(strmatch('Arginine and Proline Metabolism',model.subSystems,'exact'))={'Arginine and proline Metabolism'};
model.subSystems(strmatch(' ',model.subSystems,'exact'))={'Miscellaneous'};

if 1
    %convert to v3 format except for coupling constraints
    model   = convertOldStyleModel(model,0,0);
end

variable = model;
end

function variable = correctWBMfields(model, modelSex)
% This function replaces the field model.gender by model.sex and removes
% the field model.rxnGeneMat".
%
% USAGE:
%                   variable = correctWBMfields(model, modelSex)
%
% INPUT:
% model:            WBM model
% modelSex          Character or string array of the sex of the WBM model
%
% OUTPUT:
% variable:     matlab variable returned
%
% Author: 
%         - Tim Hensen, August 2024

% Replace model.gender by model.sex
if isfield(model,'gender')
    model.sex = model.gender;
    model = rmfield(model,'gender');
else
    model.sex = modelSex;
end

% Remove rxnGeneMat
if isfield(model,'rxnGeneMat')
    model = rmfield(model,'rxnGeneMat');
end

% Set output
variable = model;
end