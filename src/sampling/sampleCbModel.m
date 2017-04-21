function [modelSampling,samples,volume] = sampleCbModel(model,sampleFile,samplerName,options,modelSampling)
% Samples the solution-space of a constraint-based model
%
% USAGE:
%
%    [modelSampling, samples] = sampleCbModel(model, sampleFile, samplerName, options, modelSampling)
%
% INPUTS:
%    model:         COBRA model structure
%    sampleFile:    File names for sampling output files (only required for
%                   ACHR)
%
% OPTIONAL INPUTS:
%    samplerName:   {('ACHR'),'CHRR'} Name of the sampler to be used to sample the solution
%    options:       Options for sampling and pre/postprocessing (default values
%                   in parenthesis)
%
%                     * .nStepsPerPoint - Number of sampler steps per point saved (200)
%                     * .nPointsReturned - Number of points loaded for analysis (2000)
%                     * .nWarmupPoints - Number of warmup points (5000). ACHR only.
%                     * .nFiles - Number of output files (10). ACHR only.
%                     * .nPointsPerFile - Number of points per file (1000). ACHR only.
%                     * .nFilesSkipped - Number of output files skipped when loading points to avoid potentially biased initial samples (2) loops (true). ACHR only.
%                     * .maxTime - Maximum time limit (Default = 36000 s). ACHR only.
%                     * .toRound - Option to round the model before sampling (true). CHRR only.
%    modelSampling: From a previous round of sampling the same
%                   model. Input to avoid repeated preprocessing.
%
% OUTPUTS:
%    modelSampling: Cleaned up model used in sampling
%    samples:       Uniform random samples of the solution space
%
% EXAMPLES:
%    %1) Sample a model called 'superModel' using default settings and save the
%    %   results in files with the common beginning 'superModelSamples'
%
%    [modelSampling,samples] = sampleCbModel(superModel,'superModelSamples');
%
%    %2) Sample a model called 'hyperModel' using default settings except with a total of 50 sample files
%    %   saved and with 5000 sample points returned.
%    %   Save the results in files with the common beginning 'hyperModelSamples'
%
%    options.nFiles = 50;
%    options.nPointsReturned = 5000;
%    [modelSampling,samples] = sampleCbModel(hyperModel,'hyperModelSamples');
%
% .. Author: - Markus Herrgard 8/14/06

nWarmupPoints = 5000;
nFiles = 10;
nPointsPerFile = 1000;
nStepsPerPoint = 200;
nPointsReturned = 2000;
nFilesSkipped = 2;
maxTime = 10*3600;
toRound = 1;
% Default options above
if (nargin < 3 || isempty(samplerName))
    samplerName = 'ACHR';
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
end

if nargin < 5
    modelSampling = [];
end

switch samplerName
    case 'ACHR'
        fprintf('Prepare model for sampling\n');
        % Prepare model for sampling by reducing bounds
        [nMet,nRxn] = size(model.S);
        fprintf('Original model: %d rxns %d metabolites\n',nRxn,nMet);

        % Reduce model
        fprintf('Reduce model\n');
        model.rxns = regexprep(model.rxns,'(_r)$','_bladibla'); % Workaround to avoid renaming reactions that end in '_r'

        modelRed = reduceModel(model, 1e-6, false,false,true);

        modelRed.rxns = regexprep(modelRed.rxns,'(_bladibla)$','_r'); % Replace '_r' ending
        [nMet,nRxn] = size(modelRed.S);
        fprintf('Reduced model: %d rxns %d metabolites\n',nRxn,nMet);
        save modelRedTmp modelRed;

        modelSampling = modelRed;

        % Use Artificial Centering Hit-and-run

        fprintf('Create warmup points\n');
        % Create warmup points for sampler
        warmupPts= createHRWarmup(modelSampling,nWarmupPoints);

        save sampleCbModelTmp modelSampling warmupPts

        fprintf('Run sampler for a total of %d steps\n',nFiles*nPointsPerFile*nStepsPerPoint);
        % Sample model
        ACHRSampler(modelSampling,warmupPts,sampleFile,nFiles,nPointsPerFile,nStepsPerPoint,[],[],maxTime);

        fprintf('Load samples\n');
        % Load samples
        nPointsPerFileLoaded = ceil(nPointsReturned/(nFiles-nFilesSkipped));
        if (nPointsPerFileLoaded > nPointsPerFile)
            error('Attempted to return more points than were saved');
        end
        samples = loadSamples(sampleFile,nFiles,nPointsPerFileLoaded,nFilesSkipped);
        samples = samples(:,round(linspace(1,size(samples,2),min([nPointsReturned,size(samples,2)]))));
        % Fix reaction directions
        [modelSampling,samples] = convRevSamples(modelSampling,samples);

        volume = 'Set samplerName = ''MFE'' to estimate volume.';

    case 'CHRR'
        [samples,modelSampling] = chrrSampler(model,nStepsPerPoint,nPointsReturned,toRound,modelSampling);

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
        if 1
            A=[ model.S;...
                -model.S;...
                -eye(n,n);...
                eye(n,n)];
            b=[ model.b;...
                -model.b;...
                -model.lb;...
                model.ub];
        else
            A=[ model.S;...
                -eye(n,n);...
                eye(n,n)];
            b=[ model.b;...
                -model.lb;...
                model.ub];
        end
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
        [volume,T,steps,r_steps] = Volume(P,E,eps);

        modelSampling=[];
        samples=[];

    otherwise
        error(['Unknown sampler: ' samplerName]);
end
