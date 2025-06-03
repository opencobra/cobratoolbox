% The COBRAToolbox: minCardinalityConservationRelaxationVector.m
%
% Purpose:
%     - tests the functionality of checkStoichiometricConsistency and minCardinalityConservationRelaxationVector
%
% Authors:
%     - Ronan Fleming 06/11/2025
%     - Farid Zare    03/03/2025 enhanced formatting
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMinCardinalityConservationRelaxationVector'));
cd(fileDir);

solvers = prepareTest('needsLP', true, 'excludeSolvers', {'ibm_cplex'});

for k = 1:length(solverPkgs.LP)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs.LP{k}, 'LP', 0);

    if solverOK

        fprintf('   Testing checkStoichiometricConsistency and minCardinalityConservationRelaxationVector using solver %s...\n', solverPkgs.LP{k})
        model = getDistributedModel('Recon3DModel_301.mat');

        printLevel=0;

        model = findSExRxnInd(model,[],printLevel-1);

        N = model.S(:,model.SIntRxnBool);

        %Recon3DModel_301 is stoichiometrically consistent, so check should be
        %positive
        [isConsistent, m, model] = checkStoichiometricConsistency(model, printLevel);
        assert(isConsistent==1)

        [mlt,nlt]=size(N');
        feasTol = getCobraSolverParams('LP', 'feasTol');
        param.eta=feasTol*100;
        param.checkConsistency=0;
        param.epsilon=1e-4;
        param.nonRelaxBool=false(mlt,1);
        param.checkFeasibility = 0;
        param.printLevel=printLevel;

        %Recon3DModel_301 is stoichiometrically consistent, so no relaxations
        %should be needed
        [relaxRxnBool, solutionRelax] = minCardinalityConservationRelaxationVector(N,param);
        assert(nnz(relaxRxnBool)==0);


        [relaxRxnBool, solutionRelax] = minCardinalityConservationRelaxationVector(N);
        assert(nnz(relaxRxnBool)==0);

        if solutionRelax.stat==1
            %conserved if relaxation is below epsilon
            relaxRxnBool=abs(solutionRelax.x)>=param.eta;
            if printLevel>1
                fprintf('%g%s\n',norm(N(:,~relaxRxnBool)'*solutionRelax.z),' = ||N''*z|| (should be zero)')
            end
            if printLevel>1
                fprintf('%s\n',[int2str(nnz(relaxRxnBool)) '/' int2str(length(relaxRxnBool)) ' reactions relaxed.'])
            end
        else
            disp(solutionRelax)
            error('solve for minimum cardinality of conservation relaxation vector failed')
        end

        assert(isConsistent & nnz(relaxRxnBool)==0);

        % output a success message
        fprintf('Done.\n');

    end
end
% change the directory
cd(currentDir)
