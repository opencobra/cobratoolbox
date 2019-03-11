function [fluxROOM, solutionROOM, totalFluxDiff] = ROOM(model, fluxWT, rxnKO, varargin)
% Performs a MILP version of the ROOM (Regulatory on/off minimization of 
% metabolic flux changes) approach
%
% USAGE:
%
%    [fluxROOM, solutionROOM, totalFluxDiff] = ROOM(model, WTflux, rxnKO, delta, epsilon, printLevel)
%
% INPUTS:
%    model:            Metabolic model
%    fluxWT:           Numeric array with flux distribution of wild type
%    rxnKO:            List of perturbations performed to the model
%                      (reactions that are eliminated)
%
% OPTIONAL INPUTS:
%    delta:            Multiplicative tol for flux change (Default = 0.03)
%    epsilon:          Additive tolerance for flux change (Default = 0.001)
%    printLevel:       Verbose output (Default = 1)
%
% OUTPUTS:
%    fluxROOM:         Flux distribution after ROOM calculation
%    solutionROOM:     Solution structure
%    totalFluxDiff:    Euclidean distance of ROOM objective, i.e.
%                      :math:`\sum (v_{wt}-v_{del})^2`
% 
% Solve the following problem:
%
% .. math::
%      min ~&~ \sum y_{i} \\
%          ~&~ S_{del}v_{del} = 0 \\
%          ~&~ lb_{del} \leq v_{del} \leq ub_{del} \\
%          ~&~ for i=1:nRxns\\
%          ~&~ v_{i} - y_{i}(v_{max,i}-w_{wt,i}^u) \leq w_{wt,i}^u \\
%          ~&~ v_{i} - y_{i}(v_{min,i}-w_{wt,i}^l) \geq w_{wt,i}^l \\
%          ~&~ y_{i} \in {0,1} \\
%          ~&~ w_{wt,i}^u = w_{wt,i} + \delta |w_{wt,i}| + \epsilon \\
%          ~&~ w_{wt,i}^l = w_{wt,i} - \delta |w_{wt,i}| - \epsilon \\
%
% NOTE::
%
%    The code here has been based on:
%    Shlomi, T., Berkman, O., & Ruppin, E. (2005). Regulatory on/off 
%    minimization of metabolic flux changes after genetic perturbations.
%    Proceedings of the National Academy of Sciences, 102(21), 7695-7700
%
% .. Authors:
%       - Luis V. Valcarcel, 23/01/2019, University of Navarra, CIMA & TECNUN School of Engineering.


p = inputParser;
% check required arguments
addRequired(p, 'model');
addRequired(p, 'WTflux', @(x)isnumeric(x)&&isvector(x));
addRequired(p, 'rxnKO', @(x)iscell(x));
% Check optional arguments
addParameter(p, 'delta', 0.03, @(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'epsilon', 0.001, @(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'printLevel', 1, @(x)isnumeric(x)&&isscalar(x));
% extract variables from parser
parse(p, model, fluxWT, rxnKO, varargin{:});
delta = p.Results.delta;
epsilon = p.Results.epsilon;
printLevel = p.Results.printLevel;

% LP solution tolerance
global CBT_LP_PARAMS
if (exist('CBT_LP_PARAMS', 'var'))
    if isfield(CBT_LP_PARAMS, 'objTol')
        tol = CBT_LP_PARAMS.objTol;
    else
        tol = 1e-6;
    end
else
    tol = 1e-6;
end


% Check the inputs
fluxWT = reshape(fluxWT,[],1); % reshape flux vector
assert(numel(model.rxns)==numel(fluxWT), 'This flux distribution has different number of reactions than the model')
assert(norm(model.S * fluxWT)< 10*tol, 'This flux distribution cannot exist in this model')
assert(all(ismember(rxnKO, model.rxns)), 'Some reactions are not in the model')

% Eliminate almost-zero fluxes
fluxWT(abs(fluxWT)<tol) = 0;

% generate auxiliary variables
WT_upperTol = fluxWT + delta*abs(fluxWT) + epsilon;
WT_lowerTol = fluxWT - delta*abs(fluxWT) - epsilon;

%auxiliary variables
[nMets, nRxns] = size(model.S);

% Generate model
ROOMmodel = model;
new_variables = strcat('binary_',model.rxns);
% add novel variables
ROOMmodel = addCOBRAVariables(ROOMmodel,new_variables,'lb',0,'ub',1);
% add novel constrains
for i=1:nRxns
    ROOMmodel = addCOBRAConstraints(ROOMmodel, {model.rxns{i}, strcat('binary_',model.rxns{i})}, WT_upperTol(i),...
        'c', [+1, -(model.ub(i)-WT_upperTol(i))], 'dsense', 'L');
end
for i=1:nRxns
    ROOMmodel = addCOBRAConstraints(ROOMmodel, {model.rxns{i}, strcat('binary_',model.rxns{i})}, WT_lowerTol(i),...
        'c', [+1, -(model.lb(i)-WT_lowerTol(i))], 'dsense', 'G');
end
% Block reactions in model
ROOMmodel = changeRxnBounds(ROOMmodel, rxnKO, 0, 'b');
% change objective function
ROOMmodel.c(:) = 0;
ROOMmodel.evarc(cellfun(@length,regexp(ROOMmodel.evars,'^binary_'))==1) = 1;
ROOMmodel.osenseStr = 'min';

MILPproblem = buildLPproblemFromModel(ROOMmodel);

MILPproblem.vartype = char(ones(1,size(MILPproblem.A,2))*'C');
MILPproblem.vartype(MILPproblem.c==1) = 'B';

solutionROOM = solveCobraMILP(MILPproblem, 'printLevel', printLevel);

if solutionROOM.stat == 1
    fluxROOM = solutionROOM.full(1:nRxns);
    totalFluxDiff = norm(fluxROOM-fluxWT);
else
    fluxROOM = nan(nRxns,1);
    totalFluxDiff = nan;
end

end