% The COBRAToolbox: testICONGEMs.m
%
% Purpose:
%     - Tests the ICONGEMs function 
%
%..Author: 
%    -Original file, Thummarat Paklao, Apichat Suratanee, and Kitiporn Plaimas. 

global CBTDIR

% set the tolerance
tol = 1e-4;
tol2 = 2e-1;

% define the solver required to run the test
useIfAvailable = {'gurobi'};

% test solver packages
solverPkgs = prepareTest('needsLP', true, 'needsQP', true, 'useSolversIfAvailable', useIfAvailable);

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testICONGEMs'));
cd(fileDir);

% load model
modelFileName = 'ecoli_core_model.mat';
model = getDistributedModel(modelFileName); 
[modelIrrev, matchRev, rev2irrev, irrev2rev] = convertToIrreversible(model);
Re = zeros(size(modelIrrev.rxns,1),size(modelIrrev.rxns,1));
for i = 1:length(model.rxns)
    if length(rev2irrev{i, 1}) == 2
        Re(i, rev2irrev{i,1}(2)) = 1;
    end
end

% load gene expression data
fileName = 'gene_exp.csv';
[exp, txt] = xlsread(fileName);

% set optional parameter
condition1=1:size(exp,2);
threashold = 0.8;
alpha = 0.99;

% test optimizeCbModel in cobratoolbox

sol_fba = optimizeCbModel(model);

for k = 1:length(solverPkgs.QP)
    fprintf(' -- Running testICONGEMs using the solver interface: %s ... ', solverPkgs.QP{k});

    solverQPOK = changeCobraSolver(solverPkgs.QP{k}, 'QP', 0);

    if solverQPOK
        [solICONGEMs, solEflux, R, boundEf] = ICONGEMs(model, exp, txt);
        for i = 1:size(exp,2)
            assert(norm(model.S * table2array(solICONGEMs.sol(:,i+1)) - model.b, 2) < tol);
            assert(abs(table2array(solICONGEMs.solRev(:,i+1))' * Re * table2array(solICONGEMs.solRev(:,i+1))) < tol)
            assert(abs(model.c' * table2array(solICONGEMs.sol(:,i+1)) - alpha * model.c' * table2array(solEflux.sol(:,i+1))) < tol)

        end

    end
    
    % output a success message
    fprintf('Done.\n');
end

% change the directory
cd(currentDir)