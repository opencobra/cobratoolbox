%% *Visualisation and map manipulation in Cell Designer*
%% Authors: 
%% Jennifer Modamio, Anna Danielsdottir, Systems Biochemistry group, University of Luxembourg.
%% Nicolas Sompairac, Bioinformatics and Computational Systems Biology of Cancer, Institut Curie.
%% *Reviewer(s): Ronan Fleming, Inna Kuperstein and Andrei Zinovyev. *
%% INTRODUCTION
% Visualisation of data on top of biochemical pathways is an important tool 
% for interpreting the results of constrained-based modeling. It can be an invaluable 
% aid for developing an understanding of the biological meaning implied by a prediction. 
% Biochemical network maps permit the visual integration of model predictions 
% with the underlying biochemical context. Patterns that are very difficult to 
% appreciate in a vector can often be much better appreciated by studying a generic 
% map contextualised with model predictions. Genome-scale biochemical network 
% visualisation is particularly demanding. No currently available software satisfies 
% all of the requirements that might be desired for visualisation of predictions 
% from genome-scale models.
% 
% Here we present a tool for the visualisation of computational predictions 
% from The Constraint-based Reconstruction and Analysis Toolbox (COBRA Toolbox) 
% [1] to available metabolic maps developed in CellDesigner [2].
% 
% Several maps are used in this tutorial for illustration: (i) a comprehensive 
% mitochondrial metabolic map compassing 1263 metabolic reactions extracted from 
% the latest version of the human cellular metabolism, Recon 3D [3]. (ii) Small 
% map contaning Glycolisis and TCA for faster testing and manipulation. (iii) 
% A mitochondria map combining metabolic pathways with protein-protein interactions 
% (PPI). Proteins and complexes implicated in mitochondrial reactions have been 
% extracted from the Parkinson Disease map (PDMap) [4].
% 
% In this tutorial, manipulation of CellDesgner maps in COBRA toolbox and 
% visualising model predictions is explained. The main covered topics are:
% 
% * Loading metabolic models and models containing both metabolic and regulatory 
% networks constructed in CellDesigner 
% * Detection and correction of discrepancies between map and models
% * Basic map manipulation (change color and size of nodes and reactions, directionality 
% of reactions, reaction types...) 
% * Basic model analysis visualisation (visualisation of Flux Balance Analysis) 
%% EQUIPMENT SETUP 
% To visualise the metabolic maps it is necessary to obtain the version 4.4 
% of CellDesigner. This software can be freely downloaded from: 
% 
% <http://www.celldesigner.org/download.html http://www.celldesigner.org/download.html>
%% Initialise The Cobra Toolbox and set the solver. 
% If needed, initialise the cobra toolbox.
%%
initCobraToolbox
%% 
% The present tutorial can run with <https://opencobra.github.io/cobratoolbox/deprecated/docs/cobra/solvers/changeCobraSolver.html 
% glpk package>, which does not require additional installation and configuration. 
% Although, for the analysis of large models it is recommended to use the <https://github.com/opencobra/cobratoolbox/blob/master/docs/source/installation/solvers.md 
% GUROBI> package.

changeCobraSolver('gurobi6','all')
%% Model setup. 
% In this tutorial, we provided two exclusive metabolic models. A mitochondrial 
% model and a small metabolic model specific for Glycolysis and Citric acid cycle. 
% Both models were extracted from the latest version of the database of the human 
% cellular metabolism, Recon 3D [3]. For extra information about metabolites structures 
% and reactions, and to download the latest COBRA model releases, visit the Virtual 
% Metabolic Human database (VMH, <https://vmh.life). https://vmh.life).> 
% 
% Before proceeding with the simulations, load the model into the workspace: 

modelFileName = 'Recon2.0model.mat';
modelDirectory = getDistributedModelFolder(modelFileName);
modelFileName = [modelDirectory filesep modelFileName];
model = readCbModel(modelFileName);
%% PROCEDURE
% Aforementioned, two kind of maps will be used along the tutorial. Depending 
% on the nature of the species in the map (metabolites or proteins), different 
% functions will be used to import the XML file produced in CellDesigner into 
% MATLAB.
%% 1. Import a CellDesigner XML file to MATLAB environment
%% A) Parse a Metabolic map
% The |transformXML2MatStruct| function parses an XML file from Cell Designer 
% (CD) into a Matlab structure. This structure is organised similarly to the structure 
% found in the COnstraint-Base and Reconstruction Analysis (COBRA) models.
% 
% Load two types of metabolic maps: 
% 
% # A small metabolic model representative of glycolysis and citric acid cycle. 
% # A bigger metabolic map representative of the mitochondrial metabolism. 
%%
[xml_gly, map_gly] = transformXML2MatStruct('Glycolysis_and_TCA.xml');
[xml_mitoMetab, map_mitoMetab] = ...
    transformXML2MatStruct('metabolic_mitochondria.xml');
%% 
% 
% 
% This function internally calls the function |xml2struct| which parses the 
% XML file to a general Matlab structure. Afterwards, this general structure is 
% reorganised. Due to this internal function, there are two outputs: "|xml|" is 
% the general Matlab structure obtain from |xml2struct| function, whereas "|map|" 
% is the desired final structure that could be later manipulated.
%% B) Parse a Metabolic map combined with Protein-Protein-Interactions (PPI)
% The |transformFullXML2MatStruct| function parses an XML file from Cell Designer 
% (CD) into a Matlab structure. The resultant structure contains all the information 
% commonly stored in a metabolic map, plus extra information corresponding to 
% proteins and complexes.
%%
[xml_PPI, map_PPI] = transformFullXML2MatStruct('metabolic_PPI_mitochondria.xml');
%% 
% _*NOTE! *The XML file to be parsed must be in the current folder in MATLAB 
% when executing the function._
% 
% *TIMING*
% 
% The time to parse a Cell Designer map from a XML file to a MATLAB structure 
% or vice-versa depends on the size of the map, and can vary from seconds to minutes.
%% TROUBLESHOOTING (Control error check)
% In order to properly visualise the modeling obtained during model analysis, 
% the map used for the visualisation must match with the model under study. Errors 
% in reaction or metabolite names are highly common, leading to mismatches and 
% therefore wrong representation of data.
% 
% In order to ensure a proper visualisation of the outputs coming from model 
% analysis, a control error check is highly recommended.
% 
% The function |checkCDerrors| gives four outputs summarising all possible 
% discrepancies between model and map.

[diff_reactions, diff_Metabolites, diff_reversibility, diff_formula] = ...
    checkCDerrors(map_gly, model);
%% 
% 
% 
% Four outputs are obtained from this function:
% 
% "|diff_reactions|" summarises present and absent reactions between model 
% and map.
% 
% "|diff_metabolites|" summarises present and absent metabolites. 
% 
% _*NOTE!* Note that having more metabolites and reactions in the COBRA model 
% is normal since the model can contain more elements than the map. From the other 
% hand, the map should only contain elements present in the model._
% 
%  "|diff_reversibility|" summarises discrepancies in defining the reversibility 
% of reactions.
% 
% The last output "|diff_formula"| summarises discrepancies in reactions 
% formulae (kinetic rates) and also lists duplicated reactions.
% 
% Some functions have been developed to modify attributes in the map automatically 
% from MATLAB:  
% 
% * Errors in reaction names can be manually corrected in the Matlab structure 
% with the function |correctRxnNameCD|. In the example one of the most common 
% errors is shown: spaces in names are identified as errors.
%%
correct_rxns = diff_reactions.extra_rxn_model;
map_gly_corrected = correctRxnNameCD(map_gly, ...
    diff_reactions, correct_rxns);
%% 
% * Errors in metabolites can be corrected manually or automatically by the 
% function |correctErrorMets| by giving a list of correct metabolite names. In 
% the example, |"diff_Metabolites.extra_mets_model"| correspond to the correct 
% name of wrong metabolites in "|diff_Metabolites.extra_mets_map"|.
%%
correct_mets = diff_Metabolites.extra_mets_model;
map_gly_corrected = correctMetNameCD(map_gly_corrected, ...
    diff_Metabolites, correct_mets);
%% 
% * Two functions can be used to solve errors in defining the reaction reversibility. 
% The functions |transformToReversibleMap| and |transformToIrreversibleMap|, modify 
% the reversibility of reactions in the map. Reaction lists obtained from "|diff_reversibility"| 
% can be used as an input of the next functions.
% 
% To correct a reversible reaction in the map, irreversible in the model. 
%%
map_gly_corrected = transformToIrreversibleMap(map_gly_corrected, ...
    diff_reversibility.wrong_reversible_rxns_map);
%% 
% To correct a irreversible reaction in the map, reversible in the model. 

map_gly_corrected = transformToReversibleMap(map_gly_corrected, ...
    diff_reversibility.wrong_irreversible_rxns_map);
%% 
% _*NOTE!* Reversibility errors due to base direction of the arrow can only 
% be manually fixed in Cell designer. When creating a "reversible" reaction in 
% CellDesigner, first a "irreverisble" reaction is created and has a particular 
% direction. This "base" direction can be interpreted as an error as it dictates 
% what metabolites are reactants or products._
% 
% In order to check the reaction reversibility, reaction formulae can be 
% printed from the map and model using different functions.

wrong_formula = mapFormula(map_gly, ...
    diff_reversibility.wrong_reversible_rxns_map);
%% 
% Print the same formula in the model to see the corrected formula: 

right_formula = printRxnFormula(model, ...
    diff_reversibility.wrong_reversible_rxns_map);
%% 
% Print reaction formula from the corrected file map_gly_corrected: 

corrected_formula = mapFormula(map_gly_corrected, ...
    diff_reversibility.wrong_reversible_rxns_map);
%% 
% * *Anticipated results*
% 
% Before correcting formula's errors, run the control check again. Probably 
% several errors in the output "|diff_formula|" have already been taken care of 
% when correcting previous outputs.

[diff_reactions, diff_Metabolites, diff_reversibility, diff_formula] = ...
    checkCDerrors(map_gly_corrected,model);
%% 
% _*NOTE!* Formula errors can only be manually corrected from the XML file 
% in Cell designer._
%% 2. Export the modified MATLAB structure to CellDesigner XML file
% In order to save the corrections previously made into an XML file, two functions 
% are available depending on the MATLAB structure used.
%% A) Parse a metabolic MATLAB structure
% The "|transformMatStruct2XML|" function parsed a MATLAB structure (from a 
% simple metabolic map) into a XML file.  In order to save the previous corrections 
% made.
%%
transformMatStruct2XML(xml_gly, ...
    map_gly_corrected,'Glycolysis_and_TCA_corrected.xml');
%% B) Parse a metabolic MATLAB structure combined with PPI
% As in the parsing from XML to a MATLAB structure, a different function will 
% be used when proteins and complexes are present in the map "|transformFullMatStruct2XML|".
%% Visualisation of Metabolic networks
%% EQUIPMENT SETUP
% CellDesigner uses the HTML-based colour format. This information if used to 
% modify colors of pathways of interest such as Fluxes. The function |createColorsMap| 
% contains all references for different colours HTML code to be directly recognised 
% in Cell Designer and associated to a specific name. Therefore, users wont need 
% to give a code but a colour name in capitals (143 colors are recognized).
%%
% Check the list of available colours to use in Cell designer (retrieve 143 colors) 
open createColorsMap.m
%% 
%% PROCEDURE
% Several modification can be done in the maps. All attributes can be easily 
% reached in the COBRA type MATLAB structure and modified. The colour, name, type 
% and size of nodes can be easily modified from MATLAB instead of doing it manually 
% in CellDesigner. Furthermore, other attributes such as reaction type or reversibility 
% (previously mentioned) can also be modified.
%% *1. Change reaction colour and width*
% The function |changeRxnColorAndWidth| modifies the width and colour of reactions 
% provided in the form of a list of names.
% 
% * *Anticipated results*
% 
% All reactions present in the map can be coloured if the list given is extracted 
% from the map and not from the model. See the next example: 
% 
% In the example, all reactions in the map will be coloured as Light-salmon 
% and have a width of 10 (width=1 by default). Furthermore, the newly generated 
% map will be transformed to be opened in CD.
%%
map_gly_coloured = changeRxnColorAndWidth(map_gly_corrected, ...
    map_gly_corrected.rxnName, 'LIGHTSALMON',10);
transformMatStruct2XML(xml_gly, map_gly_coloured,'map_gly_rxn_coloured.xml');
%% 
% 
% 
% _*NOTE! *in this example all reactions present in the map are being given 
% as input list. However, this list can contain a set of reactions given by the 
% user._
%% 2. Add colour to metabolites
% The function |addColourNode| adds colour to all nodes linked to a specific 
% list of reactions. Taking as an example the previous list we can modify the 
% colour of all those nodes in the map in Light-steel-blue. Furthermore, the newly 
% generated map will be transformed into a XML file.
%%
map_gly_coloured_Nodes = addColourNode(map_gly_coloured, ...
    map_gly_coloured.rxnName, 'LIGHTSTEELBLUE');
transformMatStruct2XML(xml_gly, ...
    map_gly_coloured_Nodes,'map_gly_met_coloured.xml');
%% 
% 
%% *3. Changing the colour of individual metabolite*
% It is possible to change the colour of specific metabolites in the map given 
% a list of metabolite names. Here for example we want to visualise where ATP 
% and ADP appear in order to give a global visual image of where energy is being 
% produced and consumed.
% 
% First, for an easier visualisation all metabolites present in the map will 
% be coloured in white. Afterwards, selected metabolites "mitochondrial ATP and 
% ADP" will be coloured in Red. Finally, the newly generated map will be transformed 
% into a XML file. 
%%
map_ATP_ADP = changeMetColor(map_gly, ...
    map_gly.specName, 'WHITE'); % Change the colour of all nodes in the map to white
map_ATP_ADP = changeMetColor(map_ATP_ADP, ...
    {'atp[m]'}, 'RED'); % Change specifically the colour of ATP and ADP
map_ATP_ADP = changeMetColor(map_ATP_ADP, {'adp[m]'}, 'RED');

transformMatStruct2XML(xml_gly, map_ATP_ADP, 'map_ATP_ADP_coloured.xml');
%% 
% 
% 
% Furthermore, we can also color reactions linked to specific metabolites 
% by combining functions for the COBRA models and Visualisation. The function 
% |findRxnsFromMets |identify all reactions containing specific metabolites. Here 
% we want to find reactions containing "mitochondrial ATP and ADP", and colour 
% these reactions in "aquamarine".  Moreover,the newly generated map will be transformed 
% into a XML file.

rxns_ATP_ADP = findRxnsFromMets(model,{'atp[m]';'adp[m]'});
map_ATP_ADP_rxns = changeRxnColorAndWidth(map_ATP_ADP, ...
    rxns_ATP_ADP, 'AQUAMARINE' ,10);

transformMatStruct2XML(xml_gly, map_ATP_ADP_rxns, 'map_ATP_ADP_rxns_coloured.xml');
%% 
% 
% 
% _*NOTE! *This funtion colors a list of specific metabolites whereas the 
% function |addColourNode |color all nodes linked to a specific list of reactions._
% 
% This combination of specific metabolites and reactions can be also directly 
% done using the function |modifyReactionsMetabolites| mentioned before. However, 
% using the functions described in this section, one can colour metabolites associated 
% to the same reaction and chose colours in different ways. 
%% *4. Erase coloring of the map*
% In order to better visualize small changes it might be necessary to unify 
% the rest of colours in the map. The function |unifyMetabolicMapCD| changes all 
% nodes colour to white and reactions colour to light grey and width to 1 (usually 
% set as default).
%%
map_gly_unified = unifyMetabolicMapCD(map_gly);
transformMatStruct2XML(xml_gly, map_gly_unified, 'map_gly_Unified.xml');
%% 
% 
%% *5. Change reactions and specific nodes color and width *
% The combination of previously mentioned functions can be summarise by the 
% function |modifyReactionsMetabolites.| This function colours a list of reactions 
% and specific metabolites linked to these reactions. In this example, reactions 
% containing "mitochondrial ATP and ADP" will be coloured in Dodger-blue and have 
% a width of 10. Furthremore, the two described metabolites will be also coloured. 
%%
map_gly_ATP_ADP_RXNS = modifyReactionsMetabolites(map_gly_unified, ...
    rxns_ATP_ADP , {'atp[m]';'adp[m]'}, 'DODGERBLUE', 10);
transformMatStruct2XML(xml_gly, ...
    map_gly_ATP_ADP_RXNS, 'map_gly_ATP_ADP_RXNS_all_coloured.xml');
%% 
% 
%% *6. Colour subsystems*
% The function |colorSubsystemCD| colours all reactions associated to a specific 
% subsystem in the model (a subsystem is to be understood as a metabolic pathway). 
% Furthermore changes in the width are also possible. Here three subsystems are 
% differentially coloured: Glycolysis, TCA and Pyruvate metabolism.
%%
map_subSystems = colorSubsystemCD(map_gly, ...
    model, 'Citric acid cycle', 'HOTPINK', 10);
map_subSystems = colorSubsystemCD(map_subSystems, ...
    model, 'Pyruvate metabolism', 'DARKMAGENTA' , 10);
map_subSystems = colorSubsystemCD(map_subSystems, ...
    model, 'Glycolysis/gluconeogenesis', 'SPRINGGREEN', 10);
transformMatStruct2XML(xml_gly, ...
    map_subSystems,'map_gly_subsystems_coloured.xml');
%% 
% 
%% *7. Colour reactions associated to specific genes*
% The function |colorRxnsFromGenes| colours metabolic reactions linked to a 
% gene based on a list of Entrez references. A list of mitochondria-associated 
% genes was obtained from mitocarta 2.0 [5]. Based on this list of genes, we would 
% like to know how many reactions in our metabolic map are associated to these 
% genes. 
%%
load('mitocarta_humanGenes.mat')
map_mitocarta = colorRxnsFromGenes(map_mitoMetab, model, ...
    MitocartaHuman_Genes, 'CRIMSON', 10);

transformMatStruct2XML(xml_mitoMetab, ...
    map_mitocarta, 'map_mitocarta_human_genes.xml');
%% 
% 
%% 8. Change and visualize reaction types
% One of the characteristics of CD, is the possibility to represent different 
% types of reactions depending on the interaction that needs to be ilustrated. 
% As for example, the common reaction type is named "STATE TRANSITION" (check 
% |map.rxnsType|).  Reactions can be modified manually; however it can also be 
% done automatically with the function |changeRxnType|. In the next example, we 
% identify transport reactions in Recon2 model, and we change them to "TRANSPORT" 
% type in the map. 
% 
% First, we obtain reactions associated to all transport subsystems in Recon2 
% model: 
%%
transport_mitochondria = strfind(model.subSystems, 'Transport');
index=find(~cellfun(@isempty, transport_mitochondria));
transport_reactions = model.rxns(index,1);
%% 
% Afterwards, we use this list of reactions to change the reaction type 
% in the map. As a result, all "transport" reactions in the model will be converted 
% to "transport" type in the map.

mito_map_transport = changeRxnType(map_mitoMetab, transport_reactions, 'TRANSPORT');
%% 
% Furthermore, we would like to visualize these "transport" reactions: 

mito_map_transport_coloured = colour_rxn_type(mito_map_transport, ...
    'TRANSPORT', 'DARKORCHID', 10);
transformMatStruct2XML(xml_mitoMetab, mito_map_transport_coloured, ...
    'map_mitocarta_transport_coloured.xml');
%% 
% 
%% 9. Changing the node sizes in CellDesigner
% Molecule sizes can be modified by changing their height and width with the 
% function |changeNodesArea| by giving a list of molecule names. Previously, we 
% visualized mitochondrial ATP and ADP. Here we would like to modify their size 
% in the map. The measures given are: heigth 100 and width 80.
%%
 map_nodesArea = changeNodesArea(map_gly, {'atp[m]'; 'adp[m]'}, 100, 80);
 transformMatStruct2XML(xml_gly, map_nodesArea, 'map_nodesArea.xml');
%% 
% 
% 
% _*NOTE! *Size of metabolites can be automatically modified. However coordinates 
% of metabolites in the map will remain the same. Due to this, changes in size 
% might lead to overlapping between entities._
%% TROUBLESHOOTING
% In order to come back to the default map, two functions revert the changes 
% saved in the map. |defaultColourCD| reverts the changes in reactions width and 
% colour (revert all reactions to black and width 1). Furthremore,  |defaultLookMap| 
% reverts to default reactions colour and width (black and 1) and metabolites 
% colour and size (a specific colour is given depending on metabolite type, moreover 
% the size is also given depending on metabolite relevance). 
%%
map_default = defaultColourCD(map);
map_default_all = defaultLookMap(map);
%% Functions mimicking COBRA functions for model manipulation
%% *1. Obtain logical matrices*
% Based on the COBRA model structure of the S matrix, similar matrices can be 
% created based on the map. Three logical matrices will be added to the map structure:
% 
% * S_ID: Logical matrix with rows=species_ID and columns=reactions_ID
% * S_Alias: Logical matrix with rows=species_Alias and columns=reactions_ID
% * ID_Alias: Logical matrix with rows=species_ID and columns=species_Alias
% 
% These matrices will be added to the map structure by the function |getMapMatrices|.
%%
map_gly_corrected = getMapMatrices(map_gly_corrected);
%% 
% 
% 
% _*NOTE!* To use these matrices with COBRA, this function should be used 
% with Metabolic only maps. An error will occur if used with PPI maps!_
%% *2. Research of indexes in the map structure*
% Basic functions were created to simplify the manipulation of maps. 
% 
% The function |findRxnsPerType| gives a list of desired reactions based 
% on the reaction type (2nd colum), and the index for those reactions in |map.rxnName| 
% (1st colum). 
%%
transport_reactions_index_list = findRxnsPerType(map_gly_corrected, 'TRANSPORT');
%% 
% The function |findMetIDs| finds the IDs of specific metabolites in |map.specName| 
% given a list of metabolites.  

ATP_ADP_index_list = findMetIDs(map_gly_corrected, ...
    {'atp[c]', 'adp[c]', 'atp[m]', 'adp[m]'});
%% 
% The function |findRxnIDs| finds the IDs of specific reactions in |map.rxnName| 
% given a list of reactions.

rxn_of_interest_index_list = findRxnIDs(map_gly_corrected, ...
    {'FBP', 'FBA', 'GAPD', 'PFK', 'ENO'});
%% 
% The function |findMetFromCompartMap| finds all metabolites in the map 
% associated to a specific compartment by looking at the composition of metabolite 
% names (example: mitochondrial atp = atp*[m]*). 

[mitochondrial_mets_name_list,mitochondrial_mets_index_list] = ...
    findMetFromCompartMap(map_gly_corrected, '[m]');
%% 
% The function |findRxnFromCompartMap| finds all reactions in the map associated 
% to a specific compartment by looking at the composition of metabolite names. 

mitochondrial_rxns_index_list = findRxnFromCompartMap(map_gly_corrected, '[m]');
%% Visualisation of Metabolic and PPI networks
% Some of the aforementioned functions were addapted to be used in metabolic 
% and PPi maps. Some examples are shown below:  
%% *1. Change protein colour based on a list of proteins*
% A list of proteins of interest can be highlighted in the map. Here we extract 
% a list of proteins associated to the mitochondrial compartment from PDmap [4].
% 
% First, we load the protein list. 
%%
load('mitochondrial_proteins_PDmap.mat')
%% 
%  Then, we would like to identify those proteins in our map. 

map_coloured_proteins = colorProtein(map_PPI, ...
    mitochondrial_proteins_PDmap(:,1), 'BLACK');
transformFullMatStruct2XML(xml_PPI, ...
    map_coloured_proteins, 'map_coloured_proteins.xml');
%% 
% 
% 
% _*NOTE!* A gene can codify for more than one protein. An association protein-gene-metabolicReaction 
% doesn't have to be true. Manual curation would be required in this step._
%% TROUBLESHOOTING
% In order to come back to the default map, two functions revert the changes 
% saved in the map. |defaultColorCD| reverts the changes in reactions width and 
% colour (revert all reactions to black and width 1). Furthermore, |defaultColorAndSizeCDMap| 
% reverts to default reactions and nodes (colour and size).
%%
map2 = unifyMetabolicPPImapCD(map_PPI);
transformFullMatStruct2XML(xml_PPI, map2, 'map_PPI_unified.xml');
%% 
% 
%% Specific visualisation for model analysis:
%% *Visualise results from Flux Balance analysis (FBA)*
% Flux balance analysis is a mathematical approach for analysing the flow of 
% metabolites through a metabolic network. This flow can be added to a parsed 
% XML Matlab structure and visualised a posteriori in CellDesigner.
% 
% First, it would be necessary to select an objective function. Since the 
% map represented is a mitochondria (main organelle responsible for energy production 
% in the cell), we would maximize ATP production through complex V in the electron 
% transport chain. 
%%
formula_ATPS4m = printRxnFormula(modelMito_3D, 'ATPS4m');
model = changeObjective(modelMito_3D, 'ATPS4m');
FBAsolution = optimizeCbModel(model, 'max');
%% 
% The output |FBAsolution| will be afterwards used as input. The width assigned 
% to each reaction in the map is directly related to the flux carried by the reaction 
% in FBA. 
% 
% Two types of visualisation are available: 
% 
% * For a basic visualisation of fluxes |addFluxFBA| can be used:  

map_general_ATP = addFluxFBA(map_mitoMetab, modelMito_3D, ...
    FBAsolution, 'MEDIUMAQUAMARINE');
transformMatStruct2XML(xml_mitoMetab, map_general_ATP, 'FBA_flux.xml');
%% 
% * For a more specific visualisation including directionality of reactions, 
% |addFluxFBAdirectionAndcolour| function can be used:

map_specific_ATP = addFluxFBAdirectionAndcolour(map_mitoMetab, ...
    modelMito_3D, FBAsolution);
transformMatStruct2XML(xml_mitoMetab, ...
    map_specific_ATP, 'FBA_flux_directionalyty.xml');
%% Visualize gene expression
% A Cytoscape plugin [6] is available to visualize gene expression on top of 
% a network map generated from CellDesigner: *BiNoM* [7].
%% Writing information about models to map
% Information from the models specific to each reaction or metabolite can be 
% retrieved from the models and added to the CellDesigner map in notes.
%%
map_gly_corrected_notes = addNotes(model, map_gly_corrected);
transformMatStruct2XML(xml_gly, map_gly_corrected_notes, 'map_gly_notes.xml');
%% 
% 
% 
% # Hyduke D. COBRA Toolbox 2.0. _Nature Protocols _(2011). 
% # Thiele, I., et al. "A community-driven global reconstruction of human metabolism". 
% _Nat. Biotechnol.,_ 31(5), 419-425 (2013).
% # Funahashi A.  "CellDesigner: a process diagram editor for gene-regulatory 
% and biochemical networks". _BIOSILICO_, 1:159-162, (2003).
% # Kazuhiro A. "Integrating Pathways of Parkinson's Disease in a Molecular 
% Interaction Map". _Mol Neurobiol_. 49(1):88-102 (2014).
% # Calvo SE. "MitoCarta2.0: an updated inventory of mammalian mitochondrial 
% proteins". _Nucleic Acids Res_. 4;44(D1):D1251-7 (2016).
% # Shannon, Paul et al. “Cytoscape: A Software Environment for Integrated Models 
% of Biomolecular Interaction Networks.” _Genome Research_ 13.11 (2003): 2498–2504. 
% _PMC_. Web. 5 Dec. (2017).
% # Bonnet E. et al, "BiNoM 2.0, a Cytoscape plugin for accessing and analyzing 
% pathways using standard systems biology formats". _BMC Syst Biol._ 1;7:18 (2013).