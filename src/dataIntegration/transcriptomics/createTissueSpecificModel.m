function [tissueModel,Rxns] = createTissueSpecificModel(model, expressionData,exRxnRemove,solver,funcModel,options,param)
                                                  
% Creates draft tissue specific model from mRNA expression data
%
% USAGE:
%
%    [tissueModel, Rxns] = createTissueSpecificModel(model, expressionData, exRxnRemove, solver, funcModel, options,param)
%
%INPUTS
%	model                   model strusture
%	expressionData          mRNA expression data structure
%       .gene               	cell array containing GeneIDs in the same
%                               format as model.genes
%       .value                  Vector containing corresponding expression
%                               value (FPKM)
%
%OPTIONAL INPUTS
%	exRxnRemove             Names of exchange reactions to remove
%                           (Default = [])
%	solver                  Use either 'GIMME','iMAT','INIT','GIMME','mCADRE','fastCore'
%                           (Default = 'GIMME')
%	funcModel               1 - Build a functional model having only reactions
%                           that can carry a flux (using a consistency check), 0 - skip this
%                           step (Default = 0)
%	options                 1- user defines the parameters for running the extraction
%                           methods 0- extraction methods use default settings
%   param                   structure containing the specific parameters reauired for each
%                           extraction method need only to be provided is options = 1 (see
%                           PARAMETER section below)
%
%PARAMETER 
%    for iMAT
%       param.threshold_lb          lower bound of expression threshold, reactions with
%                                   expression below this value are "non-expressed"
%                                   (default - 25 percentile of expression)
%       param.threshold_ub          upper bound of expression threshold, reactions with
%                                   expression above this value are "expressed"
%                                   (default - 75 percentile of expression)
%       param.tol                   minimum flux threshold for "expressed" reactions
%                                   (default 1e-8)
%       param.core                  cell with reaction names (strings) that are manually put in
%                                   the high confidence set (default - no core
%                                   reactions)
%       param.logfile               name of the file to save the MILP log (defaut - 'MILPlog')
%       param.runtime               maximum solve time for the MILP (default - 7200s)
%
%   for GIMME
%       param.threshold             expression threshold, reactions below this are
%                                   minimized (default - 75 percentile of
%                                   expression)
%       param.obj_frac              minimum fraction of the model objective function
%                                   (default - 0.9)
%
%   for INIT
%       param.weights               column with positive (high expression) and negative 
%                                   (low expression) weights for each reaction
%                                   (default - weights are defined in function of the
%                                   log of expression value normalized by
%                                   the 75 percentile of expression)
%       param.tol                   minimum flux threshold for "expressed" reactions
%                                   (default  - 1e-8)
%   	param.logfile               name of the file to save the MILP log (defaut - 'MILPlog')
%       param.runtime               maximum solve time for the MILP (default - 7200s)
%
%   for MBA
%       param.medium_set            list of reaction names with medium confidence
%                                   (default - reactions associated to expression > 50
%                                   percentile)
%       param.high_set              list of reaction names with high confidence
%                                   (default - reactions associated to expression > 75
%                                   percentile)
%       param.tol                   minimum flux threshold for "expressed" reactions
%                                   (default 1e-8)
%       param.core                  cell with reaction names that are manually put in
%                                   the high confidence core
%
%   for mCADRE
%       param.ubiquityScore         ubiquity scores corresponding to genes
%                                   in gene_id quantify how often a gene is expressed accross samples.                       
%                                   (default - expression normalized by 75 percentile)
%       param.confidenceScores      literature-based evidence for generic model,
%                                   (default - 0)
%       param.protectedRxns         cell with reactions names that are manually added to
%                                   the core reaction set (i.e. {'Biomass_reaction'})
%       param.checkFunctionality    Boolean variable that determine if the model should be able 
%                                   to produce the metabolites associated with the protectedRxns
%                                       0: don't use functionality check (default value)
%                                       1: include functionality check                           
%       param.eta                   tradeoff between removing core and zero-expression
%                                   reactions (default - 1/3)
%       param.tol                   minimum flux threshold for "expressed" reactions
%                                   (default - 1e-8)
%
%   for fastcore
%       param.core                  indices of reactions in cobra model that are part of the
%                                   core set of reactions 
%       param.epsilon               smallest flux value that is considered nonzero
%                                   (default 1e-8)               
%       param.printLevel            0 = silent, 1 = summary, 2 = debug
%
%
% OUTPUTS:
%	tissueModel         Model produced by GIMME or iMAT, containing only
%                       reactions carrying flux
%	Rxns                Statistics of test:
%
%                              * ExpressedRxns - predicted by mRNA data
%                              * UnExpressedRxns - predicted by mRNA data
%                              * unknown - unable to be predicted by mRNA data
%                              * Upregulated - added back into model
%                              * Downregulated - removed from model
%                              * UnknownIncluded - orphans added
%
%
%
% .. Authors:
%       - Aarash Bordbar 05/15/2009
%       - IT 10/30/09 Added proceedExp
%       - IT 05/27/10 Adjusted manual input for alt. splice form
%       - AB 08/05/10 Final Corba 2.0 Version
%       - Anne Richelle, May 2017 - integration of new extraction methods 

if iscell(expressionData.Locus(1))
  match_strings = true;
else
  match_strings = false;
end
% Define defaults
% Deal with hardcoded belief that all the genes will have human entrez
% ids and the user wants to collapse alternative constructs
if ~exist('proceedExp','var') || isempty(proceedExp)
    proceedExp = 1;
end

if ~exist('solver','var') || isempty(solver)
    solver = 'GIMME';
end

if ~exist('exRxnRemove','var') || isempty(exRxnRemove)
    exRxnRemove = [];
end

if ~exist('funcModel','var') || isempty(funcModel)
    funcModel = 0;
end

if ~exist('options','var') || isempty(options)
    options = 0;
end
if ~exist('param','var') || isempty(param)
    param = {};
end


% Extracting GPR data from model
[parsedGPR,corrRxn] = extractGPRs(model);

% Find wich genes in expression data are used in the model
[gene_id, gene_expr] = findUsedGenesLevels(model,expressionData);

% Link the gene to the model reactions
expressionRxns = mapGeneToRxn(model, gene_id, gene_expr, parsedGPR, corrRxn);

ExpressedRxns=expressionRxns(expressionRxns>0);
UnExpressedRxns=expressionRxns(expressionRxns==0);
unknown=expressionRxns(expressionRxns==-1);

% Removing exchange reactions that are not in this specific tissue
% metabolome
if ~isempty(exRxnRemove)
    model = removeRxns(model,exRxnRemove);
end



switch solver
    case 'iMAT'
        if options==1
            tissueModel = iMAT(model, expressionRxns, param.threshold_lb, param.threshold_ub, param.tol, param.core, param.logfile, param.runtime); 
        else
            % if options are not defined use default settings
            tissueModel = iMAT(model, expressionRxns);
        end
        
    case 'GIMME'
        if options==1
            tissueModel = GIMME(model, expressionRxns, param.threshold, param.obj_frac); 
        else
            % if options are not defined use default settings
            tissueModel = GIMME(model, expressionRxns);  
        end
        
    case 'INIT'
        if options==1
            tissueModel = INIT(model, param.weights, param.tol, param.runtime, param.logfile); 
        else
            % if options are not defined use default settings
            data=expressionRxns(expressionRxns>=0);
            threshold =prctile(data,75);
            
            weights = zeros(length(expressionRxns),1);
            weights(expressionRxns >= 0) = 5*log(expressionRxns(expressionRxns>=0)/threshold);
            weights(expressionRxns < 0) = -2; % "unknown" entries get a weight of -2
            weights(weights < -max(weights)) = -max(weights);
            tissueModel = INIT(model, weights);
        end
        
    case 'MBA'
        if options==1
            tissueModel = MBA(model, param.medium_set, param.high_set, param.tol, param.core);       
        else
            % if options are not defined use default settings
            data=expressionRxns(expressionRxns>=0);
            threshold_high =prctile(data,75);
            threshold_medium =prctile(data,50);
            
            % Get High expression core and medium expression core
            high_set= model.rxns(expressionRxns > threshold_high);
            medium_set = model.rxns(expressionRxns >= threshold_medium & expressionRxns <= threshold_high);
    
            tissueModel = MBA(model, medium_set, high_set);
        end

    case 'mCADRE'
        if options==1
            tissueModel = mCADRE(model, param.ubiquityScore, param.confidenceScores, param.protectedRxns, param.checkFunctionality, param.eta, param.tol);
        else
            % if options are not defined use default settings
            % Determine expression-based evidence for ranking reactions 
            data=expressionRxns(expressionRxns>=0);
            threshold =prctile(data,75);
            %Gene expression data [0,1], scaled w.r.t. threshold
            ubiquityScore = expressionRxns/threshold;
            ubiquityScore(ubiquityScore >= 1) = 1; 
            % Penalize genes with zero expression, such that corresponding reactions
            % will be ranked lower than non-gene associated reactions.
            ubiquityScore(ubiquityScore <= 0) = -1e-6;

            % Determine confidence level-based evidence for ranking reactions
            confidenceScores=zeros(length(model.rxns),1);
        
            tissueModel = mCADRE(model, ubiquityScore, confidenceScores);
        end
    
    case 'fastCore'
        if options==1
            tissueModel = fastcore(model, param.core, param.epsilon, param.printlevel);
        else
            % if options are not defined use default settings
            data=expressionRxns(expressionRxns>=0);
            threshold =prctile(data,75);
            core = find(expressionRxns >= threshold);  
            
            tissueModel = fastcore(model, core);
        end
            
end


if funcModel ==1
	remove = [];
	[fluxConsistentMetBool,fluxConsistentRxnBool] = findFluxConsistentSubset(tissueModel,param);
    remove=tissueModel.rxns(fluxConsistentRxnBool==0);
    tissueModel = removeRxns(tissueModel,remove);
end
        

Rxns.Expressed = ExpressedRxns;
Rxns.UnExpressed = UnExpressedRxns;
Rxns.unknown = unknown;

x = ismember(UnExpressedRxns,tissueModel.rxns);
loc = find(x);
Rxns.UpRegulated = UnExpressedRxns(loc);

x = ismember(ExpressedRxns,tissueModel.rxns);
loc = find(x==0);
Rxns.DownRegulated = ExpressedRxns(loc);

x = ismember(model.rxns,[ExpressedRxns;UnExpressedRxns]);
loc = find(x==0);
x = ismember(tissueModel.rxns,model.rxns(loc));
loc = find(x);
Rxns.UnknownIncluded = tissueModel.rxns(loc);

end






