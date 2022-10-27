function [sgd,dgd,tgd]=fastSL_tg(model,cutoff,flag)
%%
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
% flag           set this to '1' for a more exhaustive search for lethals
%
%OUTPUT
% sgd        Lethal single gene deletions identified;
% dgd        Lethal double gene deletions identified;
% tgd        Lethal triple gene deletions identified;

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

fprintf('\n Initializing...\n');
[~,~,UniqRuleIdx]=unique(model.rules); %Identify indices of unique rules
eliIdx=find(ismember(UniqRuleIdx,UniqRuleIdx(1)));  %Eliminate non-gene associated reactions

solWT=optimizeCbModel(model,'max','one'); %Wildtype FBA Solution
grWT=solWT.f; %Wildtype Growth Rate
Jnz=find(~eq(solWT.x,0)); %Set Jnz with non-zero fluxes in wildtype minimal norm solution

% Non-gene associated reactions can be eliminated for gene lethality
if (~isempty(eliIdx)) 
    Jnz=Jnz(~ismember(Jnz,eliIdx)); %Jnz after eliminating non-gene associated reactions
end
%Initialize Jsl, Jdl,Jtl

Jsl=[];
Jdl=[];
Jtl=[];

genes_ex=zeros(100,100);
gex_ind=1;

fprintf('\n Done...\n');

h = waitbar(0,'0.00','Name','Identifying Jdl& Jtl - Part 1 of 2...');

modeldel=model; 
Jnz_copy=Jnz;
while(length(Jnz_copy))~=0
%    length(Jnz_copy)
    delIdx_i=Jnz_copy(1); %Index of ith reaction
    AssoRxns_i=find(ismember(UniqRuleIdx,UniqRuleIdx(delIdx_i))); %Reactions with same gene rules as ith reaction, which would be deleted upon deletion of ith reaction
    %Delete all reactions associated with ith reaction whose index is delIdx_i
    modeldel.lb(AssoRxns_i)=0; 
    modeldel.ub(AssoRxns_i)=0;

    solKO_i=optimizeCbModel(modeldel,'max','one'); %FBA solution after deletion
    
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
                    if (solKO_ij.f<cutoff*grWT || isnan(solKO_ij.f)) %Check if it is infeasibledue to atpm violation
                        Jdl=[Jdl;delIdx_i delIdx_j];
                        modeldel.lb(AssoRxns_j)=model.lb(AssoRxns_j);
                        modeldel.ub(AssoRxns_j)=model.ub(AssoRxns_j);
                        Jnz_i=Jnz_i(~ismember(Jnz_i,AssoRxns_j));
                        continue;
                    end
                  end
                Jnz_ij=find(~eq(solKO_ij.x,0));
                Jnz_ij_copy=Jnz;
                Jnz_ij=Jnz_ij(~ismember(Jnz_ij,[Jnz;eliIdx;AssoRxns_i;AssoRxns_j]));
%                 nnzfl1=nnzfl1(~ismember(nnzfl1,eliIdx));
%                 nnzfl1=nnzfl1(~ismember(nnzfl1,AssoRxns_i));
%                 nnzfl1=nnzfl1(~ismember(nnzfl1,AssoRxns_j));
                
                while(length(Jnz_ij))~=0
                    delIdx_k=Jnz_ij(1);
                    AssoRxns_k=find(ismember(UniqRuleIdx,UniqRuleIdx(delIdx_k)));
                    modeldel.lb(AssoRxns_k)=0;
                    modeldel.ub(AssoRxns_k)=0;
                    solKO_ijk=optimizeCbModel(modeldel,'max','one');
                    if (solKO_ijk.f<cutoff*grWT && ~eq(solKO_ijk.stat,0)) 
                        Jtl=[Jtl;delIdx_i delIdx_j delIdx_k];
                    else
                        if eq(solKO_ijk.stat,0)                          
                            solKO_ijk=optimizeCbModel(modeldel);
                            if (solKO_ijk.f<cutoff*grWT || isnan(solKO_ijk.f)) %Check if it is infeasible due to atpm violation
                                Jtl=[Jtl;delIdx_i delIdx_j delIdx_k];
                                modeldel.lb(AssoRxns_k)=model.lb(AssoRxns_k);
                                modeldel.ub(AssoRxns_k)=model.ub(AssoRxns_k);
                                Jnz_ij=Jnz_ij(~ismember(Jnz_ij,AssoRxns_k));
                                continue;
                            end
                        end
                        genesinv=unique([find(model.rxnGeneMat(delIdx_i,:))';find(model.rxnGeneMat(delIdx_j,:))';find(model.rxnGeneMat(delIdx_k,:))']);
                        Jnz_ijk=find(~eq(solKO_ijk.x,0));
                        Jnz_ijk=Jnz_ijk(~ismember(Jnz_ijk,Jnz_ij_copy));
                        if sum(sum(model.rxnGeneMat(unique(UniqRuleIdx(Jnz_ijk)),genesinv)))>=2
                            genes_ex(gex_ind,1:length(unique(genesinv)))=unique(genesinv);
                            gex_ind=gex_ind+1;
                        end
                    end
                    modeldel.lb(AssoRxns_k)=model.lb(AssoRxns_k);
                    modeldel.ub(AssoRxns_k)=model.ub(AssoRxns_k);
                    Jnz_ij=Jnz_ij(~ismember(Jnz_ij,AssoRxns_k));
                    genes_ex=unique(genes_ex,'rows');
                    gex_ind=length(genes_ex)+1;
                end
            end
            % Reset bounds
            modeldel.lb(AssoRxns_j)=model.lb(AssoRxns_j);
            modeldel.ub(AssoRxns_j)=model.ub(AssoRxns_j);
           % Eliminate already evaluated combinations
            Jnz_i=Jnz_i(~ismember(Jnz_i,AssoRxns_j));
          end
    end
    %Reset bounds
    modeldel.lb(AssoRxns_i)=model.lb(AssoRxns_i);
    modeldel.ub(AssoRxns_i)=model.ub(AssoRxns_i);
   % Eliminate already evaluated combinations
    Jnz_copy=Jnz_copy(~ismember(Jnz_copy,AssoRxns_i));
    
    waitbar(((length(Jnz)-length(Jnz_copy))/length(Jnz)),h,[num2str(round((length(Jnz)-length(Jnz_copy))*100/length(Jnz))) '% completed...']);
end
close(h);
ph2=find(ismember(UniqRuleIdx,UniqRuleIdx([Jsl;Jdl(:,2)])));
Jnz_ph2=Jnz(~ismember(Jnz,ph2)); %Jnz to analyze the rest of the triplets- phase 2
%%
h = waitbar(0,'0.00','Name','Identifying Jdl& Jtl - Part 2 of 2...');
length(Jnz_ph2);
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
                        continue;
                    end
                end
                Jnz_ij=find(~eq(solKO_ij.x,0));
                Jnz_ij_copy=Jnz_ij;

                Jnz_ij=Jnz_ij(~ismember(Jnz_ij,[Jnz;eliIdx;AssoRxns_i;AssoRxns_j]));

                
                while(length(Jnz_ij))~=0
                    delIdx_k=Jnz_ij(1);
                    AssoRxns_k=find(ismember(UniqRuleIdx,UniqRuleIdx(delIdx_k)));
                    modeldel.lb(AssoRxns_k)=0;
                    modeldel.ub(AssoRxns_k)=0;
                    solKO_ijk=optimizeCbModel(modeldel,'max','one');
                    if (solKO_ijk.f<cutoff*grWT && ~eq(solKO_ijk.stat,0))
                        Jtl=[Jtl;delIdx_i delIdx_j delIdx_k];
                    else
                        if eq(solKO_ijk.stat,0)
                            solKO_ijk=optimizeCbModel(modeldel);
                            if (solKO_ijk.f<cutoff*grWT || isnan(solKO_ijk.f)) %Check if it is infeasible due to atpm violation
                                Jtl=[Jtl;delIdx_i delIdx_j delIdx_k];
                                %Reset bounds
                                modeldel.lb(AssoRxns_k)=model.lb(AssoRxns_k);
                                modeldel.ub(AssoRxns_k)=model.ub(AssoRxns_k);
                               %Eliminate already evaluated combinations
                                Jnz_ij=Jnz_ij(~ismember(Jnz_ij,AssoRxns_k));
                                continue;
                            end
                        else
                            genesinv=unique([find(model.rxnGeneMat(delIdx_i,:))';find(model.rxnGeneMat(delIdx_j,:))';find(model.rxnGeneMat(delIdx_k,:))']);
                            Jnz_ijk=find(~eq(solKO_ijk.x,0));
                            Jnz_ijk=Jnz_ijk(~ismember(Jnz_ijk,Jnz_ij_copy));
                            if sum(sum(model.rxnGeneMat(unique(UniqRuleIdx(Jnz_ijk)),genesinv)))>=2
                                genes_ex(gex_ind,1:length(unique(genesinv)))=unique(genesinv);
                                gex_ind=gex_ind+1;
                            end
                            
                        end
                    end
                    % Reset Bounds
                    modeldel.lb(AssoRxns_k)=model.lb(AssoRxns_k);
                    modeldel.ub(AssoRxns_k)=model.ub(AssoRxns_k);
                   % Eliminate already evaluated combinations
                    Jnz_ij=Jnz_ij(~ismember(Jnz_ij,AssoRxns_k));
                    
                end
                
                
                for k=1:length(Jnz_ph2)
                    if(k<j)
                        delIdx_k=Jnz_ph2(k);
                        
                        AssoRxns_k=find(ismember(UniqRuleIdx,UniqRuleIdx(delIdx_k)));
                        modeldel.lb(AssoRxns_k)=0;
                        modeldel.ub(AssoRxns_k)=0;
                  
                        solKO_ijk=optimizeCbModel(modeldel,'max','one');
                        if (solKO_ijk.f<cutoff*grWT && ~eq(solKO_ijk.stat,0))
                            Jtl=[Jtl;delIdx_i delIdx_j delIdx_k];
                        else
                            if eq(solKO_ijk.stat,0)
                                solKO_ijk=optimizeCbModel(modeldel);
                                if (solKO_ijk.f<cutoff*grWT || isnan(solKO_ijk.f)) %Check if it is infeasible due to atpm violation
                                    Jtl=[Jtl;delIdx_i delIdx_j delIdx_k];
                                    modeldel.lb(AssoRxns_k)=model.lb(AssoRxns_k);
                                    modeldel.ub(AssoRxns_k)=model.ub(AssoRxns_k);                            
                                    continue;
                                end
                            end
                            genesinv=unique([find(model.rxnGeneMat(delIdx_i,:))';find(model.rxnGeneMat(delIdx_j,:))';find(model.rxnGeneMat(delIdx_k,:))']);
                            Jnz_ijk=find(~eq(solKO_ijk.x,0));
                            Jnz_ijk=Jnz_ijk(~ismember(Jnz_ijk,Jsl)); %not Jnz_ij as it could also be because of a reaction from the non-zero flux list
                             if sum(sum(model.rxnGeneMat(unique(UniqRuleIdx(Jnz_ijk)),genesinv)))>=2
                                genes_ex(gex_ind,1:length(unique(genesinv)))=unique(genesinv);
                                gex_ind=gex_ind+1;
                             end
                        end
                        %Reset Bounds
                        modeldel.lb(AssoRxns_k)=model.lb(AssoRxns_k);
                        modeldel.ub(AssoRxns_k)=model.ub(AssoRxns_k);
                    else
                        break;
                    end
                end
            end
            %Reset Bounds
            modeldel.lb(AssoRxns_j)=model.lb(AssoRxns_j);
            modeldel.ub(AssoRxns_j)=model.ub(AssoRxns_j);
            
        else
            break;
            
        end
    end   
    %Reset Bounds
            modeldel.lb(AssoRxns_i)=model.lb(AssoRxns_i);
            modeldel.ub(AssoRxns_i)=model.ub(AssoRxns_i);
    waitbar((i/length(Jnz_ph2)),h,[num2str(round(i*100/length(Jnz_ph2))) '% completed...']);
 end
close(h);
fprintf('\n Mapping lethal reactions to genes ...');
[sgd,dgd,tgd]=g_from_r(model,Jsl,Jdl,Jtl);
length(tgd)

%% For a more extensive enumeration of lethals(i.e., if the flag is set to 1)

if (flag==1)
    sgd1=[]; 
    tid=[];
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
            Gene_combinations=[Gene_combinations;nchoosek(gene_i,3)];
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
    
    %Eliminate already identified lethals

    clear g;
    for i=1:length(gd)
        for j=1:length(dgd)
            g(j)=sum(ismember(gd(i,:),dgd(j,:)));
            
            if g(j)>=2
                break;
            end
        end
        if max(g)<2
            tid=[tid;gd(i,:)];
        end
    end
    tgd=[tgd;tid];
   % Eliminate duplicates
    tgd=unique(sort(tgd,2),'rows');
end
sgd=model.genes(sgd);
dgd=model.genes(dgd);
tgd=model.genes(tgd);
fprintf('\n Done...\n');
end
