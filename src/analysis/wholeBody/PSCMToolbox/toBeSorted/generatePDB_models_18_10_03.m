if set==1
    pathdef;
    addpath(genpath('../../HH_final'))
    addpath(genpath('/home/ines.thiele/P/GitHub/codeBaseHarveyAnalysis'))
    addpath(genpath('/home/ines.thiele/P/GitHub/_cobraHARVEYGenerationONLY'))
    addpath(genpath('/opt/tomlab'))
end

%% prepare HH
% load HH
load Harvey_1_01c % male
%load Harvetta_1_01c % female

% % set constraints for HH
% standardPhysiolDefaultParameters;
% EUAverageDietNew;
% % set fasting or feeding state
% male = setFeedingFastingConstraints(male, 'feeding');
% % set diet - either AvAm or Bal
% male = setDietConstraints(male,Diet);
% male = physiologicalConstraintsHMDBbased(male,IndividualParameters,'');
% % set fasting or feeding state
% female = setFeedingFastingConstraints(female, 'feeding');
% % set diet - either AvAm or Bal
% female = setDietConstraints(female,Diet);
% female = physiologicalConstraintsHMDBbased(female,IndividualParameters,'');
% 
%% add demand reactions in [bc]
male.S=male.A;
male = addDemandReaction(male, 'his_L[bc]');
male = addDemandReaction(male, 'met_L[bc]');
male = addDemandReaction(male, 'taur[bc]');
male = addDemandReaction(male, 'HC02192[bc]');
male = addDemandReaction(male, 'tdechola[bc]');
male = addDemandReaction(male, 'tdchola[bc]');
male = addDemandReaction(male, 'ser_L[bc]');
male = addDemandReaction(male, 'hom_L[bc]');
male = addDemandReaction(male, 'leu_L[bc]');
male = addDemandReaction(male, 'asn_L[bc]');
male = addDemandReaction(male, 'phe_L[bc]');
male = addDemandReaction(male, 'cyst_L[bc]');
male = addDemandReaction(male, '3hmp[bc]');
male = addDemandReaction(male, 'CE2176[bc]');
male = addDemandReaction(male, '2hb[bc]');
male.A = male.S;
%% reactions to be tested for
Rxn = {
    % based on DeNoPa metabolomic data
    'DM_his_L[bc]'
    'DM_HC02192[bc]'
    'DM_tdechola[bc]'
    'DM_tdchola[bc]'
    'DM_met_L[bc]'
    'DM_taur[bc]'
    'DM_ser_L[bc]'
    'DM_hom_L[bc]'
    'DM_leu_L[bc]'
    'DM_asn_L[bc]'
    'DM_phe_L[bc]'
    'DM_cyst_L[bc]'
    'DM_3hmp[bc]'
    'DM_CE2176[bc]'
    'DM_2hb[bc]'
    % exp gives CSF concentration
    'Liver_PCSF';%Y
    'Liver_ALCD2if';%Y
    % still to check
    'Liver_ACS'; % gluconeogenesis from acetate%Y
    % (https://academic.oup.com/jcem/article/101/4/1445/2804883)
    'Liver_DGAT';%Y
    'Liver_DHCR72r';%Y
    'Liver_EX_val_L(e)_[bc]';
    'Liver_EX_ile_L(e)_[bc]';
     'Liver_EX_leu_L(e)_[bc]'
    'Colon_HMR_0156' ;%atp[c] + but[c] + coa[c] <=> amp[c] + btcoa[c] + ppi[c]%Y
    % neurotransmitter
    'Brain_DM_atp_c_';
    'Brain_DM_dopa[c]';%Y
    'Brain_DM_srtn[c]';%Y
    'Brain_DM_adrnl[c]';
    'Brain_DM_4abut[c]';
    'Brain_DM_hista[c]';
    'Brain_DM_kynate[c]';
    'Brain_DM_nrpphr[c]';
    'Brain_DM_Lkynr[c]';
    'Brain_DM_3dhchol(c)';
    'Brain_DM_3dhdchol(c)';
    'Brain_DM_ca3s(c)';
    'Brain_DM_gca3s(c)';
    'Brain_DM_gcdca3s(c)';
    'Brain_DM_gdca3s(c)';
    'Brain_DM_tcdca3s(c)';
    'Brain_DM_thyochol(c)';
    'Brain_DM_udca3s(c)';
    'Brain_CYOOm3'
    'Brain_PDHm'
    'Brain_PCm'
    'Brain_NADH2_u10m'
    'Liver_DM_4abut(c)'
    'Brain_DOPACCL'
    'Brain_3DHCDCHOLt'
    'LI_EX_gbbtn[luLI]_[fe]'
    'Brain_GBA'
    'Brain_GBA2e'
    'Brain_GND'
    'Brain_GTHS'
    'Brain_PUNP5'
    'Brain_sink_fe3(c)'
    'Brain_TRDR'
    'Brain_UGLT'
    'Brain_UPPN'
    'Brain_URIDK2m'
    'EX_uchol[u]'
    'EX_csn[u]'
    'EX_tsul[u]'
    'EX_12dhchol[u]'
    'EX_glc_D[sw]'
    'EX_isochol[u]'
    'Brain_DM_atp_c_'
    'Brain_ATPtm'
    'Brain_24_25VITD3Hm'
    'Brain_2OXOADOXm'
    'Brain_34HPLFM'
    'Brain_3AIBTm'
    'Brain_3DPHBH1'
    'Brain_3DPHBH2'
    'Brain_3HBCOAHLm'
    'Brain_4HBZCOAFm'
    'Brain_4HBZFm'
    'Brain_ABTArm'
    'Brain_ACACT10m'
    'Brain_ACCOACm'
    'Brain_ACOAD10m'
    'Brain_ACOAD1fm'
    'Brain_ACOAD8m'
    'Brain_ACONTm'
    'Brain_ACSm'
    'Brain_ADK1m'
    'Brain_ADK3m'
    'Brain_ADNK1m'
    'Brain_AGMTm'
    'Brain_AKGDm'
    'Brain_ALASm'
    'Brain_APAT2rm'
    'Brain_APOCFm'
    'Brain_APOC_LYS_BTNPm'
    'Brain_ARGDCm'
    'Brain_ASNNm'
    'Brain_ASPNATm'
    'Brain_ASPTAm'
    'Brain_BACCLm'
    'Brain_BDHm'
    'Brain_BTNDm'
    'Brain_BTNPLm'
    'Brain_CATm'
    'Brain_CDSm'
    'Brain_CHSTEROLt1'
    'Brain_CHSTEROLt2'
    'Brain_CK'
    'Brain_COQ3m'
    'Brain_COQ5m'
    'Brain_COQ6m'
    'Brain_COQ7m'
    'Brain_COUCOAFm'
    'Brain_CSm'
    'Brain_CYTDK2m'
    'Brain_CYTK1m'
    'Brain_DCK1m'
    'Brain_DHDPBMTm'
    'Brain_DM_datp_m_'
    'Brain_DM_dctp_m_'
    'Brain_DM_dgtp_m_'
    'Brain_DM_dttp_m_'
    'Brain_DPHMBDCm'
    'Brain_DUTPDPm'
    'Brain_ECOAH12m'
    'Brain_ECOAH1m'
    'Brain_ECOAH9m'
    'Brain_FACOAL40im'
    'Brain_FAOXC80'
    'Brain_FCLTm'
    'Brain_FTHFLm'
    'Brain_FUMm'
    'Brain_G5SADrm'
    'Brain_G5SDym'
    'Brain_GCC2am'
    'Brain_GCC2bim'
    'Brain_GCC2cm'
    'Brain_GCCam'
    'Brain_GCCbim'
    'Brain_GCCcm'
    'Brain_GHMT2rm'
    'Brain_GLU5Km'
    'Brain_GLUDxm'
    'Brain_GLUDym'
    'Brain_GLUNm'
    'Brain_GLUTCOADHm'
    'Brain_GLYOXm'
    'Brain_GTHPm'
    'Brain_H2CO3Dm'
    'Brain_HACD1m'
    'Brain_HACD9m'
    'Brain_HBZOPT10m'
    'Brain_HIBDm'
    'Brain_HMGCOASim'
    'Brain_HMGLm'
    'Brain_ICDHxm'
    'Brain_ICDHyrm'
    'Brain_ILETAm'
    'Brain_LDH_Lm'
    'Brain_LEUTAm'
    'Brain_MCCCrm'
    'Brain_MCDm'
    'Brain_MDHm'
    'Brain_ME2m'
    'Brain_MGCHrm'
    'Brain_MMCDm'
    'Brain_MMEm'
    'Brain_MMMm'
    'Brain_MMSAD3m'
    'Brain_MMTSADm'
    'Brain_MTHFCm'
    'Brain_MTHFDm'
    'Brain_NDPK1m'
    'Brain_NDPK3m'
    'Brain_NDPK4m'
    'Brain_NDPK6m'
    'Brain_OCOAT1m'
    'Brain_OIVD1m'
    'Brain_OIVD2m'
    'Brain_OIVD3m'
    'Brain_ORNTArm'
    'Brain_P5CRm'
    'Brain_PCm'
    'Brain_PDHm'
    'Brain_PHETA1m'
    'Brain_PPAm'
    'Brain_PPPGOm'
    'Brain_PROD2m'
    'Brain_PSDm_hs'
    'Brain_SARDHm'
    'Brain_SPODMm'
    'Brain_SUCD1m'
    'Brain_SUCOAS1m'
    'Brain_SUCOASm'
    'Brain_T4HCINNMFM'
    'Brain_TMDK1m'
    'Brain_TYRTAm'
    'Brain_URIDK2m'
    'Brain_VALTAm'
    'Brain_r0022'
    'Brain_r0033'
    'Brain_r0047'
    'Brain_r0062'
    'Brain_r0074'
    'Brain_r0178'
    'Brain_r0179'
    'Brain_r0196'
    'Brain_r0221'
    'Brain_r0309'
    'Brain_r0317'
    'Brain_r0319'
    'Brain_r0365'
    'Brain_r0383'
    'Brain_r0423'
    'Brain_r0425'
    'Brain_r0426'
    'Brain_r0509'
    'Brain_r0517'
    'Brain_r0555'
    'Brain_r0560'
    'Brain_r0579'
    'Brain_r0590'
    'Brain_r0596'
    'Brain_r0633'
    'Brain_r0669'
    'Brain_r0754'
    'Brain_r0755'
    'Brain_r0756'
    'Brain_r0757'
    'Brain_r0779'
    'Brain_r0927'
    'Brain_r1154'
    'Brain_RE1447M'
    'Brain_RE2111M'
    'Brain_RE2427M'
    'Brain_RE2428M'
    'Brain_RE2626M'
    'Brain_RE2649M'
    'Brain_RE2972M'
    'Brain_RE3346M'
    'Brain_FAOXC8C6m'
    'Brain_DTMPKm'
    'Brain_FADH2ETC'
    'Brain_DM_4hrpo'
    'Brain_r0295'
    'Brain_r0202m'
    'Brain_PGPP_hsc'
    'Brain_TD2GLTRCOAm'
    'Brain_3HGLUTCOAm'
    'Brain_3OHGLUTACm'
    'Brain_HMR_2613'
    'Brain_HMR_3121'
    'Brain_HMR_3149'
    'Brain_HMR_3398'
    'Brain_HMR_4777'
    'Brain_HMR_9803'
    'Brain_HMR_9804'
    'Brain_DM_btn(m)'
    'Brain_ATPS4m'
    'Brain_CYOR_u10m'
    'Brain_Htm'
    'Brain_NADH2_u10m'
    'Brain_CYOOm3'
    'Brain_MMSAD1m'
    'Brain_r0541'
    'Brain_r0655'
    'Brain_RE2030M'
    'Brain_HMR_2713'
    'Brain_HMR_3426'
    'Brain_CYOOm2'
    'Brain_P45027A1m'
    'Brain_RE1828M'
    'Brain_RE2632M'
    'Brain_RE1829M'
    'Brain_RE1827M'
    'Brain_RE1830M'
    'Brain_XOL27OHtm'
    'Brain_HMR_1798'
    };
%% Define microbiome samples
files = {'ERS1647277'
    'ERS1647278'
    'ERS1647279'
    'ERS1647280'
    'ERS1647281'
    'ERS1647282'
    'ERS1647283'
    'ERS1647284'
    'ERS1647285'
    'ERS1647286'
    'ERS1647287'
    'ERS1647288'
    'ERS1647289'
    'ERS1647290'
    'ERS1647291'
    'ERS1647292'
    'ERS1647293'
    'ERS1647294'
    'ERS1647295'
    'ERS1647296'
    'ERS1647297'
    'ERS1647298'
    'ERS1647299'
    'ERS1647300'
    'ERS1647301'
    'ERS1647302'
    'ERS1647303'
    'ERS1647304'
    'ERS1647305'
    'ERS1647306'
    'ERS1647307'
    'ERS1647308'
    'ERS1647309'
    'ERS1647310'
    'ERS1647311'
    'ERS1647312'
    'ERS1647313'
    'ERS1647314'
    'ERS1647315'
    'ERS1647316'
    'ERS1647317'
    'ERS1647318'
    'ERS1647319'
    'ERS1647320'
    'ERS1647321'
    'ERS1647322'
    'ERS1647323'
    'ERS1647324'
    'ERS1647325'
    'ERS1647326'
    'ERS1647327'
    'ERS1647328'
    'ERS1647329'
    'ERS1647330'
    'ERS1647331'
    'ERS1647332'
    'ERS1647333'
    'ERS1647334'
    'ERS1647335'
    };
for j = a : z
    
    % load microbiome model
    if set ==0
        S= load(strcat('Y:\Microbiome\PD\PD_h\ht\results\microbiota_model_samp_',files{j}));
    else
        S= load(strcat('/home/ines.thiele/atlas_lcsb_spg/Microbiome/PD/PD_h/ht/results/microbiota_model_samp_',files{j},'.mat'));
    end
    
    microbiota_model = S.microbiota_model;
    % create HM model
    
    k = 1;
    gender = 'male'; %only males in this study
    couplingConstraint = 400;
    if strcmp(gender,'male')
        modelHM = combineHarveyMicrotiota(male,microbiota_model,couplingConstraint);
    else
        modelHM = combineHarveyMicrotiota(female,microbiota_model,couplingConstraint);
    end
    modelHM.gender = gender;
    modelHM.ID = files{j};
    
    standardPhysiolDefaultParameters;
    modelHM = physiologicalConstraintsHMDBbased(modelHM,IndividualParameters);
    
    EUAverageDietNew;
    % set fasting or feeding state
    modelHM = setFeedingFastingConstraints(modelHM, 'feeding');
    % set diet - either AvAm or Bal
    modelHM = setDietConstraints(modelHM,Diet);
    % set some more constraints
    modelHM = setSimulationConstraints(modelHM);
    modelHM.status = 'personalized microbiota, no personalized Harvey';
    % set microbial excretion constraint
    modelHM.lb(find(ismember(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=1; %
    modelHM.ub(find(ismember(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=1; %
    
    % further constraint adjustments
    modelHM.lb(strmatch('BBB_KYNATE[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
    modelHM.lb(strmatch('BBB_LKYNR[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
    modelHM.lb(strmatch('BBB_TRP_L[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
    
    modelHM.lb(strmatch('BBB_HC02194[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
    modelHM.lb(strmatch('BBB_CHOLATE[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
    modelHM.lb(strmatch('BBB_GCHOLA[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
    modelHM.lb(strmatch('BBB_TDCHOLA[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
    modelHM.lb(strmatch('BBB_DGCHOL[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
    modelHM.lb(strmatch('BBB_TCHOLA[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
    modelHM.lb(strmatch('BBB_C02528[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
    
    modelHM.ub(strmatch('Brain_EX_glc_D(',modelHM.rxns)) = -100; % currently -400 rendering many of the models to be infeasible in germfree state
    
    
    if strcmp(gender,'male')
        Results.gender = 'male';
        Results.ID = files{j};
        modelOrganAllCoupled = male;
        % save Results_male_microbiota_model_samp_SRS064645.mat modelHM microbiota_model modelOrganAllCoupled Results
        % save Results_male_microbiota_model_samp_SRS011084.mat modelHM microbiota_model modelOrganAllCoupled Results
        save(strcat('2018_10_07_PDB_male_microbiota_model_samp_',files{j},'.mat'), 'modelHM', 'microbiota_model' ,'modelOrganAllCoupled' );
    else
        Results.gender = 'female';
        Results.ID = files{j};
        modelOrganAllCoupled = female;
        %   save Results_female_microbiota_model_samp_SRS024388.mat modelHM microbiota_model modelOrganAllCoupled Results
        save(strcat('2018_10_07_PDB_female_microbiota_model_samp_',files{j},'.mat'), 'modelHM', 'microbiota_model' ,'modelOrganAllCoupled' );
    end
    
    for k = 1 : length(Rxn)
        modelHM = changeObjective(modelHM,Rxn{k});
        modelHM.osense = -1;%max
        [sol]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');
        if isempty(sol.full) || sol.origStat==3
            break
        else
            RxnF(k,1) = sol.full(find(ismember(modelHM.rxns,Rxn{k})));
        end
        clear sol
    end
    
    clear Organ* Obje* Indivi* Number*  k  gender  d ID Body* BloodF* sol ResultsATP_Fat_S*  bloodF*
    
    save(strcat('Results_PD_Bonn_2018_10_07_',files{j}));
    
end