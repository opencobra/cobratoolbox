%Sets cobraLP and cobraMILP solver to MPS, generates test MPS files named
%testMPSLP.mps and testMPSMILP.mps by calling solveCobraLP and
%solveCobraMILP and resets cobraLP and cobraMILP solver to original
%solver.

%Sample MILP Problem
MILPproblem.A = [1 1 0; -1 0 -1; 0 -1 1];           %LHS matrix
MILPproblem.b = [5; -10; 7];                        %RHS vector
MILPproblem.lb = [0; -1; 0];                        %Lower bound vector
MILPproblem.ub = [4; 1; inf];                       %Upper bound vector
MILPproblem.c = [1 4 9];                            %Objective coeff vector
MILPproblem.x0 = [];
MILPproblem.csense = ['L'; 'L'; 'E'];               %Constraint sense
MILPproblem.vartype = ['I'; 'C'; 'C'];              %Variable type
MILPproblem.osense = 1;                             %Minimize

%parameters
VarNameFun = @(m) (char('x'+(m-1)));    %Function used to name variables
EqtNames = {'Equality'};
paramStruct.MPSfilename='testMPSMILP';
paramStruct.EqtNames=EqtNames;
paramStruct.VarNameFun=VarNameFun;

global CBT_MILP_SOLVER
CBT_MILP_SOLVER = 'mps'

%Call solveCobraMILP; name output file 'testMPSMILP.mps'
%mpsFileMILP = solveCobraMILP(MILPproblem,'MPSfilename','testMPSMILP.mps','EqtNames',EqtNames,'VarNameFun',VarNameFun);
mpsFileMILP = solveCobraMILP(MILPproblem, paramStruct);

%Verify mpsFile
if any(~strcmp(mpsFileMILP,mpsFileMILPStd))
    display('MILP MPS matrix does not match');
    statusOK = 0;
end

%Verify File Exists
if ~exist('testMPSMILP.mps','file')
    display('testMPSMILP.mps file not written');
    statusOK=0;
end

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
