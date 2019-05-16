
% Perform the experiments described in the application note
% "Computationally efficient Flux Variability Analysis"
% Authors: S. Gudmundsson and I. Thiele.

% FVA settings
optPercentage=90;
objective='max';

solver='glpk'; % or 'cplexint'

% Parallel settings
bParallel=false;
nworkers=8;       % Number of parallel workers (quad core CPU + hyperthr.)

% Data sets
dataDir='../data';
modelList={ 'TM',      '1174671 TM_minimal_medium_glc.mat'
            'Pputida'  'Pputida_model_glc_min.mat'
            'E.Coli',  'iAF1260.mat'
            'Human',   'modelRecon1Biomass.mat'
           % 'Ematrix' 'Thiele et al. - E-matrix_LB_medium.mat'
           % 'Ecoupled','Ematrix_LPProblemtRNACoupled90.mat'
           };

nmodels=size(modelList,1);
T=zeros(nmodels,1);
fprintf('Solver: %s\n', solver)

if bParallel
   fprintf('Multi-process version\n')
   SetWorkerCount(nworkers);
else
   fprintf('Sequential version\n')
   if GetWorkerCount() > 0
      SetWorkerCount(0);
   end
end

for iModel=1:nmodels
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

   tstart=tic;
   [minFlux,maxFlux,optsol,ret] = fastFVA(model,optPercentage,objective, solver);
   T(iModel) = toc(tstart);
   fprintf('%s\t%1.1f\n', modelList{iModel,1}, T(iModel))
end
