function [Jsl,Jdl,Jtl,Jql] = parallelSL(model,cutoff,eliList,atpm)
%%  [Jsl,Jdl,Jtl,Jql] = parallelSL(model,cutoff,eliList,atpm)
% INPUT
% model (the following fields are required - others can be supplied)
%   S            Stoichiometric matrix
%   b            Right hand side = dx/dt
%   c            Objective coefficients
%   lb           Lower bounds
%   ub           Upper bounds
%   rxns         Reaction Names
%OPTIONAL
% cutoff         cutoff percentage value for lethality.Default is 0.01.
% eliList        List of reactions to be ignored for lethality
% analysis:Exchange Reactions, ATPM etc.
% is true.
% atpm           ATPM Reaction Id in model.rxns if other than 'ATPM'
%OUTPUT
% Jsl        Indices of single lethal reactions identified
% Jdl        Indices of double lethal reactions identified
% Jtl        Indices of triple lethal reactions identified
% Jql        Indices of quadruple lethal reactions identified
% Aditya Pratapa       3/23/15.
%%


if exist('cutoff', 'var')
    if isempty(cutoff)
        cutoff = 0.01;
    end
else
    cutoff = 0.01;
end

% if exist('order', 'var')
%     if isempty(order)
%         order = 4;
%     end
% else
%     order = 4;
% end

if exist('eliList', 'var')
    if isempty(eliList)
        eliList = model.rxns(ismember(model.rxns,'ATPM')); %To eliminate ATPM.
    end
else
    eliList = model.rxns(ismember(model.rxns,'ATPM'));
end

[nMets,nRxns]=size(model.S);
modeldel=Cplex();
modeldel.Model.A=sparse(model.S);
modeldel.Model.obj=model.c;
modeldel.Model.rhs=model.b;
modeldel.Model.lhs=model.b;
modeldel.Model.lb=model.lb;
modeldel.Model.ub=model.ub;
modeldel.Model.sense='maximize';
modeldel.Param.barrier.display.Cur=0;
modeldel.Param.simplex.display.Cur=0;
solution=modeldel.solve();

grWT=solution.objval;
solWT=solution;

% L1-Norm LP Problem

LPproblem2.A = [model.S sparse(nMets,2*nRxns);
    speye(nRxns,nRxns) speye(nRxns,nRxns) sparse(nRxns,nRxns);
    -speye(nRxns,nRxns) sparse(nRxns,nRxns) speye(nRxns,nRxns);
    model.c' sparse(1,2*nRxns)];
LPproblem2.c = [zeros(nRxns,1);ones(2*nRxns,1)];
LPproblem2.lb = [model.lb;zeros(2*nRxns,1)];
LPproblem2.ub = [model.ub;10000*ones(2*nRxns,1)];
LPproblem2.b = [model.b;zeros(2*nRxns,1);grWT];

M2=Cplex();
M2.Model.A=sparse(LPproblem2.A);
M2.Model.obj=LPproblem2.c;

M2.Model.rhs(1:nMets)=LPproblem2.b(1:nMets);
M2.Model.rhs((nMets+1):(nMets+2*nRxns+1))=Inf*[(nMets+1):(nMets+2*nRxns+1)];

M2.Model.lhs(1:nMets)=LPproblem2.b(1:nMets);
M2.Model.lhs((nMets+1):(nMets+2*nRxns+1))=LPproblem2.b((nMets+1):(nMets+2*nRxns+1));

M2.Model.lb=LPproblem2.lb;
M2.Model.ub=LPproblem2.ub;
M2.Model.sense='minimize';
M2.Param.simplex.display.Cur=0;
%%

Jnz=find(~eq(solWT.x,0));

if (~isempty(eliList))
    eliIdx = find(ismember(model.rxns,eliList));
    Jnz=Jnz(~ismember(Jnz,eliIdx)); %Jnz
end
solKO_i=zeros(length(Jnz),1);

tic

parfor iRxn=1:length(Jnz);
    [solKO_i(iRxn), ~]= optMod(modeldel,Jnz(iRxn,:),model);
end

Jsl_time=toc;
Jsl_size=sum(lt(solKO_i,0.01*grWT));
fprintf('\n Identified %d Synthetic Lethals in %d seconds...\n',Jsl_size,Jsl_time);

Jsl=Jnz(lt(solKO_i,0.01*grWT));

%%
%Double Lethal Reactions
Jnz_copy=[solKO_i(~lt(solKO_i,0.01*grWT)) Jnz(~lt(solKO_i,0.01*grWT))];

Jdl=[];

tic
parfor iRxn=1:size(Jnz_copy,1)
   [solKO_i_f(iRxn) solKO_i_x(iRxn,:)]=optMod(M2,Jnz_copy(iRxn,2),model,Jnz_copy(iRxn,1));
end

Jdl_p=[];
for i=1:length(Jnz_copy)
    delIdx_i=Jnz_copy(i,2); 

    newnnz=find(~eq(solKO_i_x(i,:),0))';
    Jnz_i=newnnz(~ismember(newnnz,[Jsl;eliIdx]));
    
    Jdl_p=[Jdl_p;(delIdx_i*(ones(length(Jnz_i),1))) Jnz_i];
end

Jdl_p=unique(sort(Jdl_p,2),'rows');

Jdl=[];
Jtl_ps12=[];
solKO_ij=zeros(length(Jdl_p),1);

parfor i=1:length(Jdl_p);
    [solKO_ij(i),~]= optMod(modeldel,Jdl_p(i,:),model);
end

Jdl_time=toc;
Jdl_size=sum(lt(solKO_ij,0.01*grWT));
fprintf('\n Identified %d Synthetic Lethal Pairs in %d seconds...\n',Jdl_size,Jdl_time);

Jdl=Jdl_p(find(lt(solKO_ij,0.01*grWT)),:);

Jtl_ps12=[solKO_ij(~lt(solKO_ij,0.01*grWT)), Jdl_p(find(~lt(solKO_ij,0.01*grWT)),:)];

Jdl=unique(sort(Jdl,2),'rows');

%%
%Triple Lethal Reactions
Jtl_p=[];
tic
parfor iRxn=1:length(Jtl_ps12)
   [solKO_ij_f(iRxn), solKO_ij_x(iRxn,:)]=optMod(M2,Jtl_ps12(iRxn,2:end),model,Jtl_ps12(iRxn,1));
end


for i=1:length(Jtl_ps12)
    delIdx_ij=Jtl_ps12(i,2:end); 

    newnnz=find(~eq(solKO_ij_x(i,:),0))';
    Jnz_ij=newnnz(~ismember(newnnz,[Jsl;eliIdx]));
    
    Jtl_p=[Jtl_p; delIdx_ij([ones(length(Jnz_ij),1) 2*(ones(length(Jnz_ij),1))]) Jnz_ij];
    
end
Jtl_p=unique(sort(Jtl_p,2),'rows');
temporary=[];
tttt=Jtl_p;
uJdl=unique(Jdl);
dummy=0;
mm=0;
parfor iRxn=1:length(Jtl_p)
    mm=mm+1;
dummy1=ismember(Jtl_p(iRxn,:),uJdl);
dum=Jtl_p(iRxn,:);
if sum(dummy1)>=2
    if max(sum(ismember(Jdl,nchoosek(dum(dummy1),2))'))<2
        temporary=[temporary;Jtl_p(iRxn,:)];
        dummy=dummy+1;
    end
    
else
    temporary=[temporary;Jtl_p(iRxn,:)];
end
end
Jtl_p=temporary;


solKO_ijk=zeros(length(Jtl_p),1);
parfor i=1:length(Jtl_p);
    [solKO_ijk(i)]= optMod(modeldel,Jtl_p(i,:),model);
end

Jtl_size=sum(lt(solKO_ijk,0.01*grWT));
Jtl_time=toc;
fprintf('\n Identified %d Synthetic Lethal Triplets in %d seconds...\n',Jtl_size,Jtl_time);

%%
%Quadruple Lethals
Jtl=Jtl_p(find(lt(solKO_ijk,0.01*grWT)),:);

Jql_ps123=[solKO_ijk(~lt(solKO_ijk,0.01*grWT)), Jtl_p(find(~lt(solKO_ijk,0.01*grWT)),:)];



tic
solKO_ijk_x=sparse(zeros(length(Jql_ps123),nRxns));
solKO_ijk_f=sparse(zeros(length(Jql_ps123),1));
tic
parfor iRxn=1:length(Jql_ps123)
   [solKO_ijk_f(iRxn) solKO_ijk_x(iRxn,:)]=optMod(M2,Jql_ps123(iRxn,2:end),model,Jql_ps123(iRxn,1));
end

Jql_p=[];
Jql_p=zeros(100000000,4); %Some large value
k=0;
for i=1:length(Jql_ps123)
    delIdx_ijk=Jql_ps123(i,2:end); 

    newnnz=find(~eq(solKO_ijk_x(i,:),0))';
    Jnz_ijk=newnnz(~ismember(newnnz,[Jsl;eliIdx]));
 
        
    Jql_p(k+1:k+length(Jnz_ijk),:)=[delIdx_ijk([ones(length(Jnz_ijk),1) 2*(ones(length(Jnz_ijk),1)) 3*(ones(length(Jnz_ijk),1))]) Jnz_ijk];
    k=k+length(Jnz_ijk)+1;
    if k>length(Jql_p)
        warning('Code will run slower. To improve performance re-initialize the matrix Jql_p with larger matrix size in line 221.');
    end
end
Jql_p(k:end,:)=[];
Jql_p=unique(sort(Jql_p,2),'rows');
if sum(Jql_p(1,:))==0
    Jql_p(1,:)=[];
end

solKO_ijkl=zeros(length(Jql_p),1);
parfor i=1:length(Jql_p);
    [solKO_ijkl(i)]= optMod(modeldel,Jql_p(i,:),model);
end

Jql_size=sum(lt(solKO_ijkl,0.01*grWT));



Jql=Jql_p(find(lt(solKO_ijkl,0.01*grWT)),:);

temporary=[];
tttt=Jql;
uJdl=unique(Jdl);
dummy=0;

mm=0;
parfor iRxn=1:length(Jql)
dummy1=ismember(Jql(iRxn,:),uJdl);
dum=Jql(iRxn,:);
if sum(dummy1)>=2
    if max(sum(ismember(Jdl,nchoosek(dum(dummy1),2))'))<2
        temporary=[temporary;Jql(iRxn,:)];
        dummy=dummy+1;
    end
else
    temporary=[temporary;Jql(iRxn,:)];
end
end



Jql=temporary;

uJtl=unique(Jtl);
dummy=0;

temporary=[];
mm=0;
parfor iRxn=1:length(Jql)
dummy1=ismember(Jql(iRxn,:),uJtl);
dum=Jql(iRxn,:);
if sum(dummy1)>=3
    if max(sum(ismember(Jtl,nchoosek(dum(dummy1),3))'))<3
        temporary=[temporary;Jql(iRxn,:)];
        dummy=dummy+1;
    end
else
    temporary=[temporary;Jql(iRxn,:)];
end
end


Jql=temporary;

Jql_time=toc;

fprintf('\n Identified %d Synthetic Lethal Quadruplets in %d seconds...\n',length(Jql),Jql_time);
