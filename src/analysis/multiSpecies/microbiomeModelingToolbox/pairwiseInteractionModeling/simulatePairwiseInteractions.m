function [pairwiseInteractions, pairwiseSolutions] = simulatePairwiseInteractions(pairedModels, pairedModelInfo, varargin)
% This function predicts the outcome of pairwise simulations in every
% combination from a given list of pairwise models. The pairwise models
% need to be created first with the function joinModelsPairwiseFromList.
% This script requires the COBRA Toolbox function solveCobraLP. Due to the
% coupling constraints on the pairwise models, the simulations cannot
% currently be run with optimizeCbModel.
% Below is a description of all possible consequences for the two joined
% organisms. Please note that the outcomes depend on the two genome-scale
% reconstructions joined and are highly dependent on the applied
% constraints.
%
% * Competition: both organisms grow slower in co-growth than separately
%   (same outcome for both).
%
% * Parasitism: one organism grows faster in co-growth than separately, while
%   the other grows slower in co-growth than separately. Outcome for
%   faster-growing organism: Parasitism_Taker, for slower-growing organism:
%   Parasitism_Giver
%
% * Amensalism: one organism's growth is unaffected by co-growth,  while
%   the other grows slower in co-growth than separately. Outcome for
%   unaffected organism: Amensalism_Unaffected, for slower-growing organism:
%   Amensalism_Affected
%
% * Neutralism: both organisms' growths are unaffected by co-growth (same
%   outcome for both)
%
% * Commensalism: one organism's growth is unaffected by co-growth,  while
%   the other grows fatser in co-growth than separately. Outcome for
%   unaffected organism: Commensalism_Giver, for slower-growing organism:
%   Commensalism_Taker
%
% * Mutualism: both organisms growth faster in co-growth than separately
%   (same outcome for both)
%
% USAGE:
%     [pairwiseInteractions, pairwiseSolutions] = simulatePairwiseInteractions(pairedModels, pairedModelInfo, varargin)
%
% INPUTS:
%     pairedModels:            Array of pairwise model structures to be simulated
%     pairedModelInfo:         Information on species joined in the pairwise models
%
% OPTIONAL INPUTS:
%     inputDiet:               Cell array of strings with three columns containing
%                              exchange reaction model abbreviations, lower bounds,
%                              and upper bounds.
%                              If no diet is input then the input pairwise models
%                              will be used with unchanged constraints.
%     saveSolutionsFlag:       If true, flux solutions are stored (may result in
%                              large output files)
%     numWorkers:              Number of workers in parallel pool if desired
%     sigD:                    Difference in growth rate that counts as significant
%                              change (by default: 10%)
%
% OUTPUTS:
%     pairwiseInteractions:    Table with computed pairwise and single growth
%                              rates for all entered microbe-microbe models
%
% OPTIONAL OUTPUT:
%     pairwiseSolutions:       Table with all computed flux solutions saved
%                              (may result in large output files)
%
% .. Authors:
%       - Almut Heinken, 02/2018

parser = inputParser();  % Parse input parameters
parser.addRequired('pairedModels', @iscell);
parser.addRequired('pairedModelInfo', @iscell);
parser.addParameter('inputDiet', {}, @iscell)
parser.addParameter('saveSolutionsFlag', false, @(x) isnumeric(x) || islogical(x))
parser.addParameter('numWorkers', 0, @(x) isnumeric(x))
parser.addParameter('sigD', 0.1, @(x) isnumeric(x))

parser.parse(pairedModels, pairedModelInfo, varargin{:});

pairedModels = parser.Results.pairedModels;
pairedModelInfo = parser.Results.pairedModelInfo;
inputDiet = parser.Results.inputDiet;
saveSolutionsFlag = parser.Results.saveSolutionsFlag;
numWorkers = parser.Results.numWorkers;
sigD = parser.Results.sigD;

if saveSolutionsFlag == true
    pairwiseSolutions{1, 1} = 'pairedModelID';
    pairwiseSolutions{1, 2} = 'PairwiseSolution';
    pairwiseSolutions{1, 3} = 'SingleModel1Solution';
    pairwiseSolutions{1, 4} = 'SingleModel2Solution';
end

pairwiseSolutions = {};
pairwiseInteractions{1, 1} = 'pairedModelID';
pairwiseInteractions{1, 2} = 'ModelID1';
pairwiseInteractions{1, 3} = 'ModelID2';
pairwiseInteractions{1, 4} = 'pairedGrowth_Model1';
pairwiseInteractions{1, 5} = 'pairedGrowth_Model2';
pairwiseInteractions{1, 6} = 'singleGrowth_Model1';
pairwiseInteractions{1, 7} = 'singleGrowth_Model2';
pairwiseInteractions{1, 8} = 'Outcome_Model1';
pairwiseInteractions{1, 9} = 'Outcome_Model2';
pairwiseInteractions{1, 10} = 'Total_Outcome';

if numWorkers > 0
    % with parallelization
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
    global CBT_LP_SOLVER
    solver = CBT_LP_SOLVER;

    solutionPairedTemp = {};
    solutionSingle1Temp = {};
    solutionSingle2Temp = {};
    iAFirstTemp = {};
    iASecondTemp = {};
    iABothTemp = {};
    parfor i = 1:size(pairedModelInfo, 1)
        changeCobraSolver(solver, 'LP');
        % load the model
        pairedModel = pairedModels{i};
        % if a diet was input
        if ~isempty(inputDiet)
            pairedModel = useDiet(pairedModel, inputDiet);
        end
        % for each paired model, set both biomass objective functions as
        % objectives
        biomass1 = strcat(pairedModelInfo{i, 2}, '_', pairedModelInfo{i, 3});
        biomass2 = strcat(pairedModelInfo{i, 4}, '_', pairedModelInfo{i, 5});
        model1biomass = find(ismember(pairedModel.rxns, biomass1));
        pairedModel.c(model1biomass, 1) = 1;
        model2biomass = find(ismember(pairedModel.rxns, biomass2));
        pairedModel.c(model2biomass, 1) = 1;
        % enforce minimal growth
        pairedModel = changeRxnBounds(pairedModel, biomass1, 0.001, 'l');
        pairedModel = changeRxnBounds(pairedModel, biomass2, 0.001, 'l');
        % calculate joint biomass
        solutionPaired = solveCobraLP(buildLPproblemFromModel(pairedModel,false));
        solutionPairedTemp{i} = solutionPaired;
        % separate growth
        % silence model 2 and optimize model 1
        % load the model again to avoid errors
        pairedModel = pairedModels{i};
        % if a diet was input
        if ~isempty(inputDiet)
            pairedModel = useDiet(pairedModel, inputDiet);
        end
        pairedModel = changeObjective(pairedModel, biomass1);
        % disable flux through the second model
        pairedModel = changeRxnBounds(pairedModel, pairedModel.rxns(strmatch(strcat(pairedModelInfo{i, 4}, '_'), pairedModel.rxns)), 0, 'b');
        % calculate single biomass
        solutionSingle1 = solveCobraLP(buildLPproblemFromModel(pairedModel),false);
        solutionSingle1Temp{i} = solutionSingle1;
        % silence model 1 and optimize model 2
        % load the model again to avoid errors
        pairedModel = pairedModels{i};
        % if a diet was input
        if ~isempty(inputDiet)
            pairedModel = useDiet(pairedModel, inputDiet);
        end
        pairedModel = changeObjective(pairedModel, biomass2);
        % disable flux through the first model
        pairedModel = changeRxnBounds(pairedModel, pairedModel.rxns(strmatch(strcat(pairedModelInfo{i, 2}, '_'), pairedModel.rxns)), 0, 'b');
        % calculate single biomass
        solutionSingle2 = solveCobraLP(buildLPproblemFromModel(pairedModel,false));
        solutionSingle2Temp{i} = solutionSingle2;

        % interpret computed growth rates-only if solutions are feasible
        if solutionPaired.stat ~= 0 && solutionSingle1.stat ~= 0 && solutionSingle2.stat ~= 0
            [iAFirstModelTemp, iASecondModelTemp, iATotalTemp] = analyzePairwiseInteractions(solutionPaired.full(model1biomass), solutionPaired.full(model2biomass), solutionSingle1.full(model1biomass), solutionSingle2.full(model2biomass), sigD);
            iAFirstTemp{i} = iAFirstModelTemp;
            iASecondTemp{i} = iASecondModelTemp;
            iABothTemp{i} = iATotalTemp;
        end
    end
    for i = 1:size(pairedModelInfo, 1)
        %% fill in all results
        pairedModel = pairedModels{i};
        biomass1 = strcat(pairedModelInfo{i, 2}, '_', pairedModelInfo{i, 3});
        biomass2 = strcat(pairedModelInfo{i, 4}, '_', pairedModelInfo{i, 5});
        model1biomass = find(ismember(pairedModel.rxns, biomass1));
        model2biomass = find(ismember(pairedModel.rxns, biomass2));
        % fill out the results table with the model information
        pairwiseInteractions{i + 1, 1} = pairedModelInfo{i, 1};
        pairwiseInteractions{i + 1, 2} = pairedModelInfo{i, 2};
        pairwiseInteractions{i + 1, 3} = pairedModelInfo{i, 4};
        % combined growth
        pairwiseInteractions{i + 1, 4} = solutionPairedTemp{i}.full(model1biomass);
        pairwiseInteractions{i + 1, 5} = solutionPairedTemp{i}.full(model2biomass);
        pairwiseInteractions{i + 1, 6} = solutionSingle1Temp{i}.full(model1biomass);
        pairwiseInteractions{i + 1, 7} = solutionSingle2Temp{i}.full(model2biomass);
        % make sure that infeasible solutions are flagged
        if solutionPairedTemp{i}.stat == 0 || solutionSingle1Temp{i}.stat == 0 || solutionSingle2Temp{i}.stat == 0
            pairwiseInteractions{i + 1, 8} = 'Infeasible';
            pairwiseInteractions{i + 1, 9} = 'Infeasible';
            pairwiseInteractions{i + 1, 10} = 'Infeasible';
        else
            % save the results
            pairwiseInteractions{i + 1, 8} = iAFirstTemp{i};
            pairwiseInteractions{i + 1, 9} = iASecondTemp{i};
            pairwiseInteractions{i + 1, 10} = iABothTemp{i};
        end
        %% store the solutions if storeSolutionFlag==true
        if nargin > 3 && saveSolutionsFlag == true
            pairwiseSolutions{i + 1, 1} = pairedModelInfo{i, 1};
            pairwiseSolutions{i + 1, 2} = solutionPairedTemp{i};
            pairwiseSolutions{i + 1, 3} = solutionSingle1Temp{i};
            pairwiseSolutions{i + 1, 4} = solutionSingle2Temp{i};
        end
    end
else
    % without parallization
    for i = 1:size(pairedModelInfo, 1)
        % load the model
        pairedModel = pairedModels{i};
        % if a diet was input
        if ~isempty(inputDiet)
            pairedModel = useDiet(pairedModel, inputDiet);
        end
        % for each paired model, set both biomass objective functions as
        % objectives
        biomass1 = strcat(pairedModelInfo{i, 2}, '_', pairedModelInfo{i, 3});
        biomass2 = strcat(pairedModelInfo{i, 4}, '_', pairedModelInfo{i, 5});
        model1biomass = find(ismember(pairedModel.rxns, biomass1));
        pairedModel.c(model1biomass, 1) = 1;
        model2biomass = find(ismember(pairedModel.rxns, biomass2));
        pairedModel.c(model2biomass, 1) = 1;
        % enforce minimal growth
        pairedModel = changeRxnBounds(pairedModel, biomass1, 0.001, 'l');
        pairedModel = changeRxnBounds(pairedModel, biomass2, 0.001, 'l');
        % calculate joint biomass
        solutionPaired = solveCobraLP(buildLPproblemFromModel(pairedModel,false));
        % separate growth
        % silence model 2 and optimize model 1
        % load the model again to avoid errors
        pairedModel = pairedModels{i};
        % if a diet was input
        if ~isempty(inputDiet)
            pairedModel = useDiet(pairedModel, inputDiet);
        end
        pairedModel = changeObjective(pairedModel, biomass1);
        % disable flux through the second model
        pairedModel = changeRxnBounds(pairedModel, pairedModel.rxns(strmatch(strcat(pairedModelInfo{i, 4}, '_'), pairedModel.rxns)), 0, 'b');
        % calculate single biomass
        solutionSingle1 = solveCobraLP(buildLPproblemFromModel(pairedModel,false));
        % silence model 1 and optimize model 2
        % load the model again to avoid errors
        pairedModel = pairedModels{i};
        % if a diet was input
        if ~isempty(inputDiet)
            pairedModel = useDiet(pairedModel, inputDiet);
        end
        pairedModel = changeObjective(pairedModel, biomass2);
        % disable flux through the first model
        pairedModel = changeRxnBounds(pairedModel, pairedModel.rxns(strmatch(strcat(pairedModelInfo{i, 2}, '_'), pairedModel.rxns)), 0, 'b');
        % calculate single biomass
        solutionSingle2 = solveCobraLP(buildLPproblemFromModel(pairedModel,false));

        % interpret computed growth rates-only if solutions are feasible
        if solutionPaired.stat ~= 0 && solutionSingle1.stat ~= 0 && solutionSingle2.stat ~= 0
            [iAFirstModel, iASecondModel, iATotal] = analyzePairwiseInteractions(solutionPaired.full(model1biomass), solutionPaired.full(model2biomass), solutionSingle1.full(model1biomass), solutionSingle2.full(model2biomass), sigD);
        end

        %% list all results
        % fill out the results table with the model information
        pairwiseInteractions{i + 1, 1} = pairedModelInfo{i, 1};
        pairwiseInteractions{i + 1, 2} = pairedModelInfo{i, 2};
        pairwiseInteractions{i + 1, 3} = pairedModelInfo{i, 4};
        % combined growth
        pairwiseInteractions{i + 1, 4} = solutionPaired.full(model1biomass);
        pairwiseInteractions{i + 1, 5} = solutionPaired.full(model2biomass);
        pairwiseInteractions{i + 1, 6} = solutionSingle1.full(model1biomass);
        pairwiseInteractions{i + 1, 7} = solutionSingle2.full(model2biomass);
        % make sure that infeasible solutions are flagged
        if solutionPaired.stat == 0 || solutionSingle1.stat == 0 || solutionSingle2.stat == 0
            pairwiseInteractions{i + 1, 8} = 'Infeasible';
            pairwiseInteractions{i + 1, 9} = 'Infeasible';
            pairwiseInteractions{i + 1, 10} = 'Infeasible';
        else
            % save the results
            pairwiseInteractions{i + 1, 8} = iAFirstModel;
            pairwiseInteractions{i + 1, 9} = iASecondModel;
            pairwiseInteractions{i + 1, 10} = iATotal;
        end
        %% store the solutions if storeSolutionFlag==true
        if nargin > 3 && saveSolutionsFlag == true
            pairwiseSolutions{i + 1, 1} = pairedModelInfo{i, 1};
            pairwiseSolutions{i + 1, 2} = solutionPaired;
            pairwiseSolutions{i + 1, 3} = solutionSingle1;
            pairwiseSolutions{i + 1, 4} = solutionSingle2;
        end
    end
end
end

function [iAFirstOrg, iASecondOrg, iATotal] = analyzePairwiseInteractions(pairedGrowthOrg1, pairedGrowthOrg2, singleGrowthOrg1, singleGrowthOrg2, sigD)
% This function evaluates the outcome of pairwise growth of two organisms
% compared with the two organisms separately. There are six possible
% outcomes of the interaction, and nine possible outcomes from the
% perspective of each organism.

if abs(1 - (pairedGrowthOrg1 / singleGrowthOrg1)) < sigD
    % first microbe unaffected - all possible cases resulting froms
    % second microbe's growth
    if abs(1 - (pairedGrowthOrg2 / singleGrowthOrg2)) < sigD
        % second microbe unaffected
        iAFirstOrg = 'Neutralism';
        iASecondOrg = 'Neutralism';
        iATotal = 'Neutralism';
    elseif abs((pairedGrowthOrg2 / singleGrowthOrg2)) > 1 + sigD
        % second microbe grows better
        iAFirstOrg = 'Commensalism_Giver';
        iASecondOrg = 'Commensalism_Taker';
        iATotal = 'Commensalism';
    elseif abs((singleGrowthOrg2 / pairedGrowthOrg2)) > 1 + sigD
        % second microbe grows slower
        iAFirstOrg = 'Amensalism_Unaffected';
        iASecondOrg = 'Amensalism_Affected';
        iATotal = 'Amensalism';
    else
        % if no case fits - needs inspection!
        iAFirstOrg = 'No_Result';
        iASecondOrg = 'No_Result';
        iATotal = 'No_Result';
    end
elseif abs((pairedGrowthOrg1 / singleGrowthOrg1)) > 1 + sigD
    % first microbe grows better - all possible cases resulting froms
    % second microbe's growth
    if abs(1 - (pairedGrowthOrg2 / singleGrowthOrg2)) < sigD
        % second microbe unaffected
        iAFirstOrg = 'Commensalism_Taker';
        iASecondOrg = 'Commensalism_Giver';
        iATotal = 'Commensalism';
    elseif abs((pairedGrowthOrg2 / singleGrowthOrg2)) > 1 + sigD
        % second microbe grows better
        iAFirstOrg = 'Mutualism';
        iASecondOrg = 'Mutualism';
        iATotal = 'Mutualism';
    elseif abs((singleGrowthOrg2 / pairedGrowthOrg2)) > 1 + sigD
        % second microbe grows slower
        iAFirstOrg = 'Parasitism_Taker';
        iASecondOrg = 'Parasitism_Giver';
        iATotal = 'Parasitism';
    else
        % if no case fits - needs inspection!
        iAFirstOrg = 'No_Result';
        iASecondOrg = 'No_Result';
        iATotal = 'No_Result';
    end
elseif abs((singleGrowthOrg1 / pairedGrowthOrg1)) > 1 + sigD
    % first microbe grows slower - all possible cases resulting froms
    % second microbe's growth
    if abs(1 - (pairedGrowthOrg2 / singleGrowthOrg2)) < sigD
        % second microbe unaffected
        iAFirstOrg = 'Amensalism_Affected';
        iASecondOrg = 'Amensalism_Unaffected';
        iATotal = 'Amensalism';
    elseif abs((pairedGrowthOrg2 / singleGrowthOrg2)) > 1 + sigD
        % second microbe grows better
        iAFirstOrg = 'Parasitism_Giver';
        iASecondOrg = 'Parasitism_Taker';
        iATotal = 'Parasitism';
    elseif abs((singleGrowthOrg2 / pairedGrowthOrg2)) > 1 + sigD
        % second microbe grows slower
        iAFirstOrg = 'Competition';
        iASecondOrg = 'Competition';
        iATotal = 'Competition';
    else
        % if no case fits - needs inspection!
        iAFirstOrg = 'No_Result';
        iASecondOrg = 'No_Result';
        iATotal = 'No_Result';
    end
else
    % if no case fits - needs inspection!
    iAFirstOrg = 'No_Result';
    iASecondOrg = 'No_Result';
    iATotal = 'No_Result';
end
end
