% This script creates pairwise models in every combination for a set of
% five provided single microbe reconstructions as an example. The example
% reconstructions are found in the zipped file
% "AGORAExampleReconstructions".
% The script can be expanded to any number of microbes to be paired, or
% parts of the script can be used for pairing two microbes only.
% Please cite "Magnusdottir, Heinken et al., Nat Biotechnol. 2017 35(1):81-89"
% if you use this script for your own analysis.

% Almut Heinken 15.03.2017

% first create an input file with the information on the five example
% microbes to be paired - five AGORA reconstructions (version 1.0) with
% strain names and the reaction abbreviation of the respective biomass
% objective function. The input filr needs to be adapted for different
% reconstructions according to individual reaction names.

InfoFile = {
    'Model_ID'    'Strain'  'BOF_Abbr'
    'Abiotrophia_defectiva_ATCC_49176'  'Abiotrophia defectiva ATCC 49176'  'biomass082'
    'Acidaminococcus_fermentans_DSM_20731'  'Acidaminococcus fermentans DSM 20731'  'biomass363'
    %'Acidaminococcus_intestini_RyC_MR95'    'Acidaminococcus intestini RyC-MR95'  'biomass318'
    %'Acidaminococcus_sp_D21'    'Acidaminococcus sp. D21'   'biomass473'
    %'Acinetobacter_calcoaceticus_PHEA_2'    'Acinetobacter calcoaceticus PHEA-2'    'biomass236'
    };

pairedModelsList{1, 1} = 'pairedModelID';
pairedModelsList{1, 2} = 'ModelID1';
pairedModelsList{1, 3} = 'Strain1';
pairedModelsList{1, 4} = 'Biomass1';
pairedModelsList{1, 5} = 'ModelID2';
pairedModelsList{1, 6} = 'Strain2';
pairedModelsList{1, 7} = 'Biomass2';
modelList = 2;
for i = 2:size(InfoFile, 1)
    load(strcat(InfoFile{i, 1}, '.mat'));
    % name the first model "model1" by default
    model1 = model;
    % make sure pairs are only generated once ("microbe1_microbe2" and
    % "microbe2_microbe1" are the same pairwise model and thus only one is created)
    % also make sure models aren't paired with themselves
    for j = i + 1:size(InfoFile, 1)
         load(strcat(InfoFile{j, 1}, '.mat'));
        % name the second model "model2 by default
        model2 = model;
        % script "createMultiSpeciesModel" will join the two microbes
        % need to create file with the two models and two corresponding
        % name tags as input for createMultipleSpeciesModel
        models{1, 1} = model1;
        models{2, 1} = model2;
        nameTagsModels{1, 1} = strcat(InfoFile{i, 1}, '_');
        nameTagsModels{2, 1} = strcat(InfoFile{j, 1}, '_');
        % use the function createMultipleSpeciesModel with the required
        % inputs
        [pairedModel] = createMultipleSpeciesModel(models, nameTagsModels);

        % create coupling constraints: the reactions of each individual
        % microbe need to be coupled to its own biomass objective function.
        % For this, it is necessary to find all reactions in each paired
        % microbe by looking for the name tags each microbe received (see
        % "nameTagsModels" above). The biomass objective function is also
        % found by retrieving the name tag + name of the biomass objective
        % function. The coupling factor c here is 400 with a threshold u of
        % 0, this may be edited as convenient.

        [pairedModel] = coupleRxnList2Rxn(pairedModel, pairedModel.rxns(strmatch(strcat(InfoFile{i, 1}, '_'), pairedModel.rxns)), strcat(InfoFile{i, 1}, '_', InfoFile{i, 3}), 400, 0);
        [pairedModel] = coupleRxnList2Rxn(pairedModel, pairedModel.rxns(strmatch(strcat(InfoFile{j, 1}, '_'), pairedModel.rxns)), strcat(InfoFile{j, 1}, '_', InfoFile{j, 3}), 400, 0);

        save(strcat('pairedModel', '_', InfoFile{i, 1}, '_', InfoFile{j, 1}, '.mat'), 'pairedModel');

        % keep track of the generated models
        pairedModelsList{modelList, 1} = strcat('pairedModel', '_', InfoFile{i, 1}, '_', InfoFile{j, 1}, '.mat');
        pairedModelsList{modelList, 2} = InfoFile{i, 1};
        pairedModelsList{modelList, 3} = InfoFile{i, 2};
        pairedModelsList{modelList, 4} = InfoFile{i, 3};
        pairedModelsList{modelList, 5} = InfoFile{j, 1};
        pairedModelsList{modelList, 6} = InfoFile{j, 2};
        pairedModelsList{modelList, 7} = InfoFile{j, 3};
        modelList = modelList + 1;
    end
end
save pairedModelsList  pairedModelsList;
