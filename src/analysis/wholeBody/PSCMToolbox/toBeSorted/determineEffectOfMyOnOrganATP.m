%compute the effect of microbiota on organ atp hydrolysis capability

    standardPhysiolDefaultParameters;
if strcmp(gender,'male')
    load 2017_05_18_HarveyJoint_10_28_constraintHMDB_EUDiet_d
    %load 2017_10_28_male_microbiota_model_samp_SRS013476a
    load 2017_10_28_male_microbiota_model_samp_SRS011134
     modelOrganAllCoupled = physiologicalConstraintsHMDBbased(modelOrganAllCoupled,IndividualParameters,ExclList);
    modelOrganAllCoupled=setSimulationConstraints(modelOrganAllCoupled);
     modelHM = physiologicalConstraintsHMDBbased(modelHM,IndividualParameters,ExclList);
    modelHM=setSimulationConstraints(modelHM);
else
    load 2017_05_18_HarvettaJoint_10_28_constraintHMDB_EUDiet_d
    % load 2017_10_28_female_microbiota_model_samp_SRS050752a
    load 2017_10_28_female_microbiota_model_samp_SRS011239
   %load 2017_10_28_female_microbiota_model_samp_SRS052697
     modelOrganAllCoupled = physiologicalConstraintsHMDBbased(modelOrganAllCoupled,IndividualParameters,ExclList);
    modelOrganAllCoupled=setSimulationConstraints(modelOrganAllCoupled);
     modelHM = physiologicalConstraintsHMDBbased(modelHM,IndividualParameters,ExclList);
    modelHM=setSimulationConstraints(modelHM);
end

OrganLists;

modelOrganAllCoupled = changeRxnBounds(modelOrganAllCoupled,'Whole_body_objective_rxn',1,'b');
modelHM = changeRxnBounds(modelHM,'Whole_body_objective_rxn',1,'b');

for i = 1 :length(OrgansListShort)
    k = 1;
    Results.List{i+1,k} = OrgansListShort{i};k = k+1;
    if ~isempty(find(ismember(modelHM.rxns,strcat(OrgansListShort{i},'_DM_atp_c_'))))
        
        modelHM = changeObjective(modelHM,strcat(OrgansListShort{i},'_DM_atp_c_'));
        modelHM.osense = -1;
        tic;[solutionHM_Max,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
        Results.List{i+1,k} = num2str(solutionHM_Max.full(find(modelHM.c)));
        k = k+1;
        if 0
        modelOrganAllCoupled = changeObjective(modelOrganAllCoupled,strcat(OrgansListShort{i},'_DM_atp_c_'));
        modelOrganAllCoupled.osense = -1;
        tic;[solutionGF_Max,LPProblem]=solveCobraLPCPLEX(modelOrganAllCoupled,1,0,0,[],0,'tomlab_cplex');toc
        Results.List{i+1,k} = num2str(solutionGF_Max.full(find(modelOrganAllCoupled.c)));k = k+1;
        Results.List{i+1,k} = num2str(solutionHM_Max.full(find(modelHM.c))/solutionGF_Max.full(find(modelOrganAllCoupled.c)));k = k+1;
        end
    end
end

% the values seem to change with the coupling constraints (and diet and
% other applied constraints)
% I will try with another coupling constraint

% Orig has 20000 as coupling constrain
if 0
    modelOrganAllCoupled.A(find(modelOrganAllCoupled.A==20000))=17000;
    modelOrganAllCoupled.A(find(modelOrganAllCoupled.A==-20000))=-17000;
    
    modelOrganAllCoupled = changeRxnBounds(modelOrganAllCoupled,'Whole_body_objective_rxn',1,'b');
    modelHM = changeRxnBounds(modelHM,'Whole_body_objective_rxn',1,'b');
    
    for i = 1 :length(OrgansListShort)
        k = 1;
        Results.List{i+1,k} = OrgansListShort{i};k = k+1;
        if ~isempty(find(ismember(modelHM.rxns,strcat(OrgansListShort{i},'_DM_atp_c_'))))
            
            modelHM = changeObjective(modelHM,strcat(OrgansListShort{i},'_DM_atp_c_'));
            modelHM.osense = -1;
            tic;[solutionHM_Max,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
            Results17.List{i+1,k} = num2str(solutionHM_Max.full(find(modelHM.c)));
            k = k+1;
            
            modelOrganAllCoupled = changeObjective(modelOrganAllCoupled,strcat(OrgansListShort{i},'_DM_atp_c_'));
            modelOrganAllCoupled.osense = -1;
            tic;[solutionGF_Max,LPProblem]=solveCobraLPCPLEX(modelOrganAllCoupled,1,0,0,[],0,'tomlab_cplex');toc
            Results17.List{i+1,k} = num2str(solutionGF_Max.full(find(modelOrganAllCoupled.c)));k = k+1;
            Results17.List{i+1,k} = num2str(solutionHM_Max.full(find(modelHM.c))/solutionGF_Max.full(find(modelOrganAllCoupled.c)));k = k+1;
            
        end
    end
    
end

% compute atp-fat with modelHM
if 1
    %modelOrganAllCoupled = changeRxnBounds(modelOrganAllCoupled,'Whole_body_objective_rxn',1,'b');
    modelHM = changeRxnBounds(modelHM,'Whole_body_objective_rxn',1,'b');
    modelHM = changeRxnBounds(modelHM,'EX_microbeBiomass[fe]',1,'b');
    
    stepSize = 10;
    % defaul config
    if strcmp(gender,'male')
        [ResultsATP_Fat_male_HM, ResultsATP_Fat_Rcost_male_HM, ResultsATP_Fat_Sprice_male_HM,ResultsATP_Fat_Full_male_HM] = computeMuscleATP_FatStorage(modelHM,stepSize);
    else
        [ResultsATP_Fat_female_HM, ResultsATP_Fat_Rcost_female_HM, ResultsATP_Fat_Sprice_female_HM,ResultsATP_Fat_Full_female_HM] = computeMuscleATP_FatStorage(modelHM,stepSize);
    end
end

if strcmp(gender,'male')
    save 2017_10_28_Results_MyEffectOrganATP_male
else
    save 2017_10_28_Results_MyEffectOrganATP_female
end