%tests checkStoichiometricConsistency and minCardinalityConservationRelaxationVector
if ~exist('model','var')
    load 'Recon3DModel_301.mat'
end
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

%Check that the maximal conservation vector is nonzero for each the
%internal stoichiometric matrix
maxCardinalityConsParams.method = 'dc';
maxCardinalityConsParams.epsilon=1e-4;%1/epsilon is the largest mass considered, needed for numerical stability
maxCardinalityConsParams.theta = 0.5;
maxCardinalityConsParams.eta=getCobraSolverParams('LP', 'feasTol');
[maxConservationMetBool,maxConservationRxnBool,solution1]=maxCardinalityConservationVector(N, maxCardinalityConsParams);
assert(nnz(maxConservationMetBool)==length(maxConservationMetBool));
assert(nnz(maxConservationRxnBool)==length(maxConservationRxnBool));

maxCardinalityConsParams.method = 'quasiConcave';
maxCardinalityConsParams.epsilon=1e-4;%1/epsilon is the largest mass considered, needed for numerical stability
maxCardinalityConsParams.eta=getCobraSolverParams('LP', 'feasTol');
[maxConservationMetBool,maxConservationRxnBool,solution1]=maxCardinalityConservationVector(N, maxCardinalityConsParams);
assert(nnz(maxConservationMetBool)==length(maxConservationMetBool));
assert(nnz(maxConservationRxnBool)==length(maxConservationRxnBool));

maxCardinalityConsParams.method = 'optimizeCardinality';
maxCardinalityConsParams.epsilon=1e-4;%1/epsilon is the largest mass considered, needed for numerical stability
maxCardinalityConsParams.theta = 0.5;
maxCardinalityConsParams.eta=getCobraSolverParams('LP', 'feasTol');
[maxConservationMetBool,maxConservationRxnBool,solution1]=maxCardinalityConservationVector(N, maxCardinalityConsParams);
assert(nnz(maxConservationMetBool)==length(maxConservationMetBool));
assert(nnz(maxConservationRxnBool)==length(maxConservationRxnBool));

%Check that the maximal conservation vector is nonzero for each the internal stoichiometric matrix
[maxConservationMetBool,maxConservationRxnBool,solution2]=maxCardinalityConservationVector(N);
assert(nnz(maxConservationMetBool)==length(maxConservationMetBool));
assert(nnz(maxConservationRxnBool)==length(maxConservationRxnBool));

if nnz(maxConservationMetBool)==size(N,1) && nnz(maxConservationRxnBool)==nnz(model.SIntRxnBool)
    if printLevel>1
        fprintf('%6u\t%6u\t%s\n',nnz(maxConservationMetBool),nnz(maxConservationRxnBool),' All internally stoichiometrically consistent. (Check 3: maximim cardinality conservation vector.)');
    end
end

assert(isConsistent & nnz(maxConservationMetBool)==length(maxConservationMetBool));
