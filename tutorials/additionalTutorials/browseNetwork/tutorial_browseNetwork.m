%% Browse Networks in the Matlab Command Window Using surfNet
%% Author(s): Siu Hung Joshua Chan, Department of Chemical Engineering, The Pennsylvania State University
%% Reviewer(s): 
% __
%% INTRODUCTION
% In this tutorial, we will demonstrate how to browse a COBRA model in verbal 
% format in the Matlab command window through an initial call and interactive 
% mouse clicking.
%% MATERIALS
%% EQUIPMENT SETUP
% Start CobraToolbox

% initCobraToolbox;
%% PROCEDURE
% Load the _E. coli_ iJO1366 model as an example model.

modelFileName = 'iJO1366.mat';
modelDirectory = getDistributedModelFolder(modelFileName); %Look up the folder for the distributed Models.
modelFileName= [modelDirectory filesep modelFileName]; % Get the full path. Necessary to be sure, that the right model is loaded
iJO1366 = readCbModel(modelFileName);

%% 
% *Browse a network*
% 
% Browse the network by starting from an initial metabolite, e.g., D-glucose 
% in the extracellular compartment.

surfNet(iJO1366, 'glc__D_e')
%% 
% All reactions producing or consuming '|*glc__D_e|*' will have their reaction 
% indices (#xxx), ids (.rxns), bounds (.lb/.ub), names (.rxnNames) and formulae 
% printed on the command window. All reactions and the participating metabolites 
% are hyperlinked. For example, *click* on the reaction '|*GLCtex_copy1|*'. (This 
% is equivalent to run the following command.)

% called by clicking 'GLCtex_copy1'
surfNet([], 'GLCtex_copy1', 0, 'none', 0, 1, [], 0)  
%% 
% Details for the metabolites will appear, e.g., indeices, ids, stoichiometric 
% coefficients, names and chemical formulae. By iteratively clicking on the reactions 
% and metabolites that you are interested in, you can browse through the metabolic 
% network.
% 
% Now, say you have gone through a series of metabolites and reactions (glc__D_e, 
% GLCtex_copy1, glc__D_p, GLCptspp, g6p_c): 
% 
% Click glc__D_p:

% called by clicking 'glc__D_p'
surfNet([], 'glc__D_p', 0, 'none', 0, 1, [], 0)  
%% 
% Click GLCptspp:

% called by clicking 'GLCptspp'
surfNet([], 'GLCptspp', 0, 'none', 0, 1, [], 0)  
%% 
% Click g6p_c:

% called by clicking 'g6p_c'
surfNet([], 'g6p_c', 0, 'none', 0, 1, [], 0)  
%% 
% In each click, there is also a button '*Show previous steps...*' at the 
% bottom. Clicking on it will show the metabolites and reactions that you have 
% visited in order. This is equivalent to calling:

% called by clicking 'Show previous steps...'
surfNet([], [], 0, 'none', 0, 1, [], 0, struct('showPrev', true))  
%% 
% You can go back to any of the intermediate metabolites/reactions by clicking 
% the hyperlinked |mets/rxns| shown.
% 
% *Call options*
% 
% Shown below are various call options for including flux vectors and customizing 
% display. All call options are preserved during the interactive browsing by mouse 
% clicking.
% 
% *Show objective reactions*
% 
% Omit the '|metrxn|' (2nd) argument to print objective reactions:

surfNet(iJO1366)
%% 
% *Call with a list of mets/rxns*
% 
% The 'metrxn' arguement can be a string of id for a metabolite or reaction. 
% It can also be a cell array of ids, e.g.,

surfNet(iJO1366, {'glc__D_p'; 'GLCptspp'; 'g6p_c'})
%% 
% *Show metabolite names in reaction formulae*
% 
% Some models may use generic ids for |mets/rxns|. In this case, call |surfNet()| 
% with the '|metNameFlag|' (3rd) arguement turned on to show the names for metabolites 
% (|.metNames|) in the reaction formulae, e.g.,

surfNet(iJO1366, 'fgam_c', 1)
%% 
% *Hide reaction detials*
% 
% Turn off the '|showMets|' (6th) arguement to suppress details for reactions, 
% e.g.,

surfNet(iJO1366, iJO1366.rxns(1001:1010), [], [], [], 0)
%% 
% *Look at one or more flux distributions*
% 
% First, get a flux distribution by optimizing the biomass production of 
% the model (the standard flux balance analysis$$^1$). Then call surfNet with 
% the flux distribution (4th argument) to look at how the flux through pyruvate 
% is distributed:

s = optimizeCbModel(iJO1366, 'max', 'one');
surfNet(iJO1366, 'pyr_c', [], s.x)
%% 
% All reactions involving pyruvate with non-zero fluxes are printed. The 
% flux values are in the parentheses following the reaction ids. Note that reactions 
% stated as consuming or producing the metabolite have taken the directions of 
% the fluxes into account. Therefore, supplying a different flux distribution 
% or not supplying may give different display. By default, only reactions with 
% non-zero fluxes are printed if a flux distribution is supplied. Turn the '|nonzeroFluxFlag|' 
% (5th) argument off to show all reactions:

surfNet(iJO1366, 'pyr_c', [], s.x, 0)
%% 
% You can also compare multiple flux distributions by supplying them in 
% a matrix format, each column being a flux distribution. For example, get another 
% flux distribution maximizing the biomass production using D-fructose instead 
% of glucose as substrate. Then call surfNet to look at reactions with different 
% fluxes.
% 
% Original uptake rates:

printUptakeBound(iJO1366);
%% 
% Use fructose instead of glucose as substrate:

iJO1366 = changeRxnBounds(iJO1366, {'EX_glc__D_e'; 'EX_fru_e'},...
    [0; -10], {'L'; 'L'});
printUptakeBound(iJO1366);
%% 
% Run FBA again to get a flux distribution using fructose as substrate. 
% Then look at reactions with different fluxes in the glucose and fructose cases 
% using |surfNet|.

sFru = optimizeCbModel(iJO1366, 'max', 'one');  % FBA
fluxMatrix = [s.x, sFru.x];  % put two flux vectors in a matrix
% reactions with different fluxes
rxnDiff = abs(fluxMatrix(:, 1) - fluxMatrix(:, 2)) > 1e-6;  
surfNet(iJO1366, iJO1366.rxns(rxnDiff), [], fluxMatrix, [], 0)
%% 
% *Customize model data to be displayed*
% 
% Customize the fields for metabolites and reactions to be printed by supplying 
% the '|field2print|' (7th) argument. It is defaulted to be:  
% 
% |{{'metNames','metFormulas'}, {'rxnNames','lb','ub'}}|
% 
% The first cell contains the metabolite-related fields to be printed and 
% the second cell contains the reaction-related fields to be printed. It can also 
% be inputted as a single cell array of strings, as long as from the size (equal 
% to #|mets| or #|rxns)| or from the name of the field (starting with '|met|' 
% or '|rxn|'), the fields are recognizable to be met- or rxn-related. For example, 
% show the |grRules| for rxns but omit the bounds and show the constraint sense 
% (|csense|) associated with each metabolite. Note the difference from the original 
% call:

surfNet(iJO1366, 'fdp_c', [], [], [], [],...
    {'metNames', 'metFormulas', 'rxnNames', 'grRules', 'csense'})
surfNet(iJO1366, 'fdp_c')
%% 
% The last argument (8th) 'nCharBreak' sets the number of characters printed 
% per line. By default, it is equal to the width of the Matlab command window. 
% Note the difference:
% 
% Characters per line = width of the command window (default):

surfNet(iJO1366, [], [], [], [], 0)
%% 
% 40 characters per line:

surfNet(iJO1366, [], [], [], [], 0, [], 40)
%% 
% 80 characters per line:

surfNet(iJO1366, [], [], [], [], 0, [], 80)
%% 
% 
%% REFERENCES
% [1] Orth, J. D., Thiele I., and Palsson, B. Ø. What is flux balance analysis? 
% _Nat. Biotechnol., 28_(3), 245–248 (2010).