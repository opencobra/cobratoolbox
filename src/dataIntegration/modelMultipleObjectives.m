function solutions = modelMultipleObjectives(model, param)
% Solves multiple flux balance analysis problems, and variants thereof
%
% USAGE:
%
%    solutions = modelMultipleObjectives(model, param)
%
% INPUT:
%    model: A generic COBRA model
%
%       * .S - Stoichiometric matrix
%       * .mets - Metabolite ID vector
%       * .rxns - Reaction ID vector
%       * .lb - Lower bound vector
%       * .ub - Upper bound vector
%
% OPTIONAL INPUTS:
%    param: a structure containing the parameters for the function:
%
%        * .modelType - type of predictions {'sec', 'upt'}.
%        * .printLevel - Greater than zero to receive more output printed.
%        * .objectives -﻿List of objective functions to be tested.
%           objectives supported: 'unWeighted0norm', 'Weighted0normGE', 
%          'Weighted0normBBF', 'unWeighted1norm', 'Weighted1normGE', 
%          'Weighted1normBBF', 'unWeighted2norm', 'Weighted2normGE', 
%          'Weighted2normBBF', 'unWeightedTCBMflux', 
%          'unWeightedTCBMfluxConc'.
%    
%       entropicFluxBalanceAnalysis
%       'unWeightedTCBMflux' unweighted thermodynamic constraint based 
%       modelling for fluxes.
%       'unWeightedTCBMfluxConc' unweighted thermodynamic constraint 
%       based modelling for fluxes and concentrations.
%
%           minimize        g.*vf'*(log(vf) -1) + (cf + ci)'*vf + g.*vr'*(log(vr) -1) + (cr - ci)'*vr 
%           vf,vr,x,x0   +  f.*x' *(log(x)  -1)        + u0'*x0 + f.*x0'*(log(x0) -1)        + u0'*x0
%
%           subject to      N*(vf - vr) - x + x0  <=> b   : y_N
%           C*(vf - vr)           <=> d   : y_C
%               vl <= vf - vr <= vu  : z_v
%               dxl <= x  - x0 <= dxu : z_dx
%               0 <= vf      <=  ub : z_vf
%               0 <=      vr <= -lb : z_vr
%               xl <= x       <= xu  : z_x
%               x0l <=      x0 <= x0u : z_x0
%
%           A mosek solver is required.
%
%       zero-norm
%       'unWeighted0norm' min 0-norm unweighted.
%       and formed.
%
%            Minimize the cardinality (zero-norm) of v
%
%           .. math::
%
%               min  ~& d.*||v||_0 \\
%               s.t. ~& S v = b \\
%                    ~& c^T v = f \\
%                    ~& lb \leq v \leq ub
%
%           The zero-norm is approximated by a non-convex approximation
%           Six approximations are available: capped-L1 norm, exponential function
%           logarithmic function, SCAD function, L_p norm with p<0, L_p norm with 0<p<1
%           Note : capped-L1, exponential and logarithmic function often give
%           the best result in term of sparsity.
%
%           .. See "Le Thi et al., DC approximation approaches for sparse optimization,
%           European Journal of Operational Research, 2014"
%           http://dx.doi.org/10.1016/j.ejor.2014.11.031
%           A LP solver is required.
%
%       1-norm
%       'unWeighted1norm' min 1-norm unweighted.
%       'Weighted1normGE' min 1-norm weighted by the gene expression. 
%       'Weighted1normBBF' min 1-norm weighted by number of bonds broken 
%       and formed.
%
%           Minimise the Taxicab Norm using LP.
%
%           .. math::
%
%               min  ~& d.*|v| \\
%               s.t. ~& S v = b \\
%                    ~& c^T v = f \\
%                    ~& lb \leq v \leq ub
%
%           A LP solver is required.
%
%       2-norm
%       'unWeighted2norm' min 2-norm unweighted.
%       'Weighted2normGE' min 2-norm weighted by the gene expression.
%       'Weighted2normBBF' min 2-norm weighted by the number of bonds 
%       broken and formed.
%
%       	unweighted; minimises the squared Euclidean Norm of internal fluxes.
%
%           .. math::
%
%               min  ~& 1/2 v'*v \\
%               s.t. ~& S v = b \\
%                    ~& c^T v = f \\
%               	 ~& lb \leq v \leq ub
%
%           weighted; `n` x 1   Forms the diagonal of positive definite  matrix 
%           `F` in the quadratic program.
%
%           .. math::
%
%               min  ~& 0.5 v^T F v \\
%               s.t. ~& S v = b \\
%                    ~& c^T v = f \\
%                    ~& lb \leq v \leq ub
%
%           A QP solver is required.
%
% OUTPUTS:
%    solutions:  The solution for each objective defined in param.objectives
%       * .unWeighted0norm: min 0-norm unweighted
%       * .unWeighted1norm: min 1-norm unweighted.
%       * .Weighted1normGE: min 1-norm weighted by the gene expression. 
%       * .Weighted1normBBF: min 1-norm weighted by number of bonds broken 
%       * .unWeighted2norm: min 2-norm unweighted.
%       * .Weighted2normGE: min 2-norm weighted by the gene expression.
%       * .Weighted2normBBF: min 2-norm weighted by the number of bonds 
%       * .weightedTCBMt
%       * .weightedTCBM
%       * .unWeightedTCBMfluxConcNorm
%       * .unWeightedTCBMfluxConc: unweighted thermodynamic constraint based modelling for fluxes and concentrations
%       * .weightedTCBMflux:
%       * .unWeightedTCBMflux: unweighted thermodynamic constraint based 
%          modelling for fluxes


if nargin < 2 || isempty(param)
    param = struct;
end
if ~isfield(param, 'printLevel')
    param.printLevel = 0;
end
if ~isfield(param, 'modelType')
    param.modelType = 'sec';
end
if ~isfield(param, 'objectives')
    param.objectives =  {'unWeighted0norm'; 'Weighted0normGE'; 'unWeighted1norm'; 'Weighted1normGE';...
        'unWeighted2norm'; 'Weighted2normGE'; 'unWeightedTCBMflux'};
%     param.objectives = {'unWeighted0norm'; ...
%         'unWeighted1norm'; 'Weighted1normGE';  'Weighted1normBBF';...
%         'unWeighted2norm'; 'Weighted2normGE'; 'Weighted2normBBF'; ...
%         'weightedTCBMt'; 'weightedTCBM'; 'unWeightedTCBMfluxConcNorm'; ...
%         'unWeightedTCBMfluxConc'; 'weightedTCBMflux'; 'unWeightedTCBMflux'};
end

if isfield(model, 'g0')
    model = rmfield(model, 'g0');
end
if isfield(model, 'g1')
    model = rmfield(model, 'g1');
end

%% Print objectives and weigths

% Delete objectives that cannot be used
systemObjectives = 0;
if ~isfield(model, 'bondsBF') || length(model.rxns) ~= length(model.bondsBF)
    param.objectives(contains(param.objectives, 'BBF')) = [];
else
    model_bondsBF = columnVector(model.bondsBF);
    meanBBF =  mean(model.bondsBF(model.SConsistentRxnBool & model.bondsBF ~=0 ), 'omitnan');
    model_bondsBF(isnan(model_bondsBF))=meanBBF;
    model_bondsBF(~model.SConsistentRxnBool)=0;

    if param.printLevel > 0
        systemObjectives = systemObjectives + 1;
    end
end
if ~isfield(model, 'bondsE') || length(model.rxns) ~= length(model.bondsBF)
    param.objectives(contains(param.objectives, 'BE')) = [];
else
    model_bondsE = columnVector(model.bondsE);
    meanBE =  mean(model.bondsE(model.SConsistentRxnBool & model.bondsE ~=0 ) ,'omitnan');
    model_bondsE(isnan(model_bondsBF))=meanBE;
    model_bondsE(~model.SConsistentRxnBool)=0;

    if param.printLevel > 0
        systemObjectives = systemObjectives + 1;
    end
end
if ~isfield(model, 'expressionRxns') || length(model.rxns) ~= length(model.expressionRxns)
    param.objectives(contains(param.objectives, 'GE0')) = [];
else
    if param.printLevel > 0
        systemObjectives = systemObjectives + 3;
    end
end
if ~isfield(model,'expressionRxns0norm')
    systemObjectives = systemObjectives + 1;
    % expressionRxns0norm
    model.expressionRxns0norm = -log(model.expressionRxns) / log(max(model.expressionRxns));
    model.expressionRxns0norm(isnan(model.expressionRxns0norm)) = 0;
end
if ~isfield(model,'expressionRxns1norm')
    systemObjectives = systemObjectives + 1;
    % expressionRxns1norm
    model.expressionRxns1norm = -(log(model.expressionRxns) - max(log(model.expressionRxns)));
    % mean penalty for reactions without expression data
    model.expressionRxns1norm(isnan(model.expressionRxns1norm)) = mean(model.expressionRxns1norm, 'all', 'omitnan');
    % no penalty for exchange reactions
    model.expressionRxns1norm(~model.SConsistentRxnBool) = 0;
end
if ~isfield(model,'expressionRxns2norm')
    systemObjectives = systemObjectives + 1;
    % expressionRxns2norm
    model.expressionRxns2norm = model.expressionRxns1norm;
end
if ~isfield(model, 'DfGt0') || length(model.mets) ~= length(model.DfGt0)
    param.objectives(contains(param.objectives, 'weightedEBA')) = [];
end

% Print used objectives
if param.printLevel > 0 && ~isequal(param.modelType, 'upt')
    display('Objectives to be used:')
    display(param.objectives)
end

% Polt weights
if param.printLevel > 0 && ~isequal(param.modelType, 'upt')
    
    % Calculate the number of subplots to be printed
    graphNo = 0;
    while isprime(systemObjectives) && systemObjectives > 4
        systemObjectives = systemObjectives + 1;
    end
    p = factor(systemObjectives);
    if length(p) == 1
        p = [1, p];
    end
    %hack - German to check
    if p(2)==0
        p(2)=1;
    end
%     if p(2)==3
%         p(2)=4;
%     end
    
    figure
    if isfield(model, 'expressionRxns')
        graphNo = graphNo + 1;
        subplot(p(1), p(2), graphNo)
        hist(model.expressionRxns0norm)
        model.expressionRxns0norm(isnan(model.expressionRxns0norm)) = 0;
        title('Reaction Expression; 0 Norm')
        ylabel('Number of reactions')
        
        graphNo = graphNo + 1;
        subplot(p(1), p(2), graphNo)
        hist(model.expressionRxns1norm)
        model.expressionRxns1norm(isnan(model.expressionRxns1norm)) = 0;
        title('Reaction Expression; 1 Norm')
        ylabel('Number of reactions')
        
        graphNo = graphNo + 1;
        subplot(p(1), p(2), graphNo)
        hist(model.expressionRxns2norm)
        model.expressionRxns2norm(isnan(model.expressionRxns2norm)) = 0;
        title('Reaction Expression; 2 Norm')
        ylabel('Number of reactions')
    end
    % bondsBF
    if isfield(model, 'bondsBF') && 0
        graphNo = graphNo + 1;
        subplot(p(1), p(2), graphNo)
        hist(model.bondsBF)
        title('Bonds Broken + Formed')
        ylabel('Number of reactions')
    end
    
end

%% Test multiple objectives

modelOrig = model;
hasErrored = 0;
for i = 1:size(param.objectives, 1)
    
    model = modelOrig;
    
    switch param.objectives{i}
        
        % unweighted thermodynamic constraint based modelling
        case 'unWeightedTCBMflux'
            try
                model.osenseStr = 'min';
                model.cf = 0;
                model.cr = 0;
                model.g = 2;
                model.u0 = 0;
                model.f = 1;
                tcbmParam.method = 'fluxes';
                tcbmParam.printLevel = param.printLevel;
                tcbmParam.solver = 'mosek';
                [solutions.unWeightedTCBMflux, ~] = entropicFluxBalanceAnalysis(model, tcbmParam);
            catch ME
                solutions.unWeightedTCBMflux.stat = '';
                solutions.unWeightedTCBMflux.message = ME.message; disp(getReport(ME))
                hasErrored = 1;
            end
        case 'weightedTCBMflux'
            try
                model.osenseStr = 'min';
                model.cf = 0;%TODO add weights here
                model.cr = 0;
                model.g = 2;
                model.u0 = 0;
                model.f = 1;
                tcbmParam.method = 'fluxes';
                tcbmParam.printLevel = param.printLevel;
                tcbmParam.solver = 'mosek';
                [solutions.unWeightedTCBMflux, ~] = entropicFluxBalanceAnalysis(model, tcbmParam);
            catch ME
                solutions.unWeightedTCBMflux.stat = '';
                solutions.unWeightedTCBMflux.message = ME.message; disp(getReport(ME))
                hasErrored = 1;
            end
        case 'unWeightedTCBMfluxConc'
            try
                model.osenseStr = 'min';
                model.cf = 0;
                model.cr = 0;
                model.g = 2;
                model.u0 = 0;
                model.f = 1;
                tcbmParam.method = 'fluxConc';
                tcbmParam.printLevel = param.printLevel;
                tcbmParam.solver = 'mosek';
                [solutions.unWeightedTCBMfluxConc, ~] = entropicFluxBalanceAnalysis(model, tcbmParam);
            catch ME
                solutions.unWeightedTCBMfluxConc.stat = '';
                solutions.unWeightedTCBMfluxConc.message = ME.message; disp(getReport(ME))
                hasErrored = 1;
            end
            
        case 'unWeightedTCBMfluxConcNorm'
            try
                model.osenseStr = 'min';
                model.cf = 0;
                model.cr = 0;
                model.g = 2;
                model.u0 = 0;
                model.f = 1;
                tcbmParam.method = 'fluxConcNorm';
                tcbmParam.printLevel = param.printLevel;
                tcbmParam.solver = 'mosek';
                [solutions.unWeightedTCBMfluxConcNorm, ~] = entropicFluxBalanceAnalysis(model, tcbmParam);
            catch ME
                solutions.unWeightedTCBMfluxConcNorm.stat = '';
                solutions.unWeightedTCBMfluxConcNorm.message = ME.message; disp(getReport(ME))
                hasErrored = 1;
            end
            %thermodynamic constraint based modelling weighted by standard Gibbs energy of formation
        case 'weightedTCBM'
            try
                model.osenseStr = 'min';
                model.cf = 0;
                model.cr = 0;
                model.g = 2;
                model.u0 = model.DfG0;
                model.f = 1;
                tcbmParam.method = 'fluxConc';
                tcbmParam.printLevel = param.printLevel;
                tcbmParam.solver = 'mosek';
                [solutions.weightedTCBM, ~] = entropicFluxBalanceAnalysis(model, tcbmParam);
            catch ME
                solutions.weightedTCBM.stat = '';
                solutions.weightedTCBM.message = ME.message; disp(getReport(ME))
                hasErrored = 1;
            end
            
            %weighted thermodynamic constraint based modelling weighted by standard transformed Gibbs energy of formation
        case 'weightedTCBMt'
            try
                model.osenseStr = 'min';
                model.cf = 0;
                model.cr = 0;
                model.g = 2;
                model.u0 = model.DfG0;
                model.f = 1;
                tcbmParam.method = 'fluxConcNorm';
                tcbmParam.printLevel = param.printLevel;
                tcbmParam.solver = 'mosek';
                [solutions.weightedTCBMt, ~] = entropicFluxBalanceAnalysis(model, tcbmParam);
            catch ME
                solutions.weightedTCBMt.stat = '';
                solutions.weightedTCBMt.message = ME.message; disp(getReport(ME))
                hasErrored = 1;
            end
            
            % min 0-norm unweighted
        case 'unWeighted0norm'
            try
                solutions.unWeighted0norm = optimizeCbModel(model, 'min', 'zero');
            catch ME
                solutions.unWeighted0norm.stat = '';
                solutions.unWeighted0norm.message = ME.message; disp(getReport(ME))
                hasErrored = 1;
            end
            
            % min 0-norm weighted by the gene expression
        case 'Weighted0normGE'
            model.g0 = model.expressionRxns0norm;
            try
                solutions.Weighted0normGE = optimizeCbModel(model, 'min', 'optimizeCardinality');
            catch ME
                solutions.Weighted0normGE.stat = '';
                solutions.Weighted0normGE.message = ME.message; disp(getReport(ME))
                hasErrored = 1;
            end
            
            % min 0-norm weighted by number of bonds broken and formed
        case 'Weighted0normBBF'
            model.g0 = model_bondsBF;
            try
                solutions.Weighted0normBBF = optimizeCbModel(model, 'min', 'optimizeCardinality');
            catch ME
                solutions.Weighted0normBBF.stat = '';
                solutions.Weighted0normBBF.message = ME.message; disp(getReport(ME))
                hasErrored = 1;
            end
            
            % min 1-norm unweighted
        case 'unWeighted1norm'
            try
                solutions.unWeighted1norm = optimizeCbModel(model, 'min', 'one');
            catch ME
                solutions.unWeighted1norm.stat = '';
                solutions.unWeighted1norm.message = ME.message; disp(getReport(ME))
                hasErrored = 1;
            end
            
            % min 1-norm weighted by the gene expression
        case 'Weighted1normGE'
            model.g1 = model.expressionRxns1norm + abs(min(model.expressionRxns1norm));
            try
                solutions.Weighted1normGE = optimizeCbModel(model, 'min', 'one');
            catch ME
                solutions.Weighted1normGE.stat = '';
                solutions.Weighted1normGE.message = ME.message; disp(getReport(ME))
                hasErrored = 1;
            end
            
            % min 1-norm weighted by number of bonds broken and formed
        case 'Weighted1normBBF'
            model.g1 = model_bondsBF;
            try
                solutions.Weighted1normBBF = optimizeCbModel(model, 'min', 'one');
            catch ME
                solutions.Weighted1normBBF.stat = '';
                solutions.Weighted1normBBF.message = ME.message; disp(getReport(ME))
                hasErrored = 1;
            end
            
            % min 2-norm unweighted
        case 'unWeighted2norm'
            try
                solutions.unWeighted2norm = optimizeCbModel(model, 'min', 1e-6);
            catch ME
                solutions.unWeighted2norm.stat = '';
                solutions.unWeighted2norm.message = ME.message; disp(getReport(ME))
                hasErrored = 1;
            end
            
            % min 2-norm weighted by the gene expression - make sure weights are non-negative
        case 'Weighted2normGE'
            try
               solutions.Weighted2normGE = optimizeCbModel(model, 'min', model.expressionRxns2norm + abs(min(model.expressionRxns2norm)) + 1e-6);
                if isequal(solutions.Weighted2normGE.origStat, 'INFEASIBLE')
                    solutions.Weighted2normGE.message = 'INFEASIBLE';
                end
            catch ME
                solutions.Weighted2normGE.stat = '';
                solutions.Weighted2normGE.message = ME.message; disp(getReport(ME))
                hasErrored = 1;
            end
            
            % min 2-norm weighted by the number of bonds broken and formed
        case 'Weighted2normBBF'
            try
                solutions.Weighted2normBBF = optimizeCbModel(model, 'min', model_bondsBF + 1e-6);
            catch ME
                solutions.Weighted2normBBF.stat = '';
                solutions.Weighted2normBBF.message = ME.message; disp(getReport(ME))
                hasErrored = 1;
            end
    end
    if hasErrored == 1
        disp(getReport(ME))
    end
end
end
