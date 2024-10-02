function [model] = reformulateWBMCoupling(model, BIG, printLevel)
% Reformulates badly-scaled model
% Transforms LPproblems with badly-scaled stoichiometric and
% coupling constraints of the form:
% :math:`max c*x` subject to: math:`Ax <= b`
%
% Eliminates the need for scaling and hence prevents infeasibilities
% after unscaling. After using PREFBA to transform a badly-scaled FBA program,
% please turn off scaling and reduce the aggressiveness of presolve.
%
% Rransforms a badly-scaled LPproblem
% contained in the struct FBA and returns the transformed program in the
% structure FBA. `reformulate` assumes `S` and `C` do not contain very small entries
% and transforms constraints containing very large entries (entries larger than
% BIG). BIG should be set between 1000 and 10000 on double precision machines.
% `printLevel` = 1 or 0 enables/diables printing respectively.
%
% Reformulation techniques are described in detail in:
% `Y. Sun, R. M.T. Fleming, M. A. Saunders, I. Thiele, An Algorithm for Flux
% Balance Analysis of Multi-scale Biochemical Networks, submitted`.
%
% USAGE:
%
%    [LPproblem] = reformulate(LPproblem, BIG, printLevel)
%
% INPUTS:
%    LPproblem:     Structure contain the original LP to be solved. The format of
%                   this struct is described in the documentation for `solveCobraLP.m`
%
% OPTIONAL INPUTS:
%    BIG:           A parameter the controls the largest entries that appear in the
%                   reformulated problem.
%    printLevel:    1 enables printing of problem statistics;
%                   0 = silent
%
% OUTPUTS:
%    LPproblem:     Structure contain the reformulated LP to be solved.
%
% .. Authors:
%       - Michael Saunders, saunders@stanford.edu
%       - Yuekai Sun, yuekai@stanford.edu, Systems Optimization Lab (SOL), Stanford University
%
% ..
%    VERSION HISTORY:
%      0.1.0
%      0.1.1  Optimized code for large sparse S and C matrices.
%      0.1.2  Committed Prof. Saunders' suggestions and optimizations.
%      0.2.0  Implemented new method that for transforming badly-scaled S matrices
%             that yields smaller programs.
%      0.2.1  c = maxval(k1) was overwriting vector c. Changed to qty = maxval(k1).
%      0.3    Oct 1st Tailored to WBMs - Ronan Fleming

if ~exist('BIG','var')
    BIG=1000;
end
logbig  = log(BIG);

if ~exist('printLevel','var')
    printLevel=1;
end

A      = model.C;
b      = model.d;
c      = model.c;
x_L    = model.lb;
x_U    = model.ub;
dsense = char(model.dsense);
ctrs = model.ctrs;

if isfield(model,'modelID')
    modelID=model.modelID;
else
    modelID='aModel';
end

% find badly scaled coupling constraints

L       = dsense=='L';
G       = dsense=='G';
cuprowBool  = (L|G) & b==0 & ...
    (sum(abs(A)>0,2)==2) & ...
    (sum(sign(A) ,2)==0);
ncuprowBool = ~cuprowBool;

C       = A(cuprowBool,:);
ctrs_cuprow = ctrs(cuprowBool);

[maxval,maxind] = max(abs(C),[],2);
badrowBool  = maxval>=BIG;

maxval  = maxval(badrowBool);
maxind  = maxind(badrowBool);
badrowInd  = find(badrowBool);
nbadrow = length(badrowInd);

cupcon  = dsense(cuprowBool);

if printLevel == 1
    fprintf([...
        'Transforming %i badly-scaled coupling constraints with sequences of\n'...
        'well-scaled coupling constraints. This may take a few minutes.\n'...
        ],nbadrow)
end

% Replace badly-scaled coupling constraints with sequences of well-scaled
% coupling constraints.
% The loop processes "bad" rows of matrix `C` identified by `badrowInd` and modifies
% `C` by adding dummy blocks and adjusting certain matrix elements.
% Dummy variables are introduced to handle large values (`qty`) in `C(i, j)`,
% and the matrix `C` is expanded accordingly. The `newcon` array stores updated
% constraints, one for each dummy variable added.

[m,n]  = size(C);  % Get the dimensions of matrix C, with m as the number of rows and n as the number of columns
ndum   = 0;        % Initialize the variable ndum, which will count the number of dummy variables added
newcon = [];       % Initialize an empty array newcon, which will store new constraints

for k1 = 1:nbadrow  % Loop over all the bad rows (nbadrow) identified in the problem
    i   = badrowInd(k1);  % Get the index of the current bad row from badrowInd(k1)
    j   = maxind(k1);  % Get the column index corresponding to the maximum value for this row
    qty = maxval(k1);  % Get the maximum value itself for this row

    sgn = sign(C(i,j));  % Determine the sign of the element C(i,j) (positive or negative)
    dum = max(floor(log(qty)/logbig),1);  % Calculate the number of dummy variables needed based on the log of the max value
    stp = 2^ceil(log2(qty)/dum);  % Compute the step size as a power of 2, ensuring equal division by the number of dummies

    % Create a diagonal block matrix dumblk using sparse diagonal representation.
    % This matrix has -1 on the diagonal and stp on the superdiagonal, with 'dum' size.
    dumblk = spdiags(sgn*[-ones(dum,1) stp*ones(dum,1)],...
        [0 1],dum,dum);
    C      = blkdiag(C,dumblk);  % Add the new diagonal block dumblk to the matrix C, expanding its size

    C(i,n+1)   = sgn*stp;       % Update the matrix C: Set the element in row i and the new (n+1) column to sgn*stp
    ctrs_cuprow{i} = ['dummy0_' ctrs_cuprow{i}]; %Annotate the original coupling constraint identifier with dummy0
    C(m+dum,j) = sgn*qty/stp^dum;  % Update C at the new row (m+dum) and column j with the adjusted qty/stp^dum
    C(i,j)     = 0;            % Set the original element C(i,j) to zero, as it's replaced by the dummy
    number=1;
    for ind = m:m+dum
        ctrs_cuprow{ind} = ['dummy' num2str(number) '_' ctrs_cuprow{i}]; %Annotate the dummy coupling constraint identifier with dummyNumber
        number = number + 1;
    end
    [m,n] = size(C);  % Update the dimensions of matrix C after adding the new dummy block
    ndum  = ndum+dum;  % Increment the count of dummy variables by dum

    % Append the constraint associated with row i to the new constraints array, repeated 'dum' times
    newcon = [newcon
        repmat(cupcon(i),dum,1)];
end

A      = [[A(ncuprowBool,:) sparse(nnz(ncuprowBool),ndum)];
    C ];
newctrs = [ctrs(ncuprowBool) ; ctrs_cuprow];
b      = [b(ncuprowBool)
    b(cuprowBool)
    zeros(ndum,1)];
c      = [c
    zeros(ndum,1)];
x_L    = [x_L
    -Inf(ndum,1)];
x_U    = [x_U
    Inf(ndum,1)];
dsense = [dsense(ncuprowBool)
    cupcon
    newcon];

% dump tranformed model into struct
model.S      = [model.S, sparse(size(model.S,1),ndum)];
model.c      = c;
model.C      = A;
model.d      = b;
model.lb     = x_L;
model.ub     = x_U;
model.dsense = dsense;
model.modelID = [modelID '_liftedCouplingConstraints'];
end


function A = delnan(A)
% DELNAN Delete NaN's.
%
[I,J,a]   = find(A);
nanind    = find(isnan(a));
I(nanind) = [];
J(nanind) = [];
a(nanind) = [];
A         = sparse(I,J,a);
end
