function testResults = runTestsOnModel(model, microbeID, inputDataFolder)
% Part of the DEMETER pipeline. This function performs all quality
% control/quality assurance tests on a model.
%
% USAGE:
%
%   testResults = runTestsOnModel(model, microbeID, inputDataFolder)
%
% INPUTS
% modelFolder           Folder with COBRA models (draft or refined
%                       reconstructions) to analyze
% inputDataFolder       Folder with experimental data and database files
%                       to load
%
% OUTPUT
% testResults           Structure with results of the test run
%
% .. Author:
%   - Almut Heinken, 03/2021


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
    'AromaticAminoAcidDegradation_TruePositives'
    'AromaticAminoAcidDegradation_FalseNegatives'
    };

testResults=struct();
% iterate over the field
for k=1:length(fields)
    testResults.(fields{k}){1, 1} = microbeID;
end

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
try
[massImbalancedRxns, chargeImbalancedRxns, ~, metsMissingFormulas] = testModelMassChargeBalance(model, true, biomassReaction);
testResults.Mass_imbalanced(1, 2:size(massImbalancedRxns,1)) =massImbalancedRxns(2:end,1);
testResults.Charge_imbalanced(1, 2:size(chargeImbalancedRxns,1))= chargeImbalancedRxns(2:end,1);
testResults.Mets_without_formulas(1, 2:length(metsMissingFormulas)) = metsMissingFormulas(2:end,1);
catch
    warning('Mass and charge balance could not be tested for draft reconstructions!')
end
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
testResults.Leaking_metabolites(1, 2:length(leakingMets)+1) = leakingMets;

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
testResults.ATP_from_O2{1, 2} = FBA.f;

%% Blocked reactions
% Computes all reactions in the reconstruction that can never carry flux.
% set "unlimited" constraints
model = changeRxnBounds(model, model.rxns(strncmp('EX_', model.rxns, 3)), -1000, 'l');
model = changeRxnBounds(model, model.rxns(strncmp('EX_', model.rxns, 3)), 1000, 'u');
BlockedRxns = identifyFastBlockedRxns(model);
testResults.Blocked_reactions(1, 2:length(BlockedRxns)+1) = BlockedRxns;

%% Test whether reactions added through refinement of gene annotations carry flux
[RefinedReactionsCarryingFlux, BlockedRefinedReactions] = testRefinedReactions(microbeID, BlockedRxns);
testResults.RefinedReactionsCarryingFlux(1, 2:length(RefinedReactionsCarryingFlux)+1) = RefinedReactionsCarryingFlux;
testResults.BlockedRefinedReactions(1, 2:length(BlockedRefinedReactions)+1) = BlockedRefinedReactions;

%% Entries in gene rules that have incorrect nomenclature
incorrectGeneRules = testGeneRules(model);
testResults.Incorrect_Gene_Rules(1, 2:length(incorrectGeneRules)+1) = incorrectGeneRules;

%% Reactions and metabolites with non-microbial compartments
[incorrectRxns,incorrectMets] = validateCompartments(model);
testResults.Incorrect_Compartments(1, 2:length(incorrectRxns)+1) = incorrectRxns;
testResults.Incorrect_Compartments(1, 2:length(incorrectMets)+1) = incorrectMets;

%% Carbon sources
% Tests which carbon sources that are reported in _in vitro_ data can be taken
% up by the model. The test requires a low flux through the biomass objective
% function.
% *Note:* Because we do not have data on carbon sources that should _not_
% be taken up by the model, we can only compare those that are known to be taken
% up by the microbe. Therefore, it is not possible to evaluate true negatives
% and false positives.

[TruePositives, FalseNegatives] = testCarbonSources(model, microbeID, biomassReaction, inputDataFolder);
testResults.Carbon_sources_TruePositives(1, 2:length(TruePositives)+1) = TruePositives;
testResults.Carbon_sources_FalseNegatives(1, 2:length(FalseNegatives)+1) = FalseNegatives;
%%
% The function |*carbonSourceGapfill|* aims to enable to uptake of all _in
% vitro_ reported carbon sources. In the case of any false negatives, the reconstruction
% needs to be manually refined to make sure that uptaken carbon source can enter
% an active metabolic pathway within the reconstruction.
%% Fermentation pathways
% Tests which fermentation pathways that are reported in _in vitro_ data are
% active in the model. The test requires a low flux through the biomass objective
% function.
% *Note:* Because we do not have data on carbon sources that should _not_
% be taken up by the model, we can only compare those that are known to be taken
% up by the microbe. Therefore, it is not possible to evaluate true negatives
% and false positives.

[TruePositives, FalseNegatives] = testFermentationProducts(model, microbeID, biomassReaction, inputDataFolder);
testResults.Fermentation_products_TruePositives(1, 2:length(TruePositives)+1) = TruePositives;
testResults.Fermentation_products_FalseNegatives(1, 2:length(FalseNegatives)+1) = FalseNegatives;
%%
% The function |*fermentationPathwayGapfill|* aims to enable to secretion
% of all _in vitro_ reported fermentation productions. In the case of any false
% negatives, the reconstruction needs to be manually refined to make sure that
% fermentation pathways are active within the reconstruction.

%% test the defined media according to literature
[growsOnDefinedMedium,constrainedModel,growthOnKnownCarbonSources] = testGrowthOnDefinedMedia(model, microbeID, biomassReaction, inputDataFolder);
testResults.growsOnDefinedMedium{1, 2} = growsOnDefinedMedium;
testResults.growthOnKnownCarbonSources{1, 2} = growthOnKnownCarbonSources;

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

[TruePositives, FalseNegatives] = testMetaboliteUptake(model, microbeID, biomassReaction, inputDataFolder);
testResults.Metabolite_uptake_TruePositives(1, 2:length(TruePositives)+1) = TruePositives;
testResults.Metabolite_uptake_FalseNegatives(1, 2:length(FalseNegatives)+1) = FalseNegatives;

%% Metabolite secretion
% Performs an FVA and reports those secretion products (exchange reactions)
% that can be secreted by the model and should be secreted according to
% data (true positives) and those secretion products that cannot be secreted by
% the model but should be secreted according to in vitro data (false
% negatives).
% Based on literature search of reported vitamin-secreting probiotics
% performed 11/2017, and a compendium of uptake and secretion products
% (PMID:28585563)

[TruePositives, FalseNegatives] = testSecretionProducts(model, microbeID, biomassReaction, inputDataFolder);
testResults.Secretion_products_TruePositives(1, 2:length(TruePositives)+1) = TruePositives;
testResults.Secretion_products_FalseNegatives(1, 2:length(FalseNegatives)+1) = FalseNegatives;

%% Bile acid biotransformation
% Performs an FVA and reports those bile acid metabolites (exchange reactions)
% that can be secreted by the model and should be secreted according to
% data (true positives) and those bile acid metabolites that cannot be secreted by
% the model but should be secreted according to in vitro data (false
% negatives).

[TruePositives, FalseNegatives] = testBileAcidBiosynthesis(model, microbeID, biomassReaction);
testResults.Bile_acid_biosynthesis_TruePositives(1, 2:length(TruePositives)+1) = TruePositives;
testResults.Bile_acid_biosynthesis_FalseNegatives(1, 2:length(FalseNegatives)+1) = FalseNegatives;
%% Drug biotransformation
% Performs an FVA and reports those drug metabolites (exchange reactions)
% that can be secreted by the model and should be taken up and/or secreted according to
% data (true positives) and those drug metabolites that cannot be secreted by
% the model but should be secreted according to in vitro data (false
% negatives).

if exist('drugTable.txt','File')==2
    [TruePositives, FalseNegatives] = testDrugMetabolism(model, microbeID, biomassReaction);
    testResults.Drug_metabolism_TruePositives(1, 2:length(TruePositives)+1) = TruePositives;
    testResults.Drug_metabolism_FalseNegatives(1, 2:length(FalseNegatives)+1) = FalseNegatives;
end
%% Putrefaction pathways
% Performs an FVA and reports those putrefaction pathway end reactions (exchange reactions)
% that can carry flux in the model and should carry flux according to
% data (true positives) and those putrefaction pathway end reactions that
% cannot carry flux in the model but should be secreted according to in
% vitro data (false negatives).

[TruePositives, FalseNegatives] = testPutrefactionPathways(model, microbeID, biomassReaction);
testResults.PutrefactionPathways_TruePositives(1, 2:length(TruePositives)+1) = TruePositives;
testResults.PutrefactionPathways_FalseNegatives(1, 2:length(FalseNegatives)+1) = FalseNegatives;
%% Aromatic amino acid degradation
% Performs an FVA and reports those AromaticAA pathway end reactions (exchange reactions)
% that can carry flux in the model and should carry flux according to
% data (true positives) and those AromaticAA pathway end reactions that
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
% TruePositives     Cell array of strings listing all aromatic amino acid
% degradation products
% that can be secreted by the model and in comnparative genomic data.
% FalseNegatives    Cell array of strings listing all aromatic amino acid
% degradation products
% that cannot be secreted by the model but should be secreted according to comparative genomic data.

[TruePositives, FalseNegatives] = testAromaticAADegradation(model, microbeID, biomassReaction);
testResults.AromaticAminoAcidDegradation_TruePositives(1, 2:length(TruePositives)+1) = TruePositives;
testResults.AromaticAminoAcidDegradation_FalseNegatives(1, 2:length(FalseNegatives)+1) = FalseNegatives;

end