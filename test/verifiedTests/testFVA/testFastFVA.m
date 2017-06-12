%===========================================================================================
% MATLAB command: >> matlab -nodesktop -r simpleDriverFVA -logfile simpleDriverFVA.log
%
% Author: Laurent Heirendt, LCSB
% Date: June 2016
%
% Minimum working examples
%
% Example 1 - full fastFVA, minimal number of output arguments
% [minFluxT,maxFluxT,optsolT,retT] = fastFVA(model,optPercentage,objective,solver);
%
% Example 2 - full fastFVA, all output arguments
% [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT] = fastFVA(model,optPercentage,objective,solver);
%
% Example 3 - fastFVAex and customized set of CPLEX parameters
% matrixAS = 'S'; %'A'
% cpxControl = CPLEXParamSet;
% rxnsList = model.rxns(1:10);
% [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT] = fastFVA(model,optPercentage,objective, ...
%                                                           solver, matrixAS, cpxControl, rxnsList);
%===========================================================================================

% MATLAB commands for setting a fresh environment
%clear all; clc; format long;

%w = warning('off', 'all');

%% Setting parameters

% Root directory
rootdirect = '../../';

% Adding the paths
%addpath(genpath(rootdirect))

% Choice of the example
example = 1;

% FVA settings
optPercentage = 90;
objective = 'max';

% Define the number of workers to be used
nworkers = 2;

% Define the solver
solver = 'cplex';

% Model loading
data = load('e_coli_core.mat', 'model');

% fastFVA validation
validation = false;

% Add all relevant project paths
if ispc && validation
    home = [getenv('HOMEDRIVE') getenv('HOMEPATH')];
    addpath(genpath([home '/work/git/cobraMSP/fastCobrawin/fastFVAwin']))
end

% Print out the header of the script
    fprintf('================================================================================\n\n')
    fprintf('\n -------------------------------------       Toy Example       --------------------------------- \n\n');

% Stoichiometric matrix
% (adapted from Papin et al. Genome Res. 2002 12: 1889-1900.)
model.S=[
%	 v1 v2 v3 v4 v5 v6 b1 b2 b3
    -1  0  0  0  0  0  1  0  0 % A
	  1 -2 -2  0  0  0  0  0  0 % B
	  0  1  0  0 -1 -1  0  0  0 % C
	  0  0  1 -1  1  0  0  0  0 % D
	  0  0  0  1  0  1  0 -1  0 % E
	  0  1  1  0  0  0  0  0 -1 % byp
	  0  0 -1  1 -1  0  0  0  0 % cof
        ];

% Flux limits
%           v1   v2   v3   v4   v5   v6   b1    b2   b3
model.lb=[   0,   0,   0,   0,   0,   0,   0,   0,   0]'; % Irreversibility
model.ub=[ inf, inf, inf, inf, inf, inf,  10, inf, inf]'; % b1 represents the "substrate"

% b2 represents the "growth"
model.c=[0 0 0 0 0 0 0 1 0]';
model.b=zeros(size(model.S,1),1);

model.rxns={'v1','v2','v3','v4','v5','v6','b1','b2','b3'};

optPercentage=100; % FVA based on maximum growth
for iExperiment=1:2
   if iExperiment==1
      str='Flux ranges for the wild-type network';
   elseif iExperiment==2
      str='Flux ranges for a mutant with reaction v6 knocked out';
      model.lb(6)=0;
      model.ub(6)=0;
   end

   fprintf('\n\n\n>> New function - Toy example - minimal output.\n\n');
   [minFlux,maxFlux,optsol,ret]=fastFVA(model, optPercentage);

   fprintf('\n\n\n>> New function - Toy example - all output arguments.\n\n');
   [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT,statussolmin,statussolmax] = fastFVA(model,optPercentage);

   minFluxT
    maxFluxT
end

%% Validation of Toy Example
load('refData_fastFVA.mat');
assert(i == referenceToyResults.i);
assert(iExperiment == referenceToyResults.iExperiment);
assert(maxFlux == referenceToyResults.maxFlux);
assert(minFlux == referenceToyResults.minFlux);
assert(optPercentage == referenceToyResults.optPercentage);
assert(optsol == referenceToyResults.optsol);

fprintf('================================================================================\n\n')
fprintf('\n ---------------------------------           Example %d          ------------------------------- \n\n', example);

% Assimilate model variables to standard form
fname = fieldnames(data);
idx   = strmatch('model',fname);
if isempty(idx) fname = fname{1};
else fname = fname{idx(1)}; end
model = getfield(data,fname);

% Start a parpool environment in MATLAB
SetWorkerCount(nworkers);

%% Running Experiments

% Example 1 - full fastFVA, minimal number of output arguments
if example == 1

    fprintf('\n\n\n>> New function - Example 1.\n\n');
    [minFluxT,maxFluxT,optsolT,retT] = fastFVA(model,optPercentage,objective,solver);
    flag = true;

    if ispc && validation
        fprintf('\n\n\n>> Validated function - Example 1.\n\n');
        [minFluxTwin,maxFluxTwin,optsolTwin,retTwin] = fastFVAwin(model,optPercentage,objective,solver);
        flag = true;
    end

% Example 2 - full fastFVA, all output arguments
elseif example == 2
    fprintf('\n\n\n>> New function - Example 2.\n\n');
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT,statussolmin,statussolmax] = fastFVA(model,optPercentage,objective,solver);
    flag = true;

    if ispc && validation
        fprintf('\n\n\n>> Validated function - Example 2.\n\n');
        [minFluxTwin,maxFluxTwin,optsolTwin,retTwin,fbasolTwin,fvaminTwin,fvamaxTwin] = fastFVAwin(model,optPercentage,objective,solver);
        flag = true;
    end

% Example 3 - fastFVAex and customized set of CPLEX parameters
elseif example == 3

    % Choice of the reaction list (fastFVAex)
    rxnsList = model.rxns; %model.rxns(1:8);

    % Choice of the stoichiometric matrix
    matrixAS = 'S'; %'A'

    % Load CPLEX parameters
    cpxControl = CPLEXParamSetFVA;

    % Select the splitting strategy
    strategy = 0;

    fprintf('\n\n\n>> Example 3 - with 4 nargin, 2 nargout.\n');
    fprintf('================================================================================\n\n')
    [minFluxT,maxFluxT] = fastFVA(model,optPercentage,objective,solver);

    fprintf('\n\n\n>> Example 3 - with 5 nargin & 7 nargout.\n');
    fprintf('================================================================================\n\n')
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT] = fastFVA(model,optPercentage,objective,solver,rxnsList);

    fprintf('\n\n\n>> Example 3 - with 6 nargin & 7 nargout.\n');
    fprintf('================================================================================\n\n')
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT] = fastFVA(model,optPercentage,objective,solver, ...
        rxnsList,matrixAS);

    fprintf('\n\n\n>> Example 3 - with 7 nargin & 7 nargout.\n');
    fprintf('================================================================================\n\n')
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT] = fastFVA(model,optPercentage,objective,solver, ...
        rxnsList,matrixAS,cpxControl);

    fprintf('\n\n\n>> Example 3 - with 8 nargin & 7 nargout.\n');
    fprintf('================================================================================\n\n')
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT] = fastFVA(model,optPercentage,objective,solver, ...
        rxnsList,matrixAS,cpxControl);

    fprintf('\n\n\n>> Example 3 - with 5 nargin & 9 nargout.\n');
    fprintf('================================================================================\n\n')
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT,statussolmin,statussolmax] = fastFVA(model,optPercentage,objective,solver,rxnsList);

    fprintf('\n\n\n>> Example 3 - with 6 nargin & 9 nargout.\n');
    fprintf('================================================================================\n\n')
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT,statussolmin,statussolmax] = fastFVA(model,optPercentage,objective,solver, ...
            rxnsList,matrixAS);

    fprintf('\n\n\n>> Example 3 - with 7 nargin & 9 nargout.\n');
    fprintf('================================================================================\n\n')
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT,statussolmin,statussolmax] = fastFVA(model,optPercentage,objective,solver, ...
            rxnsList,matrixAS,cpxControl);

    fprintf('\n\n\n>> Example 3 - with 8 nargin & 9 nargout.\n');
    fprintf('================================================================================\n\n')
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT,statussolmin,statussolmax] = fastFVA(model,optPercentage,objective,solver, ...
            rxnsList,matrixAS,cpxControl);

    fprintf('\n\n\n>> Example 3 - with 9 nargin.\n');
    fprintf('================================================================================\n\n')
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT,statussolmin,statussolmax] = fastFVA(model,optPercentage,objective,solver, ...
                                                               rxnsList,matrixAS,cpxControl,strategy);

    rxnsList = model.rxns([1,3,6,9]); %model.rxns(1:8);
    fprintf('\n\n\n>> Example 3 - with 5 nargin (sorted rxnsList).\n');
    fprintf('================================================================================\n\n')
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT,statussolmin,statussolmax] = fastFVA(model,optPercentage,objective,solver,rxnsList);

    %Setting the optPercentage
    optPercentage = 90;

    rxnsList = model.rxns([1,20,30,19,5,4,3]); %model.rxns(1:8);
    fprintf('\n\n\n>> Running new function - Example 3 - with 5 nargin (UNsorted rxnsList & optPercentage = 90).\n');
    fprintf('================================================================================\n\n')
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT,statussolmin,statussolmax] = fastFVA(model,optPercentage,objective,solver,rxnsList);


    rxnsList = model.rxns([1,2,3,4,12,14]); %model.rxns(1:8);
    fprintf('\n\n\n>> Running new function - Example 3 - with 10 nargin (rxnsOptMode) (1).\n');
    fprintf('================================================================================\n\n')
    rxnsOptMode = [0,1,2,0,1,2];
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT,statussolmin,statussolmax] = fastFVA(model,optPercentage,objective,solver,rxnsList,[],[],[],rxnsOptMode);

    if(norm(statussolmin - [1,0,1,1,0,1]') < 1e-9 && norm(statussolmax - [0,1,1,0,1,1]') < 1e-9)
      fprintf(' >> Success - Example 3 - (1).\n');
    else
        error('Example 3 - (1) failed.')
    end

    rxnsList = model.rxns([8,9,15,27,38]); %model.rxns(1:8);
    fprintf('\n\n\n>> Running new function - Example 3 - with 10 nargin (rxnsOptMode) (2).\n');
    fprintf('================================================================================\n\n')
    rxnsOptMode = [2,1,2,0,0];
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT,statussolmin,statussolmax] = fastFVA(model,optPercentage,objective,solver,rxnsList,[],[],[],rxnsOptMode);

    if(norm(statussolmin - [1,0,1,1,1]') < 1e-9 && norm(statussolmax - [1,1,1,0,0]') < 1e-9)
      fprintf(' >> Success - Example 3 - (2).\n');
    else
        error('Example 3 - (2) failed.')
    end

    % for optimal solutions
    % rxnsOptMode = [0,0,0,0,0,0] -> statussolmin = [1,1,1,1,1,1]; statussolmax = [0,0,0,0,0,0];
    % rxnsOptMode = [1,1,1,1,1,1] -> statussolmin = [0,0,0,0,0,0]; statussolmax = [1,1,1,1,1,1];
    % rxnsOptMode = [2,2,2,2,2,2] -> statussolmin = [1,1,1,1,1,1]; statussolmax = [1,1,1,1,1,1];
    % rxnsOptMode = [0,1,2,0,1,2] -> statussolmin = [1,0,1,1,0,1]; statussolmax = [0,1,1,0,1,1];

    optPercentage=90;
    testKey = [4,5,7,8];%[1, 18, 20, 35];
    rxnsList = model.rxns(testKey);
    fprintf('\n\n\n>> Running new function - Example 3 - with 10 nargin (rxnsOptMode) (3).\n');
    fprintf('================================================================================\n\n')
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT,statussolmin,statussolmax] = fastFVA(model,optPercentage,objective,solver,rxnsList);
    [minFluxT1,maxFluxT1,optsolT1,retT1,fbasolT1,fvaminT1,fvamaxT1,statussolmin1,statussolmax1] = fastFVA(model,optPercentage,objective,solver,model.rxns);

    % Test Evaluation
    if(norm(minFluxT - minFluxT1(testKey)) < 1e-9 && norm(maxFluxT - maxFluxT1(testKey)) < 1e-9)
        fprintf(' >> Success - Example 3 - (3).\n');
    else
        minFluxT
        minFluxT1(testKey)
        maxFluxT
        maxFluxT1(testKey)
        error('Example 3 - (3) failed.')
    end

    testKey = [7:10];
    optPercentage=90;
    rxnsList = model.rxns(testKey); %model.rxns(1:8);
    fprintf('\n\n\n>> Running new function - Example 3 - with 10 nargin (rxnsOptMode) (4).\n');
    fprintf('================================================================================\n\n')
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT,statussolmin,statussolmax] = fastFVA(model,optPercentage,objective,solver,rxnsList);
    [minFluxT1,maxFluxT1,optsolT1,retT1,fbasolT1,fvaminT1,fvamaxT1,statussolmin1,statussolmax1] = fastFVA(model,optPercentage,objective,solver,model.rxns);

    % Test Evaluation
    if(norm(minFluxT - minFluxT1(testKey)) < 1e-9 && norm(maxFluxT - maxFluxT1(testKey)) < 1e-9)
        fprintf(' >> Success - Example 3 - (4).\n');
    else
        minFluxT
        minFluxT1(testKey)
        maxFluxT
        maxFluxT1(testKey)
        error('Example 3 - (4) failed.')
    end

    testKey = [1:20];
    optPercentage = 99; %try with a higher percentage (don't run with 100)
    rxnsList = model.rxns(testKey); %model.rxns(1:8);
    fprintf('\n\n\n>> Running new function - Example 3 - with 10 nargin (rxnsOptMode) (5).\n');
    fprintf('================================================================================\n\n')
    [minFluxT,maxFluxT,optsolT,retT]= fastFVA(model,optPercentage,objective,solver,rxnsList);
    [minFluxT1,maxFluxT1,optsolT1,retT1] = fastFVA(model,optPercentage,objective,solver,model.rxns);

    % Test Evaluation
    if(norm(minFluxT - minFluxT1(testKey)) < 1e-9 && norm(maxFluxT - maxFluxT1(testKey)) < 1e-9)
        fprintf(' >> Success - Example 3 - (5).\n');
    else
        minFluxT
        minFluxT1(testKey)
        maxFluxT
        maxFluxT1(testKey)
        error('Example 3 - (5) failed.')
    end

    optPercentage=90;
    testKey = [1:12];
    rxnsList = model.rxns(testKey);
    fprintf('\n\n\n>> Running new function - Example 3 - with 10 nargin (rxnsOptMode) (6).\n');
    fprintf('================================================================================\n\n')
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT,statussolmin,statussolmax] = fastFVA(model,optPercentage,objective,solver,rxnsList);
    [minFluxT1,maxFluxT1,optsolT1,retT1,fbasolT1,fvaminT1,fvamaxT1,statussolmin1,statussolmax1] = fastFVA(model,optPercentage,objective,solver,model.rxns);

    % Test Evaluation
    if(norm(minFluxT - minFluxT1(testKey)) < 1e-9 && norm(maxFluxT - maxFluxT1(testKey)) < 1e-9)
        fprintf(' >> Success - Example 3 - (6).\n');
    else
        minFluxT
        minFluxT1(testKey)
        maxFluxT
        maxFluxT1(testKey)
        error('Example 3 - (6) failed.')
    end

    optPercentage = 92;
    testKey = [13:18, 77, 78:80, 90, 92:95];
    rxnsList = model.rxns(testKey);
    fprintf('\n\n\n>> Running new function - Example 3 - with 10 nargin (rxnsOptMode) (7).\n');
    fprintf('================================================================================\n\n')
    [minFluxT,maxFluxT,optsolT,retT,fbasolT,fvaminT,fvamaxT,statussolmin,statussolmax] = fastFVA(model,optPercentage,objective,solver,rxnsList);
    [minFluxT1,maxFluxT1,optsolT1,retT1,fbasolT1,fvaminT1,fvamaxT1,statussolmin1,statussolmax1] = fastFVA(model,optPercentage,objective,solver,model.rxns);

    % Test Evaluation
    if(norm(minFluxT - minFluxT1(testKey)) < 1e-9 && norm(maxFluxT - maxFluxT1(testKey)) < 1e-9)
        fprintf(' >> Success - Example 3 - (7).\n');
    else
        minFluxT
        minFluxT1(testKey)
        maxFluxT
        maxFluxT1(testKey)
        error('Example 3 - (7) failed.')
    end

    flag = true;
end;

%% Validation module
if validation && ispc && example == 2
    flag = false;
    counter = 0;
    tol = 1e-9;

    if (norm(optsolT - optsolTwin) < tol) flag = true;  else flag = false; end;
    if (norm(minFluxT - minFluxTwin) < tol) flag = true;  else flag = false; end;
    if (norm(maxFluxT - maxFluxTwin) < tol) flag = true;  else flag = false; end;
    if (norm(retT - retTwin) < tol) flag = true;  else flag = false; end;

    if(norm(fbasolT - fbasolTwin) < tol)  flag = true;  else flag = false; end;

    for i=1:size(model.S,2)
        if(norm(fvaminT(:,i) - fvaminTwin(:,i)) > tol) counter = counter +1; end;
        if(norm(fvamaxT(:,i) - fvamaxTwin(:,i)) > tol) counter = counter +1; end;
    end

    if flag
      fprintf('\n --> Model validated. \n')
          if counter > 0
            fprintf('\n --> Note: Some solution vectors in fvamin and fvamax are different.\n')
          else
            fprintf('\n --> All solution vectors are the same.\n')
          end
    else
      error('\n --> Model not validated. \n')
    end
end

%% Conclusion
if flag
  fprintf('\n --> All tests passed. \n')
else
  fprintf('\n --> Some tests failed. \n')
end
