function [LPproblem] = reformulate(LPproblem, BIG, printLevel)
% REFORMULATE reformulates badly-scaled FBA program
% REFORMULATE transforms LPproblems with badly-scaled stoichiometric and 
% coupling constraints of the form:
% 
%   max c*x  subject to: Ax <= b
% 
% REFORMULATE eliminates the need for scaling and hence prevents infeasibilities
% after unscaling. After using PREFBA to transform a badly-scaled FBA program,
% please turn off scaling and reduce the aggressiveness of presolve.
% 
% [LPproblem] = REFORMULATE(LPproblem,BIG) transforms a badly-scaled LPproblem 
% contained in the struct FBA and returns the transformed program in the 
% structure FBA. REFORMULATE assumes S and C do not contain very small entries 
% and transforms constraints containing very large entries (entries larger than 
% BIG). BIG should be set between 1000 and 10,000 on double precision machines.
% PRINTLEVEL = 1 or 0 enables/diables printing respectively.
% 
% Reformulation techniques are described in detail in:
% Y. Sun, R. M.T. Fleming, M. A. Saunders, I. Thiele, An Algorithm for Flux
% Balance Analysis of Multi-scale Biochemical Networks, submitted.
% 
% INPUTS:
%   LPproblem  : Structure contain the original LP to be solved. The format of
%                this struct is described in the documentation for solveCobraLP.m
%   BIG        : A parameter the controls the largest entries that appear in the
%                reformulated problem.
%   printLevel : printLevel = 1 enables printing of problem statistics
%                printlevel = 0 silent
% 
% OUTPUTS:
%   LPproblem  : Structure contain the reformulated LP to be solved. 
% 
% AUTHORS:
%   Michael Saunders    saunders@stanford.edu
%   Yuekai Sun          yuekai@stanford.edu
%   Systems Optimization Lab (SOL), Stanford University
% 
% VERSION HISTORY:
%   0.1.0
%   0.1.1  Optimized code for large sparse S and C matrices.
%   0.1.2  Committed Prof. Saunders' suggestions and optimizations.
%   0.2.0  Implemented new method that for transforming badly-scaled S matrices
%          that yields smaller programs.
%   0.2.1  c = maxval(k1) was overwriting vector c. Changed to qty = maxval(k1).
% 
  A      = LPproblem.A;
  b      = LPproblem.b;
  c      = LPproblem.c*LPproblem.osense;
  x_L    = LPproblem.lb;
  x_U    = LPproblem.ub;
  csense = char(LPproblem.csense);
  mets   = LPproblem.mets;
  rxns   = LPproblem.rxns;
  nrxn   = length(rxns);
  if isfield(LPproblem,'modelID')
      modelID=LPproblem.modelID;
  else
      modelID='aModel';
  end
% find reactions with large coefficients

  logbig  = log(BIG);

  storow  = csense == 'E' & b==0;
  nstorow = nnz(storow);
  S       = A(storow,:);
  Sabs    = abs(S);

  lrgcol  = find(max(Sabs)>BIG);
  nlrgcol = length(lrgcol);
  lrgrow  = find(max(Sabs(:,lrgcol),[],2)>BIG);
  nlrgrow = length(lrgrow);
  Slrg    = S(lrgrow,lrgcol);
  Sabs    = Sabs(lrgrow,lrgcol);
  
  if printLevel == 1
    fprintf([...
    'Transforming %i reactions with large coefficients with sequences of\n'...
    'reactions with small coefficients. This may take a few minutes.\n'...
    ],nlrgcol)
  end

% replace reactions with large coefficients with sequences of reactions with
% small coefficients

  [m,n]  = size(Slrg);
  ndum   = 0;
  for k1 = 1:nlrgrow
      lrgind  = find(Sabs(k1,:)>BIG);
      lrgnums = Sabs(k1,lrgind);
      dum     = max(floor(log(lrgnums)./logbig),1);
      stp     = 2^mode(ceil(log2(lrgnums)./dum));

      maxdum  = max(dum);
      dumblk       = spdiags([ones(maxdum,1) -stp*ones(maxdum,1)],...
                             [0 1],maxdum,maxdum);
      Slrg         = blkdiag(Slrg,dumblk);
      Slrg(k1,n+1) = -stp;
      for k2 = min(dum):max(dum)
          j = lrgind(dum==k2);
          Slrg(m+k2,j) = Slrg(k1,j)./stp^k2;
      end
      S(lrgrow(k1),lrgcol(lrgind)) = NaN;

      [m,n] = size(Slrg);
      ndum  = ndum+maxdum;
  end
  
  i1 = 1:nlrgrow;
  i2 = nlrgrow+1:nlrgrow+ndum;
  j1 = 1:nlrgcol;
  j2 = nlrgcol+1:nlrgcol+ndum;
  S1 = delnan(S);
  S2 = sparse(ndum,nrxn);
  S2(:,lrgcol) = Slrg(i2,j1);
  S3 = sparse(nnz(storow),ndum);
  S3(lrgrow,:) = Slrg(i1,j2);
  S4 = Slrg(i2,j2);
  
  A      = [[S1 S3
             S2 S4];
            [A(~storow,:) sparse(nnz(~storow),ndum)]];
  b      = [b(storow)
            zeros(ndum,1)
            b(~storow)];
  c      = [c
            zeros(ndum,1)];
  x_L    = [x_L
           -Inf(ndum,1)];
  x_U    = [x_U
            Inf(ndum,1)];
  csense = [repmat('E',nnz(storow)+ndum,1)
            csense(~storow)];

% find badly scaled coupling constraints

  L       = csense=='L';
  G       = csense=='G';
  cuprow  = (L|G) & b==0 & ...
            (sum(abs(A)>0,2)==2) & ...
            (sum(sign(A) ,2)==0);
  ncuprow = ~cuprow;

  C       = A(cuprow,:);
  [maxval,maxind] = max(abs(C),[],2);
  badrow  = maxval>=BIG;

  maxval  = maxval(badrow);
  maxind  = maxind(badrow);
  badrow  = find(badrow);
  nbadrow = length(badrow);

  cupcon  = csense(cuprow);
  
  if printLevel == 1
    fprintf([...
    'Transforming %i badly-scaled coupling constraints with sequences of\n'...
    'well-scaled coupling constraints. This may take a few minutes.\n'...
    ],nbadrow)
  end
  
% replace badly-scaled coupling constraints with sequences of well-scaled
% coupling constraints

  [m,n]  = size(C);
  ndum   = 0;
  newcon = [];
  for k1 = 1:nbadrow
      i   = badrow(k1);
      j   = maxind(k1);
      qty = maxval(k1);

      sgn = sign(C(i,j));
      dum = max(floor(log(qty)/logbig),1);
      stp = 2^ceil(log2(qty)/dum);

      dumblk = spdiags(sgn*[-ones(dum,1) stp*ones(dum,1)],...
                       [0 1],dum,dum);
      C      = blkdiag(C,dumblk);

      C(i,n+1)   = sgn*stp;
      C(m+dum,j) = sgn*qty/stp^dum;
      C(i,j)     = 0;

      [m,n] = size(C);
      ndum  = ndum+dum;

      newcon = [newcon
                repmat(cupcon(i),dum,1)];
  end

  A      = [[A(ncuprow,:) sparse(nnz(ncuprow),ndum)];
             C ];
  b      = [b(ncuprow)
            b(cuprow)
            zeros(ndum,1)];
  c      = [c
            zeros(ndum,1)];
  x_L    = [x_L
           -Inf(ndum,1)];
  x_U    = [x_U
            Inf(ndum,1)];
  csense = [csense(ncuprow)
            cupcon
            newcon];

% dump tranformed LPproblem into struct

  LPproblem.c      = c;
  LPproblem.A      = A;
  LPproblem.b      = b;
  LPproblem.lb     = x_L;
  LPproblem.ub     = x_U;
  LPproblem.csense = csense;
  LPproblem.modelID = ['L_' modelID];
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

