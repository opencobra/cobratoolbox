%% Paint4Net: visualisation toolbox for COBRA
%% Author(s):
% Andrejs Kostromins, Biosystems Group, Department of Computer Systems, Latvia 
% University of Agriculture, Liela iela 2, LV-3001 Jelgava, Latvia. 
% 
% Egils Stalidzans, Institute of Microbiology and Biotechnology, University 
% of Latvia, Jelgavas iela 1, LV-1004, Latvia.
%% Reviewer(s): 
% Agris Pentjuss, Institute of Microbiology and Biotechnology, University of 
% Latvia, Jelgavas iela 1, LV-1004, Latvia.
% 
% Almut Heinken, Luxembourg Centre for Systems Biomedicine, Universiy of 
% Luxembourg, 6 avenue du Swing, Belvaux, L-4367, Luxembourg.
%% IMPORTANT NOTE
% Paint4Net uses Bioinformatics Toolbox to generate visualisation layout, however 
% it is not supported in .mlx causing an error during function execution. Thus 
% the functions involving visualisation were run in regular MATLAB command window 
% and each visualisation  layout was saved as a static figure and flaced in the 
% .mlx tutorial, while the corresponding functions were run in .mlx with visualisation 
% feature turned off (input argument _drawMap _was set to 'false') to get outputs 
% (without visualisation) in .mlx without crashing. Be aware of this issue when 
% you are running the functions in .mlx. All _drawMap _input arguments are set 
% to 'true' in .mlx. Change it to 'false' to avoid an error. 
%% INTRODUCTION
% A visual analysis of reconstructions and large stoichiometric models with 
% elastic change of the visualization scope and representation methods becomes 
% increasingly important due to the rapidly growing size and number of available 
% reconstructions.
% 
% The Paint4Net is a COBRA Toolbox extension for automatic generation of 
% a hypergraph layout of defined scope with the steady state rates of reaction 
% fluxes of stoichiometric models. Directionalities and fluxes of reactions are 
% constantly represented in the visualization while detailed information about 
% reaction (ID, name and synonyms, and formula) and metabolite (ID, name and synonyms, 
% and charged formula) appears placing the cursor on the item of interest. Additionally 
% Paint4Net functionality can be used to: (1) get lists of involved metabolites 
% and dead end metabolites of the visualized part of the network, (2) exclude 
% (filter) particular metabolites from representation, (3) find isolated parts 
% of a network and (4) find running cycles when all the substrates are cut down. 
% Layout pictures can be saved in various formats and easily distributed. 
% 
% *Two functions with their arguments are used in the Paint4Net to define 
% the scope of visualization: (1) [involvedMets, deadEnds] = draw by rxn(model, 
% rxns, drawMap, direction, initialMet, excludeMets, flux) – to define scope by 
% a list of reactions and (2) [directionRxns, involvedMets, deadEnds] = draw by 
% met(model, metAbbr, drawMap, radius, direction, excludeMets, flux) – to define 
% the metabolite of interest to see linked reactions within radius of, for instance, 
% 2 reactions.* The function draw_by_rxn has 7 input arguments: (1) model – stands 
% for stoichiometric reconstruction or model with constraints, (2) rxns – stands 
% for a list of the reactions of interest for analysis, (3) drawMap (optional) 
% – stands for request to generate visualization ('true' or 'false', default is 
% 'false'), (4) direction (optional) – stands for algorithm visualization mode 
% ('struc', 'sub', 'prod' or 'both') in order to visualize structure (struc) of 
% reconstructions without FBA data or visualize substrates (sub), products (prod) 
% or substrates and products (both) for models with flux constraints and FBA data 
% (default is 'struc'), (5) initialMet (optional) – stands for metabolite of interest 
% to be used by function draw by met (default is empty), (6) excludeMets (optional) 
% – stands for a list of the excludable metabolites as a filter and (7) flux (optional) 
% – stands for vector of FBA data of reactions flux distribution (default is vector 
% of x characters if flux is not calculated). The last 5 arguments are optional 
% and can be unset. The function draw_by_rxn has 2 outputs: (1) involvedMets – 
% stands for a list of involved metabolites depending on the input arguments and 
% (2) deadEnds – stands for a list of dead-end metabolites depending on the input 
% arguments. The function draw_by_met has 7 input arguments: (1) model – stands 
% for stoichiometric reconstruction or model with constraints, (2) metAbbr – stands 
% for an input for metabolite of interest for analysis, (3) drawMap (optional) 
% – stands for request to generate visualization ('true' or 'false', default is 
% 'false'), (4) radius (optional) – stands for distance indicator between metabolite 
% of interest and involved reactions (default is 1), (5) direction (optional) 
% – stands for algorithm visualization mode ('struc', 'sub', 'prod' or 'both') 
% in order to visualize structure (struc) of reconstructions without FBA data 
% or visualize substrates (sub), products (prod) or substrates and products (both) 
% for models with flux constraints and FBA data (default is 'struc'), (6) excludeMets 
% (optional) – stands for a list of the excludable metabolites as a filter and 
% (7) flux (optional) – stands for vector of FBA data of reactions flux distribution 
% (default is vector of x characters for no flux). The last 5 arguments are optional 
% and can be unset. The function draw_by_met has 3 outputs: (1) directionRxns 
% – stands for a list of involved reactions depending on the input arguments, 
% (2) involvedMets – stands for a list of involved metabolites depending on the 
% input arguments and (3) deadEnds – stands for alist of dead-end metabolites 
% depending on the input arguments. 
% 
% The layout of the network is generated by Bioinformatics Toolbox using 
% hierarchical (default), radial or equilibrium layout engine algorithm, which 
% can be changed in the menu item “Tool” of the layout. The automatically generated 
% layout stays the same as long as the scope of representation and directionality 
% of reactions remain unchanged. The layout of automatically generated network 
% can be changed by dragging metabolites or reactions for analysis or publishing 
% needs. Still the new layout cannot be saved for next visualizations. The visual 
% representation of information in the layout (see Fig. 1) allows quick assessment 
% of running processes generally.
% 
% 
% 
% *Fig. 1 *Zoomed fragment of a large model. Reaction nodes (rectangle) contain 
% IDs and flux rates. Metabolite nodes (ellipse) are marked by IDs. Forward and 
% reverse fluxes (arrows) are green and blue correspondingly, zero fluxes are 
% grey. The thickness of an arrow is proportional to the rate of flux. Rectangles 
% of blocked and exchange reactions are marked by red. One node at a time can 
% be chosen by a cursor to see detailed information: (1) ID, name, synonyms and 
% equation for a reaction and (2) ID, name, synonyms and charged formula for a 
% metabolite.  Metabolite _acald[c]_is selected by cursor for displaying of detailed 
% information.  Creation of this figure is described in the “Anticipated results” 
% section, Step 8.
% 
% 
% 
% Detailed information about any reaction and metabolite can be requested 
% right on the visualization choosing the node of interest by cursor. To facilitate 
% the analysis the Paint4Net creates a list of involved metabolites and a list 
% of the dead end metabolites (metabolite cannot be produced or consumed caused 
% by gap – missing reaction – in the model) (Thiele and Palsson, 2010) in the 
% visualized part of the reaction network. That is a convenient feature analyzing 
% larger visualizations where it becomes hard to be sure that a particular metabolite 
% is or is not involved just by search of the abbreviation in the picture. The 
% dead end metabolites are detected according to the S matrix (Palsson, 2006) 
% of the biochemical model and the rates of reactions at steady state according 
% to FBA. Flux rates below 10E−9 mmol g−1 h−1 are considered to be zero flux rates. 
% To reduce the density of visualization a metabolite filter can be used. Stoichiometric 
% model may have some particular metabolites (H, H2O, ATP, ADP, NAD, NADPH, NADP 
% etc.), which are more involved in the metabolism, than other ones. It leads 
% to a very tight interconnectivity and makes it harder to visualize larger models. 
% For this reason both functions of the Paint4Net have special argument for the 
% list of excludable metabolites. Each excluded metabolite reduces the number 
% of interconnecting curves in the visualization of the model. Debugging of a 
% model can be facilitated in several ways. The visualization shows the interconnections 
% between reactions and metabolites and isolated parts of a network appear very 
% clearly. There are three reasons why isolated reactions can be present in the 
% model: (1) human made mistakes in the model while generating the model, (2) 
% intentionally left gaps in case of no interest in specific metabolic process 
% or (3) knowledge gaps in case of missing biochemical knowledge for the organism. 
% Isolated parts can be related to metabolic dead-ends in the model (Thiele and 
% Palsson, 2010). The Paint4Net is able to find the dead end metabolites and represent 
% them in the visualization (red ellipses). Blocked reactions which cannot carry 
% the fluxes (Thiele and Palsson, 2010) can appear in the model as intentionally 
% blocked reactions (gene knockouts, flux constraints set to 0), however often 
% there are cases when the model is stoichiometrically unbalanced or lower and 
% upper bounds are set incorrectly. The Paint4Net can deal with this problem as 
% well by showing the nodes of the blocked reactions in the visualization by red 
% rectangles. The true power of visualization reflects when the user has to find 
% Type III-extreme pathways (Thiele and Palsson, 2010) in the model. Those are 
% stoichiometrically balanced cycles which can have fluxes even when all the substrate 
% sources are cut down. According to FBA data the Paint4Net visualizes the network 
% and then it is relatively easy to distinguish cycles by nonzero fluxes marked 
% by green and blue arrows, which in most cases are caused by insufficient constraints 
% of the flux and/or directionality. 
% 
% Paint4Net has been used in the development of stoichiometric models of 
% Zymomonas mobilis (Pentjuss et al., 2013), Methanococcus maripaludis (Richards 
% et al., 2016) and Kluyveromyces marxianus (Pentjuss et al., 2017). Paint4Net 
% was used for to develop draft model, to identify network reactions connecting 
% missing outputs to inputs and/or to produce figures for the published manuscript 
% (Aurich and Thiele, 2012), (Demidenko et al., 2017), (Contador et al., 2015). 
% It is used also for analysis and published figures in other studies (Koussa 
% et al., 2014). Paint4Net is mentioned also as valuable supplement to other COBRA 
% Tollboxes like ORCA (Mao and Verwoerd, 2014). Paint4Net has been used also for 
% analysis of networks during building of modeling software (Rove et al., 2012) 
% and supporting software tools (Rubina and Stalidzans, 2013), (Meitalovs and 
% Stalidzans, 2013). Paint4Net is also used in a number of doctoral theses in 
% different countries.
%% MATERIALS
% No materials are needed as Paint4Net is a software product.
%% EQUIPMENT
% The equipment has to be able to run MATLAB._ _
%% EQUIPMENT SETUP
% The COBRA toolbox and the Bioinformatics toolbox are required to use the Paint4Net.
%% PROCEDURE
% The Paint4Net v1.3 contains two main commands for the visualization purposes:
% 
% * _[involvedMets, deadEnds] = draw_by_rxn(model, rxns, drawMap, direction, 
% initialMet, excludeMets, flux)_;
% * _[directionRxns, involvedMets, deadEnds] = draw_by_met(model, metAbbr, drawMap, 
% radius, direction, excludeMets, flux)_.
%% _Application of command_ _*draw_by_rxn *_
% _*draw_by_rxn _*can be performed using *option* *A* in case COBRA model optimization 
% results have to be visualized or *option* *B* if the interconnections between 
% metabolites in COBRA file have to be visualized (See Fig. 2).
% 
% 
% 
% *Fig. 2.* The scenarios of an application of the command _draw_by_rxn_.
% 
% 
% 
% Before starting the tutorial, initialize the Cobra Toolbox if necessary 
% and set a LP solver.

initCobraToolbox(false) %don't update the toolbox
changeCobraSolver ('gurobi', 'all', 1);
%changeCobraSolver ('glpk', 'all', 1);
%% _A*.* COBRA model visualization_ 
% *i.* a COBRA model has to be loaded into MATLAB. The sample model is available 
% at <http://www.biosystems.lv/files/Paint4Net%20sample%20pack%2008.07.2017.zip 
% http://www.biosystems.lv/files/Paint4Net%20sample%20pack%2008.07.2017.zip>. 
% Download the file and extract it in a folder of your choice. You can also use 
% your own model.

model = xls2model('test_model.xls')
%% 
% *ii.* optimization of the objective function by using the COBRA_ _toolbox 
% command _optimizeCbModel, _where the argument _model_ corresponds to the COBRA_ 
% _model in the MATLAB workspace.

FBAsolution = optimizeCbModel(model)
%% 
% This step ensures that a vector of the steady state fluxes _x_ will be 
% available for the command _draw_by_rxn_.

FBAsolution.x
%% 
% *iii.* execution of the command _[involvedMets, deadEnds] = draw_by_rxn 
% (model, rxns, drawMap, direction, initialMet, excludeMets, flux)_.

[Involved_mets, Dead_ends] = draw_by_rxn(model, model.rxns, 'true', 'struc', {''}, {''}, FBAsolution.x)
    
%% 
% 
%% _B.  COBRA reconstruction visualization_ 
% *i.* a COBRA model has to be loaded into MATLAB. 

model = xls2model('test_model.xls')
%% 
% *ii.* execution of the command _[involvedMets, deadEnds] = draw_by_rxn 
% (model, rxns, drawMap, direction, initialMet, excludeMets, flux)_

[involvedMets, deadEnds] = draw_by_rxn(model, model.rxns, 'true')
%% 
% 
% 
% In this case in the brackets in the rectangles are shown characters _x_ 
% indicating that fluxes at steady state were not calculated. This approach is 
% useful in case of reconstruction visualization where fluxes are not calculated. 
% The arrows in the end of the edges point on the forward directions of the reactions 
% in the COBRA_ _model.
%% _*Input arguments of the command draw_by_rxn*_
% The command _draw_by_rxn_ has several input arguments – _model, rxns_,_ drawMap_, 
% _direction_, _initialMet_, _excludeMets_, and_ flux_. The last 5 arguments are 
% optional; it means that the algorithm of the command _draw_by_rxn_ uses default 
% values of those arguments, so user can ignore them if additional functionality 
% is not actual.
% 
% *i. argument_ model*_
% 
% This argument stands for a COBRA model in the MATLAB workspace.
% 
% *ii. argument_ rxns*_
% 
% This argument represents a list of reactions from a COBRA model separated 
% by a comma. The layout of map depends on this list, as a result if new abbreviation 
% is added or some deleted in the list the layout will change as well. To prevent 
% layout change by potential mistakes and save time by not creating the list every 
% time from scratch it is possible to create a _cell _type vector in the MATLAB 
% workspace that contains the static abbreviations of the reactions in the COBRA_ 
% _model and use it as argument _rxns_. 

rxns = {'glyc12', 'glyc21', 'carb12', 'ed2'}

[involvedMets, deadEnds] = draw_by_rxn(model, rxns)
%% 
% Another example is a list of reaction in the COBRA model which can be 
% accessed by _model.rxns_. It illustrates all COBRA model.

[involvedMets, deadEnds] = draw_by_rxn(model, model.rxns)
%% 
% *iii. argument _drawMap*_
% 
% It is a _logical_ type variable that can take value of _'true_' or _'false'_ 
% (default is _'false_') indicating whether to visualize the COBRA model or not. 
% The main idea of this argument is to ensure possibility to save time by not 
% visualizing a large COBRA_ _model and get a result faster.

[involvedMets, deadEnds] = draw_by_rxn(model, model.rxns, 'false')
%% 
% *iiii. optional argument _direction*_
% 
% It is a _string_ type variable that can take value of _'struc'_, _'sub'_, 
% _'prod'_ or _'both'_ (default is _'struc'_) indicating a direction for the algorithm 
% of the command _draw_by_rxn._

[Involved_mets, Dead_ends] = draw_by_rxn(model, model.rxns, 'false', 'struc')
%% 
% In case of _'struc'_ (structure) the algorithm visualizes all metabolites 
% connected to the specified reactions in the argument _rxns_. The key feature 
% of this function is visualization of all specified reactions not taking in account 
% a steady state fluxes in that way representing the structure of the COBRA_ _model. 
% In case of _'sub'_ (substrates) the algorithm visualizes only those metabolites 
% which are substrates for the specified reactions in the argument _rxns_. This 
% time the algorithm is using a stoichiometric matrix and the steady state fluxes 
% to determine direction of each reaction. The algorithm is using an assumption 
% that only those fluxes which rates are smaller than -10-9 mmol*g-1*h-1or greater 
% than +10-9 mmol*g-1*h-1 are non-zero fluxes. In case of _'prod'_ (products) 
% the algorithm visualizes only those metabolites which are products for the specified 
% reactions in the argument _rxns_ but in case of _'both' _the algorithm visualizes 
% both – substrates and products - for the specified reactions in the argument 
% _rxns_. For both cases the algorithm is using the same rules regarding to calculation 
% of the directions for each reaction as for case of _'sub'_. This argument is 
% essential for the command _draw_by_met _ of the Paint4Net_ _v1.3 because the 
% command _draw_by_met_ is calling out the command _draw_by_rxn _and passing the 
% argument _direction_.
% 
% *iiiii. optional argument _initialMet*_
% 
% It is a _cell_ type variable that can take a value that represents the 
% abbreviation of a metabolite in the COBRA_ _model (default is empty).

[Involved_mets, Dead_ends] = draw_by_rxn(model, model.rxns, 'true', 'struc', {'atp[c]'}, {''}, FBAsolution.x)
    
%% 
% This metabolite is represented as green ellipse on the map (see Fig. 3) 
% and this feature is essential for the command _draw_by_met _of the Paint4Net 
% v1.3 because the command _draw_by_met_ is calling out the command _draw_by_rxn_ 
% and passing the argument _initialMet_.
% 
% 
% 
% 
% 
% *Fig. 3.*The metabolite _atp[c]_ as initial metabolite on the map of the 
% COBRA_ _model.
% 
% *iiiiii. optional argument _excludeMets*_
% 
% This argument represents a list of metabolites (default is empty) that 
% will be excluded from the visualization map of the COBRA model in form of the 
% abbreviations of the metabolites separated by a comma. To save time by not creating 
% the list every time from scratch it is possible to create a _cell _type vector 
% in the MATLAB workspace that contains the static abbreviations of the metabolites 
% in the COBRA_ _model and use it as argument _excludeMets_. 

excludeMets = {'atp[c]', 'nad[c]', 'adp[c]', 'h[c]'}
[Involved_mets, Dead_ends] = draw_by_rxn(model, model.rxns, 'true', 'struc', {''}, excludeMets)
%% 
% The main idea of this argument is to ensure possibility to exclude very 
% employed metabolites (e.g., h, h2o, atp, adp, nad etc.) to avoid unnecessary 
% mesh on the map (see Fig. 4, Fig. 5, Fig. 6, Fig. 7, Fig. 8 and Fig. 9).
% 
% 
% 
% *Fig. 4.* An example of the map of the COBRA model. Full scope.
% 
% 
% 
% 
% 
% *Fig. 5.* An example of the map of the COBRA model. The metabolite _h[c]_ 
% is excluded from map which reduce the number of edges by 26.
% 
% 
% 
% 
% 
% *Fig. 6.* An example of the map of the COBRA model. The metabolites _h[c]_, 
% and _h2o[c]_ are excluded from map which reduce the number of edges by 26+17=43.
% 
% 
% 
% 
% 
% *Fig. 7. *An example of the map of the COBRA model. The metabolites _h[c]_, 
% _h2o[c]_, and _atp[c]_ are excluded from map which reduce the number of edges 
% by 26+17+9=52.
% 
% 
% 
% 
% 
% *Fig. 8.* An example of the map of the COBRA model. The metabolites _h[c]_, 
% _h2o[c]_, _atp[c]_, and _adp[c]_ are excluded from map which reduce the number 
% of edges by 26+17+9+9=61.
% 
% 
% 
% 
% 
% *Fig. 9.* An example of the map of the COBRA model. The metabolites _h[c]_, 
% _h2o[c]_, _atp[c]_, _adp[c]_, and _nad[c]_ are excluded from map which reduce 
% the number of edges by 26+17+9+9+8=69.
% 
% 
% 
% *iiiiiii. optional argument _flux*_
% 
% It is a _double_ type Nx1 size vector of fluxes of reactions where N is 
% number of reactions (default is vector of x). This vector is calculated during 
% the optimization of the objective function and can be accessed through the result 
% of the optimization command.

FBAsolution.x
%% _*Output of the command draw_by_rxn*_
% The command _draw_by_rxn _has two output vectors in the result: _involvedMets 
% _and _deadEnds_.
% 
% *i. the vector _involvedMets*_
% 
% It is a _cell _type vector that contains a list of the involved metabolites 
% in the specified reactions (see Fig. 10).
% 
% 
% 
% *Fig. 10.* An example of the list of the involved metabolites.
% 
% 
% 
% *ii. the vector _deadEnds*_
% 
% It is also a _cell _type vector but it contains a list of the dead end 
% metabolites in the specified reactions (see Fig. 11).
% 
% 
% 
% *Fig. 11. *An example of the list of the dead end metabolites.
% 
%  
%% _Application of command* draw_by_met_* 
% _*draw_by_met* _can be used can be performed using *option* *A* in case COBRA 
% model with optimization results have to be visualized or *option B* if the interconnections 
% between metabolites in COBRA file have to be visualized (See Fig. 12).
% 
%  
% 
% *Fig. 12. *The scenarios of an application of the command _draw_by_met_.
% 
%  
%% _A. COBRA model visualization_ 
% *i.* a COBRA model has to be loaded into MATLAB. 

model = xls2model('test_model.xls')
%% 
% *ii.* optimization of the objective function by using the COBRA_ _toolbox 
% command _optimizeCbModel, _where the argument _model_ corresponds to the COBRA_ 
% _model in the MATLAB workspace.

FBAsolution = optimizeCbModel(model)
%% 
% This step ensures that a vector of the steady state fluxes _x_ will be 
% available for the command _draw_by_met_.

FBAsolution.x
%% 
% *iii.* execution of the command [directionRxns, involvedMets, deadEnds] 
% = draw_by_met(model, metAbbr, drawMap, radius, direction, excludeMets, flux).

[directionRxns, involvedMets, deadEnds] = draw_by_met(model, {'etoh[c]'}, 'true', 2, 'struc', {''}, FBAsolution.x)
%% 
% 
%% _B.  COBRA reconstruction visualization_
% *i.* a COBRA model has to be loaded into MATLAB. 

model = xls2model('test_model.xls')
%% 
% *ii.* execution of the command [directionRxns, involvedMets, deadEnds] 
% = draw_by_met(model, metAbbr, drawMap, radius, direction, excludeMets, flux)

[directionRxns, involvedMets, deadEnds] = draw_by_met(model, {'etoh[c]'}, 'true', 2)
%% 
% 
% 
% In this case in the brackets in the rectangles are shown characters _x_indicating 
% that fluxes at steady state were not calculated. This approach is useful in 
% case of reconstruction visualization where fluxes are not calculated.
%% *Input arguments of the command _draw_by_met*_
% The command _draw_by_met _has several input arguments – _model, metAbbr, drawMap, 
% radius, direction, excludeMets, _and _flux_. The last 5 are optional, it means 
% that the algorithm of the command _draw_by_met _uses default values of those 
% arguments, so user can ignore them if additional functionality is not necessary.
% 
% *i. argument _model*_
% 
% This argument stands for a COBRA model in the MATLAB workspace.
% 
% *ii. argument _metAbbr*_
% 
% It is a _cell _type variable that can take a value that represents the 
% abbreviation of a metabolite in a COBRA_ _model. This argument is the start 
% point for the algorithm of the command _draw_by_met_ for visualization.

[directionRxns, involvedMets, deadEnds] = draw_by_met(model, {'etoh[c]'})
%% 
% *iii. optional argument _drawMap*_
% 
% It is a _logical_ type variable that can take value of _'true'_ or _'false_' 
% (default is _'false'_) indicating whether to visualize the COBRA model or not_. 
% _The main idea of this argument is to ensure possibility to save time by not 
% visualizing a large COBRA_ _model and get a result  faster.

[directionRxns, involvedMets, deadEnds] = draw_by_met(model, {'etoh[c]'}, 'true');
%% 
% *iiii. optional argument _radius*_
% 
% It is a _double_ type variable that can take a value of natural numbers 
% (1,2,3…n).

[directionRxns, involvedMets, deadEnds] = draw_by_met(model, {'etoh[c]'}, 'true', 1)
%% 
% The argument _radius _indicates the depth of an analysis of the initial 
% metabolite (the argument _metAbbr_) and it is tightly connected to the optional 
% argument _direction. _For example, if user is interested in the substrates of 
% _ethanol_, the user can analyse substrates step by step starting from the first 
% reactions where the argument _radius_ is equal to 1 and moving to the next reactions 
% by increasing the value of the argument _radius_ (see Fig. 13 and Fig. 14).
% 
% 
% 
% *Fig. 13.* Example where the argument _radius _= 1 (distance = one reaction 
% from initial metabolite _etoh[c]_). In the reaction _Alchocol4_ the metabolites 
% _h[c]_, _nadh[c]_, and _acald[c]_ are consumed and the metabolite _etoh[c] _is 
% produced. The flux rate is -80 mmol*g-1*h-1that indicates that reaction is going 
% backwards.
% 
% 
% 
% 
% 
% *Fig. 14.* Example where the argument _radius_ = 2 (distance = two reactions 
% from initial metabolite _etoh[c]_). The metabolites _glyc-R[c]_, _glc-D[c]_, 
% _h2o[c]_, _pyr[c]_, _g3p[c]_, and _pi[c]_ are consumed and the metabolite _etoh[c] 
% _is produced.
% 
% 
% 
% The algorithm of the command _draw_by_met_ interconnects all involved metabolites 
% according to the stoichiometric matrix of a COBRA_ _model. The important point 
% to understand correctly is imbalance of the rates of fluxes in case of partial 
% network. The algorithm of the command _draw_by_met_ shows the rates of fluxes 
% in the brackets in the rectangles according to steady state, but in case of 
% visualization of partial network not all rectangles are seen which leads to 
% imbalance for some metabolites. For example, in the Fig. 14* *the metabolite 
% _h[c]_ is produced in 5 reactions (_Cofact17_, _glyc21_, _ed3_, _g6pd_, and 
% _glyc1_) with total 5*40=200 mmol*g-1*h-1 but it is consumed in 2 reactions 
% (_pyr_dec_and _Alchocol4_) with only 2*80 = 160 mmol*g-1*h-1.
% 
% *iiiii. optional argument _direction*_
% 
% It is a _string_type variable that can take value of _'struc'_, _'sub'_, 
% _'prod'_ or _'both'_ (default is _'struc'_) indicating a direction for the algorithm 
% of the command _draw_by_met. _In case of _'struc'_ (structure) the algorithm 
% visualizes all metabolites connected to the specified reactions in the argument 
% _rxns_. The key feature of this function is visualization of all specified reactions 
% not taking in account a steady state fluxes in that way representing the structure 
% of the COBRA_ _model. In case of _'sub'_ (substrates) the algorithm visualizes 
% only those metabolites which are substrates for the specified reactions in the 
% argument _rxns_. This time the algorithm is using a stoichiometric matrix and 
% the steady state fluxes to determine direction of each reaction. The algorithm 
% is using an assumption that only those fluxes which rates are smaller than -10-9 
% mmol*g-1*h-1or greater than +10-9 mmol*g-1*h-1 are non-zero fluxes. In case 
% of _'prod'_ (products) the algorithm visualizes only those metabolites which 
% are products for the specified reactions in the argument _rxns_ but in case 
% of _'both' _the algorithm visualizes both – substrates and products - for the 
% specified reactions in the argument _rxns_. For both cases the algorithm is 
% using the same rules regarding to calculation of the directions for each reaction 
% as for case of _'sub'_.
% 
% *iiiiii. optional argument _excludeMets*_
% 
% This argument represents a list of metabolites (default is empty) that 
% will be excluded from the visualization map of the COBRA model in form of the 
% abbreviations of the metabolites separated by a comma. 
% 
% *iiiiiii. optional argument _flux*_
% 
% It is a _double_ type Nx1 size vector of fluxes of reactions where N is 
% number of reactions (default is vector of x). This vector is calculated during 
% the optimization of the objective function and can be accessed through the result 
% of the optimization command by _FBAsolution.x._ 
%% _Output of the command draw_by_met _
% The command _draw_by_met _has three output vectors in the result: _involvedRxns_,_ 
% involvedMets_,_ _and _deadEnds_.
% 
% *i. vector _involvedRxns*_
% 
% It is a _cell _type vector that contains a list of the involved reactions 
% according to the set of input arguments (see *Fig. 15*).
% 
% 
% 
% *Fig. 15. *An example of the list of the involved reactions.
% 
% *ii. vector _involvedMets*_
% 
% It is a _cell _type vector that contains a list of the involved metabolites 
% in the specified reactions (see Fig. 10).
% 
% *iii. vector _deadEnds*_
% 
% It is also a _cell _type vector but it contains a list of the dead end 
% metabolites in the specified reactions (see Fig. 11).
%% TROUBLESHOOTING
% *Problem: *output vectors ar valid, but visuaization layout is not generated.
% 
% *Possible reason: *the input argument _drawMap _is not provided properly.
% 
% *Solution: *It is a _logical_ type variable that can take value of _'true'_ 
% or _'false_' (default is _'false'_) indicating whether to visualize the COBRA 
% model or not. Please pay attention to single quotes around the argument.
%% TIMING
% Timing is given as Start_time, End_time and Total_time for every Paint4Net 
% function call. It may varie based on equipment computing power.
%% ANTICIPATED RESULTS	
% *1. Load a model.*

model = xls2model('test_model.xls')
%% 
% *2. Find involved and dead-end metabolites in the whole model without 
% visualization and without FBA data (assuming all reaction rates are 0).*
% 
% The model must be loaded before (see step 1).* *The first two arguments 
% are used for the function [involvedMets, deadEnds] = draw_by_rxn(model, rxns, 
% drawMap, direction, initialMet, excludeMets, flux), the rest will take default 
% values. The expected involved metabolites are all 60 metabolites in the model 
% and the list of them will be created in the MATLAB workspace as variable _involvedMets_. 
% The expected dead-end metabolites are: 'glc-D[c]', 'o2[c]' and 'xyl-D[c]'. The 
% list of dead-end metabolites will be created in the MATLAB workspace as variable 
% _deadEnds_.

[involvedMets, deadEnds] = draw_by_rxn(model, model.rxns)
%% 
% *3. Create a list of the reactions of interest.*
% 
% The list of the reactions of interest will be created in the MATLAB workspace 
% as variable _rxns_.

rxns = {'glyc12', 'glyc21', 'carb12', 'ed2', 'g6pd', 'ed3', 'ed1', 'R035', 'ppp4', 'ppp3', 'carb2', 'R040', 'ppp5', 'glyc3', 'glyc1', 'glyc4', 'glyc7', 'glyc23', 'glyc14', 'pyr_dec'};
%% 
% *4. Find involved and dead-end metabolites for the list of the reactions 
% of interest without visualization and without FBA data (assuming all reaction 
% rates are 0).*
% 
% The model must be loaded before (see step 1).* *The list of reactions of 
% interest must be created before (see step 3). The first two arguments are used 
% for the function [involvedMets, deadEnds] = draw_by_rxn(model, rxns, drawMap, 
% direction, initialMet, excludeMets, flux), the rest will take default values. 
% Results depends on the scope of the reactions of interest. The expected involved 
% metabolites are: 'f6p[c]', 'g6p[c]', 'atp[c]', 'glc-D[c]', 'adp[c]', 'h[c]', 
% 'fru[c]', 'nadp[c]', 'gl6p[c]', 'nadph[c]', 'nad[c]', 'nadh[c]', 'h2o[c]', 'pgl[c]', 
% 'dgp[c]', 'co2[c]', 'ru5p-D[c]', 'xu5p-D[c]', 'e4p[c]', 'g3p[c]', 'r5p[c]', 
% 's7p[c]', 'pyr[c]', 'dhap[c]', 'pi[c]', '13dpg[c]', '3pg[c]', '2pg[c]', 'pep[c]' 
% and 'acald[c]'. The list of involved metabolites will be created in the MATLAB 
% workspace as variable _involvedMets_. The expected dead-end metabolites are: 
% 'glc-D[c]', 'fru[c]', 'co2[c]', 'e4p[c]', 's7p[c]', 'dhap[c]', 'pi[c]' and 'acald[c]'. 
% The list of dead-end metabolites will be created in the MATLAB workspace as 
% variable _deadEnds_. 

[involvedMets, deadEnds] = draw_by_rxn(model, rxns)
%% 
% *5. Visualize the model without FBA data (assuming all reaction rates 
% are 0).*
% 
% The model must be loaded before (see step 1). The first three arguments 
% are used for the function [involvedMets, deadEnds] = draw_by_rxn(model, rxns, 
% drawMap, direction, initialMet, excludeMets, flux), the rest will take default 
% values. Besides the list of involved metabolites and the list of dead-end metabolites 
% the hypergraph layout will be generated by Paint4Net using the Bioinformatics 
% Toolbox. The reaction nodes will contain _x _for flux rates.

[involvedMets, deadEnds] = draw_by_rxn(model, model.rxns, 'true')
%% 
% 
% 
% *6. Visualize the reactions of interest without FBA data (assuming all 
% reaction rates are 0).*
% 
% The model must be loaded before (see step 1).* *The list of reactions of 
% interest must be created before (see step 3). The first three arguments are 
% used for the function [involvedMets, deadEnds] = draw_by_rxn(model, rxns, drawMap, 
% direction, initialMet, excludeMets, flux), the rest will take default values. 
% Besides the list of involved metabolites and the list of dead-end metabolites 
% the hypergraph layout will be generated by Paint4Net using the Bioinformatics 
% Toolbox. The reaction nodes will contain _x _for flux rates. All interconnecting 
% edges will be in gray because of no FBA data.

[involvedMets, deadEnds] = draw_by_rxn(model, rxns, 'true')
%% 
% 	
% 
% *7. Perform FBA.*
% 
% The FBA results will be stored in the MATLAB workspace as variable _FBAsolution_.

FBAsolution=optimizeCbModel(model)
%% 
% *8. Visualize the model with FBA data.*
% 
% The model must be loaded before (see step 1). The FBA must be performed 
% before (see step 7). Besides the list of 78 involved metabolites and the list 
% of three (not 4 like in the step 2 because of FBA data) dead-end metabolites  
% the hypergraph layout will be generated by Paint4Net using the Bioinformatics 
% Toolbox. The reaction nodes will contain flux rates according to FBA data. Interconnecting 
% nodes will be in corresponding colors according to flux rates for each reaction.

[Involved_mets, Dead_ends] = draw_by_rxn(model, model.rxns, 'true', 'struc', {''}, {''}, FBAsolution.x)
%% 
% 	
% 
% *9. Visualize the reactions of interest with FBA data.*
% 
% The model must be loaded before (see step 1). The list of reactions of 
% interest must be created before (see step 3). The FBA must be performed before 
% (see step 7). Besides the list of involved metabolites and the list of dead-end 
% metabolites the hypergraph layout will be generated by Paint4Net using the Bioinformatics 
% Toolbox. The reaction nodes will contain flux rates according to FBA data. Interconnecting 
% nodes will be in corresponding colors according to flux rates for each reaction.

[Involved_mets, Dead_ends] = draw_by_rxn(model, rxns, 'true', 'struc', {''}, {''}, FBAsolution.x)
%% 
% 
% 
% *10. Create a list of the excludable metabolites.*
% 
% The list with _atp_, _nad_, _adp_and _h_ as excludable metabolites will 
% be created in the MATLAB workspace as variable _excludeMets_.

excludeMets = {'atp[c]', 'nad[c]', 'adp[c]', 'h[c]'}
%% 
% *11. Visualize the model with excluded metabolites without FBA data.*
% 
% The model must be loaded before (see step 1). The list of excludable metabolites 
% must be created before (see step 10). The first six arguments are used for the 
% function [involvedMets, deadEnds] = draw_by_rxn(model, rxns, drawMap, direction, 
% initialMet, excludeMets, flux), the last will take default value. Besides the 
% list of involved metabolites and the list of dead-end metabolites the hypergraph 
% layout will be generated by Paint4Net using the Bioinformatics Toolbox. The 
% reaction nodes will contain”_x” _for flux rates. The generated layout will not 
% contain any of metabolites declared in the list of excludable metabolites _excludeMets_. 
% All interconnecting edges will be in gray because of no FBA data.

[Involved_mets, Dead_ends] = draw_by_rxn(model, model.rxns, 'true', 'struc', {''}, excludeMets)
%% 
% 
% 
% *12. Visualize the model with excluded metabolites with FBA data.*
% 
% The model must be loaded before (see step 1). The FBA must be performed 
% before (see step 7).* *The list of excludable metabolites must be created before 
% (see step 10). Besides the list of involved metabolites and the list of dead-end 
% metabolites the hypergraph layout will be generated by Paint4Net using the Bioinformatics 
% Toolbox. The reaction nodes will contain flux rates according to FBA data. Interconnecting 
% nodes will be in corresponding colors according to flux rates for each reaction. 
% The generated layout will not contain any of metabolites declared in the list 
% of excludable metabolites _excludeMets_.

[Involved_mets, Dead_ends] = draw_by_rxn(model, model.rxns, 'true', 'struc', {''}, excludeMets, FBAsolution.x)
%% 
% 
% 
% *13. Find involved reactions, involved metabolites and dead-end metabolite 
% in the radius of 2 reactions from the metabolite of interest (in this case etoh[c]) 
% without visualization, without FBA data.*
% 
% The model must be loaded before (see step 1). The first four arguments 
% are used for the function [directionRxns, involvedMets, deadEnds]=draw_by_met(model, 
% metAbbr, drawMap, radius, direction, excludeMets, flux), the rest will take 
% default values. The expected involved reactions are: 'Alcohol4', 'R66', 'Cofact17', 
% 'R27', 'R28', 'R35', 'R42', 'R48', 'R49', 'R70', 'R73', 'acet_dehy', 'acet_dehyh', 
% 'carb12', 'carbx5', 'ed2', 'ed3', 'ed5', 'g6pd', 'glyc1', 'glyc14', 'glyc21', 
% 'glyc8', 'gpl3', 'pengluc3', 'ppp2', 'ppp8', 'pyr_dec', 'secmet7' and 'tca12'. 
% The list of involved reactions will be created in the MATLAB workspace as variable 
% _directionRxns_. The expected involved metabolites are: 'f6p[c]', 'g6p[c]', 
% 'atp[c]', 'glc-D[c]', 'adp[c]', 'h[c]', 'fru[c]', 'nadp[c]', 'gl6p[c]', 'nadph[c]', 
% 'nad[c]', 'nadh[c]', 'h2o[c]', 'pgl[c]', 'co2[c]', 'xu5p-D[c]', 'g3p[c]', 'pyr[c]', 
% 'dhap[c]', 'pi[c]', '13dpg[c]', '3pg[c]', 'pep[c]', 'acald[c]', 'coa[c]', 'accoa[c]', 
% 'etoh[c]', 'ac[c]', 'lac-D[c]', 'q[c]', 'qh2[c]', 'oaa[c]', 'cit[c]', 'akg[c]', 
% 'nh4[c]', 'glu-L[c]', 'mal-L[c]', 'hco3[c]', 'glyc3p[c]', 'glyc-R[c]', 'glyc[c]', 
% 'xylu-D[c]', 'acin[c]', 'gllc[e]', 'glcn[e]', 'glcn[c]' and '2dhglcn[c]'. The 
% list of involved metabolites will be created in the MATLAB workspace as variable 
% _involvedMets_. The expected dead-end metabolites are: 'f6p[c]', 'glc-D[c]', 
% 'fru[c]', 'xu5p-D[c]', 'g3p[c]', 'dhap[c]', '13dpg[c]', '3pg[c]', 'pep[c]', 
% 'lac-D[c]', 'q[c]', 'qh2[c]', 'oaa[c]', 'cit[c]', 'akg[c]', 'nh4[c]', 'glu-L[c]', 
% 'mal-L[c]', 'hco3[c]', 'glyc-R[c]', 'glyc[c]', 'xylu-D[c]', 'acin[c]', '2dhglcn[c]' 
% and 'gllc[c]'. The list of dead-end metabolites will be created in the MATLAB 
% workspace as variable _deadEnds_.

[directionRxns,involvedMets,deadEnds] = draw_by_met(model,{'etoh[c]'},'false',2)
%% 
% *14. Visualize the part of the model in the* *radius of 2 reactions from 
% the metabolite of interest (in this case etoh[c]) without FBA data.*
% 
% The model must be loaded before (see step 1). The first four arguments 
% are used for the function [directionRxns, involvedMets, deadEnds] = draw_by_met(model, 
% metAbbr, drawMap, radius, direction, excludeMets, flux), the rest will take 
% default values. Besides the list of involved reactions, the list of involved 
% metabolites and the list of dead-end metabolites the hypergraph layout will 
% be generated by Paint4Net using the Bioinformatics Toolbox. The reaction nodes 
% will contain _x _for flux rates. All interconnecting edges will be in gray because 
% of no FBA data.

[directionRxns, involvedMets, deadEnds] = draw_by_met(model, {'etoh[c]'}, 'true', 2)
%% 
% 
% 
% 	
% 
% *15. Visualize the part of the model in the* *radius of 2 reactions from 
% the metabolite of interest (in this case etoh[c]) with FBA data.*
% 
% The model must be loaded before (see step 1). The FBA must be performed 
% before (see step 7). Besides the list of involved reactions, the list of involved 
% metabolites and the list of dead-end metabolites the hypergraph layout will 
% be generated by Paint4Net using the Bioinformatics Toolbox. The reaction nodes 
% will contain flux rates according to FBA data. Interconnecting nodes will be 
% in corresponding colors according to flux rates for each reaction.

[directionRxns, involvedMets, deadEnds] = draw_by_met(model, {'etoh[c]'}, 'true', 2, 'struc', {''}, FBAsolution.x)
%% 
% 
% 
% *16. Visualize substrates in the radius of 2 reactions from the metabolite 
% of interest (in this case etoh[c]) with FBA data.*
% 
% The model must be loaded before (see step 1). The FBA must be performed 
% before (see step 7). Besides the list of involved reactions, the list of involved 
% metabolites and the list of dead-end metabolites the hypergraph layout will 
% be generated by Paint4Net using the Bioinformatics Toolbox where only substrates 
% for g6p[c] in the radius of 2 reactions will be visualized. The reaction nodes 
% will contain flux rates according to FBA data. Interconnecting nodes will be 
% in corresponding colors according to flux rates for each reaction.

[directionRxns, involvedMets, deadEnds] = draw_by_met(model, {'g6p[c]'}, 'true', 2, 'sub', {''}, FBAsolution.x)
%% 
% 
% 
% *17. Visualize products in the radius of 2 reactions from the metabolite 
% of interest (in this case atp[c]) with FBA data.*
% 
% The model must be loaded before (see step 1). The FBA must be performed 
% before (see step 7). Besides the list of involved reactions, the list of involved 
% metabolites and the list of dead-end metabolites the hypergraph layout will 
% be generated by Paint4Net using the Bioinformatics Toolbox where only products 
% of atp[c] in the radius of 2 reactions will be visualized. The reaction nodes 
% will contain flux rates according to FBA data. Interconnecting nodes will be 
% in corresponding colors according to flux rates for each reaction.

[directionRxns, involvedMets, deadEnds] = draw_by_met(model, {'atp[c]'}, 'true', 2, 'prod', {''}, FBAsolution.x)
%% 
% 
%% Acknowledgments
% Authors are thankful to Ines Thiele who inspired to make a simple visualization 
% software for COBRA models. 
% 
% This work is funded by a project of European Structural Fund Nr. 2009/0207/1DP/1.1.1.2.0/09/APIA/VIAA/128 
% “Latvian Interdisciplinary Interuniversity Scientific Group of Systems Biology” 
% www.sysbio.lv.
%% REFERENCES
% Aurich, M.K., Thiele, I., 2012. Contextualization Procedure and Modeling of 
% Monocyte Specific TLR Signaling. PLoS One 7, e49978. doi:10.1371/journal.pone.0049978
% 
% Contador, C.A., Rodr?guez, V., Andrews, B.A., Asenjo, J.A., 2015. Genome-scale 
% reconstruction of Salinispora tropica CNB-440 metabolism to study strain-specific 
% adaptation. Antonie Van Leeuwenhoek 108, 1075–1090. doi:10.1007/s10482-015-0561-9
% 
% Demidenko, A., Akberdin, I.R., Allemann, M., Allen, E.E., Kalyuzhnaya, 
% M.G., 2017. Fatty Acid Biosynthesis Pathways in Methylomicrobium buryatense 
% 5G(B1). Front. Microbiol. 7. doi:10.3389/fmicb.2016.02167
% 
% Koussa, J., Chaiboonchoe, A., Salehi-Ashtiani, K., 2014. Computational 
% Approaches for Microalgal Biofuel Optimization: A Review. Biomed Res. Int. 2014, 
% 1–12. doi:10.1155/2014/649453
% 
% Mao, L., Verwoerd, W.S., 2014. ORCA: a COBRA toolbox extension for model-driven 
% discovery and analysis. Bioinformatics 30, 584–585. doi:10.1093/bioinformatics/btt723
% 
% Meitalovs, J., Stalidzans, E., 2013. Analysis of synthetic metabolic pathways 
% solution space, in: 2013 International Conference on System Science and Engineering 
% (ICSSE). Ieee, pp. 183–187. doi:10.1109/ICSSE.2013.6614656
% 
% Palsson, B.O., 2006. Systems Biology: Properties of Reconstructed Networks. 
% Cambridge University Press, New York.
% 
% Pentjuss, A., Odzina, I., Kostromins, A., Fell, D.A., Stalidzans, E., Kalnenieks, 
% U., 2013. Biotechnological potential of respiring Zymomonas mobilis: a stoichiometric 
% analysis of its central metabolism. J. Biotechnol. 165, 1–10. doi:10.1016/j.jbiotec.2013.02.014
% 
% Pentjuss, A., Stalidzans, E., Liepins, J., Kokina, A., Martynova, J., Zikmanis, 
% P., Mozga, I., Scherbaka, R., Hartman, H., Poolman, M.G., Fell, D.A., Vigants, 
% A., 2017. Model-based biotechnological potential analysis of Kluyveromyces marxianus 
% central metabolism. J. Ind. Microbiol. Biotechnol. doi:10.1007/s10295-017-1946-8
% 
% Richards, M.A., Lie, T.J., Zhang, J., Ragsdale, S.W., Leigh, J.A., Price, 
% N.D., 2016. Exploring Hydrogenotrophic Methanogenesis: a Genome Scale Metabolic 
% Reconstruction of Methanococcus maripaludis. J. Bacteriol. 198, 3379–3390. doi:10.1128/JB.00571-16
% 
% Rove, Z., Mednis, M., Odzina, I., 2012. Biochemical networks comparison 
% tool, in: 5th International Scientific Conference on Applied Information and 
% Communication Technologies. Jelgava, Latvia., pp. 306–311.
% 
% Rubina, T., Stalidzans, E., 2013. BINESA — A software tool for evolution 
% modelling of biochemical networks’ structure, in: 2013 IEEE 14th International 
% Symposium on Computational Intelligence and Informatics (CINTI). IEEE, pp. 345–350. 
% doi:10.1109/CINTI.2013.6705218
% 
% Thiele, I., Palsson, B.Ø., 2010. A protocol for generating a high-quality 
% genome-scale metabolic reconstruction. Nat. Protoc. 5, 93–121. doi:10.1038/nprot.2009.203
% 
% __