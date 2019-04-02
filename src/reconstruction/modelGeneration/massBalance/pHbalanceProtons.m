function model = pHbalanceProtons(model, massImbalance, printLevel, fileName)
% Mass balance protons for each reaction by adjusting the hydrogen ion stoichiometric coefficient.
%
% For each non transport reaction the proton stoichiometric coefficient for each
% reaction is given by the difference between the sum of the average number
% of protons bound by substrate reactants and the average number of protons
% bound by product reactants
%
% i.e. proton `S_ij = sum(substrates(S_ij*aveHbound)) - sum(products(S_ij*aveHbound))`
%
% For each transport reaction, model  transport across the membrane as three
% reactions, one where non-proton reactants convert into non-proton metabolites
% involved in one compartment,then in the other compartment, non-proton
% metabolites convert into non-proton reactants. In between is a reconstruction
% transport reaction which must be elementally balanced for `H` to begin
% with. We assume that the transporter involved has affinity only for a particular
% species of metabolite defined by the reconstrution.
%
% USAGE:
%
%    model = pHbalanceProtons(model, massImbalance, printLevel, fileName)
%
% INPUT:
%    model:            structure with fields:
%
%                        * model.S - stoichiometric matrix
%                        * model.mets - metabolites
%                        * model.SIntRxnBool - Boolean of internal reactions
%                        * model.aveHbound - average number of bound hydrogen ions
%                        * model.metFormulas - average number of bound hydrogen ions
%                        * model.metCharges - charge of metabolite species from reconstruction
%
% OPTIONAL INPUTS:
%    massImbalance:    `nRxn` x `nElement` matrix where `massImbalance(i,j)` is imbalance of
%                      reaction `i` for element `j`. `massImbalance(i,j) == 0` if
%                      balanced for that element. The first column is assumed
%                      to correspond to `H` balancing.
%    printLevel:       {(0), -2, -1, 0, 1, 2, 3) print more to file or more to the command window
%    fileName:         name of the file to print out to
%
% OUTPUT:
%    model:            structure containing:
%
%                        * .S - Stoichiometric matrix balanced for protons where each row.
%                          corresponds to a reactant at specific pH.
%                        * .Srecon - Stoichiometric matrix of the reconstruction
%
% .. Author: - Ronan M. T. Fleming

if ~exist('printLevel','var')
    printLevel=0;
end
if ~exist('massImbalance','var')
    massBalancedBool=true(nRxn,1);
else
    massBalancedBool=~any(massImbalance(:,2:end),2);
end
if printLevel<0
    if ~exist('fileName','var')
        fileName='pHbalanceProtons.txt';
    else
        fileName=[fileName 'pHbalanceProtons.txt'];
    end
end
if any(any(isnan(model.S)))
    error('NaN in S matrix before proton balancing.')
end

[nMet,nRxn]=size(model.S);

if isfield(model,'Srecon')
    %start with the stoichiometric matrix of the reconstruction in case
    %this function is run more than once, which would result in successive
    %changes to the stoichiometric matrix
    model.S = model.Srecon;
else
    %save the stoichiometric matrix of the reconstruction
    model.Srecon = model.S;
end

A=sparse(nMet,length(model.compartments));
for m=1:nMet
    A(m,strcmp(model.metComps{m},model.compartments))=1; %TODO streamline
end

compartmentHindex=zeros(length(model.compartments),1);
boolH=false(nMet,1);
%indices of protons in different model.compartments
for p=1:length(model.compartments)
    ind=find(strcmp(['h[' model.compartments{p} ']'],model.mets)~=0);
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
    metCharge(m)    = double(model.metCharges(m));
    aveHbound(1,m)  = model.aveHbound(m);
    if strcmp(model.metFormulas,'')
        if firstMissing
            warning('propper pH based balancing of protons requires a chemical formula for all metabolites')
            firstMissing=0;
        end
        reconstructionH(1,m)=NaN;
    else
        reconstructionH(1,m) = numAtomsOfElementInFormula(model.metFormulas{m},'H');
    end
end

%check that canonical model is hydrogen balanced
dH = (reconstructionH*model.S)';
unbalancedInternalBool = dH~=0 & model.SIntRxnBool;

if printLevel<0
    fid=fopen(fileName,'w');
end

if any(unbalancedInternalBool)
    % if printLevel>0
    %     fprintf('%s\n','Unbalanced reconstruction reactions:')
    % else
    %     if printLevel<0
    %         fprintf(fid,'%s\n','Unbalanced reconstruction reactions:')
    %     end
    % end
    % unbalancedInd=find(unbalancedInternalBool);
    % for p=1:length(unbalancedInd)
    %     if printLevel>0
    %         fprintf('\n%20s\t%s\n',model.rxns{unbalancedInd(p)},model.rxn(unbalancedInd(p)).equation);
    %     else
    %         if printLevel<0
    %             fprintf(fid,'\n%20s\t%s\n',model.rxns{unbalancedInd(p)},model.rxn(unbalancedInd(p)).equation);
    %         end
    %     end
    % end
    % error(['vonBertalanffy:pHbalanceProtons ' 'Hydrogen unbalanced reconstruction reactions exist.'])
    warning(['vonBertalanffy:pHbalanceProtons ''Hydrogen unbalanced reconstruction reactions exist!'])
end

%calculate the number of hydrogen atoms involved in each reaction
R=model.S;
R(model.S<0)=0;

%change in binding of Hydrogen ions which accompanies the conversion of
%reactant into reconstruction metabolite species
deltaHBound = aveHbound - reconstructionH;

if printLevel>0
    fprintf('%s\n%s\n','Proton balancing of reactants.' ,'Assuming that transport reactions are specific to the metabolite species given in the reconstruction.')
else
    if printLevel<0
        fprintf(fid,'%s\n%s\n','Proton balancing of reactants.' ,'Assuming that transport reactions are specific to the metabolite species given in the reconstruction.');
    end
end
%assign new proton stoichiometric coefficients depending on compartment
for n=1:nRxn
    if strcmp(model.rxns{n},'IDHPOXOX2b')
        pause(0.1);
    end
    %no change for biomass reaction or exchange reactions or imbalanced
    %reactions
    if model.SIntRxnBool(n)
        if massBalancedBool(n)
            %model.compartments of all metabolites involved in reactions
            metCompartments = model.metComps(model.S(:,n)~=0);
            rxnUniqueMetCompartments=unique(metCompartments);

            %dont change reaction if any one of the metabolites has a NaN for
            %standard Gibbs energy of formation and therefore NaN for the
            %average number of H bound
            if any(isnan(aveHbound(model.S(:,n)~=0)))
                if printLevel>0
                    if length(rxnUniqueMetCompartments)==1
                        if printLevel>0
                            fprintf('%15g\t%20s\t%s\t%s\t%s\n',NaN,model.rxns{n}, rxnUniqueMetCompartments{1},'','Not proton balanced - NaN aveHbound.')

                        else
                            if printLevel<0
                                fprintf(fid,'%15g\t%20s\t%s\t%s\t%s\n',NaN,model.rxns{n}, rxnUniqueMetCompartments{1},'','Not proton balanced - NaN aveHbound.');

                            end
                        end

                    else
                        if printLevel>0
                            fprintf('%15g\t%20s\t%s\t%s\t%s\n',NaN, rxnUniqueMetCompartments{1},rxnUniqueMetCompartments{2},'Not proton balanced - NaN aveHbound.')

                        else
                            if printLevel<0
                                fprintf(fid,'%15g\t%20s\t%s\t%s\t%s\n',NaN, rxnUniqueMetCompartments{1},rxnUniqueMetCompartments{2},'Not proton balanced - NaN aveHbound.');

                            end
                        end
                    end
                end
            else
                %no change if only protons involved in a reaction
                if any(model.S(:,n)~=0 & ~boolH)

                    %model.compartments of non-proton metabolites involved in reactions
                    metCompartmentsNotH = model.metComps(model.S(:,n)~=0 & ~boolH);
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
                        compartBool = strcmp(uniqueCompartmentsNotH{1},model.metComps);
                        metRxnCompartBool = model.S(:,n)~=0 & compartBool & ~boolH;
                        %                     if 0
                        %                         model.mets(model.S(:,n)~=0)
                        %                         model.mets(metRxnCompartBool)
                        %                     end
                        %                     %index for H involved in compartment with reaction
                        %                     indexHRxn  = compartmentHindex(strcmp(uniqueCompartmentsNotH{1},model.compartments));

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
                        %                     indexHRxn  = compartmentHindex(strcmp(uniqueCompartmentsNotH{1},model.compartments));
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
                        %check the number of unique model.compartments involving non
                        %proton metabolites
                        if length(uniqueCompartmentsNotH)==1
                            %reaction involves metabolites in one compartment only
                            indexHRxn  = compartmentHindex(strcmp(uniqueCompartmentsNotH{1},model.compartments));
                            %proton stoichiometric coefficient set to balance
                            %protons with respect to average H bound by all other
                            %substrates and products
                            model.S(indexHRxn,n)= model.S(indexHRxn,n) - deltaHBound(~boolH)*model.S(~boolH,n);
                        else
                            %non-proton metabolites in two model.compartments or more
                            if length(uniqueCompartmentsNotH)>2
                                error('More than two model.compartments for a single reaction?!')
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
                            compartBool1 = strcmp(uniqueCompartmentsNotH{1},model.metComps);
                            %boolean for non-proton metabolites in first compartment
                            metCompartBool1 = model.S(:,n)~=0 & compartBool1 & ~boolH;
                            %index for stoichiometric coefficient of first compartment
                            indexHRxn1  = compartmentHindex(strcmp(uniqueCompartmentsNotH{1},model.compartments));

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
                            %                         %TODO - need proper way to tell the order of model.compartments
                            %                         if model.S(indexHRxn1,n)~=0
                            %                             if model.S(indexHRxn1,n)>0
                            %                                 warning('assuming it is a symport transport reaction - FIX')
                            %                                 netTransportZi(n,1)=-netTransportZi(n,1);
                            %                             end
                            %                         end

                            %second compartment
                            compartBool2 = strcmp(uniqueCompartmentsNotH{2},model.metComps);
                            %boolean for non-proton metabolites in first compartment
                            metCompartBool2 = model.S(:,n)~=0 & compartBool2 & ~boolH;
                            %index for stoichiometric coefficient of first compartment
                            indexHRxn2  = compartmentHindex(strcmp(uniqueCompartmentsNotH{2},model.compartments));

                            %                         %second index must be for opposite column of first
                            %                         if spIndexCol==1
                            %                             spIndexCol=2;
                            %                         else
                            %                             spIndexCol=1;
                            %                         end
                            %                         %save index of hydrogen ion for second compartment
                            %                         substrateProductIndexH(n,spIndexCol)=indexHRxn2;
                            %
                            %                         %net charge transported from second to first compartment
                            %                         netTransportZiReverse=metCharge(compartBool2)*model.S(compartBool2,n);
                            %                         if netTransportZiReverse~=netTransportZi(n,1)
                            %                             error('Reconstruction reaction not charge balanced?');
                            %                         end

                            %mass balance reactant reactions
                            model.S(indexHRxn1,n)=model.S(indexHRxn1,n) - deltaHBound(metCompartBool1)*model.S(metCompartBool1,n);
                            model.S(indexHRxn2,n)=model.S(indexHRxn2,n) - deltaHBound(metCompartBool2)*model.S(metCompartBool2,n);
                        end
                    end
                end
            end

            if abs(aveHbound*model.S(:,n))>1e-6
                %if the initial reconstruction reaction unbalanced for protons
                %then the pHbalanced reaction will not

                if printLevel>0
                    if length(rxnUniqueMetCompartments)==1
                        fprintf('%u\t%15g\t%20s\t%s\t%s\t%s\n',unbalancedInternalBool(n),abs(aveHbound*model.S(:,n)),model.rxns{n}, rxnUniqueMetCompartments{1},'','Not proton balanced.')
                    else
                        fprintf('%u\t%15g\t%20s\t%s\t%s\t%s\n',unbalancedInternalBool(n),abs(aveHbound*model.S(:,n)),model.rxns{n}, rxnUniqueMetCompartments{1},rxnUniqueMetCompartments{2},'Not proton balanced.')
                    end
                else
                    if printLevel<0
                        if length(rxnUniqueMetCompartments)==1
                            fprintf(fid,'%u\t%15g\t%20s\t%s\t%s\t%s\n',unbalancedInternalBool(n),abs(aveHbound*model.S(:,n)),model.rxns{n}, rxnUniqueMetCompartments{1},'','Not proton balanced.');
                        else
                            fprintf(fid,'%u\t%15g\t%20s\t%s\t%s\t%s\n',unbalancedInternalBool(n),abs(aveHbound*model.S(:,n)),model.rxns{n}, rxnUniqueMetCompartments{1},rxnUniqueMetCompartments{2},'Not proton balanced.');
                        end
                    end
                end
                if printLevel>1 || ~unbalancedInternalBool(n)
                    rxnFormula=printRxnFormula(model,model.rxns{n},0);
                    fprintf('%s\n',rxnFormula{1});
                end
                if printLevel>2 || ~unbalancedInternalBool(n)
                    disp(model.mets(model.S(:,n)~=0)')
                    disp(aveHbound(model.S(:,n)~=0))
                end
                if printLevel<-1
                    rxnFormula=printRxnFormula(model,model.rxns{n},0);
                    fprintf(fid,'%s\n',rxnFormula{1});
                end
            end
        else
            if massImbalance(n,1)~=0
                if printLevel>0
                    fprintf('%s\t\n',[ 'vonBertalanffy:pHbalanceProtons ' model.rxns{n} ' reconstruction reaction not balanced for H to begin with']);
                else
                    if printLevel<0
                        fprintf(fid,'%s\t\n',[ 'vonBertalanffy:pHbalanceProtons ' model.rxns{n} ' reconstruction reaction not balanced for H to begin with']);
                    end
                end
            else
                if printLevel>0
                    fprintf('%s\n',['vonBertalanffy:pHbalanceProtons ' model.rxns{n} ' reconstruction reaction not balanced to begin with']);
                else
                    if printLevel<0
                        fprintf(fid,'%s\n',['vonBertalanffy:pHbalanceProtons ' model.rxns{n} ' reconstruction reaction not balanced to begin with']);
                    end
                end
            end
        end

%         if aveHbound*model.S(:,n)>(eps*1e4)
%             if printLevel>1 %debugging
%                 disp(n)
%                 disp(model.rxns{n})
%                 printRxnFormula(model,model.rxns{n},1);
%             end
%             fprintf('%s\n',['Reaction ' model.rxns{n} ', #' int2str(n) ' not proton balanced. No thermodynamic data available to balance reaction.'])
%         end
    end
end
if any(any(isnan(model.S)))
    error('NaN in S matrix after proton balancing.')
end
