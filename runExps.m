%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB command: >> matlab -nodesktop -r runExps -logfile runExps_auto.log
%
% Perform the experiments described in the application note
% "Computationally efficient Flux Variability Analysis"
% Authors: S. Gudmundsson and I. Thiele.
% Contributor: Laurent Heirendt, LCSB
%
% 20160315: Minor modifications for Linux support
% 20160316: Support for Matlab R2014a+
% 201604 : Support for running multiple experiments with multiple models,
%          matrices and workers
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Adding the paths
addpath(genpath('~/Dropbox/UNI.LU/sbgCloud/models'))
addpath(genpath('~/Dropbox/UNI.LU/git'))

% MATLAB commands for setting a fresh environment
clear all
clc
format long

% FVA settings
optPercentage = 90;
objective = 'max';

% Define the model indices to be solved
modelStart = 4;
modelIncrement = 1; % step through the model array
modelEnd = 4;

% Define the respective parameter to be appended - make sure that the appropriate
% arameters are set in the external code
paramstring = 'DEF';

% Define the model matrix to be solved A: coupled; S: uncoupled
matrixASvect = ['S'];

% Define the solver
solver = 'cplexint'; % or 'glpk' %%cplexint

% Parallel settings
bParallel = true; %false; true
nworkersvect = [4]; %[8; 16; 32];% Number of parallel workers

autonames = {};
autotimes = [];

% Load the respective datasets
datasets
nmodels = size(modelList,1);
T = zeros(nmodels,1);

fprintf('\n ========================== fastFVA analysis started ========================== \n');

% Print warning for optPercentage
if (optPercentage > 90)
  fprintf('\n Warning: The optPercentage is higher than 90. The solution process might take longer than you might expect.\n\n');
end

% Print out information o
if modelEnd ~= modelStart
    fprintf('\n >> The following models have been loaded and will be solved:\n\n');
    for iModel=modelStart:modelIncrement:modelEnd
        fprintf('     - %s\n\n',  modelList{iModel,1});
    end
end

% Main loop for numerical experiments
for k = 1:length(nworkersvect)

    % Set the number of workers
    if ~bParallel
      nworkers = 0;
    else
      nworkers = nworkersvect(k);
    end

    % Start a parallel pool from Matlab
    SetWorkerCount(nworkers);

    for iModel=modelStart:modelIncrement:modelEnd
        for j = 1:length(matrixASvect)

            matrixAS = matrixASvect(j);

            fprintf('\n >> Currently solving model %s, matrix: %s with %d workers. Solver: %s\n',  modelList{iModel,1}, matrixAS, nworkers, solver);

            % Read model data
            data=load([modelList{iModel,2}]);
            %data=load([dataDir,'/',modelList{iModel,2}]);
            fname=fieldnames(data);

            idx=strmatch('model',fname);
            if isempty(idx)
                fname=fname{1};
            else
                fname=fname{idx(1)};
            end

            model = getfield(data,fname);

            %chop b to the correct length
            if isfield(model,'A')
                model.b = model.b(1:size(model.A,1));
                model.csense = model.csense(1:size(model.A,1));
            end

            % Modify objective if needed
            if ~isempty(modelList{iModel,3})
                model.c=0*model.c;
                model.c(modelList{iModel,3})=1;
            end

            % Call the external fastFVA function
            tstart=tic;
            [minFlux,maxFlux,optsol,ret] = fastFVA(model,optPercentage,objective, solver,matrixAS);
            T(iModel) = toc(tstart);
            fprintf('>> nworkers = %d, \t model = %s\t%1.1f\n', nworkers, modelList{iModel,1}, T(iModel))

            % Output the file and save the respective MATLAB workspaces
            filename = strcat(modelList{iModel,1},'_',matrixAS,'_n',num2str(nworkers),'_',paramstring,'.mat');

            autonames{end+1} = {filename};
            autotimes(end+1) = T(iModel);

            % Save the corresponding solution files
            save(filename);

        end %end looping through the matrices A or S
    end % loop through the models
end %loop through the workers

% Print all the names of the numerical experiments and their respective total solution times
celldisp(autonames)
autotimes
