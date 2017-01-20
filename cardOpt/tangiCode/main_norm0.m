% Code matalb
clear all
%####################################################################
% Definitions des constantes :

% Précision à zéro :
zeps=eps;

%####################################################################
% Fleming's test case in biology :

% For instance exemple AraGEM :
load iAsyn_0_3_0.mat

c=-model.c; %note the negative
n=size(c,1)
Aeq=model.S;
beq=model.b;
lb=model.lb;
ub=model.ub;
Ain=zeros(n,1)';bin=0;
size(Aeq)
polyhedron=struct('Aeq',model.S,'beq',model.b,'Ain',Ain,'bin',bin,'lb',model.lb,'ub',model.ub);

% min   ||x||_0
% min   c'x
% s.t.  Sx=b
%       lb <= x <= ub

[result_tab,code_error,nb_warm_start, sol]=SparseLP_old(c,polyhedron, zeps, 10);

result_tab

% error_code :
% -2 : maximum iteration in r
% -1 : maximum iteration in SLA
% 0 : success
% 1 : unbounded
% 2 : precision
code_error

nb_warm_start

precision=max(norm(Aeq*sol-beq,Inf),max(max(Ain*sol-bin),max(max(lb-sol),max(sol-ub))))
