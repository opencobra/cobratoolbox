% The COBRAToolbox: testMPS.m
%
% Purpose:
%     - testMPS tests to write an MPS file
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMPS'));
cd(fileDir);

% load the ecoli_core_model
load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');

% write the MPS using method 1 (creates a file CobraLPProblem.mps)
out = convertCobraLP2mps(model);

assert(out == 1);

% write the MPS using a different name
out = convertCobraLP2mps(model, 'LP1');
assert(out == 1);

% run using a legacy interface (creates a file LP.mps)
solution = solveCobraLP(model, 'solver', 'mps');
assert(isempty(solution));

% run using writeCbModel
writeCbModel(model, 'mps', 'LP2.mps', [], [], [], [], []);

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

% run using solveCobraMILP


% compare the 4 files: CobraLPProblem.mps, LP1.mps, LP.mps and LP2.mps

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

% cleanup
delete('CobraLPProblem.mps');
delete('LP.mps');
delete('LP1.mps');
delete('LP2.mps');
delete('testMPSLP.mps');
