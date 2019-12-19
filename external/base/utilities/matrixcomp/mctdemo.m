clc
format compact
echo on
%MCTDEMO       Demonstration of Matrix Computation Toolbox.
%              N. J. Higham.

% The Matrix Computation Toolbox contains test matrices, matrix
% factorizations, visualization functions, direct search optimization
% functions, and other miscellaneous functions.

% The version of the toolbox is

matrix(-1)
echo on

% For this demonstration you will need to view both the command window
% and one figure window.
% This demonstration emphasises graphics and shows only
% some of the features of the toolbox.

pause  % Press any key to continue after pauses.

% A list of test matrices available in MATLAB and in the Toolbox (all full,
% square, and of arbitrary dimension) is obtained by typing `matrix':

matrix

pause

% The FV command plots the boundary of the field of values of a matrix
% (the set of all Rayleigh quotients) and plots the eigenvalues as
% crosses (`x').  Here are some examples:

% Here is the field of values of the 10-by-10 Grcar matrix:

clf
fv(gallery('grcar',10));
title('fv(gallery(''grcar'',10))')

pause

% Next, we form a random orthogonal matrix and look at its field of values.
% The boundary is the convex hull of the eigenvalues since A is normal.

A = gallery('randsvd',10, 1);
fv(A);
title('fv(gallery(''randsvd'',10, 1))')
pause

% The PS command plots an approximation to a pseudospectrum of A,
% which is the set of complex numbers that are eigenvalues of some
% perturbed matrix A + E, with the norm of E at most epsilon
% (default: epsilon = 1E-3).
% The eigenvalues of A are plotted as crosses (`x').
% Here are some interesting PS plots.

% First, we use the Kahan matrix, a triangular matrix made up of sines and
% cosines.  Here is an approximate pseudospectrum of the 10-by-10 matrix:

ps(gallery('kahan',10),25);
title('ps(gallery(''kahan'',10),25)')
pause

% Next, a different way of looking at pseudospectra, via norms of
% the resolvent.  (The resolvent of A is INV(z*I-A), where z is a complex
% variable).  PSCONT gives a color map with a superimposed contour
% plot.  Here we specify a region of the complex plane in
% which the 8-by-8 Kahan matrix is interesting to look at.

pscont(gallery('kahan',8), 0, 20, [0.2 1.2 -0.5 0.5]);
title('pscont(gallery(''kahan'',8))')
pause

% The triw matrix is upper triangular, made up of 1s and -1s:

gallery('triw',4)

% Here is a combined surface and contour plot of the resolvent for N = 11.
% Notice how the repeated eigenvalue 1 `sucks in' the resolvent.

pscont(gallery('triw',11), 2, 15, [-2 2 -2 2]);
title('pscont(gallery(''triw'',11))')
pause

% The next PSCONT plot is for the companion matrix of the characteristic
% polynomial of the CHEBSPEC matrix:

A = gallery('chebspec',8); C = compan(poly(A));

% The SHOW command shows the +/- pattern of the elements of a matrix, with
% blanks for zero elements:

show(C)

pscont(C, 2, 20, [-.1 .1 -.1 .1]);
title('pscont(gallery(''chebspec'',8))')
pause

% The following matrix has a pseudospectrum in the form of a limacon.

n = 25; A = gallery('triw',n,1,2) - eye(n);
sub(A, 6)               % Leading principal 6-by-6 submatrix of A.
ps(A);
pause

% We can get a visual representation of a matrix using the SEE
% command, which produces subplots with the following layout:
%     /---------------------------------\
%     | MESH(A)        SEMILOGY(SVD(A)) |
%     | PS(A)               FV(A)       |
%     \---------------------------------/
% where PS is the 1e-3 pseudospectrum and FV is the field of values.
% RSCHUR is an upper quasi-triangular matrix:

see(rschur(16,18));

pause

% Matlab's MAGIC function produces magic squares:

A = magic(5)

% Using the toolbox routine PNORM we can estimate the matrix p-norm
% for any value of p.

[pnorm(A,1) pnorm(A,1.5) pnorm(A,2) pnorm(A,pi) pnorm(A,inf)]

% As this example suggests, the p-norm of a magic square is
% constant for all p!

pause

% GERSH plots Gershgorin disks.  Here are some interesting examples.
clf
gersh(gallery('lesp',12));
title('gersh(gallery(''lesp'',12))')
pause

gersh(gallery('hanowa',10));
title('gersh(gallery(''hanowa'',10))')
pause

gersh(gallery('ipjfact',6,1));
title('gersh(gallery(''ipjfact'',6,1))')
pause

gersh(gallery('smoke',16,1));
title('gersh(gallery(''smoke'',16,1))')
pause

% GFPP generates matrices for which Gaussian elimination with partial
% pivoting produces a large growth factor.

gfpp(6)
pause

% Let's find the growth factor RHO for partial pivoting and complete pivoting
% for a bigger matrix:

A = gfpp(20);

[L, U, P, Q, rho] = gep(A,'p'); % Partial pivoting using Toolbox function GEP.
[rho, 2^19]

[L, U, P, Q, rho] = gep(A,'c'); % Complete pivoting using Toolbox function GEP.
rho
% As expected, complete pivoting does not produce large growth here.
pause

% Function MATRIX allows test matrices in the Toolbox and MATLAB to be
% accessed by number.  The following piece of code steps through all the
% non-Hermitian matrices of arbitrary dimension, setting A to each
% 10-by-10 matrix in turn.  It evaluates the 2-norm condition number and the
% ratio of the largest to smallest eigenvalue (in absolute values).

% c = []; e = []; j = 1;
% for i=1:matrix(0)
%     % Double on next line avoids bug in MATLAB 6.5 re. i = 35.
%     A = double(matrix(i, 10));
%     if ~isequal(A,A')  % If not Hermitian...
%        c1 = cond(A);
%        eg = eig(A);
%        e1 = max(abs(eg)) / min(abs(eg));
%        % Filter out extremely ill-conditioned matrices.
%        if c1 <= 1e10, c(j) = c1; e(j) = e1; j = j + 1; end
%     end
% end
echo off

c = []; e = []; j = 1;
for i=1:matrix(0)
    % Double on next line avoids bug in MATLAB 6.5 re. i = 35.
    A = double(matrix(i, 10));
    if ~isequal(A,A')  % If not Hermitian...
       c1 = cond(A);
       eg = eig(A);
       e1 = max(abs(eg)) / min(abs(eg));
       % Filter out extremely ill-conditioned matrices.
       if c1 <= 1e10, c(j) = c1; e(j) = e1; j = j + 1; end
    end
end
echo on

% The following plots confirm that the condition number can be much
% larger than the extremal eigenvalue ratio.
echo off
j = max(size(c));
subplot(2,1,1)
semilogy(1:j, c, 'x', 1:j, e, 'o'), hold on
semilogy(1:j, c, '-', 1:j, e, '--'), hold off
title('cond: x, eig\_ratio: o')
subplot(2,1,2)
semilogy(1:j, c./e)
title('cond/eig\_ratio')
echo on
pause

% Finally, here are three interesting pseudospectra based on pentadiagonal
% Toeplitz matrices:

clf
ps(full(gallery('toeppen',32,0,1/2,0,0,1)));            % Propeller
pause

ps(inv(full(gallery('toeppen',32,0,1,1,0,.25))));       % Man in the moon
pause

ps(full(gallery('toeppen',32,0,1/2,1,1,1)));            % Fish
pause

echo off
clear A L U P Q V D
format
