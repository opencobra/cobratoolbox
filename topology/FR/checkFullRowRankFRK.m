% check for positive left nullspace basis when kinetic parameters are
% variables

makeLoopToyModel;

%If the sum of each column of  If equals that of the corresponding column of  Ir,
%then there exists a vector of ones in the left nullspace.
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
if 1
    A = [ -F +  R;
        -If + Ir];
else
    A = [-If + Ir];
end

[nMet,nRxn]=size(A);

disp(A)

model.S=A;
[inform,m]=checkStoichiometricConsistency(model,1);
fprintf('\n');

B = [F R;
    If Ir];

disp(B)

fprintf('%s\n',['Row rank deficiency = ' int2str(size(B,1)-rank(B))])

if 1
    syms a b c c1 c2 c3 c4 real
    x=[a,b,c,c1,c2,c3,c4]';
    
    pretty(A*A'*x(1:nMet,1))
end
