ExclList='';
    standardPhysiolDefaultParameters;
   load 2017_10_28_female_microbiota_model_samp_SRS065504
%load 2017_10_28_female_microbiota_model_samp_SRS024388
modelOrganAllCoupled = physiologicalConstraintsHMDBbased(modelOrganAllCoupled,IndividualParameters,ExclList);
modelOrganAllCoupled=setSimulationConstraints(modelOrganAllCoupled);
modelHM = physiologicalConstraintsHMDBbased(modelHM,IndividualParameters,ExclList);
modelHM=setSimulationConstraints(modelHM);


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
    };
for i = 1 : length(Rxn)
    modelHM = changeObjective(modelHM,Rxn{i});
    modelHM.osense = -1;%max
    [sol,]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');
    RxnF(i,1) = sol.full(find(ismember(modelHM.rxns,Rxn{i})));
    if 0
        modelOrganAllCoupled = changeObjective(modelOrganAllCoupled,Rxn{i});
        modelOrganAllCoupled.osense = -1;%max
        [solGF]=solveCobraLPCPLEX(modelOrganAllCoupled,1,0,0,[],0,'tomlab_cplex');
        RxnF(i,2) = solGF.full(find(ismember(modelOrganAllCoupled.rxns,Rxn{i})));
    end
end