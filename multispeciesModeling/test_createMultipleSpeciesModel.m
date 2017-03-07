
%% test the code for creating multi-species model
clear all
% test model creation and biomass production
solverOK=changeCobraSolver('glpk','LP');
load('Ecoli_core_model.mat');
% also as "host"
host=modelEcore;

%% test joining one microbe model with/without host
microbeModels{1,1}=modelEcore;

% only one microbe entered
[modelJoint] = createMultipleSpeciesModel(microbeModels);
assert(length(modelEcore.rxns) == length(strmatch('model1_',modelJoint.rxns)))
assert(length(modelEcore.mets) == length(strmatch('model1_',modelJoint.mets)))

% one microbe model with host
[modelJointHost] = createMultipleSpeciesModel(microbeModels,[],host);
assert(length(modelEcore.rxns) == length(strmatch('model1_',modelJointHost.rxns)))
assert(length(modelEcore.mets) == length(strmatch('model1_',modelJointHost.mets)))
% count the number of extracellular reactions in host to determine number
% of body fluid compartment reactions added
exRxns={};
rxnCnt=1;
metCnt=1;
for i = 1:length(host.mets)
    if ~isempty(strfind(host.mets{i},'[e]'))
        exMets{metCnt,1}=host.mets{i};
        metCnt=metCnt+1;
        % find all reactions associated - copy and rename
        ERxnind = find(host.S(i,:));
        for j=1:length(ERxnind)
        exRxns{rxnCnt,1}=host.rxns{ERxnind(j),1};
        rxnCnt=rxnCnt+1;
        end
    end
end
exRxns=unique(exRxns);
exch=strmatch('EX_',exRxns);
assert(length(exch) == length(strmatch('Host_EX',modelJointHost.rxns)))
% now compare total number of reactions
% NOTE: some large host reconstructions (e.g., Recon2) are too complex and/or already have lumen compartment-in this
% case, the test won't work
assert(length(host.rxns)+length(exRxns) == length(strmatch('Host_',modelJointHost.rxns)))
assert(length(host.mets)+length(exMets) == length(strmatch('Host_',modelJointHost.mets)))

%% test joining of two microbes with/without host
microbeModels{1,1}=modelEcore;
microbeModels{2,1}=modelEcore;
% with two microbe models and host
[modelJointHost] = createMultipleSpeciesModel(microbeModels,[],host);
% two microbe models without host
[modelJoint] = createMultipleSpeciesModel(microbeModels);

% ensure that the joined models have all reactions and metabolites that
% the original models had and that the models can produce biomass
% for model without host
for i=1:2
assert(length(modelEcore.rxns) == length(strmatch(strcat('model',num2str(i),'_'),modelJoint.rxns)))
assert(length(modelEcore.mets) == length(strmatch(strcat('model',num2str(i),'_'),modelJoint.mets)))
modelJoint=changeObjective(modelJoint,strcat('model',num2str(i),'_','Biomass_Ecoli_core_w_GAM'));
FBA=optimizeCbModel(modelJoint,'max');
assert(FBA.f > 0.000001)
end

% for model with host
for i=1:2
assert(length(modelEcore.rxns) == length(strmatch(strcat('model',num2str(i),'_'),modelJointHost.rxns)))
assert(length(modelEcore.mets) == length(strmatch(strcat('model',num2str(i),'_'),modelJointHost.mets)))
modelJointHost=changeObjective(modelJointHost,strcat('model',num2str(i),'_','Biomass_Ecoli_core_w_GAM'));
FBA=optimizeCbModel(modelJointHost,'max');
assert(FBA.f > 0.000001)
end
% count the number of extracellular reactions in host to determine number
% of body fluid compartment reactions added
exRxns={};
rxnCnt=1;
metCnt=1;
for i = 1:length(host.mets)
    if ~isempty(strfind(host.mets{i},'[e]'))
        exMets{metCnt,1}=host.mets{i};
        metCnt=metCnt+1;
        % find all reactions associated - copy and rename
        ERxnind = find(host.S(i,:));
        for j=1:length(ERxnind)
        exRxns{rxnCnt,1}=host.rxns{ERxnind(j),1};
        rxnCnt=rxnCnt+1;
        end
    end
end
exRxns=unique(exRxns);
exch=strmatch('EX_',exRxns);
assert(length(exch) == length(strmatch('Host_EX',modelJointHost.rxns)))
% now compare total number of reactions
% NOTE: some large host reconstructions (e.g., Recon2) are too complex and/or already have lumen compartment-in this
% case, the test won't work
assert(length(host.rxns)+length(exRxns) == length(strmatch('Host_',modelJointHost.rxns)))
assert(length(host.mets)+length(exMets) == length(strmatch('Host_',modelJointHost.mets)))
% test host biomass
modelJointHost=changeObjective(modelJointHost,'Host_Biomass_Ecoli_core_w_GAM');
FBA=optimizeCbModel(modelJointHost,'max');
assert(FBA.f > 0.000001)

%% test joining three models with/without host
microbeModels{1,1}=modelEcore;
microbeModels{2,1}=modelEcore;
microbeModels{3,1}=modelEcore;
% three microbe models without host
[modelJoint] = createMultipleSpeciesModel(microbeModels);
% three microbe models with host
[modelJointHost] = createMultipleSpeciesModel(microbeModels,[],host);

% ensure that the joined models have all reactions and metabolites that
% the original models had and can produce biomass
% for model without host
for i=1:3
assert(length(modelEcore.rxns) == length(strmatch(strcat('model',num2str(i),'_'),modelJoint.rxns)))
assert(length(modelEcore.mets) == length(strmatch(strcat('model',num2str(i),'_'),modelJoint.mets)))
modelJoint=changeObjective(modelJoint,strcat('model',num2str(i),'_','Biomass_Ecoli_core_w_GAM'));
FBA=optimizeCbModel(modelJoint,'max');
assert(FBA.f > 0.000001)
end

% for model with host
for i=1:3
assert(length(modelEcore.rxns) == length(strmatch(strcat('model',num2str(i),'_'),modelJointHost.rxns)))
assert(length(modelEcore.mets) == length(strmatch(strcat('model',num2str(i),'_'),modelJointHost.mets)))
modelJointHost=changeObjective(modelJointHost,strcat('model',num2str(i),'_','Biomass_Ecoli_core_w_GAM'));
FBA=optimizeCbModel(modelJointHost,'max');
assert(FBA.f > 0.000001)
end
% count the number of extracellular reactions in host to determine number
% of body fluid compartment reactions added
exRxns={};
rxnCnt=1;
metCnt=1;
for i = 1:length(host.mets)
    if ~isempty(strfind(host.mets{i},'[e]'))
        exMets{metCnt,1}=host.mets{i};
        metCnt=metCnt+1;
        % find all reactions associated - copy and rename
        ERxnind = find(host.S(i,:));
        for j=1:length(ERxnind)
        exRxns{rxnCnt,1}=host.rxns{ERxnind(j),1};
        rxnCnt=rxnCnt+1;
        end
    end
end
exRxns=unique(exRxns);
exch=strmatch('EX_',exRxns);
assert(length(exch) == length(strmatch('Host_EX',modelJointHost.rxns)))
% now compare total number of reactions
% NOTE: some large host reconstructions (e.g., Recon2) are too complex and/or already have lumen compartment-in this
% case, the test won't work
assert(length(host.rxns)+length(exRxns) == length(strmatch('Host_',modelJointHost.rxns)))
assert(length(host.mets)+length(exMets) == length(strmatch('Host_',modelJointHost.mets)))
% test host biomass
modelJointHost=changeObjective(modelJointHost,'Host_Biomass_Ecoli_core_w_GAM');
FBA=optimizeCbModel(modelJointHost,'max');
assert(FBA.f > 0.000001)
%% test that custom nametags can be entered
microbeModels{1,1}=modelEcore;
microbeModels{2,1}=modelEcore;
microbeModels{3,1}=modelEcore;
% use custom nametags
microbeNameTags={'ecoli1_'
    'ecoli2_'
    'ecoli3_'
    };
hostNameTag='modelHost_';
% three microbe models with host
[modelJointHost] = createMultipleSpeciesModel(microbeModels,microbeNameTags,host,hostNameTag);
% three microbe models without host
[modelJoint] = createMultipleSpeciesModel(microbeModels,microbeNameTags);

% ensure that the joined models have all reactions and metabolites that
% the original models had and can produce biomass
% for model without host
for i=1:3
assert(length(modelEcore.rxns) == length(strmatch(strcat('ecoli',num2str(i),'_'),modelJoint.rxns)))
assert(length(modelEcore.mets) == length(strmatch(strcat('ecoli',num2str(i),'_'),modelJoint.mets)))
modelJoint=changeObjective(modelJoint,strcat('ecoli',num2str(i),'_','Biomass_Ecoli_core_w_GAM'));
FBA=optimizeCbModel(modelJoint,'max');
assert(FBA.f > 0.000001)
end

% for model with host
for i=1:3
assert(length(modelEcore.rxns) == length(strmatch(strcat('ecoli',num2str(i),'_'),modelJointHost.rxns)))
assert(length(modelEcore.mets) == length(strmatch(strcat('ecoli',num2str(i),'_'),modelJointHost.mets)))
modelJointHost=changeObjective(modelJointHost,strcat('ecoli',num2str(i),'_','Biomass_Ecoli_core_w_GAM'));
FBA=optimizeCbModel(modelJointHost,'max');
assert(FBA.f > 0.000001)
end
% count the number of extracellular reactions in host to determine number
% of body fluid compartment reactions added
exRxns={};
rxnCnt=1;
metCnt=1;
for i = 1:length(host.mets)
    if ~isempty(strfind(host.mets{i},'[e]'))
        exMets{metCnt,1}=host.mets{i};
        metCnt=metCnt+1;
        % find all reactions associated - copy and rename
        ERxnind = find(host.S(i,:));
        for j=1:length(ERxnind)
        exRxns{rxnCnt,1}=host.rxns{ERxnind(j),1};
        rxnCnt=rxnCnt+1;
        end
    end
end
exRxns=unique(exRxns);
exch=strmatch('EX_',exRxns);
assert(length(exch) == length(strmatch('modelHost_EX',modelJointHost.rxns)))
% now compare total number of reactions
% NOTE: some large host reconstructions (e.g., Recon2) are too complex and/or already have lumen compartment-in this
% case, the test won't work
assert(length(host.rxns)+length(exRxns) == length(strmatch('modelHost_',modelJointHost.rxns)))
assert(length(host.mets)+length(exMets) == length(strmatch('modelHost_',modelJointHost.mets)))
% test host biomass
modelJointHost=changeObjective(modelJointHost,'modelHost_Biomass_Ecoli_core_w_GAM');
FBA=optimizeCbModel(modelJointHost,'max');
assert(FBA.f > 0.000001)

%% test that one hundred models can be joined
for i=1:100
    microbeModels{i,1}=modelEcore;
end
[modelJoint] = createMultipleSpeciesModel(microbeModels);

% ensure that the joined models have all reactions and metabolites that
% the original models had and can produce biomass
for i=1:100
assert(length(modelEcore.rxns) == length(strmatch(strcat('model',num2str(i),'_'),modelJoint.rxns)))
assert(length(modelEcore.mets) == length(strmatch(strcat('model',num2str(i),'_'),modelJoint.mets)))
modelJoint=changeObjective(modelJoint,strcat('model',num2str(i),'_','Biomass_Ecoli_core_w_GAM'));
FBA=optimizeCbModel(modelJoint,'max');
assert(FBA.f > 0.000001)
end


load iSS1393.mat;
host=MouseModel;
% one microbe model with host
[modelJointHost] = createMultipleSpeciesModel(microbeModels,[],host);
assert(length(modelEcore.rxns) == length(strmatch('model1_',modelJointHost.rxns)))
assert(length(modelEcore.mets) == length(strmatch('model1_',modelJointHost.mets)))
% count the number of extracellular reactions in host to determine number
% of body fluid compartment reactions added
exRxns={};
rxnCnt=1;
for i = 1:length(host.mets)
    if ~isempty(strfind(host.mets{i},'[e]'))
        % find all reactions associated - copy and rename
        ERxnind = find(host.S(i,:));
        for j=1:length(ERxnind)
        exRxns{rxnCnt,1}=host.rxns{ERxnind(j),1};
        rxnCnt=rxnCnt+1;
        end
    end
end
exRxns=unique(exRxns);
exch=strmatch('EX_',exRxns);
assert(length(exch) == length(strmatch('Host_EX',modelJointHost.rxns)))
% test host biomass
modelJointHost=changeObjective(modelJointHost,'Host_biomass_mm_1_no_glygln');
FBA=optimizeCbModel(modelJointHost,'max');
assert(FBA.f > 0.000001)

