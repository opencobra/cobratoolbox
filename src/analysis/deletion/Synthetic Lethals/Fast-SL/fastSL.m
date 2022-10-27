function fastSL(model,cutoff,order,eliList,atpm)                                  
%% fastSL(model,cutoff,order,eliList,atpm)
% Requires the openCOBRA toolbox
% http://opencobra.sourceforge.net/openCOBRA/Welcome.html
% 
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
% order          Order of SLs required.Default order is 2. Max value 3.
% eliList        List of reactions to be ignored for lethality
% analysis:Exchange Reactions, ATPM etc.
% atpm           ATPM Reaction Id in model.rxns if other than 'ATPM'
% 
%
% Aditya Pratapa      6/26/14. 
%%
%initCobraToolbox
if exist('cutoff', 'var')
    if isempty(cutoff)
        cutoff = 0.01;
    end
else
    cutoff = 0.01;
end

if exist('order', 'var')
    if isempty(order)
        order = 2;
    else
        if (order>3)
        err = MException('ResultChk:OutOfRange', ...
        'Resulting value is outside expected range. Maximum value is 3.');
         throw(err)
        end
    end
else
    order = 2;
end


%Please change this according to your model
if exist('atpm', 'var')
    if isempty(atpm)
        atpm = 'ATPM'; %Reaction Id of ATP maintenance reaction- by default it takes 'ATPM'
    end
else
    atpm = 'ATPM';
end


if exist('eliList', 'var')
    if isempty(eliList)
        eliList = model.rxns(ismember(model.rxns,atpm)); %To eliminate ATPM.
    end
else
    eliList = model.rxns(ismember(model.rxns,atpm));
end

fname=strcat(model.description,'iAB_RBC_283.mat');


%%
%varx = open("iAB_RBC_283.mat");
switch order
    case 1
        [Jsl]=singleSL(model,cutoff,eliList,atpm);
       
        fprintf('\n Saving Single Lethal Reactions List...\n');
        save(fname,'Jsl');
        fprintf('Done. \n');
    case 2
        [Jsl,Jdl]=doubleSL(model,cutoff,eliList,atpm);
     
        fprintf('\n Saving Single and Double Lethal Reactions List...\n');
        save(fname,'Jsl');
        save(fname,'Jdl','-append');
        fprintf('Done. \n');
    case 3
        [Jsl,Jdl,Jtl]=tripleSL(model,cutoff,eliList,atpm);
      
        fprintf('\n Saving Single, Double and Triple Lethal Reactions List...\n');
        save(fname,'Jsl');
        save(fname,'Jdl','-append');
        save(fname,'Jtl','-append');
        fprintf('Done. \n');
end


%%
function [Jsl]=singleSL(model,cutoff,eliList,atpm)
% [Jsl]=singleSL(model,cutoff,eliList,atpm)
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
% atpm           ATPM Reaction Id in model.rxns if other than 'ATPM'
%OUTPUT
% Jsl            Single lethal reactions identified
% Aditya Pratapa       6/26/14. 

if exist('cutoff', 'var')
    if isempty(cutoff)
        cutoff = 0.01;
    end
else
    cutoff = 0.01;
end

if exist('atpm', 'var')
    if isempty(atpm)
        atpm = 'ATPM'; %Reaction Id of ATP maintenance reaction- by default it takes 'ATPM'
    end
else
    atpm = 'ATPM';
end



if exist('eliList', 'var')
    if isempty(eliList)
        eliList = model.rxns(ismember(model.rxns,atpm)); %To eliminate ATPM.
    end
else
        eliList = model.rxns(ismember(model.rxns,atpm));
end



Jsl=[];

%Step1 Identify Single Lethal Reactions...
%Identify minNorm flux distribution
solWT=optimizeCbModel(model,'max','one');
grWT=solWT.f;
Jnz=find(~eq(solWT.x,0));
%vary = eliList;
if (~isempty(eliList))
    eliIdx = find(ismember(model.rxns,eliList)); %Index of reactions not considered for lethality analysis
    Jnz=Jnz(~ismember(Jnz,eliIdx)); %Jnz
end
h = waitbar(0,'0.00','Name','Identifying Jsl...');

%Identify Single Lethal Reaction Deletions...
    modeldel=model;
for iRxn=1:length(Jnz)
    delIdx_i=Jnz(iRxn);
    modeldel.lb(delIdx_i)=0;modeldel.ub(delIdx_i)=0;
    solKO_i=optimizeCbModel(modeldel);
    if (solKO_i.f<cutoff*grWT || isnan(solKO_i.f))
        Jsl=[Jsl;delIdx_i];
    end
   %Reset bounds on idx reaction
    modeldel.lb(delIdx_i)=model.lb(delIdx_i);
    modeldel.ub(delIdx_i)=model.ub(delIdx_i);
    waitbar(iRxn/length(Jnz),h,[num2str(round(iRxn*100/length(Jnz))) '% completed...']);

end
close(h);
Jsl=model.rxns(Jsl);
end
%%
function [Jsl,Jdl]=doubleSL(model,cutoff,eliList,~)
% [Jsl,Jdl]=doubleSL(model,cutoff,eliList,atpm)
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
%%
function [Jsl,Jdl,Jtl]=tripleSL(model,cutoff,eliList,atpm)
%  [slist_id,dlist_id,tlist_id]=tripleSL(model,cutoff,eliList,atpm)
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
% Aditya Pratapa       7/1/14.
%%

if exist('cutoff', 'var')
    if isempty(cutoff)
        cutoff = 0.01;
    end
else
    cutoff = 0.01;
end


if exist('atpm', 'var')
    if isempty(atpm)
        atpm = 'ATPM'; %Reaction Id of ATP maintenance reaction- by default it takes 'ATPM'
    end
else
    atpm = 'ATPM';
end



if exist('eliList', 'var')
    if isempty(eliList)
        eliList = model.rxns(ismember(model.rxns,atpm)); %To eliminate ATPM.
    end
else
    eliList = model.rxns(ismember(model.rxns,atpm));
end

%Wildtype FBA solution

solWT=optimizeCbModel(model,'max','one');
grWT=solWT.f;
Jnz=find(~eq(solWT.x,0));
%If a list of reactions for which are eliminated for lethality is given often exchange reactions are not considered
if (~isempty(eliList))
    eliIdx = find(ismember(model.rxns,eliList));
    Jnz_copy=Jnz(~ismember(Jnz,eliIdx)); %Jnz
end

Jsl=singleSL(model,cutoff,eliList);
Jsl=find(ismember(model.rxns,Jsl));
Jnz_copy=Jnz_copy(~ismember(Jnz_copy,Jsl)); %Eliminate Single lethal reaction deletions for enumeration of higher order lethals

Jdl=[];
Jtl=[];
%%

h = waitbar(0,'0.00','Name','Identifying Jdl & Jtl - Part 1 of 2...');
modeldel=model;

for iRxn=1:length(Jnz_copy)
    delIdx_i=Jnz_copy(iRxn);
    modeldel.lb(delIdx_i)=0; modeldel.ub(delIdx_i)=0;
    solKO_i=optimizeCbModel(modeldel,'max','one'); %It can't be a single lethal so we can proceed further
    Jnz_i=find(~eq(solKO_i.x,0));
    Jnz_i=Jnz_i(~ismember(Jnz_i,Jnz));
    
    if (~isempty(eliList))
        Jnz_i=Jnz_i(~ismember(Jnz_i,eliIdx)); %Eliminate Exchange and ATP Maintenance reactions
    end
    
    for jRxn=1:length(Jnz_i)
            delIdx_j=Jnz_i(jRxn);
            modeldel.lb(delIdx_j)=0;modeldel.ub(delIdx_j)=0;
            solKO_ij=optimizeCbModel(modeldel,'max','one');
            if (solKO_ij.f<cutoff*grWT && ~eq(solKO_ij.stat,0)) 
                Jdl=[Jdl;delIdx_i delIdx_j];
            else
                  if eq(solKO_ij.stat,0)
                    solKO_ij=optimizeCbModel(modeldel);
                    if (solKO_ij.f<cutoff*grWT || isnan(solKO_ij.f)) 
                        Jdl=[Jdl;delIdx_i delIdx_j];
                        modeldel.lb(delIdx_j)=model.lb(delIdx_j);
                        modeldel.ub(delIdx_j)=model.ub(delIdx_j);
                        continue;
                    end
                end
                Jnz_ij=find(~eq(solKO_ij.x,0));
                Jnz_ij=Jnz_ij(~ismember(Jnz_ij,Jnz));
                
                if (~isempty(eliList))
                    Jnz_ij=Jnz_ij(~ismember(Jnz_ij,eliIdx)); %Eliminate Exchange and ATPM reactions
                end
                
                for kRxn=1:length(Jnz_ij)           
                    
                    delIdx_k=Jnz_ij(kRxn);
                    modeldel.lb(delIdx_k)=0;modeldel.ub(delIdx_k)=0;
                    solKO_ijk=optimizeCbModel(modeldel);
                    if (solKO_ijk.f<cutoff*grWT || isnan(solKO_ijk.f))
                        Jtl=[Jtl;delIdx_i delIdx_j delIdx_k];
                    end
                    
                    modeldel.lb(delIdx_k)=model.lb(delIdx_k);
                    modeldel.ub(delIdx_k)=model.ub(delIdx_k);
                    
                end
            end
            modeldel.lb(delIdx_j)=model.lb(delIdx_j);
            modeldel.ub(delIdx_j)=model.ub(delIdx_j);
       
    end
    
    modeldel.lb(delIdx_i)=model.lb(delIdx_i);
    modeldel.ub(delIdx_i)=model.ub(delIdx_i);
    waitbar(iRxn/length(Jnz_copy),h,[num2str(round(iRxn*100/length(Jnz_copy))) '% completed...']);

end
close(h);

%%
h = waitbar(0,'0.00','Name','Identifying Jdl & Jtl - Part 2 of 2...');

for iRxn=1:length(Jnz_copy)
    for jRxn=1:length(Jnz_copy)
        if (jRxn<iRxn)
            modeldel=model;
            delIdx_i=Jnz_copy(iRxn);
            delIdx_j=Jnz_copy(jRxn);
            modeldel.lb(delIdx_i)=0;modeldel.ub(delIdx_i)=0;
            modeldel.lb(delIdx_j)=0;modeldel.ub(delIdx_j)=0;
            solKO_ij=optimizeCbModel(modeldel,'max','one');
            if (solKO_ij.f<cutoff*grWT && ~eq(solKO_ij.stat,0))
                Jdl=[Jdl;delIdx_i delIdx_j];
            else
                  if eq(solKO_ij.stat,0)
                    solKO_ij=optimizeCbModel(modeldel);
                    if (solKO_ij.f<cutoff*grWT || isnan(solKO_ij.f)) 
                        Jdl=[Jdl;delIdx_i delIdx_j];
                        modeldel.lb(delIdx_j)=model.lb(delIdx_j);
                        modeldel.ub(delIdx_j)=model.ub(delIdx_j);
                        continue;
                    end
                end
                Jnz_ij=find(~eq(solKO_ij.x,0));
                Jnz_ij=Jnz_ij(~ismember(Jnz_ij,Jnz));
                
                if (~isempty(eliList))
                    Jnz_ij=Jnz_ij(~ismember(Jnz_ij,eliIdx)); %Eliminate Exchange and ATPM reactions
                end
                
                for kRxn=1:length(Jnz_ij)
                    delIdx_k=Jnz_ij(kRxn);
                    modeldel.lb(delIdx_k)=0;modeldel.ub(delIdx_k)=0;
                    solKO_ijk=optimizeCbModel(modeldel);
                    if (solKO_ijk.f<cutoff*grWT || isnan(solKO_ijk.f))
                        Jtl=[Jtl;delIdx_i delIdx_j delIdx_k];
                    end
                    
                    modeldel.lb(delIdx_k)=model.lb(delIdx_k);
                    modeldel.ub(delIdx_k)=model.ub(delIdx_k);
                    
                end
                
                for kRxn=1:length(Jnz_copy)
                    
                    if (kRxn<jRxn)
                        delIdx_k=Jnz_copy(kRxn);
                        modeldel.lb(delIdx_k)=0;modeldel.ub(delIdx_k)=0;
                        solKO_ijk=optimizeCbModel(modeldel);
                        if (solKO_ijk.f<cutoff*grWT ||isnan(solKO_ijk.f))
                            Jtl=[Jtl;delIdx_i delIdx_j delIdx_k ];
                        end
                        
                        modeldel.lb(delIdx_k)=model.lb(delIdx_k);
                        modeldel.ub(delIdx_k)=model.ub(delIdx_k);
                        
                    else
                        break;
                    end
                end
            end
            modeldel.lb(delIdx_j)=model.lb(delIdx_j);
            modeldel.ub(delIdx_j)=model.ub(delIdx_j);
        else
            break;
        end
        
    end
    modeldel.lb(delIdx_i)=model.lb(delIdx_i);
    modeldel.ub(delIdx_i)=model.ub(delIdx_i);
    waitbar(iRxn*(iRxn-1)*(iRxn-2)/(length(Jnz_copy)*(length(Jnz_copy)-1)*(length(Jnz_copy)-2)),h,[num2str(round(iRxn*(iRxn-1)*(iRxn-2)*100/(length(Jnz_copy)*(length(Jnz_copy)-1)*(length(Jnz_copy)-2)))) '% completed...']);

end
close(h);

%Eliminate double lethal reaction deletions in triple lethal reactions
temporary=[];
g=zeros(1,length(Jdl));
for iRxn=1:length(Jtl)
    for jRxn=1:length(Jdl)
        g(jRxn)=sum(ismember(Jtl(iRxn,:),Jdl(jRxn,:)));
        if g(jRxn)>=2
            break;
        end
    end
    if max(g)<2
        temporary=[temporary;Jtl(iRxn,:)];
    end
end
Jtl=temporary;

%Eliminate duplicates in triple reaction deletions
Jtl=unique(sort(Jtl,2),'rows');



Jsl=model.rxns(Jsl);
Jdl=model.rxns(Jdl);
Jtl=model.rxns(Jtl);
end



end