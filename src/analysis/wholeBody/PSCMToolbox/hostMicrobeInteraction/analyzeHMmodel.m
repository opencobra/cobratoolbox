function [Results,ResultsSol,ResultsStats] = analyzeHMmodel(modelHM,Diet, Results,ResultsSol,setStandard,RxnMin,RxnMax,LPSolver)
% This function performs host-microbiome optimization for a set of defined
% model reactions. Please note that the fecal secretion rate for the
% microbiome community biomass reaction is constrained to lb=0.4 and ub=1.
%
% [Results,ResultsSol,ResultsStats] = analyzeHMmodel(modelHM,Diet, Results,ResultsSol,setStandard,RxnMin,RxnMax)
%
% INPUT
% modelHM       model structure containing the host-microbiome model
% Diet          Diet option: 'EUAverageDiet' (default)
% Results       List of result names of FBA simulations using modelHM. The function provides the option to append the new results
%               to a previous list of results. If not provided, a new list of results
%               will be returned.
% ResultsSol    Array of FBA solution vectors corresponding to the optimization problems in Results. The function provides the option to append the new results
%               to a previous list of results. If not provided, a new list of results
%               will be returned.
% setStandard   default: 1
% RxnMin        Reaction(s) in modelHM to be minimized
% RxnMax        Reaction(s) in modelHM to be maximized
% LPSolver      Define LP solver to be used ('tomlab_cplex' or
%               'ILOGcomplex' (default))
%
% OUTPUT
% Results       List of result names of FBA simulations using modelHM. 
% ResultsSol    Array of FBA solution vectors corresponding to the optimization problems in Results.
% ResultsStats  List of solver status for each FBA solution
%
%
% Ines Thiele 2016-2019
%
%
% define solver
if  ~exist('LPSolver','var')
    LPSolver = 'ILOGcomplex';
end

% define diet
if ~exist('Diet','var')
    EUAverageDietNew;
elseif strcmp(Diet,'EUAverageDiet')
    EUAverageDietNew;
elseif strcmp(Diet,'HighFiberDiet')
    HighFiberDiet;
elseif strcmp(Diet,'HighProteinDiet')
    HighProteinDiet;
elseif strcmp(Diet,'UnhealthyDiet')
    UnhealthyDiet;
elseif strcmp(Diet,'VegetarianDiet')
    VegetarianDiet;
end
if ~exist('setStandard','var')
    setStandard=1;
end

if ~exist('RxnMin','var')
    RxnMin ={'Kidney_EX_chsterol(e)_[bc]'
        % 'Kidney_EX_vldl_hs(e)_[bc]'
        % 'Kidney_EX_hdl_hs(e)_[bc]'
        'Kidney_EX_glc(e)_[bc]'
        'Kidney_EX_leuktrE4(e)_[bc]'
        'Kidney_EX_leuktrA4(e)_[bc]'
        'Brain_EX_dopa(e)_[csf]'
        'Brain_EX_srtn(e)_[csf]'
        'Brain_EX_bhb(e)_[csf]'
        'Brain_EX_acac(e)_[csf]'
        'Kidney_EX_etoh(e)_[bc]'
        'Kidney_EX_dopa(e)_[bc]'
        'Kidney_EX_fol(e)_[bc]'
        'Kidney_EX_prostgd2(e)_[bc]'
        'Kidney_EX_prostge2(e)_[bc]'
        'Kidney_EX_prostgf2(e)_[bc]'
        'Kidney_EX_prostgh2(e)_[bc]'
        'Kidney_EX_tststerone(e)_[bc]'
        'Kidney_EX_3ddcrn(e)_[bc]'
        'Kidney_EX_3deccrn(e)_[bc]'
        'Kidney_EX_3hdececrn(e)_[bc]'
        'Kidney_EX_3hexdcrn(e)_[bc]'
        'Kidney_EX_3octdec2crn(e)_[bc]'
        'Kidney_EX_3octdeccrn(e)_[bc]'
        'Kidney_EX_3tetd7ecoacrn(e)_[bc]'
        'Kidney_EX_3thexddcoacrn(e)_[bc]'
        'Kidney_EX_3ttetddcoacrn(e)_[bc]'
        'Kidney_EX_c10crn(e)_[bc]'
        'Kidney_EX_c12dc(e)_[bc]'
        'Kidney_EX_c16dc(e)_[bc]'
        'Kidney_EX_c3dc(e)_[bc]'
        'Kidney_EX_c51crn(e)_[bc]'
        'Kidney_EX_c5dc(e)_[bc]'
        'Kidney_EX_c6crn(e)_[bc]'
        'Kidney_EX_c8crn(e)_[bc]'
        'Kidney_EX_ddecrn(e)_[bc]'
        'Kidney_EX_ivcrn(e)_[bc]'
        'Kidney_EX_lac_L(e)_[bc]'
        'Kidney_EX_taur(e)_[bc]'
        'Kidney_EX_HC02191(e)_[bc]'
        'Kidney_EX_HC02192(e)_[bc]'
        'Kidney_EX_HC02193(e)_[bc]'
        'Kidney_EX_HC02195(e)_[bc]'
        'Kidney_EX_HC02196(e)_[bc]'
        'Kidney_EX_HC02220(e)_[bc]'
        'Kidney_EX_HC02194(e)_[bc]'
        'Kidney_EX_HC02197(e)_[bc]'
        'Kidney_EX_HC02198(e)_[bc]'
        'Kidney_EX_HC02199(e)_[bc]'
        'Brain_EX_HC02193(e)_[csf]'
        'Brain_EX_HC02195(e)_[csf]'
        'Brain_EX_HC02196(e)_[csf]'
        'Brain_EX_HC02199(e)_[csf]'
        'Brain_EX_HC02191(e)_[csf]'
        'Brain_EX_HC02194(e)_[csf]'
        'Brain_EX_HC02197(e)_[csf]'
        'Brain_EX_HC02198(e)_[csf]'
        'Brain_EX_HC02192(e)_[csf]'
        'Brain_EX_gchola(e)_[csf]'
        'Brain_EX_tchola(e)_[csf]'
        'Kidney_EX_gchola(e)_[bc]'
        'Kidney_EX_tchola(e)_[bc]'
        'Kidney_EX_tdchola(e)_[bc]'
        'Brain_EX_tdchola(e)_[csf]'
        'EX_acnam[u]'
        'EX_pheacgln[u]'
        'EX_3hmp[u]'
        'EX_succ[u]'
        'EX_cit[u]'
        'EX_glc_D[u]'
        'EX_urea[u]'
        'EX_glcur[u]'
        'Brain_EX_srtn(e)_[csf]'
        'Brain_EX_o2(e)_[csf]'
        'Heart_EX_o2(e)_[bc]'
        };
    RxnMin = unique(RxnMin);
end
if ~exist('RxnMax','var')
    RxnMax = {
        'Adipocytes_TAG_HSad'
        'Adipocytes_sink_c226coa(c)'
        'Adipocytes_sink_doco13ecoa(c)'
        'Adipocytes_sink_hdca(c)'
        'Adipocytes_sink_lnlc(c)'
        'Adipocytes_sink_lnlccoa(c)'
        'Adipocytes_sink_lnlncacoa(c)'
        'Adipocytes_sink_lnlncgcoa(c)'
        'Adipocytes_sink_odecoa(c)'
        'Adipocytes_sink_pmtcoa(c)'
        'Adipocytes_sink_stcoa(c)'
        'Adipocytes_sink_tag_hs(c)'
        'Adipocytes_sink_tmndnc(c)'
        'Adipocytes_sink_tmndnccoa(c)'
        'Muscle_DM_PROTEIN'
        'Muscle_DM_atp_c_'
        'Brain_3HLYTCL' % dopamine synthesis
        'Brain_5HLTDL' %Serotonin synthesis
        'Brain_NORANMT' % adrenaline
        'Brain_GLUDC' % gaba production
        'Brain_DOPAc'
        'Kidney_KYNATESYN' % kynate synthesis
        'Kidney_QUILSYN' % Quinolinate Synthesis
        'Brain_CHAT' % acetylcholine synthesis
        'Liver_VLDL_HSSYN'
        'Liver_IDL_HSSYN'
        'Liver_LDL_HSSYN'
        'Liver_HDL_HSSYN'
        'Liver_LDH_D'
        % 'Liver_BAAT2x'
        'Liver_ACS'
        % 'Liver_ACS2'
        'Liver_ALCD2if'
        % 'Liver_BGLYFm'
        'Liver_DGAT'
        'Liver_DHCR72r'
        'Liver_DHCR243r' %% add in next simulation round
        'Liver_GTHS'
        'Liver_PHACCOAGLNAC'
        'Liver_r0629'
        'Liver_r0630'
        'Liver_RE2637C'
        % 'Liver_RE2637X'
        'Liver_BGLYFm'
        'Liver_EX_chsterols(e)_[bc]'
        'Liver_VALTA'
        'Liver_VALTAm'
        'Adipocytes_VALTA'
        'Adipocytes_VALTAm'
        'Brain_VALTA'
        'Brain_VALTAm'
        'Liver_LEUTA'
        'Liver_LEUTAm'
        'Adipocytes_LEUTA'
        'Adipocytes_LEUTAm'
        'Brain_LEUTA'
        'Brain_LEUTAm'
        'Liver_ILETAA'
        'Liver_ILETAm'
        'Adipocytes_ILETA'
        'Adipocytes_ILETAm'
        'Brain_ILETA'
        'Brain_ILETAm'
        'Liver_OIVD2m'
        'Adipocytes_OIVD2m'
        'Brain_OIVD2m'
        'Liver_PDHm'
        'Adipocytes_PDHm'
        'Brain_PDHm'
        'Heart_PDHm'
        'Muscle_PDHm'
        'Brain_PHETHPTOX2'
        'Brain_PGM'
        'Brain_HMR_7749'
        'Brain_HMR_7746'
        'Brain_HMR_7748'
        'Brain_HMR_7745'
        'Brain_PHEMEtm'
        'Brain_PGK'
        'Muscle_PGK'
        'Heart_PGK'
        'Liver_PGK'
        'Adipocytes_PGK'
        'Brain_CYOOm3'
        'Muscle_CYOOm3'
        'Heart_CYOOm3'
        'Liver_CYOOm3'
        'Adipocytes_CYOOm3'
        'Brain_SUCOASm'
        'Muscle_SUCOASm'
        'Heart_SUCOASm'
        'Liver_SUCOASm'
        'Adipocytes_SUCOASm'
        'EX_acnam[u]'
        'EX_pheacgln[u]'
        'EX_3hmp[u]'
        'EX_succ[u]'
        'EX_cit[u]'
        'EX_glc_D[u]'
        'EX_urea[u]'
        'EX_glcur[u]'
        'CD4Tcells_EX_leuktrA4(e)_[bc]'
        'CD4Tcells_EX_leuktrD4(e)_[bc]'
        'Nkcells_EX_lac_L(e)_[bc]'
        'Nkcells_EX_leuktrA4(e)_[bc]'
        'Nkcells_EX_leuktrB4(e)_[bc]'
        'Nkcells_EX_leuktrF4(e)_[bc]'
        'Monocyte_EX_leuktrA4(e)_[bc]'
        'Monocyte_EX_leuktrB4(e)_[bc]'
        'Monocyte_EX_leuktrD4(e)_[bc]'
        'Monocyte_EX_leuktrE4(e)_[bc]'
        'Brain_G6PPer' %gluconeogenisis
        'Liver_G6PPer' %gluconeogenisis
        'Kidney_G6PPer' %gluconeogenisis
        'Brain_EX_o2(e)_[csf]'
        'Heart_EX_o2(e)_[bc]'
        'RBC_MTHFR3'
        'Kidney_MTHFR3'
        'Brain_CK'
        'Brain_CKc'
        'Muscle_CK'
        'Muscle_CKc'
        'Heart_CK' % increase linked to heart attack
        'Heart_CKc'
        };
    RxnMax = unique(RxnMax);
end
if exist('Results','var')
    [cnt,b] =size(Results);
    cnt = cnt +1; % append to existing Results
else
    cnt = 1;
end

% modelHM = modelOHM;
% set fasting or feeding state
modelHM = setFeedingFastingConstraints(modelHM, 'feeding');
% set diet - either AvAm or Bal
modelHM = setDietConstraints(modelHM, Diet);
if setStandard ==1
    % set constraints based on HMDB
    sex=modelHM.sex;
    standardPhysiolDefaultParameters;
    modelHM = physiologicalConstraintsHMDBbased(modelHM,IndividualParameters);
    [modelHM] = setDefaultModelingConstraints(modelHM);
end
% This allows me the use the script also for the GF version
if ~isempty(strmatch('Excretion_EX_microbiota_LI_biomass[fe]',modelHM.rxns,'exact'))
    %%fecal microbiota
    modelHM = changeObjective(modelHM, 'Excretion_EX_microbiota_LI_biomass[fe]');
    tic;[solutionHM,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    Results{cnt,1}='Excretion_EX_microbiota_LI_biomass[fe]';
    if solutionHM.origStat ~= -1 % problem is feasible
        Results{cnt,2}=num2str(solutionHM.full(find(modelHM.c)));
        ResultsSol(:,cnt)=solutionHM.full;
        ResultsStats(:,cnt)=solutionHM.origStat;
    else
        Results{cnt,2}='NaN';
        ResultsSol(:,cnt)=[];
        ResultsStats(:,cnt)=solutionHM.origStat;
    end
    cnt = cnt +1;
    % set faecal secretion constraint
    modelHM.lb(find(ismember(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=0.4; %
    modelHM.ub(find(ismember(modelHM.rxns,'Excretion_EX_microbiota_LI_biomass[fe]')))=1; %
else
    Results{cnt,1}='Excretion_EX_microbiota_LI_biomass[fe]';
    Results{cnt,2}=num2str(0);
    ResultsSol(:,cnt)=zeros(length(modelHM.rxns),1);
    ResultsStats(:,cnt)=1;
    cnt = cnt +1;
end
%%Test flux through Whole_body_objective_rxn
modelHM = changeObjective(modelHM, 'Whole_body_objective_rxn');
tic;[solutionHM,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,LPSolver);toc
Results{cnt,1}='Whole_body_objective_rxn(max)';
if solutionHM.origStat ~= -1 % problem is feasible
    Results{cnt,2}=num2str(solutionHM.full(find(modelHM.c)));
    ResultsSol(:,cnt)=solutionHM.full;
    ResultsStats(:,cnt)=solutionHM.origStat;
else
    Results{cnt,2}='NaN';
    ResultsSol(:,cnt)=[];
    ResultsStats(:,cnt)=solutionHM.origStat;
end
cnt = cnt +1;
LPProblem=modelHM;

LPProblem.osense = 1; % minimization
tic;[solutionHM,LPProblem]=solveCobraLPCPLEX(LPProblem,1,0,0,[],0,LPSolver);toc
Results{cnt,1}='Whole_body_objective_rxn(min)';
if solutionHM.origStat ~= -1 % problem is feasible
    Results{cnt,2}=num2str(solutionHM.full(find(LPProblem.c)));
    ResultsSol(:,cnt)=solutionHM.full;
    ResultsStats(:,cnt)=solutionHM.origStat;
else
    Results{cnt,2}='NaN';
    ResultsSol(:,cnt)=[];
    ResultsStats(:,cnt)=solutionHM.origStat;
end
cnt = cnt +1;

% set lb of RMR to 1U
%modelHM.lb(find(ismember(modelHM.rxns,'Whole_body_objective_rxn')))=1;
%% Maximize for alternatives - reuse basis

for i = 1 : length(RxnMax)
    RxnMax{i}
    % check that reaction is in model
    if ~isempty(strmatch(RxnMax{i},LPProblem.rxns,'exact'))
        LPProblemMin = changeObjective(LPProblem,RxnMax{i});
        LPProblemMin.osense = -1;
        tic;[solutionHM,LPProblemMin]=solveCobraLPCPLEX(LPProblemMin,1,1,0,[],0,LPSolver);toc
        Results{cnt,1}=RxnMax{i};
        if solutionHM.origStat ~= -1 % problem is feasible
            Results{cnt,2}=num2str(solutionHM.full(find(LPProblemMin.c)));
            ResultsSol(:,cnt)=solutionHM.full;
            ResultsStats(:,cnt)=solutionHM.origStat;
        else
            Results{cnt,2}='NaN';
            ResultsSol(:,cnt)=[];
            ResultsStats(:,cnt)=solutionHM.origStat;
        end
        cnt = cnt +1;
    end
end

for i = 1 : length(RxnMin)
    % check that reaction is in model
    if ~isempty(strmatch(RxnMin{i},LPProblem.rxns,'exact'))
        LPProblemMin = changeObjective(LPProblem,RxnMin{i});
        LPProblemMin.osense = 1;
        tic;[solutionHM,LPProblemMin]=solveCobraLPCPLEX(LPProblemMin,1,1,0,[],0,LPSolver);toc
        Results{cnt,1}=RxnMin{i};
        if solutionHM.origStat ~= -1 % problem is feasible
            Results{cnt,2}=num2str(solutionHM.full(find(LPProblemMin.c)));
            ResultsSol(:,cnt)=solutionHM.full;
            ResultsStats(:,cnt)=solutionHM.origStat;
        else
            Results{cnt,2}='NaN';
            ResultsSol(:,cnt)=[];
            ResultsStats(:,cnt)=solutionHM.origStat;
        end
        cnt = cnt +1;
    end
end
