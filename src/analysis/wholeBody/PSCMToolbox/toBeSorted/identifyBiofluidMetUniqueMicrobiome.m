% identify unique microbial metabolites for GF and 5 random HM models
clear

%% Harvetta
% identify [u] reactions that cannot carry flux
load('Y:\SemiAutomated_Organ_Models\_InesProteomeMapData\HH_final\HMP\Results_HMPNew_GF_2017_12_07_female_microbiota_model_samp_SRS011061.mat')
M1 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'Kidney_EX_'))));
M2 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'[u]'))));
Rxns2CheckF = modelOrganAllCoupled.rxns(setdiff(M2,M1));
L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelOrganAllCoupled.c=zeros(length(modelOrganAllCoupled.rxns),1);
    modelOrganAllCoupled.c(find(ismember(modelOrganAllCoupled.rxns,Rxns2CheckF)))=1;
    modelOrganAllCoupled.osense = -1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelOrganAllCoupled,1,0,0,[],0,'tomlab_cplex');toc
    % modelOrganAllCoupled.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelOrganAllCoupled.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
URxns2CheckF_GF_female = Rxns2CheckF;

% bbb
K1 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'BBB_'))));
K2 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'[CSF]upt'))));
Rxns2CheckF = modelOrganAllCoupled.rxns(intersect(K1,K2));
L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelOrganAllCoupled.c=zeros(length(modelOrganAllCoupled.rxns),1);
    modelOrganAllCoupled.c(find(ismember(modelOrganAllCoupled.rxns,Rxns2CheckF)))=1;
    modelOrganAllCoupled.osense = 1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelOrganAllCoupled,1,0,0,[],0,'tomlab_cplex');toc
    % modelOrganAllCoupled.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelOrganAllCoupled.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
BRxns2CheckF_GF_female = Rxns2CheckF;



M1 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.mets,'[bc]'))));
M2 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.mets,'slack'))));
M = setdiff(M1,M2);
modelOrganAllCoupled.S=modelOrganAllCoupled.A;
modelOrganAllCoupled = addDemandReaction(modelOrganAllCoupled,modelOrganAllCoupled.mets(M),0);

modelOrganAllCoupled.A=modelOrganAllCoupled.S;


M1 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'DM_'))));
M2 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'[bc]'))));
Rxns2CheckF = modelOrganAllCoupled.rxns(intersect(M2,M1));


L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelOrganAllCoupled.c=zeros(length(modelOrganAllCoupled.rxns),1);
    modelOrganAllCoupled.c(find(ismember(modelOrganAllCoupled.rxns,Rxns2CheckF)))=1;
    modelOrganAllCoupled.osense = -1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelOrganAllCoupled,1,0,0,[],0,'tomlab_cplex');toc
    % modelOrganAllCoupled.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelOrganAllCoupled.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
BcRxns2CheckF_GF_female = Rxns2CheckF;

%% HM
%[u]
%
M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'Kidney_EX_'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[u]'))));
Rxns2CheckF = modelHM.rxns(setdiff(M2,M1));
L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = -1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelHM.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
URxns2CheckF_my_SRS022137 = Rxns2CheckF;

% bbb
K1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'BBB_'))));
K2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[CSF]upt'))));
Rxns2CheckF = modelHM.rxns(intersect(K1,K2));
L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = 1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelHM.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
BRxns2CheckF_my_SRS022137 = Rxns2CheckF;

M1 = (find(~cellfun(@isempty,strfind(modelHM.mets,'[bc]'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.mets,'slack'))));
M = setdiff(M1,M2);

modelHM = addDemandReaction(modelHM,modelHM.mets(M),0);
modelHM.A=modelHM.S;

M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'DM_'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[bc]'))));
Rxns2CheckF = modelHM.rxns(intersect(M2,M1));

L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = -1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelOrganAllCoupled.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
BcRxns2CheckF_SRS022137_female = Rxns2CheckF;

% identify [u] reactions that cannot carry flux
load('Y:\SemiAutomated_Organ_Models\_InesProteomeMapData\HH_final\2017_10_28_female_microbiota_model_samp_SRS013521.mat')

M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'Kidney_EX_'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[u]'))));
Rxns2CheckF = modelHM.rxns(setdiff(M2,M1));
L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = -1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelHM.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
URxns2CheckF_my_SRS013521 = Rxns2CheckF;

% bbb
K1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'BBB_'))));
K2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[CSF]upt'))));
Rxns2CheckF = modelHM.rxns(intersect(K1,K2));
L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = 1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelHM.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
BRxns2CheckF_my_SRS013521 = Rxns2CheckF;


M1 = (find(~cellfun(@isempty,strfind(modelHM.mets,'[bc]'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.mets,'slack'))));
M = setdiff(M1,M2);

modelHM = addDemandReaction(modelHM,modelHM.mets(M),0);
modelHM.A=modelHM.S;

M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'DM_'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[bc]'))));
Rxns2CheckF = modelHM.rxns(intersect(M2,M1));

L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = -1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelOrganAllCoupled.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
BcRxns2CheckF_my_SRS013521 = Rxns2CheckF;

save 2017_10_28_UniqueMicrobialMets

load('Y:\SemiAutomated_Organ_Models\_InesProteomeMapData\HH_final\2017_10_28_female_microbiota_model_samp_SRS065504a.mat')

M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'Kidney_EX_'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[u]'))));
Rxns2CheckF = modelHM.rxns(setdiff(M2,M1));
L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = -1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelHM.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
URxns2CheckF_my_SRS065504 = Rxns2CheckF;

% bbb
K1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'BBB_'))));
K2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[CSF]upt'))));
Rxns2CheckF = modelHM.rxns(intersect(K1,K2));
L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = 1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelHM.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
BRxns2CheckF_my_SRS065504 = Rxns2CheckF;


M1 = (find(~cellfun(@isempty,strfind(modelHM.mets,'[bc]'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.mets,'slack'))));
M = setdiff(M1,M2);

modelHM = addDemandReaction(modelHM,modelHM.mets(M),0);
modelHM.A=modelHM.S;

M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'DM_'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[bc]'))));
Rxns2CheckF = modelHM.rxns(intersect(M2,M1));

L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = -1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelOrganAllCoupled.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
BcRxns2CheckF_my_SRS065504 = Rxns2CheckF;
save 2017_10_28_UniqueMicrobialMets

% 
% load('Y:\SemiAutomated_Organ_Models\_InesProteomeMapData\HH_final\2017_10_28_female_microbiota_model_samp_SRS064276.mat')
% 
% M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'Kidney_EX_'))));
% M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[u]'))));
% Rxns2CheckF = modelHM.rxns(setdiff(M2,M1));
% L = length(Rxns2CheckF)
% Llast=L+1;
% while L<Llast
%     Llast = L;
%     modelHM.c=zeros(length(modelHM.rxns),1);
%     modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
%     modelHM.osense = -1;
%     tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
%     % modelHM.LPBasis = LPProblem.LPBasis;
%     Rxns2Check = modelHM.rxns;
%     Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
%     Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
%     L = length(Rxns2CheckF)
% end
% URxns2CheckF_my_SRS064276 = Rxns2CheckF;
% 
% % bbb
% K1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'BBB_'))));
% K2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[CSF]upt'))));
% Rxns2CheckF = modelHM.rxns(intersect(K1,K2));
% L = length(Rxns2CheckF)
% Llast=L+1;
% while L<Llast
%     Llast = L;
%     modelHM.c=zeros(length(modelHM.rxns),1);
%     modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
%     modelHM.osense = 1;
%     tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
%     % modelHM.LPBasis = LPProblem.LPBasis;
%     Rxns2Check = modelHM.rxns;
%     Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
%     Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
%     L = length(Rxns2CheckF)
% end
% BRxns2CheckF_my_SRS064276 = Rxns2CheckF;
% 
% M1 = (find(~cellfun(@isempty,strfind(modelHM.mets,'[bc]'))));
% M2 = (find(~cellfun(@isempty,strfind(modelHM.mets,'slack'))));
% M = setdiff(M1,M2);
% 
% modelHM = addDemandReaction(modelHM,modelHM.mets(M),0);
% modelHM.A=modelHM.S;
% 
% M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'DM_'))));
% M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[bc]'))));
% Rxns2CheckF = modelHM.rxns(intersect(M2,M1));
% 
% L = length(Rxns2CheckF)
% Llast=L+1;
% while L<Llast
%     Llast = L;
%     modelHM.c=zeros(length(modelHM.rxns),1);
%     modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
%     modelHM.osense = -1;
%     tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
%     % modelOrganAllCoupled.LPBasis = LPProblem.LPBasis;
%     Rxns2Check = modelHM.rxns;
%     Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
%     Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
%     L = length(Rxns2CheckF)
% end
% BcRxns2CheckF_my_SRS064276 = Rxns2CheckF;
% 
% load('Y:\SemiAutomated_Organ_Models\_InesProteomeMapData\HH_final\2017_10_28_female_microbiota_model_samp_SRS043001.mat')
% 
% M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'Kidney_EX_'))));
% M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[u]'))));
% Rxns2CheckF = modelHM.rxns(setdiff(M2,M1));
% L = length(Rxns2CheckF)
% Llast=L+1;
% while L<Llast
%     Llast = L;
%     modelHM.c=zeros(length(modelHM.rxns),1);
%     modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
%     modelHM.osense = -1;
%     tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
%     % modelHM.LPBasis = LPProblem.LPBasis;
%     Rxns2Check = modelHM.rxns;
%     Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
%     Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
%     L = length(Rxns2CheckF)
% end
% URxns2CheckF_my_SRS043001 = Rxns2CheckF;
% 
% % bbb
% K1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'BBB_'))));
% K2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[CSF]upt'))));
% Rxns2CheckF = modelHM.rxns(intersect(K1,K2));
% L = length(Rxns2CheckF)
% Llast=L+1;
% while L<Llast
%     Llast = L;
%     modelHM.c=zeros(length(modelHM.rxns),1);
%     modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
%     modelHM.osense = 1;
%     tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
%     % modelHM.LPBasis = LPProblem.LPBasis;
%     Rxns2Check = modelHM.rxns;
%     Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
%     Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
%     L = length(Rxns2CheckF)
% end
% BRxns2CheckF_my_SRS043001 = Rxns2CheckF;
% 
% M1 = (find(~cellfun(@isempty,strfind(modelHM.mets,'[bc]'))));
% M2 = (find(~cellfun(@isempty,strfind(modelHM.mets,'slack'))));
% M = setdiff(M1,M2);
% 
% modelHM = addDemandReaction(modelHM,modelHM.mets(M),0);
% modelHM.A=modelHM.S;
% 
% M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'DM_'))));
% M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[bc]'))));
% Rxns2CheckF = modelHM.rxns(intersect(M2,M1));
% 
% L = length(Rxns2CheckF)
% Llast=L+1;
% while L<Llast
%     Llast = L;
%     modelHM.c=zeros(length(modelHM.rxns),1);
%     modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
%     modelHM.osense = -1;
%     tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
%     % modelOrganAllCoupled.LPBasis = LPProblem.LPBasis;
%     Rxns2Check = modelHM.rxns;
%     Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
%     Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
%     L = length(Rxns2CheckF)
% end
% BcRxns2CheckF_my_SRS043001 = Rxns2CheckF;
% % 
% setdiff(BRxns2CheckF_GF_female,BRxns2CheckF_my_SRS013521)
% setdiff(BRxns2CheckF_GF_female,BRxns2CheckF_my_SRS022137)
% setdiff(BRxns2CheckF_GF_female,BRxns2CheckF_my_SRS043001)
% setdiff(BRxns2CheckF_GF_female,BRxns2CheckF_my_SRS064276)
% setdiff(BRxns2CheckF_GF_female,BRxns2CheckF_my_SRS065504)
% %
% 
% setdiff(URxns2CheckF_GF_female,URxns2CheckF_my_SRS013521)
% setdiff(URxns2CheckF_GF_female,URxns2CheckF_my_SRS013521)
% setdiff(URxns2CheckF_GF_female,URxns2CheckF_my_SRS043001)
% setdiff(URxns2CheckF_GF_female,URxns2CheckF_my_SRS064276)
% setdiff(URxns2CheckF_GF_female,URxns2CheckF_my_SRS065504)


%% Harvey
% identify [u] reactions that cannot carry flux
load('Y:\SemiAutomated_Organ_Models\_InesProteomeMapData\HH_final\2017_10_28_male_microbiota_model_samp_SRS049959.mat')
M1 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'Kidney_EX_'))));
M2 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'[u]'))));
Rxns2CheckF = modelOrganAllCoupled.rxns(setdiff(M2,M1));
L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelOrganAllCoupled.c=zeros(length(modelOrganAllCoupled.rxns),1);
    modelOrganAllCoupled.c(find(ismember(modelOrganAllCoupled.rxns,Rxns2CheckF)))=1;
    modelOrganAllCoupled.osense = -1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelOrganAllCoupled,1,0,0,[],0,'tomlab_cplex');toc
    % modelOrganAllCoupled.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelOrganAllCoupled.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
URxns2CheckF_GF_male = Rxns2CheckF;

% bbb
K1 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'BBB_'))));
K2 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'[CSF]upt'))));
Rxns2CheckF = modelOrganAllCoupled.rxns(intersect(K1,K2));
L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelOrganAllCoupled.c=zeros(length(modelOrganAllCoupled.rxns),1);
    modelOrganAllCoupled.c(find(ismember(modelOrganAllCoupled.rxns,Rxns2CheckF)))=1;
    modelOrganAllCoupled.osense = 1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelOrganAllCoupled,1,0,0,[],0,'tomlab_cplex');toc
    % modelOrganAllCoupled.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelOrganAllCoupled.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
BRxns2CheckF_GF_male = Rxns2CheckF;

M1 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.mets,'[bc]'))));
M2 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.mets,'slack'))));
M = setdiff(M1,M2);
modelOrganAllCoupled.S=modelOrganAllCoupled.A;
modelOrganAllCoupled = addDemandReaction(modelOrganAllCoupled,modelOrganAllCoupled.mets(M),0);

modelOrganAllCoupled.A=modelOrganAllCoupled.S;


M1 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'DM_'))));
M2 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'[bc]'))));
Rxns2CheckF = modelOrganAllCoupled.rxns(intersect(M2,M1));


L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelOrganAllCoupled.c=zeros(length(modelOrganAllCoupled.rxns),1);
    modelOrganAllCoupled.c(find(ismember(modelOrganAllCoupled.rxns,Rxns2CheckF)))=1;
    modelOrganAllCoupled.osense = -1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelOrganAllCoupled,1,0,0,[],0,'tomlab_cplex');toc
    % modelOrganAllCoupled.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelOrganAllCoupled.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
BcRxns2CheckF_GF_male = Rxns2CheckF;

%% HM
%[u]
%
M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'Kidney_EX_'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[u]'))));
Rxns2CheckF = modelHM.rxns(setdiff(M2,M1));
L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = -1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelHM.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
URxns2CheckF_my_SRS049959 = Rxns2CheckF;

% bbb
K1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'BBB_'))));
K2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[CSF]upt'))));
Rxns2CheckF = modelHM.rxns(intersect(K1,K2));
L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = 1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelHM.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
BRxns2CheckF_my_SRS049959 = Rxns2CheckF;


M1 = (find(~cellfun(@isempty,strfind(modelHM.mets,'[bc]'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.mets,'slack'))));
M = setdiff(M1,M2);

modelHM = addDemandReaction(modelHM,modelHM.mets(M),0);
modelHM.A=modelHM.S;

M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'DM_'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[bc]'))));
Rxns2CheckF = modelHM.rxns(intersect(M2,M1));

L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = -1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelOrganAllCoupled.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
BcRxns2CheckF_my_SRS049959 = Rxns2CheckF;
save 2017_10_28_UniqueMicrobialMets


% identify [u] reactions that cannot carry flux
load('Y:\SemiAutomated_Organ_Models\_InesProteomeMapData\HH_final\2017_10_28_male_microbiota_model_samp_SRS023176.mat')

M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'Kidney_EX_'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[u]'))));
Rxns2CheckF = modelHM.rxns(setdiff(M2,M1));
L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = -1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelHM.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
URxns2CheckF_my_SRS023176 = Rxns2CheckF;

% bbb
K1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'BBB_'))));
K2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[CSF]upt'))));
Rxns2CheckF = modelHM.rxns(intersect(K1,K2));
L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = 1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelHM.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
BRxns2CheckF_my_SRS023176 = Rxns2CheckF;

M1 = (find(~cellfun(@isempty,strfind(modelHM.mets,'[bc]'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.mets,'slack'))));
M = setdiff(M1,M2);

modelHM = addDemandReaction(modelHM,modelHM.mets(M),0);
modelHM.A=modelHM.S;

M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'DM_'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[bc]'))));
Rxns2CheckF = modelHM.rxns(intersect(M2,M1));

L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = -1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelOrganAllCoupled.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
BcRxns2CheckF_my_SRS023176 = Rxns2CheckF;
save 2017_10_28_UniqueMicrobialMets

load('Y:\SemiAutomated_Organ_Models\_InesProteomeMapData\HH_final\2017_10_28_male_microbiota_model_samp_SRS020869.mat')

M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'Kidney_EX_'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[u]'))));
Rxns2CheckF = modelHM.rxns(setdiff(M2,M1));
L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = -1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelHM.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
URxns2CheckF_my_SRS020869 = Rxns2CheckF;

% bbb
K1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'BBB_'))));
K2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[CSF]upt'))));
Rxns2CheckF = modelHM.rxns(intersect(K1,K2));
L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = 1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelHM.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
BRxns2CheckF_my_SRS020869 = Rxns2CheckF;

M1 = (find(~cellfun(@isempty,strfind(modelHM.mets,'[bc]'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.mets,'slack'))));
M = setdiff(M1,M2);

modelHM = addDemandReaction(modelHM,modelHM.mets(M),0);
modelHM.A=modelHM.S;

M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'DM_'))));
M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[bc]'))));
Rxns2CheckF = modelHM.rxns(intersect(M2,M1));

L = length(Rxns2CheckF)
Llast=L+1;
while L<Llast
    Llast = L;
    modelHM.c=zeros(length(modelHM.rxns),1);
    modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
    modelHM.osense = -1;
    tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
    % modelOrganAllCoupled.LPBasis = LPProblem.LPBasis;
    Rxns2Check = modelHM.rxns;
    Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
    Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
    L = length(Rxns2CheckF)
end
save 2017_10_28_UniqueMicrobialMets

% BcRxns2CheckF_my_SRS020869 = Rxns2CheckF;
% 
% load('Y:\SemiAutomated_Organ_Models\_InesProteomeMapData\HH_final\2017_10_28_male_microbiota_model_samp_SRS024549.mat')
% 
% M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'Kidney_EX_'))));
% M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[u]'))));
% Rxns2CheckF = modelHM.rxns(setdiff(M2,M1));
% L = length(Rxns2CheckF)
% Llast=L+1;
% while L<Llast
%     Llast = L;
%     modelHM.c=zeros(length(modelHM.rxns),1);
%     modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
%     modelHM.osense = -1;
%     tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
%     % modelHM.LPBasis = LPProblem.LPBasis;
%     Rxns2Check = modelHM.rxns;
%     Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
%     Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
%     L = length(Rxns2CheckF)
% end
% URxns2CheckF_my_SRS024549 = Rxns2CheckF;
% 
% % bbb
% K1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'BBB_'))));
% K2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[CSF]upt'))));
% Rxns2CheckF = modelHM.rxns(intersect(K1,K2));
% L = length(Rxns2CheckF)
% Llast=L+1;
% while L<Llast
%     Llast = L;
%     modelHM.c=zeros(length(modelHM.rxns),1);
%     modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
%     modelHM.osense = 1;
%     tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
%     % modelHM.LPBasis = LPProblem.LPBasis;
%     Rxns2Check = modelHM.rxns;
%     Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
%     Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
%     L = length(Rxns2CheckF)
% end
% BRxns2CheckF_my_SRS024549 = Rxns2CheckF;
% 
% M1 = (find(~cellfun(@isempty,strfind(modelHM.mets,'[bc]'))));
% M2 = (find(~cellfun(@isempty,strfind(modelHM.mets,'slack'))));
% M = setdiff(M1,M2);
% 
% modelHM = addDemandReaction(modelHM,modelHM.mets(M),0);
% modelHM.A=modelHM.S;
% 
% M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'DM_'))));
% M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[bc]'))));
% Rxns2CheckF = modelHM.rxns(intersect(M2,M1));
% 
% L = length(Rxns2CheckF)
% Llast=L+1;
% while L<Llast
%     Llast = L;
%     modelHM.c=zeros(length(modelHM.rxns),1);
%     modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
%     modelHM.osense = -1;
%     tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
%     % modelOrganAllCoupled.LPBasis = LPProblem.LPBasis;
%     Rxns2Check = modelHM.rxns;
%     Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
%     Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
%     L = length(Rxns2CheckF)
% end
% BcRxns2CheckF_my_SRS024549 = Rxns2CheckF;
% 
% 
% load('Y:\SemiAutomated_Organ_Models\_InesProteomeMapData\HH_final\2017_10_28_male_microbiota_model_samp_SRS019030.mat')
% 
% M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'Kidney_EX_'))));
% M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[u]'))));
% Rxns2CheckF = modelHM.rxns(setdiff(M2,M1));
% L = length(Rxns2CheckF)
% Llast=L+1;
% while L<Llast
%     Llast = L;
%     modelHM.c=zeros(length(modelHM.rxns),1);
%     modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
%     modelHM.osense = -1;
%     tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
%     % modelHM.LPBasis = LPProblem.LPBasis;
%     Rxns2Check = modelHM.rxns;
%     Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
%     Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
%     L = length(Rxns2CheckF)
% end
% URxns2CheckF_my_SRS019030 = Rxns2CheckF;
% 
% % bbb
% K1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'BBB_'))));
% K2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[CSF]upt'))));
% Rxns2CheckF = modelHM.rxns(intersect(K1,K2));
% L = length(Rxns2CheckF)
% Llast=L+1;
% while L<Llast
%     Llast = L;
%     modelHM.c=zeros(length(modelHM.rxns),1);
%     modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
%     modelHM.osense = 1;
%     tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
%     % modelHM.LPBasis = LPProblem.LPBasis;
%     Rxns2Check = modelHM.rxns;
%     Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
%     Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
%     L = length(Rxns2CheckF)
% end
% BRxns2CheckF_my_SRS019030 = Rxns2CheckF;
% %
% 
% M1 = (find(~cellfun(@isempty,strfind(modelHM.mets,'[bc]'))));
% M2 = (find(~cellfun(@isempty,strfind(modelHM.mets,'slack'))));
% M = setdiff(M1,M2);
% 
% modelHM = addDemandReaction(modelHM,modelHM.mets(M),0);
% modelHM.A=modelHM.S;
% 
% M1 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'DM_'))));
% M2 = (find(~cellfun(@isempty,strfind(modelHM.rxns,'[bc]'))));
% Rxns2CheckF = modelHM.rxns(intersect(M2,M1));
% 
% L = length(Rxns2CheckF)
% Llast=L+1;
% while L<Llast
%     Llast = L;
%     modelHM.c=zeros(length(modelHM.rxns),1);
%     modelHM.c(find(ismember(modelHM.rxns,Rxns2CheckF)))=1;
%     modelHM.osense = -1;
%     tic;[solutionGF_O2,LPProblem]=solveCobraLPCPLEX(modelHM,1,0,0,[],0,'tomlab_cplex');toc
%     % modelOrganAllCoupled.LPBasis = LPProblem.LPBasis;
%     Rxns2Check = modelHM.rxns;
%     Rxns2Check(find(abs(solutionGF_O2.full)>1e-6))=[];
%     Rxns2CheckF = intersect(Rxns2CheckF,Rxns2Check);
%     L = length(Rxns2CheckF)
% end
% BcRxns2CheckF_my_SRS019030 = Rxns2CheckF;
% 
