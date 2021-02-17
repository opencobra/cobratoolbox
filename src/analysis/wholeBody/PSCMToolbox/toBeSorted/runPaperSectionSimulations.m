

load 2017_05_18_HarveyJoint_11_22_constraintHMDB_EUDiet_d
male = modelOrganAllCoupled;
load 2017_05_18_HarvettaJoint_11_22_constraintHMDB_EUDiet_d
female = modelOrganAllCoupled;

standardPhysiolDefaultParameters;
% apply HMDB metabolomic data based on personalized individual parameters
female = physiologicalConstraintsHMDBbased(female,IndividualParameters);

female = setDietConstraints(female);
% set some more constraints
female = setSimulationConstraints(female);

female.lb(strmatch('BBB_KYNATE[CSF]upt',female.rxns)) = -1000000; %constrained uptake
female.lb(strmatch('BBB_LKYNR[CSF]upt',female.rxns)) = -1000000; %constrained uptake
female.lb(strmatch('BBB_TRP_L[CSF]upt',female.rxns)) = -1000000; %constrained uptake

female.ub(strmatch('Brain_EX_glc_D(',female.rxns)) = -100; % currently -400 rendering many of the models to be infeasible in germfree state
%
male = physiologicalConstraintsHMDBbased(male,IndividualParameters);
male = setDietConstraints(male);
% set some more constraints
male = setSimulationConstraints(male);
male.lb(strmatch('BBB_KYNATE[CSF]upt',male.rxns)) = -1000000; %constrained uptake
male.lb(strmatch('BBB_LKYNR[CSF]upt',male.rxns)) = -1000000; %constrained uptake
male.lb(strmatch('BBB_TRP_L[CSF]upt',male.rxns)) = -1000000; %constrained uptake
male.ub(strmatch('Brain_EX_glc_D(',male.rxns)) = -100; % currently -400 rendering many of the models to be infeasible in germfree state

%% compute BMR
male = changeRxnBounds(male,'Whole_body_objective_rxn',1,'b');
female = changeRxnBounds(female,'Whole_body_objective_rxn',1,'b');

male = changeObjective(male,'Whole_body_objective_rxn');
male.osense = 1;
%[solution_male,LPProblem]=solveCobraLPCPLEX(male,1,0,0,[],1e-6,'tomlab_cplex')
 [solution_male] = computeMin2Norm_HH(male);
S = male.A;
F = max(-S,0);
R = max(S,0);
vf = max(solution_male.full,0);
vr = max(-solution_male.full,0);
prod=[R;F]*[vf vr];
con=[F;R]*[vf vr];
atp = (find(~cellfun(@isempty,strfind(male.mets,'_atp['))));
Sum_atp_male=sum( prod(atp));

Energy_kJ = Sum_atp_male/1000 * 64; %in kJ per person per day
% 1 kJ = 0.239006 kcal
Energy_kcal_male = Energy_kJ*0.239006 %in kcal per person per day

Brain_atp = (find(~cellfun(@isempty,strfind(male.mets,'Brain_atp['))));
Sum_Brain_atp_male=sum( prod(Brain_atp))

Energy_kJ = Sum_Brain_atp_male/1000 * 31; %in kJ per person per day
% 1 kJ = 0.239006 kcal
Brain_Energy_kcal_male = Energy_kJ*0.239006 %in kcal per person per day

Muscle_atp = (find(~cellfun(@isempty,strfind(male.mets,'Muscle_atp['))));
Sum_Muscle_atp_male=sum( prod(Muscle_atp))

Energy_kJ = Sum_Muscle_atp_male/1000 * 64; %in kJ per person per day
% 1 kJ = 0.239006 kcal
Muscle_Energy_kcal_male = Energy_kJ*0.239006 %in kcal per person per day

Heart_atp = (find(~cellfun(@isempty,strfind(male.mets,'Heart_atp['))));
Sum_Heart_atp_male=sum( prod(Heart_atp))

Energy_kJ = Sum_Heart_atp_male/1000 * 64; %in kJ per person per day
% 1 kJ = 0.239006 kcal
Heart_Energy_kcal_male = Energy_kJ*0.239006 %in kcal per person per day

female = changeObjective(female,'Whole_body_objective_rxn');
female.osense = 1;
%[solution_female,LPProblem]=solveCobraLPCPLEX(female,1,0,0,[],1e-6,'tomlab_cplex')

 [solution_female] = computeMin2Norm_HH(female);
S = female.A;
F = max(-S,0);
R = max(S,0);
vf = max(solution_female.full,0);
vr = max(-solution_female.full,0);
prod=[R;F]*[vf vr];
con=[F;R]*[vf vr];
atp = (find(~cellfun(@isempty,strfind(female.mets,'_atp['))));
Sum_atp_female=sum( prod(atp));

Energy_kJ = Sum_atp_female/1000 * 64; %in kJ per person per day
% 1 kJ = 0.239006 kcal
Energy_kcal_female = Energy_kJ*0.239006 %in kcal per person per day

Brain_atp = (find(~cellfun(@isempty,strfind(female.mets,'Brain_atp['))));
Sum_Brain_atp_female=sum( prod(Brain_atp))

Energy_kJ = Sum_Brain_atp_female/1000 ; %in kJ per person per day
% 1 kJ = 0.239006 kcal
Brain_Energy_kcal_female = Energy_kJ*0.239006 %in kcal per person per day

Muscle_atp = (find(~cellfun(@isempty,strfind(female.mets,'Muscle_atp['))));
Sum_Muscle_atp_female=sum( prod(Muscle_atp))

Energy_kJ = Sum_Muscle_atp_female/1000 * 64; %in kJ per person per day
% 1 kJ = 0.239006 kcal
Muscle_Energy_kcal_female = Energy_kJ*0.239006 %in kcal per person per day

Heart_atp = (find(~cellfun(@isempty,strfind(female.mets,'Heart_atp['))));
Sum_Heart_atp_female=sum( prod(Heart_atp))

Energy_kJ = Sum_Heart_atp_female/1000 * 64; %in kJ per person per day
% 1 kJ = 0.239006 kcal
Heart_Energy_kcal_female = Energy_kJ*0.239006 %in kcal per person per day

% cori cycle flux
Liver_glc = (find(~cellfun(@isempty,strfind(female.rxns,'Liver_EX_glc_D(e)_[bc]'))));
Liver_glcF=solution_female.full(Liver_glc);
Muscle_glc = (find(~cellfun(@isempty,strfind(female.rxns,'Muscle_EX_glc_D(e)_[bc]'))));
Muscle_glcF=solution_female.full(Muscle_glc);
Liver_lac = (find(~cellfun(@isempty,strfind(female.rxns,'Liver_EX_lac_L(e)_[bc]'))));
Liver_lacF=solution_female.full(Liver_lac);
Muscle_lac = (find(~cellfun(@isempty,strfind(female.rxns,'Muscle_EX_lac_L(e)_[bc]'))));
Muscle_lacF=solution_female.full(Muscle_lac);
Muscle_ldh_l = (find(~cellfun(@isempty,strfind(female.rxns,'Muscle_LDH_L'))));
Muscle_ldh_lF=solution_female.full(Muscle_ldh_l);
Liver_ldh_l = (find(~cellfun(@isempty,strfind(female.rxns,'Liver_LDH_L'))));
Liver_ldh_lF=solution_female.full(Liver_ldh_l);

if 1
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
    male = changeRxnBounds(male,'Whole_body_objective_rxn',1,'b');
    male = changeObjective(male,'Brain_DM_atp_c_');
    male.osense = -1;
    tic;[solution_male_brain,LPProblem]=solveCobraLPCPLEX(male,1,0,0,[],0,'tomlab_cplex');toc
       male_brain(1,1) = solution_male_brain.full(find(male.c));
    [RCostTableAll_male_brain,RCostTableRxnTag_male_brain] = getRCostTable(male, solution_male_brain,'Diet_EX');
    
    female = changeRxnBounds(female,'Whole_body_objective_rxn',1,'b');
    female = changeObjective(female,'Brain_DM_atp_c_');
    female.osense = -1;
    tic;[solution_female_brain,LPProblem]=solveCobraLPCPLEX(female,1,0,0,[],0,'tomlab_cplex');toc
       female_brain(1,1) = solution_female_brain.full(find(female.c));
    [RCostTableAll_female_brain,RCostTableRxnTag_female_brain] = getRCostTable(female, solution_female_brain,'Diet_EX');
    %% test diet supplementations for increased Brain_DM_atp_c_
       female = changeRxnBounds(female,'Whole_body_objective_rxn',1,'b');
      male = changeRxnBounds(male,'Whole_body_objective_rxn',1,'b');
   
    % ksi
    male_ksi = changeRxnBounds(male,'Diet_EX_ksi[d]',-100,'l'); %from 0
    male_ksi = changeObjective(male_ksi,'Brain_DM_atp_c_');
    male_ksi.osense = -1;
    tic;[solution_male_brain_ksi,LPProblem]=solveCobraLPCPLEX(male_ksi,1,0,0,[],0,'tomlab_cplex');toc
    male_brain(1,2) = solution_male_brain_ksi.full(find(male_ksi.c));
    [RCostTableAll_male_brain_ksi,RCostTableRxnTag_male_brain_ksi] = getRCostTable(male_ksi, solution_male_brain_ksi,'Diet_EX');
    
    female_ksi = changeRxnBounds(female,'Diet_EX_ksi[d]',-100,'l');
    female_ksi = changeObjective(female_ksi,'Brain_DM_atp_c_');
    female_ksi.osense = -1;
    tic;[solution_female_brain_ksi,LPProblem]=solveCobraLPCPLEX(female_ksi,1,0,0,[],0,'tomlab_cplex');toc
    female_brain(1,2) = solution_female_brain_ksi.full(find(female_ksi.c));
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
       male_brain(1,3) = solution_male_brain_Lcystin.full(find(male_Lcystin.c));
    [RCostTableAll_male_brain_Lcystin,RCostTableRxnTag_male_brain_Lcystin] = getRCostTable(male_Lcystin, solution_male_brain_Lcystin,'Diet_EX');
    
    female_Lcystin = changeRxnBounds(female,'Diet_EX_Lcystin[d]',-100,'l');
    female_Lcystin = changeObjective(female_Lcystin,'Brain_DM_atp_c_');
    female_Lcystin.osense = -1;
    tic;[solution_female_brain_Lcystin,LPProblem]=solveCobraLPCPLEX(female_Lcystin,1,0,0,[],0,'tomlab_cplex');toc
       female_brain(1,3) = solution_female_brain_Lcystin.full(find(female_Lcystin.c));
    [RCostTableAll_female_brain_Lcystin,RCostTableRxnTag_female_brain_Lcystin] = getRCostTable(female_Lcystin, solution_female_brain_Lcystin,'Diet_EX');
    % 7thf
    male_7thf = changeRxnBounds(male,'Diet_EX_7thf[d]',-100,'l');%from -50
    male_7thf = changeObjective(male_7thf,'Brain_DM_atp_c_');
    male_7thf.osense = -1;
    tic;[solution_male_brain_7thf,LPProblem]=solveCobraLPCPLEX(male_7thf,1,0,0,[],0,'tomlab_cplex');toc
       male_brain(1,4) = solution_male_brain_7thf.full(find(male_7thf.c));
    [RCostTableAll_male_brain_7thf,RCostTableRxnTag_male_brain_7thf] = getRCostTable(male_7thf, solution_male_brain_7thf,'Diet_EX');
    
    female_7thf = changeRxnBounds(female,'Diet_EX_7thf[d]',-100,'l');
    female_7thf = changeObjective(female_7thf,'Brain_DM_atp_c_');
    female_7thf.osense = -1;
    tic;[solution_female_brain_7thf,LPProblem]=solveCobraLPCPLEX(female_7thf,1,0,0,[],0,'tomlab_cplex');toc
       female_brain(1,4) = solution_female_brain_7thf.full(find(female_7thf.c));
    [RCostTableAll_female_brain_7thf,RCostTableRxnTag_female_brain_7thf] = getRCostTable(female_7thf, solution_female_brain_7thf,'Diet_EX');
   
     male_gthrd = changeRxnBounds(male,'Diet_EX_gthrd[d]',-100,'l');%from -50
    male_gthrd = changeObjective(male_gthrd,'Brain_DM_atp_c_');
    male_gthrd.osense = -1;
    tic;[solution_male_brain_gthrd,LPProblem]=solveCobraLPCPLEX(male_gthrd,1,0,0,[],0,'tomlab_cplex');toc
       male_brain(1,5) = solution_male_brain_gthrd.full(find(male_gthrd.c));
    [RCostTableAll_male_brain_gthrd,RCostTableRxnTag_male_brain_gthrd] = getRCostTable(male_gthrd, solution_male_brain_gthrd,'Diet_EX');
    
    female_gthrd = changeRxnBounds(female,'Diet_EX_gthrd[d]',-100,'l');
    female_gthrd = changeObjective(female_gthrd,'Brain_DM_atp_c_');
    female_gthrd.osense = -1;
    tic;[solution_female_brain_gthrd,LPProblem]=solveCobraLPCPLEX(female_gthrd,1,0,0,[],0,'tomlab_cplex');toc
       female_brain(1,5) = solution_female_brain_gthrd.full(find(female_gthrd.c));
    [RCostTableAll_female_brain_gthrd,RCostTableRxnTag_female_brain_gthrd] = getRCostTable(female_gthrd, solution_female_brain_gthrd,'Diet_EX');
       
    male_met_L = changeRxnBounds(male,'Diet_EX_met_L[d]',-100,'l');%from -50
    male_met_L = changeObjective(male_met_L,'Brain_DM_atp_c_');
    male_met_L.osense = -1;
    tic;[solution_male_brain_met_L,LPProblem]=solveCobraLPCPLEX(male_met_L,1,0,0,[],0,'tomlab_cplex');toc
       male_brain(1,6) = solution_male_brain_met_L.full(find(male_met_L.c));
    [RCostTableAll_male_brain_met_L,RCostTableRxnTag_male_brain_met_L] = getRCostTable(male_met_L, solution_male_brain_met_L,'Diet_EX');
    
    female_met_L = changeRxnBounds(female,'Diet_EX_met_L[d]',-100,'l');
    female_met_L = changeObjective(female_met_L,'Brain_DM_atp_c_');
    female_met_L.osense = -1;
    tic;[solution_female_brain_met_L,LPProblem]=solveCobraLPCPLEX(female_met_L,1,0,0,[],0,'tomlab_cplex');toc
       female_brain(1,6) = solution_female_brain_met_L.full(find(female_met_L.c));
    [RCostTableAll_female_brain_met_L,RCostTableRxnTag_female_brain_met_L] = getRCostTable(female_met_L, solution_female_brain_met_L,'Diet_EX');
   
       male_cys_L = changeRxnBounds(male,'Diet_EX_cys_L[d]',-100,'l');%from -50
    male_cys_L = changeObjective(male_cys_L,'Brain_DM_atp_c_');
    male_cys_L.osense = -1;
    tic;[solution_male_brain_cys_L,LPProblem]=solveCobraLPCPLEX(male_cys_L,1,0,0,[],0,'tomlab_cplex');toc
       male_brain(1,7) = solution_male_brain_cys_L.full(find(male_cys_L.c));
    [RCostTableAll_male_brain_cys_L,RCostTableRxnTag_male_brain_cys_L] = getRCostTable(male_cys_L, solution_male_brain_cys_L,'Diet_EX');
    
    female_cys_L = changeRxnBounds(female,'Diet_EX_cys_L[d]',-100,'l');
    female_cys_L = changeObjective(female_cys_L,'Brain_DM_atp_c_');
    female_cys_L.osense = -1;
    tic;[solution_female_brain_cys_L,LPProblem]=solveCobraLPCPLEX(female_cys_L,1,0,0,[],0,'tomlab_cplex');toc
       female_brain(1,7) = solution_female_brain_cys_L.full(find(female_cys_L.c));
    [RCostTableAll_female_brain_cys_L,RCostTableRxnTag_female_brain_cys_L] = getRCostTable(female_cys_L, solution_female_brain_cys_L,'Diet_EX');
   
        male_combined = changeRxnBounds(male,'Whole_body_objective_rxn',1,'b');
     male_combined = changeRxnBounds(male_combined,'Diet_EX_Lcystin[d]',-100,'l');
    male_combined = changeRxnBounds(male_combined,'Diet_EX_ksi[d]',-100,'l');
     male_combined = changeRxnBounds(male_combined,'Diet_EX_7thf[d]',-100,'l');   
    male_gthrd = changeRxnBounds(male,'Diet_EX_gthrd[d]',-100,'l');
    male_met_L = changeRxnBounds(male,'Diet_EX_met_L[d]',-100,'l');%from -50
     male_combined = changeObjective(male_combined,'Brain_DM_atp_c_');
    male_combined.osense = -1;
    tic;[solution_male_brain_combined,LPProblem]=solveCobraLPCPLEX(male_combined,1,0,0,[],0,'tomlab_cplex');toc
       male_brain(1,8) = solution_male_brain_combined.full(find(male_combined.c));
      [RCostTableAll_male_brain_combined,RCostTableRxnTag_male_brain_combined] = getRCostTable(male_combined, solution_male_brain_combined,'Diet_EX');
  
        female_combined = changeRxnBounds(female,'Whole_body_objective_rxn',1,'b');
     female_combined = changeRxnBounds(female_combined,'Diet_EX_Lcystin[d]',-100,'l');
    female_combined = changeRxnBounds(female_combined,'Diet_EX_ksi[d]',-100,'l');
     female_combined = changeRxnBounds(female_combined,'Diet_EX_7thf[d]',-100,'l');   
    female_gthrd = changeRxnBounds(female,'Diet_EX_gthrd[d]',-100,'l');
    female_met_L = changeRxnBounds(female,'Diet_EX_met_L[d]',-100,'l');
     female_combined = changeObjective(female_combined,'Brain_DM_atp_c_');
    female_combined.osense = -1;
    tic;[solution_female_brain_combined,LPProblem]=solveCobraLPCPLEX(female_combined,1,0,0,[],0,'tomlab_cplex');toc
       female_brain(1,8) = solution_female_brain_combined.full(find(female_combined.c));
    [RCostTableAll_female_brain_combined,RCostTableRxnTag_female_brain_combined] = getRCostTable(female_combined, solution_female_brain_combined,'Diet_EX');
  
    figure 
    subplot(1,2,1)
    bar((female_brain./female_brain(1,1)))
    subplot(1,2,2)
    bar(male_brain./female_brain(1,1))
    
   
    
end
if 1
    %% Muscle DM atp
    male = changeRxnBounds(male,'Whole_body_objective_rxn',1,'b');
    female = changeRxnBounds(female,'Whole_body_objective_rxn',1,'b');
    
    EUAverageDietNew;
    male = setDietConstraints(male,Diet);
    female = setDietConstraints(female,Diet);
    
    EUAverageDietNew;
    [ResultsATP_Fat_male] = computeMuscleATP_FatStorage3(male,2); % computes only min max
    [ResultsATP_Fat_female] = computeMuscleATP_FatStorage3(female,2); % computes only min max
    [Energy_kJ_male,Energy_kcal_male,Meter_K_male,StepNumber_male] = convertATPflux2StepNumer(ResultsATP_Fat_male(1,1), 'male', 70, 170);
    [Energy_kJ_female,Energy_kcal_female,Meter_K_female,StepNumber_female] = convertATPflux2StepNumer(ResultsATP_Fat_female(1,1), 'female', 58, 160);
    
    % change diet to unhealthy
    
    UnhealthyDiet;
    male_Unh = setDietConstraints(male,Diet);
    male_Unh = changeObjective(male_Unh,'Whole_body_objective_rxn');
    male_Unh.osense = -1;
    tic;[solution_female,LPProblem]=solveCobraLPCPLEX(male_Unh,1,0,0,[],0,'tomlab_cplex');toc
    
    UnhealthyDiet;
    female_Unh = setDietConstraints(female,Diet);
    female_Unh = changeObjective(female_Unh,'Whole_body_objective_rxn');
    male_Unh.osense = -1;
    tic;[solution_female,LPProblem]=solveCobraLPCPLEX(female_Unh,1,0,0,[],0,'tomlab_cplex');toc
    [ResultsATP_Fat_male_Unh] = computeMuscleATP_FatStorage3(male_Unh,2); % computes only min max
    [ResultsATP_Fat_female_Unh] = computeMuscleATP_FatStorage3(female_Unh,2); % computes only min max
    [Energy_kJ_male_Unh,Energy_kcal_male_Unh,Meter_K_male_Unh,StepNumber_male_Unh] = convertATPflux2StepNumer(ResultsATP_Fat_male_Unh(1,1), 'male', 70, 170);
    [Energy_kJ_female_Unh,Energy_kcal_female_Unh,Meter_K_female_Unh,StepNumber_female_Unh] = convertATPflux2StepNumer(ResultsATP_Fat_female_Unh(1,1), 'female', 58, 160);
    
    % change diet to DACH
    DACH;
    male_Dach = setDietConstraints(male,Diet);
    male_Dach = changeObjective(male_Dach,'Whole_body_objective_rxn');
    male_Dach.osense = -1;
    tic;[solution_female,LPProblem]=solveCobraLPCPLEX(male_Dach,1,0,0,[],0,'tomlab_cplex');toc
    
    DACH;
    female_Dach = setDietConstraints(female,Diet);
    female_Dach = changeObjective(female_Dach,'Whole_body_objective_rxn');
    female_Dach.osense = -1;
    tic;[solution_female,LPProblem]=solveCobraLPCPLEX(female_Dach,1,0,0,[],0,'tomlab_cplex');toc
    [ResultsATP_Fat_male_Dach] = computeMuscleATP_FatStorage3(male_Dach,2); % computes only min max
    [ResultsATP_Fat_female_Dach] = computeMuscleATP_FatStorage3(female_Dach,2); % computes only min max
    [Energy_kJ_male_Dach,Energy_kcal_male_Dach,Meter_K_male_Dach,StepNumber_male_Dach] = convertATPflux2StepNumer(ResultsATP_Fat_male_Dach(1,1), 'male', 70, 170);
    [Energy_kJ_female_Dach,Energy_kcal_female_Dach,Meter_K_female_Dach,StepNumber_female_Dach] = convertATPflux2StepNumer(ResultsATP_Fat_female_Dach(1,1), 'female', 58, 160);
    
    % change diet to Mediterranian
    Mediterranian;
    male_Medi = setDietConstraints(male,Diet);
    male_Medi = changeObjective(male_Medi,'Whole_body_objective_rxn');
    male_Medi.osense = -1;
    tic;[solution_female,LPProblem]=solveCobraLPCPLEX(male_Medi,1,0,0,[],0,'tomlab_cplex');toc
    
    Mediterranian;
    female_Medi = setDietConstraints(female,Diet);
    female_Medi = changeObjective(female_Medi,'Whole_body_objective_rxn');
    female_Medi.osense = -1;
    tic;[solution_female,LPProblem]=solveCobraLPCPLEX(female_Medi,1,0,0,[],0,'tomlab_cplex');toc
    [ResultsATP_Fat_male_Medi] = computeMuscleATP_FatStorage3(male_Medi,2); % computes only min max
    [ResultsATP_Fat_female_Medi] = computeMuscleATP_FatStorage3(female_Medi,2); % computes only min max
    [Energy_kJ_male_Medi,Energy_kcal_male_Medi,Meter_K_male_Medi,StepNumber_male_Medi] = convertATPflux2StepNumer(ResultsATP_Fat_male_Medi(1,1), 'male', 70, 170);
    [Energy_kJ_female_Medi,Energy_kcal_female_Medi,Meter_K_female_Medi,StepNumber_female_Medi] = convertATPflux2StepNumer(ResultsATP_Fat_female_Medi(1,1), 'female', 58, 160);
    
    % change diet to VegetarianDiet
    % VegetarianDiet;
    % male_Veggie = setDietConstraints(male,Diet);
    % male_Veggie = changeObjective(male_Veggie,'Whole_body_objective_rxn');
    % male_Veggie.osense = -1;
    % tic;[solution_female,LPProblem]=solveCobraLPCPLEX(male_Veggie,1,0,0,[],0,'tomlab_cplex');toc
    %
    % female_Veggie = setDietConstraints(female,Diet);
    % female_Veggie = changeObjective(female_Veggie,'Whole_body_objective_rxn');
    % male_Veggie.osense = -1;
    % tic;[solution_female,LPProblem]=solveCobraLPCPLEX(female_Veggie,1,0,0,[],0,'tomlab_cplex');toc
    % [ResultsATP_Fat_male_Veggie] = computeMuscleATP_FatStorage3(male_Veggie,2); % computes only min max
    % [ResultsATP_Fat_female_Veggie] = computeMuscleATP_FatStorage3(female_Veggie,2); % computes only min max
    % [Energy_kJ_male_Veggie,Energy_kcal_male_Veggie,Meter_K_male_Veggie,StepNumber_male_Veggie] = convertATPflux2StepNumer(ResultsATP_Fat_male_Veggie(1,1), 'male', 70, 170);
    % [Energy_kJ_female_Veggie,Energy_kcal_female_Veggie,Meter_K_female_Veggie,StepNumber_female_Veggie] = convertATPflux2StepNumer(ResultsATP_Fat_female_Veggie(1,1), 'female', 58, 160);
    
    % change diet to HFLC
    HighFatLowCarbDiet;
    male_HFLC = setDietConstraints(male,Diet);
    male_HFLC = changeObjective(male_HFLC,'Whole_body_objective_rxn');
    male_HFLC.osense = -1;
    tic;[solution_female,LPProblem]=solveCobraLPCPLEX(male_HFLC,1,0,0,[],0,'tomlab_cplex');toc
    
    HighFatLowCarbDiet;
    female_HFLC = setDietConstraints(female,Diet);
    female_HFLC = changeObjective(female_HFLC,'Whole_body_objective_rxn');
    female_HFLC.osense = -1;
    tic;[solution_female,LPProblem]=solveCobraLPCPLEX(female_HFLC,1,0,0,[],0,'tomlab_cplex');toc
    [ResultsATP_Fat_male_HFLC] = computeMuscleATP_FatStorage3(male_HFLC,2); % computes only min max
    [ResultsATP_Fat_female_HFLC] = computeMuscleATP_FatStorage3(female_HFLC,2); % computes only min max
    [Energy_kJ_male_HFLC,Energy_kcal_male_HFLC,Meter_K_male_HFLC,StepNumber_male_HFLC] = convertATPflux2StepNumer(ResultsATP_Fat_male_HFLC(1,1), 'male', 70, 170);
    [Energy_kJ_female_HFLC,Energy_kcal_female_HFLC,Meter_K_female_HFLC,StepNumber_female_HFLC] = convertATPflux2StepNumer(ResultsATP_Fat_female_HFLC(1,1), 'female', 58, 160);
    
    % change diet to HFiber
    HighFiberDiet;
    male_HFiber = setDietConstraints(male,Diet);
    male_HFiber = changeObjective(male_HFiber,'Whole_body_objective_rxn');
    male_HFiber.osense = -1;
    tic;[solution_female,LPProblem]=solveCobraLPCPLEX(male_HFiber,1,0,0,[],0,'tomlab_cplex');toc
    
    HighFiberDiet;
    female_HFiber = setDietConstraints(female,Diet);
    female_HFiber = changeObjective(female_HFiber,'Whole_body_objective_rxn');
    female_HFiber.osense = -1;
    tic;[solution_female,LPProblem]=solveCobraLPCPLEX(female_HFiber,1,0,0,[],0,'tomlab_cplex');toc
    [ResultsATP_Fat_male_HFiber] = computeMuscleATP_FatStorage3(male_HFiber,2); % computes only min max
    [ResultsATP_Fat_female_HFiber] = computeMuscleATP_FatStorage3(female_HFiber,2); % computes only min max
    [Energy_kJ_male_HFiber,Energy_kcal_male_HFiber,Meter_K_male_HFiber,StepNumber_male_HFiber] = convertATPflux2StepNumer(ResultsATP_Fat_male_HFiber(1,1), 'male', 70, 170);
    [Energy_kJ_female_HFiber,Energy_kcal_female_HFiber,Meter_K_female_HFiber,StepNumber_female_HFiber] = convertATPflux2StepNumer(ResultsATP_Fat_female_HFiber(1,1), 'female', 58, 160);
    % change diet to HProt
    HighProteinDiet;
    male_HProt = setDietConstraints(male,Diet);
    male_HProt = changeObjective(male_HProt,'Whole_body_objective_rxn');
    male_HProt.osense = -1;
    tic;[solution_female,LPProblem]=solveCobraLPCPLEX(male_HProt,1,0,0,[],0,'tomlab_cplex');toc
    
    HighProteinDiet;
    female_HProt = setDietConstraints(female,Diet);
    female_HProt = changeObjective(female_HProt,'Whole_body_objective_rxn');
    female_HProt.osense = -1;
    tic;[solution_female,LPProblem]=solveCobraLPCPLEX(female_HProt,1,0,0,[],0,'tomlab_cplex');toc
    [ResultsATP_Fat_male_HProt] = computeMuscleATP_FatStorage3(male_HProt,2); % computes only min max
    [ResultsATP_Fat_female_HProt] = computeMuscleATP_FatStorage3(female_HProt,2); % computes only min max
    [Energy_kJ_male_HProt,Energy_kcal_male_HProt,Meter_K_male_HProt,StepNumber_male_HProt] = convertATPflux2StepNumer(ResultsATP_Fat_male_HProt(1,1), 'male', 70, 170);
    [Energy_kJ_female_HProt,Energy_kcal_female_HProt,Meter_K_female_HProt,StepNumber_female_HProt] = convertATPflux2StepNumer(ResultsATP_Fat_female_HProt(1,1), 'female', 58, 160);
    
    
    
    Table(1,:)=[ResultsATP_Fat_female(1,1) ResultsATP_Fat_female(2,2) ResultsATP_Fat_male(1,1) ResultsATP_Fat_male(2,2)];
    Table(2,:)=[ResultsATP_Fat_female_Dach(1,1) ResultsATP_Fat_female_Dach(2,2) ResultsATP_Fat_male_Dach(1,1) ResultsATP_Fat_male_Dach(2,2)];
    Table(3,:)=[ResultsATP_Fat_female_HFLC(1,1) ResultsATP_Fat_female_HFLC(2,2) ResultsATP_Fat_male_HFLC(1,1) ResultsATP_Fat_male_HFLC(2,2)];
    Table(4,:)=[ResultsATP_Fat_female_HFiber(1,1) ResultsATP_Fat_female_HFiber(2,2) ResultsATP_Fat_male_HFiber(1,1) ResultsATP_Fat_male_HFiber(2,2)];
    Table(5,:)=[ResultsATP_Fat_female_HProt(1,1) ResultsATP_Fat_female_HProt(2,2) ResultsATP_Fat_male_HProt(1,1) ResultsATP_Fat_male_HProt(2,2)];
    Table(6,:)=[ResultsATP_Fat_female_Medi(1,1) ResultsATP_Fat_female_Medi(2,2) ResultsATP_Fat_male_Medi(1,1) ResultsATP_Fat_male_Medi(2,2)];
    Table(7,:)=[ResultsATP_Fat_female_Unh(1,1) ResultsATP_Fat_female_Unh(2,2) ResultsATP_Fat_male_Unh(1,1) ResultsATP_Fat_male_Unh(2,2)];
end
save ResultsPaperSimulations3

load 2017_05_18_HarveyJoint_11_22_constraintHMDB_EUDiet_d
male = modelOrganAllCoupled;
load 2017_05_18_HarvettaJoint_11_22_constraintHMDB_EUDiet_d
female = modelOrganAllCoupled;

standardPhysiolDefaultParameters;
% apply HMDB metabolomic data based on personalized individual parameters
female = physiologicalConstraintsHMDBbased(female,IndividualParameters);

% set some more constraints
female = setSimulationConstraints(female);

female.lb(strmatch('BBB_KYNATE[CSF]upt',female.rxns)) = -1000000; %constrained uptake
female.lb(strmatch('BBB_LKYNR[CSF]upt',female.rxns)) = -1000000; %constrained uptake
female.lb(strmatch('BBB_TRP_L[CSF]upt',female.rxns)) = -1000000; %constrained uptake

female.ub(strmatch('Brain_EX_glc_D(',female.rxns)) = -100; % currently -400 rendering many of the models to be infeasible in germfree state
%
male = physiologicalConstraintsHMDBbased(male,IndividualParameters);

% set some more constraints
male = setSimulationConstraints(male);

male.lb(strmatch('BBB_KYNATE[CSF]upt',male.rxns)) = -1000000; %constrained uptake
male.lb(strmatch('BBB_LKYNR[CSF]upt',male.rxns)) = -1000000; %constrained uptake
male.lb(strmatch('BBB_TRP_L[CSF]upt',male.rxns)) = -1000000; %constrained uptake

male.ub(strmatch('Brain_EX_glc_D(',male.rxns)) = -100; % currently -400 rendering many of the models to be infeasible in germfree state


male = changeRxnBounds(male,'Whole_body_objective_rxn',1,'b');
female = changeRxnBounds(female,'Whole_body_objective_rxn',1,'b');

o=1;
EUAverageDietNew;
male = setDietConstraints(male,Diet);
female = setDietConstraints(female,Diet);

male_EU = changeObjective(male,'Brain_DM_atp_c_');
male_EU.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_EU,1,0,0,[],0,'tomlab_cplex');toc
Table_Brain_DM_atp_c_(o,1) = solution.full(find(male_EU.c));

female_EU = setDietConstraints(female,Diet);
female_EU = changeObjective(female_EU,'Brain_DM_atp_c_');
female_EU.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_EU,1,0,0,[],0,'tomlab_cplex');toc
Table_Brain_DM_atp_c_(o,2) = solution.full(find(female_EU.c));
o=o+1;
% change diet to unhealthy

UnhealthyDiet;
male_Unh = setDietConstraints(male,Diet);
male_Unh = changeObjective(male_Unh,'Brain_DM_atp_c_');
male_Unh.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_Unh,1,0,0,[],0,'tomlab_cplex');toc
Table_Brain_DM_atp_c_(o,1) = solution.full(find(male_Unh.c));

UnhealthyDiet;
female_Unh = setDietConstraints(female,Diet);
female_Unh = changeObjective(female_Unh,'Brain_DM_atp_c_');
female_Unh.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_Unh,1,0,0,[],0,'tomlab_cplex');toc
Table_Brain_DM_atp_c_(o,2) = solution.full(find(female_Unh.c));
o=o+1;

% change diet to DACH
DACH;
male_Dach = setDietConstraints(male,Diet);
male_Dach = changeObjective(male_Dach,'Brain_DM_atp_c_');
male_Dach.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_Dach,1,0,0,[],0,'tomlab_cplex');toc
Table_Brain_DM_atp_c_(o,1) = solution.full(find(male_Dach.c));

DACH;
female_Dach = setDietConstraints(female,Diet);
female_Dach = changeObjective(female_Dach,'Brain_DM_atp_c_');
female_Dach.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_Dach,1,0,0,[],0,'tomlab_cplex');toc
Table_Brain_DM_atp_c_(o,2) = solution.full(find(female_Dach.c));o = o+1;

% change diet to Mediterranian
Mediterranian;
male_Medi = setDietConstraints(male,Diet);
male_Medi = changeObjective(male_Medi,'Brain_DM_atp_c_');
male_Medi.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_Medi,1,0,0,[],0,'tomlab_cplex');toc
Table_Brain_DM_atp_c_(o,1) = solution.full(find(male_Medi.c));

Mediterranian;
female_Medi = setDietConstraints(female,Diet);
female_Medi = changeObjective(female_Medi,'Brain_DM_atp_c_');
female_Medi.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_Medi,1,0,0,[],0,'tomlab_cplex');toc
Table_Brain_DM_atp_c_(o,2) = solution.full(find(female_Medi.c));
o=o+1;

% change diet to VegetarianDiet
% VegetarianDiet;
% male_Veggie = setDietConstraints(male,Diet);
% male_Veggie = changeObjective(male_Veggie,'Brain_DM_atp_c_');
% male_Veggie.osense = -1;
% tic;[solution,LPProblem]=solveCobraLPCPLEX(male_Veggie,1,0,0,[],0,'tomlab_cplex');toc
%
% female_Veggie = setDietConstraints(female,Diet);
% female_Veggie = changeObjective(female_Veggie,'Brain_DM_atp_c_');
% male_Veggie.osense = -1;
% tic;[solution,LPProblem]=solveCobraLPCPLEX(female_Veggie,1,0,0,[],0,'tomlab_cplex');toc
% [ResultsATP_Fat_male_Veggie] = computeMuscleATP_FatStorage3(male_Veggie,2); % computes only min max
% [ResultsATP_Fat_female_Veggie] = computeMuscleATP_FatStorage3(female_Veggie,2); % computes only min max
% [Energy_kJ_male_Veggie,Energy_kcal_male_Veggie,Meter_K_male_Veggie,StepNumber_male_Veggie] = convertATPflux2StepNumer(ResultsATP_Fat_male_Veggie(1,1), 'male', 70, 170);
% [Energy_kJ_female_Veggie,Energy_kcal_female_Veggie,Meter_K_female_Veggie,StepNumber_female_Veggie] = convertATPflux2StepNumer(ResultsATP_Fat_female_Veggie(1,1), 'female', 58, 160);

% change diet to HFLC
HighFatLowCarbDiet;
male_HFLC = setDietConstraints(male,Diet);
male_HFLC = changeObjective(male_HFLC,'Brain_DM_atp_c_');
male_HFLC.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_HFLC,1,0,0,[],0,'tomlab_cplex');toc
Table_Brain_DM_atp_c_(o,1) = solution.full(find(male_HFLC.c));

HighFatLowCarbDiet;
female_HFLC = setDietConstraints(female,Diet);
female_HFLC = changeObjective(female_HFLC,'Brain_DM_atp_c_');
female_HFLC.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_HFLC,1,0,0,[],0,'tomlab_cplex');toc
Table_Brain_DM_atp_c_(o,2) = solution.full(find(female_HFLC.c));
o=o+1;

% change diet to HFiber
HighFiberDiet;
male_HFiber = setDietConstraints(male,Diet);
male_HFiber = changeObjective(male_HFiber,'Brain_DM_atp_c_');
male_HFiber.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_HFiber,1,0,0,[],0,'tomlab_cplex');toc
Table_Brain_DM_atp_c_(o,1) = solution.full(find(male_HFiber.c));

HighFiberDiet;
female_HFiber = setDietConstraints(female,Diet);
female_HFiber = changeObjective(female_HFiber,'Brain_DM_atp_c_');
female_HFiber.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_HFiber,1,0,0,[],0,'tomlab_cplex');toc
Table_Brain_DM_atp_c_(o,2) = solution.full(find(female_HFiber.c));
o=o+1;
% change diet to HProt
HighProteinDiet;
male_HProt = setDietConstraints(male,Diet);
male_HProt = changeObjective(male_HProt,'Brain_DM_atp_c_');
male_HProt.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_HProt,1,0,0,[],0,'tomlab_cplex');toc
Table_Brain_DM_atp_c_(o,1) = solution.full(find(male_HProt.c));

HighProteinDiet;
female_HProt = setDietConstraints(female,Diet);
female_HProt = changeObjective(female_HProt,'Brain_DM_atp_c_');
female_HProt.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_HProt,1,0,0,[],0,'tomlab_cplex');toc
Table_Brain_DM_atp_c_(o,2) = solution.full(find(female_HProt.c));
o=o+1;

%% Muscle
load 2017_05_18_HarveyJoint_11_22_constraintHMDB_EUDiet_d
male = modelOrganAllCoupled;
load 2017_05_18_HarvettaJoint_11_22_constraintHMDB_EUDiet_d
female = modelOrganAllCoupled;

standardPhysiolDefaultParameters;
% apply HMDB metabolomic data based on personalized individual parameters
female = physiologicalConstraintsHMDBbased(female,IndividualParameters);

% set some more constraints
female = setSimulationConstraints(female);

female.lb(strmatch('BBB_KYNATE[CSF]upt',female.rxns)) = -1000000; %constrained uptake
female.lb(strmatch('BBB_LKYNR[CSF]upt',female.rxns)) = -1000000; %constrained uptake
female.lb(strmatch('BBB_TRP_L[CSF]upt',female.rxns)) = -1000000; %constrained uptake

female.ub(strmatch('Muscle_EX_glc_D(',female.rxns)) = -100; % currently -400 rendering many of the models to be infeasible in germfree state
%
male = physiologicalConstraintsHMDBbased(male,IndividualParameters);

% set some more constraints
male = setSimulationConstraints(male);

male.lb(strmatch('BBB_KYNATE[CSF]upt',male.rxns)) = -1000000; %constrained uptake
male.lb(strmatch('BBB_LKYNR[CSF]upt',male.rxns)) = -1000000; %constrained uptake
male.lb(strmatch('BBB_TRP_L[CSF]upt',male.rxns)) = -1000000; %constrained uptake

male.ub(strmatch('Muscle_EX_glc_D(',male.rxns)) = -100; % currently -400 rendering many of the models to be infeasible in germfree state


male = changeRxnBounds(male,'Whole_body_objective_rxn',1,'b');
female = changeRxnBounds(female,'Whole_body_objective_rxn',1,'b');

o=1;
EUAverageDietNew;
male = setDietConstraints(male,Diet);
female = setDietConstraints(female,Diet);

male_EU = changeObjective(male,'Muscle_DM_atp_c_');
male_EU.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_EU,1,0,0,[],0,'tomlab_cplex');toc
Table_Muscle_DM_atp_c_(o,1) = solution.full(find(male_EU.c));

female_EU = setDietConstraints(female,Diet);
female_EU = changeObjective(female_EU,'Muscle_DM_atp_c_');
female_EU.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_EU,1,0,0,[],0,'tomlab_cplex');toc
Table_Muscle_DM_atp_c_(o,2) = solution.full(find(female_EU.c));
o=o+1;
% change diet to unhealthy

UnhealthyDiet;
male_Unh = setDietConstraints(male,Diet);
male_Unh = changeObjective(male_Unh,'Muscle_DM_atp_c_');
male_Unh.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_Unh,1,0,0,[],0,'tomlab_cplex');toc
Table_Muscle_DM_atp_c_(o,1) = solution.full(find(male_Unh.c));

UnhealthyDiet;
female_Unh = setDietConstraints(female,Diet);
female_Unh = changeObjective(female_Unh,'Muscle_DM_atp_c_');
female_Unh.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_Unh,1,0,0,[],0,'tomlab_cplex');toc
Table_Muscle_DM_atp_c_(o,2) = solution.full(find(female_Unh.c));
o=o+1;

% change diet to DACH
DACH;
male_Dach = setDietConstraints(male,Diet);
male_Dach = changeObjective(male_Dach,'Muscle_DM_atp_c_');
male_Dach.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_Dach,1,0,0,[],0,'tomlab_cplex');toc
Table_Muscle_DM_atp_c_(o,1) = solution.full(find(male_Dach.c));

DACH;
female_Dach = setDietConstraints(female,Diet);
female_Dach = changeObjective(female_Dach,'Muscle_DM_atp_c_');
female_Dach.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_Dach,1,0,0,[],0,'tomlab_cplex');toc
Table_Muscle_DM_atp_c_(o,2) = solution.full(find(female_Dach.c));o = o+1;

% change diet to Mediterranian
Mediterranian;
male_Medi = setDietConstraints(male,Diet);
male_Medi = changeObjective(male_Medi,'Muscle_DM_atp_c_');
male_Medi.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_Medi,1,0,0,[],0,'tomlab_cplex');toc
Table_Muscle_DM_atp_c_(o,1) = solution.full(find(male_Medi.c));

Mediterranian;
female_Medi = setDietConstraints(female,Diet);
female_Medi = changeObjective(female_Medi,'Muscle_DM_atp_c_');
female_Medi.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_Medi,1,0,0,[],0,'tomlab_cplex');toc
Table_Muscle_DM_atp_c_(o,2) = solution.full(find(female_Medi.c));
o=o+1;

% change diet to VegetarianDiet
% VegetarianDiet;
% male_Veggie = setDietConstraints(male,Diet);
% male_Veggie = changeObjective(male_Veggie,'Muscle_DM_atp_c_');
% male_Veggie.osense = -1;
% tic;[solution,LPProblem]=solveCobraLPCPLEX(male_Veggie,1,0,0,[],0,'tomlab_cplex');toc
%
% female_Veggie = setDietConstraints(female,Diet);
% female_Veggie = changeObjective(female_Veggie,'Muscle_DM_atp_c_');
% male_Veggie.osense = -1;
% tic;[solution,LPProblem]=solveCobraLPCPLEX(female_Veggie,1,0,0,[],0,'tomlab_cplex');toc
% [ResultsATP_Fat_male_Veggie] = computeMuscleATP_FatStorage3(male_Veggie,2); % computes only min max
% [ResultsATP_Fat_female_Veggie] = computeMuscleATP_FatStorage3(female_Veggie,2); % computes only min max
% [Energy_kJ_male_Veggie,Energy_kcal_male_Veggie,Meter_K_male_Veggie,StepNumber_male_Veggie] = convertATPflux2StepNumer(ResultsATP_Fat_male_Veggie(1,1), 'male', 70, 170);
% [Energy_kJ_female_Veggie,Energy_kcal_female_Veggie,Meter_K_female_Veggie,StepNumber_female_Veggie] = convertATPflux2StepNumer(ResultsATP_Fat_female_Veggie(1,1), 'female', 58, 160);

% change diet to HFLC
HighFatLowCarbDiet;
male_HFLC = setDietConstraints(male,Diet);
male_HFLC = changeObjective(male_HFLC,'Muscle_DM_atp_c_');
male_HFLC.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_HFLC,1,0,0,[],0,'tomlab_cplex');toc
Table_Muscle_DM_atp_c_(o,1) = solution.full(find(male_HFLC.c));

HighFatLowCarbDiet;
female_HFLC = setDietConstraints(female,Diet);
female_HFLC = changeObjective(female_HFLC,'Muscle_DM_atp_c_');
female_HFLC.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_HFLC,1,0,0,[],0,'tomlab_cplex');toc
Table_Muscle_DM_atp_c_(o,2) = solution.full(find(female_HFLC.c));
o=o+1;

% change diet to HFiber
HighFiberDiet;
male_HFiber = setDietConstraints(male,Diet);
male_HFiber = changeObjective(male_HFiber,'Muscle_DM_atp_c_');
male_HFiber.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_HFiber,1,0,0,[],0,'tomlab_cplex');toc
Table_Muscle_DM_atp_c_(o,1) = solution.full(find(male_HFiber.c));

HighFiberDiet;
female_HFiber = setDietConstraints(female,Diet);
female_HFiber = changeObjective(female_HFiber,'Muscle_DM_atp_c_');
female_HFiber.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_HFiber,1,0,0,[],0,'tomlab_cplex');toc
Table_Muscle_DM_atp_c_(o,2) = solution.full(find(female_HFiber.c));
o=o+1;
% change diet to HProt
HighProteinDiet;
male_HProt = setDietConstraints(male,Diet);
male_HProt = changeObjective(male_HProt,'Muscle_DM_atp_c_');
male_HProt.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_HProt,1,0,0,[],0,'tomlab_cplex');toc
Table_Muscle_DM_atp_c_(o,1) = solution.full(find(male_HProt.c));

HighProteinDiet;
female_HProt = setDietConstraints(female,Diet);
female_HProt = changeObjective(female_HProt,'Muscle_DM_atp_c_');
female_HProt.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_HProt,1,0,0,[],0,'tomlab_cplex');toc
Table_Muscle_DM_atp_c_(o,2) = solution.full(find(female_HProt.c));
o=o+1;

%%
load 2017_05_18_HarveyJoint_11_22_constraintHMDB_EUDiet_d
male = modelOrganAllCoupled;
load 2017_05_18_HarvettaJoint_11_22_constraintHMDB_EUDiet_d
female = modelOrganAllCoupled;

standardPhysiolDefaultParameters;
% apply HMDB metabolomic data based on personalized individual parameters
female = physiologicalConstraintsHMDBbased(female,IndividualParameters);

% set some more constraints
female = setSimulationConstraints(female);

female.lb(strmatch('BBB_KYNATE[CSF]upt',female.rxns)) = -1000000; %constrained uptake
female.lb(strmatch('BBB_LKYNR[CSF]upt',female.rxns)) = -1000000; %constrained uptake
female.lb(strmatch('BBB_TRP_L[CSF]upt',female.rxns)) = -1000000; %constrained uptake

female.ub(strmatch('Muscle_EX_glc_D(',female.rxns)) = -100; % currently -400 rendering many of the models to be infeasible in germfree state
%
male = physiologicalConstraintsHMDBbased(male,IndividualParameters);

% set some more constraints
male = setSimulationConstraints(male);

male.lb(strmatch('BBB_KYNATE[CSF]upt',male.rxns)) = -1000000; %constrained uptake
male.lb(strmatch('BBB_LKYNR[CSF]upt',male.rxns)) = -1000000; %constrained uptake
male.lb(strmatch('BBB_TRP_L[CSF]upt',male.rxns)) = -1000000; %constrained uptake

male.ub(strmatch('Muscle_EX_glc_D(',male.rxns)) = -100; % currently -400 rendering many of the models to be infeasible in germfree state


male = changeRxnBounds(male,'Whole_body_objective_rxn',1,'b');
female = changeRxnBounds(female,'Whole_body_objective_rxn',1,'b');

o=1;
EUAverageDietNew;
male = setDietConstraints(male,Diet);
female = setDietConstraints(female,Diet);

male_EU = changeObjective(male,'Adipocytes_DM_lipid_storage');
male_EU.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_EU,1,0,0,[],0,'tomlab_cplex');toc
Table_Adipocytes_DM_lipid_storage(o,1) = solution.full(find(male_EU.c));

female_EU = setDietConstraints(female,Diet);
female_EU = changeObjective(female_EU,'Adipocytes_DM_lipid_storage');
female_EU.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_EU,1,0,0,[],0,'tomlab_cplex');toc
Table_Adipocytes_DM_lipid_storage(o,2) = solution.full(find(female_EU.c));
o=o+1;
% change diet to unhealthy

UnhealthyDiet;
male_Unh = setDietConstraints(male,Diet);
male_Unh = changeObjective(male_Unh,'Adipocytes_DM_lipid_storage');
male_Unh.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_Unh,1,0,0,[],0,'tomlab_cplex');toc
Table_Adipocytes_DM_lipid_storage(o,1) = solution.full(find(male_Unh.c));

UnhealthyDiet;
female_Unh = setDietConstraints(female,Diet);
female_Unh = changeObjective(female_Unh,'Adipocytes_DM_lipid_storage');
female_Unh.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_Unh,1,0,0,[],0,'tomlab_cplex');toc
Table_Adipocytes_DM_lipid_storage(o,2) = solution.full(find(female_Unh.c));
o=o+1;

% change diet to DACH
DACH;
male_Dach = setDietConstraints(male,Diet);
male_Dach = changeObjective(male_Dach,'Adipocytes_DM_lipid_storage');
male_Dach.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_Dach,1,0,0,[],0,'tomlab_cplex');toc
Table_Adipocytes_DM_lipid_storage(o,1) = solution.full(find(male_Dach.c));

DACH;
female_Dach = setDietConstraints(female,Diet);
female_Dach = changeObjective(female_Dach,'Adipocytes_DM_lipid_storage');
female_Dach.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_Dach,1,0,0,[],0,'tomlab_cplex');toc
Table_Adipocytes_DM_lipid_storage(o,2) = solution.full(find(female_Dach.c));o = o+1;

% change diet to Mediterranian
Mediterranian;
male_Medi = setDietConstraints(male,Diet);
male_Medi = changeObjective(male_Medi,'Adipocytes_DM_lipid_storage');
male_Medi.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_Medi,1,0,0,[],0,'tomlab_cplex');toc
Table_Adipocytes_DM_lipid_storage(o,1) = solution.full(find(male_Medi.c));

Mediterranian;
female_Medi = setDietConstraints(female,Diet);
female_Medi = changeObjective(female_Medi,'Adipocytes_DM_lipid_storage');
female_Medi.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_Medi,1,0,0,[],0,'tomlab_cplex');toc
Table_Adipocytes_DM_lipid_storage(o,2) = solution.full(find(female_Medi.c));
o=o+1;

% change diet to VegetarianDiet
% VegetarianDiet;
% male_Veggie = setDietConstraints(male,Diet);
% male_Veggie = changeObjective(male_Veggie,'Adipocytes_DM_lipid_storage');
% male_Veggie.osense = -1;
% tic;[solution,LPProblem]=solveCobraLPCPLEX(male_Veggie,1,0,0,[],0,'tomlab_cplex');toc
%
% female_Veggie = setDietConstraints(female,Diet);
% female_Veggie = changeObjective(female_Veggie,'Adipocytes_DM_lipid_storage');
% male_Veggie.osense = -1;
% tic;[solution,LPProblem]=solveCobraLPCPLEX(female_Veggie,1,0,0,[],0,'tomlab_cplex');toc
% [ResultsATP_Fat_male_Veggie] = computeMuscleATP_FatStorage3(male_Veggie,2); % computes only min max
% [ResultsATP_Fat_female_Veggie] = computeMuscleATP_FatStorage3(female_Veggie,2); % computes only min max
% [Energy_kJ_male_Veggie,Energy_kcal_male_Veggie,Meter_K_male_Veggie,StepNumber_male_Veggie] = convertATPflux2StepNumer(ResultsATP_Fat_male_Veggie(1,1), 'male', 70, 170);
% [Energy_kJ_female_Veggie,Energy_kcal_female_Veggie,Meter_K_female_Veggie,StepNumber_female_Veggie] = convertATPflux2StepNumer(ResultsATP_Fat_female_Veggie(1,1), 'female', 58, 160);

% change diet to HFLC
HighFatLowCarbDiet;
male_HFLC = setDietConstraints(male,Diet);
male_HFLC = changeObjective(male_HFLC,'Adipocytes_DM_lipid_storage');
male_HFLC.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_HFLC,1,0,0,[],0,'tomlab_cplex');toc
Table_Adipocytes_DM_lipid_storage(o,1) = solution.full(find(male_HFLC.c));

HighFatLowCarbDiet;
female_HFLC = setDietConstraints(female,Diet);
female_HFLC = changeObjective(female_HFLC,'Adipocytes_DM_lipid_storage');
female_HFLC.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_HFLC,1,0,0,[],0,'tomlab_cplex');toc
Table_Adipocytes_DM_lipid_storage(o,2) = solution.full(find(female_HFLC.c));
o=o+1;

% change diet to HFiber
HighFiberDiet;
male_HFiber = setDietConstraints(male,Diet);
male_HFiber = changeObjective(male_HFiber,'Adipocytes_DM_lipid_storage');
male_HFiber.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_HFiber,1,0,0,[],0,'tomlab_cplex');toc
Table_Adipocytes_DM_lipid_storage(o,1) = solution.full(find(male_HFiber.c));

HighFiberDiet;
female_HFiber = setDietConstraints(female,Diet);
female_HFiber = changeObjective(female_HFiber,'Adipocytes_DM_lipid_storage');
female_HFiber.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_HFiber,1,0,0,[],0,'tomlab_cplex');toc
Table_Adipocytes_DM_lipid_storage(o,2) = solution.full(find(female_HFiber.c));
o=o+1;
% change diet to HProt
HighProteinDiet;
male_HProt = setDietConstraints(male,Diet);
male_HProt = changeObjective(male_HProt,'Adipocytes_DM_lipid_storage');
male_HProt.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_HProt,1,0,0,[],0,'tomlab_cplex');toc
Table_Adipocytes_DM_lipid_storage(o,1) = solution.full(find(male_HProt.c));

HighProteinDiet;
female_HProt = setDietConstraints(female,Diet);
female_HProt = changeObjective(female_HProt,'Adipocytes_DM_lipid_storage');
female_HProt.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_HProt,1,0,0,[],0,'tomlab_cplex');toc
Table_Adipocytes_DM_lipid_storage(o,2) = solution.full(find(female_HProt.c));
o=o+1;

%% Heart
load 2017_05_18_HarveyJoint_11_22_constraintHMDB_EUDiet_d
male = modelOrganAllCoupled;
load 2017_05_18_HarvettaJoint_11_22_constraintHMDB_EUDiet_d
female = modelOrganAllCoupled;

standardPhysiolDefaultParameters;
% apply HMDB metabolomic data based on personalized individual parameters
female = physiologicalConstraintsHMDBbased(female,IndividualParameters);

% set some more constraints
female = setSimulationConstraints(female);

female.lb(strmatch('BBB_KYNATE[CSF]upt',female.rxns)) = -1000000; %constrained uptake
female.lb(strmatch('BBB_LKYNR[CSF]upt',female.rxns)) = -1000000; %constrained uptake
female.lb(strmatch('BBB_TRP_L[CSF]upt',female.rxns)) = -1000000; %constrained uptake

female.ub(strmatch('Heart_EX_glc_D(',female.rxns)) = -100; % currently -400 rendering many of the models to be infeasible in germfree state
%
male = physiologicalConstraintsHMDBbased(male,IndividualParameters);

% set some more constraints
male = setSimulationConstraints(male);

male.lb(strmatch('BBB_KYNATE[CSF]upt',male.rxns)) = -1000000; %constrained uptake
male.lb(strmatch('BBB_LKYNR[CSF]upt',male.rxns)) = -1000000; %constrained uptake
male.lb(strmatch('BBB_TRP_L[CSF]upt',male.rxns)) = -1000000; %constrained uptake

male.ub(strmatch('Heart_EX_glc_D(',male.rxns)) = -100; % currently -400 rendering many of the models to be infeasible in germfree state


male = changeRxnBounds(male,'Whole_body_objective_rxn',1,'b');
female = changeRxnBounds(female,'Whole_body_objective_rxn',1,'b');

o=1;
EUAverageDietNew;
male = setDietConstraints(male,Diet);
female = setDietConstraints(female,Diet);

male_EU = changeObjective(male,'Heart_DM_atp_c_');
male_EU.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_EU,1,0,0,[],0,'tomlab_cplex');toc
Table_Heart_DM_atp_c_(o,1) = solution.full(find(male_EU.c));

female_EU = setDietConstraints(female,Diet);
female_EU = changeObjective(female_EU,'Heart_DM_atp_c_');
female_EU.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_EU,1,0,0,[],0,'tomlab_cplex');toc
Table_Heart_DM_atp_c_(o,2) = solution.full(find(female_EU.c));
o=o+1;
% change diet to unhealthy

UnhealthyDiet;
male_Unh = setDietConstraints(male,Diet);
male_Unh = changeObjective(male_Unh,'Heart_DM_atp_c_');
male_Unh.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_Unh,1,0,0,[],0,'tomlab_cplex');toc
Table_Heart_DM_atp_c_(o,1) = solution.full(find(male_Unh.c));

UnhealthyDiet;
female_Unh = setDietConstraints(female,Diet);
female_Unh = changeObjective(female_Unh,'Heart_DM_atp_c_');
female_Unh.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_Unh,1,0,0,[],0,'tomlab_cplex');toc
Table_Heart_DM_atp_c_(o,2) = solution.full(find(female_Unh.c));
o=o+1;

% change diet to DACH
DACH;
male_Dach = setDietConstraints(male,Diet);
male_Dach = changeObjective(male_Dach,'Heart_DM_atp_c_');
male_Dach.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_Dach,1,0,0,[],0,'tomlab_cplex');toc
Table_Heart_DM_atp_c_(o,1) = solution.full(find(male_Dach.c));

DACH;
female_Dach = setDietConstraints(female,Diet);
female_Dach = changeObjective(female_Dach,'Heart_DM_atp_c_');
female_Dach.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_Dach,1,0,0,[],0,'tomlab_cplex');toc
Table_Heart_DM_atp_c_(o,2) = solution.full(find(female_Dach.c));o = o+1;

% change diet to Mediterranian
Mediterranian;
male_Medi = setDietConstraints(male,Diet);
male_Medi = changeObjective(male_Medi,'Heart_DM_atp_c_');
male_Medi.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_Medi,1,0,0,[],0,'tomlab_cplex');toc
Table_Heart_DM_atp_c_(o,1) = solution.full(find(male_Medi.c));

Mediterranian;
female_Medi = setDietConstraints(female,Diet);
female_Medi = changeObjective(female_Medi,'Heart_DM_atp_c_');
female_Medi.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_Medi,1,0,0,[],0,'tomlab_cplex');toc
Table_Heart_DM_atp_c_(o,2) = solution.full(find(female_Medi.c));
o=o+1;

% change diet to VegetarianDiet
% VegetarianDiet;
% male_Veggie = setDietConstraints(male,Diet);
% male_Veggie = changeObjective(male_Veggie,'Heart_DM_atp_c_');
% male_Veggie.osense = -1;
% tic;[solution,LPProblem]=solveCobraLPCPLEX(male_Veggie,1,0,0,[],0,'tomlab_cplex');toc
%
% female_Veggie = setDietConstraints(female,Diet);
% female_Veggie = changeObjective(female_Veggie,'Heart_DM_atp_c_');
% male_Veggie.osense = -1;
% tic;[solution,LPProblem]=solveCobraLPCPLEX(female_Veggie,1,0,0,[],0,'tomlab_cplex');toc
% [ResultsATP_Fat_male_Veggie] = computeHeartATP_FatStorage3(male_Veggie,2); % computes only min max
% [ResultsATP_Fat_female_Veggie] = computeHeartATP_FatStorage3(female_Veggie,2); % computes only min max
% [Energy_kJ_male_Veggie,Energy_kcal_male_Veggie,Meter_K_male_Veggie,StepNumber_male_Veggie] = convertATPflux2StepNumer(ResultsATP_Fat_male_Veggie(1,1), 'male', 70, 170);
% [Energy_kJ_female_Veggie,Energy_kcal_female_Veggie,Meter_K_female_Veggie,StepNumber_female_Veggie] = convertATPflux2StepNumer(ResultsATP_Fat_female_Veggie(1,1), 'female', 58, 160);

% change diet to HFLC
HighFatLowCarbDiet;
male_HFLC = setDietConstraints(male,Diet);
male_HFLC = changeObjective(male_HFLC,'Heart_DM_atp_c_');
male_HFLC.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_HFLC,1,0,0,[],0,'tomlab_cplex');toc
Table_Heart_DM_atp_c_(o,1) = solution.full(find(male_HFLC.c));

HighFatLowCarbDiet;
female_HFLC = setDietConstraints(female,Diet);
female_HFLC = changeObjective(female_HFLC,'Heart_DM_atp_c_');
female_HFLC.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_HFLC,1,0,0,[],0,'tomlab_cplex');toc
Table_Heart_DM_atp_c_(o,2) = solution.full(find(female_HFLC.c));
o=o+1;

% change diet to HFiber
HighFiberDiet;
male_HFiber = setDietConstraints(male,Diet);
male_HFiber = changeObjective(male_HFiber,'Heart_DM_atp_c_');
male_HFiber.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_HFiber,1,0,0,[],0,'tomlab_cplex');toc
Table_Heart_DM_atp_c_(o,1) = solution.full(find(male_HFiber.c));

HighFiberDiet;
female_HFiber = setDietConstraints(female,Diet);
female_HFiber = changeObjective(female_HFiber,'Heart_DM_atp_c_');
female_HFiber.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_HFiber,1,0,0,[],0,'tomlab_cplex');toc
Table_Heart_DM_atp_c_(o,2) = solution.full(find(female_HFiber.c));
o=o+1;
% change diet to HProt
HighProteinDiet;
male_HProt = setDietConstraints(male,Diet);
male_HProt = changeObjective(male_HProt,'Heart_DM_atp_c_');
male_HProt.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(male_HProt,1,0,0,[],0,'tomlab_cplex');toc
Table_Heart_DM_atp_c_(o,1) = solution.full(find(male_HProt.c));

HighProteinDiet;
female_HProt = setDietConstraints(female,Diet);
female_HProt = changeObjective(female_HProt,'Heart_DM_atp_c_');
female_HProt.osense = -1;
tic;[solution,LPProblem]=solveCobraLPCPLEX(female_HProt,1,0,0,[],0,'tomlab_cplex');toc
Table_Heart_DM_atp_c_(o,2) = solution.full(find(female_HProt.c));
o=o+1;


save ResultsPaperSimulations3

