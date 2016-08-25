function testOK=testSubspaces()

load Ecoli_core.mat

model=findSExRxnInd(model);

printLevel=1;
subspace='all';
%internal reactions from stoichiometric matrix
SInt=model.S(:,model.SIntRxnBool);

[m,n]=size(SInt);

%calculate the subspace projectors
[PR,PN,PC,PL]=subspaceProjector(model,printLevel,subspace);

u=rand(m,1);
v=rand(n,1);

% Let M denote the Moore-Penrose pseudoinverse of the internal reaction
% stoichiometric matrix and the subscripts are the following
% _R row space
% _N nullspace
% _C column space
% _L left nullspace
%
% Let v = v_R + v_N
%
% v_R = M*S*v = PR*v 
v_R = PR*v;

% v_N = (I - M*S)*v = PN*v
v_N = PN*v;

% Let u = u_C + u_L
%
% u_C = S*M*u = PC*u
u_C=PC*u;

% u_L = (I - S*M)*u = PL*u
u_L=PL*u;

tol=1e-6;
if norm(v - v_R - v_N)<tol && norm(u - u_C - u_L)<tol
    testOK=1;
else
    testOK=0;
end

    