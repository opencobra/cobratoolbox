function [Jsl,Jdl]=doubleSL(model,cutoff,eliList,atpm)
%% [Jsl,Jdl]=doubleSL(model,cutoff,eliList,atpm)
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
%
% Aditya Pratapa       6/26/14. 

if exist('cutoff', 'var')
    if isempty(cutoff)
        cutoff = 0.01;
    end
else
    cutoff = 0.01;
end

if exist('eliList', 'var')
    if isempty(eliList)
        eliList = model.rxns(ismember(model.rxns,'ATPM')); %To eliminate ATPM.
    end
else
    eliList = model.rxns(ismember(model.rxns,'ATPM'));
end

solWT=optimizeCbModel(model,'max','one');
grWT=solWT.f;
Jnz=find(~eq(solWT.x,0));
if (~isempty(eliList))
    eliIdx = find(ismember(model.rxns,eliList));
    Jnz=Jnz(~ismember(Jnz,eliIdx)); %Jnz
end

Jsl=singleSL(model,cutoff,eliList);
Jsl=find(ismember(model.rxns,Jsl));

Jnz_copy=Jnz(~ismember(Jnz,Jsl)); %Jnz-Jsl

Jdl=[];

%%
h = waitbar(0,'0.00','Name','Identifying Jdl - Part 1 of 2...');

modeldel=model;
for iRxn=1:length(Jnz_copy)
    
    delIdx_i=Jnz_copy(iRxn);
    modeldel.lb(delIdx_i)=0; modeldel.ub(delIdx_i)=0;
    solKO_i=optimizeCbModel(modeldel,'max','one');
    newnnz=find(~eq(solKO_i.x,0));
    Jnz_i=newnnz(~ismember(newnnz,Jnz));
    
    if (~isempty(eliList))
        Jnz_i=Jnz_i(~ismember(Jnz_i,eliIdx));
    end
    
    for jRxn=1:length(Jnz_i)
        delIdx_j=Jnz_i(jRxn);
        modeldel.lb(delIdx_j)=0;modeldel.ub(delIdx_j)=0;
        solKO_ij=optimizeCbModel(modeldel);
        if (solKO_ij.f<cutoff*grWT || isnan(solKO_ij.f))
            Jdl=[Jdl;delIdx_i delIdx_j];
        end
        %Reset bounds on idx1 reaction
        modeldel.lb(delIdx_j)=model.lb(delIdx_j);
        modeldel.ub(delIdx_j)=model.ub(delIdx_j);
    end
    %Reset bounds on idx reaction
    modeldel.lb(delIdx_i)=model.lb(delIdx_i);
    modeldel.ub(delIdx_i)=model.ub(delIdx_i);
    waitbar(iRxn/length(Jnz_copy),h,[num2str(round(iRxn*100/length(Jnz_copy))) '% completed...']);

end
close(h);

%%
h = waitbar(0,'0.00','Name','Identifying Jdl - Part 2 of 2...');

for iRxn=1:length(Jnz_copy)
    for jRxn=1:length(Jnz_copy)
        if (jRxn<iRxn)
            modeldel=model;
            delIdx_i=Jnz_copy(iRxn);
            delIdx_j=Jnz_copy(jRxn);
            modeldel.lb(delIdx_i)=0;modeldel.ub(delIdx_i)=0;modeldel.lb(delIdx_j)=0;modeldel.ub(delIdx_j)=0;
            solKO_ij=optimizeCbModel(modeldel);
            if (solKO_ij.f<cutoff*grWT || isnan(solKO_ij.f))
                Jdl=[Jdl;delIdx_i delIdx_j];
            end
        else
            break;
        end
    end
    waitbar(iRxn*(iRxn-1)/(length(Jnz_copy)*(length(Jnz_copy)-1)),h,[num2str(round(iRxn*(iRxn-1)*100/(length(Jnz_copy)*(length(Jnz_copy)-1)))) '% completed...']);

end
close(h);
Jsl=model.rxns(Jsl);
Jdl=model.rxns(Jdl);

fprintf('\n Done...');
end
