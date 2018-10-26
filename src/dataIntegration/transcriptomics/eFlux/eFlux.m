function [foldChange,standardError,solControl,solCondition] = eFlux(model,controlExpression,conditionExpression,varargin)
% Calculate the objective fold change according to the eFlux approach for
% expression integration as described in:
% Interpreting Expression Data with Metabolic Flux Models: Predicting Mycobacterium tuberculosis Mycolic Acid Production
% Colijn C, Brandes A, Zucker J, Lun DS, Weiner B, et al. (2009)
% PLOS Computational Biology 5(8): e1000489. https://doi.org/10.1371/journal.pcbi.1000489
%
% USAGE:
%    [foldChange,standardError] = eFlux(model,controlExpression,conditionExpression,varargin)
%
% INPUTS:
%    model:                  The COBRA model struct to use
%    controlExpression:      struct for the control expression with two fields required and one optional field:
%                              * .target       - the names of the target (rxns or genes)
%                              * .value        - the value for the target. Positive values for all constraint reactions, negative values for unconstraint reactions.
%                              * .preprocessed - Indicator whether the provided targets are genes (false), or reactions (true) Default: false
%    conditionExpression:    struct for the condition expression (fields are the same as controlExpression)
% OPTIONAL INPUT:
%    varargin:               parameters given as struct or parameter/value pairs.
%                             * testNoise - indicator whether to run multiple calculations with added noise to get a significance of the fold change. Requires either a noise function and a standard deviation of noise ('noiseFun' and 'noiseStd' respectively) or a controlData struct and a noise function. 
%                             * noiseCount - number of noisy controls to create if noise is tested (default: 10)
%                             * noiseFun - The noise function to use, has to be a function handle taking 2 arguments (mean and std)
%                             * noiseStd - The standard deviation(s) to use. Either a single value (used for all values, or a vector with length equal to controlExpression.value).
%                             * controlData - a struct (like controlExpression which has a value matrix with multiple values per controlExpression to determine the noise distribution. If provided with testNoise == false, the values from this struct will be used to determine the noise.
%                             * minSum:           Switch for the processing of Genetic data. If false, ORs in the GPR will be treated as min. If true(default), ORs will be treated as addition.
%                             * softBounds:       Whether to use soft bounds for the infered constraints or to add flexibility variables (default: false).
%                             * weightFactor:     The weight factor for soft bounds (default: 1) 
% OUTPUTS:
%    foldChange:             The fold change between the objective of the
%                            condition and the objective of the control
%                            expression
%    standardError:          The error if noise is being used.
%    solControl:             The solution of the given Control expression;
%    solCondition:           The solution of the given Condition expression;
%
% ..Author:    Thomas Pfau OCt 2018
%
% NOTE:
%    This si an implementation of the eFlux concept as presented in:
%    Interpreting Expression Data with Metabolic Flux Models: Predicting Mycobacterium tuberculosis Mycolic Acid Production
%    Colijn C, Brandes A, Zucker J, Lun DS, Weiner B, et al. (2009)
%    PLOS Computational Biology 5(8): e1000489. https://doi.org/10.1371/journal.pcbi.1000489
%    Please note, that this code does not perform any preprocessing expcept
%    for that described in the above paper after array normalization. 

normFun = @(mean,std) normrnd(mean,std);

if ~isfield(controlExpression,'preprocessed')
    controlExpression.preprocessed = true;
end

parser = inputParser();
parser.addRequired('model',@(x) verifyModel(x,'simpleCheck',true));
parser.addRequired('controlExpression',@(x) verifyEFluxExpressionStruct(model,x));
parser.addRequired('conditionExpression',@(x) verifyEFluxExpressionStruct(model,x));
parser.addParameter('testNoise',false, @(x) islogical(x) || (isnumeric(x) && (x==1 || x==0)));
parser.addParameter('noiseCount',10, @isnumeric);
parser.addParameter('noiseFun',normFun, @(x) isa(x, 'function_handle'));
parser.addParameter('noiseStd',[], @isnumeric);
parser.addParameter('controlData',[], @(x) verifyEFluxExpressionStruct(model,x));
parser.addParameter('minSum',false,@(x) islogical(x) || (isnumeric(x) && (x==1 || x==0)));
parser.addParameter('softBounds',false,@(x) islogical(x) || (isnumeric(x) && (x==1 || x==0)));
parser.addParameter('weightFactor',1,@isnumeric);


parser.parse(model,controlExpression,conditionExpression,varargin{:});
testNoise = parser.Results.testNoise;
noiseCount = parser.Results.noiseCount;
noiseStd = parser.Results.noiseStd;
noiseFun = parser.Results.noiseFun;
controlData = parser.Results.controlData;
noisyControl = [];
% remove enforcing bounds (contradict eFlux concept)
if(any(model.lb > 0 | model.ub < 0))
    warning('Enforcing bounds for the following fluxes have been removed:\n%s', strjoin(model.rxns((model.lb > 0 | model.ub < 0)),'\n'));
    model.lb(model.lb > 0) = 0;
    model.ub(model.ub < 0) = 0;
end
    
if testNoise
    noisyControl = repmat(columnVector(controlExpression.value),1,noiseCount);
    if isempty(controlData) && isempty(noiseStd) 
        error('To test noise, either a standard deviation, or appropriate controlData has to be provided')
    end
    if ~isempty(controlData)
        if ~isempty(noiseStd)
            error('To test noise, either a standard deviation, or appropriate controlData has to be provided but not both.')
        end        
        % ok, we use the controlData and create noise based on its
        % standarddeviations.        
        noiseStd = std(controlData.values');                
    else
        if numel(noiseStd) == 1
            noiseStd = repmat(noiseStd,size(noisyControl,1),1);
        end
        controlData.target = controlExpression.target;
        controlData.preprocessed = controlExpression.preprocessed;
    end    
    for i = 1:noiseCount
            % add the noise.
            noise = arrayfun(@(x) noiseFun(0,x),columnVector(noiseStd));
            noisyControl(:,i) = noisyControl(:,i) + columnVector(noise);
    end
else
    if ~isempty(controlData)
        noisyControl = controlData.values;
    end
end

% calculate the condition solution 
conditionModel = applyEFluxConstraints(model,conditionExpression,varargin{:});
solCondition = optimizeCbModel(conditionModel);
conditionValue =  solCondition.f;

% calculate the default solution (for controlExpression
defaultControl = applyEFluxConstraints(model,controlExpression,varargin{:});
solControl = optimizeCbModel(defaultControl);
controlValue = zeros(1+size(noisyControl,2),1);
controlValue(1) = solControl.f;

for noisy = 1:size(noisyControl,2)
    % calculcate the noisy solutions
    if isfield(controlData,'preprocessed')
        exprStruct.target = controlData.target;
        exprStruct.value = noisyControl(:,noisy);
        exprStruct.preprocessed = controlData.preprocessed;
    else
        exprStruct.target = controlData.target;
        exprStruct.value = noisyControl(:,noisy);
    end
    defaultControl = applyEFluxConstraints(model,exprStruct,varargin{:});
    controlSol = optimizeCbModel(defaultControl);
    controlValue(1+noisy) = controlSol.f;
end
% set the outputs
foldChanges = conditionValue./controlValue;
foldChange = foldChanges(1);
standardError = std(foldChanges) / sqrt(numel(foldChanges));

end


