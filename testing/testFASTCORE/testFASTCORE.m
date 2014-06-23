function x =testfastcc_and_fastcore()
%testFastcore tests the functionality of fastcore.
%
%   Maria Pires Pacheco 06/20/2014

oriFolder = pwd;

test_folder = what('testFastcore');
cd(test_folder.path);

%epsilon
epsilon= 1e-4;
fprintf('\n*** testfastcore ***\n\n');
load('consistRecon1.mat', 'model'); % load model
load('C_liver.mat');%load the indexes of the core reactions 
A = fastcore( C, model, epsilon ) ; %run fastcore
model=removeRxns(model,model.rxns(setdiff(1:numel(model.rxns),A))); % create a tissue-specific model
B = fastcc( model, epsilon );% check the consistency of the output of fastcore with fastcc
if numel(A)== numel(B);% ckeck if the size of the model is decreasing after the consistency check
    disp('test passed');
    x=1;
else
    disp('test failed');
    x=0
end
cd(oriFolder);    
        


end