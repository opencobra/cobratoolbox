function [out,solution]=testDifferentLPSolvers(model,solvers,printLevel)
%tests the output from different LP solvers to see if they are consistent
%
%INPUT
% model     COBRA model to test
%
%OUTPUT
% out       1 = test sucessful, 0 = test unsucessful
%

% Ronan Fleming 18/11/2014 First version

if exist('model','var')
    if ~isempty(model)
        %model.A assumed to be matrix with coupling constraints
        if ~isfield(model,'A')
            model.A=model.S;
        end
        model.lb=double(full(model.lb));
        model.ub=double(full(model.ub));
        model.c=double(full(model.c));
        model.osense=-1;
        [m,n]=size(model.S);
        if isfield(model,'csense')
            model.csense=model.csense(:);
        else
            model.csense(1:m,1)='E';
        end
        solveDefaultModel=0;
    else
        solveDefaultModel=1;
    end
else
    solveDefaultModel=1;
end
if ~exist('printLevel','var')
    printLevel  = 1;
end

if solveDefaultModel
    %solve a default model
    if exist('121114_Recon2betaModel.mat','file')~=0
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
end
%print size of model
try
    [m,n]=size(model.S);
catch
    [m,n]=size(model.A);
end
if printLevel>0
    fprintf('%s\n',['Testing model with linear constraint matrix that has ' num2str(m) ' rows and ' num2str(n) ' columns...'])
end
%set the solver and solver parameters
global CBT_LP_SOLVER
oldSolver=CBT_LP_SOLVER;

if ~exist('solvers','var')
    solvers = {'opti'};
%     solvers={'gurobi6','mosek','ibm_cplex','cplex_direct','pdco','glpk','quadMinos','dqqMinos'};
    %solvers={'gurobi6','mosek_linprog','mosek','ibm_cplex','cplex_direct','pdco','glpk','quadMinos'};
end

i=1;
for j=1:length(solvers)
    %current solver
    solver=solvers{j};
    if strcmp(solver,'opti')
        if 1   
            % clp
            if exist('opts','var')
                clear opts
            end
            solverOK = changeCobraSolver(solver,'LP');
            opts.solver = 'clp';
            opts.tolrfun = 1e-9;
            opts.tolafun = 1e-9;
            opts.display = 'iter';
            opts.warnings = 'all';            
            solution{i} = solveCobraLP(model,opts);
            i = i+1;            
        end
        if 1   
            % clp:barrier
            if exist('opts','var')
                clear opts
            end
            solverOK = changeCobraSolver(solver,'LP');
            opts.solver = 'clp';
            opts.tolrfun = 1e-9;
            opts.tolafun = 1e-9;
            opts.display = 'iter';
            opts.warnings = 'all';            
            opts.algorithm = 'barrier';
            solution{i} = solveCobraLP(model,opts);
            i=i+1;            
        end
        % note that scip does not return the dual solution        
        if 1
            if exist('opts','var')
                clear opts
            end
            solverOK = changeCobraSolver(solver,'LP');
            opts.solver = 'scip';            
            solution{i} = solveCobraLP(model,'printLevel',3,...
                                       'optTol',1e-9,...
                                       opts);
            i = i+1;
        end
        if 1
            if exist('opts','var')
                clear opts
            end
            solverOK = changeCobraSolver(solver,'LP');
            opts.solver = 'auto';
            opts.algorithm = 'automatic';
            solution{i} = solveCobraLP(model,'printLevel',3,...
                                       'optTol',1e-9,...
                                       opts);
            i = i+1;
        end
        if 1
            if exist('opts','var')
                clear opts
            end
            solverOK = changeCobraSolver(solver,'LP');
            opts.solver = 'auto';            
            solution{i} = solveCobraLP(model,'printLevel',3,...
                                       'optTol',1e-9,...
                                       opts);
            i = i+1;
        end
    end
    if strcmp(solver,'dqqMinos')
        if 1
            solverOK = changeCobraSolver(solver,'LP');
            param.Method=1;
            solution{i} = solveCobraLP(model,param);
            i=i+1;
            clear param
        end
    end
    
    if strcmp(solver,'gurobi6')
        if 1
            solverOK = changeCobraSolver(solver,'LP');
            param.Method=1;
            solution{i} = solveCobraLP(model,param);
            i=i+1;
            clear param
        end
        
        if 0
            %by default, the check for stoichiometric consistency omits the columns
            %of S corresponding to exchange reactions
            solverOK = changeCobraSolver(solver,'LP');
            param.Method=2;
            solution{i} = solveCobraLP(model,param);
            i=i+1;
            clear param
        end
        
        if 0
            %by default, the check for stoichiometric consistency omits the columns
            %of S corresponding to exchange reactions
            solverOK = changeCobraSolver(solver,'LP');
            param.Method=3;
            solution{i} = solveCobraLP(model,param);
            i=i+1;
            clear param
        end
        
        if 0
            %by default, the check for stoichiometric consistency omits the columns
            %of S corresponding to exchange reactions
            solverOK = changeCobraSolver(solver,'LP');
            param.Method=4;
            solution{i} = solveCobraLP(model,param);
            i=i+1;
            clear param
        end
    end

    if strcmp(solver,'mosek_linprog')
        %by default, the check for stoichiometric consistency omits the columns
        %of S corresponding to exchange reactions
        solverOK = changeCobraSolver(solver,'LP');
        solution{i} = solveCobraLP(model);
        i=i+1;
        clear param
    end

    if strcmp(solver,'mosek')
        if 1
            %by default, the check for stoichiometric consistency omits the columns
            %of S corresponding to exchange reactions
            solverOK = changeCobraSolver(solver,'LP');
            param.MSK_IPAR_OPTIMIZER='MSK_OPTIMIZER_PRIMAL_SIMPLEX';
            solution{i} = solveCobraLP(model,param);
            i=i+1;
            clear param
        end
        
        if 1
            %by default, the check for stoichiometric consistency omits the columns
            %of S corresponding to exchange reactions
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
    end
    
    if strcmp(solver,'ibm_cplex')
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
            solverOK = changeCobraSolver(solver,'LP');
            param.lpmethod.Cur=0; %Automatic
            solution{i} = solveCobraLP(model,param);
            i=i+1;
            clear param
        end
        
        if 1
            solverOK = changeCobraSolver(solver,'LP');
            param.lpmethod.Cur=1; % Primal Simplex
            solution{i} = solveCobraLP(model,param);
            i=i+1;
        end
        
        if 1
            solverOK = changeCobraSolver(solver,'LP');
            param.lpmethod.Cur=2; % Dual Simplex
            solution{i} = solveCobraLP(model,param);
            i=i+1;
            clear param
        end
        
        if 0
            solverOK = changeCobraSolver(solver,'LP');
            param.lpmethod.Cur=3; % Network Simplex
            solution{i} = solveCobraLP(model,param);
            i=i+1;
            clear param
        end
        
        if 1
            solverOK = changeCobraSolver(solver,'LP');
            param.lpmethod.Cur=4; % Barrier
            solution{i} = solveCobraLP(model,param);
            i=i+1;
            clear param
        end
        
        if 1
            solverOK = changeCobraSolver(solver,'LP');
            param.lpmethod.Cur=5; % Sifting
            solution{i} = solveCobraLP(model,param);
            i=i+1;
            clear param
        end
        
        if 1
            solverOK = changeCobraSolver(solver,'LP');
            param.lpmethod.Cur=6; % Concurrent Dual, Barrier and Primal
            solution{i} = solveCobraLP(model,param);
            i=i+1;
            clear param
        end
    end
    
    
    if strcmp(solver,'cplex_direct')
        solverOK = changeCobraSolver(solver,'LP');
        solution{i} = solveCobraLP(model);
        i=i+1;
        clear param
    end
    
    if strcmp(solver,'pdco')
        solverOK = changeCobraSolver(solver,'LP');
        solution{i} = solveCobraLP(model);
        i=i+1;
        clear param
    end
    
    if strcmp(solver,'glpk')
        solverOK = changeCobraSolver(solver,'LP');
        solution{i} = solveCobraLP(model);
        i=i+1;
        clear param
    end
    
    if strcmp(solver,'quadMinos')
        solverOK = changeCobraSolver(solver,'LP');
        solution{i} = solveCobraLP(model);
        i=i+1;
        clear param
    end
end


%change back to the old solver
solverOK = changeCobraSolver(oldSolver,'LP');

%compare solutions
ilt=i-1;
if printLevel>0
    fprintf('%3s%15s%15s%15s%15s%20s\t%30s\n','   ','time','obj','y(rand)','w(rand)','solver','algorithm')
end



testIndex='rand';
switch testIndex
    case 'max'
        %pick a large entry in each dual vector, to check the signs
        randrcost=find(max(solution{1}.rcost)==solution{1}.rcost);
        randrcost=randrcost(1);
        randdual=find(max(solution{1}.dual)==solution{1}.dual);
        randdual=randdual(1);
    case 'min'
        %pick a small entry in each dual vector, to check the signs
        
        randrcost=find(min(solution{1}.rcost)==solution{1}.rcost);
        randrcost=randrcost(1);
        randdual=find(min(solution{1}.dual)==solution{1}.dual);
        randdual=randdual(1);
    case 'rand'
        %pick a random entry in each dual vector, to check the signs
        randrcost=ceil(rand*n);
        randdual=ceil(rand*m);
end

for i=1:ilt
    if 0
        disp(i)
        solution{i}
    end
    if solution{1}.stat==1
        if printLevel>0
            fprintf('%3d%15f%15f%15f%15f%20s\t%30s\n',i,solution{i}.time,solution{i}.obj,solution{i}.dual(randdual),solution{i}.rcost(randrcost),solution{i}.solver,solution{i}.algorithm)
        end
            all_obj(i)=solution{i}.obj;
    else
        fprintf('%3d%15f%15f%15f%15f%20s\t%30s\n',i,solution{i}.time,solution{i}.obj,NaN,NaN,solution{i}.solver,solution{i}.algorithm)  
        all_obj(i)=NaN;
    end
end

if abs(min(all_obj)-max(all_obj))<1e-8
    out=1;
else
    out=0;
end


