function [iWBM, iWBMcontrol_female, iWBMcontrol_male, persParams] = persWBM(metadataPath, varargin)
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
% metadata                     Can be a cell array or a table or a path to an
%                              excel file. In any case, this should contain
%                              a list with a minimum of three column and option
%                              for additional columns for each individual for which a model should be created:

%
%                              |"ID"              |"Sex"    |"CardiacOutput"|
%                              ----------------------------------------------
%                              |"unit"           |""        | "mg/dL"       |
%                              |"Individual1"    |"male"    |5345           |
%                              |"Individual2"    |"female"  |5360           |
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
% femaleWBM                   A female WBM (Whole Body Metabolic Model).
%                             for any female subject detailed in the
%                             metadata, this model will be personalised.
%                             If no model is provided, either Harvey or Harvetta will be loaded from the COBRA
%                             toolbox, depending on sex in provided physiological data.
%                             If multiple models are provided, the model ID must
%                             match the model name provided in the
%                             physiological data.
% maleWBM                     A male WBM (Whole Body Metabolic Model).
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
%
% OUTPUTS
%
% iWBM                        Model with updated physiological paramteres
%                             (stored as "persModelName.mat"). All updated
%                             paramteres are described in
%                             model.IndividualisedParameters
% controlWBM                  This is a WBM with no personalised
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
% Add required inputs (based on your description)
addRequired(parser, 'metadataPath', @ischar);

% Add optional parameters
addParameter(parser, 'persPhysiology',{}, @iscell);
addParameter(parser, 'femaleWBM', '', @(x) isstruct(x));
addParameter(parser, 'maleWBM', '', @(x) isstruct(x));
addParameter(parser, 'resPath', pwd, @ischar);
addParameter(parser, 'persMetabolites',{}, @iscell);
addParameter(parser, 'Diet', '', @ischar);
addParameter(parser, 'solver', 'glpk', @ischar);

% Parse required and optional inputs
parse(parser, metadataPath, varargin{:});

% Access the parsed inputs
metadataPath = parser.Results.metadataPath;
persPhysiology = parser.Results.persPhysiology;
femaleWBM = parser.Results.femaleWBM;
maleWBM = parser.Results.maleWBM;
resPath = parser.Results.resPath;
persMetabolites = parser.Results.persMetabolites;
Diet = parser.Results.Diet;
solver = parser.Results.solver;

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


if ~exist('Diet', 'var') || isempty(Diet)
    EUAverageDietNew;
end
    
if ~ischar(metadataPath)
    error('metadata data does not satisfy the input requirments (iscell, ischar, istable)')
else
    Data = readMetadataForPersephone(metadataPath);
end


% Check Data has units stored in table properties
if ~strcmp('ID', Data.Properties.VariableNames{1})
    error('Please ensure column 1 of your metadata is ID and is labelled accordingly')
elseif isempty(Data.Properties.VariableUnits)
    error('Please ensure row 2 of your metadata contains units and is labelled accordingly')
else
end

AllParams = {
    'age'; ...
    'organ weight';...
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
    'glomerular filtration rate';...
    'blood flow for each organ'};

% Check that the data given matches the parameters that can be personalised
% Ensure male and female are not m and f, ensure column 1 is paramters and
% column 2 is units
% Data = processMetadata(Data);
% Check sex is in metadata
sex = cell2mat(strfind(lower(Data.Properties.VariableNames), 'sex'));
%
if sex == 0
    error("Sex info not found in metadata")
else
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
    disp(' > Physiological personalisation will be skipped (persPhysiology not provided as input)')
end

if ~isempty(parser.Results.persMetabolites)
    personalisingMets = true;
else
    personalisingMets = false;
    disp(' > Metabolomic personalisation will be skipped (persMetabolites not provided as input)')
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
    else
        iWBMcontrol_male = maleWBM;
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
    else
        iWBMcontrol_female = femaleWBM;
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

% Define file path and check existence
persParamsFile = fullfile(resPath, 'persParameters.xlsx');

if isfile(persParamsFile)
    [~, sheets] = xlsfinfo(persParamsFile); % Get sheet names
    % Load sheets if they exist
    if ismember('PhysiologicalParameters', sheets)
        persParamsCheck = true;
        persParams = readtable(persParamsFile, 'Sheet', 'PhysiologicalParameters');
        fprintf(' > Loaded %d PhysiologicalParameters entries.\n', height(persParams));
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


% extract units
units = cell2table(Data.Properties.VariableUnits);
units.Properties.VariableNames = Data.Properties.VariableNames;

for s = 1:size(Data, 1)
    if personalisingPhys == 1
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
        
        
        % ID
        if any(strcmp(lower(dataCurrent.Properties.VariableNames), 'id'))
            idxID = find(strcmp(lower(dataCurrent.Properties.VariableNames),'id'));
            ID = dataCurrent{2, idxID};
            IndividualParameters.ID = ID;
            WBMcurrent.ID = ID;
        end
        
        % BODY WEIGHT
        if any(strcmp(lower(dataCurrent.Properties.VariableNames),'body weight')) || any(strcmp(lower(dataCurrent.Properties.VariableNames),'weight'))
            idxWt = find(strcmp(lower(dataCurrent.Properties.VariableNames),'body weight'));
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
            elseif strcmp(currentUnit, "years")
                
            else
                error('Age not provided in a valid unit');
            end
            IndividualParameters.Age = Age;
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
        end
        
        
        % HEART RATE
        if any(strcmp(lower(dataCurrent.Properties.VariableNames),'heart rate'))
            idxHR = find(strcmp(lower(dataCurrent.Properties.VariableNames),'heart rate'));
            if size(idxHR, 2)>1
                error('More than one column header in the metadata contains the paramter heart rate!')
            end
            HR = cell2mat(dataCurrent{2, idxHR});
            currentUnit = dataCurrent{1, idxHR};
            if ~strcmp(currentUnit, "bpm")
                error('Heart rate must be provided in bpm');
            end
            IndividualParameters.HeartRate = HR;
        end
        
        % STROKE VOLUME
        if any(strcmp(lower(dataCurrent.Properties.VariableNames),'stroke volume'))
            idxSV = find(strcmp(lower(dataCurrent.Properties.VariableNames),'stroke volume'));
             if size(idxSV, 2)>1
                error('More than one column header in the metadata contains the paramter stroke volume!')
            end
            SV = cell2mat(dataCurrent{2, idxSV});
            currentUnit = dataCurrent{1, idxSV};
            if ~strcmp(currentUnit, "mL") && ~strcmp(currentUnit, "ml")
                error('Stroke volume must be provided in ml');
            end
            IndividualParameters.StrokeVolume = SV;
        end
        
        % CARDIAC OUTPUT
        if any(strcmp(lower(dataCurrent.Properties.VariableNames),'cardiac output'))
            idxCO = find(strcmp(lower(dataCurrent.Properties.VariableNames),'cardiac output'));
            if size(idxCO, 2)>1
                error('More than one column header in the metadata contains the paramter cardiac output!')
            end
            CO = cell2mat(dataCurrent{2, idxCO});
            currentUnit = dataCurrent{1, idxCO};
            if strcmp(currentUnit, "L/min")
                CO = CO*1000;
            elseif ~strcmp(currentUnit, "L/min")
                error("Cardiac Output Unit not valid")
            end
            IndividualParameters.CardiacOutput = CO;
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
            IndividualParameters.Creatinine = Cn;
        end
        
        % BLOOD FLOW RATE
        if any(strcmp(lower(dataCurrent.Properties.VariableNames),'blood flow rate'))
            idxBFR = find(strcmp(lower(dataCurrent.Properties.VariableNames),'blood flow rate'));
            if size(idxBFR, 2)>1
                error('More than one column header in the metadata contains the paramter blood flow rate!')
            end
            BFR = cell2mat(dataCurrent{2, idxBFR});
            currentUnit = dataCurrent{1, idxBFR};
            if ~strcmp(currentUnit, "mL/min")
                error('Blood flow rate must be provided in mL/min');
            end
            IndividualParameters.BloodFlowRate = BFR;
        end
        
        % GLOMERULAR FILTRATION RATE
        if any(strcmp(lower(dataCurrent.Properties.VariableNames),'glomerular filtration rate')) || any(strcmp(lower(dataCurrent.Properties.VariableNames),'gfr'))
            idxGFR = find(strcmp(lower(dataCurrent.Properties.VariableNames),'glomerular filtration rate'));
            if size(idxGFR, 2)>1
                error('More than one column header in the metadata contains the paramter glomerular filtration rate!')
            end
            GFR = cell2mat(dataCurrent{2, idxGFR});
            currentUnit = dataCurrent{1, idxGFR};
            if ~strcmp(currentUnit, "mL/min/1.73m^2")
                error('Glomerular Filtration rate must be provided in mL/min/1.73m^2');
            end
            IndividualParameters.GlomerularFiltrationRate = GFR;
        end
        
        % LEAN BODY MASS
        if any(strcmp(lower(dataCurrent.Properties.VariableNames),'lean body mass'))
            idxLBM = find(strcmp(lower(dataCurrent.Properties.VariableNames),'lean body mass'));
            if size(idxLBM, 2)>1
                error('More than one column header in the metadata contains the paramter lean body mass!')
            end
            LBM = cell2mat(dataCurrent{2, idxLBM});
            currentUnit = dataCurrent{1, idxLBM};
            if strcmp(currentUnit, "g")
                LBM = LBM / 1000; % Convert grams to kilograms
            elseif strcmp(currentUnit, "kg")
                % No conversion needed
            else
                error('Lean body mass must be provided in g or kg');
            end
            IndividualParameters.LeanBodyMass = LBM;
        end
        
        % BODY FAT PERCENTAGE
        if any(strcmp(lower(dataCurrent.Properties.VariableNames),'body fat'))
            idxBF = find(strcmp(lower(dataCurrent.Properties.VariableNames),'body fat'));
            if size(idxBF, 2)>1
                error('More than one column header in the metadata contains the paramter body fat!')
            end
            BF = cell2mat(dataCurrent{2, idxBF});
            currentUnit = dataCurrent{1, idxBF};
            if ~strcmp(currentUnit, '%') && strcmp(currentUnit, 'kg')
                BF = (BF /Wt)*100;
            elseif strcmp(currentUnit, 'g')
                BF = (BF/(Wt*1000))*100;
            elseif isempty(currentUnit)
                warning('Body weight (Wt) is in the wrong unit or conversion is not possible.');
            end
            IndividualParameters.BodyFat = BF;
        end
        
        clear idxAge idxBF idxBFR idxCn idxCO idxGFR idxHmt idxHR idxHt idxID idxLBM idxSex idxSV idxWt Age Col Cols cParam currentUnit Hmt Ht Numbers Wt
        %% Step 4: Conditional calculations:
        % 1. Estimate blood volume
        if strcmp(IndividualParameters.sex, 'male')
            IndividualParameters.BloodVolume = (0.3669 * (IndividualParameters.Height/100)^3 + 0.03219 * IndividualParameters.bodyWeight + 0.6041)*1000;
        elseif strcmp(IndividualParameters.sex, 'female')
            IndividualParameters.BloodVolume = (0.3561 * (IndividualParameters.Height/100)^3 + 0.03308 * IndividualParameters.bodyWeight + 0.1833)*1000;
        end
        
        % For now, 1 is hardcoded. Should update to check available
        % parameters and then accoordingly use the most accurate
        % calculation
        optionCardiacOutput =1;
        
        % 2. Estimate (resting) cardiac output from blood volume in case that no stroke volume is provided
        if optionCardiacOutput ~=-1 % skip adjustment of CO
                IndividualParameters.CardiacOutput = IndividualParameters.HeartRate * IndividualParameters.StrokeVolume; % in ml/min = beats/min * ml/beat
                IndividualParameters.CardiacOutput_Note = 'Calculated from personalized StrokeVolume and heart rate';
            elseif optionCardiacOutput == 1  
                % actually I think that it makes more sense to keep the cardiac output to
                % be calculated based on default strokevolume and heart rate
                IndividualParameters.CardiacOutput = IndividualParameters.HeartRate * IndividualParameters.StrokeVolume; % in ml/min = beats/min * ml/beat
                IndividualParameters.CardiacOutput_Note = 'Calculated from default StrokeVolume and heart rate';
            elseif optionCardiacOutput == 2
                IndividualParameters.StrokeVolume ='NaN';
                IndividualParameters.CardiacOutput = IndividualParameters.BloodVolume;
                IndividualParameters.CardiacOutput_Note = 'Estimated from BloodVolume'; % in ml/min = beats/min * ml/beat
            elseif optionCardiacOutput == 0
                % With the blood volume estimate the CO gets too low.
                % hence I used the equation given here:
                % http://www.ams.sunysb.edu/~hahn/psfile/pap_obesity.pdf
                % note that the weight here is given in kg rather than g
                
                Wt = IndividualParameters.bodyWeight;
                IndividualParameters.CardiacOutput = 9119-exp(9.164-2.91e-2*Wt+3.91e-4*Wt^2-1.91e-6*Wt^3);
                IndividualParameters.CardiacOutput_Note = 'Estimated from CO equation'; % in ml/min = beats/min * ml/beat
            elseif optionCardiacOutput == 3
                % from wikipedia: https://en.wikipedia.org/wiki/Fick_principle
                %     VO_2 = (CO \times\ C_a) - (CO \times\ C_v)
                % where CO = Cardiac Output, Ca = Oxygen concentration of arterial blood and Cv = Oxygen concentration of mixed venous blood.
                % Note that (Ca ? Cv) is also known as the arteriovenous oxygen difference.
                % Cardiac Output = (125 ml O2/minute x 1.9) / (200 ml O2/L - 150 ml O2/L) = 4.75 L/minute
                % can be refined to account for haemoglobin content
                IndividualParameters.CardiacOutput = ((IndividualParameters.VO2*1000)*60*24/(200 - 150));
                IndividualParameters.CardiacOutput_Note = 'Estimated from VO2 ';
            elseif optionCardiacOutput == 4 %
                %Cardiac Output = (125 ml O2/minute x 1.9) / (200 ml O2/L - 150 ml O2/L) = 4.75 L/minute
                % Various calculations have been published to arrive at the BSA without direct measurement. In the following formulae, BSA is in m2, W is mass in kg, and H is height in cm.
                % The most widely used is the Du Bois, Du Bois formula,[4][5] which has been shown to be equally as effective in estimating body fat in obese and non-obese patients, something the Body mass index fails to do.[6]
                % BSA=0.007184 * W^{0.425}* H^{0.725}}
                W = IndividualParameters.bodyWeight;
                H = IndividualParameters.Height;
                BSA=0.007184 * W^0.425* H^0.725 ;
                IndividualParameters.CardiacOutput = ((0.125*1000*BSA)*60*24/(200 - 150));
                IndividualParameters.CardiacOutput_Note = 'Estimated from surface area ';
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
            elseif  optionCardiacOutput == 6 %
                %estimation of stroke volume based on Frick
                % http://circ.ahajournals.org/content/circulationaha/14/2/250.full.pdf
                PP = 40; % pulse pressure
                DP = 80; % diatstolic blood pressure
                IndividualParameters.StrokeVolume = 91.0 + 0.54 * PP - 0.57*DP-0.61 *IndividualParameters.age ;
                IndividualParameters.CardiacOutput = IndividualParameters.HeartRate * IndividualParameters.StrokeVolume; % in ml/min = beats/min * ml/beat
            elseif  optionCardiacOutput == 7 %
                %estimation of stroke volume based on Bridwell
                % http://circ.ahajournals.org/content/circulationaha/14/2/250.full.pdf
                PP = 40; % pulse pressure
                DP = 80; % diatstolic blood pressure
                IndividualParameters.StrokeVolume = 66.0 + 0.34 * PP - 0.11*DP-0.36 *IndividualParameters.age ;
                IndividualParameters.CardiacOutput = IndividualParameters.HeartRate * IndividualParameters.StrokeVolume; % in ml/min = beats/min * ml/beat
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
                WBMcurrent = maleWBM;
            else
                WBMcurrent = femaleWBM;
            end
            iWBM = WBMcurrent;
            iWBM.SetupInfo.IndividualParameters = IndividualParameters;
            if any(strcmp(lower(Data.Properties.VariableNames), 'id'))
                idxID = find(strcmp(lower(Data.Properties.VariableNames),'id'));
                ID = Data{s, idxID};
                IndividualParameters.ID = ID;
            end
        end
        
        % match every metabolite in persMetabolites to the
        % correct compartment in DataCurrentM
        for m = 1:length(persMetabolites)
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

    else
    end
    
    
    %% Step 7: sanity check
    iWBM = setDietConstraints(iWBM, Diet);
    iWBM = changeRxnBounds(iWBM, 'Whole_body_objective_rxn', 1, 'b');
    iWBM.osenseStr = 'max';
    iWBM = changeObjective(iWBM, 'Whole_body_objective_rxn');
    FBA = optimizeWBModel(iWBM);
    fprintf(' > FBA for model %s complete: \n     FBA.stat = %f \n     origStatText = %s\n', ID, FBA.stat, FBA.origStat);
    IndividualParametersN.FBAstat{1, 1} = FBA.stat;
    IndividualParametersN.FBAorigStat{1, 1} = FBA.origStat;
    
    %% Step 8: Save the updated iWBM, controlWBM and personalisationOverview
    if exist('iWBM', 'var') && isstruct(iWBM)
        if personalisingPhys == 1 && personalisingMets == 1
            iWBM.status = 'iWBM personalised with physiological and metabolomic data';
        elseif personalisingPhys == 1
            iWBM.status = 'iWBM personalised with physiological data';
        elseif personalisingMets == 1
            iWBM.status = 'iWBM personalised with metabolomic data';
        else
            iWBM.status = 'iWBM not personalised';
        end
    else
        warning('iWBM does not exist or is not a structure. Status update skipped.');
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
            persParamCurrent.FBAstat = cell2mat(IndividualParametersN.FBAstat);
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
end

if numModels > 0
    clear persParamCurrent persParamMCurrent dataCurrent missing
    excelFilename = fullfile(resPath, 'persParameters.xlsx');
    %% Save an excel file with a summary of all changes made to all models
    if personalisingPhys == 1 && personalisingMets == 1
        writetable(persParams, excelFilename, 'Sheet', 'PhysiologicalParameters');
        writetable(persParamsM, excelFilename, 'Sheet', 'MetabolomicParameters'); 
    elseif personalisingPhys == 1
        writetable(persParams, excelFilename, 'Sheet', 'PhysiologicalParameters');
    elseif personalisingMets == 1
        writetable(persParamsM, excelFilename, 'Sheet', 'MetabolomicParameters');
    end
end
end