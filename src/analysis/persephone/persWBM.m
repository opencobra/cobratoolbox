function [iWBM, iWBMcontrol_female, iWBMcontrol_male, persParams] = persWBM(metadata, varargin)
%
% This function takes a table of physiological parameters for an individual or multiple individuals
% (listed in inputs) and adjusts the paramteres of a provided WBM or Harvey/Harvetta to
% create a personalised WBM
%
% The calculation of physiological parameteres will be performed based on
% the available data e.g., if the user provides Cardiac output, this given
% value is assigned, if the user provides stroked volume and no CO, CO is
% calculated based on SV. If neither values are provided, CO will be
% calculated based on XXX. All details of parameter calculation are
% detailed in the personalised model output and in the excel file provided
% by this function.
%
% INPUTS
%
% REQUIRED:
% metadata                     Can be a struct (for personalising one model)
%                              or a path to an excel file (for batch
%                              personalisation). If it is a structure, it
%                              should follow the format of the individualised
%                              parameters struct obtained from running:
%                              > sex = "male";
%                              OR
%                              > sex = "female";
%                              AND
%                              > standardPhysiolDefaultParameters;

%                              There must be a field with sex in the struct
%                              which is a string containing "male" or
%                              "female"
%                              For batch personalisation using an excel
%                              file, a list with a minimum of three column
%                              and option for additional columns for each
%                              individual for which a model should be created:
%
%                              |"ID"              |"Sex"    |"CardiacOutput"|
%                              ----------------------------------------------
%                              |"unit"           |""        | "mg/dL"       |
%                              |"Individual1"    |"male"    |5345           |
%                              |"Individual2"    |"female"  |5360           |
%
%
% OPTIONAL:
% persPhysiology               A list of all non-metabolite paramters in the
%                              metadata that you would like the models to be personalised with.
%                              Parameters that can be personalised include:
%                              Organ weight(g), modelID, body weight(kg), height(cm),
%                              sex, heart rate(), stroke volume(), cardiac
%                              output(), hematocrit(), creatinine(), blood flow
%                              rate(), glomerular filtration rate(), blood flow
%                              for each organ()
%                              *for each the default unit used by the model
%                              is provided. For x, y, z- unit conversion
%                              will be performed for all known common units of
%                              measurement.
% femaleWBM                   A female WBM (Whole Body Metabolic Model), or path to it.
%                             for any female subject detailed in the
%                             metadata, this model will be personalised.
%                             If no model is provided, either Harvey or Harvetta will be loaded from the COBRA
%                             toolbox, depending on sex in provided physiological data.
%                             If multiple models are provided, the model ID must
%                             match the model name provided in the
%                             physiological data.
% maleWBM                     A male WBM (Whole Body Metabolic Model), or path to it.
%                             for any male subject detailed in the
%                             metadata, this model will be personalised.
% resPath                     Path on which to store personalised model and
%                             other outputs.
%                             Default = current directory
% persMetabolites             Option to also personalise the metabolite constraints
%                             in the model based on metabolomic data
%                             (Default = skip). If not empty, the user must
%                             provide a list of metabolites (which should correspond
%                             to column headers in the metadata) that they
%                             would like to personalise the model for.
%                             ** This function can also be run in isolation
%                             but if a user wants to personalise both
%                             physiological and metabolomic- this function
%                             should alway be run and NOT
%                             persWBMmetabolomics in isolation!
% Diet                        Diet option: 'EUAverageDiet' (default)
%
% OUTPUTS
%
% iWBM                        Model with updated physiological paramteres
%                             (stored as "persModelName.mat"). All updated
%                             paramteres are described in
%                             model.IndividualisedParameters
% controlWBM(s)               This is a WBM with no personalised
%                             adjustments. When a WBM or multiple WBMs have
%                             been given as inputs, the controlWBMs are
%                             exact copies of those. When Harvey or
%                             Harvetta are used, controlWBM is copies of
%                             Harvey/Harvetta.
% persParameters              Excel file with details of the updated
%                             parameter and how it was calculated
%
%
% author: Anna Sheehy November 2024
%% Step 1: Read in the available data, check all data is valid
% Define the input parser
parser = inputParser();

% Add required inputs
addRequired(parser, 'metadata', @(x) ischar(x) || isstring(x) || isstruct(x));

% Add optional parameters
addParameter(parser, 'persPhysiology',{}, @iscell);
addParameter(parser, 'femaleWBM', '', @(x) isstruct(x) || ischar(x) || isstring(x));
addParameter(parser, 'maleWBM',   '', @(x) isstruct(x) || ischar(x) || isstring(x));
addParameter(parser, 'resPath', pwd, @ischar);
addParameter(parser, 'persMetabolites',{}, @iscell);
addParameter(parser, 'Diet', '', @ischar);

addParameter(parser, 'solver', '', @ischar);

% Parse required and optional inputs
parse(parser, metadata, varargin{:});

% Access the parsed inputs
metadata = parser.Results.metadata;
persPhysiology = parser.Results.persPhysiology;
femaleWBM = parser.Results.femaleWBM;
maleWBM = parser.Results.maleWBM;
resPath = parser.Results.resPath;
persMetabolites = parser.Results.persMetabolites;
Diet = parser.Results.Diet;
solver = parser.Results.solver;

metadataStruct = 0;

% Decide what metadata is
if isstruct(metadata)
    disp(' > Detected metadata structure, ensuring all required paramteres are present');
    % Rename user defined Individual parameters
    IndividualParametersP = metadata;
    sex = IndividualParametersP.sex;
    standardPhysiolDefaultParameters;
    % Ensure all fields from IndividualParameters are in metadata
    fields = fieldnames(IndividualParameters);
    for i = 1:numel(fields)
        if ~isfield(IndividualParametersP, fields{i})
            IndividualParametersP.(fields{i}) = IndividualParameters.(fields{i});
        end
    end
    % If creatinine is provided, calculate min and max (+/- 10%) to use for
    % constraining metabolite exchange in urine
    fn = fieldnames(IndividualParametersP);
    idx = find(strcmpi(fn, 'creatinine'), 1);
    if ~isempty(idx)
        Cn = IndividualParametersP.(fn{idx});
        IndividualParametersP.MConUrCreatinineMin = Cn * 0.9;
        IndividualParametersP.MConUrCreatinineMax = Cn * 1.1;
    end
    metadataStruct = 1;
else
    
    if ~ischar(metadata)
        error('metadata data does not satisfy the input requirments (iscell, ischar, isstruct)')
    else
        disp('Detected metadata is file path, reading and checking table');
        % Locate metadata file allowing for .csv or .xlsx ('_processed'
        % removal relevant only if running this function as part of the
        % Persephone pipeline)
        unprocessedMetadata = strrep(metadata, '_processed.csv', '');
        d = dir([unprocessedMetadata, '*']);
        match = d(endsWith({d.name}, {'.csv', '.xlsx'}, 'IgnoreCase', true));

        if isempty(match)
            error('No matching metadata file (.csv or .xlsx) found.')
        end
        % Set unprocessedMetadata to full path of matched file
        unprocessedMetadata = fullfile(match(1).folder, match(1).name);
        
        % Read the metadata table. If the variable names have more than 64
        % characters, the variable names in the table will be truncated. We account
        % for this later, so this warning is ignored here.
        warning('off')
        opts = detectImportOptions(metadata, 'VariableNamingRule', 'preserve');
        opts = setvartype(opts, opts.VariableNames(1), 'string');
        Data = readtable(metadata, opts);
        warning('on')
        
        % Check if metadata table is not empty
        validateattributes(Data, {'table'}, {'nonempty'}, mfilename, 'metadataTable')

        % The variable names in the metadata table will be truncated if the names
        % are longer than 64 characters. Read the true variable names and store
        % them in the VariableDescriptions property.
        % Next, the first 2 lines of the metadata are loaded
        metadataCell = readcell(unprocessedMetadata,"TextType","string",'Range', '1:2');
        Data.Properties.VariableUnits = string(metadataCell(2,:));
        
    end
end




disp(' > Personalisation of WBMs will now be performed')
% check if the solver is defined by the user
if ~isempty(solver)
    evalc('changeCobraSolver(solver, ''LP'');');
else
    % otherwise use the default solver (*note: glpk takes excessive time
    % running microbiotaModelSimulator: it is recommeneded to skip this
    % step if you don't have a different solver and manually apply the diet
    % instead using setDietConstraints -Anna Sheehy Jan 2025
    global CBT_LP_SOLVER
    if isempty(CBT_LP_SOLVER)
        initCobraToolbox;
    end
end


if isempty(Diet)
    Diet = 'EUAverageDiet';
    disp(' > No valid diet provided, average European diet will be used')
end


% Check Data has units stored in table properties
if ~metadataStruct && ~strcmp('ID', Data.Properties.VariableNames{1})
    error('Please ensure column 1 of your metadata is ID and is labelled accordingly')
elseif ~metadataStruct && isempty(Data.Properties.VariableUnits)
    error('Please ensure row 2 of your metadata contains units and is labelled accordingly')
end

AllParams = {
    'age'; ...
    'modelID'; ...
    'body weight';...
    'body fat'; ...
    'lean body mass'; ...
    'height';...
    'sex'; ...
    'heart rate'; ...
    'stroke volume'; ...
    'cardiac output';...
    'hematocrit'; ...
    'creatinine'; ....
    'blood flow rate';...
    'glomerular filtration rate'};

% Check that the data given matches the parameters that can be personalised
% Ensure male and female are not m and f, ensure column 1 is paramters and
% column 2 is units
% Data = processMetadata(Data);
% Check sex is in metadata
if metadataStruct
    sex = metadata.sex;
    sexType = sex;
else
    sex = cell2mat(strfind(lower(Data.Properties.VariableNames), 'sex'));
end
%
if ~metadataStruct && sex == 0
    error("Sex info not found in metadata")
elseif ~metadataStruct 
    sexCol = find(strcmp(lower(Data.Properties.VariableNames), 'sex'));
    sexType = table2cell(unique(lower(Data(:, sexCol))));
    if size(sexType, 1) == 2
        % check if subjects are mixed
        disp(" > Cohort includes both male and female subjects")
        sexType = 'mixed';
    elseif sexType == "male"
        % check if all sunjects are male
        disp("All subjects are male")
        sexType = 'male';
        clear femaleWBM
    elseif sexType == "female"
        % check if all subjects are female
        disp("All subjects are female")
        sexType = 'female';
        clear maleWBM
    else
        disp("Error reading sex info, please check your metadata")
    end
end


% Check that each parameter specified to be used in personalisation is usable, display warning for those that
% will be excluded
if ~isempty(persPhysiology)
    personalisingPhys = true;
    for s = 2:size(persPhysiology)
        matches = find(strcmp(lower(persPhysiology{s}), AllParams));
        if matches == 0
            error('Parameter %s does not match any parameter that can be personalised. Please check spelling and check function annotation for parameters that can be personalised', param);
        end
    end
else
    personalisingPhys = false;
    disp(' > persPhysiology not provided as input')
end

if ~isempty(parser.Results.persMetabolites)
    personalisingMets = true;
else
    personalisingMets = false;
    disp(' > persMetabolites not provided as input')
end

% If neither physiological or metabolomic paramters were speficief to
% personalise with, compare the parameters in the metadata to those we can
% personalise and extract the relevant parameters
if ~metadataStruct && ~personalisingPhys && ~personalisingMets
    fprintf(' > No parameters from metadata were specified to be used in personalisation\n');
    
    % Match variable names (case-insensitive)
    vars = Data.Properties.VariableNames;
    matches = ismember(lower(vars), lower(AllParams));
    persPhysiology = vars(matches);
    
    if isempty(persPhysiology)
        error(['No valid parameters found in metadata for personalising WBMs.\n' ...
            'Check names against valid list: %s'], strjoin(AllParams, ', '));
    end
    
    fprintf('> Using matched parameters from metadata to personalise:\n');
    disp(persPhysiology);
    personalisingPhys = true;
elseif  metadataStruct && ~personalisingPhys && ~personalisingMets
    personalisingPhys = true;
end

disp(" > All parameters are valid");
%% Step 2: Take each model iteratively, collect the available data and convert any units where necessary
% check if female control already exists on resPath
maleControlCreated = isfile(fullfile(resPath, 'iWBMcontrol_male.mat'));

% Create male control if not already completed and metadata contains
% male models
if sexType == "male" || sexType == "mixed"
    if isempty(maleWBM)
        maleWBM = loadPSCMfile('Harvey');
        iWBMcontrol_male = maleWBM;
    elseif isstruct(maleWBM)
        iWBMcontrol_male = maleWBM;
    elseif ischar(maleWBM) || isstring(maleWBM)
        maleWBM = load(maleWBM);
    else
        error("Cannot read input maleWBM")
    end
    if maleControlCreated == 0
        % run control through with no adjustments
        sex = "male";
        standardPhysiolDefaultParameters;
        iWBMcontrol_male = physiologicalConstraintsHMDBbased(iWBMcontrol_male,IndividualParameters);
        iWBMcontrol_male.SetupInfo.IndividualParameters = IndividualParameters;
        iWBMcontrol_male.ID = "male control";
        % if using metabolomic parameters also carry out step as control
        if ~isempty(parser.Results.persMetabolites)
            cParam = table();
            [~, iWBMcontrol_male] = persWBMmetabolomics(sex, cParam, 'iWBMcontrol', iWBMcontrol_male);
        end
        save(fullfile(resPath, 'iWBMcontrol_male.mat'),'-struct', 'iWBMcontrol_male');
    else
        disp(' > Male WBM control creation skipped')
        iWBMcontrol_male = 'Male WBM control creation skipped';
    end
else
    iWBMcontrol_male = "No male sample found in the metadata";
end

%check if female control already exists on resPath
femaleControlCreated = isfile(fullfile(resPath, 'iWBMcontrol_female.mat'));

% Create female control if not already completed and metadata contains
% female models
if sexType == "female" || sexType == "mixed"
    if isempty(femaleWBM)
        femaleWBM = loadPSCMfile('Harvetta');
        iWBMcontrol_female = femaleWBM;
    elseif isstruct(femaleWBM)
        iWBMcontrol_female = femaleWBM;
    elseif ischar(femaleWBM) || isstring(femaleWBM)
        femaleWBM = load(femaleWBM);
    else 
        error("Cannot read input femaleWBM")
    end
    if femaleControlCreated == 0
        % run control through with no adjustments
        sex = "female";
        standardPhysiolDefaultParameters
        iWBMcontrol_female = physiologicalConstraintsHMDBbased(iWBMcontrol_female,IndividualParameters);
        iWBMcontrol_female.SetupInfo.IndividualParameters = IndividualParameters;
        iWBMcontrol_female.ID = "female control";
        % if using metabolomic parameters also carry out step as control
        
        if ~isempty(parser.Results.persMetabolites)
            cParam = table();
            [~, iWBMcontrol_female] = persWBMmetabolomics(sex, cParam, 'iWBMcontrol', iWBMcontrol_female);
        end
        save(fullfile(resPath, 'iWBMcontrol_female.mat'),'-struct', 'iWBMcontrol_female');
    else
        disp(' > Female WBM control creation skipped')
        iWBMcontrol_female = 'Female WBM control creation skipped';
    end
else
    iWBMcontrol_female = 'No females samples found in the metadata';
end

%% Step 3: Process the data for each  model and update Individualized paramteres based on the metadata
% Check if some models are already created and remove them from data if so
if ~metadataStruct
    origSizeData = size(Data, 1);
    fprintf(' > There are %d models found in the metadata.\n', origSizeData);
    fileList = dir(fullfile(resPath, 'iWBM_*.mat'));
    existingIDs = extractBetween({fileList.name}, 'iWBM_', '.mat');
    existingIDs = string(existingIDs);
    
    % Filter Data table to remove already created models
    mask = ~ismember(string(Data{:,1}), existingIDs);
    Data = Data(mask, :);
    numModels = size(Data, 1);
    if numModels == 0
        fprintf(' > All models found to be created, skipping personalisation')
        iWBM = 'complete';
    else
        fprintf(' > %d of %d models in the metadata have already been personalised, %d models will now be personalised.\n', (origSizeData-numModels), origSizeData, numModels)
    end
    % extract units
    units = cell2table(Data.Properties.VariableUnits);
    units.Properties.VariableNames = Data.Properties.VariableNames;
else 
    numModels = 1;
end

% Define file path and check existence
persParamsFile = fullfile(resPath, 'persParameters.xlsx');

if isfile(persParamsFile)
    [~, sheets] = xlsfinfo(persParamsFile); % Get sheet names
    % Load sheets if they exist
    if ismember('PhysiologicalParameters', sheets)
        persParamsCheck = true;
        persParams = readtable(persParamsFile, 'Sheet', 'PhysiologicalParameters');
        fprintf(' > Loaded %d PhysiologicalParameters entries.\n', height(persParams));
        newNames = { ...
            'MConUrCreatinineMax', 'MConUrCreatinineMin', 'MConDefaultBc', ...
            'MConDefaultCSF', 'MConDefaultUrMax', 'MConDefaultUrMin'};
        oldNames = { ...
            'Max conc of creatinine in the urine', ...
            'Min conc of creatinine in the urine', ...
            'Max conc of a metabolite in the blood plasma', ...
            'Max conc of a metabolite in the CSF', ...
            'Max conc of a metabolite in the urine', ...
            'Min conc of a metabolite in the urine'};
        
        for k = 1:numel(oldNames)
            j = strcmp(persParams.Properties.VariableNames, oldNames{k});
            if any(j), persParams.Properties.VariableNames{j} = newNames{k}; end
        end
    else
        persParamsCheck = false;
        warning('Missing sheet: PhysiologicalParameters');
    end
    
    if ismember('MetabolomicParameters', sheets)
        persParamsMCheck = true;
        persParamsM = readtable(persParamsFile, 'Sheet', 'MetabolomicParameters');
        fprintf(' > Loaded %d MetabolomicParameters entries.\n', height(persParamsM));
    else
        persParamsMCheck = false;
        warning('Missing sheet: MetabolomicParameters');
    end
else
    persParamsCheck = false;
    persParamsMCheck = false;
end


for s = 1:numModels
    if personalisingPhys == 1
        if ~metadataStruct
            % extract relevant data
            dataCurrent = Data(s, :);
            warning('off', 'all')
            % delete empty rows need to get working or just use paramsPhysiology
            dataCurrent = [units; dataCurrent];
            keepIndices = find(ismember(lower(dataCurrent.Properties.VariableNames), lower(persPhysiology)));
            dataCurrent = dataCurrent(:, unique([1, keepIndices, sexCol], 'stable'));
            warning('on', 'all')
            
            % Update based on the subject
            % SEX
            sexID = find(strcmp(lower(dataCurrent.Properties.VariableNames),'sex'));
            sex = string(dataCurrent{2, sexID});
            
            % Load the default parameters
            standardPhysiolDefaultParameters;
            IndividualParameters.sex = sex;
            if sex  == "male"
                WBMcurrent = maleWBM;
            else
                WBMcurrent = femaleWBM;
            end
            
            % Create table to save detail on source of parameter (user define,
            % default, calculated using x)
            % Create a 1-row table from the structure
            fieldsToDelete = {'bloodFlowData', 'OrgansWeights', 'bloodFlowPercCol', 'bloodFlowOrganCol'};
            paramSource = rmfield(IndividualParameters, fieldsToDelete);
            paramSource = struct2table(paramSource);
            % Add some constant descriptions
            paramSource.sex = 'User defined';
            paramSource.BloodVolume = 'Estimated based on sex, height & weight';
            
            % ID
            if any(strcmp(lower(dataCurrent.Properties.VariableNames), 'id'))
                idxID = find(strcmp(lower(dataCurrent.Properties.VariableNames),'id'));
                ID = dataCurrent{2, idxID};
                IndividualParameters.ID = ID;
                paramSource.ID = 'User defined';
                WBMcurrent.ID = ID;
            end
            
            % BODY WEIGHT
            if any(strcmp(lower(dataCurrent.Properties.VariableNames),'body weight')) || any(strcmp(lower(dataCurrent.Properties.VariableNames),'weight')) || any(strcmp(lower(dataCurrent.Properties.VariableNames),'bodyweight'))
                idxWt = find(strcmp(lower(dataCurrent.Properties.VariableNames),'body weight') | strcmp(lower(dataCurrent.Properties.VariableNames),'weight')| strcmp(lower(dataCurrent.Properties.VariableNames),'bodyweight'));
                if size(idxWt, 2)>1
                    error('More than one column header in the metadata contains the paramter weight!')
                end
                if isempty(idxWt)
                    idxWt = find(strcmp(lower(dataCurrent.Properties.VariableNames),'weight'));
                end
                Wt = cell2mat(dataCurrent{2, idxWt});
                currentUnit = dataCurrent{1, idxWt};
                % Convert lbs to kg
                if ~isempty(currentUnit) && (strcmp(currentUnit, "kgs") || strcmp(currentUnit, "kg"))
                    IndividualParameters.bodyWeight = Wt;
                elseif strcmp(currentUnit, "lb") || strcmp(currentUnit, "lbs")
                    Wt = Wt * 0.453592;
                else
                    warning("Unable to read weight for patient %s, default weight will be applied", ID)
                end
                paramSource.bodyWeight = 'User defined';
            else
                paramSource.bodyWeight = 'Default';
            end
            
            % AGE
            if any(strcmp(lower(dataCurrent.Properties.VariableNames),'age'))
                idxAge = find(strcmp(lower(dataCurrent.Properties.VariableNames),'age'));
                if size(idxAge, 2)>1
                    error('More than one column header in the metadata contains the paramter age!')
                end
                Age = cell2mat(dataCurrent{2, idxAge});
                currentUnit = dataCurrent{1, idxAge};
                if strcmp(currentUnit, "days")
                    Age = Age / 365;
                elseif strcmp(currentUnit, "months")
                    Age = Age / 12;
                elseif strcmp(currentUnit, "years")|| strcmp(currentUnit, "yrs")
                    
                else
                    error('Age not provided in a valid unit');
                end
                IndividualParameters.Age = Age;
                paramSource.Age = 'User defined';
            else
                paramSource.Age = 'Default';
            end
            
            % HEIGHT
            if any(strcmp(lower(dataCurrent.Properties.VariableNames),'height'))
                idxHt = find(strcmp(lower(dataCurrent.Properties.VariableNames),'height'));
                if size(idxHt, 2)>1
                    error('More than one column header in the metadata contains the paramter height!')
                end
                Ht = cell2mat(dataCurrent{2, idxHt});
                currentUnit = dataCurrent{1, idxHt};
                if ~isempty(currentUnit) && strcmp(currentUnit, "cm")
                    IndividualParameters.Height = Ht;
                elseif strcmp(currentUnit, "ft")
                    Ht = Ht * 30.48;
                elseif strcmp(currentUnit, "in")
                    Ht = Ht * 2.54;
                else
                    warning("Unable to read height for patient %s, default height will be applied", ID)
                end
                paramSource.Height = 'User defined';
            else
                paramSource.Height = 'Default';
            end
            
            
            % HEART RATE
            if any(strcmp(lower(dataCurrent.Properties.VariableNames),'heart rate'))|| any(strcmp(lower(dataCurrent.Properties.VariableNames),'heartrate'))|| any(strcmp(lower(dataCurrent.Properties.VariableNames),'bpm'))
                idxHR = find(strcmp(lower(dataCurrent.Properties.VariableNames),'heart rate')| strcmp(lower(dataCurrent.Properties.VariableNames),'heartrate')| strcmp(lower(dataCurrent.Properties.VariableNames),'bpm'));
                if size(idxHR, 2)>1
                    error('More than one column header in the metadata contains the paramter heart rate!')
                end
                HR = cell2mat(dataCurrent{2, idxHR});
                currentUnit = dataCurrent{1, idxHR};
                if ~strcmp(currentUnit, "bpm")
                    error('Heart rate must be provided in bpm');
                end
                IndividualParameters.HeartRate = HR;
                paramSource.HeartRate = 'User defined';
            else
                paramSource.HeartRate = 'Default';
            end
            
            % STROKE VOLUME
            if any(strcmp(lower(dataCurrent.Properties.VariableNames),'stroke volume')) || any(strcmp(lower(dataCurrent.Properties.VariableNames),'SV'))|| any(strcmp(lower(dataCurrent.Properties.VariableNames),'strokevolume'))
                idxSV = find(strcmp(lower(dataCurrent.Properties.VariableNames),'stroke volume') | strcmp(lower(dataCurrent.Properties.VariableNames),'SV')| strcmp(lower(dataCurrent.Properties.VariableNames),'strokevolume'));
                if size(idxSV, 2)>1
                    error('More than one column header in the metadata contains the paramter stroke volume!')
                end
                SV = cell2mat(dataCurrent{2, idxSV});
                currentUnit = dataCurrent{1, idxSV};
                if ~strcmp(currentUnit, "mL") && ~strcmp(currentUnit, "ml")
                    error('Stroke volume must be provided in ml');
                end
                IndividualParameters.StrokeVolume = SV;
                paramSource.StrokeVolume = 'User defined';
            else
                paramSource.StrokeVolume = 'Default';
            end
            
            % HEMATOCRIT
            if any(strcmp(lower(dataCurrent.Properties.VariableNames),'hematocrit'))
                idxHmt = find(strcmp(lower(dataCurrent.Properties.VariableNames),'hematocrit'));
                if size(idxHmt, 2)>1
                    error('More than one column header in the metadata contains the paramter hematocrit!')
                end
                Hmt = cell2mat(dataCurrent{2, idxHmt});
                currentUnit = dataCurrent{1, idxHmt};
                % convert % to decimal
                if Hmt > 1
                    try
                        Hmt = Hmt / 100;
                    catch
                        Hmt = str2double(Hmt) / 100;
                    end
                end
                IndividualParameters.Hematocrit = Hmt;
                paramSource.Hematocrit = 'User defined';
            else
                paramSource.Hematocrit = 'Default';
            end
            
            % CREATININE
            if any(strcmp(lower(dataCurrent.Properties.VariableNames),'creatinine'))
                idxCn = find(strcmp(lower(dataCurrent.Properties.VariableNames),'creatinine'));
                if size(idxCn, 2)>1
                    error('More than one column header in the metadata contains the paramter creatinine!')
                end
                Cn = cell2mat(dataCurrent{2, idxCn});
                currentUnit = dataCurrent{1, idxCn};
                % Validate the unit
                if ~strcmp(currentUnit, "mg/dL")
                    error('Creatinine must be provided in mg/dL');
                end
                IndividualParameters.MConUrCreatinineMin = Cn*0.9;
                IndividualParameters.MConUrCreatinineMax = Cn*1.1;
                paramSource.MConUrCreatinineMin = 'User defined';
                paramSource.MConUrCreatinineMax = 'User defined';
            else
                paramSource.MConUrCreatinineMin = 'Default';
                paramSource.MConUrCreatinineMax = 'Default';
            end
            
            
%             % LEAN BODY MASS
%             if any(strcmp(lower(dataCurrent.Properties.VariableNames),'lean body mass'))
%                 idxLBM = find(strcmp(lower(dataCurrent.Properties.VariableNames),'lean body mass'));
%                 if size(idxLBM, 2)>1
%                     error('More than one column header in the metadata contains the paramter lean body mass!')
%                 end
%                 LBM = cell2mat(dataCurrent{2, idxLBM});
%                 currentUnit = dataCurrent{1, idxLBM};
%                 if strcmp(currentUnit, "g")
%                     LBM = LBM / 1000; % Convert grams to kilograms
%                 elseif strcmp(currentUnit, "kg")
%                     % No conversion needed
%                 else
%                     error('Lean body mass must be provided in g or kg');
%                 end
%                 IndividualParameters.LeanBodyMass = LBM;
%                 paramSource.LeanBodyMass = 'User defined';
%             else
%                 %paramSource.LeanBodyMass = 'Default';
%             end
            
%             % BODY FAT PERCENTAGE
%             if any(strcmp(lower(dataCurrent.Properties.VariableNames),'body fat'))
%                 idxBF = find(strcmp(lower(dataCurrent.Properties.VariableNames),'body fat'));
%                 if size(idxBF, 2)>1
%                     error('More than one column header in the metadata contains the paramter body fat!')
%                 end
%                 BF = cell2mat(dataCurrent{2, idxBF});
%                 currentUnit = dataCurrent{1, idxBF};
%                 if ~strcmp(currentUnit, '%') && strcmp(currentUnit, 'kg')
%                     BF = (BF /Wt)*100;
%                 elseif strcmp(currentUnit, 'g')
%                     BF = (BF/(Wt*1000))*100;
%                 elseif isempty(currentUnit)
%                     warning('Body weight (Wt) is in the wrong unit or conversion is not possible.');
%                 end
%                 IndividualParameters.BodyFat = BF;
%                 paramSource.BodyFat = 'User defined';
%             else
%                 %paramSource.BodyFat = 'Default';
%             end
            
            clear idxAge idxBF idxBFR idxCn idxCO idxGFR idxHmt idxHR idxHt idxID idxLBM idxSex idxSV idxWt Age Col Cols cParam currentUnit Hmt Ht Numbers Wt
           
            % For now, 1 is hardcoded. Should update to check available
            % parameters and then accoordingly use the most accurate
            % calculation
            % CARDIAC OUTPUT
            if any(strcmp(lower(dataCurrent.Properties.VariableNames),'cardiac output')) || any(strcmp(lower(dataCurrent.Properties.VariableNames),'CO'))|| any(strcmp(lower(dataCurrent.Properties.VariableNames),'cardiacoutput'))
                idxCO = find(strcmp(lower(dataCurrent.Properties.VariableNames),'cardiac output') | strcmp(lower(dataCurrent.Properties.VariableNames),'CO')| strcmp(lower(dataCurrent.Properties.VariableNames),'cardiacoutput'));
                if size(idxCO, 2)>1
                    error('More than one column header in the metadata contains the paramter cardiac output!')
                end
                CO = cell2mat(dataCurrent{2, idxCO});
                currentUnit = dataCurrent{1, idxCO};
                if strcmp(currentUnit, "L/min")
                    CO = CO*1000;
                elseif strcmp(currentUnit, "ml/min")
                    % no change needed
                else
                    error("Cardiac Output Unit not valid")
                end
                IndividualParameters.CardiacOutput = CO;
                paramSource.CardiacOutput = 'User defined';
            else
                paramSource.CardiacOutput = 'Default';
                optionCardiacOutput =1;
                
                % 2. Estimate (resting) cardiac output from blood volume in case that no stroke volume is provided
                if optionCardiacOutput ~=-1 % skip adjustment of CO
                    IndividualParameters.CardiacOutput = IndividualParameters.HeartRate * IndividualParameters.StrokeVolume; % in ml/min = beats/min * ml/beat
                    paramSource.CardiacOutput = 'Calculated from personalized StrokeVolume and heart rate';
                elseif optionCardiacOutput == 1
                    % actually I think that it makes more sense to keep the cardiac output to
                    % be calculated based on default strokevolume and heart rate
                    IndividualParameters.CardiacOutput = IndividualParameters.HeartRate * IndividualParameters.StrokeVolume; % in ml/min = beats/min * ml/beat
                    paramSource.CardiacOutput = 'Calculated from default StrokeVolume and heart rate';
                elseif optionCardiacOutput == 2
                    IndividualParameters.StrokeVolume ='NaN';
                    IndividualParameters.CardiacOutput = IndividualParameters.BloodVolume;
                    paramSource.CardiacOutput = 'Estimated from BloodVolume'; % in ml/min = beats/min * ml/beat
                elseif optionCardiacOutput == 0
                    % With the blood volume estimate the CO gets too low.
                    % hence I used the equation given here:
                    % http://www.ams.sunysb.edu/~hahn/psfile/pap_obesity.pdf
                    % note that the weight here is given in kg rather than g
                    
                    Wt = IndividualParameters.bodyWeight;
                    IndividualParameters.CardiacOutput = 9119-exp(9.164-2.91e-2*Wt+3.91e-4*Wt^2-1.91e-6*Wt^3);
                    paramSource.CardiacOutput = 'Estimated from CO equation'; % in ml/min = beats/min * ml/beat
                elseif optionCardiacOutput == 3
                    % from wikipedia: https://en.wikipedia.org/wiki/Fick_principle
                    %     VO_2 = (CO \times\ C_a) - (CO \times\ C_v)
                    % where CO = Cardiac Output, Ca = Oxygen concentration of arterial blood and Cv = Oxygen concentration of mixed venous blood.
                    % Note that (Ca ? Cv) is also known as the arteriovenous oxygen difference.
                    % Cardiac Output = (125 ml O2/minute x 1.9) / (200 ml O2/L - 150 ml O2/L) = 4.75 L/minute
                    % can be refined to account for haemoglobin content
                    IndividualParameters.CardiacOutput = ((IndividualParameters.VO2*1000)*60*24/(200 - 150));
                    paramSource.CardiacOutput = 'Estimated from VO2 (Fick principle)';
                elseif optionCardiacOutput == 4 %
                    %Cardiac Output = (125 ml O2/minute x 1.9) / (200 ml O2/L - 150 ml O2/L) = 4.75 L/minute
                    % Various calculations have been published to arrive at the BSA without direct measurement. In the following formulae, BSA is in m2, W is mass in kg, and H is height in cm.
                    % The most widely used is the Du Bois, Du Bois formula,[4][5] which has been shown to be equally as effective in estimating body fat in obese and non-obese patients, something the Body mass index fails to do.[6]
                    % BSA=0.007184 * W^{0.425}* H^{0.725}}
                    W = IndividualParameters.bodyWeight;
                    H = IndividualParameters.Height;
                    BSA=0.007184 * W^0.425* H^0.725 ;
                    IndividualParameters.CardiacOutput = ((0.125*1000*BSA)*60*24/(200 - 150));
                    paramSource.CardiacOutput = 'Estimated from surface area';
                elseif optionCardiacOutput == 5 %
                    % estimation of vO2max
                    % file:///Users/ines.thiele/Dropbox/work/Papers/SystemsPhysiology/schneider2013.pdf
                    % for males: VO2max/kg = -0.42 A + 58, where A is age
                    % for females: VO2max/kg = -0.35 A + 46, where A is age
                    % assuming that at low activity the vo2 is 25% of vo2max
                    % "At low exercise intensities (25% of maximal oxygen uptake (VO2max)), which in an average
                    % healthy untrained young adult (VO2max per kg body mass = 42 ml kg?1min?1)
                    % corresponds with level walking at 4?5 km h?1
                    W = IndividualParameters.bodyWeight;
                    A = IndividualParameters.age;
                    if strcmp(IndividualParameters.sex,'male')
                        VO2max = (-0.42* A + 58)*W; %ml/min
                    elseif strcmp(IndividualParameters.sex,'female')
                        VO2max = (-0.35* A + 46)*W;
                    end
                    VO2 = 0.07*VO2max;
                    IndividualParameters.CardiacOutput = ((VO2)*60*24/(200 - 150));
                    paramSource.CardiacOutput = 'Estimated based on VO2 max (Schneider, 2013)';
                elseif  optionCardiacOutput == 6 %
                    %estimation of stroke volume based on Frick
                    % http://circ.ahajournals.org/content/circulationaha/14/2/250.full.pdf
                    PP = 40; % pulse pressure
                    DP = 80; % diatstolic blood pressure
                    IndividualParameters.StrokeVolume = 91.0 + 0.54 * PP - 0.57*DP-0.61 *IndividualParameters.age ;
                    IndividualParameters.CardiacOutput = IndividualParameters.HeartRate * IndividualParameters.StrokeVolume; % in ml/min = beats/min * ml/beat
                    paramSource.CardiacOutput = 'Calculated based on HR and SV (stroke volume estimated based on Frick';
                elseif  optionCardiacOutput == 7 %
                    %estimation of stroke volume based on Bridwell
                    % http://circ.ahajournals.org/content/circulationaha/14/2/250.full.pdf
                    PP = 40; % pulse pressure
                    DP = 80; % diatstolic blood pressure
                    IndividualParameters.StrokeVolume = 66.0 + 0.34 * PP - 0.11*DP-0.36 *IndividualParameters.age ;
                    IndividualParameters.CardiacOutput = IndividualParameters.HeartRate * IndividualParameters.StrokeVolume; % in ml/min = beats/min * ml/beat
                    paramSource.CardiacOutput = 'Calculated based on HR and SV (stroke volume estimated based on Bridwell';
                end
            end
            
            % GLOMERULAR FILTRATION RATE
            if any(strcmp(lower(dataCurrent.Properties.VariableNames),'glomerular filtration rate')) || any(strcmp(lower(dataCurrent.Properties.VariableNames),'gfr'))
                idxGFR = find(strcmp(lower(dataCurrent.Properties.VariableNames), 'glomerular filtration rate') | strcmp(lower(dataCurrent.Properties.VariableNames), 'gfr'));
                if size(idxGFR, 2)>1
                    error('More than one column header in the metadata contains the paramter glomerular filtration rate!')
                end
                GFR = cell2mat(dataCurrent{2, idxGFR});
                currentUnit = dataCurrent{1, idxGFR};
                if strcmp(currentUnit, "mL/min/1.73m^2") || strcmp(currentUnit, "mL/min")
                    IndividualParameters.GlomerularFiltrationRate = GFR;
                    paramSource.GlomerularFiltrationRate = 'User defined';
                else
                    error('Glomerular Filtration rate must be provided in mL/min/1.73m^2 or mL/min');
                end
            else
                % Calculate GFR
                % the filtration fraction should be 20% of the renal plasma flow
                RenalFiltrationFraction  = 0.2; %20%
                % blood flow percentage that Kidney gets
                if strcmp(sex,'male')
                    BK = IndividualParameters.bloodFlowData{strmatch('Kidney',IndividualParameters.bloodFlowData(:,1),'exact'),IndividualParameters.bloodFlowPercCol(1)};
                elseif strcmp(sex,'female')
                    BK = IndividualParameters.bloodFlowData{strmatch('Kidney',IndividualParameters.bloodFlowData(:,1),'exact'),IndividualParameters.bloodFlowPercCol(2)};
                end
                try
                    BK = str2num(BK(2:end-1));
                catch
                    BK = (BK);
                end
                RenalFlowRate=BK*IndividualParameters.CardiacOutput*(1-IndividualParameters.Hematocrit); % k_plasma_organ in ml/min
                IndividualParameters.GlomerularFiltrationRate = RenalFlowRate*RenalFiltrationFraction;% in ml/min
                paramSource.GlomerularFiltrationRate = 'Calculated based sex, cardiac output and hematocrit';
            end % end of adding user provided inputs
        
        else  % If using a structure, check sex and load the correct model
            if IndividualParametersP.sex  == "male"
                WBMcurrent = maleWBM;
            else
                WBMcurrent = femaleWBM;
            end
            % Update the structure with the user defined inputs
            IndividualParameters = IndividualParametersP;
            ID = IndividualParameters.ID;
        end
        
        %% Step 4: Conditional calculations:
        % 1. Estimate blood volume
        if strcmp(IndividualParameters.sex, 'male') && ~isfield(IndividualParameters, 'BloodVolume')
            IndividualParameters.BloodVolume = (0.3669 * (IndividualParameters.Height/100)^3 + 0.03219 * IndividualParameters.bodyWeight + 0.6041)*1000;
        elseif strcmp(IndividualParameters.sex, 'female')&& ~isfield(IndividualParameters, 'BloodVolume')
            IndividualParameters.BloodVolume = (0.3561 * (IndividualParameters.Height/100)^3 + 0.03308 * IndividualParameters.bodyWeight + 0.1833)*1000;
        end
        
            
            %% Step 5: Update organ weight and the biomass
            [organs,~,OrganWeightFract,IndividualParametersN] = calcOrganFract(WBMcurrent, IndividualParameters);
            [WBMcurrent] = adjustWholeBodyRxnCoeff(WBMcurrent, organs, OrganWeightFract);
            
            %% Step 6: Update constraints based on new physiological parameters and biomass
            iWBM = physiologicalConstraintsHMDBbased(WBMcurrent,IndividualParametersN);
            
            % Find indices where lower bounds exceed upper bounds
            invalidIdx = find(iWBM.lb > iWBM.ub);
            if ~isempty(invalidIdx)
                % Initialize a string for the warning message
                warningMsg = 'Physiological personalisation has caused invalid bounds for the following reactions\n';
                
                % Loop through each invalid index and accumulate the message
                for i = 1:length(invalidIdx)
                    warningMsg = [warningMsg, sprintf('%s (%s): lb = %.2f, ub = %.2f\n', ...
                        iWBM.rxns{invalidIdx(i)}, ...
                        iWBM.rxnNames{invalidIdx(i)}, ...
                        iWBM.lb(invalidIdx(i)), ...
                        iWBM.ub(invalidIdx(i)))];
                end
                
                % Display the warning with multiple lines
                fprintf(2, '%s', warningMsg);
                
            end
            fprintf(" > Physiological parameters incorporated in model for subject %d of %d\n", s, numModels);
            iWBM.SetupInfo.Status = 'personalised';
            iWBM.SetupInfo.IndividualParameters = IndividualParametersN;
    end
    
    %% Step 6.1: option to personalise using metabolomic data
    if personalisingMets
        % extract relevant data
        dataCurrentM = Data(s, :);
        warning('off', 'all')
        % Add on units from table properties
        dataCurrentM = [units; dataCurrentM];
        % delete empty rows need to get working or just use paramsPhysiology
        keepIndices = find(ismember(dataCurrentM.Properties.VariableNames, persMetabolites));
        dataCurrentM = dataCurrentM(:, unique([1, keepIndices], 'stable'));
        dataCurrentM{3, 1} = "compartment";
        warning('on', 'all')
        
        % If persPhysiology was skipped, sex must be assigned and model
        % loaded
        if personalisingPhys == 0
            sex = string(Data{s, sexCol});
            % Load the default parameters
            standardPhysiolDefaultParameters;
            IndividualParameters.sex = sex;
            if sex  == "male"
                iWBM = maleWBM;
            else
                iWBM = femaleWBM;
            end
            if any(strcmp(lower(Data.Properties.VariableNames), 'id'))
                idxID = find(strcmp(lower(Data.Properties.VariableNames),'id'));
                ID = Data{s, idxID};
                IndividualParameters.ID = ID;
                iWBM.ID = ID;
            end
            iWBM.SetupInfo.IndividualParameters = IndividualParameters;
        else 
            iWBM = WBMcurrent;
        end
        
        % match every metabolite in persMetabolites to the
        % correct compartment in DataCurrentM
        for m = 1:size(persMetabolites, 1)
            met = persMetabolites{m, 1};
            comp = persMetabolites(m, 2);
            idxMet = find(strcmp(lower(dataCurrentM.Properties.VariableNames), lower(met)));
            if m == 1
                col1 = idxMet;
            end
            dataCurrentM(3, idxMet) = comp;
        end
        if idxMet > 2
            dataCurrentM = dataCurrentM(:, [1, col1:end]);
        end
        
        % Apply changes
        [iWBM, ~, persParamMcurrent] = persWBMmetabolomics(sex, dataCurrentM, 'iWBM', iWBM);
        fprintf(" > Metabolomic data incorporated in model for subject %d of %d\n", s, numModels);
        
        % Find indices where lower bounds exceed upper bounds
        invalidIdx = find(iWBM.lb > iWBM.ub);
        if ~isempty(invalidIdx)
            % Collect the data into a table
            conflictingBounds = table;
            conflictingBounds.ID      = repmat({ID}, length(invalidIdx), 1);  % repeat ID for each row
            conflictingBounds.rxns    = iWBM.rxns(invalidIdx);
            conflictingBounds.rxnName = iWBM.rxnNames(invalidIdx);
            conflictingBounds.lb      = iWBM.lb(invalidIdx);
            conflictingBounds.ub      = iWBM.ub(invalidIdx);
            
            % Initialize a string for the warning message
            warningMsg = 'Metabolomic personalisation has caused invalid bounds for the following reactions:';
            
            % Loop through each invalid index and accumulate the message
            for i = 1:length(invalidIdx)
                warningMsg = [warningMsg, sprintf('\n%s (%s): lb = %.2f, ub = %.2f\n in model: %s', ...
                    iWBM.rxns{invalidIdx(i)}, ...
                    iWBM.rxnNames{invalidIdx(i)}, ...
                    iWBM.lb(invalidIdx(i)), ...
                    iWBM.ub(invalidIdx(i)), ...
                    ID)];  % Fixed the missing closing parenthesis here
            end
            
            % Display the warning with multiple lines
            fprintf(2, '%s\n', warningMsg);
        end
    end % end of personalising metabolites
    %% Step 7: Save the updated iWBM, controlWBM and personalisationOverview
    if exist('iWBM', 'var') && isstruct(iWBM)
        if personalisingPhys == 1 && personalisingMets == 1
            iWBM.status = 'iWBM personalised with physiological and metabolomic data\n';
        elseif personalisingPhys == 1
            iWBM.status = 'iWBM personalised with physiological data\n';
        elseif personalisingMets == 1
            iWBM.status = 'iWBM personalised with metabolomic data\n';
        else
            iWBM.status = 'iWBM not personalised\n';
        end
    end
    
    filename = fullfile(resPath, strcat('iWBM_', num2str(ID), '.mat'));
    save(filename ,'-struct', 'iWBM');
    % Join physiological personalisation details together where personalising
    % for more than one model
    if personalisingPhys == 1
        fieldsToDelete = {'bloodFlowData', 'OrgansWeightsRefMan', 'OrgansWeights', 'bloodFlowPercCol', 'bloodFlowOrganCol'};
        IndividualParametersN = rmfield(IndividualParametersN, fieldsToDelete);
        persParamCurrent = struct2table(IndividualParametersN);
        if s == 1 && persParamsCheck == 0
            persParams = persParamCurrent;
        else
            persParams.ID = cellstr(persParams.ID);
            persParamCurrent.ID = cellstr(persParamCurrent.ID);
            persParams = [persParams; persParamCurrent];
        end
    end
    
    % Join metabolic personalisation details together where personalising
    % for more than one model
    if personalisingMets == 1
        if s == 1 && persParamsMCheck == 0
            persParamsM = persParamMcurrent;
        else
            persParamsM.ID = cellstr(persParamsM.ID);
            persParamMcurrent.ID = cellstr(persParamMcurrent.ID);
            % persParamsM.Properties.VariableNames = persParamMcurrent.Properties.VariableNames;
            persParamsM = [persParamsM; persParamMcurrent];
        end
    end 
    % Add diet to model
    factor = 1; % Percentage of the provided diet to be added.
    iWBM = setDietConstraints(iWBM, Diet, factor);

    
    if exist('conflictingBounds', 'var')
        if s == 1 && persParamsMCheck == 0
            conflictingBoundsAll = conflictingBounds;
        else
            conflictingBoundsAll = [conflictingBoundsAll; conflictingBounds];
        end
    end 
  
end % end of forloop for each model
 % If necessary, save
 if exist('conflictingBoundsAll', 'var')
     writetable(conflictingBoundsAll, fullfile(resPath, 'conflictingBounds.xlsx'));
 end

%% Step 8: Diet and sanity check
% REMOVE MODELS WITH CONFLICTING BOUNDS
% infeasModels = unique(conflictingBoundsAll.ID);
% feasPaths = ~contain(resPath.name, infeasModels)
% resPathFeas = resPath(feasPaths);
[dietInfo, dietGrowthStats] = ensureWBMfeasibility(resPath, 'Diet', Diet, 'solver', solver);

if any(dietGrowthStats(:, 2) == false)
    disp("All models were found to be feasible on the given diet")
elseif any(dietGrowthStats(:, 3) == false)
    disp("Some models were not feasible on the given and some adjustments" + newline + ...
        "were made to ensure feasibility, the adjustments are stored in ...:ADD")
elseif any(dietGrowthStats(:, 4) == false)
    disp("Some models were found that were not feasible on any diet,..." + newline + ...
        "they are listed in the file: dietGrowthStats in the same folder as your iWBMs")
end

if numModels > 0
    clear persParamCurrent persParamMCurrent dataCurrent missing
    if personalisingPhys == 1 && ~metadataStruct
        % Update some table headers for clarity
        oldNames = { ...
            'MConUrCreatinineMax', 'MConUrCreatinineMin', 'MConDefaultBc', ...
            'MConDefaultCSF', 'MConDefaultUrMax', 'MConDefaultUrMin'};
        newNames = { ...
            'Max conc of creatinine in the urine', ...
            'Min conc of creatinine in the urine', ...
            'Max conc of a metabolite in the blood plasma', ...
            'Max conc of a metabolite in the CSF', ...
            'Max conc of a metabolite in the urine', ...
            'Min conc of a metabolite in the urine'};
        
        for k = 1:numel(oldNames)
            i = strcmp(paramSource.Properties.VariableNames, oldNames{k});
            if any(i), paramSource.Properties.VariableNames{i} = newNames{k}; end
            
            j = strcmp(persParams.Properties.VariableNames, oldNames{k});
            if any(j), persParams.Properties.VariableNames{j} = newNames{k}; end
        end
        
        
        % Join descriptor row with the calculation detail of the parameter
        paramSourceC = [paramSource.Properties.VariableNames; table2cell(paramSource)];
        persParamsC = [persParams.Properties.VariableNames; table2cell(persParams)];
        % Check headers match (or reconcile manually if needed)
        % Here, just concatenate assuming same headers
        persParamsC = [paramSourceC; persParamsC(2:end,:)];  % skip second header rows
        
    end
    excelFilename = fullfile(resPath, 'persParameters.xlsx');
    %% Save an excel file with a summary of all changes made to all models
    if personalisingPhys == 1 && personalisingMets == 1
        writecell(persParamsC, excelFilename, 'Sheet', 'PhysiologicalParameters');
        writetable(persParamsM, excelFilename, 'Sheet', 'MetabolomicParameters');
    elseif personalisingPhys == 1 && ~metadataStruct
        writecell(persParamsC, excelFilename, 'Sheet', 'PhysiologicalParameters');
    elseif personalisingMets == 1
        writetable(persParamsM, excelFilename, 'Sheet', 'MetabolomicParameters');
    end
    
end
% assign output for persParams
if exist('persParamsC', 'var') && exist('persParamsM', 'var')
    persParams = struct('PhysiologicalParams', persParamsC,'MetabolomicParams', persParamsM);
elseif exist('persParamsC', 'var')
    persParams = persParamsC;
elseif exist('persParamsM', 'var')
    persParams = persParamsM;
else
    persParams = {};
end
end
