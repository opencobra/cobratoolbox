Build MPS matrix string that contains linear programming problem:

Minimizing (for x in R^n): f(x) = cost'*x, subject to
      A*x <= b        (LE)
      Aeq*x = beq     (EQ)
      L <= x <= U     (BD).

Only single rhs (b and beq) is supported.

Also supported is integer/mixte programming problem similar to the above,
where a subset of components of x is restricted to be integer (N set) or
binary set {0,1}.

The MPS file format was introduced for an IBM program, but has also been
accepted by most subsequent linear programming codes.

To learn about mps format, please see:
  http://lpsolve.sourceforge.net/5.5/mps-format.htm


Usage example:
    A = [1 1 0; -1 0 -1];
    b = [5; -10];
    L = [0; -1; 0];
    U = [4; +1; +inf];
    Aeq = [0 -1 1];
    beq = 7;
    cost = [1 4 9];
    VarNameFun = @(m) (char('x'+(m-1))); % returning varname 'x', 'y' 'z'
  
    Contain = BuildMPS(A, b, Aeq, beq, cost, L, U, 'Pbtest', ...
                       'VarNameFun', VarNameFun, ...
                       'EqtNames', {'Equality'}, ...
                       'Integer', [1], ... % first variable 'x' integer
                       'MPSfilename', 'Pbtest.mps');NameFun, 'MPSfilename', ...
                    'Pbtest.mps')

Author: Bruno Luong
update: 15-Jul-2008: sligly improved number formatting
        25-Aug-2009: Improvement in handling sparse matrix
	03-Sep-2009: integer/binary variables