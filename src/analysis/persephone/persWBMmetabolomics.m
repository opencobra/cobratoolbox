function [iWBM, iWBMcontrol, personalisationOverview] = persWBMetabolomics(sex, metabolomicParams, varargin)
%
%
% This function takes a table of metabolomic parameters for an individual or multiple individuals
% (listed in inputs) and adjusts the paramteres of a provided WBM or Harvey/Harvetta to
% create a personalised WBM
%
% The calculation of metabolomic parameteres will be performed based on
% the available data 
%
% INPUTS
%
% REQUIRED:
% metabolomicParamters         Can be a cell array or a table or a path to an
%                              excel file. In any case, this should contain
%                              a list with a minimum of three columns and option
%                              for additional columns for each individual for which a model should be created:
%
%                              |"ID"              |"glucose"    |"HC0192"  |
%                              ----------------------------------------------
%                              |"compartment"    |"blood"       |"urine"   |
%                              |"unit"           |"mg/dL"       | "mg/dL"  |                
%                              |"Individual1"    |180           |50        |
%                              |"Individual2"    |150           |66        |
%
%
%                              Sex must be provided for each model. The compartment must be specified and must be
%                              one of the following: csf, u, blParameters that can be personalised include:
%                              All of those metabolites which are found in
%                              the
%                              *for each the default unit used by the model
%                              is provided. For x, y, z- unit conversion
%                              will be performed for all known common units of
%                              measurement.
%
%
% OPTIONAL:
% WBM/(s)                     User can provide a WBM (Whole Body Metabolic Model) or a path to multiple models.
%                             If no model is provided, either Harvey or Harvetta will be loaded from the COBRA
%                             toolbox, depending on sex in provided physiological data.
%                             If multiple models are provided, the model ID must
%                             match the model name provided in the physiological data.
% resPath                     Path on which to store personalised model and
%                             other outputs.
%                             Default = current directory
% Diet                        Diet in the form of text file or named .mat
%                             file from the COBRA toolbox (default =
%                             EUAverageDiet)
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
%% Step One: Read in the available data, check all data is valid
% Define the input parser
parser = inputParser();

% Add required inputs (based on your description)
addRequired(parser, 'metabolomicParams', @(x) ischar(x) || iscell(x) || istable(x));

% Add optional parameters
addParameter(parser, 'iWBM', '', @(x) isstruct(x));
addParameter(parser, 'iWBMcontrol', '', @(x) isstruct(x));
addParameter(parser, 'resPath', pwd, @ischar);
addParameter(parser, 'Diet', 'EUAverageDietNew', @iscell);

% Parse required and optional inputs
parse(parser, metabolomicParams, varargin{:});

% Access the parsed inputs
metabolomicParams = parser.Results.metabolomicParams;
iWBM = parser.Results.iWBM;
iWBMcontrol = parser.Results.iWBMcontrol;
resPath = parser.Results.resPath;
Diet = parser.Results.Diet;

if ~isempty(parser.Results.iWBM)
    modelID = iWBM.ID;
elseif ~isempty(parser.Results.iWBMcontrol)
    modelID = iWBMcontrol.ID;
else 
    error('No model provided')
end

Type = 'direct';

% if control, skip to end
if isempty(parser.Results.iWBMcontrol)
    %% Collect MW for all metabolites
    DB = loadVMHDatabase();
    % Obtain molecular weights using computeMW and create table of metabolite name and moleceular weight
    formulae = DB.metabolites(~cellfun('isempty', DB.metabolites(:, 4)), 4); % Remove empty entries
    emptyIdx = find(cellfun('isempty', DB.metabolites(:, 4))); % Indices of original empty entries
    MW = getMolecularMass(formulae);
    metIDs = DB.metabolites(:, 1);
    metIDs(emptyIdx) = [];
    
    % Create the table
    AllMolecularWeights = table(metIDs, formulae, MW);
    %% Step Five: Update constraints based on new physiological parameters and biomass
    IndividualParameters = iWBM.SetupInfo.IndividualParameters;
    % Initialize tables for blood, urine, and CSF metabolites
    dataBC = {'met', 'minCon', 'maxCon'};
    dataU = {'met', 'minCon', 'maxCon'};
    dataCSF = {'met', 'minCon', 'maxCon'};
    
    for m=1:size(metabolomicParams, 2)-1
        met = metabolomicParams.Properties.VariableNames{m+1};
        idx = find(strcmp(lower(AllMolecularWeights.metIDs), lower(met)));
        MW = AllMolecularWeights.MW(idx);
        if isempty(MW)||MW == 0||isnan(MW)
            error('MW for %s unavailable in VMH database- please check metabolite name matched name on vmh.life', met);
        end
        % convert units if needed
        % CONVERT TO MICROMOLE PER LITER
        % Determine the unit
        unit = string(metabolomicParams{1, m+1});
        if isempty(unit)
            error('Unit is missing for metabolite %s', met);
        end
        Conc = cell2mat(metabolomicParams{2, m+1});
        switch unit
            case {'µmol/L', 'umol/L', 'uM'}
                Conc_umolL = Conc;
            case 'mg/dL'
                Conc_umolL = Conc*10^4/MW;
            case 'g/dL'
                Conc_umolL = Conc*10^7/MW;
            case 'pg/mL'
                Conc_umolL = Conc/MW;
            case 'mmol/L'
                Conc_umolL = Conc*10^3;
            case 'ng/dL'
                Conc_umolL = Conc*10^2/MW;
            otherwise
                error('Unknown unit: %s', unit);
        end
        comp = string(metabolomicParams{3, m+1});
        if strcmp(comp, 'blood')
            % Append to blood table
            dataBC = [dataBC; {met, Conc_umolL * 0.8, Conc_umolL * 1.2}];
        elseif strcmp(comp, 'urine')
            % Append to urine table
            dataU = [dataU; {met, Conc_umolL * 0.8, Conc_umolL * 1.2}];
        else
            % Append to CSF table
            dataCSF = [dataCSF; {met, Conc_umolL * 0.8, Conc_umolL * 1.2}];
        end
        
    end
    
   personalisationOverview = cell(0, 5); 
   if size(dataBC, 1) > 1
        iWBM = physiologicalConstraintsHMDBbased(iWBM, IndividualParameters, '',Type , dataBC, 'bc');
        personalisationOverview = [personalisationOverview; [repmat({modelID}, size(dataBC, 1) - 1, 1), repmat({'bc'}, size(dataBC, 1) - 1, 1), dataBC(2:end, :), ]];
    end
    
    if size(dataU, 1) > 1
        iWBM = physiologicalConstraintsHMDBbased(iWBM, IndividualParameters, '',Type , dataU, 'u');
        personalisationOverview = [personalisationOverview; [repmat({modelID}, size(dataU, 1) - 1, 1), repmat({'u'}, size(dataU, 1) - 1, 1), dataU(2:end, :)]];
    end
    
    if size(dataCSF, 1) > 1
        iWBM = physiologicalConstraintsHMDBbased(iWBM, IndividualParameters, '',Type , dataCSF, 'csf');
        personalisationOverview = [personalisationOverview; [repmat({modelID}, size(dataCSF, 1) - 1, 1), repmat({'csf'}, size(dataCSF, 1) - 1, 1), dataCSF(2:end, :)]];
    end
    
 
    % Convert to table if needed
    personalisationOverview = cell2table(personalisationOverview, 'VariableNames', {'ID', 'biofluid', 'met', 'min concentration', 'max concentration'});
else
    % Run the control through the same process
    dataE = {'ID', 'min concentration', 'max concentration'};
    IndividualParameters = iWBMcontrol.SetupInfo.IndividualParameters;
    iWBMcontrol = physiologicalConstraintsHMDBbased(iWBMcontrol, IndividualParameters, '',Type , dataE, 'bc');
    iWBMcontrol = physiologicalConstraintsHMDBbased(iWBMcontrol, IndividualParameters, '',Type , dataE, 'u');
    iWBMcontrol = physiologicalConstraintsHMDBbased(iWBMcontrol, IndividualParameters, '',Type , dataE, 'csf');
    
    %Save the description of parameter updates and parameter calculation
    personalisationOverview = dataE;
end