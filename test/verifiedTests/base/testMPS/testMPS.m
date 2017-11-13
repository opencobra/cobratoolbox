% The COBRAToolbox: testMPS.m
%
% Purpose:
%     - testMPS tests to write an MPS file and generates test MPS files named
%       testMPSLP.mps and testMPSMILP.mps by calling solveCobraLP and
%       solveCobraMILP and resets cobraLP and cobraMILP solver to original
%       solver.
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMPS'));
cd(fileDir);

% load the ecoli_core_model
model = getDistributedModel('ecoli_core_model.mat');


% write the MPS using method 1 (creates a file CobraLPProblem.mps)
out = writeLPProblem(model);

assert(out == 1);

% write the MPS using a different name
out = writeLPProblem(model, 'LP1');
assert(out == 1);

% run using a legacy interface (creates a file LP.mps)
solution = solveCobraLP(model, 'solver', 'mps');
assert(isempty(solution));

% run using writeCbModel
writeLPProblem(model, 'problemName','mps','fileName','LP2.mps','writeMatrix',0);

% read in all MPS files
LP_str = readMixedData('LP.mps');
CobraLPProblem_str = readMixedData('CobraLPProblem.mps');
LP1_str = readMixedData('LP1.mps');
LP2_str = readMixedData('LP2.mps');

% check if the length of each MPS file is the same
assert(length(LP_str) == length(CobraLPProblem_str))
assert(length(LP_str) == length(LP1_str))
assert(length(LP_str) == length(LP2_str))

% check if each row (apart from the first line - title) is the same
for k = 2:length(LP_str)  % title is different
    assert(isequal(LP_str{k}, CobraLPProblem_str{k}))
    assert(isequal(LP_str{k}, LP1_str{k}))
    assert(isequal(LP_str{k}, LP2_str{k}))
end

%Sample LP Problem
LPproblem.A = [1 1 0; -1 0 -1; 0 -1 1];             %LHS matrix
LPproblem.b = [5; -10; 7];                          %RHS vector
LPproblem.lb = [0; -1; 0];                          %Lower bound vector
LPproblem.ub = [4; 1; inf];                         %Upper bound vector
LPproblem.c = [1 4 9];                              %Objective coeff vector
LPproblem.csense = ['L'; 'L'; 'E'];                 %Constraint sense
LPproblem.osense = 1;                               %Minimize
%LPproblem.rxns = ['R1', 'R2', 'R3'];
%LPproblem.mets = ['a', 'b'];
VarNameFun = @(m) (char('x'+(m-1)));      %Function used to name variables
EqtNames = {'Equality'};

%Call solveCobraLP; Name output file 'testMPSLP' .mps suffix added %automatically
paramStruct.MPSfilename = 'testMPSLP';
paramStruct.EqtNames = EqtNames;
paramStruct.VarNameFun = VarNameFun;

%call with parameter structure - Ronan
solveCobraLP(LPproblem, 'solver', 'mps', paramStruct);

mpsFileLP = readMixedData([paramStruct.MPSfilename, '.mps']);

%Verify mpsFile
mpsFileLPStd = readMixedData('refData_testLP.txt');
assert(~any(~strcmp(strtrim(mpsFileLP), strtrim(mpsFileLPStd))));
clear paramStruct;

% run using solveCobraMILP

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
paramStruct.MPSfilename = 'testMPSMILP';
paramStruct.EqtNames = EqtNames;
paramStruct.VarNameFun = VarNameFun;

%Call solveCobraMILP; name output file 'testMPSMILP.mps'
%mpsFileMILP = solveCobraMILP(MILPproblem,'MPSfilename','testMPSMILP.mps','EqtNames',EqtNames,'VarNameFun',VarNameFun);
solveCobraMILP(MILPproblem, 'solver', 'mps', paramStruct); %

mpsFileMILP = readMixedData([paramStruct.MPSfilename, '.mps']);

%Verify mpsFile
mpsFileMILP_ref = readMixedData('refData_testMILP.txt');
assert(~any(~strcmp(strtrim(mpsFileMILP), strtrim(mpsFileMILP_ref))));

clear paramStruct;

% verify another model (this is still ecoli, iAF was never used as its name
% is iAF...
model = getDistributedModel('ecoli_core_model.mat');

paramStruct.EqtNames = model.mets;
paramStruct.VarNames = model.rxns;
paramStruct.MPSfilename = 'LP3';
solveCobraLP(model, 'solver', 'mps', paramStruct);
mpsFileLP3 = readMixedData('LP3.mps');

mpsFileLP_ref2 = readMixedData('refData_testLP_2.txt');
assert(~any(~strcmp(strtrim(mpsFileLP3), strtrim(mpsFileLP_ref2))));

clear paramStruct;

% cleanup
delete('CobraLPProblem.mps');
delete('LP.mps');
delete('LP1.mps');
delete('LP2.mps');
delete('testMPSMILP.mps');
delete('testMPSLP.mps');
delete('LP3.mps');

% change the directory
cd(currentDir)
