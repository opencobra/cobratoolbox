function [dGt,dGt0,dGft,dGft0,SpH,aveHbound,aveZi,pHVec,isVec,chiVec]=testInterCompartmentRxn(model,rxnAbbr,PHmin,PHmax,ISmin,ISmax,CHImin,CHImax,N)
%Calculates the transformed Gibbs energy for a reaction and
%standard transformend Gibbs energy for a reaction as a function of
%pH, ionic strength and electrical potential. The reaction may involve
%multiple compartments.
%
% model     COBRA model structure
% rxnAbbr   Abbreviation of a reaction in the model.rxns field to be tested
% PHmin     Minimum glass electrode pH
% PHmax     Maximum glass electrode pH
% ISmin     Ionic strength minimum
% ISmax     Ionic strength maximum
% CHImin    Electrical potential minimum
% CHImax    Electrical potential maximum
% N         Number of data points to interpolate between each min and max
%           for each of pH, IS and CHI.
%
% OUTPUT
% dGt       N by N by N matrix of reaction transformed Gibbs energies
%           as a function of pH, ionic strength and electrical potential
%           respectively.
% dGt0      N by N by N matrix of reaction standard transformed Gibbs energies
%           as a function of pH, ionic strength and electrical potential
%           respectively.
% dGft      M by N by N by N matrix of reactant transformed Gibbs energies
%           as a function of pH, ionic strength and electrical potential
%           respectively. M is the number of reactants involved in the
%           reaction.
% dGft0     M by N by N by N matrix of reactant standard transformed Gibbs energies
%           as a function of pH, ionic strength and electrical potential
%           respectively. M is the number of reactants involved in the
%           reaction.
% SpH       M by N by N matrix of pH balanced stoichiometric coefficients
%           as a function of pH, ionic strength and electrical potential
%           respectively. M is the number of reactants involved in the
%           reaction. see pHbalanceProtons.m
% aveHbound M by N by N by N matrix of average number of protons bound by each reactant
%           as a function of pH, ionic strength and electrical potential
%           respectively. M is the number of reactants involved in the
%           reaction. see pHbalanceProtons.m
% aveZi     M by N by N by N matrix of the average charge of each reactant
%           as a function of pH, ionic strength and electrical potential
%           respectively. M is the number of reactants involved in the
%           reaction. see pHbalanceProtons.m
% pHVec     N by 1 vector of glass electrode pH used
% isVec     N by 1 vector of ionic strengths used
% chiVec    N by 1 vector of electrical potentials used


if ~exist('PHmin','var')
    PHmin = 5.5;
end
if ~exist('PHmax','var')
    PHmax = 8.5;
end
if ~exist('ISmin','var')
    ISmin = 0;
end
if ~exist('ISmax','var')
    ISmax = 0.25;
end
if ~exist('CHImin','var')
    CHImin = 0;
end
if ~exist('CHImax','var')
    CHImax = 0.25;
end
if ~exist('N','var')
    N = 50;
end
if ~exist('Alberty2006','var')
    loadDataToSetupThermoModel
end
for n=1:length(Alberty2006)
    albertyAbbrAll{n,1}=Alberty2006(n).abbreviation; 
end
if ~exist('rxnAbbr','var')
    if 1
        %'succinate transport via proton symport (2 H)'
        rxnAbbr='SUCCt2_2';
    else
        %'citrate transport, mitochondrial'
        rxnAbbr='CITtam';
    end
end

[nMet,nRxn]=size(model.S);
%reduce size of model to just selected reaction and protons in each
%compartment
rxnBool=strcmp(model.rxns,rxnAbbr);
if ~any(rxnBool)
    error(['could not find ' rxnAbbr])
end
metBool=false(nMet,1);
metBool(model.S(:,rxnBool)~=0)=1;

[compartments,uniqueCompartments]=getCompartment(model.mets(metBool));
%indices of protons in different uniqueCompartments
hydrogenBool=false(nMet,1);
for p=1:length(uniqueCompartments)
    ind=find(strcmp(['h[' uniqueCompartments{p} ']'],model.mets)~=0);
    if ~isempty(ind)
        hydrogenBool(ind)=1;
    end
end
metBool = metBool | hydrogenBool;

%extract that part of the model needed for thermodynamic calculations
model2.mets=model.mets(metBool);
model2.metNames=model.metNames(metBool);
model2.metFormulas=model.metFormulas(metBool);
model2.metCharges=model.metCharge(metBool);
model2.rxns=model.rxns(rxnBool);
model2.rxnNames=model.rxnNames(rxnBool);
model2.rev=model.rev(rxnBool);
model2.lb=model.lb(rxnBool);
model2.ub=model.ub(rxnBool);
model2.S=model.S(metBool,rxnBool);
[nMet,nRxn]=size(model2.S);
model2.b=zeros(nMet,1);
model2.c=zeros(nRxn,1);

%save reduced model
model=model2;
model.biomassRxnAbbr='NONE';

%create vectors of changing pH, ionic strength and electrical potential
pHVec  = linspace(PHmin,PHmax,N);
isVec  = linspace(ISmin,ISmax,N);
chiVec = linspace(CHImin,CHImax,N);

%parameters for setupThermoModel
rxnBoundsFile=[];
Legendre=1;
LegendreCHI=1;
useKeqData=1;
nStdDevGroupCont=1;
cumNormProbCutoff=0.2;
figures=0;
printToFile=0;

rxnAbbr='SUCCt_Jol';
%rxnAbbr='SUCCt2_2';
%rxnAbbr='SUCCt2_3';
%rxnAbbr='SUCCt2_3';
%rxnAbbr='CITtam';
switch rxnAbbr
    case 'SUCCt_Jol'
        Ni=N; Nj=1; Nk=1;
        
        %Extracellular compartment pH =  inside compartment in Jol et al.
        %Intracellular compartment pH = outside compartment in Jol et al.
        PHR.c=5; %real pH 5 - make sure to set pH adjustment off in setupThermoModel        
        
        if 1
            IS.c=0.15;
            IS.e=0.15;
            isVec(1)=IS.e;
        else
            IS.c=0;
            IS.e=0;
            isVec(1)=IS.e;
        end
        
        if 1
            CHI.c=40;
            CHI.e=0;
            chiVec(1)=CHI.e;
        else
            CHI.c=0;
            CHI.e=0;
            chiVec(1)=CHI.e;
        end

        temp=298.15;
        
        model.rxns{1}='SUCCt';
        
        model.metFormulas{strcmp(model.mets,'succ[c]')}='C4H6O4';
        model.metFormulas{strcmp(model.mets,'succ[e]')}='C4H6O4';
        model.S(strcmp('succ[e]',model.mets),1)=1;
        model.S(strcmp('succ[c]',model.mets),1)=-1;
        model.S(strcmp('h[c]',model.mets),1)=0;
        model.S(strcmp('h[e]',model.mets),1)=0;
        model.metCharge(strcmp(model.mets,'succ[c]'))=0;
        model.metCharge(strcmp(model.mets,'succ[e]'))=0;
        model.metCharge(strcmp(model.mets,'h[c]'))=1;
        model.metCharge(strcmp(model.mets,'h[e]'))=1;
        
        if 1
            metBoundsFile='SuccinateTransport.txt';
        else
            metBoundsFile='SuccinateTransportStandard.txt';
        end
                
        %left
        bool=strcmp('succ',metAbbrAlbertyAbbr(:,2));
        albertyAbbr=metAbbrAlbertyAbbr(bool,3);
        n=find(strcmp(albertyAbbr,albertyAbbrAll));
        %find the number of species within pseudoisomer group
        p=max(find(~isnan(Alberty2006(n).basicData(:,1))));
        [dGf0_left,dHf0_left,mf_left,aveHbound_left,aveZi_left,lambda_left]=calcdGHT(Alberty2006(n).basicData(1:p,1),Alberty2006(n).basicData(1:p,2),Alberty2006(n).basicData(1:p,3),Alberty2006(n).basicData(1:p,4),PHR.c,IS.c,temp,CHI.c,Legendre,LegendreCHI);
        
        dGt2=zeros(Ni,1);
        dGft02=zeros(nMet,Ni);
        
        staticCompartment='c';
        variableCompartment='e';
        
    case 'SUCCt2_2'
        Ni=N; Nj=N; Nk=N;
        
        PHR.c=5; %real pH 5 - make sure to set pH adjustment off in setupThermoModel
        
        CHI.c  = 0;
        CHI.e  = 0;
        chiVec(1)=CHI.e;
        
        isVec = 0.15;
        IS.e  = 0.15;
        isVec(1)=IS.e;
        
        temp=298.15;
        
        model.metFormulas{strcmp(model.mets,'succ[c]')}='C4H6O4';
        model.metFormulas{strcmp(model.mets,'succ[e]')}='C4H6O4';
        model.S(strcmp('h[c]',model.mets),1)=0;
        model.S(strcmp('h[e]',model.mets),1)=0;
        
        metBoundsFile='SuccinateTransportStandard.txt';
        
        staticCompartment='c';
        variableCompartment='e';
        
    case 'SUCCt2_3'
        %Groeneveld, M.; Weme, R. G. J. D. O.; Duurkens, R. H. & Slotboom, D. J. 
        %Biochemical characterization of the C4-dicarboxylate transporter DctA from
        %Bacillus subtilis. J Bacteriol, 2010, 192, 2900-2907
        
%         The Vmax for succinate
%         transport was approximately 3-fold lower at an external pH of
%         7 [1.4 nmol (mg protein)21 s21] than at pH 5.5 [3.9 nmol (mg
%         protein)21 s21]. This result is consistent with the protons being
%         cosubstrates.

        if 1
            if 0
                Ni=N; Nj=N; Nk=N;
            else
                Ni=N; Nj=N; Nk=1;
            end
        else
            Ni=N; Nj=1; Nk=1;
        end
        
        %cytoplasm mimics vesicle compartment
        if 1
            PHR.c=8;
        else
            PHR.c=6;
        end
        
        %"In the first experiment, we varied the external pH (5.5 or 7) while keeping the internal pH (8) constant.
        if 1
            PHmin = 5.5;
            PHmax = 7;
            pHVec  = linspace(PHmin,PHmax,N);
        end
        
        %"In the presence of valinomycin, an additional K+ diffusion potential, 
        %DC (Nernst potential, -118 mV), was created."
        if 1
            CHI.c=0;
            CHI.e=118;
            if 1
                 chiVec  = linspace(0,118,Nj);
            else
                 chiVec(1)=CHI.e;
            end
        else
            CHI.c=0;
            CHI.e=0;
        end

        %"Membrane vesicles contain 100 mM K-HEPES (pH 7.5)."
        %http://www.sigmaaldrich.com/life-science/core-bioreagents/biological-buffers/hepes-specification.html
%         Synonyms	    4-(2-Hydroxyethyl)piperazine-1-ethanesulfonic acid
%         N-(2-Hydroxyethyl)piperazine-N'-(2-ethanesulfonic acid)
%         Molecular Formula	C8H18N2O4S	Beilstein Registry	883043	pKa (at 20)	7.55
%         Molecular Weight	238.30	MDL Number	MFCD00006158	pKa (at 25)	7.48
%         CAS Number	7365-45-9	EG/EC Number	230-907-9	pKa (at 37)	7.31
%         Useful pH range	6.8 - 8.2
        pKa=7.31;
        IS.c = 0.5 *(10^-pKa)*0.1;
        
        %"vesicles were diluted 100-fold in an isosmotic Na-MES buffer, pH 5.5 
        %(consisting of 135 mM MES [morpholineethanesulfonic acid] adjusted to 
        %pH 5.5 with NaOH)"
%         http://www.sigmaaldrich.com/life-science/core-bioreagents/biological-buffers/mes-sodium-salt-specification.html
%         Molecular Formula	C6H12NNaO4S	Beilstein Registry	3765682	Useful pH range	5.5 - 6.7
%         Molecular Weight	217.22	MDL Number	MFCD00065473	pKa (at 25)	6.1
%         CAS Number	71119-23-8	EG/EC Number	275-203-2
        pKa=6.1;
        IS.e = 0.5 *(10^-pKa)*0.135;
        isVec(1)=IS.e;
        
        temp=310.15;
        
        % "Succinate transport was stimulated by a negative membrane potential,
        % indicating that transport was electrogenic. Therefore, at
        % least three protons must be transported with the divalent anion
        % succinate."
        model.metFormulas{strcmp(model.mets,'succ[c]')}='C4H4O4';
        model.metFormulas{strcmp(model.mets,'succ[e]')}='C4H4O4';
        model.metCharge(strcmp(model.mets,'succ[c]'))=-2;
        model.metCharge(strcmp(model.mets,'succ[e]'))=-2;
        model.S(strcmp('h[c]',model.mets),1)=3;
        model.S(strcmp('h[e]',model.mets),1)=-3;
        model.metCharges(strcmp(model.mets,'h[c]'))=1;
        model.metCharges(strcmp(model.mets,'h[e]'))=1;
        
        if 0
            %"3.1 mM [14C]succinate"
            metBoundsFile='SuccinateTransportGROENEVELD.txt'; % 3.1 mM on both sides at present
        else
            metBoundsFile='SuccinateTransportStandard.txt';
        end
        
        staticCompartment='c';
        variableCompartment='e';
          
    case 'CITtam'
         %citrate transport, mitochondrial
         %cit[c] + mal-L[m] <==> cit[m] + mal-L[c]
         
%         F. Bisaccia, A. De Palma, G. Prezioso, and F. Palmieri. Kinetic characterization
%         of the reconstituted tricarboxylate carrier from rat liver mitochondria.
%         Biochim Biophys Acta, 1019(3):250–256, Sep 1990.

          temp = 273.15 + 25;
          
          %10 mM PIPES
          %1,4-Piperazinediethanesulfonic acid
          if 1
              %http://www.sigmaaldrich.com/catalog/ProductDetail.do?lang=en&N4=P6757|SIGMA&N5=SEARCH_CONCAT_PNO|BRAND_KEY&F=SPEC
              %http://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:44933
              %pKa (25 °C) 6.8
              pKa_PIPES = 6.8;
          else
              %GOLDBERG, KISHORE, AND LENNEN NIST tables
              pKa_PIPES=7.141;
          end
          
          %50 mM NaCl
          %pKa = 6.7–7.3
          pKa_NaCl=7;
          
          if 0
              %IS.c = 0.5 *(2*(10^-pKa_PIPES)*0.01 + 2*(10^-pKa_NaCl)*0.05);
              IS.c = 0.5 *(2*(10^-pKa_PIPES)*0.01 + 2*(1)*0.05);
              IS.m = IS.c;
              % TODO how to include effect of
              % 10mM citrate or 20mM malate
          else
              IS.c = 0;
              IS.m = IS.c;
          end
          
          if 1
              CHI.c = 0;
              CHI.m = 0;
          else
              CHI.c = 0;
              CHI.m = 0;
          end
          
          if 1
              PHR.c = 7;
              PHR.m = 7;
          else
              %intracellular
              PHR.c = 7.35;
              PHR.m = 8;
          end
          
          metBoundsFile='CITtam.txt';
          metBoundsFile='CITtam_Standard.txt';
          
          if 1
              %cit[c] + mal-L[m] <==> cit[m] + mal-L[c]
              model.metFormulas{strcmp(model.mets,'cit[m]')}='C6H5O7';
              model.metFormulas{strcmp(model.mets,'cit[c]')}='C6H5O7';
              model.metCharges(strcmp(model.mets,'cit[m]'))=-3;
              model.metCharges(strcmp(model.mets,'cit[c]'))=-3;
              model.metFormulas{strcmp(model.mets,'mal-L[m]')}='C4H4O5';
              model.metFormulas{strcmp(model.mets,'mal-L[c]')}='C4H4O5';
              model.metCharges(strcmp(model.mets,'mal-L[m]'))=-2;
              model.metCharges(strcmp(model.mets,'mal-L[c]'))=-2;
          else
              %cit[c] + mal-L[m] <==> cit[m] + mal-L[c] + h[m]
              model.S(strcmp(model.mets,'h[m]'),1)=1;
              model.metFormulas{strcmp(model.mets,'cit[m]')}='C6H5O7';
              model.metFormulas{strcmp(model.mets,'cit[c]')}='C6H6O7';
              model.metCharges(strcmp(model.mets,'cit[m]'))=-3;
              model.metCharges(strcmp(model.mets,'cit[c]'))=-2;
              model.metFormulas{strcmp(model.mets,'mal-L[m]')}='C4H4O5';
              model.metFormulas{strcmp(model.mets,'mal-L[c]')}='C4H4O5';
              model.metCharges(strcmp(model.mets,'mal-L[m]'))=-2;
              model.metCharges(strcmp(model.mets,'mal-L[c]'))=-2;
          end
              
          
          if 1
              if 0
                  Ni=N; Nj=N; Nk=N;
              else
                  Ni=N; Nj=1; Nk=1;
              end
          else
              Ni=N; Nj=1; Nk=1;
          end
          
          staticCompartment='c';
          variableCompartment='m';
end

[nMet,nRxn]=size(model.S);

dGt=zeros(Ni,Nj,Nk);
dGt0=zeros(Ni,Nj,Nk);
dGft=zeros(nMet,Ni,Nj,Nk);
dGft0=zeros(nMet,Ni,Nj,Nk);
SpH=zeros(nMet,Ni,Nj,Nk);
aveHbound=zeros(nMet,Ni,Nj,Nk);
aveZi=zeros(nMet,Ni,Nj,Nk);


for i=1:Ni
    PHR.(variableCompartment)=pHVec(i);
    for j=1:Nj
        CHI.(variableCompartment)=chiVec(j);
        for k=1:Nk
            IS.(variableCompartment)=isVec(k);
                 
            %setup thermo model for a single reaction
            [modelT,directions,solutionThermoRecon]=setupThermoModel(model,metAbbrAlbertyAbbr,...
                metGroupCont,Alberty2006,temp,PHR,IS,CHI,model.biomassRxnAbbr,...
                symphID_rxnAbbr,metBoundsFile,rxnBoundsFile,Legendre,useKeqData,...
                nStdDevGroupCont,cumNormProbCutoff,figures,printToFile);

            %assumes there is only one reaction
            dGt0(i,j,k)=(modelT.rxn(1).dGt0Min + modelT.rxn(1).dGt0Max)/2;
            dGt(i,j,k)=(modelT.rxn(1).dGtMin + modelT.rxn(1).dGtMax)/2;
            
            %stoichiometry
            SpH(:,i,j,k)=modelT.S;
            %average number of protons bound
            for m=1:nMet
                aveHbound(m,i,j,k)=modelT.met(m).aveHbound;
                aveZi(m,i,j,k)=modelT.met(m).aveZi;
                dGft0(m,i,j,k)=modelT.met(m).dGft0;
                dGft(m,i,j,k)=(modelT.dGftMin(m) + modelT.dGftMax(m))/2;
            end
                
            if strcmp(rxnAbbr,'SUCCt_Jol')
                % Compare with Jol et al approach for neutral succinate transport
                zi = 0;
                if 1
                    Cj_left  = 0.00005;
                    Cj_right = 0.0005;
                else
                    Cj_left  = 1;
                    Cj_right = 1;
                end
                
                %other data
                dGf0_H = 0; %proton standard
                
                
                %By convention, we assume the chemical potential of a metabolite
                %includes an electrical potential term
                % u = u0 + RT*log(activity) + F*zi*chi;
        
                R = 8.314472/1000; % kJ K-1 mol-1
                F = 96.48;     % Coloumb mol-1
                RT=R*temp;
                nH = numAtomsOfElementInFormula(model.metFormulas{strcmp(model.mets,'succ[c]')},'H');
                
                pH_right   = pHVec(i);
                chi_right  = CHI.e;
                is_right   = IS.e;
                
                %stoichiometry
                Sj_left  = 0;
                Sj_right = 0;
                si_transport_left  = -1;
                si_transport_right = 1;
                si_charge_inside   = 1;
                
                %find the right bit of Alberty's data
                bool=strcmp('succ',metAbbrAlbertyAbbr(:,2));
                albertyAbbr=metAbbrAlbertyAbbr(bool,3);
                n=find(strcmp(albertyAbbr,albertyAbbrAll));
                
                %find the number of species within pseudoisomer group
                p=max(find(~isnan(Alberty2006(n).basicData(:,1))));
                [dGf0_right,dHf0_right,mf_right,aveHbound_right,aveZi_right,lambda_right]=calcdGHT(Alberty2006(n).basicData(1:p,1),Alberty2006(n).basicData(1:p,2),Alberty2006(n).basicData(1:p,3),Alberty2006(n).basicData(1:p,4),pH_right,is_right,temp,chi_right,Legendre,LegendreCHI);
                
                %legendre transform of species
                %dGft0_species_left  = dGf0i  - nH*(dGf0_H + RT*log(10^-pH_left));
                %dGft0_species_right = dGf0i  - nH*(dGf0_H + RT*log(10^-pH_right));
                
                %Standard transformed Gibbs energy of reactant
                dGft0_reactant_left=dGf0_left;
                dGft0_reactant_right=dGf0_right;
                
                dGft02(1,i)=dGf0_H - RT*log(10^-PHR.c);
                dGft02(2,i)=dGf0_H - RT*log(10^-pH_right);
                dGft02(3,i)=dGft0_reactant_left;
                dGft02(4,i)=dGft0_reactant_right;
                
                dGft2(1,i)= dGf0_H + (F*(CHI.e/1000))*zi;
                dGft2(2,i)= dGf0_H + (F*(chi_right/1000))*zi;
                dGft2(3,i)= dGft0_reactant_left   + RT*log(Cj_left);
                dGft2(4,i)= dGft0_reactant_right   + RT*log(Cj_right);
                
                dGt2(i) =    Sj_left*(dGft0_reactant_left + RT*log(Cj_left))   +  si_transport_left*(dGft0_reactant_left   + RT*log(Cj_left)  + nH*(dGf0_H + RT*log(10^-PHR.c )))...
                    + Sj_right*(dGft0_reactant_right + RT*log(Cj_right)) +  si_transport_right*(dGft0_reactant_right + RT*log(Cj_right) + nH*(dGf0_H + RT*log(10^-pH_right)))...
                    + F*(-CHI.c + chi_right)*si_charge_inside*zi;
                if i==Ni
                    pause(eps)
                end
            end
            
        end
    end
end

if Nj==1
    %pH vs delta G
    figure;
    hold on
    plot(pHVec,dGt(:,1,1),'.-b')
    xlabel(['pH[' staticCompartment ']'])
    ylabel('\Delta G')
    equation=printRxnFormula(model,model.rxns(1),0);
    if 1
        string = {['pH[' variableCompartment '] = ' num2str(PHR.c)];['\Delta \psi = -' num2str(CHI.(variableCompartment)) ' mV']; equation{1}};
    else
        string = equation;
    end

    if strcmp(rxnAbbr,'SUCCt_Jol')
        plot(pHVec,dGt2,'*--r')
        xlabel('inside pH')

        if 1
            string = {['pH[out] = ' num2str(PHR.c)];['\Delta \psi = ' num2str(CHI.c) ' mV']; equation{1}};
        else
            string = equation;
        end

        disp(model.metFormulas{1})
        disp(equation)
        model.mets

        if 1
            dGft0
            dGft02
            dGft
            dGft2
        end
    end
    pause(eps)

    title(string)
else
    %pH, chi, deltaG
    figure;
    hold on;
    surf(pHVec,chiVec,dGt(:,:,1))
    xlabel('pH[e]')
    ylabel('\Delta \psi')
    zlabel('\Delta G (kJ/mol)')
    %box on
    grid on
end
    
    


