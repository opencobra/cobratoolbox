function out=test()
%tests the output from different LP solvers to see if they are consistent
clear

if exist('121114_Recon2betaModel.mat','file')
    load 121114_Recon2betaModel.mat
    model=modelRecon2beta121114;
    model.A=model.S;
    model.osense=-1;
    model.csense(1:size(model.S,1),1)='E';
else
    model.c = [200; 400];
    model.A = [1/40, 1/60; 1/50, 1/50];
    model.b = [1; 1];
    model.lb = [0; 0];
    model.ub = [1; 1];
    model.osense = -1;
    model.csense = ['L'; 'L'];
end

%set the solver and solver parameters
global CBTLPSOLVER
oldSolver=CBTLPSOLVER;


i=1;
if 1
    solver='gurobi5';
    solverOK = changeCobraSolver(solver,'LP');
    param.Method=1;
    solution{i} = solveCobraLP(model,param);
    i=i+1;
    clear param
end

if 1
    %by default, the check for stoichiometric consistency omits the columns
    %of S corresponding to exchange reactions
    solver='gurobi5';
    solverOK = changeCobraSolver(solver,'LP');
    param.Method=2;
    solution{i} = solveCobraLP(model,param);
    i=i+1;
    clear param
end

if 1
    %by default, the check for stoichiometric consistency omits the columns
    %of S corresponding to exchange reactions
    solver='gurobi5';
    solverOK = changeCobraSolver(solver,'LP');
    param.Method=3;
    solution{i} = solveCobraLP(model,param);
    i=i+1;
    clear param
end

if 1
    %by default, the check for stoichiometric consistency omits the columns
    %of S corresponding to exchange reactions
    solver='gurobi5';
    solverOK = changeCobraSolver(solver,'LP');
    param.Method=4;
    solution{i} = solveCobraLP(model,param);
    i=i+1;
    clear param
end

if 1
    %by default, the check for stoichiometric consistency omits the columns
    %of S corresponding to exchange reactions
    solver='mosek_linprog';
    solverOK = changeCobraSolver(solver,'LP');
    solution{i} = solveCobraLP(model);
    i=i+1;
    clear param
end

if 1
    %by default, the check for stoichiometric consistency omits the columns
    %of S corresponding to exchange reactions
    solver='mosek';
    solverOK = changeCobraSolver(solver,'LP');
    param.MSK_IPAR_OPTIMIZER='MSK_OPTIMIZER_PRIMAL_SIMPLEX';
    solution{i} = solveCobraLP(model,param);
    i=i+1;
    clear param
end

if 1
    %by default, the check for stoichiometric consistency omits the columns
    %of S corresponding to exchange reactions
    solver='mosek';
    solverOK = changeCobraSolver(solver,'LP');
    param.MSK_IPAR_OPTIMIZER='MSK_OPTIMIZER_DUAL_SIMPLEX';
    solution{i} = solveCobraLP(model,param);
    i=i+1;
    clear param
end

if 0 %still debugging this solve with Erling @ Mosek
    %by default, the check for stoichiometric consistency omits the columns
    %of S corresponding to exchange reactions
    solver='mosek';
    solverOK = changeCobraSolver(solver,'LP');
    param.MSK_IPAR_OPTIMIZER='MSK_OPTIMIZER_INTPNT';
    solution{i} = solveCobraLP(model,param);
    i=i+1;
    clear param
end

if 1
    % ILOGcplex.param.lpmethod.Cur
    % Determines which algorithm is used. Currently, the behavior of the Automatic setting is that CPLEX almost
    % always invokes the dual simplex method. The one exception is when solving the relaxation of an MILP model
    % when multiple threads have been requested. In this case, the Automatic setting will use the concurrent optimization
    % method. The Automatic setting may be expanded in the future so that CPLEX chooses the method
    % based on additional problem characteristics.
    %  0 Automatic
    % 1 Primal Simplex
    % 2 Dual Simplex
    % 3 Network Simplex (Does not work for almost all stoichiometric matrices)
    % 4 Barrier (Interior point method)
    % 5 Sifting
    % 6 Concurrent Dual, Barrier and Primal
    % Default: 0
    solver='ibm_cplex';
    solverOK = changeCobraSolver(solver,'LP');
    param.lpmethod.Cur=0; %Automatic
    solution{i} = solveCobraLP(model,param);
    i=i+1;
    clear param
end

if 1
    solver='ibm_cplex';
    solverOK = changeCobraSolver(solver,'LP');
    param.lpmethod.Cur=1; % Primal Simplex
    solution{i} = solveCobraLP(model,param);
    i=i+1;
end

if 1
    solver='ibm_cplex';
    solverOK = changeCobraSolver(solver,'LP');
    param.lpmethod.Cur=2; % Dual Simplex
    solution{i} = solveCobraLP(model,param);
    i=i+1;
    clear param
end

if 0
    solver='ibm_cplex';
    solverOK = changeCobraSolver(solver,'LP');
    param.lpmethod.Cur=3; % Network Simplex
    solution{i} = solveCobraLP(model,param);
    i=i+1;
    clear param
end

if 1
    solver='ibm_cplex';
    solverOK = changeCobraSolver(solver,'LP');
    param.lpmethod.Cur=4; % Barrier
    solution{i} = solveCobraLP(model,param);
    i=i+1;
    clear param
end

if 1
    solver='ibm_cplex';
    solverOK = changeCobraSolver(solver,'LP');
    param.lpmethod.Cur=5; % Sifting
    solution{i} = solveCobraLP(model,param);
    i=i+1;
    clear param
end

if 1
    solver='ibm_cplex';
    solverOK = changeCobraSolver(solver,'LP');
    param.lpmethod.Cur=6; % Concurrent Dual, Barrier and Primal
    solution{i} = solveCobraLP(model,param);
    i=i+1;
    clear param
end


if 1
    solver='cplex_direct';
    solverOK = changeCobraSolver(solver,'LP');
    solution{i} = solveCobraLP(model);
    i=i+1;
    clear param
end

if 0
    solver='pdco';
    solverOK = changeCobraSolver(solver,'LP');
    solution{i} = solveCobraLP(model);
    i=i+1;
    clear param
end

if 1
    solver='glpk';
    solverOK = changeCobraSolver(solver,'LP');
    solution{i} = solveCobraLP(model);
    i=i+1;
    clear param
end

%change back to the old solver
solverOK = changeCobraSolver(oldSolver,'LP');

%compare solutions
ilt=i-1;
fprintf('%3s%15s%15s%15s%15s%20s\t%30s\n','   ','time','obj','y(rand)','w(rand)','solver','algorithm')

%pick a large entry in each dual vector, to check the signs
if 1
    randrcost=find(max(solution{1}.rcost)==solution{1}.rcost);
    randrcost=randrcost(1);
    randdual=find(max(solution{1}.dual)==solution{1}.dual);
    randdual=randdual(1);
else
    randrcost=find(min(solution{1}.rcost)==solution{1}.rcost);
    randrcost=randrcost(1);
    randdual=find(min(solution{1}.dual)==solution{1}.dual);
    randdual=randdual(1);
end

for i=1:ilt
    if 0
    disp(i)
    solution{i}
    end
    fprintf('%3d%15f%15f%15f%15f%20s\t%30s\n',i,solution{i}.time,solution{i}.obj,solution{i}.dual(randdual),solution{i}.rcost(randrcost),solution{i}.solver,solution{i}.algorithm)
    all_obj(i)=solution{i}.obj;    
end

if abs(min(all_obj)-max(all_obj))<1e-8
    out=1;
else
    out=0;
end


