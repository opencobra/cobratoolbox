% The COBRAToolbox: testStoichiometricConsistency.m
%
% Purpose:
%     - tests the checkStoichiometricConsistency function
%
% Authors:
%     - Ronan Fleming 03/12/2014
%     - Farid Zare    03/06/2024 enhanced formatting
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testStoichiometricConsistency'));
cd(fileDir);

[solversToUse] = prepareTest('requireOneSolverOf',{'gurobi'});

printLevel=1;
solverOK = changeCobraSolver('gurobi','LP');
modelToLoad='Recon3DModel_301';
%modelToLoad='ecoli_core_model';

switch modelToLoad
    case 'ecoli_core_model'
        load('ecoli_core_model')
    case 'Recon3DModel_301'
        load('Recon3DModel_301.mat')
        
    case 'Recon3D'
        load('Recon3D_301.mat')
        model = Recon3D;
    case 'Recon2betaModel'
        %graphStoich/data/modelCollection/121114_Recon2betaModel.mat
        load 121114_Recon2betaModel.mat
        model=modelRecon2beta121114;
    case 'KEGGMatrix'
        load ~/work/modeling/projects/graphStoich/data/modelCollectionBig/KEGGMatrix.mat
        model=KEGG;
end

if 1
    %[SConsistentMetBool, SConsistentRxnBool, SInConsistentMetBool, SInConsistentRxnBool, unknownSConsistencyMetBool, unknownSConsistencyRxnBool, model, stoichConsistModel] = findStoichConsistentSubset(model, massBalanceCheck, printLevel, fileName, epsilon)
    [SConsistentMetBool, SConsistentRxnBool, SInConsistentMetBool, SInConsistentRxnBool, unknownSConsistencyMetBool, unknownSConsistencyRxnBool, model, stoichConsistModel] = findStoichConsistentSubset(model,0,1);
    if strcmp(modelToLoad,'Recon3DModel_301')
        % load('Recon3DModel_301.mat') should be fully stoichiometrically
        % consistent
        assert(nnz(SConsistentMetBool)==5835)
        assert(nnz(SConsistentRxnBool)==8791)
        assert(nnz(SInConsistentMetBool)==0)
        assert(nnz(SInConsistentRxnBool)==1809)
        assert(nnz(unknownSConsistencyMetBool)==0)
        assert(nnz(unknownSConsistencyRxnBool)==0)
    end
else
    
    %finds the exchange reactions
    model=findSExRxnInd(model);
    
    [nMet,nIntRxn]=size(model.S(:,model.SIntRxnBool));
    m=sparse(nMet,15);
    i=1;
    
    if 1
        if 1
            %by default, the check for stoichiometric consistency omits the columns
            %of S corresponding to exchange reactions
            clear method
            method.interface='solveCobraLP';
            method.solver='gurobi5';
            method.param.Method=1;
            [inform(i),m(:,i),models{i}]=checkStoichiometricConsistency(model,printLevel,method);
            i=i+1;
        end
        
        if 1
            %by default, the check for stoichiometric consistency omits the columns
            %of S corresponding to exchange reactions
            clear method
            method.interface='solveCobraLP';
            method.solver='gurobi5';
            method.param.Method=2;
            [inform(i),m(:,i),models{i}]=checkStoichiometricConsistency(model,printLevel,method);
            i=i+1;
        end
        
        if 1
            %by default, the check for stoichiometric consistency omits the columns
            %of S corresponding to exchange reactions
            clear method
            method.interface='solveCobraLP';
            method.solver='gurobi5';
            method.param.Method=3;
            [inform(i),m(:,i),models{i}]=checkStoichiometricConsistency(model,printLevel,method);
            i=i+1;
        end
        
        if 1
            %by default, the check for stoichiometric consistency omits the columns
            %of S corresponding to exchange reactions
            clear method
            method.interface='solveCobraLP';
            method.solver='gurobi5';
            method.param.Method=4;
            [inform(i),m(:,i),models{i}]=checkStoichiometricConsistency(model,printLevel,method);
            i=i+1;
        end
        
        if 0
            %by default, the check for stoichiometric consistency omits the columns
            %of S corresponding to exchange reactions
            clear method
            method.interface='solveCobraLP';
            method.solver='mosek_linprog';
            [inform(i),m(:,i),models{i}]=checkStoichiometricConsistency(model,printLevel,method);
            i=i+1;
        end
        
        if 0
            %by default, the check for stoichiometric consistency omits the columns
            %of S corresponding to exchange reactions
            clear method
            method.interface='solveCobraLP';
            method.solver='mosek';
            method.param.MSK_IPAR_OPTIMIZER='MSK_OPTIMIZER_PRIMAL_SIMPLEX';
            [inform(i),m(:,i),models{i}]=checkStoichiometricConsistency(model,printLevel,method);
            i=i+1;
        end
        
        if 0
            %by default, the check for stoichiometric consistency omits the columns
            %of S corresponding to exchange reactions
            clear method
            method.interface='solveCobraLP';
            method.solver='mosek';
            method.param.MSK_IPAR_OPTIMIZER='MSK_OPTIMIZER_DUAL_SIMPLEX';
            [inform(i),m(:,i),models{i}]=checkStoichiometricConsistency(model,printLevel,method);
            i=i+1;
        end
        
        if 0 %still debugging this solve with Erling @ Mosek
            %by default, the check for stoichiometric consistency omits the columns
            %of S corresponding to exchange reactions
            clear method
            method.interface='solveCobraLP';
            method.solver='mosek';
            method.param.MSK_IPAR_OPTIMIZER='MSK_OPTIMIZER_INTPNT';
            printLevelZ=3;
            [inform(i),m(:,i),models{i}]=checkStoichiometricConsistency(model,printLevelZ,method);
            i=i+1;
        end
    end
    
    if 1
        clear method
        method.interface='solveCobraLP';
        method.solver='ibm_cplex';
        [inform(i),m(:,i),models{i}]=checkStoichiometricConsistency(model,printLevel+1,method);
        i=i+1;
    end
    
    if 0
        clear method
        method.interface='solveCobraLP';
        method.solver='pdco';
        [inform(i),m(:,i),models{i}]=checkStoichiometricConsistency(model,printLevel+1,method);
        i=i+1;
    end
    
    if 0
        clear method
        method.interface='cvx';
        method.solver='gurobi';
        [inform(i),m(:,i),models{i}]=checkStoichiometricConsistency(model,printLevel,method);
        i=i+1;
    end
    
    if 0
        clear method
        method.interface='cvx';
        method.solver='mosek';
        [inform(i),m(:,i),models{i}]=checkStoichiometricConsistency(model,printLevel,method);
        i=i+1;
    end
    
    m=full(m);
    
end

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)

       