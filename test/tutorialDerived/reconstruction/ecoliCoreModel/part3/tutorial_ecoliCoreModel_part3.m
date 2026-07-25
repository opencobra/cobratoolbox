%% _E.coli_ Core Model for Beginners (PART 3)
% (please run PART 2 of this tutorial first)
%% 4.C. Pentose Phosphate Pathway 
% The primary purpose of the pentose phosphate pathway (PPP) is to provide the 
% 4-, 5- and 7-carbon precursors for the cell and produce nadph[c]. The 4-, 5- 
% and 7-carbon precursors include D-erythrose-4-phosphate (e4p[c]), alpha-D-ribose-5-phosphate, 
% (r5p[c]), and sedoheptulose-7-phosphate (s7p[c]), respectively.  The nadph[c] 
% is produced in the oxidative pathway by glucose-6-phosphate dehydrogenase (G6PDH2r) 
% and phosphogluconate dehydrogenase (GND).
% 
% The location of the reactions associated with the PPP are shown below on the 
% _E.coli_ core map in Figure 16.
% 
% 
% 
% *Figure 16.* Pentose phosphate pathway subsystem reactions highlighted in 
% blue on the _E.coli_ core map [3].
% 
% The pentose phosphate pathway subsystem includes the following reactions derived 
% from the core model. _[Timing: Seconds]_

model = e_coli_core; % Starting with the original model
model = changeRxnBounds(model,'EX_glc(e)',-10,'l');
model = changeRxnBounds(model,'EX_o2(e)',-30,'l');
model = changeObjective(model,'Biomass_Ecoli_core_w_GAM');
pppSubsystem = {'Pentose Phosphate Pathway'};
pppReactions = model.rxns(ismember(model.subSystems,pppSubsystem));
[~,ppp_rxnID] = ismember(pppReactions,model.rxns);
Reaction_Names = model.rxnNames(ppp_rxnID);
Reaction_Formulas = printRxnFormula(model,pppReactions,0);
T = table(Reaction_Names,Reaction_Formulas,'RowNames',pppReactions)    
%% 
% There are two distinct phases of the pentose phosphate pathway. The first 
% is the "oxidative phase," in which nadph[c] is generated. Note that the pentose 
% phosphate pathway is not the only source of nadph[c] in aerobic conditions. 
% This was explored using "surftNet" in the energy management section (Section 
% 4.A ).  The second phase of the pentose phosphate pathway is referred to as 
% the "non-oxidative" phase that provides a pathway for the synthesis of 4-, 5-, 
% and 7-carbon precursors in anaerobic conditions. The pentose phosphate pathway 
% reactions and supported precursors are shown in the Figure17 below.
% 
% 
% 
% *Figure 17.* Pentose phosphate pathway reactions and precursors [3].
% 
% The direction of the flux flowing through the non-oxidative part of the pentose 
% phosphate pathway changes based on aerobic versus anaerobic conditions. This 
% variation in flux direction is shown below in Figure 18.
% 
% 
% 
% *Figure 18.* The flow of flux through the pentose phosphate pathway based 
% on A) aerobic or B) anaerobic conditions. 
% 
% In this figure it can be seen that under (A) aerobic conditions the flux flows 
% through the oxidative phase of the pentose phosphate pathway and then is directed 
% downward through the non-oxidative phase and then works its way back to the 
% glycolysis cycle. On the other hand, under (B) anaerobic conditions the flux 
% enters the left side of reaction TKT2 of the pentose phosphate pathway from 
% the glycolysis pathway operating under the condition of gluconeogenesis. The 
% flux then splits to feed the needs of the three major precursors e4p[c], r5p[c], 
% and s7p[c]. These specific flux values can be calculated using the COBRA Toolbox 
% as follows. _[Timing: Seconds]_

% Obtain the rxnIDs for the pentose phosphate pathway reactions
[~,glycolysis_rxnID] = ismember(glycolysisReactions,model.rxns); 

% Glucose aerobic flux
FBAsolution = optimizeCbModel(model,'max',0,0);
Glucose_Aerobic_Flux = round(FBAsolution.x(ppp_rxnID),3);

% Fructose aerobic flux
model = changeRxnBounds(model,'EX_glc(e)',-0,'l');
model = changeRxnBounds(model,'EX_fru(e)',-10,'l');
FBAsolution = optimizeCbModel(model,'max',0,0);
Fructcose_Aerobic_Flux = round(FBAsolution.x(ppp_rxnID),3);

% Set anaerobic conditions
model = changeRxnBounds(model,'EX_o2(e)',-0,'l');

% Glucose anaerobic flux
model = changeRxnBounds(model,'EX_glc(e)',-10,'l');
FBAsolution = optimizeCbModel(model,'max',0,0);
Glucose_Anaerobic_Flux = round(FBAsolution.x(ppp_rxnID),3);

% Fructose anaerobic flux
model = changeRxnBounds(model,'EX_glc(e)',-0,'l');
model = changeRxnBounds(model,'EX_fru(e)',-10,'l');
FBAsolution = optimizeCbModel(model,'max',0,0);
Fructose_Anaerobic_Flux = round(FBAsolution.x(ppp_rxnID),3);

T = table(Glucose_Aerobic_Flux,Fructcose_Aerobic_Flux,Glucose_Anaerobic_Flux,...
    Fructose_Anaerobic_Flux,'RowNames',pppReactions)
%% 4.D. Tricarboxylic Acid Cycle
% The tricarboxylic acid (TCA) cycle or the citric acid cycle supports a variety 
% of cellular functions depending on the environment. Under aerobic conditions 
% the TCA cycle operates in a counter-clockwise direction using acetyl-CoA as 
% a substrate to produce three cellular precursors, reducing power nadh[c] and 
% nadph[c], cellular energy atp[c] through substrate phosphorylation, and carbon 
% dioxide (co2[c]). While in the anaerobic condition, only part of the TCA cycle 
% will be used to produce two of the three precursors and the reducing power nadph[c]. 
% The location of the TCA cycle subsystem is shown on the following _E.coli_ core 
% map (Figure 19).
% 
% 
% 
% *Figure 19.* TCA pathway subsystem reactions highlighted in blue on _E.coli_ 
% core map [3].
% 
% The reactions associated with the TCA cycle can be retrieved from the _E.coli_ 
% core model as shown below. _[Timing: Seconds]_

model = e_coli_core;
TCA_Reactions = transpose({'CS','ACONTa','ACONTb','ICDHyr','AKGDH','SUCOAS',...
    'FRD7','SUCDi','FUM','MDH'});
[~,TCA_rxnID] = ismember(TCA_Reactions,model.rxns);
Reaction_Names = model.rxnNames(TCA_rxnID);
Reaction_Formulas = printRxnFormula(model,TCA_Reactions,0);
T = table(Reaction_Names,Reaction_Formulas,'RowNames',TCA_Reactions)    
%% 
% The _E.coli_ core model does not include the membrane reactions (FRD7 and 
% SUCDi) in the TCA cycle (Citric Acid Cycle) subsystem. They have been added 
% to this discussion since they close the TCA loop and allow complete TCA operation.
% 
% The precursors associated with the TCA cyle are shown below in Figure 20.  
% The precursors include; 1) oxaloacetate (oaa[c]) for the biosynthesis of asparagine, 
% aspartic acid, isoleucine, lysine, methionine, and threonine, 2) 2-oxoglutarate 
% or alpha-ketoglutarate (akg[c]) for the biosynthesis of arginine, glutamine, 
% glutamic acid, and proline and finally 3) succinyl-CoA (succoa[c]) for heme 
% biosynthesis.
% 
% 
% 
% *Figure 20.* TCA pathway reactions and precursors [3].
% 
% The TCA cycle can be divided into an oxidative pathway and a reductive pathway 
% as illustrated in Figure 19. The oxidative pathway of the TCA cycle runs counterclockwise 
% in the lower part of the cycle, from oxaloacetate (oaa[c]), through 2-oxoglutarate 
% (akg[c]). Under aerobic conditons the oxidative pathway can continue counterclockwise 
% from 2-oxoglutarate (akg[c]) full circle to  oxaloacetate (oaa[c]). The full 
% TCA cycle can totally oxidize acetyl-CoA (accoa[c]), but only during aerobic 
% growth on acetate or fatty acids. 
% 
% Under anaerobic conditions, the TCA cycle functions not as a cycle, but as 
% two separate pathways. The oxidative pathway, the counterclockwise lower part 
% of the cycle, still forms the precursor 2-oxoglutarate. The reductive pathway, 
% the clockwise upper part of the cycle, can form the precursor succinyl-CoA.
% 
% Let's begin this exploration by visualizing the fluxes through the core model 
% when pyruvate is used as the carbon source for both aerobic and anaerobic conditions. 
% _[Timing: Seconds]_

% Key parameters for TCA pathway section
model = e_coli_core;
model = changeRxnBounds(model,'EX_glc(e)',-0,'l'); 
model = changeRxnBounds(model,'EX_pyr(e)',-20,'l'); 
model = changeRxnBounds(model,'EX_o2(e)',-30,'l'); % Set at -30 for aerobic
model = changeObjective(model,'Biomass_Ecoli_core_w_GAM'); 
FBAsolution = optimizeCbModel(model,'max',0,0);

% Import E.coli core map and adjust parameters
map=readCbMap('ecoli_core_map.txt');
options.zeroFluxWidth = 0.1;
options.rxnDirMultiplier = 10;
drawFlux(map, model, FBAsolution.x, options);   
%% 
% A close-up on the TCA cycle for both the aerobic and anaerobic cases are shown 
% in Figure 21.
% 
% 
% 
% *Figure 21.* A close-up of the TCA cycle with pyruvate as the carbon source 
% for both aerobic and anaerobic conditions.
% 
% The specific flux values for each of these conditions is calculated below. 
% _[Timing: Seconds]_

model = e_coli_core;
% Pyruvate aerobic flux
model = changeRxnBounds(model,'EX_glc(e)',-0,'l'); 
model = changeRxnBounds(model,'EX_pyr(e)',-20,'l'); 
model = changeRxnBounds(model,'EX_o2(e)',-30,'l'); 
FBAsolution = optimizeCbModel(model,'max',0,0);
Pyrvate_Aerobic_Flux = round(FBAsolution.x(TCA_rxnID),3);

% Pyruvate anaerobic flux
model = changeRxnBounds(model,'EX_o2(e)',-0,'l');
FBAsolution = optimizeCbModel(model,'max',0,0);
Pyrvate_Anaerobic_Flux = round(FBAsolution.x(TCA_rxnID),3);

T = table(Pyrvate_Aerobic_Flux,Pyrvate_Anaerobic_Flux,...
    'RowNames',TCA_Reactions)
%% 
% These fluxes show that under aerobic conditions the full TCA cyle is operational 
% while under anaerobic conditions only the lower part of the TCA cycle (CS, ACONTa, 
% ACONTb and ICDHyr), the oxidative pathway, is used.
%% *4.E. Glycoxylate Cycle, Gluconeogenesis, and Anapleurotic Reactions*
% The glycoxylate cycle and gluconeogenic reactions are necessary to allow _E. 
% coli_ to grow on 3-carbon (pyruvate) and 4-carbon compounds (malate, fumarate, 
% and succinate). This occurs by avoiding the loss of carbon to carbon dioxide 
% in the TCA cycle (glycoxylate cycle), providing a pathway for generation of 
% glycolytic intermediates from TCA intermediates (anapleurotic reactions), and 
% reversing the carbon flux through glycolysis (gluconeogenesis) to produce essential 
% precursors for biosynthesis.
% 
% The location of the glycoxylate cycle, gluconeogenesis, and anapleurotic reactions 
% on the _E.coli_ core map is shown in Figure 22 below.
% 
% 
% 
% *Figure 22.* Glycoxylate cycle, gluconeogenesis, and anapleurotic reactions 
% highlighted in blue on the _E.coli_ core map [3].
% 
% The reactions included in this section on the glycoxylate cycle, gluconeogenesis, 
% and anapleurotic reactions are shown below.  This subsystem is referred to in 
% the core model as the "anapleurotic reactions" subsystem.  _[Timing: Seconds]_

% Set initial constraints for glycoxylate cycle, gluconeogenesis, and anapleurotic reactions section
model = e_coli_core;
ANA_Reactions = transpose({'ICL','MALS','ME1','ME2','PPS','PPCK',...
    'PPC'});
[~,ANA_rxnID] = ismember(ANA_Reactions,model.rxns);
Reaction_Names = model.rxnNames(ANA_rxnID);
Reaction_Formulas = printRxnFormula(model,ANA_Reactions,0);
T = table(Reaction_Names,Reaction_Formulas,'RowNames',ANA_Reactions)  
%% 
% These individual reactions associated with the glycoxylate cycle, gluconeogenesis, 
% and anapleurotic reactions are graphically shown in Figure 23. 
% 
% 
% 
% *Figure 23.* Reactions associated with the glycoxylate cycle, gluconeogenesis, 
% and anapleurotic reactions [3].
% 
% The anapleurotic reactions (PPC, PPS, PPCK, PPC, ME1, and ME2 ) are interconnecting, 
% reversing and bypassing reactions that replenish TCA cycle intermediates. The 
% glycoxylate cycle (CS, ACONTa, ACONTb, ICL, MALS, MDH, SUCDi and FUM), which 
% includes some TCA cycle reactions, is essential for growth on 3-carbon (pyruvate) 
% and 4-carbon compounds since it can convert the precursor acetyl-CoA into glycolytic 
% intermediates without loss of carbon to carbon dioxide (ICDHyr & AKGDH). Finally, 
% growth on 4-carbon intermediates of the TCA cycle, such as malate, requires 
% that the cell be able to produce phosphoenolpyruvate (pep[c]) for gluconeogenesis. 
% Gluconeogenesis refers to the reversal of flux through the glycolytic pathway. 
% There are two pathways able to fulfill these pep[c] demands. The first pathway 
% involves the conversion of malate (mal[c]) to pyruvate (pyr[c]) by a malic enzyme 
% (ME1 or ME2). This is followed by the synthesis of pep[c] from pyr[c] by phosphoenolpyruvate 
% synthase (PPS)_._ Malic enzyme (ME1_)_ reduces one molecule of nad[c] to nadh[c] 
% while converting mal[c] to pyr[c]. A second parallel reaction, ME2 reduces one 
% molecule of nadp[c]  to nadph[c].
% 
% Now it is time to explore the the impact on the cell of these pathways for 
% different carbon sources. Let's begin by looking at the aerobic operation of 
% the cell growing on acetate. _[Timing: Seconds]_

% Key parameters for TCA pathway section
model = e_coli_core;
model = changeRxnBounds(model,'EX_glc(e)',-0,'l'); 
model = changeRxnBounds(model,'EX_ac(e)',-10,'l'); 
model = changeRxnBounds(model,'EX_o2(e)',-30,'l'); % Set at -30 for aerobic
model = changeObjective(model,'Biomass_Ecoli_core_w_GAM'); 

% Perform FBA with Biomass_Ecoli_core_N(w/GAM)_Nmet2 as the objective, 
FBAsolution = optimizeCbModel(model,'max',0,0);

% Import E.coli core map and adjust parameters
map=readCbMap('ecoli_Textbook_ExportMap');
options.zeroFluxWidth = 0.1;
options.rxnDirMultiplier = 10;
% Draw the flux values on the map "target.svg" which can be opened in FireFox
drawFlux(map, model, FBAsolution.x, options);    
%% 
% A copy of the figure stored in "target.svg" is shown in Figure 24.
% 
% 
% 
% *Figure 24.* Screenshot of the core model with acetate as the carbon source 
% under aerobic conditions.
% 
% The active fluxes for this simulaton are given below. _[Timing: Seconds]_

printFluxVector(model,FBAsolution.x,true) % only prints nonzero fluxes
%% 
% It can be seen, using the map and the fluxes listed above, that acetate enters 
% the network at the bottom and flows into the TCA cycle. From there it can be 
% observed that not only is the full TCA cycle operational but so is the glycoxolate 
% cycle. Part of the oaa[c] metabolite flux is then directed through the glycolysis 
% pathway (gluconeogenesis) to the pentose phosphate pathway to create the 4-, 
% 5- and 7-carbon precursors precursors. 
%% 
% Using malate as a carbon source under aerobic conditions is another good example 
% of the role of the glycoxylate cycle, gluconeogenesis, and anapleurotic reactions. 
% The Matlab/COBRA Toolbox code for this example is shown below. _[Timing: Seconds]_

model = e_coli_core;
model = changeRxnBounds(model,'EX_glc(e)',-0,'l'); 
model = changeRxnBounds(model,'EX_mal_L(e)',-10,'l'); 
model = changeRxnBounds(model,'EX_o2(e)',-30,'l'); % Set at -30 for aerobic
model = changeObjective(model,'Biomass_Ecoli_core_w_GAM'); 

% Perform FBA with Biomass_Ecoli_core_N(w/GAM)_Nmet2 as the objective, 
FBAsolution = optimizeCbModel(model,'max',0,0);

% Import E.coli core map and adjust parameters
map=readCbMap('ecoli_Textbook_ExportMap');
options.zeroFluxWidth = 0.1;
options.rxnDirMultiplier = 10;
drawFlux(map, model, FBAsolution.x, options);    
%% 
% A screenshot of the figure stored in "target.svg" is shown in Figure 25.
% 
% 
% 
% *Figure 25.* COBRA Toolbox produced map showing aerobic operation with malate 
% as the carbon source.
% 
% The active fluxes for this simulaton are given below. _[Timing: Seconds]_

printFluxVector(model,FBAsolution.x,true) % only prints nonzero fluxes
%% 
% In this situation, the malate enters the network from the top and flows to 
% the TCA cycle. Part of the malate metabolite flux is converted to be used as 
% the pyruvate precursor while the rest enters the fully operational TCA cycle. 
% Note that the glycoxolate cycle is inactive. Part of the oaa[c] metabolite flux 
% is then directed through the glycolysis pathway (gluconeogenesis), to the pentose 
% phosphate pathway, to create the 4-, 5- and 7-carbon precursors.
%% 4.F. Fermentation
% Fermentation is the process of extracting energy from the oxidation of organic 
% compounds without oxygen. The location of the fermentation reactions on the 
% _E.coli_ core map are shown in the Figure 26.
% 
% 
% 
% *Figure 26.* Fermentation reactions highlighted in blue on the _E.coli_ core 
% map [3].
% 
% The reactions associated with the fermentation pathways include: _[Timing: 
% Seconds]_

% Set initial constraints for fermentation metabolism section
model = e_coli_core;
FERM_Reactions = transpose({'LDH_D','D_LACt2','PDH','PFL','FORti','FORt2',...
    'PTAr','ACKr','ACALD','ALCD2x','ACt2r','ACALDt','ETOHt2r'});
[~,FERM_rxnID] = ismember(FERM_Reactions,model.rxns);
Reaction_Names = model.rxnNames(FERM_rxnID);
Reaction_Formulas = printRxnFormula(model,FERM_Reactions,0);
T = table(Reaction_Names,Reaction_Formulas,'RowNames',FERM_Reactions)   
%% 
% The reactions, GRPA relationships, and precursors for this section on fermentation 
% are shown in Figure 27 below.
%% 
% *Figure 27.* Reactions, GRPA relationships, and precursors for the fermentation 
% metabolism [3].
% 
% During aerobic respiration, oxygen is used as the terminal electron acceptor 
% for the oxidative phosphorylation process yielding the bulk of atp[c] required 
% for cells biosynthesis. Anaerobic respiration, on the other hand, refers to 
% respiration without molecular oxygen. In this case, _E. coli_ can only generate 
% atp[c] through substrate level phosphorylation which significantly reduces the 
% amount of atp[c] that can be produced per molecule of glucose. In anaerobic 
% conditions, glycolysis results in the net production of 2 atp[c] per glucose 
% by substrate level phosphorylation. This is compared to the total of 17.5 atp[c] 
% per glucose molecule that can be produced for aerobic respiration [1]. To maintain 
% the necessary energy needed for cellular operation during anaerobic growth, 
% this forces each cell to maintain a large magnitude of flux through the glycolysis 
% pathway to generate the necessary atp[c] to meet the cells growth requirements. 
% This results in a large magnitude efflux of fermentative end products (lactate(lac-D[c]), 
% formate (for[c]), acetate (ac[c]), acetaldehyde (acald[c]), and ethanol (etoh[c])) 
% since there is insufficient atp[c] to assimilate all the carbon into biomass. 
% It should be pointed out that only ~10% of carbon substrate is effectively assimilated 
% into the cell due to the poor energy yield of fermentation.
% 
% There are two main fermentive processes included in the core model; homolactic 
% fermentation and mixed acid fermentation. Homolactic fermentation refers to 
% the conversion of pyruvate to lactate as shown on the bottom left of Figure 
% 26 and includes the reactions LDH_D and D_LACt2 . Mixed acid fermentation is 
% the process that converts pyrvate into a mixture of end products including lactate, 
% acetate, succinate, formate, ethanol and includes the following reactions; PDH, 
% PFL, FORti, FORt2, PTAr, ACKr, ACALD, ALCD2x, ACt2r, ACALDt, and ETOHt2r. It 
% should also be pointed out that the end products of each fermentation pathway, 
% with the exception of acetaldehyde, exit the cell along a concentration gradient 
% and transport a proton from the cytoplasm into the extracellular space.
% 
% Let's begin our exploration of the fermentation metabolism by determining 
% the secreted bioproducts produced in anaerobic conditions with a glucose carbon 
% source.  _[Timing: Seconds]_

model = e_coli_core;
model = changeRxnBounds(model,'EX_glc(e)',-10,'l');  
model = changeRxnBounds(model,'EX_o2(e)',0,'l'); % Anaerobic
model = changeObjective(model,'Biomass_Ecoli_core_w_GAM'); 
FBAsolution = optimizeCbModel(model,'max',0,0);
printFluxVector(model,FBAsolution.x,true, true) % only prints nonzero fluxes
%% 
% With these results we can see that acetate, ethanol, and formate are the mixed 
% fermentation products. Figure 12 shows the cell in this anaerobic condition. 
% Note the flux flow in the paths of the secreted mixed acid fermentation products. 
% Now let's explore the producers and consumers of atp[c] in anaerobic conditions 
% with a glucose carbon source using "surfNet". _[Timing: Seconds]_

surfNet(model,'atp[c]',0,FBAsolution.x,1,1)
%% 
% Note that all the atp[c] is produced through substrate phosphorylation through 
% PGK and PYK in the glycolysis pathway and ACKr in the fermentation pathway that 
% produces acetate. Now let's check to see if the majority of the produced nadh[c] 
% is reduced to nad[c] by the fermentation pathways. _[Timing: Seconds]_

surfNet(model,'nadh[c]',0,FBAsolution.x,1,1)
%% 
% In this case we can see that the nadh[c] produced in the glycolysis pathway 
% is either oxidized to nad[c] in the ethanol pathway (ACALD, ALCD2x) or converted 
% to nadph[c] for cell biosynthesis through the energy management reactions (THD2).
% 
% Now let's expore the impact of pyruvate as the carbon sources in an anaerobic 
% environment. _[Timing: Seconds]_

% Key parameters for fermentation section
model = e_coli_core;
model = changeRxnBounds(model,'EX_glc(e)',-0,'l'); 
model = changeRxnBounds(model,'EX_pyr(e)',-20,'l'); 
model = changeRxnBounds(model,'EX_o2(e)',-0,'l'); % Set at -30 for aerobic
model = changeObjective(model,'Biomass_Ecoli_core_w_GAM'); 

% Perform FBA with Biomass_Ecoli_core_N(w/GAM)_Nmet2 as the objective, 
FBAsolution = optimizeCbModel(model,'max',0,0);

% Import E.coli core map and adjust parameters
map=readCbMap('ecoli_core_map');
options.zeroFluxWidth = 0.1;
options.rxnDirMultiplier = 10;
drawFlux(map, model, FBAsolution.x, options); 
%% 
% A screenshot of that map is shown below (Figure 28).
% 
% 
% 
% *Figure 28.* Screenshot of the core network with pyruate as the carbon source 
% in an anaerobic environment. 
% 
% From this map we can see that as the pyruvate enters the cell, part of the 
% flux is directed upward through the glycolysis pathway (gluconeogenesis) to 
% the pentose phosphate pathway to create the 4-, 5- and 7-carbon precursors. 
% Part of the flux is also directed to the TCA cycle to feed the nitrogen metabolism, 
% with the remaining flux being directed through the fermentation pathways to 
% produce formate, acetate, and some atp[c] through substrate phosphorylation. 
% 
% The flux values for this condition are calculated below. _[Timing: Seconds]_

printFluxVector(model,FBAsolution.x,true) % only prints nonzero reactions
%% 4.G. Nitrogen Metabolism
% The final subsystem to be discussed in this tutorial is the nitrogen metabolism. 
% Nitrogen enters the cell as either ammonium ion (nh4[c]), or as a moiety within 
% glutamine (glu-L[c]) or glutamate (gln-L[c]). The _E.coli_ core model covers 
% the pathways between 2-oxoglutarate, L-glutamate, and L-glutamine. The location 
% of the nitrogen metabolism reactions on the _E.coli_ core map is shown in Figure 
% 29.
% 
% 
% 
% *Figure 29.* Nitrogen metabolism reactions highlighted in blue on the _E.coli_ 
% core map [3].
% 
% The reactions of the nitrogen metabolism include: _[Timing: Seconds]_

% Set initial constraints for nitrogen metabolism section
model = e_coli_core;
NIT_Reactions = transpose({'GLNabc','GLUt2r','GLUDy','GLNS','GLUSy','GLUN'});
[tmp,NIT_rxnID] = ismember(NIT_Reactions,model.rxns);
Reaction_Names = model.rxnNames(NIT_rxnID);
Reaction_Formulas = printRxnFormula(model,NIT_Reactions,0);
T = table(Reaction_Names,Reaction_Formulas,'RowNames',NIT_Reactions)   
%% 
% The reactions, GRPA relationships, and precursors for this section on the 
% nitrogen metabolism are shown in the Figure 30 below.
% 
% 
% 
% *Figure 30.* Reactions GRPA relationships, and precursors associated with 
% the nitrogen metabolism [3].
% 
% Note that the precursors supported by nitrogen metaboism are proline and arginine. 
% 
% In this simple model, one of the potential sources of nitrogen is through 
% ammonium which is transported into the cell through a transporter (NH4t). Within 
% the cell there are only two reactions (GLNS, GLUDy) that can also assimulate 
% the needed nitrogen into the cell. This can be seen using the "surfNet" function. 
% _[Timing: Seconds]_

surfNet(model,'nh4[c]',0,FBAsolution.x,1,1)
%% 
% Nitrogen can also enter the cell through the uptake of glutamate or glutamine. 
% As a reminder, the default settings for the core model do not allow any amino 
% acids to enter the core model. To change this you would need to use the "changeRxnBounds" 
% COBRA Toolbox function to allow either glutamate or gluamine uptake capability.
% 
% Both glutamate and glutamine can serve as both carbon and nitrogen sources 
% under aerobic conditions. An example of glutamate serving as both carbon and 
% nitrogen source is shown in the COBRA code and Figure 31 below. _[Timing: Seconds]_

% Key parameters for fermentation section
model = e_coli_core;
model = changeRxnBounds(model,'EX_glc(e)',-0,'l'); 
model = changeRxnBounds(model,'EX_glu_L(e)',-20,'l'); 
model = changeRxnBounds(model,'EX_nh4(e)',-0,'l'); 
model = changeRxnBounds(model,'EX_o2(e)',-30,'l'); % Set at -30 for aerobic
model = changeObjective(model,'Biomass_Ecoli_core_w_GAM'); 

% Perform FBA with Biomass_Ecoli_core_N(w/GAM)_Nmet2 as the objective, 
FBAsolution = optimizeCbModel(model,'max',0,0);

% Import E.coli core map and adjust parameters
map=readCbMap('ecoli_core_map');
options.zeroFluxWidth = 0.1;
options.rxnDirMultiplier = 10;
drawFlux(map, model, FBAsolution.x, options); 
%% 
% 
% 
% *Figure 31.* A screenshot of glutamate serving as both carbon and nitrogen 
% source. 
% 
% In this figure, it can be seen that glutamate enters the cell in the lower 
% right. It passes through the nitrogen metabolism producing 2-oxogluarate (akg[c]) 
% which then feeds the upper part of the TCA cycle. The anapleurotic reactions 
% and gluconeogenesis support the flux necessary to create the  the 4-, 5- and 
% 7-carbon precursors. Part of the flux from the TCA cycle is also directed to 
% the fermentation pathway precursors in addition to secreting both formate and 
% acetate. 
% 
% The fluxes for this example are shown below: _[Timing: Seconds]_

printFluxVector(model,FBAsolution.x,true) % only prints nonzero reactions
%% 
% Since the normal source of nadh[c] from the glycolysis pathway is not availabe 
% during gluconeogenesis, let's explore where the nadh[c] is produced and consumed. 
% _[Timing: Seconds]_

surfNet(model,'nadh[c]',0,FBAsolution.x,1,1)
%% 
% We can see here that there are many sources of nadh[c] production including: 
% AKGDH and MDH from the reductive pathways of the TCA cycle, the anapleurotic 
% reaction ME1, PDH from the fermentation metabolism, and even with the energy 
% management reactions where excess nadph[c] is converted to nadh[c]. The consumers 
% are primarily NADH16 where it provides the reducing power necessary for the 
% electron transport chain and GAPD which is required for the operaton of gluconeogenesis.
%% 5. Conclusion
% This wraps up the tutorial on the _E.coli_ core model. It has attempted to 
% show how the COBRA toolbox can be used to explore a genome-scale metabolic network 
% reconstruction using the core model as an example. Now with this beginning skill 
% set you can start exploring the larger and more accurate network reconstructions!
%% 6. *Reflective Questions*
%% 
% * What is the difference between glycolysis and gluconeogenesis?
% * What reactions make-up the glycolysis pathway?
% * What metabolites are created in the glycolysis pathway?
% * What is the final metabolite created by the glycolysis pathway?
% * What are the biosynthetic precursors created by the glycolysis pathway?
% * What are the biosynthetic precursors created by the pentose phosphate pathway?
% * What is the difference between the oxidative and non-oxidative pathways 
% of the pentose phosphate pathway?
% * What reactions make-up the pentose phosphate pathway?
% * What metabolites are created in the pentose phosphate pathway?
% * What are the different names for the TCA cycle?
% * What are the biosynthetic precursors created by the TCA cycle?
% * What is the oxidative pathway in the TCA cycle?
% * What reactions make-up the TCA cycle?
% * What metabolites are created in the TCA cycle?
% * What is the anapleurotic pathway?
% * What is the glycoxylate cycle?
% * What reactions make-up the anapleurotic pathway and the glycoxylate cycle?
% * What metabolites are created in the anapleurotic pathway and the glycoxylate 
% cycle?
% * What reactions make-up the core models oxidative phosphorylation and electron 
% transfer chain?
% * What metabolites are created in the core models oxidative phosphorylation 
% and electron transfer chain?
% * What reactions make-up the fermentation pathways?
% * What metabolites are created in the fermentation pathways?
% * What are the biosynthetic precursors created by the nitrogen metabolism?
% * What reactions make-up the nitrogen metabolism?
% * What metabolites are created in the nitrogen metabolism?
% * What is the purpose of the "changeCobraSolver" function?
% * What is the purpose of the "readCbMap" function?
% * What are geneIDs?
% * What is the purpose of the "printLabeledData" function?
% * What is the purpose of the "findRxnsFromGenes" function?
% * Describe the capabilities of the "surfNet" function?
% * What are the default model constraints for the _E.coli_ core model?
% * What is the purpose of the "findRxnIDs" function?
% * What is the purpose of the objective function?
% * What is the purpose of the biomass reaction?
% * Describe the capabilities of the "printFluxVector" function?
% * What are the units of flux in the COBRA models?
% * What is the purpose of the "computeFluxSplits" function?
% * Describe the capabilities of the "optimizeCbModel" function?
% * What is the purpose of the "changeRxnBounds" function?
% * What are the outputs produced by the "optimizeCbModel" function?
%% *7. Tutorial Understanding Enhancement Problems*
%% 
% # Find the maximum atp[c], nadh[c], and nadph[c] that can be produced by the 
% _E.coli_ core model in an aerobic environment assuming a fixed glucose uptake 
% rate of -1 $\textrm{mmol}\cdot {\textrm{gDW}}^{-1} \cdot {\textrm{hr}}^{-1}$. 
% Hint: For atp[c] you can set ATPM as the objective function but for nadh[c] 
% and nadph[c] you will need to create separate demand functions. See Chapter 
% 19 of Palsson's book [1].
% # Compare the difference in the aerobic vs anaerobic flux rate through the 
% glycolysis pathway by setting biomass function to a fixed rate of 0.8739 $h^{-1}$. 
% Why is the anaerobic flux so much higher than the aerobic flux? Hint: Set the 
% objective function to the glucose exchange reaction.
%% References
%% 
% # Palsson, B. (2015). Systems biology : constraint-based reconstruction and 
% analysis. Cambridge, United Kingdom, Cambridge University Press.
% # Palsson, B. (2006). Systems biology : properties of reconstructed networks. 
% Cambridge ; New York, Cambridge University Press.
% # Orth, Fleming, and Palsson (2010), _EcoSal Chapter 10.2.1 - Reconstruction 
% and Use of Microbial Metabolic Networks: the Core_ Escherichia coli _Metabolic 
% Model as an Educational Guide_  - <http://www.asmscience.org/content/journal/ecosalplus/10.1128/ecosalplus.10.2.1#backarticlefulltext 
% http://www.asmscience.org/content/journal/ecosalplus/10.1128/ecosalplus.10.2.1#backarticlefulltext>
% # Becker, S. et al., <http://www.nature.com/nprot/journal/v2/n3/full/nprot.2007.99.html 
% "Quantitative prediction of cellular metabolism with constraint-based models: 
% The COBRA Toolbox">, _Nat. Protoc_ *2*, 727-738 (2007). 
% # Schellenberger J, Que R, Fleming RMT, Thiele I, Orth JD, Feist AM, Zielinski 
% DC, Bordbar A, Lewis NE, Rahmanian S et al., <http://www.ncbi.nlm.nih.gov/pubmed/21886097?dopt=Abstract 
% Quantitative prediction of cellular metabolism with constraint-based models: 
% the COBRA Toolbox v2.0> _Nat. Protoc_ *6*(9):1290-307 (2011).
% # Feist, A. M., Herrgard, M. J., Thiele, I., Reed , J . L., and Palsson, B. 
% 0., (2009). Reconstruction of biochemical networks in microorganisms. Nat. Rev 
% Microbiol 7 : 129-143. 
% # Price, N. D., Papin, J . A., Schilling, C. H. , and Palsson, B. 0., (2003) 
% Genome-scale microbial _in silico_ models: the constraints-based approach. Trends 
% Biotechnol 21:162-169.
% # Orth, J. D., I. Thiele, et al. (2010). "What is flux balance analysis?" 
% Nature biotechnology 28(3): 245-248. 
% # Schellenberger, J., Park, J. O., Conrad, T. M., and Palsson, B. O., (2010) 
% <http://www.biomedcentral.com/1471-2105/11/213 "BiGG: a Biochemical Genetic 
% and Genomic knowledgebase of large scale metabolic reconstructions">, _BMC Bioinformatics_, 
% *11*:213.
% # King, Z.A., Lu, J., Draeger, A., Miller, P., Federowicz, S., Lerman, J.A., 
% Palsson, B.O., Lewis, N.E., (2015)  <http://nar.oxfordjournals.org/content/early/2015/10/15/nar.gkv1049.long 
% "BiGG models: A platform for integrating, standardizing and sharing genome-scale 
% models">, _Nucleic Acids Research._
% # Schaechter, M., Ingraham, J. L., Neidhardt, F. C. (2006), "Microbe", ASM 
% Press, Washington, D. C.
% # Edwards, J. S. and B. O. Palsson (2000). "Robustness analysis of the Escherichia 
% coli metabolic network." Biotechnology progress 16(6): 927-939.
%% 
%