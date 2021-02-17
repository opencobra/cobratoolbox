%create Harvey_1.01 and Harvetta_1.01

if strcmp(gender,'male')
    load  2018_03_29_HMP_male_GF_patched
    modelOrganAllCoupled = male;
    clear male
elseif strcmp(gender,'female')
    load  2018_03_29_HMP_female_GF_patched
    modelOrganAllCoupled = female;
    clear female
end

standardPhysiolDefaultParameters;
% 3. set personalized constraints
% [modelOrganAllCoupled,IndividualParametersPersonalized] = individualizedLabReport(modelOrganAllCoupled,IndividualParameters, [InputData(:,1) InputData(:,2) InputData(:,ID)]);
% modelOrganAllCoupled.IndividualParametersPersonalized = IndividualParametersPersonalized;

% [listOrgan,OrganWeight,OrganWeightFract] = calcOrganFract(modelOrganAllCoupled,IndividualParametersPersonalized);
% adjust whole body maintenance reaction based on new organ weight
% fractions
%  [modelOrganAllCoupled] = adjustWholeBodyRxnCoeff(modelOrganAllCoupled, listOrgan, OrganWeightFract);
% apply HMDB metabolomic data based on personalized individual parameters
modelOrganAllCoupled = physiologicalConstraintsHMDBbased(modelOrganAllCoupled,IndividualParameters);
% set some more constraints
modelOrganAllCoupled = setSimulationConstraints(modelOrganAllCoupled);
modelOrganAllCoupled.status = 'NOT personalized Harvey/Harvetta';
%  modelOrganAllCoupled.InputData = [InputData(:,1) InputData(:,2) InputData(:,ID)];
% set microbial excretion constraint
modelOrganAllCoupled.lb(find(ismember(modelOrganAllCoupled.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=1; %
modelOrganAllCoupled.ub(find(ismember(modelOrganAllCoupled.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=1; %
modelOrganAllCoupled.lb(find(ismember(modelOrganAllCoupled.rxns,'Whole_body_objective_rxn')))=1; %
modelOrganAllCoupled.ub(find(ismember(modelOrganAllCoupled.rxns,'Whole_body_objective_rxn')))=1; %
%
%     modelOrganAllCoupled.lb(strmatch('BBB_KYNATE[CSF]upt',modelOrganAllCoupled.rxns)) = -1000000; %constrained uptake
%     modelOrganAllCoupled.lb(strmatch('BBB_LKYNR[CSF]upt',modelOrganAllCoupled.rxns)) = -1000000; %constrained uptake
%     modelOrganAllCoupled.lb(strmatch('BBB_TRP_L[CSF]upt',modelOrganAllCoupled.rxns)) = -1000000; %constrained uptake
%
%     modelOrganAllCoupled.lb(strmatch('BBB_HC02194[CSF]upt',modelOrganAllCoupled.rxns)) = -1000000; %constrained uptake
%     modelOrganAllCoupled.lb(strmatch('BBB_CHOLATE[CSF]upt',modelOrganAllCoupled.rxns)) = -1000000; %constrained uptake
%     modelOrganAllCoupled.lb(strmatch('BBB_GCHOLA[CSF]upt',modelOrganAllCoupled.rxns)) = -1000000; %constrained uptake
%     modelOrganAllCoupled.lb(strmatch('BBB_TDCHOLA[CSF]upt',modelOrganAllCoupled.rxns)) = -1000000; %constrained uptake
%     modelOrganAllCoupled.lb(strmatch('BBB_DGCHOL[CSF]upt',modelOrganAllCoupled.rxns)) = -1000000; %constrained uptake
%     modelOrganAllCoupled.lb(strmatch('BBB_TCHOLA[CSF]upt',modelOrganAllCoupled.rxns)) = -1000000; %constrained uptake
%     modelOrganAllCoupled.lb(strmatch('BBB_C02528[CSF]upt',modelOrganAllCoupled.rxns)) = -1000000; %constrained uptake

% open bileduct reactions for bile acids
Rxns={
    'BileDuct_EX_cholate[bd]_[luSI]'
    'BileDuct_EX_dchac[bd]_[luSI]'
    'BileDuct_EX_dgchol[bd]_[luSI]'
    'BileDuct_EX_gchola[bd]_[luSI]'
    'BileDuct_EX_tchola[bd]_[luSI]'
    'BileDuct_EX_tdchola[bd]_[luSI]'
    'BileDuct_EX_tdechola[bd]_[luSI]'
    'BileDuct_EX_12dhchol[bd]_[luSI]'
    'BileDuct_EX_7dhchol[bd]_[luSI]'
    'BileDuct_EX_7dhcdchol[bd]_[luSI]'
    'BileDuct_EX_uchol[bd]_[luSI]'
    'BileDuct_EX_3dhchol[bd]_[luSI]'
    'BileDuct_EX_3dhcdchol[bd]_[luSI]'
    'BileDuct_EX_isochol[bd]_[luSI]'
    'BileDuct_EX_icdchol[bd]_[luSI]'
    'BileDuct_EX_thyochol[bd]_[luSI]'
    'BileDuct_EX_hyochol[bd]_[luSI]'
    'BileDuct_EX_3dhdchol[bd]_[luSI]'
    'BileDuct_EX_3dhlchol[bd]_[luSI]'
    'BileDuct_EX_cdca24g[bd]_[luSI]'
    'BileDuct_EX_cdca3g[bd]_[luSI]'
    'BileDuct_EX_lca24g[bd]_[luSI]'
    'BileDuct_EX_hdca6g[bd]_[luSI]'
    'BileDuct_EX_hdca24g[bd]_[luSI]'
    'BileDuct_EX_dca3g[bd]_[luSI]'
    'BileDuct_EX_dca24g[bd]_[luSI]'
    'BileDuct_EX_hca6g[bd]_[luSI]'
    'BileDuct_EX_hca24g[bd]_[luSI]'};

for i = 1 : length(Rxns)
    modelOrganAllCoupled = changeRxnBounds(modelOrganAllCoupled,Rxns{i},100,'u');
end

modelOrganAllCoupled.ub(strmatch('Brain_EX_glc_D(',modelOrganAllCoupled.rxns)) = -100; % currently -400 rendering many of the models to be infeasible in germfree state
modelOrganAllCoupled.lb(strmatch('Brain_DM_atp_c_',modelOrganAllCoupled.rxns)) = 1000; % currently -400 rendering many of the models to be infeasible in germfree state

[modelOrganAllCoupled]= addReactions4microbes(modelOrganAllCoupled);
EUAverageDietNew;
modelOrganAllCoupled = setDietConstraints(modelOrganAllCoupled, Diet);

if strcmp(gender,'male')
    male = modelOrganAllCoupled;
    save(strcat('Harvey_1_01c.mat'), 'male');
else
    Results.gender = 'female';
    female = modelOrganAllCoupled;
    save(strcat('Harvetta_1_01c.mat'), 'female');
end