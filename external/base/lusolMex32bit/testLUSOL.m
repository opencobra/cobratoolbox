% File testLUSOL.m
%
% Script for testing various LUSOL factorizations
% on the merged_S.mat matrix from 5 Dec 2006
% (S = 62177 x 75644 916437).
%
% 25 Jan 2008: First experiments on this particular S.
%              All used options.FactorTol = 2.
%              S is badly scaled, but several options
%              find the rank to be 61833 (rank deficiency 344).

load merged_S
[m,n] = size(S)
nnzS  = nnz(S)

options = lusolSet;
options.FactorTol = 2.0;
options.Pivoting = 'TPP';

%-----------------------------------------------------------------------------
% Try cheapest method:  L*U = S'
% It returns rank 61833.
disp(' ')
disp('Factor S(transpose)')
ST = S';
tic
[L1,U1,p1,q1,options] = lusolFactor(ST,options);
toc

% m       75644 >n       62177  Elems   916437  Amax   8.0E+05  Density   0.02
% Singular(m>n)  rank    61833  n-rank     344  nsing      344
% Merit    95.3  lenL   306685  L+U    1051242  Cmpressns    0  Incres   14.71
% Utri      556  lenU   744557  Ltol  2.00E+00  Umax   8.0E+05  Ugrwth 1.0E+00
% Ltri     3633  dense1      0  Lmax  2.00E+00
% bump    71455  dense2      0  DUmax  2.5E+03  DUmin  5.0E-01  condU  5.0E+03

rank1 = options.Rank;
rows1 = q1(1:rank1);
S1    = S(rows1,:);  % These should be independent rows of S.


%-----------------------------------------------------------------------------
% Try Rook Pivoting.
% S is too badly scaled for this to be efficient.
% Find column and row scales first.
disp(' ')
disp('Scale S now')
iprint  = 1;
scltol  = 0.9;
tic
[cscale,rscale] = gmscal(S,iprint,scltol);
disp(' ')
toc

% Apply scale factors to S.
C = spdiags(cscale,0,n,n);   Cinv = spdiags(1./cscale,0,n,n);
R = spdiags(rscale,0,m,m);   Rinv = spdiags(1./rscale,0,m,m);
SS = Rinv*S*Cinv;  % Scaled S
%-----------------------------------------------------------------------------


% Factor scaled SS with rook pivoting.
% It returns rank 61833.
disp(' ')
disp('Factor scaled S now with rook pivoting')
options.Pivoting = 'TRP';    
tic
[L2,U2,p2,q2,options] = lusolFactor(SS,options);
toc

% m       62177 <n       75644  Elems   916437  Amax   1.0E+00  Density   0.02
% Singular(m<n)  rank    61833  n-rank   13811  nsing    13811
% MerRP    39.5  lenL   210899  L+U    1617359  Cmpressns    5  Incres   76.48
% Utri     2966  lenU  1406460  Ltol  2.00E+00  Umax   2.0E+00  Ugrwth 2.0E+00
% Ltri      207  dense1      0  Lmax  2.00E+00  Akmax  0.0E+00  Agrwth 0.0E+00
% bump    59004  dense2      0  DUmax  2.0E+00  DUmin  2.3E-05  condU  8.5E+04

rank2 = options.Rank;
rows2 = p2(1:rank2);
S2    = S(rows2,:);  % These should be independent rows of S.



%-----------------------------------------------------------------------------
% Factor scaled SS with rook pivoting.
% It returns rank 61833 also.
disp(' ')
disp('Factor scaled S(transpose) now with rook pivoting')
tic
[L3,U3,p3,q3,options] = lusolFactor(SS',options);
toc

% m       75644 >n       62177  Elems   916437  Amax   1.0E+00  Density   0.02
% Singular(m>n)  rank    61833  n-rank     344  nsing      344
% Merit    12.7  lenL   571936  L+U    1015445  Cmpressns    0  Incres   10.80
% Utri      556  lenU   443509  Ltol  2.00E+00  Umax   3.2E+01  Ugrwth 3.2E+01
% Ltri     2959  dense1      0  Lmax  2.00E+00
% bump    72129  dense2      0  DUmax  2.0E+01  DUmin  5.4E-05  condU  3.8E+05

rank3 = options.Rank;
rows3 = q3(1:rank3);
S3    = S(rows3,:);  % These should be independent rows of S.

disp(' ')
disp('rows1, rows2, rows3 are 3 sets of independent rows of S')
disp('   S1,    S2,    S3 are those submatrices of S')
disp(' ')
