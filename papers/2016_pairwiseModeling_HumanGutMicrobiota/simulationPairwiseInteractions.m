% This script predicts the outcomes of pairwise simulations in every
%  combination for a set of ten pairwise models as an example. The pairwise
%  models need to be created first with the script buildPairwiseModels.
% The script can be expanded to any number of pairwise models, or
% parts of the script can be used for simulating only one pair.
% In this case, two diets are simulated without and with oxygen, any other
% number and kind of simulation conditions may be applied by setting the
% appropriate constraints.
% This script requires the COBRA Toolbox function solceCobraLPCPLEX and the
% TOMLAB Cplex solver. Due to the coupling constraints on the pairwise
% models, the simulations cannot currently be run with optimizeCbModel.
% Please cite "Magnusdottir, Heinken et al., Nat Biotechnol. 2017 35(1):81-89"
% if you use this script for your own analysis.

% Almut Heinken 15.03.2017

% four simulation conditions-set

conditions = {
    %'WesternDiet_NoOxygen'
    'WesternDiet_WithOxygen'
    'HighFiberDiet_NoOxygen'
    'HighFiberDiet_WithOxygen'
};

% load the script with the information on pairwise models created in script
% buildPairwiseModels
load pairedModelsList;

for k = 1:length(conditions)
    pairedGrowthResults = {};
    pairedGrowthResults{1, 1} = 'pairedModelID';
    pairedGrowthResults{1, 2} = 'Species1';
    pairedGrowthResults{1, 3} = 'ModelID1';
    pairedGrowthResults{1, 4} = 'Species2';
    pairedGrowthResults{1, 5} = 'ModelID2';
    pairedGrowthResults{1, 6} = 'pairedGrowth_Species1';
    pairedGrowthResults{1, 7} = 'pairedGrowth_Species2';
    pairedGrowthResults{1, 8} = 'singleGrowth_Species1';
    pairedGrowthResults{1, 9} = 'singleGrowth_Species2';
    pairedGrowthResults{1, 10} = 'Outcome_Species1';
    pairedGrowthResults{1, 11} = 'Outcome_Species2';
    pairedGrowthResults{1, 12} = 'Total_Outcome';
    for i = 2:size(pairedModelsList, 1)
        % load each paired model
        load(pairedModelsList{i, 1});
        % for each paired model, set both biomass objective functions as
        % objectives
        biomass1 = strcat(pairedModelsList{i, 2}, '_', pairedModelsList{i, 4});
        biomass2 = strcat(pairedModelsList{i, 5}, '_', pairedModelsList{i, 7});
        model1biomass = find(ismember(pairedModel.rxns, biomass1));
        pairedModel.c(model1biomass, 1) = 1;
        model2biomass = find(ismember(pairedModel.rxns, biomass2));
        pairedModel.c(model2biomass, 1) = 1;
        % enforce minimal growth
        pairedModel = changeRxnBounds(pairedModel, biomass1, 0.001, 'l');
        pairedModel = changeRxnBounds(pairedModel, biomass2, 0.001, 'l');
        % assign medium
        if k == 1
            % Western diet without oxygen
            pairedModel = useDiet_AGORA_pairedModels(pairedModel, 'Western');
        elseif k == 2
            % Western diet with oxygen
            pairedModel = useDiet_AGORA_pairedModels(pairedModel, 'Western');
            pairedModel = changeRxnBounds(pairedModel, 'EX_o2[u]', -10, 'l');
        elseif k == 3
            % High fiber diet without oxygen
            pairedModel = useDiet_AGORA_pairedModels(pairedModel, 'HighFiber');
        elseif k == 4
            % High fiber diet with oxygen
            pairedModel = useDiet_AGORA_pairedModels(pairedModel, 'HighFiber');
            pairedModel = changeRxnBounds(pairedModel, 'EX_o2[u]', -10, 'l');
        end
        % calculate joint biomass
        solutionPaired = solveCobraLP(pairedModel);  % solveCobraLPCPLEX(pairedModel,2,0,0,[],1e-6);
        % fill out the results table with the model information
        pairedGrowthResults{i, 1} = pairedModelsList{i, 1};
        pairedGrowthResults{i, 2} = pairedModelsList{i, 2};
        pairedGrowthResults{i, 3} = pairedModelsList{i, 3};
        pairedGrowthResults{i, 4} = pairedModelsList{i, 5};
        pairedGrowthResults{i, 5} = pairedModelsList{i, 6};

        % combined growth
        pairedGrowthResults{i, 6} = solutionPaired.full(model1biomass);
        pairedGrowthResults{i, 7} = solutionPaired.full(model2biomass);

        % separate growth
        % silence model 2 and optimize model 1
        % load the model again to avoid errors
        load(pairedModelsList{i, 1});
        pairedModel = changeObjective(pairedModel, biomass1);
        % disable flux through the second model
        pairedModel = changeRxnBounds(pairedModel, pairedModel.rxns(strmatch(strcat(pairedModelsList{i, 5}, '_'), pairedModel.rxns)), 0, 'b');
        % assign medium
        if k == 1
            % Western diet without oxygen
            pairedModel = useDiet_AGORA_pairedModels(pairedModel, 'Western');
        elseif k == 2
            % Western diet with oxygen
            pairedModel = useDiet_AGORA_pairedModels(pairedModel, 'Western');
            pairedModel = changeRxnBounds(pairedModel, 'EX_o2[u]', -10, 'l');
        elseif k == 3
            % High fiber diet without oxygen
            pairedModel = useDiet_AGORA_pairedModels(pairedModel, 'HighFiber');
        elseif k == 4
            % High fiber diet with oxygen
            pairedModel = useDiet_AGORA_pairedModels(pairedModel, 'HighFiber');
            pairedModel = changeRxnBounds(pairedModel, 'EX_o2[u]', -10, 'l');
        end
        % calculate single biomass
        solutionSingle1 = solveCobraLP(pairedModel);  % solveCobraLPCPLEX(pairedModel,2,0,0,[],1e-6);
        pairedGrowthResults{i, 8} = solutionSingle1.full(model1biomass);

        % silence model 1 and optimize model 2
        % load the model again to avoid errors
        load(pairedModelsList{i, 1});
        pairedModel = changeObjective(pairedModel, biomass2);
        % disable flux through the first model
        pairedModel = changeRxnBounds(pairedModel, pairedModel.rxns(strmatch(strcat(pairedModelsList{i, 2}, '_'), pairedModel.rxns)), 0, 'b');
        % assign medium
        if k == 1
            % Western diet without oxygen
            pairedModel = useDiet_AGORA_pairedModels(pairedModel, 'Western');
        elseif k == 2
            % Western diet with oxygen
            pairedModel = useDiet_AGORA_pairedModels(pairedModel, 'Western');
            pairedModel = changeRxnBounds(pairedModel, 'EX_o2[u]', -10, 'l');
        elseif k == 3
            % High fiber diet without oxygen
            pairedModel = useDiet_AGORA_pairedModels(pairedModel, 'HighFiber');
        elseif k == 4
            % High fiber diet with oxygen
            pairedModel = useDiet_AGORA_pairedModels(pairedModel, 'HighFiber');
            pairedModel = changeRxnBounds(pairedModel, 'EX_o2[u]', -10, 'l');
        end
        % calculate single biomass
        solutionSingle2 = solveCobraLP(pairedModel);  % solveCobraLPCPLEX(pairedModel,2,0,0,[],1e-6);
        pairedGrowthResults{i, 9} = solutionSingle2.full(model2biomass);

        % Analysis of the results

        % define what counts as significant difference-here 10% (may be
        % changed if desired)
        sigD = 0.1;

        % first make sure that infeasible solutions are flagged
        if solutionPaired.stat == 0 || solutionSingle1.stat == 0 || solutionSingle2.stat == 0
            pairedGrowthResults{i, 10} = 'Infeasible';
            pairedGrowthResults{i, 11} = 'Infeasible';
            pairedGrowthResults{i, 12} = 'Infeasible';
        else
            %% function to interpret pairwise interactions
            [iAFirstSpecies, iASecondSpecies, iATotal] = analyzePairwiseInteractions(pairedGrowthResults{i, 6}, pairedGrowthResults{i, 7}, pairedGrowthResults{i, 8}, pairedGrowthResults{i, 9}, sigD);
            pairedGrowthResults{i, 10} = iAFirstSpecies;
            pairedGrowthResults{i, 11} = iASecondSpecies;
            pairedGrowthResults{i, 12} = iATotal;
        end
    end
    save(strcat('pairedGrowthResults_', conditions{k}), 'pairedGrowthResults');
end
