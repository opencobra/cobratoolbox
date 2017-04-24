function [samples,roundedPolytope,minFlux,maxFlux] = chrrSampler(model,numSkip,numSamples,toRound,roundedPolytope,minFlux,maxFlux)
% Generate uniform random flux samples with CHRR
% Coordinate Hit-and-Run with Rounding
%
% USAGE:
%
%    [samples, roundedPolytope, minFlux, maxFlux] = chrrSampler(model, numSkip, numSamples, toRound, roundedPolytope, minFlux, maxFlux);
%
% INPUTS:
%    model:              COBRA model structure with fields:
%
%                          * .S - The `m` x `n` stoichiometric matrix
%                          * .lb - `n` x 1 lower bounds on fluxes
%                          * .ub - `n` x 1 upper bounds on fluxes
%                          * .c - `n` x 1 linear objective
%    numSkip:            Number of steps of coordinate hit-and-run between samples
%    numSamples:         Number of samples
%
% OPTIONAL INPUTS:
%    toRound:            {0,1} Option to round the polytope before sampling.
%    roundedPolytope:    The rounded polytope from a previous round of
%                        sampling the same model.
%    minFlux, maxFlux:    `n` x 1 flux minima and maxima from flux variability
%                        analysis of the same model.
%
% OUTPUTS:
%    samples:            `n` x `numSamples` matrix of random flux samples
%    roundedPolytope:    The rounded polytope. Save for use in subsequent
%                        rounds of sampling.
%    minFlux, maxFlux:
%
% .. Authors: - Ben Cousins and Hulda S. Haraldsdóttir, March 2017
%
% `chrrSampler` will generate `numSamples` samples from model, taking
% `numSkip` steps of a random walk between each sample
%
% Rounding the polytope is a potentially expensive step. If you generate multiple rounds
% of samples from a single model, you can save `roundedPolytope` from the first round and
% input it for subsequent rounds.

if nargin>=5 && isempty(numSkip)
    numSkip = 8*size(roundedPolytope.A,2)^2;
end

if nargin<3 || isempty(numSamples)
    numSamples = 1000;
end

if nargin<4 || isempty(toRound)
    toRound=1;
end

if nargin < 5 || isempty(roundedPolytope)
    toPreprocess = 1;
else
    toPreprocess = 0;
end

if nargin < 6 || isempty(minFlux)
    toGetWidths = 1;
else
    toGetWidths = 0;
end
% End of define defaults
% Preprocess model
if toPreprocess

    % parse the model to get the meat
    P = chrrParseModel(model);

    %check for width 0 facets to make sure we are full dimensional
    %also check for feasibility
    fprintf('Checking for width 0 facets...\n');

    if toGetWidths
        %check if we can use fastFVA
        if exist('fastFVA')==2
            %check if we can do parallel for fastFVA
            v=ver;
            PCT='Parallel Computing Toolbox';
            if  any(strcmp(PCT,{v.Name}))
                p = parcluster('local');
                SetWorkerCount(p.NumWorkers);
            end
            [minFlux, maxFlux] = fastFVA(model,100);
        else
            [minFlux, maxFlux] = fluxVariability(model);
        end
    end

    eps_cutoff = 1e-7;

    isEq = (maxFlux - minFlux) < eps_cutoff;
    eq_constraints = sparse(sum(isEq),size(P.A_eq,2));
    eq_constraints(:,isEq) = speye(sum(isEq));

    P.A_eq = [P.A_eq; eq_constraints];
    P.b_eq = [P.b_eq; minFlux(isEq)];

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
    [roundedPolytope] = preprocess(P, toRound);
end

fprintf('Generating samples...\n');

%now we're ready to sample
samples = genSamples(roundedPolytope, numSkip, numSamples);

% samples = genSamplesGaussian(roundedPolytope,numSkip,numSamples,100*ones(size(roundedPolytope.N,1),1),eye(size(roundedPolytope.N,1)));

end
