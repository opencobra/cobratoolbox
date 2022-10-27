function [sgd,dgd,tgd,qgd] = parallelSL_Gene(model,cutoff)
%%  [Jsl,Jdl,Jtl,Jql] = parallelSL_Gene(model,cutoff,eliList,atpm)
% INPUT
% model (the following fields are required - others can be supplied)
%   S            Stoichiometric matrix
%   b            Right hand side = dx/dt
%   c            Objective coefficients
%   lb           Lower bounds
%   ub           Upper bounds
%   rxns         Reaction Names
%   genes        Gene Names
%   rules        Gene-Reaction Rules
%   rxnGenemat   reactions-gene matrix
%OPTIONAL
% cutoff         cutoff percentage value for lethality.Default is 0.01.
%
%OUTPUT
% sgd        Lethal single gene deletions identified;
% dgd        Lethal double gene deletions identified;
% tgd        Lethal triple gene deletions identified;
% qgd        Lethal quadruple gene deletions identified;
% Aditya Pratapa       3/23/15.
tic
if exist('cutoff', 'var')
    if isempty(cutoff)
        cutoff = 0.01;
    end
else
    cutoff = 0.01;
end




%fprintf('\n Initializing...\n');
[~,RuleIdx,UniqRuleIdx]=unique(model.rules); %Identify indices of unique rules
eliIdx=find(ismember(model.rules,''));  %Eliminate non-gene associated reactions
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

grWT=solution.objval;%Wildtype Growth Rate
solWT=solution; %Wildtype FBA Solution
Jnz=find(~eq(solWT.x,0)); %Set Jnz with non-zero fluxes in wildtype minimal norm solution

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

% Non-gene associated reactions can be eliminated for gene lethality
if (~isempty(eliIdx)) 
    Jnz=Jnz(~ismember(Jnz,eliIdx)); %Jnz after eliminating non-gene associated reactions
end

%Initialize Jsl, Jdl,Jtl

Jsl=[];
%fprintf('\n Done...\n');

Jnz_copy=Jnz;
Jsl_p=zeros(length(Jnz_copy),10000);
k=1;
while(length(Jnz_copy))~=0
    delIdx_i=Jnz_copy(1); %Index of ith reaction
    AssoRxns_i=find(ismember(UniqRuleIdx,UniqRuleIdx(delIdx_i))); %Reactions with same gene rules as ith reaction, which would be deleted upon deletion of ith reaction
    Jsl_p(k,1:length(AssoRxns_i))=AssoRxns_i;
    k=k+1;
    Jnz_copy=Jnz_copy(~ismember(Jnz_copy,AssoRxns_i));
end
Jsl_p=unique(Jsl_p,'rows');
Jsl_p(1,:)=[];
solKO_i=zeros(size(Jsl_p,1),1);

parfor iRxn=1:size(Jsl_p,1)
        [solKO_i(iRxn), ~]= optMod(modeldel,Jsl_p(iRxn,Jsl_p(iRxn,:)>0),model);
end
Jsl=Jsl_p(lt(solKO_i,cutoff*grWT),1);

Jnz_copy=[solKO_i(~lt(solKO_i,cutoff*grWT)) Jsl_p(~lt(solKO_i,cutoff*grWT),1)];


parfor iRxn=1:length(Jnz_copy)
%    [find(ismember(UniqRuleIdx,UniqRuleIdx(Jnz_copy(iRxn,2))));Jnz_copy(iRxn,1)]
   [solKO_i_f(iRxn) solKO_i_x(iRxn,:)]=optMod(M2,find(ismember(UniqRuleIdx,UniqRuleIdx(Jnz_copy(iRxn,2)))),model,Jnz_copy(iRxn,1));
end
%%
Jdl_p=[];
for i=1:length(Jnz_copy)
    delIdx_i=UniqRuleIdx(Jnz_copy(i,2));
    newnnz=find(~eq(solKO_i_x(i,:),0))';
    newnnz=unique(UniqRuleIdx(newnnz));
    Jnz_i=newnnz(~ismember(newnnz,[UniqRuleIdx(Jsl);UniqRuleIdx(eliIdx)]));
    if ~(isempty(Jnz_i))
    Jdl_p=[Jdl_p;(delIdx_i*(ones(length(Jnz_i),1))) Jnz_i];
    end
end
%%
Jdl_p=unique(sort(Jdl_p,2),'rows');

Jdl_p_ext=zeros(size(Jdl_p,1),1000);
for i=1:size(Jdl_p,1)
    AssoRxns_ij=find(ismember(UniqRuleIdx,[Jdl_p(i,:)]));
   Jdl_p_ext(i,1:length(AssoRxns_ij))=AssoRxns_ij;
end

solKO_ij=zeros(size(Jdl_p_ext,1),1);

parfor i=1:size(Jdl_p_ext,1)
    [solKO_ij(i),~]= optMod(modeldel,Jdl_p_ext(i,Jdl_p_ext(i,:)>0),model);
end
%%
Jdl=[];
nJdl=find(lt(solKO_ij,cutoff*grWT));
for i=1:length(nJdl)
temp=unique(UniqRuleIdx(Jdl_p_ext(nJdl(i),Jdl_p_ext(nJdl(i),:)>0)));
temp1=find(ismember(UniqRuleIdx,temp(1)));
temp2=find(ismember(UniqRuleIdx,temp(2)));
Jdl=[Jdl;[temp1(1) temp2(1)]];
end

Jdl=unique(sort(Jdl,2),'rows');
%%

Jtl=[];
Jtl_p12=[solKO_ij(~lt(solKO_ij,cutoff*grWT)) Jdl_p(~lt(solKO_ij,cutoff*grWT),:)];

parfor iRxn=1:length(Jtl_p12)
   [solKO_ij_f(iRxn) solKO_ij_x(iRxn,:)]=optMod(M2,find(ismember(UniqRuleIdx,Jtl_p12(iRxn,2:end))),model,Jtl_p12(iRxn,1));
end
%%
Jtl_p=zeros(1000000,3);
k=0;
for i=1:length(Jtl_p12)
    delIdx_ij=Jtl_p12(i,2:end);
    newnnz=find(~eq(solKO_ij_x(i,:),0))';
    newnnz=unique(UniqRuleIdx(newnnz));
    Jnz_ij=newnnz(~ismember(newnnz,[UniqRuleIdx(Jsl);UniqRuleIdx(eliIdx)]));
    if ~(isempty(Jnz_ij))
    Jtl_p(k+1:k+length(Jnz_ij),:)=[delIdx_ij([ones(length(Jnz_ij),1) 2*ones(length(Jnz_ij),1)]) Jnz_ij];
    k=k+length(Jnz_ij);
    end
end


Jtl_p=unique(sort(Jtl_p,2),'rows');
if sum(Jtl_p(1,:))==0
    Jtl_p(1,:)=[];
end

%%
Jtl_p_ext=zeros(size(Jtl_p,1),1000);
for i=1:size(Jtl_p,1)
    AssoRxns_ijk=find(ismember(UniqRuleIdx,[Jtl_p(i,:)]));
   Jtl_p_ext(i,1:length(AssoRxns_ijk))=AssoRxns_ijk;
end

solKO_ijk=zeros(size(Jtl_p_ext,1),1);
parfor i=1:size(Jtl_p_ext,1)
    [solKO_ijk(i)]= optMod(modeldel,Jtl_p_ext(i,Jtl_p_ext(i,:)>0),model);
end

Jtl_size=sum(lt(solKO_ijk,cutoff*grWT));

Jtl=[];
nJtl=find(lt(solKO_ijk,cutoff*grWT));
for i=1:length(nJtl)
temp=Jtl_p(nJtl(i),:);
temp1=find(ismember(UniqRuleIdx,temp(1)));
temp2=find(ismember(UniqRuleIdx,temp(2)));
temp3=find(ismember(UniqRuleIdx,temp(3)));
Jtl=[Jtl;[temp1(1) temp2(1) temp3(1)]];
end

Jtl=unique(sort(Jtl,2),'rows');

Jtl=unique(sort(Jtl,2),'rows');
temporary=[];
tttt=Jtl;
uJdl=unique(Jdl);
dummy=0;

mm=0;
parfor iRxn=1:length(Jtl)
dummy1=ismember(Jtl(iRxn,:),uJdl);
dum=Jtl(iRxn,:);
if sum(dummy1)>=2
    if max(sum(ismember(Jdl,nchoosek(dum(dummy1),2))'))<2
        temporary=[temporary;Jtl(iRxn,:)];
        dummy=dummy+1;
    end
else
    temporary=[temporary;Jtl(iRxn,:)];
end
end
Jtl=temporary;


Jql_p123=[];
Jql_p123=[solKO_ijk(~lt(solKO_ijk,cutoff*grWT)) Jtl_p(find(~lt(solKO_ijk,cutoff*grWT)),:)];
%%
parfor iRxn=1:length(Jql_p123)
   [solKO_ijk_f(iRxn) solKO_ijk_x(iRxn,:)]=optMod(M2,find(ismember(UniqRuleIdx,Jql_p123(iRxn,2:end))),model,Jql_p123(iRxn,1));
end
%%
Jql_p=zeros(100000000,4);
k=0;
for i=1:length(Jql_p123)
    delIdx_ijk=Jql_p123(i,2:end);
    newnnz=find(~eq(solKO_ijk_x(i,:),0))';
    newnnz=unique(UniqRuleIdx(newnnz));
    Jnz_ijk=newnnz(~ismember(newnnz,[UniqRuleIdx(Jsl);UniqRuleIdx(eliIdx)]));
    if ~(isempty(Jnz_ijk))
    Jql_p(k+1:k+length(Jnz_ijk),:)=[delIdx_ijk([ones(length(Jnz_ijk),1) 2*ones(length(Jnz_ijk),1) 3*ones(length(Jnz_ijk),1)]) Jnz_ijk];
    k=k+length(Jnz_ijk);
    end
end
%%

Jql_p=unique(sort(Jql_p,2),'rows');
%%
if sum(Jql_p(1,:))==0
    Jql_p(1,:)=[];
end
clear solKO_ijk_f solKO_ijk_x
%%
Jql_p_ext=sparse(zeros(size(Jql_p,1),1000));

parfor i=1:size(Jql_p,1)
    AssoRxns_ijkl=find(ismember(UniqRuleIdx,[Jql_p(i,:)]));
    Jql_p_ext(i,:)=[AssoRxns_ijkl;zeros(1000-length(AssoRxns_ijkl),1)]';
end
%%
solKO_ijkl=zeros(size(Jql_p,1),1);
parfor i=1:size(Jql_p,1)
    [solKO_ijkl(i)]= optMod(modeldel,find(ismember(UniqRuleIdx,[Jql_p(i,:)])),model);
end
Jql_size=sum(lt(solKO_ijkl,cutoff*grWT));



Jql=[];
nJql=find(lt(solKO_ijkl,cutoff*grWT));
for i=1:length(nJql)
temp=Jql_p(nJql(i),:);
temp1=find(ismember(UniqRuleIdx,temp(1)));
temp2=find(ismember(UniqRuleIdx,temp(2)));
temp3=find(ismember(UniqRuleIdx,temp(3)));
temp4=find(ismember(UniqRuleIdx,temp(4)));
Jql=[Jql;[temp1(1) temp2(1) temp3(1) temp4(1)]];
end
Jql=unique(sort(Jql,2),'rows');


  

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

Qgd_time=toc;
[sgd,dgd,tgd,qgd]=g_from_r_4g(model,Jsl,Jdl,Jtl,Jql);

fprintf('\n Identified %d Synthetic Lethal Quadruplets in %d seconds...\n',length(qgd),Qgd_time);

end