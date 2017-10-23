function model = thermodynamicAdjustmentToStoichiometry(model)
% Thermodynamic adjustments to the stoichiometric matrix for 'co2', 'h2o', and bound cofactors.
%
% In aqueous phase, carbon dioxide is distributed between 'CO2(aq)', 'H2CO3', 'HCO3^-', 'CO3^2-'.
% For each 'CO2(tot)' in a reaction  add an 'H2O' to the other side of reaction, and change the formula for
% carbon dioxide to 'CO2.H20' = 'H2CO3' see `p150 Alberty 2003`.
%
% Also adjust stoichiometric matrix to account for the fact that the cofactors of
% succinate dehydrogenase, FAD/FADH, are bound.
%
% USAGE:
%
%    model = thermodynamicAdjustmentToStoichiometry(model)
%
% INPUT:
%    model:    structure with fields:
%
%                * .S
%                * .mets
%                * .rxns
%
% OUTPUT:
%    model:    structure with fields:
%
%                * .S - thermodynamically adjusted stoichiometric matrix
%                * .mets
%                * .rxns
%                * .Sold
%
% .. Authors:
%       - Ronan M. T. Fleming
%       - Lemmer El Assal / 2017 :
%         * adaptation to current COBRA model structure
%         * optimization

[nMet,nRxn]=size(model.S);
model.oldS=model.S;

co2MetBool=false(nMet,1);
h2oMetBool=false(nMet,1);

% co2MetBool(find(strncmpi(model.mets,'co2',3),1) = 1;
% h2oMetBool(find(strncmpi(model.mets,'h2o',3),1) = 1;


for m=1:nMet
    %         if length(model.met(m).abbreviation)==6 && strcmp(model.met(m).abbreviation(1:3),'co2')
    %             %append the number of the metabolite for the compartment to the
    %             %compartment
    %             bool=strcmp(model.met(m).abbreviation(5),compartments(:,1));
    %             if any(bool)
    %                 compartments{bool,3}=m;
    %             end
    %         end
    %         if length(model.met(m).abbreviation)==6 && strcmp(model.met(m).abbreviation(1:3),'h2o')
    %             %append the number of the metabolite for the compartment to the
    %             %compartment
    %             bool=strcmp(model.met(m).abbreviation(5),compartments(:,1));
    %             if any(bool)
    %                 compartments{bool,3}=m;
    %             end
    %         end
    %if strcmp(model.met(m).abbreviation(1:3),'co2')
    abbr = model.mets{m};
    if strcmp(abbr(1:3),'co2')
        co2MetBool(m,1)=1;
        %change the formula for carbon dioxide to CO2.H20 = H2CO3
        %model.met(m).formula='H2CO3';
        model.metFormulas{m}='H2CO3';
        %fprintf('%s\n',[ 'Formula for carbon dioxide ' model.met(m).abbreviation(4:6) ' is now H2CO3 = CO2.H20']);
        fprintf('%s\n',[ 'Formula for carbon dioxide ' abbr(4:6) ' is now H2CO3 = CO2.H20']);
    end
    %if strcmp(model.met(m).abbreviation(1:3),'h2o')
    if strcmp(abbr(1:3),'h2o')
        h2oMetBool(m,1)=1;
    end
end

%adjust reactions involving CO2
%p150 Alberty 2003
fprintf('%s\n','for each CO2(tot) in a reaction add an H2O to the other side of reaction.');
for n=1:nRxn
    %dont make this change for any exchange reactions
    if model.SIntRxnBool(n)
        co2MatchBool = co2MetBool & model.S(:,n)~=0;
        if any(co2MatchBool)
            if nnz(co2MatchBool)==2
                co2Ind=find(co2MatchBool);
                met1=model.mets{co2Ind(1)};
                met2=model.mets{co2Ind(2)};
                if strcmp(met1(end-2:end),met2(end-2:end))
                    %add an H2O to both sides of reaction only if both co2 in
                    %the same compartment
                    %compartment1=model.met(co2Ind(1)).abbreviation(4:6);
                    abbr = model.mets(co2Ind(1));
                    compartment1=abbr(4:6);

                    model.S(strcmp(['h2o' compartment1],model.mets),n)=...
                        model.S(strcmp(['h2o' compartment1],model.mets),n)-model.S(co2Ind(1),n);

                    %compartment2=model.met(co2Ind(2)).abbreviation(4:6);
                    abbr = model.mets(co2Ind(2));
                    compartment2=abbr(4:6);

                    model.S(strcmp(['h2o' compartment2],model.mets),n)=...
                        model.S(strcmp(['h2o' compartment2],model.mets),n)-model.S(co2Ind(2),n);
                end
            else
                if nnz(co2MatchBool)==1
                    %add an H2O to the other side of reaction
                    %compartment=model.met(co2MatchBool).abbreviation(4:6);
                    abbr = model.mets(co2MatchBool);
                    compartment = abbr(4:6);

                    model.S(strcmp(['h2o' compartment],model.mets),n)=...
                        model.S(strcmp(['h2o' compartment],model.mets),n)-model.S(co2MatchBool,n);
                else
                    error('co2 in 3 compartments of a reaction');
                end
            end
        end
    end
end

[nMet,nRxn]=size(model.S);

% TODO - needs more work such that it can apply to the most general case
% beyond succinate dehydrogenase bound to cofactors FAD/FADH

%adjust stoichiometric matrix to account for succinate dehydrogenase
if 1
    %Distinguish between unbound and enzyme bound FAD/FADH.
    %
    %FAD and FADH2 are often bound to the enzymes covalently
    % e.g. succinate dehydrogenase reaction:
    %Succinate + FAD_enz <=> Fumarate + FADH2_enz
    %this changes their chemical potential, therefore, define two new
    %metabolites FAD_enz_SDH and FADH2_enz_SDH and create two new reactions
    %FAD <==> FAD_enz_SDH
    %FADH2 <==> FADH2_enz_SDH
    numChar=1;
    [compartments,uniqueCompartments]=getCompartment(model.mets,numChar);

    %check for reaction in each compartment
    for p=1:length(uniqueCompartments);
        fad_ind   = [];
        fadh2_ind = [];
        fum_ind   = [];
        succ_ind  = [];

        [nMet,nRxn]=size(model.S);

        for m=1:nMet
            if strcmp(model.mets{m},['fad[' uniqueCompartments{p} ']']);
                fad_ind=m;
                break;
            end
        end
        for m=1:nMet
            if strcmp(model.mets{m},['fadh2[' uniqueCompartments{p} ']']);
                fadh2_ind=m;
                break;
            end
        end
        for m=1:nMet
            if strcmp(model.mets{m},['fum[' uniqueCompartments{p} ']']);
                fum_ind=m;
                break;
            end
        end
        for m=1:nMet
            if strcmp(model.mets{m},['succ[' uniqueCompartments{p} ']']);
                succ_ind=m;
                break;
            end
        end

        if ~isempty(fad_ind)  && ~isempty(fadh2_ind) && ~isempty(fum_ind) && ~isempty(succ_ind)

            %         %terminate loop (why?)
            %         if exist('fad_ind') && ~exist('fadh2_ind')
            %             break
            %         end

            %new metabolites
            model.mets{nMet+1}=['fad_enz_SDH[' uniqueCompartments{p} ']'];
            %model.met(nMet+1).abbreviation=model.mets{nMet+1};
            model.metNames{nMet+1}=[model.mets{nMet+1} ' (bound to Succinate Dehydrogenase)'];
%            model.met(nMet+1).charge=model.met(fad_ind).charge;
%            model.met(nMet+1).formula=model.met(fad_ind).formula;
            model.metCharges(nMet+1) = model.metCharges(fad_ind);
            model.metFormulas(nMet+1) = model.metFormulas(fad_ind);

            model.b(nMet+1)=0;

            model.mets{nMet+2}=['fadh2_enz_SDH[' uniqueCompartments{p} ']'];
            model.met(nMet+2).abbreviation=model.mets{nMet+2};
            model.metNames{nMet+2}=[model.mets{nMet+2} ' (bound to Succinate Dehydrogenase)'];
            %model.met(nMet+2).charge=model.met(fadh2_ind).charge;
            %model.met(nMet+2).formula=model.met(fadh2_ind).formula;
            model.metCharges(nMet+2) = model.metCharges(fadh2_ind);
            model.metFormulas(nMet+2) = model.metFormulas(fadh2_ind);
            model.b(nMet+2)=0;


            %new reactions
            model.rxns{nRxn+1}=['fad_enz_SDH_' uniqueCompartments{p}];
            model.rxnNames{nRxn+1}='fad binding to Succinate Dehydrogenase';
            model.subSystems{nRxn+1}={''};
            model.lb(nRxn+1)=-1000;
            model.ub(nRxn+1)=1000;
            model.c(nRxn+1)=0;

            model.rxns{nRxn+2}=['fadh2_enz_SDH_' uniqueCompartments{p}];
            model.rxnNames{nRxn+2}='fadh2 binding to Succinate Dehydrogenase';
            model.subSystems{nRxn+2}={''};
            model.lb(nRxn+2)=-1000;
            model.ub(nRxn+2)=1000;
            model.c(nRxn+2)=0;

            %change S matrix
            %edit existing reaction Succinate FAD_enz <=> Fumarate + FADH2_enz
            for n=1:nRxn
                if nnz(model.S([fad_ind,fadh2_ind,fum_ind,succ_ind],n))==4
                    fprintf('%s','Found reaction: ');
                    fprintf('%s\n',model.rxnNames{n});
                    fprintf('%s\n','Succinate + FAD <=> Fumarate + FADH2','..changed to Succinate + FAD_enz <=> Fumarate + FADH2_enz.');
                    model.rxnNames{n}=[model.rxnNames{n} ' (cofactors bound)'];

                    model.S(nMet+1,n)=model.S(fad_ind,n);
                    model.S(fad_ind,n)=0;
                    model.S(nMet+2,n)=model.S(fadh2_ind,n);
                    model.S(fadh2_ind,n)=0;
                end
            end

            %add FAD associating to Succinate Dehydrogenase
            model.S(fad_ind,nRxn+1)=-1;
            model.S(nMet+1,nRxn+1)=1;
            %add FADH2 associating to Succinate Dehydrogenase
            model.S(fadh2_ind,nRxn+2)=-1;
            model.S(nMet+2,nRxn+2)=1;

            %update v2 variables
            model.met(nMet+1).officialName='Flavin adenine dinucleotide oxidized (bound to Succinate Dehydrogenase)';
            model.met(nMet+2).officialName='Flavin adenine dinucleotide reduced (bound to Succinate Dehydrogenase)';

            model.met(nMet+1).albertyAbbreviation='fadenzox';
            model.met(nMet+1).albertyName='FAD_enz_ox';
            model.met(nMet+2).albertyAbbreviation='fadenzred';
            model.met(nMet+2).albertyName='FAD_enz_red';

            for n=nRxn+1:nRxn+2
                model.rxn(n).abbreviation=model.rxns{n};
                model.rxn(n).officialName=model.rxnNames{n};
                %equation
                eq=printRxnFormula(model,model.rxns(n),0);
                model.rxn(n).equation=eq{1};
                %directionality
                if model.lb(n)<0
                    if model.ub(n)>0
                        model.rxn(n).directionality='reversible';
                    else
                        model.rxn(n).directionality='reverse';
                    end
                else
                    model.rxn(n).directionality='forward';
                end
            end
        end
    end
else
    fprintf('%s\n','Skipping thermodynamic adjustment for Succinate Dehydrogenase')
end

model.oldS = [model.oldS; zeros((size(model.S,1) - size(model.oldS,1)),size(model.oldS,2))];
model.oldS = [model.oldS, zeros(size(model.oldS,1),(size(model.S,2) - size(model.oldS,2)))];

model.SIntRxnBool(length(model.SIntRxnBool)+1:size(model.S,2))=1;
model.SExRxnBool(length(model.SIntRxnBool)+1:size(model.S,2))=0;
pause(eps)
