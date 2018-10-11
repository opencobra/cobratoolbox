function [MinimizedFlux, modelIrrev]= minimizeModelFlux(model, osenseStr, minNorm)
% This function finds the minimum flux through the network and returns the
% minimized flux and an irreversible model
%
% USAGE:
%
%    [MinimizedFlux modelIrrev]= minimizeModelFlux(model)
%
% INPUT:
%    model:              COBRA model structure
%
% OPTIONAL INPUTS:
%    osenseStr:         Maximize ('max')/minimize ('min') (opt, default = 'max')
%    minNorm:           {(0), 'one', 'zero', > 0 , `n x 1` vector}, where `[m,n]=size(S)`;
%                       0 - Default, normal LP,
%                       'one'  Minimise the Taxicab Norm using LP.
%
%                       .. math::
%
%                          min  ~&~ |v| \\
%                          s.t. ~&~ S v = b \\
%                               ~&~ c^T v = f \\
%                               ~&~ lb \leq v \leq ub
%
%                       A LP solver is required.
%                       'zero' Minimize the cardinality (zero-norm) of v
%
%                       .. math::
%
%                          min  ~&~ ||v||_0 \\
%                          s.t. ~&~ S v = b \\
%                               ~&~ c^T v = f \\
%                               ~&~ lb \leq v \leq ub
%                       The zero-norm is approximated by a non-convex approximation
%                       Six approximations are available: capped-L1 norm, exponential function
%                       logarithmic function, SCAD function, L_p norm with p<0, L_p norm with 0<p<1
%                       Note : capped-L1, exponential and logarithmic function often give
%                       the best result in term of sparsity.
%
%                       .. See "Le Thi et al., DC approximation approaches for sparse optimization,
%                          European Journal of Operational Research, 2014"
%                          http://dx.doi.org/10.1016/j.ejor.2014.11.031
%                          A LP solver is required.
%
%                       The remaining options work only with a valid QP solver:
%
%                       > 0    Minimises the Euclidean Norm of internal fluxes.
%                       Typically 1e-6 works well.
%
%                       .. math::
%
%                          min  ~&~ ||v||      \\
%                          s.t. ~&~ S v = b    \\
%                               ~&~ c^T v = f  \\
%                               ~&~ lb \leq v \leq ub
%
%                       `n` x 1   Forms the diagonal of positive definiate
%                       matrix `F` in the quadratic program
%
%                       .. math::
%
%                          min  ~&~ 0.5 v^T F v  \\
%                          s.t. ~&~ S v = b      \\
%                               ~&~ c^T v = f    \\
%                              ~&~ lb \leq v \leq ub
%
% OUTPUTS:
%   MinimizedFlux:    minimum flux possible through the netwok
%   modelIrrev:       irreversible version of 'model'
%
% .. Authors: - Nathan E. Lewis and Anne Richelle, May 2017

if exist('osenseStr', 'var') % Process arguments and set up problem
    if isempty(osenseStr)
        osenseStr = 'min';
    end
else
    if isfield(model, 'osenseStr')
        osenseStr = model.osenseStr;
    else
        osenseStr = 'min';
    end
end

if exist('minNorm', 'var')
    if isempty(minNorm)
        minNorm = 0;
    end
else
    minNorm = 0;
end

    modelIrrev = convertToIrreversible(model);% Convert the model to amodel with only irreversible reactions

    % Add a pseudo-metabolite to measure flux through network
    modelIrrev = addMetabolite(modelIrrev,'fluxMeasure');
    modelIrrev.S(end,:) = ones(size(modelIrrev.S(1,:)));        

    % Add a pseudo reaction that measures the flux through the network
    modelIrrev = addReaction(modelIrrev,'netFlux',{'fluxMeasure'},[-1],false,0,inf,0,'','');

    % Set the flux measuring demand as the objective    
    modelIrrev = changeObjective(modelIrrev, 'netFlux');

    % Minimize the flux measuring demand (netFlux)
    MinimizedFlux = optimizeCbModel(modelIrrev, osenseStr, minNorm);
end
