function [iWBM, iWBMcontrol, personalisationOverview] = persWBMetabolomics(sex, metabolomicParams, varargin)
% Create metabolomically personalised whole-body models (WBMs) from metabolite data
%
% Takes metabolomic parameters for one or several individuals and adjusts the
% metabolite constraints of a provided WBM (or of Harvey/Harvetta) to create a
% personalised WBM. When supplied as a table, the sample and metabolite names
% are read from `metabolomicParams.Properties.VariableNames`.
%
% USAGE:
%
%    [iWBM, iWBMcontrol, personalisationOverview] = persWBMetabolomics(sex, metabolomicParams, varargin)
%
% INPUTS:
%    sex:                 string, sex of the subject(s) ("male" or "female")
%    metabolomicParams:    metabolomic parameters as a cell array, a table, or a
%                         path to an Excel file. Each column holds the
%                         metabolite concentrations for one individual, with
%                         the compartment and unit given in the leading rows
%
% OPTIONAL INPUTS (name-value pairs in varargin):
%    iWBM:           an already physiologically personalised WBM to further
%                    personalise (default '')
%    iWBMcontrol:    a control WBM to carry through unchanged (default '')
%    resPath:        path in which to store the personalised model and outputs
%                    (default the current directory)
%    Diet:           diet in the form of a text file or named `.mat` file from
%                    the COBRA toolbox (default 'EUAverageDietNew')
%
% OUTPUTS:
%    iWBM:                       model with updated metabolite constraints
%                                (updated parameters described in
%                                `model.IndividualisedParameters`)
%    iWBMcontrol:                control WBM with no personalised adjustments
%    personalisationOverview:    table summarising, per individual and biofluid,
%                                the metabolite min/max concentrations applied
%
% .. Author: - Anna Sheehy, November 2024

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
        if strcmp(comp, '[bc]')||strcmp(comp, 'blood')
            % Append to blood table
            dataBC = [dataBC; {met, Conc_umolL * 0.8, Conc_umolL * 1.2}];
        elseif strcmp(comp, '[u]')||strcmp(comp, 'urine')
            % Append to urine table
            dataU = [dataU; {met, Conc_umolL * 0.8, Conc_umolL * 1.2}];
        elseif strcmp(comp, '[csf]')||strcmp(comp, 'csf')||strcmp(comp, 'cerebrospinalfluid')
            % Append to CSF table
            dataCSF = [dataCSF; {met, Conc_umolL * 0.8, Conc_umolL * 1.2}];
        else
            error('No valid compartment found in input data for personalising metabolites. Please indlude an extra column in your input with blood, urine or csf')
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