# fastGapFill

## Requirements
In order to perform the fastGapFill analysis the following tools are needed.

1. Matlab: http://www.mathworks.nl/products/matlab/

2. Cobra toolbox from GitHub: https://github.com/opencobra/cobratoolbox
and follow the installation instructions given in Schellenberger et al.: http://www.nature.com/nprot/journal/v6/n9/abs/nprot.2011.308.html

3. A linear programming solver is needed. E.g., glpk (included in the COBRA toolbox, IBM ILOG CPLEX (http://www-01.ibm.com/software/commerce/optimization/cplex-optimizer/, free academic licenses are available).

4. fastGapFill: http://wwwen.uni.lu/lcsb/research/mol_systems_physiology/fastgapfill

## Utilization of fastGapFill

1. Follow the installation instructions of The COBRA Toolbox and run `initCobraToolbox`.
2. Make sure that a solver has been selected using `changeCobraSolver`. `CPLEX` is required.
3. Change to the folder `tutorials\fastGapFill` and run `runGapFill_example`
4. Re-run gapFill on the same model but with different weightings:
	- define weights for reactions to be added - the lower the weight the higher the priority and run in `MATLAB`, e.g.:
		````
		weights.MetabolicRxns = 0.1; % Kegg metabolic reactions
		weights.ExchangeRxns = 0.5; % Exchange reactions
		weights.TransportRxns = 1; % Transport reactions
		````
	- Run in `MATLAB`:
		````
		[AddedRxns] = fastGapFill(consistMatricesSUX, epsilon, weights);
		````
	- The newly added reactions contained in the variable `AddedRxns` are consistent with updated weights

## Utilization of the stoichiometric consistency check

1. Type into the 'Command Window': `runConsistencyCheck_example`
2. If there are stoichiometrically inconsistent metabolites, `MetIncons` lists their abbreviations as used in the model.

## Using another reaction database than the default database

1. Create an input file that has the same format as the file given in `reaction.lst`
	- e.g.:
	  ````
		ReactionAbbr: ReactionFormula
		R00001: C00890 + n C00001 <=> (n+1) C02174
		R00002: 16 C00002 + 16 C00001 + 8 C00138 <=> 8 C05359 + 16 C00009 + 16 C00008 + 8 C00139
		R00004: C00013 + C00001 <=> 2 C00009
		R00005: C01010 + C00001 <=> 2 C00011 + 2 C00014
		````
2. Create a translation table between the reaction database metabolites and the model database (e.g., as illustrated in `KEGG_dictionary.xls`), where the first column lists the model metabolites and the 2nd column the database ID
3. Optional: To exlude certain reactions from the database to be considered for the gapFilling: Generate a blacklist listing the `ReactionAbbr` of the reaction database to be excluded
4. Pass the database as input into the function `prepareFastGapFill`:
	 ````
	 [consistModel,consistMatricesSUX,BlockedRxns] = prepareFastGapFill(model,weights,listCompartments,epsilon,filename,dictionary,blackList)
	 ````
5. Proceed as normal with `fastGapFill` and postprocessing
