function OK=convertCobraLP2mps(LPProblem,name)
% create an MPS (Mathematical Programming System) format ascii file 
% representing the Linear Programming problem given by LPProblem.
%
% The MPS (Mathematical Programming System) file format was introduced by
% IBM in 1970s, but has also been accepted by most subsequent linear
% programming codes. To learn about MPS format, please see:
%   http://lpsolve.sourceforge.net/5.5/mps-format.htm
%
% INPUT
% LPproblem Structure containing the following fields describing the LP
%           problem to be solved
%           A      LHS matrix
%           b      RHS vector
%           c      Objective coeff vector
%           lb     Lower bound vector
%           ub     Upper bound vector
%           osense Objective sense (-1 max, +1 min)
%           csense Constraint senses, a string containting the constraint sense for
%                  each row in A ('E', equality, 'G' greater than, 'L' less than).
%
% OPTIONAL INPUT
% name      string giving name of LP problem     
% 
% OUTPUT
% OK      1 if saving is success, 0 otherwise
%
% Ronan M.T. Fleming: 7 Sept 09
% Uses MPS format exporting tool by Bruno Luong 03 Sep 2009
% http://www.mathworks.com/matlabcentral/fileexchange/19618

if ~exist('name','var')
    name='CobraLPProblem';
end

mlt=size(LPProblem.A,1);
if ~isfield(LPProblem,'csense')
    LPProblem.csense(1:mlt)='E';
end
if size(LPProblem.csense,1)>size(LPProblem.csense,2)
    LPProblem.csense=LPProblem.csense';
end

E=false(mlt,1);
G=false(mlt,1);
L=false(mlt,1);
Eind=findstr('E',LPProblem.csense);
Gind=findstr('G',LPProblem.csense);
Lind=findstr('L',LPProblem.csense);
E(Eind)=1;
G(Gind)=1;
L(Lind)=1;

Aeq=LPProblem.A(E,:);
beq=LPProblem.b(E,1);

%need to change sign of A*x >= b constraints
A2=LPProblem.A;
b2=LPProblem.b;
A2(G)=-A2(G);
b2(G)=-b2(G);
A=A2(G | L,:);
b=b2(G | L,:);

cost=LPProblem.c*LPProblem.osense;

L=LPProblem.lb;
U=LPProblem.ub;



% Build ascii fixed-width MPS matrix string that contains linear
% programming (LP) problem:
%
% Minimizing (for x in R^n): f(x) = cost'*x, subject to
%       A*x <= b        (LE)
%       Aeq*x = beq     (EQ)
%       L <= x <= U     (BD).

[Contain]=BuildMPS(A, b, Aeq, beq, cost, L, U,upper(name));

% Save matrix sring Contain in file "filename"
% Return OK == 1 if saving is success
%        OK == 0 otherwise
filename=[name '.mps'];
OK=SaveMPS(filename, Contain);

