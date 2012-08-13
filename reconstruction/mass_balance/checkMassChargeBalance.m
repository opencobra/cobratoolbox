function [massImbalance,imBalancedMass,imBalancedCharge,imBalancedBool,Elements] = checkMassChargeBalance(model,rxnBool,printLevel)
%checkMassChargeBalance tests for a list of reactions if these reactions are
%mass-balanced by adding all elements on left hand side and comparing them
%with the sums of elements on the right hand side of the reaction.
%
% [UnbalancedRxns] = checkMassChargeBalance(model,RxnList)
%
%INPUT
% model                         COBRA model structure
%
%OPTIONAL INPUT
% rxnBool       Boolean vector corresponding to reactions in model to be
%               tested. If empty, then all tested.
%               Alternatively, can be the indices of reactions to test:
%               i.e. rxnBool(indixes)=1;
% printLevel    {-1,(0),1} 
%               -1 = print out diagnostics on problem reactions to a file 
%                0 = silent
%                1 = print out diagnostics on problem reactions to screen
%
%OUTPUTS
% massImbalance                 nRxn x nElement matrix with mass imblance
%                               for each element checked. 0 if balanced.
% imBalancedMass                nRxn x 1 cell with charge imbalance
%                               e.g. -3 H means three hydrogens disappear
%                               in the reaction.
% imBalancedCharge              nRxn x 1 vector with charge imbalance,
%                               empty if no imbalanced reactions
%
% imbalancedBool                boolean vector indicating imbalanced reactions
%       
% Elements                      nElement x 1 cell array of element
%                               abbreviations checked 
% Ines Thiele 12/09
% IT, 06/10, Corrected some bugs and improved speed.
% RF, 09/09/10, Support for very large models and printing to file.

[nMet,nRxn]=size(model.S);
if exist('rxnBool','var')
    if ~isempty(rxnBool)
        if length(rxnBool)~=nRxn
            rxnBool2=false(nRxn,1);
            rxnBool2(rxnBool)=1;
            rxnBool=rxnBool2;
        end
    else
        model=findSExRxnInd(model);
        %only check mass balance of internal reactions
        rxnBool=model.SIntRxnBool;
    end
else
    model=findSExRxnInd(model);
    %only check mass balance of internal reactions
    rxnBool=model.SIntRxnBool;
end
if ~exist('printLevel','var')
    printLevel=0;
end

% List of Elements
Elements = {'H','C', 'O', 'P', 'S', 'N', 'Mg','X','Fe','Zn','Co','R'};

E=sparse(nMet,length(Elements));
massImbalance=sparse(nRxn,length(Elements));
for j = 1 : length(Elements)
    if j==1
        [dE,E_el]=checkBalance(model,Elements{j},printLevel);
        massImbalance(:,j)=dE;
        E(:,j)=E_el;
        fprintf('%s\n',['Checked element ' Elements{j}]);  
    else
        %no need to print out for each element which metabolites have no
        %formula
        [massImbalance(:,j),E(:,j)]=checkBalance(model,Elements{j},0);
        fprintf('%s\n',['Checking element ' Elements{j}]);
    end
end
massImbalance(~rxnBool,:)=0;
imBalancedBool=sum(abs(massImbalance'))'~=0;

imBalancedBool=rxnBool & imBalancedBool;

imBalancedMass=cell(nRxn,1);
for i = 1 : nRxn
    imBalancedMass{i,1}='';   
    if imBalancedBool(i)
        for j = 1 : length(Elements)
            if massImbalance(i,j)~=0
                if ~strcmp(imBalancedMass{i,1},'')
                    imBalancedMass{i,1} = [imBalancedMass{i,1} ', ' int2str(massImbalance(i,j)) ' ' Elements{j}];
                else
                    imBalancedMass{i,1} = [int2str(massImbalance(i,j)) ' ' Elements{j}];
                end
            end
            
        end
        if strfind(imBalancedMass{i,1},'NaN')
            imBalancedMass{i,1}='NaN';
        end
    end
    if mod(i,1000)==0
        fprintf('%n\t%s\n',i,['reactions checked for ' Elements{j} ' balance']);
    end
end
if printLevel==-1
    firstMissing=0;
    for p=1:nRxn
        if ~strcmp(imBalancedMass{p,1},'')
            %at the moment, ignore reactions with a metabolite that have
            %no formula
            if ~strcmp(imBalancedMass{p,1},'NaN')
                if ~firstMissing
                    fid=fopen('mass_imbalanced_reactions.txt','w');
                    fprintf(fid,'%s;%s;%s;%s\n','#Rxn','rxnAbbr','imbalance','equation');

                    warning('There are mass imbalanced reactions, see mass_imbalanced_reactions.txt')
                    firstMissing=1;
                end
                equation=printRxnFormula(model,model.rxns(p),0);
                fprintf(fid,'%s;%s;%s;%s\n',int2str(p),model.rxns{p},imBalancedMass{p,1},equation{1});
                for m=1:size(model.S,1)
                    if model.S(m,p)~=0
                        fprintf(fid,'%s\t%s\t%s\t%s\t%s\n',int2str(m),model.mets{m},int2str(model.S(m,p)),int2str(E(m)),model.metFormulas{m});
                    end
                end
            end
        end
    end
    if firstMissing
        fclose(fid);
    end
end
if printLevel==1
    for p=1:nRxn
        if ~strcmp(imBalancedMass{p,1},'')
            %at the moment, ignore reactions with a metabolite that have
            %no formula
            if ~strcmp(imBalancedMass{p,1},'NaN')
                equation=printRxnFormula(model,model.rxns(p),0);
                fprintf('%6s\t%30s\t%10s\t%s\n',int2str(p),model.rxns{p},imBalancedMass{p,1},equation{1});
                if 0
                for m=1:size(model.S,1)
                    if model.S(m,p)~=0
                        fprintf(fid,'%s\t%s\t%s\t%s\t%s\n',int2str(m),model.mets{m},int2str(model.S(m,p)),int2str(E(m)),model.metFormulas{m});
                    end
                end
                end
            end
        end
    end
end

%
if nnz(strcmp('',imBalancedMass))==nRxn
    imBalancedMass=[];
end

% Check for charge balance
imBalancedCharge=[];
firstMissing=0;
if isfield(model, 'metCharges')
    for m=1:nMet
        if isnan(model.metCharges(m)) && ~isempty(model.metFormulas{m})
            if printLevel==1
                fprintf('%s\t%s\n',int2str(m),[model.mets{m} ' has no charge but has formula.'])
                if ~firstMissing
                    warning('model structure must contain model.metCharges field for each metabolite');
                end
                firstMissing=1;
            end
            if printLevel==-1
                if ~firstMissing
                    fid=fopen('metabolites_without_charge.txt','w');
                end
                firstMissing=1;
                fprintf(fid,'%s\t%s\n',int2str(m),model.mets{m})
            end
        else
            dC=model.S'*model.metCharges;
        end
    end
    if any(dC(rxnBool))~=0
        imBalancedCharge=dC;
        imBalancedCharge(~rxnBool)=0;
    else
        imBalancedCharge=[];
    end
end

if printLevel==-1
    firstMissing=0;
    if ~isempty(imBalancedCharge)
        for q=1:nRxn
            if model.SIntRxnBool(q) && dC(q)~=0 && strcmp(imBalancedMass{p,1},'')
                if ~firstMissing
                    fid=fopen('charge_imbalanced_reactions.txt','w');
                    warning('There are charged imbalanced reactions (that are mass balanced), see charge_imbalanced_reactions.txt')
                    firstMissing=1;
                end
                equation=printRxnFormula(model,model.rxns(q),0);
                fprintf(fid,'%s\t%s\t%s\n',int2str(q),model.rxns{q},equation{1});
                if 0
                    for m=1:size(model.S,1)
                        if model.S(m,q)~=0
                            fprintf(fid,'%s\t%15s\t%3s\t%3s\t%s\n',int2str(m),model.mets{m},int2str(model.S(m,q)),int2str(model.metCharges(m)),model.metFormulas{m});
                        end
                    end
                end
            end
        end
        if firstMissing
            fclose(fid);
        end
    end
end

if printLevel==1
    if ~isempty(imBalancedCharge)
        fprintf('%s\n','Mass balanced, but charged imbalanced reactions:')
        for q=1:nRxn
            if model.SIntRxnBool(q) && dC(q)~=0 && strcmp(imBalancedMass{p,1},'')
                equation=printRxnFormula(model,model.rxns(q),0);
                fprintf('%s\t%s\t%s\n',int2str(q),model.rxns{q},equation{1});
                if 1
                    for m=1:size(model.S,1)
                        if model.S(m,q)~=0
                            fprintf('%s\t%15s\t%3s\t%3s\t%s\n',int2str(m),model.mets{m},int2str(model.S(m,q)),int2str(model.metCharges(m)),model.metFormulas{m});
                        end
                    end
                end
            end
        end
    end
end

if ~isempty(imBalancedCharge)
    imBalancedBool = imBalancedBool |  imBalancedCharge~=0;
end





