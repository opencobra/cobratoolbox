function [tissueModel] = createTissueSpecificModel(model, options, funcModel, exRxnRemove)                                          
% Creates draft tissue specific model from mRNA expression data
%
% USAGE:
%
%    tissueModel = createTissueSpecificModel(model, options)
%
% INPUTS:
%	model:                   model strusture
%   options:                 structure field containing method specific
%                            informations
%       .solver:                 Use either 'GIMME','iMAT','INIT','MBA',
%                                'mCADRE','fastCore'
%                           
%       .additionalparam:        see NOTE section below
%
% OPTIONAL INPUTS:
%	funcModel:               1 - Build a functional model having only reactions
%                            that can carry a flux (using a consistency check), 0 - skip this
%                            step (Default = 0)
%	exRxnRemove:             Names of exchange reactions to remove
%                           (Default = [])                                       
%
% OUTPUTS:
%	tissueModel:                     extracted model
%
% NOTES:
% This section describes the additional parameter fields that need to be set in
% 'options' structure depending on the solver used. Some of these
% are optional (marked by an '*'), if not defined, they will be set at their
% default values.
%
%    for iMAT
%       options.expressionRxns       reaction expression, expression data corresponding to model.rxns.
%                                    Note : If no gene-expression data are
%                                    available for the reactions, set the value to -1
%       options.threshold_lb         lower bound of expression threshold, reactions with
%                                    expression below this value are "non-expressed"
%       options.threshold_ub         upper bound of expression threshold, reactions with
%                                    expression above this value are
%                                    "expressed"
%       options.tol*                 minimum flux threshold for "expressed" reactions
%                                    (default 1e-8)
%       options.core*                cell with reaction names (strings) that are manually put in
%                                    the high confidence set (default - no core reactions)                           
%       options.logfile*             name of the file to save the MILP log (defaut - 'MILPlog')
%       options.runtime*             maximum solve time for the MILP (default - 7200s)
%
%   for GIMME
%       options.expressionRxns       reaction expression, expression data corresponding to model.rxns.
%                                    Note : If no gene-expression data are
%                                    available for the reactions, set the
%                                    value to -1
%       options.threshold            expression threshold, reactions below this are minimized
%       options.obj_frac*            minimum fraction of the model objective function
%                                    (default - 0.9)
%
%   for INIT
%       options.weights              column with positive (high expression) and negative 
%                                    (low expression) weights for each reaction
%       options.tol*                 minimum flux threshold for "expressed" reactions
%                                    (default  - 1e-8)
%   	options.logfile*             name of the file to save the MILP log (defaut - 'MILPlog')
%       options.runtime*             maximum solve time for the MILP (default - 7200s)
%
%   for MBA
%       options.medium_set           list of reaction names with medium confidence
%       options.high_set             list of reaction names with high confidence
%       options.tol*                 minimum flux threshold for "expressed" reactions
%                                    (default - 1e-8)
%
%   for mCADRE
%       options.ubiquityScore        ubiquity scores, vector of the size of 'model.rxns'
%                                    quantifying how often a gene is expressed accross samples. 
%                                                         
%       options.confidenceScores     literature-based evidence for generic model, 
%                                    vector of the size of 'model.rxns' 
%       options.protectedRxns*       cell array with reactions names that are manually added to
%                                    the core reaction set (default- no reactions)
%       options.checkFunctionality*  Boolean variable that determine if the model should be able 
%                                    to produce the metabolites associated with the protectedRxns
%                                       0: don't use functionality check (default value)
%                                       1: include functionality check                           
%       options.eta*                 tradeoff between removing core and zero-expression
%                                    reactions (default - 1/3)
%       options.tol*                 minimum flux threshold for "expressed" reactions
%                                    (default - 1e-8)
%
%   for fastCore
%       options.core                 indices of reactions in cobra model that are part of the
%                                    core set of reactions 
%       options.epsilon*             smallest flux value that is considered
%                                    nonzero (default 1e-4)                                      
%       options.printLevel*          0 = silent, 1 = summary, 2 = debug (default 0)
%
%
%
% .. Authors:
%       - Aarash Bordbar 05/15/2009
%       - IT 10/30/09 Added proceedExp
%       - IT 05/27/10 Adjusted manual input for alt. splice form
%       - AB 08/05/10 Final Corba 2.0 Version
%       - Anne Richelle, May 2017 - integration of new extraction methods


if ~exist('exRxnRemove','var') || isempty(exRxnRemove)
    exRxnRemove = [];
end

if ~exist('funcModel','var') || isempty(funcModel)
    funcModel = 0;
end

if ~exist('options','var') || isempty(options)
    warning ('The option field is not defined')
    return
else
    if strcmp(options.solver,'iMAT')
        if ~exist(options.expressionRxns) || ~exist(options.threshold_lb) || ~exist(options.threshold_ub)
        	warning ('One of the 3 required option fields for iMAT method is not defined')
            return
        end
        if ~exist(options.tol),options.tol=1e-8;end
        if ~exist(options.core),options.core ={};end
        if ~exist(options.logfile),options.logfile ='MILPlog';end
        if ~exist(options.runtime),options.runtime =7200;end
    elseif strcmp(options.solver,'GIMME')
        if ~exist(options.expressionRxns) || ~exist(options.threshold)
        	warning ('One of the 2 required option fields for GIMME method is not defined')
            return
        end
        if ~exist(options.obj_frac),options.obj_frac=0.9;end
    elseif strcmp(options.solver,'INIT')
        if ~exist(options.weights)
        	warning ('The required option field "weights" is not defined for INIT method')
            return
        end
        if ~exist(options.tol),options.tol=1e-8;end
        if ~exist(options.logfile),options.logfile ='MILPlog';end
        if ~exist(options.runtime),options.runtime =7200;end
    elseif strcmp(options.solver,'MBA')
        if ~exist(options.medium_set) || ~exist(options.high_set)
        	warning ('One of the 2 required option fields for MBA method is not defined')
            return
        end
        if ~exist(options.tol),options.tol=1e-8;end
    elseif strcmp(options.solver,'mCADRE')
        if ~exist(options.ubiquityScore) || ~exist(options.confidenceScores)
        	warning ('One of the 2 required option fields for mCADRE method is not defined')
            return
        end
        if ~exist(options.protectedRxns),options.protectedRxns={};end
        if ~exist(options.checkFunctionality),options.checkFunctionality=0;end
        if ~exist(options.eta),options.eta=1/3;end
        if ~exist(options.tol),options.tol=1e-8;end
    elseif strcmp(options.solver,'fastCore')
        if ~exist(options.core)
        	warning ('The required option field "core" is not defined for fastCore method')
            return
        end
        if ~exist(options.epsilon),options.epsilon=1e-4;end                                       
    end
end

% Removing exchange reactions that are not in this specific tissue
% metabolome
if ~isempty(exRxnRemove)
    model = removeRxns(model,exRxnRemove);
end


switch options.solver
    case 'iMAT'      
            tissueModel = iMAT(model, options.expressionRxns, options.threshold_lb, options.threshold_ub, options.tol, options.core, options.logfile, options.runtime);         
    case 'GIMME'
            tissueModel = GIMME(model, options.expressionRxns, options.threshold, options.obj_frac);      
    case 'INIT'
            tissueModel = INIT(model, options.weights, options.tol, options.runtime, options.logfile); 
    case 'MBA'
            tissueModel = MBA(model, options.medium_set, options.high_set, options.tol, options.core);       
    case 'mCADRE'
            tissueModel = mCADRE(model, options.ubiquityScore, options.confidenceScores, options.protectedRxns, options.checkFunctionality, options.eta, options.tol);
    case 'fastCore'
            tissueModel = fastcore(model, param.core, param.epsilon, param.printlevel);
end


if funcModel ==1
    paramConsistency.epsilon=1e-10;
    paramConsistency.modeFlag=0;
    paramConsistency.method='fastcc';
    
	remove = [];
	[fluxConsistentMetBool,fluxConsistentRxnBool] = findFluxConsistentSubset(tissueModel,paramConsistency);
    remove=tissueModel.rxns(fluxConsistentRxnBool==0);
    tissueModel = removeRxns(tissueModel,remove);
    tissueModel = removeUnusedGenes(tissueModel);
end
       
end
