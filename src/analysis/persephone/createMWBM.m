function  modelHM = createMWBM(microbiota_model, WBM_model, Diet, saveDir)
% This function creates personalised host-microbiome WBM models by joining
% microbiome community models with unpersonalised WBM models. The models
% are parameterised on a predefined diet.
%
% Example: modelHM = createMWBM(microbiota_model, WBM_model, 'EUAverageDiet')
%
% INPUTS
% microbiota model:             Microbiome community model created by the
%                               microbiome modelling toolbox.
% WBM_model:                    Harvey or Harvetta whole-body metabolic
%                               model
% Diet                          Diet option: 'EUAverageDiet' (default)
%
% Output
% modelHM:                      Personalised host-microbiome WBM model
%
% Authors:  Tim Hensen, Bronson Weston, 2022
%           Tim Hensen, expanded WBM parameterisation July 2024
%           Tim Hensen, improved mWBM annotation November 2024

if nargin < 4
    saveDir = '';
end


%%% Step 1: Combine WBM and microbiota model %%%

% Combine whole-body model with microbiota and add sex information
switch WBM_model.sex
    case 'male'
        modelHM = combineHarveyMicrotiota(WBM_model, microbiota_model, 400);
    case 'female'
        modelHM = combineHarveyMicrotiota(WBM_model, microbiota_model, 400);
end


%%% Step 2: Add diet to model %%%
factor = 1; % Percentage of the provided diet to be added.
modelHM = setDietConstraints(modelHM, Diet, factor);


%%% Step 3: Populate model setup information for tracktability %%%

% Add sex info
modelHM.SetupInfo.sex = WBM_model.sex;
modelHM.sex = string(WBM_model.sex); % For PSCM toolbox interoperability

% Add WBM version information 
modelHM.SetupInfo.WBM_version = WBM_model.version;

% Add WBM annotations
modelHM.SetupInfo.modelAnnotation = WBM_model.modelAnnotation;

% Add microbiota info in SetupInfo

% Find relative abundances
communityCoef = full(modelHM.S(:, contains(modelHM.rxns,'communityBiomass')));
        function  modelHM = createMWBM(microbiota_model, WBM_model, Diet, saveDir)
% This function creates personalised host-microbiome WBM models by joining
% microbiome community models with unpersonalised WBM models. The models
% are parameterised on a predefined diet.
%
% Example: modelHM = createMWBM(microbiota_model, WBM_model, 'EUAverageDiet')
%
% INPUTS
% microbiota model:             Microbiome community model created by the
%                               microbiome modelling toolbox.
% WBM_model:                    Harvey or Harvetta whole-body metabolic
%                               model
% Diet                          Diet option: 'EUAverageDiet' (default)
%
% Output
% modelHM:                      Personalised host-microbiome WBM model
%
% Authors:  Tim Hensen, Bronson Weston, 2022
%           Tim Hensen, expanded WBM parameterisation July 2024
%           Tim Hensen, improved mWBM annotation November 2024

if nargin < 4
    saveDir = '';
end


%%% Step 1: Combine WBM and microbiota model %%%

% Combine whole-body model with microbiota and add sex information
switch WBM_model.sex
    case 'male'
        modelHM = combineHarveyMicrotiota(WBM_model, microbiota_model, 400);
    case 'female'
        modelHM = combineHarveyMicrotiota(WBM_model, microbiota_model, 400);
end


%%% Step 2: Add diet to model %%%
factor = 1; % Percentage of the provided diet to be added.
modelHM = setDietConstraints(modelHM, Diet, factor);


%%% Step 3: Populate model setup information for tracktability %%%

% Copy the setup info from the original WBM
modelHM.SetupInfo = WBM_model.SetupInfo;

% Add sex info
modelHM.SetupInfo.sex = WBM_model.sex;
modelHM.sex = string(WBM_model.sex); % For PSCM toolbox interoperability

% Add WBM version information 
modelHM.SetupInfo.WBM_version = WBM_model.version;

% Add WBM annotations
modelHM.SetupInfo.modelAnnotation = WBM_model.modelAnnotation;

% Add microbiota info in SetupInfo

% Find relative abundances
communityCoef = full(modelHM.S(:, contains(modelHM.rxns,'communityBiomass')));
        
% Find the negative coefficients, i.e., the pan taxon biomass
% metabolites [c] and obtain taxa names.
microbiotaInfo = table();
microbiotaInfo.Microbes = erase(modelHM.mets(communityCoef < 0),'_biomass[c]');

% Find their relative abundance in percentages
microbiotaInfo.relativeAbundances = -(communityCoef(communityCoef < 0));

% Add data to table
modelHM.SetupInfo.MicrobiotaComposition = microbiotaInfo;


%%% Step 3: Set model ID %%%

% If the provided WBM_model was personalised using physiological or
% metabolomic data, the model will have a field "ID" containing the sample
% ID and the "iWBM" indication. iWBM models will be updated as muiWBM
% models. Unpersonalised WBMs will be updated to mWBM. 

% Check if iWBMs are used by looking if modelHM.SetupInfo.Status is set to
% personalised. If so then we save the model as miWBM
mWBMtrue = true;
if isfield(modelHM.SetupInfo, 'Status')
    if strcmpi(modelHM.SetupInfo.Status, 'personalised')
        modelHM.ID = ['miWBM_' char(microbiota_model.name)];
        mWBMtrue = false;
    end
end

% If the field is modelHM.SetupInfo.Status is not set to personalised we
% save the model as mWBM
if mWBMtrue == true
    modelHM.ID = ['mWBM_' char(microbiota_model.name)];
end

%%% Step 4: Parameterise the model for analysis %%% 

% enforce microbial growth (i.e., microbal fecal excretion)
modelHM = changeRxnBounds(modelHM, 'Excretion_EX_microbiota_LI_biomass[fe]', 1, 'b');

% Enforce body weight maintenance
modelHM = changeRxnBounds(modelHM, 'Whole_body_objective_rxn', 1, 'b');

% Set whole-body objective reaction
modelHM = changeObjective(modelHM, {'Whole_body_objective_rxn'}, 1);

% Set direction of optimisation
modelHM.osenseStr = 'max';

if ~isempty(saveDir)
    % Generate path to save model
    savePath = [char(saveDir) filesep modelHM.ID '_' char(modelHM.sex) '.mat'];
    % Save model
    model = modelHM;
    save(savePath,'-struct','model')
end

end

% Find the negative coefficients, i.e., the pan taxon biomass
% metabolites [c] and obtain taxa names.
microbiotaInfo = table();
microbiotaInfo.Microbes = erase(modelHM.mets(communityCoef < 0),'_biomass[c]');

% Find their relative abundance in percentages
microbiotaInfo.relativeAbundances = -(communityCoef(communityCoef < 0));

% Add data to table
modelHM.SetupInfo.MicrobiotaComposition = microbiotaInfo;


%%% Step 3: Set model ID %%%

% If the provided WBM_model was personalised using physiological or
% metabolomic data, the model will have a field "ID" containing the sample
% ID and the "iWBM" indication. iWBM models will be updated as muiWBM
% models. Unpersonalised WBMs will be updated to mWBM. 

% Check if the ID field with iWBM exists.
addIDfield = true;
if isfield(WBM_model,'ID')
    if contains(WBM_model.ID,'iWBM')
        addIDfield = false;
    end
end

% Add mWBM in a new ID field or update the ID field with mWBM
if addIDfield == true 
    modelHM.ID = ['mWBM_' char(microbiota_model.name)];
else
    modelHM.ID = ['m' char(WBM_model.ID)];
end


%%% Step 4: Parameterise the model for analysis %%% 

% enforce microbial growth (i.e., microbal fecal excretion)
modelHM = changeRxnBounds(modelHM, 'Excretion_EX_microbiota_LI_biomass[fe]', 1, 'b');

% Enforce body weight maintenance
modelHM = changeRxnBounds(modelHM, 'Whole_body_objective_rxn', 1, 'b');

% Set whole-body objective reaction
modelHM = changeObjective(modelHM, {'Whole_body_objective_rxn'}, 1);

% Set direction of optimisation
modelHM.osenseStr = 'max';

if ~isempty(saveDir)
    % Generate path to save model
    savePath = [char(saveDir) filesep modelHM.ID '_' char(modelHM.sex) '.mat'];
    % Save model
    model = modelHM;
    save(savePath,'-struct','model')
end

end
