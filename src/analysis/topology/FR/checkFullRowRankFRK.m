% Check the row rank of the [F, R] half-stoichiometric matrix of a loop toy
% model augmented with kinetic-parameter blocks If and Ir: build the augmented
% matrix, test its stoichiometric consistency, report the row rank deficiency
% of [F R; If Ir], and inspect A*A' symbolically for a left-nullspace vector.

makeLoopToyModel;
% Check for positive left nullspace basis when kinetic parameters are variables.
% If the sum of each column of  If equals that of the corresponding column of  Ir,
% then there exists a vector of ones in the left nullspace.
this=3;
switch this
    case 1
        If = diag([2,1,1]);
        Ir = diag([1,1,2]);
    case 2
        If = [1,0,0;
            0,1,0;
            0,0,1];
        Ir = [0,0,1;
            0,1,0;
            1,0,0];
    case 3
        If = [1,0,0;
            0,1,0;
            0,0,1;
            0,0,0];
        Ir = [1,0,0;
            0,1,0;
            0,0,0;
            0,0,1];
end

A = [ -F +  R;
    -If + Ir];
% A = [-If + Ir];

[nMet,nRxn]=size(A);

disp(A)

model.S=A;
[inform,m]=checkStoichiometricConsistency(model,1);
fprintf('\n');

B = [F R;
    If Ir];

disp(B)

fprintf('%s\n',['Row rank deficiency = ' int2str(size(B,1)-rank(B))])

syms a b c c1 c2 c3 c4 real
x=[a,b,c,c1,c2,c3,c4]';

pretty(A*A'*x(1:nMet,1))
