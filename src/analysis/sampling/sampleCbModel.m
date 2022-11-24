function [modelSampling,samples,volume] = sampleCbModel(model, sampleFile, samplerName, options, modelSampling)
% Samples the solution-space of a constraint-based model
%
% USAGE:
%
%    [modelSampling, samples] = sampleCbModel(model, sampleFile, samplerName, options, modelSampling)
%
% INPUTS:
%    model:           COBRA model structure with fields
%                        * .S - Stoichiometric matrix
%                        * .b - Right hand side vector
%                        * .lb - 'n x 1' vector: Lower bounds
%                        * .ub - 'n x 1' vector: Upper bounds
%                        * .C - 'k x n' matrix of additional inequality constraints
%                        * .d - 'k x 1' rhs of the above constraints
%                        * .dsense - 'k x 1' the sense of the above constraints ('L' or 'G')
%                        * .vMean - 'n x 1' vector: the mean for Gaussian sampling (RHMC only)
%                        * .vCov - 'n x 1' vector: the diagonal for the covariance for Gaussian sampling  (RHMC only)
%
% OPTIONAL INPUTS:
%    sampleFile:    File names for sampling output files (only implemented for ACHR)
%    samplerName:   {('CHRR'), 'ACHR', 'RHMC'} Name of the sampler to be used to
%                   sample the solution.
%    options:       Options for sampling and pre/postprocessing (default values
%                   in parenthesis).
%
%                     * .nStepsPerPoint - Number of sampler steps per point saved (200)
%                     * .nPointsReturned - Number of points loaded for analysis (2000)
%                     * .nWarmupPoints - Number of warmup points (5000). ACHR only.
%                     * .nFiles - Number of output files (10). ACHR only.
%                     * .nPointsPerFile - Number of points per file (1000). ACHR only.
%                     * .nFilesSkipped - Number of output files skipped when loading points to avoid potentially biased initial samples (2) loops (true). ACHR only.
%                     * .maxTime - Maximum time limit (Default = 36000 s). ACHR only.
%                     * .toRound - Option to round the model before sampling (true). CHRR only.
%                     * .lambda - the bias vector for exponential sampling. CHRR_EXP only.
%                     * .nWorkers - Number of parallel workers. RHMC only.
%    modelSampling: From a previous round of sampling the same
%                   model. Input to avoid repeated preprocessing.
%
% OUTPUTS:
%    modelSampling:    Cleaned up model used in sampling
%    samples:          `n x numSamples` matrix of flux vectors
%
% EXAMPLES:
%    %1) Sample a model called 'superModel' using default settings and save the
%    %   results in files with the common beginning 'superModelSamples'
%
%    [modelSampling,samples] = sampleCbModel(superModel,'superModelSamples');
%
%    %2) Sample a model called 'hyperModel' using default settings except with a total of 50 sample files
%    %   saved and with 5000 sample points returned.
%
%    options.nFiles = 50;
%    options.nPointsReturned = 5000;
%    [modelSampling,samples] = sampleCbModel(hyperModel,'options',options);
%
% .. Author: - Markus Herrgard 8/14/06

global SOLVERS

nWarmupPoints = 5000;
nFiles = 10;
nPointsPerFile = 1000;
nStepsPerPoint = 200;
nPointsReturned = 2000;
nFilesSkipped = 2;
maxTime = 10 * 3600;
toRound = 1;
useFastFVA = false;
optPercentage = 100;
% Default options above
if ~exist('sampleFile','var')
    samplerName = 'sampleFile.mat';
end
if ~exist('samplerName','var')
    samplerName = 'CHRR';
end

if (nargin < 3 || isempty(samplerName))
    samplerName = 'CHRR';
end
if (nargin < 5 || isempty(modelSampling))
    modelSampling = [];
end

% Handle options
if exist('options','var')
    if (isfield(options,'nStepsPerPoint'))
        nStepsPerPoint = options.nStepsPerPoint;
    end
    if (isfield(options,'nPointsReturned'))
        nPointsReturned = options.nPointsReturned;
    end
    if (isfield(options,'nWarmupPoints'))
        nWarmupPoints = options.nWarmupPoints;
    end
    if (isfield(options,'nFiles'))
        nFiles = options.nFiles;
    end
    if (isfield(options,'nPointsPerFile'))
        nPointsPerFile = options.nPointsPerFile;
    end
    if (isfield(options,'nFilesSkipped'))
        nFilesSkipped = options.nFilesSkipped;
    end
    if (isfield(options,'maxTime'))
        maxTime = options.maxTime;
    end
    if (isfield(options,'toRound'))
        toRound = double(options.toRound);
    end
    if (isfield(options,'useFastFVA'))
        useFastFVA = options.useFastFVA;
    end
    if (isfield(options,'optPercentage'))
        optPercentage = options.optPercentage;
    end
    if (isfield(options,'nWorkers'))
        nWorkers = options.nWorkers;
    end
end

switch samplerName
    case 'ACHR'
        fprintf('Prepare model for sampling\n');
        % Prepare model for sampling by reducing bounds
        [nMet, nRxn] = size(model.S);
        fprintf('Original model: %d rxns %d metabolites\n', nRxn, nMet);

        % Reduce model
        fprintf('Reduce model\n');
        model.rxns = regexprep(model.rxns,'(_r)$', '_bladibla'); % Workaround to avoid renaming reactions that end in '_r'
        if isempty(modelSampling)
            modelRed = reduceModel(model, 1e-6, false, false, true);
            modelRed.rxns = regexprep(modelRed.rxns, '(_bladibla)$', '_r'); % Replace '_r' ending
            [nMet,nRxn] = size(modelRed.S);
            fprintf('Reduced model: %d rxns %d metabolites\n', nRxn, nMet);
        else
            modelRed = modelSampling;
        end
        save modelRedTmp modelRed;

        modelSampling = modelRed;

        % Use Artificial Centering Hit-and-run

        fprintf('Create warmup points\n');
        % Create warmup points for sampler
        warmupPts= createHRWarmup(modelSampling, nWarmupPoints);

        save sampleCbModelTmp modelSampling warmupPts

        fprintf('Run sampler for a total of %d steps\n', nFiles*nPointsPerFile*nStepsPerPoint);
        % Sample model
        ACHRSampler(modelSampling, warmupPts, sampleFile, nFiles, nPointsPerFile, nStepsPerPoint, [], [], maxTime);

        fprintf('Load samples\n');
        % Load samples
        nPointsPerFileLoaded = ceil(nPointsReturned / (nFiles - nFilesSkipped));
        if (nPointsPerFileLoaded > nPointsPerFile)
            error('Attempted to return more points than were saved');
        end
        samples = loadSamples(sampleFile, nFiles, nPointsPerFileLoaded, nFilesSkipped);
        samples = samples(:, round(linspace(1, size(samples, 2), min([nPointsReturned, size(samples, 2)]))));
        % Fix reaction directions
        [modelSampling, samples] = convRevSamples(modelSampling, samples);

        volume = 'Set samplerName = ''MFE'' to estimate volume.';

    case 'CHRR'
        [samples, modelSampling] = chrrSampler(model, nStepsPerPoint, nPointsReturned, toRound, modelSampling, useFastFVA,optPercentage);

        volume = 'Set samplerName = ''MFE'' to estimate volume.';

    case 'CHRR_EXP'
        %get the bias vector
        if isfield(options,'lambda')
            lambda = options.lambda;
        elseif isfield(model,'c')
            lambda = model.c;
        end

        [samples, modelSampling] = chrrExpSampler(model, nStepsPerPoint, nPointsReturned, lambda, toRound, modelSampling, useFastFVA);

        volume = 'Set samplerName = ''MFE'' to estimate volume.';
    case 'MFE'
        %[volume,T,steps] = Volume(P,E,eps,p,flags)
        %This function is a randomized algorithm to approximate the volume of a convex
        %body K = P \cap E with relative error eps. The last 4 parameters are optional;
        %you can see the default values at the top of Volume.m.

        %---INPUT VALUES---
        %P: the polytope [A b] which is {x | Ax <= b}
        %E: the ellipsoid [Q v] which is {x | (x-v)'Q^{-1}(x-v)<=1}
        %eps: the target relative error
        %p: a point inside P \cap E close to the center
        %flags: a string of input flags. see parseFlags.m

        %---RETURN VALUES---
        %volume: the computed volume estimate
        %T: the rounding matrix. If no rounding, then T is identity matrix
        %steps: the number of steps the volume algorithm took
        %r_steps: the number of steps the rounding algorithm took

        %assign default values if not assigned in function call
        [m,n]=size(model.S);

        A=[ model.S;...
            -model.S;...
            -eye(n,n);...
            eye(n,n)];
        b=[ model.b;...
            -model.b;...
            -model.lb;...
            model.ub];
        % A=[ model.S;...
        %     -eye(n,n);...
        %     eye(n,n)];
        % b=[ model.b;...
        %     -model.lb;...
        %     model.ub];

        P=[A b];
        E=[];
        if ~isfield(options,'eps')
            eps=0.15;
        else
            eps=options.eps;
        end

        %get an intial point
        FBAsolution = optimizeCbModel(model);
        p=FBAsolution.x;
        %[volume,T,steps,r_steps] = Volume(P,E,eps,p,flags);
        %[volume,T,steps,r_steps] = Volume(P,E,eps,p);
        [volume, T, steps, r_steps] = Volume(P,E,eps);

        modelSampling=[];
        samples=[];
    
    case 'RHMC'
        if ~isempty(modelSampling) && isfield(modelSampling, 'problem')
           P = modelSampling.problem;
        else
           P = struct;        
           if (~isfield(model,'S') || ~isfield(model,'b'))
               error('You need to define both model.S and model.b');
           else
               P.Aeq = model.S;
               P.beq = model.b;
           end
           if isfield(model,'lb')
               P.lb = model.lb;
           end
           if isfield(model,'ub')
               P.ub = model.ub;
           end
           if isfield(model,'dsense')
               I = (model.dsense == 'E');
               P.Aeq = [P.Aeq; model.C(I,:)];
               P.beq = [P.beq; model.d(I)];
               P.Aineq = model.C(~I,:);
               P.bineq = model.d(~I,:);
               flip = 1-2*(model.dsense(~I) == 'G');
               P.Aineq = flip.*P.Aineq;
               P.bineq = flip.*P.bineq;
           end
        end
        
        if isfield(model,'vMean') || isfield(model,'vCov')
           if (isa(P,'Polytope'))
              warning('vMean and vCov options are ignored. We will use the same vMean and vCov last time.');
           else
              n = size(P.Aeq, 2);
              if isfield(model,'vMean')
                 vMean = model.vMean;
                 assert(all(size(vMean) == [n, 1]), 'incorrect size for model.vMean');
              else
                 vMean = zeros(n,1);
              end

              if isfield(model,'vCov')
                 assert(all(size(model.vCov) == [n, 1]), 'incorrect size for model.vCov');
                 assert(all(model.vCov >= 0), 'model.vCov must be non-negative');
                 vInvCov = 1./model.vCov;

                 idx = find(model.vCov < 1e-15);
                 if ~isempty(idx)
                    vInvCov(idx) = 1;
                    spOne = speye(size(P.lb,1));
                    P.Aeq = [P.Aeq; spOne(idx, :)];
                    P.beq = [P.beq; vMean(idx)];
                 end
              else
                 vInvCov = ones(n,1);
              end

              P.f = @(x) (vInvCov'*((x-vMean).*(x-vMean)))/2;
              P.df = @(x) vInvCov.*(x-vMean);
              P.ddf = @(x) vInvCov;
           end
        end

        opts = default_options();
        opts.maxTime = maxTime;
        if isfield(options,'nWorkers')
            opts.nWorkers = options.nWorkers;
        end
        o = sample(P, nPointsReturned, opts);
        samples = o.samples;
%         if size(samples,2) > nPointsReturned
%             samples = samples(:, ((size(samples,2)-nPointsReturned):end));
%         end
        modelSampling = o;
        modelSampling.samples = [];
        volume = 'Set samplerName = ''MFE'' to estimate volume.';
    otherwise
        error(['Unknown sampler: ' samplerName]);
end
