if set==1
   % cd atlas_lcsb_spg/SemiAutomated_Organ_Models/_InesProteomeMapData/HH_final/HMP/
    pathdef;
    addpath(genpath('../../HH_final'))
    addpath(genpath('/home/ines.thiele/P/GitHub/codeBaseHarveyAnalysis'))
    addpath(genpath('/home/ines.thiele/P/GitHub/_cobraHARVEYGenerationONLY'))
    addpath(genpath('/opt/tomlab'))
end
% e.g., load HMP data
%[InputData] = readInHMPData('HMP_metadata.xlsx');
load InputDataHMP_fromxlsx;
% adjust individual parameters using personalized input data, e.g., as in
% lab report or HMP metadata

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
    };

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
%files={'SRS016585';'SRS017433';'SRS017521';'SRS017701';'SRS018656';'SRS019267';'SRS019601';'SRS019968';'SRS020328';'SRS021948';'SRS055982';'SRS057478';'SRS057717';'SRS058723';'SRS063040';'SRS063985';'SRS019582'};
for i = a : z %length(listing)
    
    listing = dir('*.mat');
    for j =1: length(listing)
        fileNames{j,1} = listing(j).name;
    end
    fileNames = fileNames(strmatch('2017_12',fileNames));
    file = fileNames{find(~cellfun(@isempty,strfind(fileNames,files{i})))};
    
    models=   load(file);
    modelHM = models.modelHM;
    modelOrganAllCoupled = models.modelOrganAllCoupled;
    microbiota_model = models.microbiota_model;
    
    %%some fixes that I forgot to do when generating the modelHM
    % adjust microbial contribution to % rather than to fraction (has been
    % fixed in combineHarveyMicrotiota later on
    modelHM.S(:,strmatch('communityBiomass',modelHM.rxns)) = 100*modelHM.S(:,strmatch('communityBiomass',modelHM.rxns)) ;
    modelHM.A=modelHM.S;
    
    %adjust physiological constraints - has been corrected later on in
    %generateHM_models
    ID = strmatch(modelHM.ID,InputData(1,:));
    gender = modelHM.gender;
    standardPhysiolDefaultParameters;
    [modelHM,IndividualParametersPersonalized] = individualizedLabReport(modelHM,IndividualParameters, [InputData(:,1) InputData(:,2) InputData(:,ID)]);
    % 3. set personalized constraints
    modelHM.IndividualParametersPersonalized=IndividualParametersPersonalized;
    
    % apply HMDB metabolomic data based on personalized individual parameters
    modelHM = physiologicalConstraintsHMDBbased(modelHM,IndividualParametersPersonalized);
    
    modelHM = setDietConstraints(modelHM);
    % set some more constraints
    modelHM = setSimulationConstraints(modelHM);
    
    modelHM.lb(strmatch('BBB_KYNATE[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
    modelHM.lb(strmatch('BBB_LKYNR[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
    modelHM.lb(strmatch('BBB_TRP_L[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake

     modelHM.ub(strmatch('Brain_EX_glc_D(',modelHM.rxns)) = -100; % currently -400 rendering many of the models to be infeasible in germfree state
     
%     modelHM.lb(strmatch('BBB_HC02194[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
%     modelHM.lb(strmatch('BBB_CHOLATE[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
%     modelHM.lb(strmatch('BBB_GCHOLA[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
%     modelHM.lb(strmatch('BBB_TDCHOLA[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
%     modelHM.lb(strmatch('BBB_DGCHOL[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
%     modelHM.lb(strmatch('BBB_TCHOLA[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
%     modelHM.lb(strmatch('BBB_C02528[CSF]upt',modelHM.rxns)) = -1000000; %constrained uptake
    
    %%
 %   [ResultsATP_Fat] = computeMuscleATP_FatStorage2(modelHM,15);
    [ResultsATP_Fat] = computeMuscleATP_FatStorage3(modelHM,15); % computes only min max
    
    if ~isempty(ResultsATP_Fat)
        for k = 1 : length(Rxn)
            modelHM = changeObjective(modelHM,Rxn{k});
            modelHM.osense = -1;%max
            [sol]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');
            RxnF(k,1) = sol.full(find(ismember(modelHM.rxns,Rxn{k})));
            if isempty(sol.full) || sol.origStat==3
                break
            end
        end
        
        clear Organ* Obje* Indivi* Number*  k  gender  d ID Body* BloodF* sol ResultsATP_Fat_S*  bloodF*
        
        save(strcat('Results_HMPNew',file));
    else
        save(strcat('Results_HMPNew_Inf_',file));
    end
    
    
    %% germfree:
    %%
    modelHM_GF = modelHM;
    
    modelHM_GF.lb(find(ismember(modelHM_GF.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=0; %
    modelHM_GF.ub(find(ismember(modelHM_GF.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=0; %
    
    %[ResultsATP_Fat_GF] = computeMuscleATP_FatStorage2(modelHM_GF,15);
    [ResultsATP_Fat_GF] = computeMuscleATP_FatStorage3(modelHM_GF,15); % computes only min max
    
    if ~isempty(ResultsATP_Fat_GF)
        for k = 1 : length(Rxn)
            modelHM_GF = changeObjective(modelHM_GF,Rxn{k});
            modelHM_GF.osense = -1;%max
            [sol]=solveCobraLPCPLEX(modelHM_GF,1,0,0,[],0,'tomlab_cplex');
            RxnF_GF(k,1) = sol.full(find(ismember(modelHM_GF.rxns,Rxn{k})));
               if isempty(sol.full) || sol.origStat==3
                break
            end
        end
        
        clear Organ* Obje* Indivi* Number*  k  gender  d ID Body* BloodF* sol ResultsATP_Fat_S*  bloodF*
        
        save(strcat('Results_HMPNew_GF_',file));
    else
        save(strcat('Results_HMPNew_Inf_GF_',file));
    end
end


%