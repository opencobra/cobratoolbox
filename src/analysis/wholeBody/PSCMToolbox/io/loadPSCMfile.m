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
    % Loading the model in a variable makes it nested. Unnest variable
    model = model.(string(fieldnames(model)));
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

% global useSolveCobraLPCPLEX
% useSolveCobraLPCPLEX

useReadCbModel = 0;
switch fileName
    case 'Harvey'
        if useSolveCobraLPCPLEX
            %COBRA v2 format
            load Harvey_1_01c
            
            male.subSystems(strmatch('Transport, endoplasmic reticular',male.subSystems,'exact'))={'Transport, endoplasmic reticulum'};
            male.subSystems(strmatch('Arginine and Proline Metabolism',male.subSystems,'exact'))={'Arginine and proline Metabolism'};
            male.subSystems(strmatch(' ',male.subSystems,'exact'))={'Miscellaneous'};
            
            if 1
                %convert to v3 format except for coupling constraints
                male   = convertOldStyleModel(male,0,0);
            end
        else
            if useReadCbModel
                male = readCbModel('Harvey_1_03c', 'fileType','Matlab', 'modelName', 'male');
            else
                %COBRA v3 format
                %load Harvey_1_02c
                try
                    load Harvey_1_03d
                catch
                    load Harvey_1_03c
                end
            end
        end
        if isfield(male,'gender')
            male.sex = male.gender;
            male = rmfield(male,'gender');
        else
            male.sex = 'male';
        end
        if isfield(male,'rxnGeneMat')
            male = rmfield(male,'rxnGeneMat');
        end
        variable = male;
    case 'Harvetta'
        if useSolveCobraLPCPLEX
            %COBRA v2 format
            try
                load Harvetta_1_01d
            catch
                load Harvetta_1_01c
            end
            female.subSystems(strmatch('Transport, endoplasmic reticular',female.subSystems,'exact'))={'Transport, endoplasmic reticulum'};
            female.subSystems(strmatch('Arginine and Proline Metabolism',female.subSystems,'exact'))={'Arginine and proline Metabolism'};
            female.subSystems(strmatch(' ',female.subSystems,'exact'))={'Miscellaneous'};
            
            if 1
                %convert to v3 format except for coupling constraints
                female = convertOldStyleModel(female,0,0);
            end
        else
            if useReadCbModel
                female = readCbModel('Harvetta_1_03c', 'fileType','Matlab', 'modelName', 'male');
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
model = model.(string(fieldnames(model)));

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