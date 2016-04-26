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
addpath(genpath('~/Dropbox/UNI.LU/git/pCOBRA'))

% MATLAB commands for setting a fresh environment
clear all
clc
format long

% Print out the header of the script
fprintf('\n ============================= fastFVA driver started ============================= \n');

% Clean files from previous run
cleanFiles

% FVA settings
optPercentage = 90;
objective = 'max';

% Define the model indices to be solved
modelStart = 4;
modelIncrement = 1; % step through the model array
modelEnd = modelStart;

% Define the respective parameter to be appended - make sure that the appropriate
% arameters are set in the external code
paramstring = '';

% Define the model matrix to be solved A: coupled; S: uncoupled
matrixASvect = ['A']; %['S', 'A'];

% Define the solver
solver = 'cplexint'; % or 'glpk' %%cplexint

% Parallel settings
bParallel = true; %false; true
nworkersvect = [4]; %[8; 16; 32];% Number of parallel workers

% Change the solution algorithm
% 0: DEFAULT: CPXlpopt
% 1: CPXprimopt
% 2: CPXdualopt
cpxAlgorithm = 0;

autonames = {};
autotimes = [];

% Load the respective datasets
datasets

% Adjust the file names according to the parameter experiment
if cpxAlgorithm == 1
  paramstring = strcat(paramstring,'_METHOD_PRIMOPT');
elseif cpxAlgorithm == 2
  paramstring = strcat(paramstring,'_METHOD_DUALOPT');
else
  paramstring = strcat(paramstring,'_METHOD_LPOPT');
end

nmodels = size(modelList,1);
T = zeros(nmodels,1);

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
else
  iModel = modelStart;
  fprintf('\n >> The following model has been loaded and will be solved: %s\n\n', modelList{iModel,1});
end

% Load all the CPLEX parameters of the parameter set in CPLEXParamSet.m
cpxControl = CPLEXParamSet;

% Main loop for numerical experiments
for k = 1:length(nworkersvect)

    % Set the number of workers
    if ~bParallel
      nworkers = 0;
    else
      nworkers = nworkersvect(k);
    end

    %try to take advantage of more cores
    %if nworkers == 16
    %  cpxControl.AUXROOTTHREADS = 4
%    end



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
            [minFlux,maxFlux,optsol,ret] = fastFVA(model, optPercentage, objective, solver, matrixAS, cpxControl, cpxAlgorithm);
            T(iModel) = toc(tstart);
            fprintf('\n >> nworkers = %d; model = %s; Time = %1.1f [s]\n', nworkers, modelList{iModel,1}, T(iModel))

            % Output the file and save the respective MATLAB workspaces
            filename = strcat('results/', modelList{iModel,1},'_',matrixAS,'_n',num2str(nworkers),'_',paramstring,'.mat');

            autonames{end+1} = {filename};
            autotimes(end+1) = T(iModel);

            % Save the corresponding solution files
            save(filename);

        end %end looping through the matrices A or S
    end % loop through the models
end %loop through the workers

% Print all the names of the numerical experiments and their respective total solution times
fprintf('\n ===================================== Summary ==================================== \n\n');
for i =1:length(autotimes)
      fprintf('    %d. \t <> \t %s \t <> \t %1.1f [s]\n', i, autonames{i}{1}, autotimes(i));
end
fprintf('\n ================================================================================== \n');
