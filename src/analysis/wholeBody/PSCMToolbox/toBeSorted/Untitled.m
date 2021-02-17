

load 2017_05_18_HarveyJoint_11_22_constraintHMDB_EUDiet_d
male = modelOrganAllCoupled;
load 2017_05_18_HarvettaJoint_11_22_constraintHMDB_EUDiet_d
female = modelOrganAllCoupled;

%% reduced cost associated with WBO
    male = changeRxnBounds(male,'Whole_body_objective_rxn',100,'u');
    male = changeObjective(male,'Whole_body_objective_rxn');
    male.osense = -1;
     tic;[solution_male,LPProblem]=solveCobraLPCPLEX(male,1,0,0,[],0,'tomlab_cplex');toc
     [RCostTableAll_male,RCostTableRxnTag_male] = getRCostTable(male, solution_male,'Diet_EX');
     
    female = changeRxnBounds(female,'Whole_body_objective_rxn',100,'u');
    female = changeObjective(female,'Whole_body_objective_rxn');
    female.osense = -1;
     tic;[solution_female,LPProblem]=solveCobraLPCPLEX(female,1,0,0,[],0,'tomlab_cplex');toc
     [RCostTableAll_female,RCostTableRxnTag_female] = getRCostTable(female, solution_female,'Diet_EX');
     
     % test choline in diet
    female = changeRxnBounds(female,'Whole_body_objective_rxn',100,'u');
    female = changeObjective(female,'Whole_body_objective_rxn');
    female.osense = -1;
    female_chol = changeRxnBounds(female,'Diet_EX_glyb[d]',-1000,'l');
     tic;[solution_female_chol,LPProblem]=solveCobraLPCPLEX(female_chol,1,0,0,[],0,'tomlab_cplex');toc
     [RCostTableAll_female_chol,RCostTableRxnTag_female_chol] = getRCostTable(female_chol, solution_female_chol,'Diet_EX');
     %% reduced cost associated with Brain_DM_atp_c_
    male = changeRxnBounds(male,'Whole_body_objective_rxn',1,'u');
    male = changeObjective(male,'Brain_DM_atp_c_');
    male.osense = -1;
     tic;[solution_male_brain,LPProblem]=solveCobraLPCPLEX(male,1,0,0,[],0,'tomlab_cplex');toc
     [RCostTableAll_male_brain,RCostTableRxnTag_male_brain] = getRCostTable(male, solution_male_brain,'Diet_EX');
     
    female = changeRxnBounds(female,'Whole_body_objective_rxn',1,'u');
    female = changeObjective(female,'Brain_DM_atp_c_');
    female.osense = -1;
     tic;[solution_female_brain,LPProblem]=solveCobraLPCPLEX(female,1,0,0,[],0,'tomlab_cplex');toc
     [RCostTableAll_female_brain,RCostTableRxnTag_female_brain] = getRCostTable(female, solution_female_brain,'Diet_EX');
     %% test diet supplementations for increased Brain_DM_atp_c_
     % ksi
    male_ksi = changeRxnBounds(male,'Diet_EX_ksi[d]',-1,'l'); %from 0
    male_ksi = changeObjective(male_ksi,'Brain_DM_atp_c_');
    male_ksi.osense = -1;
     tic;[solution_male_brain_ksi,LPProblem]=solveCobraLPCPLEX(male_ksi,1,0,0,[],0,'tomlab_cplex');toc
     [RCostTableAll_male_brain_ksi,RCostTableRxnTag_male_brain_ksi] = getRCostTable(male_ksi, solution_male_brain_ksi,'Diet_EX');
     
    female_ksi = changeRxnBounds(female,'Diet_EX_ksi[d]',-1,'l');
    female_ksi = changeObjective(female_ksi,'Brain_DM_atp_c_');
    female_ksi.osense = -1;
     tic;[solution_female_brain_ksi,LPProblem]=solveCobraLPCPLEX(female_ksi,1,0,0,[],0,'tomlab_cplex');toc
     [RCostTableAll_female_brain_ksi,RCostTableRxnTag_female_brain_ksi] = getRCostTable(female_ksi, solution_female_brain_ksi,'Diet_EX');
       % so4 - makes no difference anymore
    male_so4 = changeRxnBounds(male,'Diet_EX_so4[d]',-1000,'l');%from -50
    male_so4 = changeObjective(male_so4,'Brain_DM_atp_c_');
    male_so4.osense = -1;
     tic;[solution_male_brain_so4,LPProblem]=solveCobraLPCPLEX(male_so4,1,0,0,[],0,'tomlab_cplex');toc
     [RCostTableAll_male_brain_so4,RCostTableRxnTag_male_brain_so4] = getRCostTable(male_so4, solution_male_brain_so4,'Diet_EX');
     
    female_so4 = changeRxnBounds(female,'Diet_EX_so4[d]',-1000,'l');
    female_so4 = changeObjective(female_so4,'Brain_DM_atp_c_');
    female_so4.osense = -1;
     tic;[solution_female_brain_so4,LPProblem]=solveCobraLPCPLEX(female_so4,1,0,0,[],0,'tomlab_cplex');toc
     [RCostTableAll_female_brain_so4,RCostTableRxnTag_female_brain_so4] = getRCostTable(female_so4, solution_female_brain_so4,'Diet_EX');
      % Lcystin
    male_Lcystin = changeRxnBounds(male,'Diet_EX_Lcystin[d]',-100,'l');%from -50
    male_Lcystin = changeObjective(male_Lcystin,'Brain_DM_atp_c_');
    male_Lcystin.osense = -1;
     tic;[solution_male_brain_Lcystin,LPProblem]=solveCobraLPCPLEX(male_Lcystin,1,0,0,[],0,'tomlab_cplex');toc
     [RCostTableAll_male_brain_Lcystin,RCostTableRxnTag_male_brain_Lcystin] = getRCostTable(male_Lcystin, solution_male_brain_Lcystin,'Diet_EX');
     
    female_Lcystin = changeRxnBounds(female,'Diet_EX_Lcystin[d]',-100,'l');
    female_Lcystin = changeObjective(female_Lcystin,'Brain_DM_atp_c_');
    female_Lcystin.osense = -1;
     tic;[solution_female_brain_Lcystin,LPProblem]=solveCobraLPCPLEX(female_Lcystin,1,0,0,[],0,'tomlab_cplex');toc
     [RCostTableAll_female_brain_Lcystin,RCostTableRxnTag_female_brain_Lcystin] = getRCostTable(female_Lcystin, solution_female_brain_Lcystin,'Diet_EX');
     % 7thf
    male_7thf = changeRxnBounds(male,'Diet_EX_7thf[d]',-100,'l');%from -50
    male_7thf = changeObjective(male_7thf,'Brain_DM_atp_c_');
    male_7thf.osense = -1;
     tic;[solution_male_brain_7thf,LPProblem]=solveCobraLPCPLEX(male_7thf,1,0,0,[],0,'tomlab_cplex');toc
     [RCostTableAll_male_brain_7thf,RCostTableRxnTag_male_brain_7thf] = getRCostTable(male_7thf, solution_male_brain_7thf,'Diet_EX');
     
    female_7thf = changeRxnBounds(female,'Diet_EX_7thf[d]',-100,'l');
    female_7thf = changeObjective(female_7thf,'Brain_DM_atp_c_');
    female_7thf.osense = -1;
     tic;[solution_female_brain_7thf,LPProblem]=solveCobraLPCPLEX(female_7thf,1,0,0,[],0,'tomlab_cplex');toc
     [RCostTableAll_female_brain_7thf,RCostTableRxnTag_female_brain_7thf] = getRCostTable(female_7thf, solution_female_brain_7thf,'Diet_EX');
   

%% Muscle DM atp
    male = changeRxnBounds(male,'Whole_body_objective_rxn',1,'u');
    female = changeRxnBounds(female,'Whole_body_objective_rxn',1,'u');
    
    [ResultsATP_Fat_male] = computeMuscleATP_FatStorage(male,10); % computes only min max
    [ResultsATP_Fat_female] = computeMuscleATP_FatStorage(female,10); % computes only min max
     [Energy_kJ_male,Energy_kcal_male,Meter_K_male,StepNumber_male] = convertATPflux2StepNumer(ResultsATP_Fat_male(10,1), 'male', 70, 170);
     [Energy_kJ_female,Energy_kcal_female,Meter_K_female,StepNumber_female] = convertATPflux2StepNumer(ResultsATP_Fat_female(10,1), 'female', 58, 160);

     % change diet to unhealthy
     
    UnhealthyDiet;
    male_Unh = setDietConstraints(male,Diet);
    male_Unh = changeObjective(male_Unh,'Whole_body_objective_rxn');
    male_Unh.osense = -1;
     tic;[solution_female,LPProblem]=solveCobraLPCPLEX(male_Unh,1,0,0,[],0,'tomlab_cplex');toc
     
    female_Unh = setDietConstraints(female,Diet);
    female_Unh = changeObjective(female_Unh,'Whole_body_objective_rxn');
    male_Unh.osense = -1;
     tic;[solution_female,LPProblem]=solveCobraLPCPLEX(female_Unh,1,0,0,[],0,'tomlab_cplex');toc
        [ResultsATP_Fat_male_Unh] = computeMuscleATP_FatStorage(male_Unh,10); % computes only min max
    [ResultsATP_Fat_female_Unh] = computeMuscleATP_FatStorage(female_Unh,10); % computes only min max
     [Energy_kJ_male_Unh,Energy_kcal_male_Unh,Meter_K_male_Unh,StepNumber_male_Unh] = convertATPflux2StepNumer(ResultsATP_Fat_male_Unh(10,1), 'male', 70, 170);
     [Energy_kJ_female_Unh,Energy_kcal_female_Unh,Meter_K_female_Unh,StepNumber_female_Unh] = convertATPflux2StepNumer(ResultsATP_Fat_female_Unh(10,1), 'female', 58, 160);

      % change diet to DACH
      DACH;
    male_Dach = setDietConstraints(male,Diet);
    male_Dach = changeObjective(male_Dach,'Whole_body_objective_rxn');
    male_Dach.osense = -1;
     tic;[solution_female,LPProblem]=solveCobraLPCPLEX(male_Dach,1,0,0,[],0,'tomlab_cplex');toc
     
    female_Dach = setDietConstraints(female,Diet);
    female_Dach = changeObjective(female_Dach,'Whole_body_objective_rxn');
    male_Dach.osense = -1;
     tic;[solution_female,LPProblem]=solveCobraLPCPLEX(female_Dach,1,0,0,[],0,'tomlab_cplex');toc
        [ResultsATP_Fat_male_Dach] = computeMuscleATP_FatStorage(male_Dach,10); % computes only min max
    [ResultsATP_Fat_female_Dach] = computeMuscleATP_FatStorage(female_Dach,10); % computes only min max
     [Energy_kJ_male_Dach,Energy_kcal_male_Dach,Meter_K_male_Dach,StepNumber_male_Dach] = convertATPflux2StepNumer(ResultsATP_Fat_male_Dach(10,1), 'male', 70, 170);
     [Energy_kJ_female_Dach,Energy_kcal_female_Dach,Meter_K_female_Dach,StepNumber_female_Dach] = convertATPflux2StepNumer(ResultsATP_Fat_female_Dach(10,1), 'female', 58, 160);

       % change diet to Mediterranian
      Mediterranian;
    male_Medi = setDietConstraints(male,Diet);
    male_Medi = changeObjective(male_Medi,'Whole_body_objective_rxn');
    male_Medi.osense = -1;
     tic;[solution_female,LPProblem]=solveCobraLPCPLEX(male_Medi,1,0,0,[],0,'tomlab_cplex');toc
     
    female_Medi = setDietConstraints(female,Diet);
    female_Medi = changeObjective(female_Medi,'Whole_body_objective_rxn');
    male_Medi.osense = -1;
     tic;[solution_female,LPProblem]=solveCobraLPCPLEX(female_Medi,1,0,0,[],0,'tomlab_cplex');toc
        [ResultsATP_Fat_male_Medi] = computeMuscleATP_FatStorage(male_Medi,10); % computes only min max
    [ResultsATP_Fat_female_Medi] = computeMuscleATP_FatStorage(female_Medi,10); % computes only min max
     [Energy_kJ_male_Medi,Energy_kcal_male_Medi,Meter_K_male_Medi,StepNumber_male_Medi] = convertATPflux2StepNumer(ResultsATP_Fat_male_Medi(10,1), 'male', 70, 170);
     [Energy_kJ_female_Medi,Energy_kcal_female_Medi,Meter_K_female_Medi,StepNumber_female_Medi] = convertATPflux2StepNumer(ResultsATP_Fat_female_Medi(10,1), 'female', 58, 160);

     