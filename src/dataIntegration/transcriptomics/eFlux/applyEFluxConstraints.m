function [ constraintModel ] = applyEFluxConstraints( model, expression, varargin)
% Implementation of the EFlux algorithm as described in:
% Interpreting Expression Data with Metabolic Flux Models: Predicting Mycobacterium tuberculosis Mycolic Acid Production
% Colijn C, Brandes A, Zucker J, Lun DS, Weiner B, et al. (2009)
% PLOS Computational Biology 5(8): e1000489. https://doi.org/10.1371/journal.pcbi.1000489
%
% USAGE:
%
%    constraintModel = eFlux(model,expression)
%
% INPUTS:
%    model:         The model to Constrain.
%    expression:    struct with two fields required and one optional field:
%                   * .target       - the names of the target (rxns or genes)
%                   * .value        - the value for the target. Positive values
%                                     for all constraint reactions, negative
%                                     values for unconstraint reactions.
%                   * .preprocessed - Indicator whether the provided
%                                     targets are genes (false), or reactions (true)
%                                     Default: false
%
% OPTIONAL INPUTS:
%
%    varargin:      Parameters given as struct or parameter/value pairs: 
%                    * minSum:           Switch for the processing of Genetic data. If false, ORs in the GPR will be treated as min. If true(default), ORs will be treated as addition.
%                    * softBounds:       Whether to use soft bounds for the infered constraints or to add flexibility variables (default: false).
%                    * weightFactor:     The weight factor for soft bounds (default: 1) 
%
% NOTE:
%
%    All Flux bounds will be reset by this function, i.e. any enforced
%    fluxes (like ATP Maintenance) will be removed!
%
% ..Authors
%     - Thomas Pfau
%
% NOTE:
%    Implementation of the EFlux algorithm as described in:
%    Interpreting Expression Data with Metabolic Flux Models: Predicting Mycobacterium tuberculosis Mycolic Acid Production
%    Colijn C, Brandes A, Zucker J, Lun DS, Weiner B, et al. (2009)
%    PLOS Computational Biology 5(8): e1000489. https://doi.org/10.1371/journal.pcbi.1000489

if ~isfield(expression,'preprocessed')
    expression.preprocessed = true;
end

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('expression', @(x) verifyEFluxExpressionStruct(model,x))
parser.addParameter('minSum',true,@(x) islogical(x) || (isnumeric(x) && (x==1 || x==0)));
parser.addParameter('softBounds',false,@(x) islogical(x) || (isnumeric(x) && (x==1 || x==0)));
parser.addParameter('weightFactor',1,@isnumeric);

parser.parse(expression,varargin{:});

minSum = parser.Results.minSum;
softBounds = parser.Results.softBounds;
weightFactor = parser.Results.weightFactor;

if ~expression.preprocessed
    % make expression
    expr.gene =  expression.target;
    expr.value = expression.value;
    reactionExpression = mapExpressionToReactions(model, expr, minSum);
else
    %Default : unconstraint.
    reactionExpression = -ones(size(model.rxns));
    [pres,pos] = ismember(model.rxns,expression.target);
    reactionExpression(pres) = expression.target(pos(pres));    
end

unconstraintReactions = reactionExpression == -1;
maxFlux = max(reactionExpression(~unconstraintReactions));
reactionExpression(unconstraintReactions) = 1;

reactionExpression(~unconstraintReactions) = reactionExpression(~unconstraintReactions)/maxFlux;
%Warning if Flux enforcing bounds are removed.
if(any(model.lb > 0 | model.ub < 0))
    warning('Enforcing bounds for the following fluxes have been removed:\n%s', strjoin(model.rxns((model.lb > 0 | model.ub < 0)),'\n'));
    model.lb(model.lb > 0) = 0;
    model.ub(model.ub < 0) = 0;
end
if ~softBounds
    model.lb(model.lb < 0) = -reactionExpression(model.lb<0);
    model.ub(model.ub > 0) = reactionExpression(model.ub>0);
else
   backRxns = model.lb<0;
   fwRxns = model.ub>0;
   Alpha_IDs = strcat('Alpha_',model.rxns(model.lb<0));
   Beta_IDs = strcat('Beta_',model.rxns(model.ub>0));
   model = addCOBRAVariables(model, Alpha_IDs,'lb',0,'ub',1000,'c',-weightFactor, 'Names', strcat('Punishment term for violation of expression derived bounds for reaction ', model.rxns(model.lb < 0)));
   model = addCOBRAVariables(model, Beta_IDs,'lb',0,'ub',1000,'c',-weightFactor, 'Names', strcat('Punishment term for violation of expression derived bounds for reaction ', model.rxns(model.ub > 0)));
   rxnspeye = speye(numel(model.rxns));
   fwConst = [rxnspeye(backRxns,:),rxnspeye(backRxns,backRxns)];
   backConst = [rxnspeye(fwRxns,:),rxnspeye(fwRxns,fwRxns)];
   % add the backward constraints
   model = addCOBRAConstraints(model,[model.rxns;Alpha_IDs],-reactionExpression(backRxns),'dsense',repmat('G',sum(backRxns),1),'c',fwConst);
   % add the forward flex
   model = addCOBRAConstraints(model,[model.rxns;Beta_IDs],reactionExpression(fwRxns),'c',backConst);
end

constraintModel = model;

end

