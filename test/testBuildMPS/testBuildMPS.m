function statusOK = testBuildMPS()
%Sets cobraLP and cobraMILP solver to MPS, generates test MPS files named 
%testMPSLP.mps and testMPSMILP.mps by calling solveCobraLP and 
%solveCobraMILP and resets cobraLP and cobraMILP solver to original 
%solver.

statusOK = 1;

%save current directory
origDir = pwd;

%change to testBuildMPS directory
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));

%Sample LP Problem
LPproblem.A = [1 1 0; -1 0 -1; 0 -1 1];             %LHS matrix
LPproblem.b = [5; -10; 7];                          %RHS vector
LPproblem.lb = [0; -1; 0];                          %Lower bound vector
LPproblem.ub = [4; 1; inf];                         %Upper bound vector
LPproblem.c = [1 4 9];                              %Objective coeff vector
LPproblem.csense = ['L'; 'L'; 'E'];                 %Constraint sense
LPproblem.osense = 1;                               %Minimize
VarNameFun = @(m) (char('x'+(m-1)));      %Function used to name variables
EqtNames = {'Equality'};

%save original solver
global CBT_LP_SOLVER;
global CBT_MILP_SOLVER;
origSolverLP = CBT_LP_SOLVER;
origSolverMILP = CBT_MILP_SOLVER;

%change LP and MILP solvers to MPS
changeCobraSolver('mps','LP');
changeCobraSolver('mps','MILP');

%Call solveCobraLP; Name output file 'testMPSLP' .mps suffix added
%automatically
paramStruct.MPSfilename='testMPSLP';
paramStruct.EqtNames=EqtNames;
paramStruct.VarNameFun=VarNameFun;

%call with parameter structure - Ronan
mpsFileLP = solveCobraLP(LPproblem,paramStruct);

%Verify mpsFile
load('mpsFileStd.mat');
if any(~strcmp(mpsFileLP,mpsFileLPStd))
    display('LP MPS matrix does not match');
    statusOK = 0;
end

%Verify File Exists
if ~exist('testMPSLP.mps','file')
    display('testMPSLP file not written');
    statusOK=0;
end

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

%Call solveCobraMILP; name output file 'testMPSMILP.mps'
%mpsFileMILP = solveCobraMILP(MILPproblem,'MPSfilename','testMPSMILP.mps','EqtNames',EqtNames,'VarNameFun',VarNameFun);
mpsFileMILP = solveCobraMILP(MILPproblem,paramStruct);

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

%cleanup;
delete('testMPSMILP.mps');
delete('testMPSLP.mps');

%switch solvers back to original
if ~isempty(origSolverLP)
    changeCobraSolver(origSolverLP,'LP');
end
if ~isempty(origSolverMILP)
    changeCobraSolver(origSolverMILP,'MILP');
end

%change to original directory
cd(origDir);