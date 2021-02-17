
%% load Harvetta and harvey

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