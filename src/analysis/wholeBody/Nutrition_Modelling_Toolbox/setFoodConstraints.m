function model = setFoodConstraints(model, foodMenu, compensateDiet)
% This function sets diet/food constraints for uptake reactions of 
% a whole-body metabolic model.
%
% function model = setFoodConstraints(model, Diet, factor)
%
% INPUT
%   model         model structure
%   foodMenu      {column vector of food items, column vector of serving mass (g))
%Optional Input:
%   compensateDiet   boolean 0 and 1; 1 indicates to compensate for gaps in nutrition components in the EUAverageDiet. default is 1

% OUTPUT
%   model         updated model
%
% AUTHORS
%   Bronson R. Weston 2021-2022

%Add any food reactions if necessary
foodMenu=makeDietFormatConsistant(model,foodMenu);
[model,~] = addFoodRxns2HM(model,foodMenu(:,1));

%Clear any current dietary/food reaction fluxes
fdRxns=find(contains(model.rxns,'Food_EX_'));
metRxns=find(contains(model.rxns,'Diet_EX_'));
model.lb(fdRxns)=0;
model.ub(fdRxns)=0;
model.lb(metRxns)=0;
model.ub(metRxns)=0;

%Add diet components
for i=1:length(foodMenu(:,1))
    %     foodMenu{i,1}
    %     find(ismember(model.rxns,foodMenu{i,1}))
    if ischar(foodMenu{i,2})
        val= -1*str2num(foodMenu{i,2});
    else
        val= -1*foodMenu{i,2};
    end
    model.ub(find(ismember(model.rxns,foodMenu{i,1}))) = val;
    model.lb(find(ismember(model.rxns,foodMenu{i,1}))) = val;
    if isempty(find(ismember(model.rxns,foodMenu{i,1})))
        error(['"' foodMenu{i,1} '" is not a valid food item/ metabolite'])
    end
end

if ~exist('compensateDiet','var')
    compensateDiet=1;
end


% load 'fdTable.mat'
% load 'fdCategoriesTable.mat'
metFlux = getMetaboliteFlux(foodMenu);

if compensateDiet~=1
    model.SetupInfo.DietComposition = metFlux;
    return
end

% If compensating diet, make changes in accordance with setDietConstraints
% and EUAverageDietNew

EUAverageDietNew
Diet = getMetaboliteFlux(Diet);

for i=1:length(Diet(:,1))
    [missingEUmets,ind]=setdiff(Diet(:,1),metFlux(:,1));
    metFlux=[metFlux; Diet(ind,:)];
end


microbiotaEnabling =1; % consider essential microbial metabolites to be added to diet

% load essential metabolite list for AGORA models
AGORAEssentialMetabolites;
AGORAessential = regexprep(AGORAessential,'EX_','Diet_EX_');
AGORAessential = regexprep(AGORAessential,'\[u\]','\[d\]');

% ensure uptake of metabolites required for microbiota (may not all be
% needed)
if microbiotaEnabling == 1
    MissingUptakes = setdiff(AGORAessential,metFlux(:,1));
    % open uptake for those reactions
    % set constraints to a default
    model.lb(ismember(model.rxns,MissingUptakes))=-0.1;
end

% these compounds are in the diet and needed for the proper function of the
% model but are not reported in our diet database
if 1
    PotentialMissingDietCompounds={'Diet_EX_asn_L[d]'; 'Diet_EX_gln_L[d]';'Diet_EX_chol[d]';'Diet_EX_crn[d]';'Diet_EX_elaid[d]';...
        'Diet_EX_hdcea[d]';'Diet_EX_dlnlcg[d]';'Diet_EX_adrn[d]';'Diet_EX_hco3[d]';...
        'Diet_EX_sprm[d]'; 'Diet_EX_carn[d]';'Diet_EX_7thf[d]';...
        'Diet_EX_Lcystin[d]';%??
        'Diet_EX_hista[d]';'Diet_EX_orn[d]';...
        'Diet_EX_ptrc[d]';'Diet_EX_creat[d]';
        'Diet_EX_cytd[d]'; 'Diet_EX_so4[d]'
        };
    MissingDietCompounds=setdiff(PotentialMissingDietCompounds,metFlux(:,1));
    model.lb(ismember(model.rxns,MissingDietCompounds))=-50;
end


% micronutrient - defined to have mole/day/person rate below 1e-6 mol/day/person
% lower bounds will be relaxed by factor 10
micronutrients ={%'Diet_EX_adpcbl[d]'
    % I changed the exchange ID since it was generated based on the
    % metabolite (ID adocbl). AH 16/12/01
    'Diet_EX_adocbl[d]'
    'Diet_EX_vitd2[d]'
    'Diet_EX_vitd3[d]'
    'Diet_EX_psyl[d]'
    'Diet_EX_gum[d]'
    'Diet_EX_bglc[d]'
    'Diet_EX_phyQ[d]'
    'Diet_EX_fol[d]'
    'Diet_EX_5mthf[d]'
    'Diet_EX_q10[d]'
    'Diet_EX_retinol_9_cis[d]'
    'Diet_EX_pydxn[d]'
    'Diet_EX_pydam[d]'
    'Diet_EX_pydx[d]'
    'Diet_EX_pheme[d]'
    'Diet_EX_ribflv[d]'
    'Diet_EX_thm[d]'
    % added 24.08.2016
    'Diet_EX_avite1[d]'
    'Diet_EX_pnto_R[d]'
    };
%no uptake enforced but max uptake rate
ions={    'Diet_EX_na1[d]'	%'0.056546816'
    'Diet_EX_cl[d]'	%'0.056412715'
    'Diet_EX_k[d]'	%'0.12020983'
    'Diet_EX_pi[d]'	%'0.007143207'
    'Diet_EX_zn2[d]'
    'Diet_EX_cu2[d]'
    };
so4={
    %02.06.2017
    'Diet_EX_so4[d]' % see text above about addition of met for brain demand
    };

for i = 1:  size(metFlux(:,1),1)
    R = metFlux{i,1};
    index=find(ismember(model.rxns,R));
    % exception for micronutrients to avoid numberical issues
    if ~isempty(find(ismember(micronutrients,R)))&& metFlux{i,2}<=10
        model.lb(index) = -10;
        model.ub(index) = -10;
%     elseif ~isempty(find(ismember(micronutrients,R))) &&  metFlux{i,2}<0.1
%         model.lb(index) = -1*metFlux{i,2}*99 +model.lb(index);
%         model.ub(index) = model.lb(index);
    elseif ~isempty(find(ismember(ions,R)))
        model.lb(index) = -1* metFlux{i,2}*99+model.lb(index);
        model.ub(index) = model.lb(index);
    elseif ~isempty(find(ismember(so4,R)))
        model.lb(index) = -1000;
        model.ub(index) = -1000;
    elseif ~isempty(find(ismember(missingEUmets,R)))
        model.lb(index) = -1* metFlux{i,2}+model.lb(index);
        model.ub(index) = model.lb(index);
    end
end

model.SetupInfo.DietComposition = metFlux;