function MDFBAProblem = buildMDFBA(model, ignoredMets, minprod)

if ~exist('ignoredMets','var')
    ignoredMets = {};
end


if ~exist('minprod','var')
    minprod = max(model.ub)/10000;
end

[nMets,nRxns] = size(model.S);

MILPproblem = struct();
%We need the following constraints:
%S * v - d = 0;
%if met i is used, then  d = minprod
%Vars will be: 
% Rxns,k,d,i_act,y
%Constraints will be:
%S * v - d =? b (depending on csense)
%k - v >= 0
%k + v >= 0
%(abs(S))*k - i_act = 0;    %-> indicates whether a metabolite is used
%-M1 <= -M1y - i_act     %-> if i_act > 0 then y = 0;
%minprod = minprod * y + d  %-> if y = 0 then d = minprod;

M1 = 10000*max(model.ub);

b = [model.b;zeros(2*nRxns,1);zeros(nMets,1);-M1*ones(nMets,1);minprod*ones(nMets,1)];
lb = [model.lb; zeros(nRxns,1);zeros(3*nMets,1)];
ub = [model.ub; inf(nRxns,1); minprod*ones(nMets,1); inf(nMets,1); ones(nMets,1)];
c = [model.c;zeros(nRxns,1);zeros(3*nMets,1)];
osense = -1;
csense = [model.csense;repmat('G',2*nRxns,1);repmat('E',nMets,1);repmat('G',nMets,1);repmat('E',nMets,1)];
vartype = [repmat('C',2*nRxns,1);repmat('C',2*nMets,1),;repmat('B',nMets,1)];

A = [model.S, sparse(nMets,nRxns), sparse(nMets,3*nMets);...
     speye(nRxns,nRxns),speye(nRxns,nRxns),sparse(nRxns,3*nMets);...
     -speye(nRxns,nRxns),speye(nRxns,nRxns),sparse(nRxns,3*nMets);...
     sparse(nMets,nRxns),abs(model.S),sparse(nMets,nMets),speye(nMets, nMets), sparse(nMets,nMets);...
     sparse(nMets,nRxns),sparse(nMets,nRxns),sparse(nMets,nMets),-speye(nMets, nMets), -M1*speye(nMets,nMets);...
     sparse(nMets,nRxns),sparse(nMets,nRxns),speye(nMets,nMets),sparse(nMets, nMets), minprod*speye(nMets,nMets)];
 
MDFBAProblem = struct('A', A, 'b', b, 'c', c, 'osense', osense,...
                    'lb',lb,'ub',ub,'csense',csense,'vartype',vartype,'x0',zeros(size(A,2),1));
                
