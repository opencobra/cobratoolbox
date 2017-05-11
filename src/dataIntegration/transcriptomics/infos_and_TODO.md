INFOS
recon1.mat 		recon1 model structure
recon2.mat		recon2 model structure
expressionData		RNAseq data that could be used to test the different script provided
preprocessing.m		preprocessing of the model structure and the expression data before use by extraction method
			preprocessing.m	 calls the 4 following functions:
				formatGenes.m
				findUsedGenesLevels.m
				extractGPRs.m
				mapGeneToRxn.m
call_XXX		function that call the related XXX extraction method



TO DO LIST


preprocessing.m
  -	provide an option to modulate the tolerance used in findBlockedReaction (check the last version of this code in cobra v3)
  -	write a check test of the existence of a solution for the model provided by the user when preprocessing
  -	update the code formatGenes.m depending on the format of model.genes structure used in cobratoolbox? for the moment fixed to the format encounter in recon1 and recon2

call_fastcore.m
  -	setting of the default values for the algorithm parameters : tol, core, scaling
  -	the initial algorithm has been developped for CPLEX and we have adapated the code for gurobi? need to check the compatibility with other solver and propose options for users to manage that

call_GIMME.m
  -	setting of the default values for the algorithm parameters : tol, obj_fraction
  -	provide an option to modulate the tolerance used in findBlockedReaction (check the last version of this code in cobra v3) - findBlocked reaction is used to check model consistency after removal of reactions identified by GIMME
  -	a modified version of convertToIrreversible is introduced in this script, need to check the fixes introduced to the last version that will be available in cobra v3 to see if we can remove that

call_iMAT.m
  -	setting of the default values for the algorithm parameters 
  -	provide an option to modulate the tolerance used in findBlockedReaction (check the last version of this code in cobra v3) - findBlocked reaction is used to check model consistency after removal of reactions identified by iMAT
  -	the algorithm use a modified version of solveCobraMILP when the computation time limit is reached ? can be implemented in the general file of solveconraMILP

call_INIT.m
  -	setting of the default values for the algorithm parameters 
  -	provide an option to modulate the tolerance used in findBlockedReaction (check the last version of this code in cobra v3) - findBlocked reaction is used to check model consistency after removal of reactions identified by INIT
  -	the algorithm use a modified version of solveCobraMILP when the computation time limit is reached ? can be implemented in the general file of solveconraMILP
  -	need to add line to compute the ?weights?  using the expression data if the user do no want to provide the weights manually

call_MBA.m
  -	setting of the default values for the algorithm parameters 
  -	update use of CheckModelConsistency.m see the second comment of  "General" section below

call_mCADRE.m
  -	setting of the default values for the algorithm parameters 
  -	update use of CheckModelConsistency.m see the second comment of  "General" section below
  -	include a local copy of changeRxnBounds such as to not print warning if a reaction has been removed? could be suppressed by introducing "warning off" before the call of this function
  -	!!!! lot of writing improvements can be done on mCADRE code? still working on it


General
  -	most of the call_xx function ask for a threshold value for expression data - need to write an additional code that allow to identify different threshold value depending on the expression data available if they do not want to set it manually (e.g. 75 percentile of the average expression data)
  -	most of the scripts call_xxx use either findBlockedReaction or CheckModelConsistency (using fastcc writed in 2013 in SauterLab)- we need to uniformize that in all the script? either by improving findBlockedReaction in cobra v3 or make a more general and independent script for CheckModelConsistency (+check solver compatibility)
  -	we need to add more warning display to the users for each of the cal_xxx functions
  -   Integration of all these scripts in one function as createTissueSpecificModel
