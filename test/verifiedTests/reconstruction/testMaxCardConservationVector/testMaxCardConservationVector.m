%clear
fprintf('%s\n','testing maxCardConservationVector.m')

[solversToUse] = prepareTest('requireOneSolverOf',{'tomlab_cplex','ibm_cplex','gurobi'});

if 0
    param.printLevel=2;
    solverOK = changeCobraSolver('ibm_cplex','LP',0);
else
    param.printLevel=0;
end

modelToLoad='Recon3D';
if exist('Recon3D_301.mat','file')==2

switch modelToLoad
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

% nbMaxIteration - Stopping criteria - maximal number of iteration (Default value 1000)
param.nbMaxIteration = 1000;
% eta - Smallest value considered non-zero (Default value feasTol*1000)
feasTol = getCobraSolverParams('LP', 'feasTol');
param.eta = feasTol*1000;%changed to 1000
% epsilon - `1/epsilon` is the largest molecular mass considered (Default value 1e-4)
param.epsilon = 1e-4;
% zeta - Stopping criteria - threshold (Default value 1e-6)

% theta - Parameter of capped `l1` approximation (Default value 0.5)
param.zeta = 1e-6;

%parameter of capped l1 approximation
param.theta   = 40;   

    
%methods = {'optimizeCardinality','quasiConcave', 'dc', 'dc_old'};
%methods = {'optimizeCardinality','quasiConcave'};
%methods = {'optimizeCardinality'};

if 0
    methods = {'optimizeCardinality','dc', 'quasiConcave'};
    maxConservationBoolAns = [551,9;551,9;509,9];
    %TODO quasiConcave giving 509,9 or 510,9 depending on solver
else
    
    methods = {'optimizeCardinality','dc'};
    maxConservationBoolAns = [551,9;551,9];
end


maxConservationMetBool=false(size(model.S,1),length(methods));
maxConservationRxnBool=false(size(model.S,2),length(methods));
for i=1:length(methods)
    param.method = methods{i};
    
    %
    fprintf('%s%s%s\n','Testing maxCardinalityConservationVector with method: ', methods{i}, '...')
    [maxConservationMetBool(:,i), maxConservationRxnBool(:,i), solution] = maxCardinalityConservationVector(model.S, param);
    fprintf('%6u\t%6u\t%s%s%s\n\n',nnz(maxConservationMetBool(:,i)),nnz(maxConservationRxnBool(:,i)),' stoichiometrically consistent by max cardinality of conservation vector. (', param.method ,' method)')
    assert(nnz(maxConservationMetBool(:,i))==maxConservationBoolAns(i,1))
    assert(nnz(maxConservationRxnBool(:,i))==maxConservationBoolAns(i,2))
    % OUTPUTS:
    %    maxConservationMetBool:    `m` x 1 boolean for consistent metabolites
    %    maxConservationRxnBool:    `n` x 1 boolean for reactions exclusively involving consistent metabolites
    %    solution:                  Structure containing the following fields:
    %
    %                                 * l - `m` x 1 molecular mass vector
    %                                 * stat - status:
    %
    %                                   * 1 =  Solution found
    %                                   * 2 =  Unbounded
    %                                   * 0 =  Infeasible
    %                                   * -1=  Invalid input
end
fprintf('%s\n','Done.')
else
   fprintf('%s\n','Skipped testing of maxCardConservationVector.m as could not find Recon3D_301.mat')
end