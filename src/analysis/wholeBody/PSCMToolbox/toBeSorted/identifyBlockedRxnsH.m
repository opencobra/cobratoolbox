% identify blocked rxns
% use modelO2 as we do not need coupling for this.
% perform LP to reduce the number of LPs needed
%model2Ori = modelO2;
modelO2 = modelWithOutPhysConstr;
modelO2 = setFeedingFastingConstraints(modelO2, 'feeding');
% set diet - either AvAm or Bal
EUAverageDietNew;
modelO2 = setDietConstraints(modelO2,Diet);

modelO2 = changeObjective(modelO2,'Whole_body_objective_rxn');
modelO2.osense = -1;
tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelO2,1,0,0,[],0,'tomlab_cplex');toc
Rxns2Check = modelO2.rxns;
Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];

modelO2 = changeRxnBounds(modelO2,'Whole_body_objective_rxn',1,'l');
modelO2.osense = 1;
tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelO2,1,0,0,[],0,'tomlab_cplex');toc
Rxns2Check2 = modelO2.rxns;
Rxns2Check2(find(abs(solutionGF_O2.full)>1e-6))=[];
Rxns2CheckF = intersect(Rxns2Check,Rxns2Check2);

%modelOrganAllCoupled = modelWithOutPhysConstr;
%genderOri = modelOrganAllCoupled.gender;
%genderOri = 'male';
%forStoichCons;

% % set fasting or feeding state
% modelOrganAllCoupled = setFeedingFastingConstraints(modelOrganAllCoupled, 'feeding');
% % set diet - either AvAm or Bal
% EUAverageDietNew;
% modelOrganAllCoupled = setDietConstraints(modelOrganAllCoupled,Diet);
%
% modelOrganAllCoupled = changeRxnBounds(modelOrganAllCoupled,'Diet_EX_vitd3[d]',-1000,'l');
% modelOrganAllCoupled = changeRxnBounds(modelOrganAllCoupled,'Diet_EX_chsterol[d]',-1000,'l');
% modelOrganAllCoupled = changeRxnBounds(modelOrganAllCoupled,'Diet_EX_xolest181_hs[d]',-1000,'l');
%
% modelOrganAllCoupled = changeObjective(modelOrganAllCoupled,'Whole_body_objective_rxn');
% modelOrganAllCoupled.osense = -1;
% tic;[solutionGF_BMR_Max,LPProblem]=solveCobraLPCPLEX(modelOrganAllCoupled,1,0,0,[],0,'tomlab_cplex');toc
%
% Rxns2Check3 = modelOrganAllCoupled.rxns;
% Rxns2Check3(find(abs(solutionGF_BMR_Max.full)>1e-6))=[];
%Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check3);

L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelO2.c=zeros(length(modelO2.rxns),1);
    modelO2.c(find(ismember(modelO2.rxns,Rxns2CheckF)))=1;
    modelO2.osense = -1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelO2,1,0,0,[],0,'tomlab_cplex');toc
    modelO2.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelO2.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end

do minimization
L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelO2.c=zeros(length(modelO2.rxns),1);
    modelO2.c(find(ismember(modelO2.rxns,Rxns2CheckF)))=1;
    modelO2.osense = 1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelO2,1,0,0,[],0,'tomlab_cplex');toc
    modelO2.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelO2.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
Diet_Rxns2CheckF=Rxns2CheckF;

if strcmp('gender','male')
    
    save 2017_05_18_HarveyJoint_06_30_constraintHMDB_EUDiet_d_Diet_Rxns2CheckF Diet_Rxns2CheckF
else
    save 2017_05_18_HarvettaJoint_06_30_constraintHMDB_EUDiet_d_Diet_Rxns2CheckF Diet_Rxns2CheckF
end
