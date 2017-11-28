function [samples,roundedPolytope] = chrrExpSampler(model,numSkip,numSamples,lambda,toRound,roundedPolytope,minFlux,maxFlux)
% CHRRSAMPLER Generate uniform random flux samples with CHRR
%   Coordinate Hit-and-Run with Rounding
%
% [samples,roundedPolytope,minFlux,maxFlux] = chrrSampler(model,numSkip,numSamples,toRound,roundedPolytope,minFlux,maxFlux);
%
%   chrrSampler will generate numSamples samples from model, taking
%   numSkip steps of a random walk between each sample
%
%   Rounding the polytope is a potentially expensive step. If you generate multiple rounds
%   of samples from a single model, you can save roundedPolytope from the first round and
%   input it for subsequent rounds.
%
% INPUTS:
% model ... COBRA model structure with fields:
% .S ... The m x n stoichiometric matrix
% .lb ... n x 1 lower bounds on fluxes
% .ub ... n x 1 upper bounds on fluxes
% .c ... n x 1 linear objective
% numSkip ... Number of steps of coordinate hit-and-run between samples
% numSamples ... Number of samples
%
% OPTIONAL INPUTS:
% lambda ... the bias vector, i.e. generate samples from exp(-<lambda, x>) restricted to the feasible region.
%            ***OPTIONAL ONLY IF model.c is nonzero, in which case we set
%            lambda=model.c
% toRound ... {0,(1)} Option to round the polytope before sampling.
% roundedPolytope ... The rounded polytope from a previous round of
%                     sampling the same model.
% minFlux,maxFlux ... n x 1 flux minima and maxima from flux variability
%                     analysis of the same model.
%
% OUTPUTS:
% samples ... n x numSamples matrix of random flux samples
% roundedPolytope ... The rounded polytope. Save for use in subsequent
%                     rounds of sampling.
%
% November 2017, Ben Cousins and Hulda S. Haraldsdóttir

% Define defaults
if nargin < 4
   lambda = model.c;
end

if max(abs(lambda))<1e-8
       error('Bias vector is too close to the zero vector.');
end

if nargin>=6 && isempty(numSkip)
    numSkip = 8*size(roundedPolytope.A,2)^2;
end

if nargin<3 || isempty(numSamples)
    numSamples = 1000;
end

if nargin<5 || isempty(toRound)
    toRound=1;
end

if nargin < 6 || isempty(roundedPolytope)
    toPreprocess = 1;
else
    toPreprocess = 0;
end

if nargin < 7 || isempty(minFlux)
    toGetWidths = 1;
else
    toGetWidths = 0;
end

% Preprocess model
if toPreprocess
    
    % parse the model to get the meat
    P = chrrParseModel(model);
    
    %check to make sure P.A and P.b are defined, and appropriately sized
    if (isfield(P,'A')==0 || isfield(P,'b')==0) || (isempty(P.A) || isempty(P.b))
        %either P.A or P.b do not exist
        error('You need to define both P.A and P.b for a polytope {x | P.A*x <= P.b}.');
    end
    
    [num_constraints,dim] = size(P.A);
    
    if exist('numSkip')~=1 || isempty(numSkip)
        numSkip=8*dim^2;
    end
    
    fprintf('Currently (P.A, P.b) are in %d dimensions\n', dim);
    
    if size(P.b,2)~= 1 || num_constraints ~= size(P.b,1)
        error('Dimensions of P.b do not align with P.A.\nP.b should be a %d x 1 vector.',num_constraints);
    end
    
    if (isfield(P,'A_eq')==0 || isempty(P.A_eq)) && ...
            (isfield(P,'b_eq')==0 || isempty(P.b_eq))
        P.A_eq = [];
        P.b_eq = [];
    end
    
    %preprocess the polytope of feasible solutions
    %restict to null space
    %round via maximum volume ellipsoid
    options.toRound=1;
    options.bioModel=1;
    options.fullDim=0;
    options.model = model;
    options.model.c = 0*options.model.c;
    [roundedPolytope] = preprocess(P,options);
    roundedPolytope.lambda = -lambda' * roundedPolytope.N;
end

fprintf('Generating samples...\n');

if norm(roundedPolytope.lambda)<1e-8
    warning('In the preprocessed space, bias vector is close to zero. Reverting to uniform sampling.');
    samples = genSamples(roundedPolytope, numSkip, numSamples);
else
    %now we're ready to sample
    samples = genSamplesExp(roundedPolytope, roundedPolytope.lambda, numSkip, numSamples);
end
end

