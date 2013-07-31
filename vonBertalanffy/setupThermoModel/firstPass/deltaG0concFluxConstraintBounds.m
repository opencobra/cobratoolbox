function model=deltaG0concFluxConstraintBounds(model,Legendre,LegendreCHI,gcmOutputFile,gcmMetList,jankowskiGroupData,figures,nStdDevGroupCont)
%set reaction directionality bounds from thermodynamic data
%
%first pass assignment of reaction directionality based on standard
%transformed Gibbs energy and concentration bounds
%
%INPUT
% model.S
% model.SintRxnBool             Boolean indicating internal reactions
% model.gasConstant             gas constant
% model.temp                    temperature
% model.boundryConc             bounds on concentration of boundary metabolites
% model.met(m).dGft0            standard transformed Gibbs energy of formation(kJ/mol)
% model.met(m).dGf0GroupContUncertainty  group. cont. uncertainty in estimate of standard Gibbs energy of formation (kJ/mol)
% model.met(m).concMin          lower bound on metabolite concentration
% model.met(m).concMax          upper bound on metabolite concentration
% model.met(m).charge           reconstruction metabolite charge
% model.lb                      reconstruction reaction lower bounds
% model.ub                      reconstruction reaction upper bounds
% model.CHI.*                   electrical potential (mV) in compartment defined by letter *
% Legendre                      {(1),0} Legendre Transformation for specifc pHr?
% LegendreCHI                   {(1),0} Legendre Transformation for specifc electrical potential?
% gcmOutputFile                 Path to output file from Jankowski et al.'s 2008
%                               implementation of the group contribution method.
% gcmMetList                    Cell array with metabolite ID for metabolites in
%                               gcmOutputFile. Metabolite order must be the same in
%                               gcmOutputFile and gcmMetList.
% jankowskiGroupData            Data on groups included in Jankowski et al.'s 2008
%                               implementation of the group contribution method.
%                               Included with von Bertalanffy 1.1. Location:
%                               ...\vonBertalanffy\setupThermoModel\experimentalDat
%                               a\groupContribution\jankowskiGroupData.mat.
%
%OPTIONAL INPUT
% figures           {1,(0)} 1=create figures
% nStdDevGroupCont  {real,(1)} number of standard deviations of group contribution
%                   uncertainty, 1 means uncertainty given by group contribution
%                   method (one standard deviation)
%
%OUTPUT
% nStdDevGroupCont  {real,(1)} number of standard deviations of group contribution
%                   uncertainty, 1 means uncertainty given by group contribution
%                   method (one standard deviation)
%
% For each metabolite:
% model.concMin
% model.concMax
% model.dGft0Min
% model.dGft0Max
% model.dGftMin
% model.dGftMax
% model.NaNdGf0MetBool              metabolites without Gibbs Energy
%
% For each reaction:
% model.rxn(n).dGt0Max              molar standard
% model.rxn(n).dGt0Min              molar standard
% model.rxn(n).dGtMax
% model.rxn(n).dGtMin
% model.rxn(n).dGtmMMin             mili molar standard
% model.rxn(n).dGtmMMax             mili molar standard
% model.rxn(n).directionalityThermo
% model.lb_reconThermo              lower bounds from dGtMin/dGtMax and recon
%                                   directions if thermo data missing
% model.ub_reconThermo              upper bounds from dGtMin/dGtMax and recon
%                                   directions if thermo data missing
% model.NaNdG0RxnBool               reactions with NaN Gibbs Energy
% model.transportRxnBool            transport reactions
%
% Ronan M. T. Fleming

[nMet,nRxn]=size(model.S);
%OPTIONS
if ~exist('figures','var')
    figures=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% METABOLITE PROPERTIES%%%%%%%%%%%%%%%%%%%%
%set the errors that accompany the standard chemical potentials
errorKeq=1*(8.314472/1.987); % kJ/mol. Upper limit on uncertainty due to lack of measurement precision according to Jankowski et al. 2008. - Hulda %0.000001;
if ~exist('nStdDevGroupCont','var')
    nStdDevGroupCont=1;
end
model.nStdDevGroupCont=nStdDevGroupCont;

%Metabolite chemical potential
%scale chemical potential by temperature and gas constant
gasConstant=model.gasConstant; %kJ K-1 mol-1
temp=model.temp; %Kelvin
rt=gasConstant*temp;

%standard chemical potential
dGft0Min=zeros(1,nMet);
dGft0Max=zeros(1,nMet);
nan_dGformationBool=false(nMet,1);
GroupCont_dGformationBool=false(nMet,1);

concMin=zeros(1,nMet);
concMax=zeros(1,nMet);
for m=1:nMet
    %     model.met(m).concMin
    concMin(1,m)=model.met(m).concMin;
    concMax(1,m)=model.met(m).concMax;
    %add the errors to the min and max standard transformed chemical
    %potentials
    if ~isnan(model.met(m).dGft0)
        %check the provinence of the data and add errors accordingly
            if  ~strcmp(model.met(m).dGft0Source,'Keq')
                %             metAbbr=model.met(m).abbreviation;
                %             if strcmp(metAbbr(end-2:end),'[c]')
                %                 fprintf('%s\n',['Transformed g.c. estimate (298.15K, pH 7) for metabolite ' int2str(m) ' : ' model.met(m).officialName]);
                %             end
                %standard transformed chemical potential values are in kJ per M
                %weightGroupCont is the weighting on the uncertainty given by
                %Group Contribution method
                dGft0Max(1,m)=model.met(m).dGft0+nStdDevGroupCont*model.met(m).dGft0GroupContUncertainty;
                dGft0Min(1,m)=model.met(m).dGft0-nStdDevGroupCont*model.met(m).dGft0GroupContUncertainty;
                GroupCont_dGformationBool(m)=1;
            else
                %add a slight error margin
                dGft0Max(1,m)=model.met(m).dGft0+errorKeq; %*abs(model.met(m).dGft0); Commented out. Used absolute error instead of relative error. - Hulda
                dGft0Min(1,m)=model.met(m).dGft0-errorKeq; %*abs(model.met(m).dGft0);
            end
    else
        nan_dGformationBool(m)=1;
    end
end
if max(dGft0Min>dGft0Max)==1
    error('dGft0Min greater than dGft0Max');
end

%standard chemical potential in kJ per Mole
if sum(dGft0Min>dGft0Max)~=0
    fprintf('%s\n','Some of the lower bounds on standard Gibbs energy are greater than upper bounds');
    %     dGft0Min>dGft0Max % Commented out. - Hulda
else
    for m=1:nMet
        model.met(m).dGft0Min=dGft0Min(m);
        model.met(m).dGft0Max=dGft0Max(m);
    end
    model.dGft0Min=dGft0Min';
    model.dGft0Max=dGft0Max';
end
%milimolar standard chemical potential
dGftmMMin=dGft0Min+rt*((log(concMin)+log(concMax))/2);
dGftmMMax=dGft0Max+rt*((log(concMin)+log(concMax))/2);

%min and max transformed chemical potential
dGftMin=dGft0Min+rt*log(concMin);
dGftMax=dGft0Max+rt*log(concMax);

%check to make sure not overlapping
if dGftMin>dGftMax
    error('dGtMin greater than dGtMax');
else
    for m=1:nMet
        model.met(m).dGftMin=dGftMin(m);
        model.met(m).dGftMax=dGftMax(m);
    end
    model.dGftMin=dGftMin';
    model.dGftMax=dGftMax';
end
%metabolites without thermodynamic information
model.NaNdGf0MetBool=nan_dGformationBool;

if figures==1
    figure; hold on;
    plot(concMax,'.');
    plot(concMin,'.r');
    legend('max','min');
    title('Maximum and minimum concentration (Molar)','FontSize',16);
    xlabel('Metabolites','FontSize',16);
    ylabel('Concentration (Molar)','FontSize',16);
end
if figures==1
    muMean=(dGftMin+dGftMax)/2;
    [s,sInd]=sort(muMean);
    figure; hold on;
    xx=1:nnz(~model.NaNdGf0MetBool);
    dGftMaxSorted=dGftMax(sInd);
    dGftMinSorted=dGftMin(sInd);
    plot(xx,dGftMaxSorted(~model.NaNdGf0MetBool),'.');
    plot(xx,dGftMinSorted(~model.NaNdGf0MetBool),'.r');
    legend('max','min');
    %     if max(GroupCont_dGformationBool)==1
    %         %sort boolean
    %         GroupCont_dGformationBool=GroupCont_dGformationBool(sInd);
    %         %plot sorted GroupCont data.
    %         plot(xx(GroupCont_dGformationBool),dGtMin(GroupCont_dGformationBool),'*r');
    %         plot(xx(GroupCont_dGformationBool),dGtMax(GroupCont_dGformationBool),'*');
    %     end
    title('Maximum and minimum \Delta_{f}G^{\prime} (kJ)','FontSize',16);
    xlabel('Metabolites, sorted by \Delta_{f}G^{\prime}','FontSize',16);
    ylabel('\Delta_{f}G^{\prime} kJ)','FontSize',16);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%REACTION PROPERTIES%%%%%%%%%%%%%%%%%%%%
%identify reactions that are affected by NaN dGf
imBalancedMass = cell(size(model.rxns'));
imBalancedMass(1:length(model.imBalancedMass)) = model.imBalancedMass;
imBalancedCharge = zeros(size(model.rxns'));
imBalancedCharge(1:length(model.imBalancedCharge)) = model.imBalancedCharge;
nanRxn=(sum(abs(model.S(nan_dGformationBool,:)),1)~=0) | (sum(model.S ~= 0, 1) == 1) | ~cellfun('isempty',imBalancedMass) | imBalancedCharge~=0; % Added "| (sum(model.S ~= 0, 1) == 1)" so nanRxn is true for demand reactions - Hulda
%reactions with NaN dG0
model.NaNdG0RxnBool=nanRxn';

boolH=false(nMet,1);
%indices of protons
for m=1:nMet
    if strcmp(model.mets{m}(1:2),'h[')
        boolH(m)=1;
    end
end

%min and max change in chemical potential
Spos=model.S;
Spos(model.S<0)=0;
Spos(boolH,:)=0; %hydrogen ion chemical potential only used for transport reaction
Sneg=model.S;
Sneg(model.S>0)=0;
Sneg(boolH,:)=0; %hydrogen ion chemical potential only used for transport reaction

metAbbrReconShort=cell(nMet,1);
for m=1:nMet
    metAbbr=model.mets{m};
    metAbbrReconShort{m,1}=metAbbr(1:end-3);
end
% Commented out following if statement. - Hulda
% if errorKeq~=0
%     error('This next section of code assumes that there is no error in the  delta Go from Keq')
% end
% - Hulda

% %identify reactions which transport between different compartments
% %then generate a matrix, which:
% %1. when multiplied by hydrogen ion chemical potential, gives the change
% % in proton chemical potential. (initial minus final)
% %1. when multiplied by electrical potential, gives the change
% % in electrical potential.  (initial minus final)
% model.transportRxnBool=false(nRxn,1);
% model.transportRxnBool2 = substrateProductIndexH(:,1)~=0 & substrateProductIndexH(:,2)~=0 & substrateProductIndexH(:,1)~=substrateProductIndexH(:,2);
% substrateProductIndexH(substrateProductIndexH(:,1)==substrateProductIndexH(:,2),:)=0;
%
% %designed to give initial minus final compartment property
% deltaMatrix=zeros(nRxn,nMet);
% for n=1:nRxn
%     deltaMatrix(n,substrateProductIndexH(n,1)) =  1;
%     deltaMatrix(n,substrateProductIndexH(n,2)) = -1;
% end

% for n=1:nRxn
%     %only for internal reactions
%     if model.SIntRxnBool(n)
%         metAbbrAll=model.mets(model.S(:,n)~=0);
%         metAbbrAllShort=cell(length(metAbbrAll),1);
%         for q=1:length(metAbbrAll)
%             metAbbr=metAbbrAll{q};
%             %omit compartment
%             metAbbrAllShort{q}=metAbbr(1:end-3);
%         end
%         %check for duplication of a metabolite
%         [bu, mu, nu] = unique(metAbbrAllShort);
%         if length(bu)~=length(metAbbrAllShort)
%             %save the transport reactions
%             model.transportRxnBool(n)=1;
%         end
%     end
% end
numChar=1;
[transportRxnBool]=transportReactionBool(model,numChar);
model.transportRxnBool=transportRxnBool;


% Implementation of uncertainty calculations in terms of groups - Hulda
SnoH = model.S;
SnoH(boolH,:) = 0;

% Create group incidence matrix for metabolites in model using jankowskiGroupData
nMetGroups = createGroupIncidenceMatrix(model,gcmOutputFile,gcmMetList,jankowskiGroupData);

% Calculate standard transformed reaction Gibbs energies with uncertainty,
% as well as transformed reaction Gibbs energies
nRxnGroups = SnoH'*nMetGroups;
groupData = jankowskiGroupData;

u_r = sqrt(nRxnGroups.^2 * (4.18400*groupData.SEgr).^2);

DfGit0 = dGft0Min + (dGft0Max - dGft0Min)/2;
DrGkt0 = SnoH'*DfGit0';

dGt0Max = DrGkt0 + nStdDevGroupCont*u_r;
dGt0Min = DrGkt0 - nStdDevGroupCont*u_r;
dGtMax = dGt0Max + 8.3144621e-3*310.15*(Spos'*log(concMax') + Sneg'*log(concMin'));
dGtMin = dGt0Min + 8.3144621e-3*310.15*(Spos'*log(concMin') + Sneg'*log(concMax'));

% - Hulda

% dGtmM defined the old way as we don't need it at this point
dGtmMMax=(dGftmMMin*Sneg+dGftmMMax*Spos);
dGtmMMin=(dGftmMMax*Sneg+dGftmMMin*Spos);


% Commented out after implementing uncertainty cancellations for all
% reactions based on identical structural groups in metabolites
%
% fprintf('%s\n','Ensuring that uncertainty is not factored into the dGt0 or dGt for transport reactions.')
% for n=1:nRxn
%     disp(n)
%     if model.transportRxnBool(n)
%         %be careful of transport reactions since group contribution uncertainty
%         %should not come into it for certain metabolites, if the same metabolite
%         %appears on both sides of the reaction
% 
%         fix=0;
%         dGft0MinTemp=dGft0Min;
%         dGft0MaxTemp=dGft0Max;
%         dGftmMMinTemp=dGftmMMin;
%         dGftmMMaxTemp=dGftmMMax;
%         dGftMinTemp=dGftMin;
%         dGftMaxTemp=dGftMax;
% 
%         metAbbrAll=model.mets(model.S(:,n)~=0);
%         metAbbrAllShort=cell(length(metAbbrAll),1);
%         for p=1:length(metAbbrAllShort) % Added this for loop - Hulda
%             metAbbrAllShort{p}=metAbbrAll{p}(1:(end-2));
%         end % - Hulda
% 
%         for p=1:length(metAbbrAllShort)
%             metBool=strcmp(metAbbrAll{p},model.mets);
%             %find the duplicated metabolite
%             if nnz(strcmp(metAbbrAllShort{p},metAbbrAllShort))>1;% &&  strcmp(model.met(metBool).dGft0Source,'GC') % Do not assume no uncertainty in data from Alberty - Hulda
%                 %this metabolite is on both sides of the reaction
%                 %we assume here that there is no uncertainty in the
%                 %data from Alberty.
%                 fix=1;
% 
%                 %if isnan then approximate with zero, this will ignore
%                 %ionic strength effects between compartments
%                 if isnan(model.met(metBool).dGft0)
%                     dGft0MinTemp(metBool)=0;
%                     dGft0MaxTemp(metBool)=0;
%                     dGftmMMinTemp(metBool)=0;
%                     dGftmMMaxTemp(metBool)=0;
%                     dGftMinTemp(metBool)=0;
%                     dGftMaxTemp(metBool)=0;
%                 else
%                     dGft0MinTemp(metBool)=model.met(metBool).dGft0;
%                     dGft0MaxTemp(metBool)=model.met(metBool).dGft0;
%                     dGftmMMinTemp(metBool)=model.met(metBool).dGft0;
%                     dGftmMMaxTemp(metBool)=model.met(metBool).dGft0;
%                     dGftMinTemp(metBool)=model.met(metBool).dGft0 + rt*log(concMin(metBool));
%                     dGftMaxTemp(metBool)=model.met(metBool).dGft0 + rt*log(concMax(metBool));
%                 end
%             end
%         end
%         %Use temp values to ensure that uncertainty is not factored into the drGt0 for transport reactions
%         if fix
%             %min and max standard change in chemical potential
%             %note that these values may still be nonzero if the pH, or
%             %ionic strength is different in the different compartments.
%             dGt0Max(n)=(dGft0MinTemp*Sneg(:,n)+dGft0MaxTemp*Spos(:,n))./max(abs(normalizationS(:,n)), [], 1);
%             dGt0Min(n)=(dGft0MaxTemp*Sneg(:,n)+dGft0MinTemp*Spos(:,n))./max(abs(normalizationS(:,n)), [], 1);
%             %thor standard
%             dGtmMMax(n)=(dGftmMMinTemp*Sneg(:,n)+dGftmMMaxTemp*Spos(:,n))./max(abs(normalizationS(:,n)), [], 1);
%             dGtmMMin(n)=(dGftmMMaxTemp*Sneg(:,n)+dGftmMMinTemp*Spos(:,n))./max(abs(normalizationS(:,n)), [], 1);
%             %
%             dGtMax(n)=(dGftMinTemp*Sneg(:,n)+dGftMaxTemp*Spos(:,n))./max(abs(normalizationS(:,n)), [], 1);
%             dGtMin(n)=(dGftMaxTemp*Sneg(:,n)+dGftMinTemp*Spos(:,n))./max(abs(normalizationS(:,n)), [], 1);
%         end
%    end
% end
% 
% - Hulda

%number of hydrogen in each metabolite species as per reconstruction
reconstructionH=sparse(nMet,1);
%charge of each metabolite species as per reconstruction
reconstructionQ=sparse(nMet,1);
for m=1:nMet
    if isfield(model,'gcmS') % Use species returned by group contribution method
        if any(isnan((model.met(m).formulaMarvin)))
            if strcmp(model.met(m).formula,'')
                reconstructionH(m)=NaN;
                reconstructionQ(m) = model.met(m).chargeMarvin;
            else
                reconstructionH(m) = numAtomsOfElementInFormula(model.met(m).formula,'H'); % Use reconstruction data if no group contribution estimate is available
                reconstructionQ(m) = model.met(m).charge;
            end
        else
            reconstructionH(m) = numAtomsOfElementInFormula(model.met(m).formulaMarvin,'H');
            reconstructionQ(m) = model.met(m).chargeMarvin;
        end
    else
        if strcmp(model.met(m).formula,'')
            reconstructionH(m)=NaN;
        else
            reconstructionH(m) = numAtomsOfElementInFormula(model.met(m).formula,'H');
        end
        reconstructionQ(m) = model.met(m).charge;
    end
end

[allMetCompartments,uniqueMetCompartments]=getCompartment(model.mets);
nUniqueMetCompartments=length(uniqueMetCompartments);

A=sparse(nMet,nUniqueMetCompartments);
for m=1:nMet
    A(m,strcmp(allMetCompartments{m},uniqueMetCompartments))=1;
end

dGfHcompartment=zeros(nUniqueMetCompartments,1);
CHIcompartment=zeros(nUniqueMetCompartments,1);
for p=1:nUniqueMetCompartments
    dGfHcompartment(p)=model.met(strcmp(model.mets,['h[' uniqueMetCompartments{p} ']'])).dGf;
    
    chi=model.CHI.(uniqueMetCompartments{p});
    %Electrical Potential conversion from mV to kJ with Faraday constant
    %eq 8.5-1 p148 Alberty 2003
    CHIcompartment(p)=model.faradayConstant*(chi/1000);
end

if Legendre
    fprintf('%s\n','Additional effect due to possible change in chemical potential of Hydrogen ions for transport reactions.')
    
    if isfield(model,'gcmS')
        %use reaction stoichiometry for species returned by group
        %contribution method
        delta  = -model.gcmS'*diag(reconstructionH)*A*dGfHcompartment;
    elseif isfield(model,'Srecon')
        %use the reconstruction stoichiometry without adjustment to proton
        %stoichiometric coefficient
        delta  = -model.Srecon'*diag(reconstructionH)*A*dGfHcompartment;
    else
        delta  = -model.S'*diag(reconstructionH)*A*dGfHcompartment;
    end
    %ignore exchange reactions
    delta(~model.SIntRxnBool)=0;
    
    %adjust the change in chemical potential due to difference in hydrogen ion
    %chemical potential between compartments
    dGt0Min  = dGt0Min'  - delta';
    dGt0Max  = dGt0Max'  - delta';
    dGtmMMin = dGtmMMin - delta';
    dGtmMMax = dGtmMMax - delta';
    dGtMin   = dGtMin'  - delta';
    dGtMax   = dGtMax'  - delta';
end
% Hulda

%TODO - compartment matrix to streamline code
if LegendreCHI
    fprintf('%s\n','Additional effect due to possible change in electrical potential for transport reactions.')
    
    if isfield(model,'gcmS')
        %use reaction stoichiometry for species returned by group
        %contribution method
        deltaCHI  = -model.gcmS'*diag(reconstructionQ)*A*CHIcompartment;
    elseif isfield(model,'Srecon')
        %use the reconstruction stoichiometry without adjustment to proton
        %stoichiometric coefficient
        deltaCHI  = -model.Srecon'*diag(reconstructionQ)*A*CHIcompartment;
    else
        deltaCHI  = -model.S'*diag(reconstructionQ)*A*CHIcompartment;
    end
    %ignore exchange reactions
    deltaCHI(~model.SIntRxnBool)=0;
    
    %adjust the change in chemical potential due to difference in hydrogen ion
    %chemical potential between compartments
    dGt0Min  = dGt0Min  - deltaCHI';
    dGt0Max  = dGt0Max  - deltaCHI';
    dGtmMMin = dGtmMMin - deltaCHI';
    dGtmMMax = dGtmMMax - deltaCHI';
    dGtMin   = dGtMin  - deltaCHI';
    dGtMax   = dGtMax  - deltaCHI';
end

model.NaNdG0RxnBool = model.NaNdG0RxnBool | isnan(dGt0Min');
%ok, now it is safe to assign these values since the error for transport not
%taken into account, and the additional change due to difference in
%hydrogen ion chemical potential between compartments is.
if any(dGt0Min>dGt0Max)
    error('dGt0Min greater than dGt0Max');
else
    for n=1:nRxn
        model.rxn(n).dGt0Min=dGt0Min(n);
        model.rxn(n).dGt0Max=dGt0Max(n);
    end
    model.dGt0Max=dGt0Max;
    model.dGt0Min=dGt0Min;
end

if any(dGtmMMin>dGtmMMax)
    error('dGtmMMin greater than dGtmMMax');
else
    for n=1:nRxn
        model.rxn(n).dGtmMMin=dGtmMMin(n);
        model.rxn(n).dGtmMMax=dGtmMMax(n);
    end
end

if any(dGtMin>dGtMax)
    error('dGtMin greater than dGtMax');
else
    for n=1:nRxn
        model.rxn(n).dGtMin=dGtMin(n);
        model.rxn(n).dGtMax=dGtMax(n);
    end
    model.dGtMax=dGtMax;
    model.dGtMin=dGtMin;
end

if figures==1
    dmu0Mean=(dGt0Min+dGt0Max)/2;
    [s,sInd]=sort(dmu0Mean);
    figure; hold on;
    dGt0MaxSorted=dGt0Max(sInd);
    dGt0MinSorted=dGt0Min(sInd);
    plot(dGt0MaxSorted(~model.NaNdG0RxnBool),'.');
    plot(dGt0MinSorted(~model.NaNdG0RxnBool),'.r');
    legend('max','min');
    title('Maximum and minimum \Delta_{r}G^{\primeo} (kJ)','FontSize',16);
    xlabel('Reactions, sorted by \Delta_{r}G^{\primeo}','FontSize',16);
    ylabel('\Delta_{r}G^{\primeo} (kJ)','FontSize',16);
    hold off;
    
    dGt0Mean=(dGt0Min+dGt0Max)/2;
    [s,sInd]=sort(dGt0Mean);
    figure; hold on;
    dGt0MaxSorted=dGt0Max(sInd)/rt;
    dGt0MinSorted=dGt0Min(sInd)/rt;
    plot(dGt0MaxSorted(~model.NaNdG0RxnBool),'.');
    plot(dGt0MinSorted(~model.NaNdG0RxnBool),'.r');
    legend('max','min');
    title('Maximum and minimum \Delta_{r}G^{\primeo} (kJ/RT)','FontSize',16);
    xlabel('All reactions, sorted by \Delta_{r}G^{\primeo}','FontSize',16);
    ylabel('\Delta_{r}G^{\primeo} (kJ/RT)','FontSize',16);
    hold off;
end

if figures==1
    dGtMean=(dGtMin+dGtMax)/2;
    [s,sInd]=sort(dGtMean);
    figure; hold on;
    dGtMaxSorted=dGtMax(sInd);
    dGtMinSorted=dGtMin(sInd);
    plot(dGtMaxSorted(~model.NaNdG0RxnBool),'.');
    plot(dGtMinSorted(~model.NaNdG0RxnBool),'.r');
    legend('max','min');
    title('Maximum and minimum \Delta_{r}G^{\prime} (kJ)','FontSize',16);
    xlabel('All reactions, sorted by \Delta_{r}G^{\prime}','FontSize',16);
    ylabel('\Delta_{r}G^{\prime} (kJ/RT)','FontSize',16);
    hold off;
    
    dmuMean=(dGtMin+dGtMax)/2;
    [s,sInd]=sort(dmuMean);
    figure; hold on;
    dGtMaxSorted=dGtMax(sInd)/rt;
    dGtMinSorted=dGtMin(sInd)/rt;
    plot(dGtMaxSorted(~model.NaNdG0RxnBool),'.');
    plot(dGtMinSorted(~model.NaNdG0RxnBool),'.r');
    legend('max','min');
    title('Maximum and minimum \Delta_{r}G^{\prime} (kJ/RT)','FontSize',16);
    xlabel('All reactions, sorted by \Delta_{r}G^{\prime}','FontSize',16);
    ylabel('\Delta_{r}G^{\prime} (kJ/RT)','FontSize',16);
    hold off;
end

%reaction directionality
%keep exchange bounds the same as for the recostruction
model.lb_reconThermo=model.lb;
model.ub_reconThermo=model.ub;
%now set internal reaction directions
for n=1:nRxn
    if model.SIntRxnBool(n)
        if nanRxn(n)
            %for the reactions that involve a NaN metabolite standard Gibbs energy of
            %formation, use the directions given by the reconstruction
            if model.lb(n)<0 && model.ub(n)>0
                model.lb_reconThermo(n)=-Inf;
                model.ub_reconThermo(n)=Inf;
            end
            %forward
            if model.lb(n)>=0 && model.ub(n)>0
                model.lb_reconThermo(n)=0;
                model.ub_reconThermo(n)=Inf;
            end
            %reverse
            if model.lb(n)<0 && model.ub(n)<=0
                model.lb_reconThermo(n)=-Inf;
                model.ub_reconThermo(n)=0;
            end
            if 0 %from Nov 22nd 2011 Ignore reactions where lb=ub=0 - Hulda
                if model.lb(n)==0 && model.ub(n)==0
                    error(['Reaction ' model.rxns{n} ' set to zero'])
                end
            end
            %note that there is no thermodynamic directionality assignment
            %for this reaction
            model.rxn(n).directionalityThermo=NaN;
        else
            if dGtMax(n)<0
                model.rxn(n).directionalityThermo='forward';
                model.lb_reconThermo(n)=0;
                model.ub_reconThermo(n)=Inf;
            end
            if dGtMin(n)>0
                model.rxn(n).directionalityThermo='reverse';
                model.lb_reconThermo(n)=-Inf;
                model.ub_reconThermo(n)=0;
            end
            if dGtMin(n)<0 && dGtMax(n)>0;
                model.rxn(n).directionalityThermo='reversible';
                model.lb_reconThermo(n)=-Inf;
                model.ub_reconThermo(n)=Inf;
            end
            if dGtMin(n)==dGtMax(n)
                model.rxn(n).directionalityThermo='equilibrium';
            end
            if 0 %from Jan 30th 2011 Ignore reactions where lb=ub=0
                if model.lb(n)==0 && model.ub(n)==0
                    error(['Reaction ' model.rxns{n} ' set to zero'])
                end
            end
        end
    end
end

model.dGt0Max = columnVector(model.dGt0Max);
model.dGt0Min = columnVector(model.dGt0Min);
model.dGtMax = columnVector(model.dGtMax);
model.dGtMin = columnVector(model.dGtMin);