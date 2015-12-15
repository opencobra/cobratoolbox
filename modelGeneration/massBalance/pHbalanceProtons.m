function model=pHbalanceProtons(model,massImbalance)
% Mass balance protons for each reaction by adjusting the hydrogen ion stoichiometric coefficient.
%
% For each non transport reaction the proton stoichiometric coefficient for each
% reaction is given by the difference between the sum of the average number
% of protons bound by substrate reactants and the average number of protons
% bound by product reactants
%
% i.e. proton S_ij = sum(substrates(S_ij*aveHbound)) -
%                           sum(products(S_ij*aveHbound))
%
% For each transport reaction, model  transport across the membrane as three
% reactions, one where non-proton reactants convert into non-proton metabolites
% involved in one compartment,then in the other compartment, non-proton
% metabolites convert into non-proton reactants. In between is a reconstruction
% transport reaction which must be elementally balanced for H to begin
% with. We assume that the transporter involved has affinity only for a particular
% species of metabolite defined by the reconstrution.
%
% INPUT
% model.S
% model.mets
% model.SIntRxnBool             Boolean of internal reactions
% model.met(m).aveHbound        average number of bound hydrogen ions
% model.met(m).formula          average number of bound hydrogen ions
% model.met(m).charge           charge of metabolite species from
%                               reconstruction
%
% OPTIONAL INPUT
% massImbalance     nRxn x nElement matrix where massImbalance(i,j) is imbalance of        
%                   reaction i for element j. massImbalance(i,j)==0 if
%                   balanced for that element. The first column is assumed
%                   to correspond to H balancing.
%
% OUTPUT
% model.S                   Stoichiometric matrix balanced for protons where each row.
%                           corresponds to a reactant at specific pH.
%
% Ronan M. T. Fleming

if any(any(isnan(model.S)))
    error('NaN in S matrix before proton balancing.')
end

[nMet,nRxn]=size(model.S);

%first save the reconstructions stoichiometric matrix
model.Srecon = model.S;

if ~exist('massImbalance','var')
    massImBalancedBool=false(nRxn,1);
else
    massImBalancedBool=(sum(massImbalance(:,2:end)')')~=0;
end

%get the compartments of the model
numChar=1;
[allMetCompartments,uniqueMetCompartments]=getCompartment(model.mets,numChar);
nUniqueCompartments=length(uniqueMetCompartments);

A=sparse(nMet,nUniqueCompartments);
for m=1:nMet
    A(m,strcmp(allMetCompartments{m},uniqueMetCompartments))=1;
end

compartmentHindex=zeros(length(uniqueMetCompartments),1);
boolH=false(nMet,1);
%indices of protons in different uniqueMetCompartments
for p=1:length(uniqueMetCompartments)
    ind=find(strcmp(['h[' uniqueMetCompartments{p} ']'],model.mets)~=0);
    if ~isempty(ind)
        compartmentHindex(p)=ind;
        boolH(ind)=1;
    end
end

%get the data on number of hydrogens bound by each reactant
aveHbound=zeros(1,nMet);
reconstructionH=zeros(1,nMet);
metCharge=zeros(1,nMet);
firstMissing=1;
for m=1:nMet
    metCharge(m)    = model.met(m).charge;
    aveHbound(1,m)  = model.met(m).aveHbound;
    if strcmp(model.met(m).formula,'')
        if firstMissing
            warning('propper pH based balancing of protons requires a chemical formula for all metabolites')
            firstMissing=0;
        end
        reconstructionH(1,m)=NaN;
    else
        reconstructionH(1,m) = numAtomsOfElementInFormula(model.met(m).formula,'H');
    end
end

%check that canonical model is mass balanced
dH = (reconstructionH*model.S)';
unbalancedInternalBool = dH~=0 & model.SIntRxnBool;

if any(unbalancedInternalBool)
    if 0
        fprintf('%s\n','Unbalanced reconstruction reactions:')
        unbalancedInd=find(unbalancedInternalBool);
        for p=1:length(unbalancedInd)
            fprintf('\n%20s\t%s\n',model.rxns{unbalancedInd(p)},model.rxn(unbalancedInd(p)).equation);
        end
        error('Hydrogen unbalanced reconstruction reactions exist.')
    else
        warning('Hydrogen unbalanced reconstruction reactions exist!')
    end
end

%calculate the number of hydrogen atoms involved in each reaction
Spos=model.S;
Spos(model.S<0)=0;

%change in binding of Hydrogen ions which accompanies the conversion of
%reactant into reconstruction metabolite species
deltaHBound = aveHbound - reconstructionH;

fprintf('%s\n%s\n','Proton balancing of reactants.' ,'Assuming that transport reactions are specific to the metabolite species given in the reconstruction.')
%assign new proton stoichiometric coefficients depending on compartment
for n=1:nRxn
    if massImbalance(n,1)~=0
        warning('vonBertalanffy:pHbalanceProtons:OriginallyUnbalancedRxn', [model.rxns{n} ' reconstruction reaction not balanced for H to begin with']); % Changed from error to warning and added a message ID - Hulda
    end
    if strcmp('ACITL',model.rxns{n})
        %pause(eps)
    end

    %no change for biomass reaction or exchange reactions or imbalanced
    %reactions
    if model.SIntRxnBool(n) && ~massImBalancedBool(n)
        %dont change reaction if any one of the metabolites has a NaN for
        %standard Gibbs energy of formation and therefore NaN for the
        %average number of H bound
        if ~any(isnan(aveHbound(model.S(:,n)~=0)))
            if 0 %debugging
                disp(model.rxns{n})
                disp(model.rxn(n).equation)
            end
            %no change if only protons involved in a reaction
            if any(model.S(:,n)~=0 & ~boolH)
                
                %uniqueMetCompartments of all metabolites involved in reactions
                metCompartments = allMetCompartments(model.S(:,n)~=0);
                rxnUniqueMetCompartments=unique(metCompartments);
                
                %uniqueMetCompartments of non-proton metabolites involved in reactions
                metCompartmentsNotH = allMetCompartments(model.S(:,n)~=0 & ~boolH);
                uniqueCompartmentsNotH=unique(metCompartmentsNotH);
                
                if length(rxnUniqueMetCompartments)>length(uniqueCompartmentsNotH)
                    %proton transport across a membrane driving a reaction
                    %make any necessary change to the proton stoichiometric
                    %coefficient on the side with the rest of the
                    %metabolites
                    % e.g. abbreviation: 'ATPS4r'
                    %      officialName: 'ATP synthase (four protons for one ATP)'
                    %      equation: 'adp[c] + 4 h[e] + pi[c]  <=> atp[c] + h2o[c] + 3 h[c] '
                    
                    %assumes the reconstruction transport reaction is elementally balanced for H
                    compartBool = strcmp(uniqueCompartmentsNotH{1},allMetCompartments);
                    metRxnCompartBool = model.S(:,n)~=0 & compartBool & ~boolH;
%                     if 0
%                         model.mets(model.S(:,n)~=0)
%                         model.mets(metRxnCompartBool)
%                     end
%                     %index for H involved in compartment with reaction
%                     indexHRxn  = compartmentHindex(strcmp(uniqueCompartmentsNotH{1},uniqueMetCompartments));
                    
                    %find out if first index is substrate or product
                    %compartment
                    
%                     if sum(model.S(compartBool,n))<0
%                         spIndexCol=1;
%                         %if the hydrogen ion is a substrate, then store the number of 
%                         %hydrogen ions transported for the species reaction
%                         %before mass balancing for the reactant reaction
%                         netTransportZi(n,1)=-S(n,indexHRxn);
%                     else
%                         spIndexCol=2;
%                     end
%                     %save index of hydrogen ions for first compartment
%                     substrateProductIndexH(n,spIndexCol)=indexHRxn;
                    
                    %adjust the proton stoichiometric coefficient
                    model.S(indexHRxn,n) = model.S(indexHRxn,n)  - deltaHBound(metRxnCompartBool)*model.S(metRxnCompartBool,n);

%                     %index for H involved in compartment with reaction
%                     indexHRxn  = compartmentHindex(strcmp(uniqueCompartmentsNotH{1},uniqueMetCompartments));
% 
%                     %second index must be for opposite column of first
%                     if spIndexCol==1
%                         spIndexCol=2;
%                     else
%                         spIndexCol=1;
% %                         %if the hydrogen ion is a substrate, then store the number of
% %                         %hydrogen ions transported for the species reaction
% %                         %before mass balancing for the reactant reaction
% %                         netTransportZi(n,1)=-model.S(n,indexHRxn);
%                     end
%                     %save index of hydrogen ions for second compartment
%                     substrateProductIndexH(n,spIndexCol)=indexHRxn;
                else
                    %check the number of unique uniqueMetCompartments involving non
                    %proton metabolites
                    if length(uniqueCompartmentsNotH)==1
                        %reaction involves metabolites in one compartment only
                        indexHRxn  = compartmentHindex(strcmp(uniqueCompartmentsNotH{1},uniqueMetCompartments));
                        %proton stoichiometric coefficient set to balance
                        %protons with respect to average H bound by all other
                        %substrates and products
                        model.S(indexHRxn,n)= model.S(indexHRxn,n) - deltaHBound(~boolH)*model.S(~boolH,n);
                    else
                        %non-proton metabolites in two uniqueMetCompartments or more
                        if length(uniqueCompartmentsNotH)>2
                            error('More than two uniqueMetCompartments for a single reaction?!')
                        end
                        %model the transport across the membrane as three
                        %reactions, one where non-proton reactants convert
                        %into non-proton metabolites involved in one compartment,
                        %then in the other compartment, non-proton
                        %metabolites convert into non-proton reactants. In
                        %between is a reconstruction transport reaction which must be
                        %elementally balanced for H to begin with
                        %this assumes that the transporter involved has
                        %affinity only for a particular species of
                        %metabolite defined by the reconstrution.
                        
                        %first compartment
                        compartBool1 = strcmp(uniqueCompartmentsNotH{1},allMetCompartments);
                        %boolean for non-proton metabolites in first compartment
                        metCompartBool1 = model.S(:,n)~=0 & compartBool1 & ~boolH;
                        %index for stoichiometric coefficient of first compartment
                        indexHRxn1  = compartmentHindex(strcmp(uniqueCompartmentsNotH{1},uniqueMetCompartments));
                        
%                         %find out if first index is substrate or product
%                         %compartment
%                         if sum(model.S(compartBool1,n))<0
%                             spIndexCol=1;
%                         else
%                             spIndexCol=2;
%                         end
%                         %save index of hydrogen ion for first compartment
%                         substrateProductIndexH(n,spIndexCol)=indexHRxn1;
%                         
%                         %net charge transported from first to second compartment
%                         netTransportZi(n,1)=metCharge(compartBool1)*model.S(compartBool1,n);
%                         
%                         %TODO - need proper way to tell the order of uniqueMetCompartments
%                         if model.S(indexHRxn1,n)~=0
%                             if model.S(indexHRxn1,n)>0
%                                 warning('assuming it is a symport transport reaction - FIX')
%                                 netTransportZi(n,1)=-netTransportZi(n,1);
%                             end
%                         end
                        
                        %second compartment
                        compartBool2 = strcmp(uniqueCompartmentsNotH{2},allMetCompartments);
                        %boolean for non-proton metabolites in first compartment
                        metCompartBool2 = model.S(:,n)~=0 & compartBool2 & ~boolH;
                        %index for stoichiometric coefficient of first compartment
                        indexHRxn2  = compartmentHindex(strcmp(uniqueCompartmentsNotH{2},uniqueMetCompartments));
                        
%                         %second index must be for opposite column of first
%                         if spIndexCol==1
%                             spIndexCol=2;
%                         else
%                             spIndexCol=1;
%                         end                        
%                         %save index of hydrogen ion for second compartment
%                         substrateProductIndexH(n,spIndexCol)=indexHRxn2;
%                         
%                         if 1
%                             %net charge transported from second to first compartment
%                             netTransportZiReverse=metCharge(compartBool2)*model.S(compartBool2,n);
%                             if netTransportZiReverse~=netTransportZi(n,1)
%                                 error('Reconstruction reaction not charge balanced?');
%                             end
%                         end
                        
                        %mass balance reactant reactions
                        model.S(indexHRxn1,n)=model.S(indexHRxn1,n) - deltaHBound(metCompartBool1)*model.S(metCompartBool1,n);
                        model.S(indexHRxn2,n)=model.S(indexHRxn2,n) - deltaHBound(metCompartBool2)*model.S(metCompartBool2,n);

                        %pause(eps)
                    end
                end
            end
        end
        if aveHbound*model.S(:,n)>(eps*1e4)
            disp(model.rxns{n})
            disp(model.rxn(n).equation)
            disp(aveHbound*model.S(:,n))
            model.mets(model.S(:,n)~=0)'
            aveHbound(model.S(:,n)~=0)
            error(['Failure to proton balance. Reaction ' model.rxns{n} ', #' int2str(n)])
        end
        if any(isnan(model.S(:,n)))
            error('Detected NaN entries in model.S');
        end
    end
    if aveHbound*model.S(:,n)>(eps*1e4)
        if 1 %debugging
            disp(n)
            disp(model.rxns{n})
            disp(model.rxn(n).equation)
        end
        error(['Reaction ' model.rxns{n} ', #' int2str(n) ' not proton balanced. No thermodynamic data available to balance reaction.'])
    end
end
if any(any(isnan(model.S)))
    error('NaN in S matrix after proton balancing.')
end
