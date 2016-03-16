
% Perform the experiments described in the application note
% "Computationally efficient Flux Variability Analysis"
% Authors: S. Gudmundsson and I. Thiele.

% 20160315: Minor modifications for Linux support by L. Heirendt
% 20160316: Support for Matlab R2014a+

addpath(genpath('~/Dropbox/UNI.LU'))

%clear all
%clc
%close all

% FVA settings
optPercentage=90;
objective='max';

solver='cplexint'; % or 'glpk' %%cplexint

% Parallel settings
bParallel=true; %true;
nworkers=8;       % Number of parallel workers (quad core CPU + hyperthr.)

% Data sets
dataDir='';
modelList={ 'TM',      '1174671 TM_minimal_medium_glc.mat',      [] 
            'Pputida'  'Pputida_model_glc_min.mat',              []
            'E.Coli',  'ecoli_core_model.mat',                            []
            'Human',   'modelRecon1Biomass.mat',                 [3820] % Biomass_reaction
            'Ematrix' 'Thiele et al. - E-matrix_LB_medium.mat'   [] % Added RHS values b=0 to the model file
            'Ecoupled','EMatrix_LPProblemtRNACoupled90.mat'      []
           }; %

nmodels=size(modelList,1);
T=zeros(nmodels,1);
fprintf('Solver: %s\n', solver)

if bParallel
   fprintf('Multi-process version with %d workers\n', nworkers)
   SetWorkerCount(nworkers);
else
   fprintf('Sequential version\n')
   SetWorkerCount(0);
end

iModel = 4;

%for iModel=3:nmodels-3

   fprintf('\n >> Currently solving model %s\n\n',  modelList{iModel,1});

   % Read model data
   data=load([dataDir,'/',modelList{iModel,2}]);
   fname=fieldnames(data);
   idx=strmatch('model',fname);
   if isempty(idx)
      fname=fname{1};
   else
      fname=fname{idx(1)};
   end
   model=getfield(data,fname);

   % Modify objective if needed
   if ~isempty(modelList{iModel,3})
      model.c=0*model.c;
      model.c(modelList{iModel,3})=1;
   end

   tstart=tic;
   [minFlux,maxFlux,optsol,ret] = fastFVA(model,optPercentage,objective, solver);
   T(iModel) = toc(tstart);
   fprintf('%s\t%1.1f\n', modelList{iModel,1}, T(iModel))
%end
