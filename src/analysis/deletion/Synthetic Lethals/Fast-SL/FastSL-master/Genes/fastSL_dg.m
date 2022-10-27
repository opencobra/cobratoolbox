function [sgd,dgd]=fastSL_dg(model,cutoff,flag)
%% [sgd,dgd]=fastSL_dg(model,cutoff,flag)
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
% flag           set this to '1' for more exhaustive search for lethals,
%
%
%OUTPUT
% sgd        Lethal single gene deletions identified;
% dgd        Lethal double gene deletions identified;
%
% Aditya Pratapa       9/28/14.
%%
if exist('cutoff', 'var')
    if isempty(cutoff)
        cutoff = 0.01;
    end
else
    cutoff = 0.01;
end


if exist('flag', 'var')
    if isempty(flag)
        flag = 0;
    end
else
    flag = 0;
end
[~,~,UniqRuleIdx]=unique(model.rules);
eliIdx=find(ismember(UniqRuleIdx,UniqRuleIdx(1)));  %Eliminate non-gene associated reactions

solWT=optimizeCbModel(model,'max','one');
grWT=solWT.f;
Jnz=find(~eq(solWT.x,0));
if (~isempty(eliIdx))
    Jnz=Jnz(~ismember(Jnz,eliIdx)); %Jnz
end
Jsl=[];
Jdl=[];
genes_ex=zeros(100,100); %Gene sets for a more extensive evalution
gex_ind=1; 
%%
h = waitbar(0,'0.00','Name','Identifying Jdl - Part 1 of 2...');

modeldel=model;
Jnz_copy=Jnz;
while(length(Jnz_copy))~=0
    delIdx_i=Jnz_copy(1);
    AssoRxns_i=find(ismember(UniqRuleIdx,UniqRuleIdx(delIdx_i)));
    modeldel.lb(AssoRxns_i)=0;
    modeldel.ub(AssoRxns_i)=0;
    solKO_i=optimizeCbModel(modeldel,'max','one');
    if (solKO_i.f<cutoff*grWT || isnan(solKO_i.f))
        Jsl=[Jsl;delIdx_i];
    else
        Jnz_i=find(~eq(solKO_i.x,0));
        Jnz_i=Jnz_i(~ismember(Jnz_i,[Jnz;eliIdx;AssoRxns_i])); %Jnz,i-Jnz
        while(length(Jnz_i))~=0
            delIdx_j=Jnz_i(1);
            AssoRxns_j=find(ismember(UniqRuleIdx,UniqRuleIdx(delIdx_j)));
            modeldel.lb(AssoRxns_j)=0;
            modeldel.ub(AssoRxns_j)=0;
            solKO_ij=optimizeCbModel(modeldel,'max','one');
            if (solKO_ij.f<cutoff*grWT && ~eq(solKO_ij.stat,0))
                Jdl=[Jdl;delIdx_i delIdx_j];
            else
                if eq(solKO_ij.stat,0)
                    solKO_ij=optimizeCbModel(modeldel);
                    if (solKO_ij.f<cutoff*grWT || isnan(solKO_ij.f)) %Check if it is infeasible due to atpm violation
                        Jdl=[Jdl;delIdx_i delIdx_j];
                        modeldel.lb(AssoRxns_j)=model.lb(AssoRxns_j);
                        modeldel.ub(AssoRxns_j)=model.ub(AssoRxns_j);
                        Jnz_i=Jnz_i(~ismember(Jnz_i,AssoRxns_j));
                        continue;
                    end
                end
                potentialGeneSets=unique([find(model.rxnGeneMat(delIdx_i,:))';find(model.rxnGeneMat(delIdx_j,:))']);
                Jnz_ij=find(~eq(solKO_ij.x,0));
                if sum(sum(model.rxnGeneMat(unique(UniqRuleIdx(Jnz_ij)),potentialGeneSets)))>=2
                    genes_ex(gex_ind,1:length(unique(potentialGeneSets)))=unique(potentialGeneSets); %Gene sets for a more extensive evalution
                    gex_ind=gex_ind+1; 
                end
            end
            %Reset Bounds
            modeldel.lb(AssoRxns_j)=model.lb(AssoRxns_j); 
            modeldel.ub(AssoRxns_j)=model.ub(AssoRxns_j);
            %Eliminate already evaluated pairs
            Jnz_i=Jnz_i(~ismember(Jnz_i,AssoRxns_j)); 
        end
    end
    %Reset bounds
    modeldel.lb(AssoRxns_i)=model.lb(AssoRxns_i);
    modeldel.ub(AssoRxns_i)=model.ub(AssoRxns_i);
    %To eliminate already evaluated reactions
    Jnz_copy=Jnz_copy(~ismember(Jnz_copy,AssoRxns_i));

    waitbar(((length(Jnz)-length(Jnz_copy))/length(Jnz)),h,[num2str(round((length(Jnz)-length(Jnz_copy))*100/length(Jnz))) '% completed...']);
end
close(h)

%% Second phase of simulations which evalute other triplets with combinations of reactions from Jnz too
h = waitbar(0,'0.00','Name','Identifying Jdl - Part 2 of 2...');

ph2=find(ismember(UniqRuleIdx,UniqRuleIdx([Jsl;Jdl(:,2)]))); 
Jnz_ph2=Jnz(~ismember(Jnz,ph2)); %Jnz
%length(Jnz_ph2)

modeldel=model;

for i=1:length(Jnz_ph2)
     for j=1:length(Jnz_ph2)
        if (j<i)
            delIdx_i=Jnz_ph2(i);
            delIdx_j=Jnz_ph2(j);
            
            AssoRxns_i=find(ismember(UniqRuleIdx,UniqRuleIdx(delIdx_i)));
            AssoRxns_j=find(ismember(UniqRuleIdx,UniqRuleIdx(delIdx_j)));
            
            modeldel.lb(AssoRxns_i)=0;
            modeldel.ub(AssoRxns_i)=0;
            modeldel.lb(AssoRxns_j)=0;
            modeldel.ub(AssoRxns_j)=0;
            
            solKO_ij=optimizeCbModel(modeldel);
            if (solKO_ij.f<cutoff*grWT || isnan(solKO_ij.f)) %Check if it is infeasible due to atpm violation
                Jdl=[Jdl;delIdx_i delIdx_j];
            end
            
            modeldel.lb(AssoRxns_i)=model.lb(AssoRxns_i);
            modeldel.ub(AssoRxns_i)=model.ub(AssoRxns_i);
            modeldel.lb(AssoRxns_j)=model.lb(AssoRxns_j);
            modeldel.ub(AssoRxns_j)=model.ub(AssoRxns_j);
            
        else
            break;
        end
        
    end
    genes_ex=unique(genes_ex,'rows');
    gex_ind=length(genes_ex)+1;
    waitbar((i/length(Jnz_ph2)),h,[num2str(round(i*100/length(Jnz_ph2))) '% completed...']);

end
close(h);

%%
fprintf('\n Mapping to lethal genes ...');
[sgd,dgd]=g_from_r(model,Jsl,Jdl);

% Eliminate duplicates in dgd
temp=[];
g=zeros(1,length(sgd));
for i=1:length(dgd)
    for j=1:length(sgd)
        g(j)=sum(ismember(dgd(i,:),sgd(j)));
        if g(j)>=1
            break;
        end
    end
    if max(g)<1
        temp=[temp;dgd(i,:)];
    end
end

dgd=temp;
%%
if (flag==1)
    sgd1=[]; 
    
    genes_ex=unique(genes_ex,'rows');
    possiblesgd=find(sum(unique(model.rxnGeneMat,'rows'))>3);
    possiblesgd=possiblesgd(~ismember(possiblesgd,sgd));
    k=[];
    for i=1:length(possiblesgd)
        solKO_i=optimizeCbModel(deleteModelGenes(model,model.genes(possiblesgd(i))));
        if (solKO_i.f < cutoff*grWT)|| isnan(solKO_i.f)
            sgd1=[sgd1;possiblesgd(i)];
        end
    end
    
    sgd=[sgd;sgd1(~ismember(sgd1,sgd))];
    [m,n]=size(genes_ex);
    Gene_combinations=[];
    for i=1:m 
        gene_i=genes_ex(i,genes_ex(i,:)>0);
        gene_i=gene_i(~ismember(gene_i,sgd));
        if (length(gene_i) > 2)
            Gene_combinations=[Gene_combinations;nchoosek(gene_i,2)];
        end
    end
    Gene_combinations=unique(Gene_combinations,'rows');
    h = waitbar(0,'Final checks in progress ...');

%    length(Gene_combinations);
    
    for i=1:length(Gene_combinations)
        waitbar(i/length(Gene_combinations),h);
        [modeldel,hasEffect,ids]=deleteModelGenes(model,model.genes(Gene_combinations(i,:)));
        ids=find(ismember(model.rxns,ids));
        if ~isempty(ids) && sum(ismember(ids,Jnz))>=0
            k=optimizeCbModel(modeldel);
            g(i)=k.f;
        else
            g(i)=10000; %A random large value
        end
    end
    close(h);
    gd=Gene_combinations(find(lt(g,cutoff*grWT)),:);
if(~isempty(gd))
    dgd=[dgd;gd];
    dgd=unique(sort(dgd,2),'rows');
end
   % Eliminate duplicates
  
end

sgd=model.genes(sgd);
dgd=model.genes(dgd);
fprintf('\n Done...\n');

end

