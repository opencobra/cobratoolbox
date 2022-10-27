function [sgd]=fastSL_sg(model,cutoff)
%% [sgd]=fastSL_sg(model,cutoff)
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
% sgd        Lethal single gene deletins identified;
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

[~,~,UniqRuleIdx]=unique(model.rules);
eliIdx=find(ismember(UniqRuleIdx,UniqRuleIdx(1))); %Eliminate non-gene associated reactions

solWT=optimizeCbModel(model,'max','one');
grWT=solWT.f;
Jnz=find(~eq(solWT.x,0));
if (~isempty(eliIdx))
    Jnz_copy=Jnz(~ismember(Jnz,eliIdx)); %Jnz
end
Jsl=[];
x = true(size(model.genes));
sgd=[];
%%
h = waitbar(0,'0.00','Name','Identifying Jsl...');

modeldel=model;
while(length(Jnz_copy))~=0
    delIdx_i=Jnz_copy(1);
    AssoRxns_i=find(ismember(UniqRuleIdx,UniqRuleIdx(delIdx_i)));
    modeldel.lb(AssoRxns_i)=0;
    modeldel.ub(AssoRxns_i)=0;
    solKO_i=optimizeCbModel(modeldel);
    if (solKO_i.f<cutoff*grWT || isnan(solKO_i.f))
        Jsl=[Jsl;delIdx_i];
    end
    %Reset bounds
    modeldel.lb(AssoRxns_i)=model.lb(AssoRxns_i);
    modeldel.ub(AssoRxns_i)=model.ub(AssoRxns_i);
    Jnz_copy=Jnz_copy(~ismember(Jnz_copy,AssoRxns_i));
    waitbar(((length(Jnz)-length(Jnz_copy))/length(Jnz)),h,[num2str(round((length(Jnz)-length(Jnz_copy))*100/length(Jnz))) '% completed...']);

end
close(h);

%%
fprintf('\n Mapping lethal reactions to genes ...');
[sgd]=g_from_r(model,Jsl);


%%
possiblesgd=find(sum(unique(model.rxnGeneMat,'rows'))>1);
possiblesgd=possiblesgd(~ismember(possiblesgd,sgd));
k=[];
for iGene=1:length(possiblesgd)
    solKO_i=optimizeCbModel(deleteModelGenes(model,model.genes(possiblesgd(iGene))));
    if (solKO_i.f < 0.01*grWT)|| isnan(solKO_i.f)
        sgd=[sgd;possiblesgd(iGene)];
    end
end
sgd=unique(sgd);
sgd=model.genes(sgd);
fprintf('\n Done...');
end
