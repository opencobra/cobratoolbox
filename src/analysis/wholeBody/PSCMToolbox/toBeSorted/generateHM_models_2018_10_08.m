if set==1
    pathdef;
    addpath(genpath('../../HH_final'))
    addpath(genpath('/home/ines.thiele/P/GitHub/codeBaseHarveyAnalysis'))
    addpath(genpath('/home/ines.thiele/P/GitHub/_cobraHARVEYGenerationONLY'))
    addpath(genpath('/opt/tomlab'))
end


load Harvey_1_01c
load Harvetta_1_01c

% load in HMP meta-data
%[InputData] = readInHMPData('HMP_metadata.xlsx');
load InputDataHMP_fromxlsx;

%ResultsAll = [];
%Results.List = [];
files = {'SRS011239'
    'SRS011302'
    'SRS011405'
    'SRS011586'
    'SRS012273'
    'SRS012902'
    'SRS013521'
    'SRS014313'
    'SRS014459'
    'SRS014613'
    'SRS014979'
    'SRS015065'
    'SRS015133'
    'SRS015190'
    'SRS015217'
    'SRS015369'
    'SRS016095'
    'SRS016203'
    'SRS016495'
    'SRS016517'
    'SRS016585'
    'SRS017433'
    'SRS017521'
    'SRS017701'
    'SRS018656'
    'SRS019267'
    'SRS019601'
    'SRS019968'
    'SRS020328'
    'SRS021948'
    'SRS022071'
    'SRS022137'
    'SRS022524'
    'SRS022713'
    'SRS023346'
    'SRS023583'
    'SRS023829'
    'SRS024009'
    'SRS024265'
    'SRS024388'
    'SRS042284'
    'SRS043001'
    'SRS043411'
    'SRS048870'
    'SRS049995'
    'SRS050752'
    'SRS051882'
    'SRS052697'
    'SRS053214'
    'SRS053335'
    'SRS053398'
    'SRS054590'
    'SRS054956'
    'SRS055982'
    'SRS057478'
    'SRS057717'
    'SRS058723'
    'SRS063040'
    'SRS063985'
    'SRS064276'
    'SRS064557'
    'SRS065504'
    'SRS075398'
    'SRS077730'
    'SRS078176'
    'SRS024388'
    'SRS011061'
    'SRS011134'
    'SRS011271'
    'SRS011452'
    'SRS011529'
    'SRS013158'
    'SRS013215'
    'SRS013476'
    'SRS013687'
    'SRS013800'
    'SRS013951'
    'SRS014235'
    'SRS014287'
    'SRS014683'
    'SRS014923'
    'SRS015264'
    'SRS015578'
    'SRS015663'
    'SRS015782'
    'SRS015794'
    'SRS015854'
    'SRS015960'
    'SRS016018'
    'SRS016056'
    'SRS016267'
    'SRS016335'
    'SRS016753'
    'SRS016954'
    'SRS016989'
    'SRS017103'
    'SRS017191'
    'SRS017247'
    'SRS017307'
    'SRS017821'
    'SRS018133'
    'SRS018313'
    'SRS018351'
    'SRS018427'
    'SRS018575'
    'SRS018817'
    'SRS019030'
    'SRS019161'
    'SRS019397'
    'SRS019582'
    'SRS019685'
    'SRS019787'
    'SRS019910'
    'SRS020233'
    'SRS020869'
    'SRS021484'
    'SRS022609'
    'SRS023176'
    'SRS023526'
    'SRS023914'
    'SRS023971'
    'SRS024075'
    'SRS024132'
    'SRS024331'
    'SRS024435'
    'SRS024549'
    'SRS024625'
    'SRS042628'
    'SRS043701'
    'SRS045004'
    'SRS045645'
    'SRS045713'
    'SRS064645'
    'SRS011084'
    'SRS047014'
    %
    'SRS047044'
    'SRS048164'
    'SRS049164'
    'SRS049712'
    'SRS049900'
    'SRS049959'
    'SRS050299'
    'SRS050422'
    'SRS050925'
    'SRS051031'
    'SRS052027'
    'SRS056259'
    'SRS056519'
    'SRS058770'
    'SRS062427'
    'SRS064645'
    };

Rxn = {'Liver_PCSF';
    'Liver_ALCD2if';
    'Liver_EX_val_L(e)_[bc]'
    'Liver_EX_ile_L(e)_[bc]'
    'Colon_HMR_0156'
    % neurotransmitter
    'Brain_DM_dopa[c]';
    'Brain_DM_srtn[c]';
    'Brain_DM_adrnl[c]'
    'Brain_DM_4abut[c]'
    'Brain_DM_hista[c]'
    'Brain_DM_kynate[c]'
    'Brain_DM_nrpphr[c]'
    'Brain_DM_Lkynr[c]'
    'Muscle_DM_atp_c_'
    'Adipocytes_DM_lipid_storage'
    };

for j = a : z
    % load microbiome model
    if set ==0
        S= load(strcat('Y:\Microbiome\HMP\Run_Almut_17_03_31_with10_new_strains\Results_Setup2\microbiota_model_samp_',files{j}));
    else
        S= load(strcat('/home/ines.thiele/atlas_lcsb_spg/Microbiome/HMP/Run_Almut_17_03_31_with10_new_strains/Results_Setup2/microbiota_model_samp_',files{j},'.mat'));
    end
    
    microbiota_model = S.microbiota_model;
    % create HM model
    
    k = 1;
    % apply personalized constraints
    % 1. match filename with ID
    ID = strmatch(files{j},InputData(1,:));
    % 2. Gender
    G = strmatch('Gender',InputData(:,1));
    gender = lower(InputData(G,ID));
    OrganLists;
    if strcmp(gender,'male')
        modelHM = combineHarveyMicrotiota(male,microbiota_model,400);
    else
        modelHM = combineHarveyMicrotiota(female,microbiota_model,400);
    end
    modelHM.gender = gender;
    modelHM.ID = InputData(1,ID);
    
    standardPhysiolDefaultParameters;
    % 3. set personalized constraints
    [modelHM,IndividualParametersPersonalized] = individualizedLabReport(modelHM,IndividualParameters, [InputData(:,1) InputData(:,2) InputData(:,ID)]);
    modelHM.IndividualParametersPersonalized = IndividualParametersPersonalized;
    
    [listOrgan,OrganWeight,OrganWeightFract] = calcOrganFract(modelHM,IndividualParametersPersonalized);
    % adjust whole body maintenance reaction based on new organ weight
    % fractions
    [modelHM] = adjustWholeBodyRxnCoeff(modelHM, listOrgan, OrganWeightFract);
    % apply HMDB metabolomic data based on personalized individual parameters
    modelHM = physiologicalConstraintsHMDBbased(modelHM,IndividualParametersPersonalized);
    % set some more constraints
    modelHM = setSimulationConstraints(modelHM);
    modelHM.status = 'personalized microbiota, personalized Harvey/Harvetta';
    modelHM.InputData = [InputData(:,1) InputData(:,2) InputData(:,ID)];
    % set microbial excretion constraint
    modelHM.lb(find(ismember(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=1; %
    modelHM.ub(find(ismember(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=1; %
    
    
    % run simulations for host-microbiome model
    for k = 1 : length(Rxn)
        modelHM = changeObjective(modelHM,Rxn{k});
        modelHM.osense = -1;%max
        tic;[sol]=solveCobraLPCPLEX(modelHM,0,0,0,[],0,'tomlab_cplex');toc
        RxnF(k,1) = sol.full(find(ismember(modelHM.rxns,Rxn{k})));
        % interrupt simulations when infeasible
        if isempty(sol.full) || sol.origStat==3
            break
        end
    end
    %  define germ-free version by disallowing the excretion of microbes
    modelHM_GF = modelHM;
    modelHM_GF.lb(find(ismember(modelHM_GF.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=0; %
    modelHM_GF.ub(find(ismember(modelHM_GF.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=0; %
    for k = 1 : length(Rxn)
        modelHM_GF = changeObjective(modelHM_GF,Rxn{k});
        modelHM_GF.osense = -1;%max
        tic;[sol]=solveCobraLPCPLEX(modelHM_GF,0,0,0,[],0,'tomlab_cplex');toc
        RxnF_GF(k,1) = sol.full(find(ismember(modelHM_GF.rxns,Rxn{k})));
        if isempty(sol.full) || sol.origStat==3
            break
        end
    end
    
    %% compute BMF
    if strcmp(gender,'male')
        modelOrganAllCoupled = male;
    else
        modelOrganAllCoupled = female;
    end
    [solution_modelHM] = computeMin2Norm_HH(modelHM);
    S = modelHM.A(1:length(modelOrganAllCoupled.mets),1:length(modelOrganAllCoupled.rxns));
    F = max(-S,0);
    R = max(S,0);
    vf = max(solution_modelHM.full(1:length(modelOrganAllCoupled.rxns)),0);
    vr = max(-solution_modelHM.full(1:length(modelOrganAllCoupled.rxns)),0);
    production=[R, F]*[vf ;vr];
    consumption=[F, R]*[vf; vr];
    % find all reactions in the model that involve atp
    atp = (find(~cellfun(@isempty,strfind(modelHM.mets(1:length(modelOrganAllCoupled.mets)),'_atp['))));
    % sum of atp consumption in the flux distribution
    Sum_atp_modelHM=sum(consumption(atp,1)); % (in mmol ATP/day/person)
    % compute the energy release in kJ
    Energy_kJ_modelHM = Sum_atp_modelHM/1000 * 64; % (in kJ/day/person)
    
    % compute the energy release in kcal, where 1 kJ = 0.239006 kcal
    Energy_kcal_modelHM = Energy_kJ_modelHM*0.239006 % (in kcal/day/person)
    
    
    S = modelHM_GF.A(1:length(modelOrganAllCoupled.mets),1:length(modelOrganAllCoupled.rxns));
    F = max(-S,0);
    R = max(S,0);
    vf = max(solution_modelHM_GF.full(1:length(modelOrganAllCoupled.rxns)),0);
    vr = max(-solution_modelHM_GF.full(1:length(modelOrganAllCoupled.rxns)),0);
    production=[R, F]*[vf ;vr];
    consumption=[F, R]*[vf; vr];
    % find all reactions in the model that involve atp
    atp = (find(~cellfun(@isempty,strfind(modelHM_GF.mets(1:length(modelOrganAllCoupled.mets)),'_atp['))));
    % sum of atp consumption in the flux distribution
    Sum_atp_modelHM_GF=sum(consumption(atp,1)); % (in mmol ATP/day/person)
    % compute the energy release in kJ
    Energy_kJ_modelHM_GF = Sum_atp_modelHM_GF/1000 * 64; % (in kJ/day/person)
    
    % compute the energy release in kcal, where 1 kJ = 0.239006 kcal
    Energy_kcal_modelHM_GF = Energy_kJ_modelHM_GF*0.239006 % (in kcal/day/person)
    
    
    if strcmp(gender,'male')
        Results.gender = 'male';
        Results.ID = files{j};
        modelOrganAllCoupled = male;
        
        % save Results_male_microbiota_model_samp_SRS064645.mat modelHM microbiota_model modelOrganAllCoupled Results
        % save Results_male_microbiota_model_samp_SRS011084.mat modelHM microbiota_model modelOrganAllCoupled Results
        save(strcat('2018_10_08_HMP_male_microbiota_model_samp_',files{j},'.mat'), 'modelHM', 'microbiota_model' ,'modelOrganAllCoupled' ,'Energy_kJ_modelHM','Energy_kcal_modelHM','Energy_kcal_modelHM_GF','Energy_kJ_modelHM_GF');
    else
        Results.gender = 'female';
        Results.ID = files{j};
        modelOrganAllCoupled = female;
        %   save Results_female_microbiota_model_samp_SRS024388.mat modelHM microbiota_model modelOrganAllCoupled Results
        save(strcat('2018_10_08_HMP_female_microbiota_model_samp_',files{j},'.mat'), 'modelHM', 'microbiota_model' ,'modelOrganAllCoupled' ,'Energy_kJ_modelHM','Energy_kcal_modelHM','Energy_kcal_modelHM_GF','Energy_kJ_modelHM_GF');
    end
end