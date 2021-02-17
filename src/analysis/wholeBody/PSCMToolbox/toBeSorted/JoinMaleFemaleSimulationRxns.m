female = {'HarvettaGF'
    'SRS011239'
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
    };

male = {'HarveyGF'
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
    };

load('Y:\SemiAutomated_Organ_Models\_InesProteomeMapData\HH_final\Results_male_microbiota_model_samp_SRS018313.mat')
K1 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'BBB_'))));
K2 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'[CSF]upt'))));
M = intersect(K1,K2);
M1 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'Kidney_EX_'))));
M2 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'[u]'))));
M = setdiff(M2,M1);
MaleU = modelOrganAllCoupled.rxns(M);
K1 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'BBB_'))));
K2 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'[CSF]upt'))));
M = intersect(K1,K2);
MaleB = modelOrganAllCoupled.rxns(M);
MaleRxns=[MaleU;MaleB];

load('Y:\SemiAutomated_Organ_Models\_InesProteomeMapData\HH_final\Results_female_microbiota_model_samp_SRS022137.mat')
K1 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'BBB_'))));
K2 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'[CSF]upt'))));
M = intersect(K1,K2);
M1 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'Kidney_EX_'))));
M2 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'[u]'))));
M = setdiff(M2,M1);
FemaleU = modelOrganAllCoupled.rxns(M);
K1 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'BBB_'))));
K2 = (find(~cellfun(@isempty,strfind(modelOrganAllCoupled.rxns,'[CSF]upt'))));
M = intersect(K1,K2);
FemaleB = modelOrganAllCoupled.rxns(M);
FemaleRxns=[FemaleU;FemaleB];

 load('Y:\SemiAutomated_Organ_Models\_InesProteomeMapData\HH_final\ResultsAll_male.mat')
 USecretionMale = USecretion;
USecretionMale(find(abs(USecretionMale)<=1e-8))=0;
 BSecretionMale = BSecretion;
BSecretionMale(find(abs(BSecretionMale)<=1e-8))=0;
BSecretionMale=BSecretionMale*-1;
MaleSecretion = [USecretionMale;BSecretionMale];
 load('Y:\SemiAutomated_Organ_Models\_InesProteomeMapData\HH_final\ResultsAll_female.mat')
 USecretionFemale = USecretion;
 USecretionFemale(find(abs(USecretionFemale)<=1e-8))=0;
 BSecretionFemale = BSecretion;
BSecretionFemale(find(abs(BSecretionFemale)<=1e-8))=0;
BSecretionFemale=BSecretionFemale*-1;
FemaleSecretion = [USecretionFemale;BSecretionFemale];

[MFRxns,IA,IB] = union(MaleRxns,FemaleRxns);
for i = 1 : length(MFRxns)
    if ~isempty(find(ismember(MaleRxns,MFRxns{i})))
    MFSecretionMale(i,:)=MaleSecretion(find(ismember(MaleRxns,MFRxns{i})),:);
    end
    if ~isempty(find(ismember(FemaleRxns,MFRxns{i})))
    MFSecretionFemale(i,:)=FemaleSecretion(find(ismember(FemaleRxns,MFRxns{i})),:);
    end
end
MFSecretion = [MFSecretionMale MFSecretionFemale];
Names = [male(1:size(MaleSecretion,2))' female(1:size(FemaleSecretion,2))'];
Gender = [ones(size(MaleSecretion,2),1)' zeros(size(FemaleSecretion,2),1)'];
clear FemaleU FemaleB MFSecretionFemale MFSecretionMale USecretionFemale BSecretionFemale BSecretionUSecretion MaleB MaleR* MaleU IA IB ...
    K1 K2 M1 M2 M i male FemaleR* FemaleSe* BSec* MaleSe* ans female USe* microbiota_model modelHM modelOrganAllCoupled