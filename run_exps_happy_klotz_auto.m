
% Perform the experiments described in the application note
% "Computationally efficient Flux Variability Analysis"
% Authors: S. Gudmundsson and I. Thiele.

% 20160315: Minor modifications for Linux support by L. Heirendt
% 20160316: Support for Matlab R2014a+


addpath(genpath('~/Dropbox/UNI.LU/models'))
addpath(genpath('~/Dropbox/UNI.LU/git'))

clear all
clc
format long

% FVA settings
optPercentage=90;
objective='max';

paramstring = 'CPX_PARAM_REDUCE_0';
matrixASvect = ['A'];


solver='cplexint'; % or 'glpk' %%cplexint

% Parallel settings
bParallel= true; %false; true
nworkers= 8;       % Number of parallel workers (quad core CPU + hyperthr.)

nworkersvect = [8; 16; 32];



autonames = {};
autotimes = [];

datasets

nmodels=size(modelList,1);
T=zeros(nmodels,1);
fprintf('Solver: %s\n', solver)


fprintf('\n >> The following models will be solved:\n\n');
for iModel=6:6

   fprintf('- %s\n\n',  modelList{iModel,1});
end


for k = 1:length(nworkersvect)

nworkers = nworkersvect(k);


if bParallel
   fprintf('Multi-process version with %d workers\n', nworkers);
else
   fprintf('Sequential version\n');
   nworkers = 0;
end;

SetWorkerCount(nworkers);

%iModel = 6;

for iModel=6:6

   for j = 1:length(matrixASvect)

   matrixAS = matrixASvect(j);

   fprintf('\n >> Currently solving model %s\n\n',  modelList{iModel,1});
   fprintf('\n >> Currently solving matrix %s\n\n', matrixAS);
   fprintf('\n >> Currently solving with %d workers\n\n', nworkers);

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

   model=getfield(data,fname);

   %chop b to the correct length
   model.b = model.b(1:size(model.A,1));
   model.csense = model.csense(1:size(model.A,1));

   % Modify objective if needed
   if ~isempty(modelList{iModel,3})
      model.c=0*model.c;
      model.c(modelList{iModel,3})=1;
   end

   tstart=tic;
   [minFlux,maxFlux,optsol,ret] = fastFVA(model,optPercentage,objective, solver,matrixAS);
   T(iModel) = toc(tstart);
   fprintf('>> nworkers = %d, \t model = %s\t%1.1f\n', nworkers, modelList{iModel,1}, T(iModel))

   filename = strcat(modelList{iModel,1},'_',matrixAS,'_',num2str(nworkers),'_',paramstring,'.mat');

   autonames{end+1} = {filename};
   autotimes(end+1) = T(iModel);

%save the corresponding solution files
   save(filename)

   end
   end



end


celldisp(autonames)
autotimes

%matlab -nodesktop -r run_exps_happy_klotz_auto -logfile run_exps_happy_auto.log

%matlab -r run_exps_happy -logfile run_exps_happy_log.txt
%filename = strcat('exp_',num2str(nworkers),'_',modelList{iModel,1} ,'_',solver,'.mat');

%save  run_exps_happy_db.mat
