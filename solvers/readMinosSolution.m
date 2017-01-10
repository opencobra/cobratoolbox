function sol = readMinosSolution(fname)
%        sol = readMinosSolution(fname);
% loads MINOS solution information from file fname.
% The file is created by MINOS with the run-time option
%        Report file 81
% Note that 81 is essential, and the gfortran compiler produces a file
% named fort.81 (which may be renamed by the script used to run MINOS).
% Other compilers may generate different generic names.
%
% The optimization problem solved by MINOS is assumed to be
%        min   osense*s(iobj)
%        st    Ax - s = 0    + bounds on x and s,
% where A has m rows and n columns.  The output structure "sol"
% contains the following data:
%
%        sol.inform          MINOS exit condition
%        sol.m               Number of rows in A
%        sol.n               Number of columns in A
%        sol.osense          osense
%        sol.objrow          Row of A containing a linear objective
%        sol.obj             Value of MINOS objective (linear + nonlinear)
%        sol.numinf          Number of infeasibilities in x and s.
%        sol.suminf          Sum    of infeasibilities in x and s.
%        sol.xstate          n vector: state of each variable in x.
%        sol.sstate          m vector: state of each slack in s.
%        sol.x               n vector: value of each variable in x.
%        sol.s               m vector: value of each slack in s.
%        sol.rc              n vector: reduced gradients for x.
%        sol.y               m vector: dual variables for Ax - s = 0.

% 04 Nov 2014: First version of readMinosSolution.m added to quadLP/matlab
%              to transfer quadLP/minos56 and quadLP/qminos56 solutions
%              to the COBRA toolbox.
%              Ding Ma and Michael Saunders, MS&E and ICME, Stanford University.

% File fname must match what is generated when MINOS and quadMINOS are run
% with option
%    Report file 81
% The file contains a (3+nb) x 3 matrix written with
% Fortran format( i2, es24.14, es24.14 ).
%
% The first 3 lines are
%  inform    m       n
%  osense    iobj    obj
%  0         ninf    sinf
%
% Example from LPnetlib problem "afiro":
% 0    2.80000000000000E+01    3.20000000000000E+01
% 1    2.80000000000000E+01   -4.64753142857143E+02
% 0    0.00000000000000E+00    0.00000000000000E+00
%
% The remaining nb lines are
%  hs(j)    xn(j)   rc(j)      for j=1:nb
% corresponding to the problem that MINOS actually solves:
%        min   - osense*s(iobj)
%        st    Ax + s = 0    + bounds on x and s.
% (The slacks have opposite sign relative to the description above,
% but we change them below to match SNOPT and other solvers.)
%  hs(1:n)     is the status of variables x
%  hs(n+1:nb)  is the status of MINOS slack variables s
%  xn(1:n)     is the solution values for x
%  xn(n+1:nb)  is the solution values for the MINOS slacks s
%  rc(1:n)     is the reduced gradients for x
%  rc(n+1:nb)  is the dual variables for each row of Ax + x = 0.

    data = load(fname);   % Should be a (3+nb) x 3 matrix
    sol.inform = data(1,1);
    sol.m      = data(1,2);
    sol.n      = data(1,3);
    sol.osense = data(2,1);
    sol.objrow = data(2,2);
    sol.obj    = data(2,3);
    sol.numinf = data(3,2);
    sol.suminf = data(3,3);

    m  = sol.m;
    n  = sol.n;
    nb = n+m;
    X  = 3+1:3+n;
    S  = 4+n:3+nb;

    xstate = data(X,1);    x = data(X,2);   rc = data(X,3);
    sstate = data(S,1);    s = data(S,2);   y  = data(S,3);

    % Change MINOS slacks into SNOPT slacks.
    s  = - s;
    LO = find(sstate==0);
    UP = find(sstate==1);
    sstate(LO) = 1;
    sstate(UP) = 0;

    sol.xstate = xstate;
    sol.sstate = sstate;
    sol.x      = x;
    sol.s      = s;
    sol.rc     = rc;
    sol.y      = y;

% end function readMinosSolution
