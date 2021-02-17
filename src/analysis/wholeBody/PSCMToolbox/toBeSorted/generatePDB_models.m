if set==1
    pathdef;
    addpath(genpath('../../HH_final'))
    addpath(genpath('/home/ines.thiele/P/GitHub/codeBaseHarveyAnalysis'))
    addpath(genpath('/home/ines.thiele/P/GitHub/_cobraHARVEYGenerationONLY'))
    addpath(genpath('/opt/tomlab'))
end

load 2017_05_18_HarveyJoint_11_22_constraintHMDB_EUDiet_d
male = modelOrganAllCoupled;
load 2017_05_18_HarvettaJoint_11_22_constraintHMDB_EUDiet_d
female = modelOrganAllCoupled;



Rxn = {'Liver_PCSF';%Y
    'Liver_ALCD2if';%Y
    % still to check
    %  'Liver_ACS' % gluconeogenesis from acetate%Y
    % (https://academic.oup.com/jcem/article/101/4/1445/2804883)
    %   'Liver_DGAT'%Y
    %   'Liver_DHCR72r'%Y
    
    'Liver_EX_val_L(e)_[bc]'
    'Liver_EX_ile_L(e)_[bc]'
    % 'Liver_EX_leu_L(e)_[bc]'
    'Colon_HMR_0156' %atp[c] + but[c] + coa[c] <=> amp[c] + btcoa[c] + ppi[c]%Y
    % neurotransmitter
    'Brain_DM_dopa[c]';%Y
    'Brain_DM_srtn[c]';%Y
    'Brain_DM_adrnl[c]'
    'Brain_DM_4abut[c]'
    
    'Brain_DM_hista[c]'
    'Brain_DM_kynate[c]'
    'Brain_DM_nrpphr[c]'
    'Brain_DM_Lkynr[c]'
    % BAs
    'Brain_DM_3dhcdchol(c)'
    'Brain_DM_3dhchol(c)'
    'Brain_DM_3dhdchol(c)'
    'Brain_DM_ca3s(c)'
    'Brain_DM_cdca24g(c)'
    'Brain_DM_gca3s(c)'
    'Brain_DM_gcdca3s(c)'
    'Brain_DM_gdca3s(c)'
    'Brain_DM_gudca3s(c)'
    'Brain_DM_tca3s(c)'
    'Brain_DM_tcdca3s(c)'
    'Brain_DM_tdca3s(c)'
    'Brain_DM_thyochol(c)'
    'Brain_DM_tudca3s(c)'
    'Brain_DM_udca3s(c)'
    };

%ResultsAll = [];
%Results.List = [];
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
        S= load(strcat('Y:\Federico\PD\setup2\results/microbiota_model_samp_',files{j}));
    else
        S= load(strcat('/home/ines.thiele/atlas_lcsb_spg/Federico/PD/setup2/results/microbiota_model_samp_',files{j},'.mat'));
    end
    
    microbiota_model = S.microbiota_model;
    % create HM model
    
    k = 1;
    gender = 'male'; %only males in this study
    if strcmp(gender,'male')
        modelHM = combineHarveyMicrotiota(male,microbiota_model);
    else
        modelHM = combineHarveyMicrotiota(female,microbiota_model);
    end
    modelHM.gender = gender;
    modelHM.ID = files{j};
    
    standardPhysiolDefaultParameters;
    modelHM = physiologicalConstraintsHMDBbased(modelHM,IndividualParameters);
    % set some more constraints
    modelHM = setSimulationConstraints(modelHM);
    modelHM.status = 'personalized microbiota, no personalized Harvey';
    % set microbial excretion constraint
    modelHM.lb(find(ismember(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=1; %
    modelHM.ub(find(ismember(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=1; %
    
    if strcmp(gender,'male')
        Results.gender = 'male';
        Results.ID = files{j};
        modelOrganAllCoupled = male;
        % save Results_male_microbiota_model_samp_SRS064645.mat modelHM microbiota_model modelOrganAllCoupled Results
        % save Results_male_microbiota_model_samp_SRS011084.mat modelHM microbiota_model modelOrganAllCoupled Results
        save(strcat('2018_01_10_PDB_male_microbiota_model_samp_',files{j},'.mat'), 'modelHM', 'microbiota_model' ,'modelOrganAllCoupled' );
    else
        Results.gender = 'female';
        Results.ID = files{j};
        modelOrganAllCoupled = female;
        %   save Results_female_microbiota_model_samp_SRS024388.mat modelHM microbiota_model modelOrganAllCoupled Results
        save(strcat('2017_12_12_PDB_female_microbiota_model_samp_',files{j},'.mat'), 'modelHM', 'microbiota_model' ,'modelOrganAllCoupled' );
    end
    
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
    
    for k = 1 : 3%length(Rxn)
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
    
    if 0
        modelHM_GF = modelHM;
        
        modelHM_GF.lb(find(ismember(modelHM_GF.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=0; %
        modelHM_GF.ub(find(ismember(modelHM_GF.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=0; %
        
        for k = 1 : length(Rxn)
            modelHM_GF = changeObjective(modelHM_GF,Rxn{k});
            modelHM_GF.osense = -1;%max
            [sol]=solveCobraLPCPLEX(modelHM_GF,1,0,0,[],0,'tomlab_cplex');
            if isempty(sol.full) || sol.origStat==3
                break
            else
                RxnF_GF(k,1) = sol.full(find(ismember(modelHM_GF.rxns,Rxn{k})));
            end
            clear sol
        end
    end
    
    clear Organ* Obje* Indivi* Number*  k  gender  d ID Body* BloodF* sol ResultsATP_Fat_S*  bloodF*
    
    save(strcat('Results_PD3_',files{j}));
    
end