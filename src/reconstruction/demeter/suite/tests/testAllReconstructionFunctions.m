function testAllReconstructionFunctions(modelFolder,testResultsFolder,inputDataFolder,reconVersion, numWorkers)
% This function performs all quality control/quality assurance tests and
% saves the results for each reconstruction in the input folder.
%
% USAGE:
%
%   testAllReconstructionFunctions(modelFolder,testResultsFolder,inputDataFolder,reconVersion, numWorkers)
%
% INPUTS
% modelFolder           Folder with COBRA models (draft or refined
%                       reconstructions) to analyze
% testResultsFolder     Folder where the test results should be saved
% inputDataFolder       Folder with experimental data and database files
%                       to load
% reconVersion          Name of the refined reconstruction resource
% numWorkers            Number of workers in parallel pool
%
% .. Author:
%   - Almut Heinken, 09/2020

% set a solver if not done yet
global CBT_LP_SOLVER
solver = CBT_LP_SOLVER;
if isempty(solver)
    initCobraToolbox(false); %Don't update the toolbox automatically
end

% initialize parallel pool
if numWorkers>0 && ~isempty(ver('parallel'))
    % with parallelization
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end
environment = getEnvironment();

% Runs through all tests
dInfo = dir(modelFolder);
modelList={dInfo.name};
modelList=modelList';
modelList(~contains(modelList(:,1),'.mat'),:)=[];

fields = {
    'Mass_imbalanced'
    'Charge_imbalanced'
    'Mets_without_formulas'
    'Leaking_metabolites'
    'ATP_from_O2'
    'Blocked_reactions'
    'RefinedReactionsCarryingFlux'
    'BlockedRefinedReactions'
    'Incorrect_Gene_Rules'
    'Incorrect_Compartments'
    'Carbon_sources_TruePositives'
    'Carbon_sources_FalseNegatives'
    'Fermentation_products_TruePositives'
    'Fermentation_products_FalseNegatives'
    'growsOnDefinedMedium'
    'growthOnKnownCarbonSources'
    'Biomass_precursor_biosynthesis_TruePositives'
    'Biomass_precursor_biosynthesis_FalseNegatives'
    'Metabolite_uptake_TruePositives'
    'Metabolite_uptake_FalseNegatives'
    'Secretion_products_TruePositives'
    'Secretion_products_FalseNegatives'
    'Bile_acid_biosynthesis_TruePositives'
    'Bile_acid_biosynthesis_FalseNegatives'
    'Drug_metabolism_TruePositives'
    'Drug_metabolism_FalseNegatives'
    'PutrefactionPathways_TruePositives'
    'PutrefactionPathways_FalseNegatives'
    };

%% load the results from existing test suite run and restart from there
Results=struct;

alreadyAnalyzedStrains={};

for i=1:length(fields)
    if isfile([testResultsFolder filesep fields{i} '_' reconVersion '.txt'])
        savedResults = readtable([testResultsFolder filesep fields{i} '_' reconVersion '.txt'], 'Delimiter', 'tab', 'ReadVariableNames', false);
        Results.(fields{i}) = table2cell(savedResults);
        alreadyAnalyzedStrains = Results.(fields{i})(:,1);
    else
        Results.(fields{i})={};
    end
end

% propagate strains to empty fields
for i=1:length(fields)
    if isempty(Results.(fields{i}))
        Results.(fields{i})=alreadyAnalyzedStrains;
    end
end

% remove already analyzed reconstructions
if size(Results.(fields{1}),1)>0
    [C,IA]=intersect(strrep(modelList(:,1),'.mat',''),Results.(fields{1})(:,1));
    modelList(IA,:)=[];
end

% define the intervals in which the testing and regular saving will be
% performed
if length(modelList)>5000
    steps=1000;
elseif length(modelList)>1000
    steps=500;
elseif length(modelList)>200
    steps=200;
else
    steps=25;
end

%% Start the test suite
for i = 1:steps:length(modelList)
    tmpData={};
    if length(modelList)>steps-1 && (length(modelList)-1)>=steps-1
        endPnt=steps-1;
    else
        endPnt=length(modelList)-i;
    end
    
    modelsToLoad={};
    for j=i:i+endPnt
        modelsToLoad{j}={};
        if j <= length(modelList)
            modelsToLoad{j}=[modelFolder filesep modelList{j}];
        end
    end
    parfor j=i:i+endPnt
        if j <= length(modelList)
            restoreEnvironment(environment);
            changeCobraSolver(solver, 'LP');
            % prevent creation of log files
            changeCobraSolverParams('LP', 'logFile', 0);
            
            tmpStruct=struct();
            % iterate over the field
            for k=1:length(fields)
                tmpStruct.(fields{k}){j, 1} = strrep(modelList{j},'.mat','');
            end
            try
                model=readCbModel(modelsToLoad{j});
            catch
                modelsToLoad{j}
                model=load(modelsToLoad{j});
                fieldnames(model)
                model=model.model;
            end
            
            microbeID=strrep(modelList{j},'.mat','');
            biomassReaction = model.rxns{strncmp('bio', model.rxns, 3)};
            %
            %% relax enforced uptake of some vitamins-causes infeasibility problems
            relaxConstraints=model.rxns(find(model.lb>0));
            model=changeRxnBounds(model,relaxConstraints,0,'l');
            
            %% Mass and charge balance
            % Tests whether the reactions in the reconstruction are mass and charge balanced.
            % The function will report any reactions that have imbalanced mass or charge,
            % along with their reaction formulas and imbalanced elements. The function will
            % also report the metabolite formulas of all metabolites that occur in any imbalanced
            % reactions. Finally, any metabolites without metabolite formulas are reported.
            %
            % *Inputs:*
            %
            % * *model*: COBRA model structure
            % * *excludeExchanges*: Exclude exchange reactions when reporting imblanced
            % reactions (default: true).
            % * *biomassReaction*: Give biomass reaction abbreviation to exclude biomass
            % reaction from analysis
            %
            % *Outputs:*
            %
            % * *massImbalancedRxns*: Cell array listing (col 1) all mass imbalanced reactions
            % in the model, (col 2) the reaction formulas, and (col 3) the imbalanced elements.
            % * *chargeImbalancedRxns*: Cell array listing (col 1) all charge imbalanced
            % reactions in the model, (col 2) the reaction formulas, and (col 3) the imblanced
            % elements.
            % * *imbalancedRxnMets*: Cell array listing (col 1) all metabolites involved
            % in any mass or charge imblanced reaction, (col 2) the metabolite name, (col
            % 3) the metabolite formula, and (col 4) the metabolite charge.
            % * *metsMissingFormulas*: Cell array listing (col 1) all metabolites that do
            % not have metabolite formulas and (col 2) the metabolite names.
            
            %             [massImbalancedRxns, chargeImbalancedRxns, ~, metsMissingFormulas] = testModelMassChargeBalance(model, true, biomassReaction);
            %             tmpStruct.Mass_imbalanced(j, 2:size(massImbalancedRxns,1)) =massImbalancedRxns(2:end,1);
            %             tmpStruct.Charge_imbalanced(j, 2:size(chargeImbalancedRxns,1))= chargeImbalancedRxns(2:end,1);
            %             tmpStruct.Mets_without_formulas(j, 2:length(metsMissingFormulas)) = metsMissingFormulas(2:end,1);
            %%
            % A metabolic reconstruction should contain no mass or charge imbalanced
            % reactions. However, some reactions will always be imbalanced by definition (exchange,
            % demand, sink, and biomass reactions), and some reactions will be imbalanced
            % when formulas of participating metabolites are not known.
            %% Leaking metabolites
            % Tests whether the model can produce any metabolites when no mass enters the
            % model (all exchange and sink reactions blocked).
            %
            % *Inputs:*
            %
            % * *model*: COBRA model structure
            %
            % *Outputs:*
            %
            % * *leakingMets*: Cell array listing any metabolites that can be be produced
            % from nothing and any reactions that are active in the simulation (along with
            % reaction formula and flux value).
            
            leakingMets = testLeakingMetabolites(model);
            tmpStruct.Leaking_metabolites(j, 2:length(leakingMets)+1) = leakingMets;
            
            % The model should not leak any metabolites. Leaking metabolites require
            % manual refinement.
            
            %% ATP from oxygen
            % Tests if models can produce ATP and carbon just from water,
            % phosphate, and oxygen without an energy source. This is
            % thermodynamically infeasible and should not happen.
            basicCompounds={
                'EX_h2o(e)' '-100'
                'EX_h(e)' '-100'
                'EX_pi(e)' '-10'
                'EX_o2(e)' '-10'
                };
            modelTest = useDiet(model,basicCompounds);
            modelTest.lb(find(strncmp(modelTest.rxns,'sink_',5)))=0;
            modelTest=changeObjective(modelTest,'DM_atp_c_');
            FBA=optimizeCbModel(modelTest);
            tmpStruct.ATP_from_O2{j, 2} = FBA.f;
            
            %% Blocked reactions
            % Computes all reactions in the reconstruction that can never carry flux.
            % set "unlimited" constraints
            model = changeRxnBounds(model, model.rxns(strncmp('EX_', model.rxns, 3)), -1000, 'l');
            model = changeRxnBounds(model, model.rxns(strncmp('EX_', model.rxns, 3)), 1000, 'u');
            [consistModel, BlockedRxns] = identifyBlockedRxns(model);
            % do not save for very large-scale resources-file would be
            % enormmous
            if length(modelList) + length(alreadyAnalyzedStrains) <10000
                tmpStruct.Blocked_reactions(j, 2:length(BlockedRxns.allRxns)+1) = BlockedRxns.allRxns;
            else
                tmpStruct.Blocked_reactions{j, 2} = length(BlockedRxns.allRxns);
            end
            
            %% Test whether reactions added through refinement of gene annotations carry flux
            [RefinedReactionsCarryingFlux, BlockedRefinedReactions] = testRefinedReactions(microbeID, BlockedRxns);
            tmpStruct.RefinedReactionsCarryingFlux(j, 2:length(RefinedReactionsCarryingFlux)+1) = RefinedReactionsCarryingFlux;
            tmpStruct.BlockedRefinedReactions(j, 2:length(BlockedRefinedReactions)+1) = BlockedRefinedReactions;
            
            %% Entries in gene rules that have incorrect nomenclature
            incorrectGeneRules = testGeneRules(model);
            tmpStruct.Incorrect_Gene_Rules(j, 2:length(incorrectGeneRules)+1) = incorrectGeneRules;
            
            %% Reactions and metabolites with non-microbial compartments
            [incorrectRxns,incorrectMets] = validateCompartments(model);
            tmpStruct.Incorrect_Compartments(j, 2:length(incorrectRxns)+1) = incorrectRxns;
            tmpStruct.Incorrect_Compartments(j, 2:length(incorrectMets)+1) = incorrectMets;
            
            %% Carbon sources
            % Tests which carbon sources that are reported in _in vitro_ data can be taken
            % up by the model. The test requires a low flux through the biomass objective
            % function.
            %
            % *Inputs:*
            %
            % * *model*: COBRA model structure
            % * *microbeID*: Microbe ID in carbon source data file
            % * *biomassReaction*: String listing the biomass reaction
            %
            % *Outputs:*
            %
            % * *TruePositives*: Cell array of strings listing all carbon sources (exchange
            % reactions) that can be taken up by the model and in _in vitro _data.
            % * *FalseNegatives*: Cell array of strings listing all carbon sources (exchange
            % reactions) that cannot be taken up by the model but should be taken up according
            % to _in vitro _data.
            %
            % *Note:* Because we do not have data on carbon sources that should _not_
            % be taken up by the model, we can only compare those that are known to be taken
            % up by the microbe. Therefore, it is not possible to evaluate true negatives
            % and false positives.
            
            [TruePositives, FalseNegatives] = testCarbonSources(model, microbeID, biomassReaction, inputDataFolder);
            tmpStruct.Carbon_sources_TruePositives(j, 2:length(TruePositives)+1) = TruePositives;
            tmpStruct.Carbon_sources_FalseNegatives(j, 2:length(FalseNegatives)+1) = FalseNegatives;
            %%
            % The function |*carbonSourceGapfill|* aims to enable to uptake of all _in
            % vitro_ reported carbon sources. In the case of any false negatives, the reconstruction
            % needs to be manually refined to make sure that uptaken carbon source can enter
            % an active metabolic pathway within the reconstruction.
            %% Fermentation pathways
            % Tests which fermentation pathways that are reported in _in vitro_ data are
            % active in the model. The test requires a low flux through the biomass objective
            % function.
            %
            % *Inputs:*
            %
            % * *model*: COBRA model structure
            % * *microbeID*: Microbe ID in carbon source data file
            % * *biomassReaction*: String listing the biomass reaction
            %
            % *Outputs:*
            %
            % * *TruePositives*: Cell array of strings listing all fermentation products
            % (exchange reactions) that can be secreted by the model and in in vitro data.
            % * *FalseNegatives*: Cell array of strings listing all fermentation products
            % (exchange reactions) that cannot be secreted by the model but should be secreted
            % according to _in vitro_ data.
            %
            % *Note:* Because we do not have data on carbon sources that should _not_
            % be taken up by the model, we can only compare those that are known to be taken
            % up by the microbe. Therefore, it is not possible to evaluate true negatives
            % and false positives.
            
            [TruePositives, FalseNegatives] = testFermentationProducts(model, microbeID, biomassReaction, inputDataFolder);
            tmpStruct.Fermentation_products_TruePositives(j, 2:length(TruePositives)+1) = TruePositives;
            tmpStruct.Fermentation_products_FalseNegatives(j, 2:length(FalseNegatives)+1) = FalseNegatives;
            %%
            % The function |*fermentationPathwayGapfill|* aims to enable to secretion
            % of all _in vitro_ reported fermentation productions. In the case of any false
            % negatives, the reconstruction needs to be manually refined to make sure that
            % fermentation pathways are active within the reconstruction.
               
            %% test the defined media according to literature
            [growsOnDefinedMedium,constrainedModel,growthOnKnownCarbonSources] = testGrowthOnDefinedMedia(model, microbeID, biomassReaction, inputDataFolder);
            tmpStruct.growsOnDefinedMedium{j, 2} = growsOnDefinedMedium;
            tmpStruct.growthOnKnownCarbonSources{j, 2} = growthOnKnownCarbonSources;
            
            % In the case of any false negatives, the reconstruction needs to be manually
            % refined to make sure that essential metabolites cannot be synthesized _de novo_
            % by the model or that non-essential metabolites are not required in the growth
            % media.
                    
            %% Metabolite consumption
            % Performs an FVA and reports those metabolites (exchange reactions)
            % that can be taken up by the model and should be taken up according to
            % data (true positives) and those metabolites that cannot be taken up by
            % the model but should be taken up according to in vitro data (false
            % negatives).
            % Based on literature search of reported vitamin-secreting probiotics
            % performed 11/2017, and a compendium of uptake and secretion products
            % (PMID:28585563)
            %
            % INPUT
            % model             COBRA model structure
            % microbeID         Microbe ID in secretion product data file
            % biomassReaction   Biomass objective functions (low flux through BOF
            %                   required in analysis)
            %
            % OUTPUT
            % TruePositives     Cell array of strings listing all metabolites
            %                   (exchange reactions) that can be taken up by the model
            %                   and in in vitro data.
            % FalseNegatives    Cell array of strings listing all metabolites
            %                   (exchange reactions) that cannot be taken up by the model
            %                   but should be taken up according to in vitro data.
            [TruePositives, FalseNegatives] = testMetaboliteUptake(model, microbeID, biomassReaction, inputDataFolder);
            tmpStruct.Metabolite_uptake_TruePositives(j, 2:length(TruePositives)+1) = TruePositives;
            tmpStruct.Metabolite_uptake_FalseNegatives(j, 2:length(FalseNegatives)+1) = FalseNegatives;
            
            %% Metabolite secretion
            % Performs an FVA and reports those secretion products (exchange reactions)
            % that can be secreted by the model and should be secreted according to
            % data (true positives) and those secretion products that cannot be secreted by
            % the model but should be secreted according to in vitro data (false
            % negatives).
            % Based on literature search of reported vitamin-secreting probiotics
            % performed 11/2017, and a compendium of uptake and secretion products
            % (PMID:28585563)
            %
            % INPUT
            % model             COBRA model structure
            % microbeID         Microbe ID in secretion product data file
            % biomassReaction   Biomass objective functions (low flux through BOF
            %                   required in analysis)
            %
            % OUTPUT
            % TruePositives     Cell array of strings listing all secretion products
            %                   (exchange reactions) that can be secreted by the model
            %                   and in in vitro data.
            % FalseNegatives    Cell array of strings listing all secretion products
            %                   (exchange reactions) that cannot be secreted by the model
            %                   but should be secreted according to in vitro data.
            [TruePositives, FalseNegatives] = testSecretionProducts(model, microbeID, biomassReaction, inputDataFolder);
            tmpStruct.Secretion_products_TruePositives(j, 2:length(TruePositives)+1) = TruePositives;
            tmpStruct.Secretion_products_FalseNegatives(j, 2:length(FalseNegatives)+1) = FalseNegatives;
             
            %% Bile acid biotransformation
            % Performs an FVA and reports those bile acid metabolites (exchange reactions)
            % that can be secreted by the model and should be secreted according to
            % data (true positives) and those bile acid metabolites that cannot be secreted by
            % the model but should be secreted according to in vitro data (false
            % negatives).
            %
            % INPUT
            % model             COBRA model structure
            % microbeID         Microbe ID in carbon source data file
            % biomassReaction   Biomass objective functions (low flux through BOF
            %                   required in analysis)
            %
            % OUTPUT
            % TruePositives     Cell array of strings listing all bile acid products
            %                   (exchange reactions) that can be secreted by the model
            %                   and in in vitro data.
            % FalseNegatives    Cell array of strings listing all bile acid products
            %                   (exchange reactions) that cannot be secreted by the model
            %                   but should be secreted according to in vitro data.
            if exist('BileAcidTable.txt','File')==2
            [TruePositives, FalseNegatives] = testBileAcidBiosynthesis(model, microbeID, biomassReaction);
            tmpStruct.Bile_acid_biosynthesis_TruePositives(j, 2:length(TruePositives)+1) = TruePositives;
            tmpStruct.Bile_acid_biosynthesis_FalseNegatives(j, 2:length(FalseNegatives)+1) = FalseNegatives;
            end
            %% Drug biotransformation
            % Performs an FVA and reports those drug metabolites (exchange reactions)
            % that can be secreted by the model and should be taken up and/or secreted according to
            % data (true positives) and those drug metabolites that cannot be secreted by
            % the model but should be secreted according to in vitro data (false
            % negatives).
            %
            % INPUT
            % model             COBRA model structure
            % microbeID         Microbe ID in carbon source data file
            % biomassReaction   Biomass objective functions (low flux through BOF
            %                   required in analysis)
            %
            % OUTPUT
            % TruePositives     Cell array of strings listing all drug metabolites
            %                   (exchange reactions) that can be taken up and/or
            %                   secreted by the model and in in vitro data.
            % FalseNegatives    Cell array of strings listing all drug metabolites
            %                   (exchange reactions) that cannot be taken up and/or secreted by the model
            %                   but should be secreted according to in vitro data.
            if exist('drugTable.txt','File')==2
            [TruePositives, FalseNegatives] = testDrugMetabolism(model, microbeID, biomassReaction);
            tmpStruct.Drug_metabolism_TruePositives(j, 2:length(TruePositives)+1) = TruePositives;
            tmpStruct.Drug_metabolism_FalseNegatives(j, 2:length(FalseNegatives)+1) = FalseNegatives;
            end
            %% Putrefaction pathways
            % Performs an FVA and reports those putrefaction pathway end reactions (exchange reactions)
            % that can carry flux in the model and should carry flux according to
            % data (true positives) and those putrefaction pathway end reactions that
            % cannot carry flux in the model but should be secreted according to in
            % vitro data (false negatives).
            %
            % INPUT
            % model             COBRA model structure
            % microbeID         Microbe ID in carbon source data file
            % biomassReaction   Biomass objective functions (low flux through BOF
            %                   required in analysis)
            %
            % OUTPUT
            % TruePositives     Cell array of strings listing all putrefaction reactions
            % that can carry flux in the model and in in vitro data.
            % FalseNegatives    Cell array of strings listing all putrefaction reactions
            % that cannot carry flux in the model but should carry flux according to in
            % vitro data.
            [TruePositives, FalseNegatives] = testPutrefactionPathways(model, microbeID, biomassReaction);
            tmpStruct.PutrefactionPathways_TruePositives(j, 2:length(TruePositives)+1) = TruePositives;
            tmpStruct.PutrefactionPathways_FalseNegatives(j, 2:length(FalseNegatives)+1) = FalseNegatives;       
             %%
            tmpData{j}=tmpStruct;
        end
    end
    for k=1:length(fields)
        for j=i:i+endPnt
            if j <= length(modelList)
                res=tmpData{j};
                Results.(fields{k})(size(Results.(fields{k}),1)+1,1:size(res.(fields{k}),2)) = res.(fields{k})(j,1:end);
            end
        end
    end
    
    %% print the results regularly to avoid having to repeat simulations
    % only if there were any findings that need to be reported
    for j=1:length(fields)
        if size(Results.(fields{j}),2)>1
            table2print=cell2table(Results.(fields{j}));
            writetable(table2print,[testResultsFolder filesep fields{j} '_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
        end
    end
end

end
