%% COBRA Tutorial using OPTI for LPs
% The test is performed using the same format as in testFBA.m  
% (by to Joseph Kang) check OPTI capabilities for COBRA
% Future solvers/tests will be added as they are completed
% cd to the directory within which this file has been placed
% Typically it would be ~/coobratoolbox/tutorials/opti
% Make sure the accompanying testFBAData.mat file is also present in the
% same location

% Make sure first OPTI is installed and on MATLAB path
% After downloading OPTI from 
% http://www.i2c2.aut.ac.nz/Wiki/OPTI/index.php
% make sure you follow the instructions in the opti_Install.m file in the
% main OPTI directory

% check what solvers are available for use from within OPTI
% this prints all available solvers
checkSolver;

% change cobra LP solver to opti
% this also displays all solvers that are available to choose from within
% opti
% if no solver is chosen during execution phase (see below) CLP is
% automatically chosen by opti as the default solver
changeCobraSolver('opti','LP');

load('testFBAData.mat');
fprintf('\n*** Test basic FBA calculations using OPTI***\n\n');

%tolerance
tol = 0.00000001;

fprintf('\n** Optimal minimum 1-norm solution **\n');
model = changeObjective(model,{'BiomassEcoli'},1);
% Since optimizaCbModel acts as a wrapper around solveCobraLP, any and all
% options that can/should be provided for opti should be done within
% optimizeCbModel
% Below several scenarios are shown for the purpose of this demo

%% solve FBA LP using default options for OPTI
% This option will solve the LP using an automatically chosen solver 
% (deafult - CLP) and corresponding algorithm
% this demo uses opti in its deafult mode
solution = optimizeCbModel(model);
f_values = solution.f;

%testing if f values are within range
x = 1;
for i =1:size(f_values)
    if(abs(solution.f-solutionStd.f)>tol)
        x=0;
    end
end
if(x==0)
    disp('Test failed for Optimal minimum 1-norm solution for f values');
else
    disp('Test succeeded for Optimal minimum 1-norm solution for f values');
end

%testing if c*x == f
y = 1;
for i =1:size(f_values)
    if abs(model.c'*solution.x - solution.f)>tol
        y=0;
    end
end
if(y==0)
    disp('Test failed for Optimal minimum 1-norm solution for c*x values');
else
    disp('Test succeeded for Optimal minimum 1-norm solution for c*x values');
end

%% solve FBA LP using user specified options for OPTI (Method A)
% In this case the call to optimizeCbModel remains the same while changes
% within optimizeCbModel that are required these changes are shown below
% Once changes to OptimizeCbModel are made, run the cell above to see the
% new results
% Note: that the structure fields are opti specific options and not
% generic Cobra options
% Note: Do not attempt to run the following lines directly as a script. It
% will result in an error. These lines are meant to go in optimizeCbModel
% before the call to solveCobraLP or outside of it with a proper LPproblem
% in COBRA format
opts.tolrfun = 1e-9;
opts.tolafun = 1e-9;
opts.display = 'iter';
opts.warnings = 'all';
opts.solver = 'clp';
opts.algorithm = 'barrier';
solution = solveCobraLP(LPproblem,opts);

%% solve FBA LP using user specified options for OPTI (Method B)
% In this case the call to optimizeCbModel remains the same while changes
% within optimizeCbModel are required these changes are shown below
% Once changes to OptimizeCbModel are made, run the cell above to see the
% new results
% This method adds 2 new parameters to the existing list of parameters for
% solveCobraLP - OPTIsolver and OPTIalgorithm

% The option OPTIalgorithm can only be set for CLP and SCIP solvers in OPTI
% While all LP capable solvers from opti are included, it is recommended
% to stick to clp and scip since other solvers serve other purposes and may
% not return optimal solutions for large LPs

% Possible choices for OPTIsolver
% 1. clp
% 2. scip
% 3. {auto}
% Not recommended solvers
% 4. csdp
% 5. dsdp
% 6. ooqp

% Possible algorithm options for CLP and SCIP
% set CLP and SCIP algorithm  - options        
% 1. automatic
% 2. barrier 
% 3. primalsimplex - primal simplex
% 4. dualsimplex - dual simplex
% 5. primalsimplexorsprint - primal simplex or sprint
% 6. barriernocross - barrier without simplex crossover

% Note: Do not attempt to run the following lines directly as a script. It
% will result in an error. These lines are meant to go in optimizeCbModel
% before the call to solveCobraLP
opts2.solver = 'scip';
solution = solveCobraLP(LPproblem,'printLevel',3,opts2);
                    
% users may also look at testDifferentLPSolvers.m for implementation options                    






