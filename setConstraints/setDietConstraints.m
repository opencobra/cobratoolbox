function modelOrganAll = setDietConstraints(modelOrganAll, Diet)
%units are given in mmol/day/person

% define diet
if ~exist('Diet','var')
    EUAverageDiet;
    % Diet variable was not read. AH 16/12/01
elseif strcmp(Diet,'EUAverageDiet')
    EUAverageDiet;
elseif strcmp(Diet,'HighFiberDiet')
    HighFiberDiet;
elseif strcmp(Diet,'HighProteinDiet')
    HighProteinDiet;
elseif strcmp(Diet,'UnhealthyDiet')
    UnhealthyDiet;
elseif strcmp(Diet,'VegetarianDiet')
    VegetarianDiet;
end

microbiotaEnabling =1; % consider essential microbial metabolites to be added to diet

% load essential metabolite list for AGORA models
AGORAEssentialMetabolites;
AGORAessential = regexprep(AGORAessential,'EX_','Diet_EX_');
AGORAessential = regexprep(AGORAessential,'\[u\]','\[d\]');

% set all  uptakes to 0
tmp = strmatch('Diet_EX_',modelOrganAll.rxns);
modelO = modelOrganAll;
modelOrganAll.lb(tmp(1:end))=0;

% ensure uptake of metabolites required for microbiota (may not all be
% needed) -- I should really check which ones of those are need
if microbiotaEnabling == 1
    MissingUptakes = setdiff(AGORAessential,Diet(:,1));
    % open uptake for those reactions
    % set constraints to a default
    modelOrganAll.lb(ismember(modelOrganAll.rxns,MissingUptakes))=-0.1;
end

MissingDietCompounds={'Diet_EX_asn_L[d]'; 'Diet_EX_gln_L[d]';'Diet_EX_chol[d]'};
modelOrganAll.lb(ismember(modelOrganAll.rxns,MissingDietCompounds))=-50;

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
    'Diet_EX_zn2[d]'	
    };
%no uptake enforced but max uptake rate
ions={    'Diet_EX_na1[d]'	%'0.056546816'
    'Diet_EX_cl[d]'	%'0.056412715'
    'Diet_EX_k[d]'	%'0.12020983'
    'Diet_EX_pi[d]'	%'0.007143207'
    };

for i = 1:  size(Diet,1)
    R = Diet{i,1};
    % exception for micronutrients to avoid numberical issues
    if ~isempty(find(ismember(micronutrients,R)))&& str2num(Diet{i,2})<=0.1
        modelOrganAll.lb(find(ismember(modelOrganAll.rxns,R))) = -0.1;%-1.2*str2num(Diet{i,2})*factor;
    elseif ~isempty(find(ismember(micronutrients,R))) && str2num(Diet{i,2})>0.1
        modelOrganAll.lb(find(ismember(modelOrganAll.rxns,R))) = -1.2*str2num(Diet{i,2});
    elseif ~isempty(find(ismember(ions,R)))
        modelOrganAll.lb(find(ismember(modelOrganAll.rxns,R))) = -1.2*str2num(Diet{i,2});
    else
        modelOrganAll.lb(find(ismember(modelOrganAll.rxns,R))) = -1.2*str2num(Diet{i,2});
    end
end
% do not enforce diet uptake --> set if statement to 0
if 1
    for i = 1:size(Diet,1) % fine until 70
        R = Diet{i,1};
        if ~isempty(find(ismember(micronutrients,R)))
            modelOrganAll.ub(find(ismember(modelOrganAll.rxns,R))) =  -0.8*str2num(Diet{i,2});
        elseif ~isempty(find(ismember(ions,R)))
            modelOrganAll.ub(find(ismember(modelOrganAll.rxns,R))) = -0.8*str2num(Diet{i,2});
        else
            modelOrganAll.ub(find(ismember(modelOrganAll.rxns,R))) = -0.8*str2num(Diet{i,2});
        end
    end
end

modelOrganAll.SetupInfo.DietComposition = Diet;

