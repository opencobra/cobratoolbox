% The COBRAToolbox: testMoomin.m
%
% Purpose:
%     - Tests the moomin function
%
% Author:
%     - Original file: Taneli Pusa 01/2020

global CBTDIR

% initialize the test
currentDir = pwd;
fileDir = fileparts(which('testMoomin.m'));
cd(fileDir);
testPath = pwd;

% glpk appears to be extremely slow with stoichiometric constraints
% gurobi needs further testing to ensure it works
solvers = prepareTest('needsMILP', true, 'requiredSolvers', {'ibm_cplex'}, 'excludeSolvers',...
	 {'glpk', 'gurobi'});

% load model and data for the test
inputModel = getDistributedModel('ecoli_core_model.mat');
load([testPath filesep 'testData_moomin.mat']);

nMets = size(inputModel.mets, 1);
nRxns = size(inputModel.rxns, 1);

% tolerance
tol = 1e-6;

% run tests with different solvers
for i=1:length(solvers.MILP)
	fprintf(' -- Running testMoomin using the solver interface: %s ... ', solvers.MILP{i});
	
	solverOK = changeCobraSolver(solvers.MILP{i}, 'MILP', 0);
	
	if solverOK
		% test stoichiometric version
		[outputModel, MILPsolutions, MILPproblem] = moomin(inputModel, expression, ...
			'enumerate', 5);
	
		% check that reading GPRs works (solver independent, only needs to be done once)
		if i==1
			assert(any(outputModel.inputColours));
		end
	
		% there should be only one solution
		assert(size(MILPsolutions, 1) == 2 && MILPsolutions{2, 1}.stat == 0);
	
		% check the MILP
		A = MILPproblem.A;
		x = MILPsolutions{1,1}.full;
		% stoichiometric balance
		assert(all(abs(A(1:nMets, 1:nRxns) * x(1:nRxns)) < tol));
		% binary variables worked as intended
		assert(all((x(1:nRxns) > 0) == (x(nRxns + 1:2 * nRxns))));
		assert(all((x(1:nRxns) < 0) == (x(2 * nRxns + 1:end))));
	
		% test the topological version
		[outputModel, MILPsolutions, MILPproblem] = moomin(inputModel, expression, ...
			'enumerate', 5, 'stoichiometry', 0);

		% there should be only one solution
		assert(size(MILPsolutions, 1) == 2 && MILPsolutions{2, 1}.stat == 0);
	
		% check the MILP
		A = MILPproblem.A;
		b = MILPproblem.b;
		x = MILPsolutions{1,1}.full;
		assert(all(A(1:nRxns + nMets, :) * x <= b(1:nRxns + nMets)));
		assert(all(A(nRxns + nMets + 1:nRxns + 3 * nMets, :) * x >=...
			b(nRxns + nMets + 1:nRxns + 3 * nMets)));
	end
	fprintf('Done.\n');
end

% delete solver log files
delete('*.log');

cd(currentDir);