

if strcmp(gender,'male')
    load 2017_10_28_male_microbiota_model_samp_SRS011134
    modelOrganAllCoupled=setSimulationConstraints(modelOrganAllCoupled);
    modelHM=setSimulationConstraints(modelHM);
else
    %load 2017_10_28_female_microbiota_model_samp_SRS011239
    load 2017_10_28_female_microbiota_model_samp_SRS065504
    modelOrganAllCoupled=setSimulationConstraints(modelOrganAllCoupled);
    modelHM=setSimulationConstraints(modelHM);
end


modelOrganAllCoupled = changeRxnBounds(modelOrganAllCoupled,'Whole_body_objective_rxn',1,'b');
modelHM = changeRxnBounds(modelHM,'Whole_body_objective_rxn',1,'b');

% tic;[sol,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
% modelHM = changeObjective(modelHM,'Brain_DM_atp_c_');
% tic;[sol,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
% modelHMO=modelHM;
% tic;[sol,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc

Rxn = {'Liver_PCSF';%Y
    'Liver_ALCD2if';%Y
    % still to check
    'Liver_ACS' % gluconeogenesis from acetate%Y
    % (https://academic.oup.com/jcem/article/101/4/1445/2804883)
    'Liver_DGAT'%Y
    'Liver_DHCR72r'%Y
    % %     'Liver_EX_val_L(e)_[bc]'
    % %     'Liver_EX_ile_L(e)_[bc]'
    % %     'Liver_EX_leu_L(e)_[bc]'
    % %     'Liver_EX_phe_L(e)_[bc]'
    'Colon_HMR_0156' %atp[c] + but[c] + coa[c] <=> amp[c] + btcoa[c] + ppi[c]%Y
    % neurotransmitter
    'Brain_DM_dopa[c]';%Y
    'Brain_DM_srtn[c]';%Y
    % %     'Brain_DM_adrnl[c]'
    % %     'Brain_DM_hista[c]'
    % %     'Brain_DM_kynate[c]'
    % %     'Brain_DM_nrpphr[c]'
    % %     'Brain_DM_Lkynr[c]'
    % %     'Brain_DM_4abut[c]'
    % %     % BAs
    % %     'Brain_DM_3dhcdchol(c)'
    % %     'Brain_DM_3dhchol(c)'
    % %     'Brain_DM_3dhdchol(c)'
    % %     'Brain_DM_ca3s(c)'
    % %     'Brain_DM_cdca24g(c)'
    % %     'Brain_DM_dca3s(c)'
    % %     'Brain_DM_gca3s(c)'
    % %     'Brain_DM_gcdca3s(c)'
    % %     'Brain_DM_gdca3s(c)'
    % %     'Brain_DM_gudca3s(c)'
    % %     'Brain_DM_tca3s(c)'
    % %     'Brain_DM_tcdca3s(c)'
    % %     'Brain_DM_tdca3s(c)'
    % %     'Brain_DM_thyochol(c)'
    % %     'Brain_DM_tudca3s(c)'
    % %     'Brain_DM_udca3s(c)'
    };

%  not interesting anymore
% 'Kidney_KYNATESYN', 'Brain_GLUDC'
%   'Brain_DM_ach[c]'
%  'Brain_DM_tym[c]'
%'Liver_EX_3aib(e)_[bc]'
%'Liver_LDL_HSSYN'
%'Muscle_ACS' % gluconeogenesis from acetate
%'Liver_ACCOALm' % gluconeogenesis from proprionate - same as Liver_DGAT
% interesting reactions:
for i = 1 : length(Rxn)
    modelHM = changeObjective(modelHM,Rxn{i});
    modelHM.osense = -1;%max
    tic;[sol,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    RxnF(i,1) = sol.full(find(ismember(modelHM.rxns,Rxn{i})));
    if 0
        modelOrganAllCoupled = changeObjective(modelOrganAllCoupled,Rxn{i});
        modelOrganAllCoupled.osense = -1;%max
        tic;[solGF,LPProblem]=solveCobraLPCPLEX(modelOrganAllCoupled,1,0,0,[],0,'tomlab_cplex');toc
        RxnF(i,2) = solGF.full(find(ismember(modelOrganAllCoupled.rxns,Rxn{i})));
    end
end

