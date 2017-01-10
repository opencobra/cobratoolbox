% DEMO for MSP group members
% Laurent Heirendt, June 13th, 2016

% Add path of the opensource cobratoolbox
addpath(genpath('~/Dropbox/UNI.LU/git/cobratoolbox'));
rmpath(genpath('~/Dropbox/UNI.LU/git/cobratoolbox/sparseOpt'));
addpath(genpath('~/Dropbox/UNI.LU/git/sbgCOBRA'));
addpath(genpath('../'));

% Select the solver; only GUROBI and TomLab/CPLEX are supported
solver = 'tomlab_cplex'; % gurobi6 // tomlab_cplex //

% Add path of the solver on the dwarfs
if strcmp(solver,'tomlab_cplex')
  addpath(genpath('/opt/tomlab'));
  changeCobraSolver('tomlab_cplex','all');
elseif strcmp(solver,'gurobi6')
  addpath(genpath('/opt/gurobi650/linux64'));
  changeCobraSolver('gurobi6','all');
end;

fprintf('Selected solver is %s\n\n', solver);

% Call the respective examples
%fprintf('\n -- Example 1 ------------------------------- \n\n', solver);
%relaxFBA_Ecoli
fprintf('\n -- Example 2 ------------------------------- \n\n', solver);
relaxFBA_ToyExample
