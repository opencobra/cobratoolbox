function X = relateConservedMoietiesToConservationRelations(C,R)
% Given a stoichiometric matrix N, a set of conserved moieties C, and a set of 
% conservation relations R, such that C*N = 0 and R*N = 0, then compute a matrix X,
% such that C = X*R, and R'*x = C(j,:)' with x' =: X(j,:) of minimal cardinality.

[nConservedMoieties,nMets1] = size(C);
[nConservationRelations,nMets2] = size(R);

if nMets1~=nMets2
    error('C and R must have the same number of columns')
end

%    [solution, nIterations, bestApprox] = sparseLP(model, approximation, params);
%
% INPUTS:
%    model:       Structure containing the following fields describing the linear constraints:
%
%                        * .A - `m x n` LHS matrix
%                        * .b - `m x 1` RHS vector
%                        * .lb - `n x 1` Lower bound vector
%                        * .ub - `n x 1` Upper bound vector
%                        * .csense - `m x 1` Constraint senses, a string containting the model sense for
%                          each row in `A` ('E', equality, 'G' greater than, 'L' less than).

model.A = R';
model.lb = zeros(nConservationRelations,1);
model.ub = inf*ones(nConservationRelations,1);
model.csense(1:nMets1,1)='E';

X=sparse(nConservedMoieties,nConservationRelations);

method ='LP1';
for j=1:nConservedMoieties
    model.b=C(j,:)';
    switch method
        case 'sparseLP'
            [solution, nIterations, bestApprox] = sparseLP(model, 'cappedL1');
            X(j,:) = solution.x';
        case 'LP1'
            model.c=ones(nConservationRelations,1);
            solution = solveCobraLP(model);
            X(j,:) = solution.full';
    end
    
    if 0==mod(j,1)
        disp(j/nConservedMoieties)
    end
end


end

