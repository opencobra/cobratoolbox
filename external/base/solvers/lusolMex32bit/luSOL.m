function [L,U,p,q,inform] = luSOL(A)

%        [L,U,p,q,inform] = luSOL(A);
%
% This is an example script that uses lusolFactor
% to find LU factors of sparse matrix A
% using predefined options (hardwired here).

% In general, it is better to call lusolSet yourself
% and then reset a few options if necessary as shown.

% 28 Apr 2004: First version of luSOL based in splu.m.
%              Michael Saunders, SOL, Stanford University.

options = lusolSet;
options.Pivoting   = 'TRP';
options.FactorTol  = 4.0;

[L,U,p,q,options]  = lusolFactor(A,options);

inform = options.Inform;
