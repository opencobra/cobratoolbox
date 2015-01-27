function x =testfun_fastcc_and_fastcore()
% x =testfun_fastcc_and_fastcore()
% test function for fastcc and fastcore
%
% Maria Pires Pacheco, Thomas Sauter, 2015
% LSRU, University of Luxembourg

oriFolder = pwd;

test_folder = what('testFastcore');
cd(test_folder.path);
solverOK=changeCobraSolver('ibm_cplex');

% flux threshold
epsilon= 1e-4;

fprintf('\n*** testfastcore ***\n\n');
load('consistRecon1.mat', 'model'); % load model
load('C_liver.mat');%load the indexes of the core reactions
A = fastcore( C, model, epsilon,1 ) ; %run fastcore

model=removeRxns(model,model.rxns(setdiff(1:numel(model.rxns),A)));
B = fastcc( model, epsilon,1 );% double-check the consistency of the output of fastcore with fastcc

if numel(A)== numel(B);% ckeck if the size of the model is decreased after the consistency check
    disp('test passed');
    x=1;
else
    disp('test failed');
    x=0
end

cd(oriFolder);

end