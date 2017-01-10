%the function finds the minimal set of reactions subject to a LP objective
%function


% min   ||x||_0
% min   c'x
% s.t.  Sx=b
%       lb <= x <= ub


%INPUT
%model

%OUTPUT
%resutl_tab - number of reactions obtained for each condition
%sol - x
%lprxns - rxns indices for LP solution
%l1rxns - rxns indices for L1 solution
%l0rxns - rxns indices for L0 solution

%Tangi Migot
%01/10/2015

function [result_tab, sol, lprxns, l1rxns, l0rxns]  = findMinimalSetOfRxns(model)
% Precision to zero :
zeps=eps;
% Maximum number of warm start :
max_nb_warm_start=10;


c=-model.c; %note the negative
n=size(c,1)
Aeq=model.S;
beq=model.b;
lb=model.lb;
ub=model.ub;
% Ain=zeros(n,1)';bin=0;
Ain=[];bin=[];

polyhedron=struct('Aeq',model.S,'beq',model.b,'Ain',Ain,'bin',bin,'lb',model.lb,'ub',model.ub);

[result_tab,code_error,nb_warm_start, sol, lprxns, l1rxns, l0rxns]=SparseLP_old(c,polyhedron, zeps, max_nb_warm_start);

result_tab

precision=max(norm(Aeq*sol-beq,2),max(max(lb-sol),max(sol-ub)))
