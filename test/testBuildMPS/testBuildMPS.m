


%Removed the test because the error on some systems is not an error 1e-05 = 1e-005 as
%a number but not as a string.
%test on iJR904 model
%load('modelMPS.mat')

%Call solver
%testModelMPS = solveCobraLP(model,'EqtNames',model.mets,'VarNames',model.rxns);

%Verify mpsFile
%if any(~strcmp(testModelMPS,modelMPS))
%    display('iJR904 MPS matrix does not match');
%    statusOK = 0;
%end
