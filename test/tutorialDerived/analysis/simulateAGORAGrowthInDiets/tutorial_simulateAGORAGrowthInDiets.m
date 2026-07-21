%% Simulation of growth of human gut microbes on different diets
%% Author: Almut Heinken, Molecular Systems Physiology Group, University of Luxembourg.
% This tutorial shows how to simulate growth of the AGORA gut microbial models 
% (or other microbial models) on different dietary inputs under aerobic and anaerobic 
% conditions.
%% Initialize the COBRA Toolbox

initCobraToolbox
%% Prepare input data and models
% change directory to where the tutorial is located

tutorialPath = fileparts(which('tutorial_simulateAGORAGrowthInDiets'));
cd(tutorialPath);
%% 
% We will use the AGORA resource (Magnusdottir et al., Nat Biotechnol. 2017 
% Jan;35(1):81-89) in this tutorial. AGORA version 1.03 is available at https://github.com/VirtualMetabolicHuman/AGORA. 
% Download AGORA and place the models into a folder.

system('curl -LJO https://github.com/VirtualMetabolicHuman/AGORA/archive/master.zip')
unzip('AGORA-master')
modPath = [pwd filesep 'AGORA-master' filesep 'CurrentVersion' filesep 'AGORA_1_03' filesep' 'AGORA_1_03_mat'];
%% 
% Import a file with information on the AGORA organisms including reconstruction 
% names and taxonomy.

[~,infoFile,~]=xlsread('AGORA_infoFile.xlsx');
% Load the AGORA reconstructions.
%% Load the AGORA reconstructions to be joined.

for i=2:size(infoFile,1)
    model=readCbModel([modPath filesep infoFile{i,1} '.mat']);
    inputModels{i-1,1}=model;
end
%% Simulation of growth on a Western and a high fiber diet in presence and absence of oxygen
% The diets were first described in Table S12, Magnusdottir et al., Nat Biotechnol. 
% 2017 Jan;35(1):81-89. Please note that there are slight differences between 
% this implementation of the Western diet and the one used for simulations in 
% the original AGORA publication (see https://www.vmh.life/files/reconstructions/AGORA/1.01/AGORA-Flux-Table.md). 
% Since the resulting differences in growth rate are only minor, it is recommended 
% to use the implementation provided in cobratoolbox/papers/2018_microbiomeModelingToolbox/resources. 
% This implementation is consistent with the Western diet used in the microbeMicrobeInteractions 
% tutorial. Both diets are simulated in presence and absence of oxygen.
%% Set a Western diet as dietary input.
% This will simulate growth on a diet high in simple sugars and fat, but low 
% in fiber. 

dietConstraints=readtable('WesternDietAGORA.txt');
dietConstraints=table2cell(dietConstraints);
dietConstraints(:,2)=cellstr(num2str(cell2mat(dietConstraints(:,2))));
for i=1:size(inputModels,1)
    model=inputModels{i,1};
    model=changeObjective(model,model.rxns(find(strncmp(model.rxns,'biomass',7))));
    model=useDiet(model,dietConstraints);
    FBA=optimizeCbModel(model,'max');
    data(i,1)=FBA.f;
    % Enable uptake of oxygen
    model=changeRxnBounds(model,'EX_o2(e)',-10,'l');
    FBA=optimizeCbModel(model,'max');
    data(i,2)=FBA.f;
end
%% Set a high fiber diet as dietary input.
% This will simulate growth on a diet high in fiber, but low in simple sugars 
% and fat.

dietConstraints=readtable('HighFiberDietAGORA.txt');
dietConstraints=table2cell(dietConstraints);
dietConstraints(:,2)=cellstr(num2str(cell2mat(dietConstraints(:,2))));
for i=1:size(inputModels,1)
    model=inputModels{i,1};
    model=changeObjective(model,model.rxns(find(strncmp(model.rxns,'biomass',7))));
    model=useDiet(model,dietConstraints);
    FBA=optimizeCbModel(model,'max');
    data(i,3)=FBA.f;
    % Enable uptake of oxygen
    model=changeRxnBounds(model,'EX_o2(e)',-10,'l');
    FBA=optimizeCbModel(model,'max');
    data(i,4)=FBA.f;
end
%% Plot the growth rates on the two diets.

dataAll=vertcat(data(:,1),data(:,2),data(:,3),data(:,4));
group=cell(size(data,1),4);
group(:,1)={'Western diet, anoxic'};
group(:,2)={'Western diet, oxic'};
group(:,3)={'High fiber diet, anoxic'};
group(:,4)={'High fiber diet, oxic'};
groupAll=vertcat(group(:,1),group(:,2),group(:,3),group(:,4));
figure
boxplot(dataAll,groupAll,'PlotStyle','traditional','BoxStyle','outline')
h = findobj(gca,'Tag','Box');
% Change colors
for j=1:length(h)
    if j==1
        patch(get(h(j),'XData'),get(h(j),'YData'),'g','FaceAlpha',.5);
    end
    if j==2
        patch(get(h(j),'XData'),get(h(j),'YData'),'b','FaceAlpha',.5);
    end
    if j==3
        patch(get(h(j),'XData'),get(h(j),'YData'),'y','FaceAlpha',.5);
    end
    if j==4
        patch(get(h(j),'XData'),get(h(j),'YData'),'r','FaceAlpha',.5);
    end
end
set(gca, 'FontSize', 12)
title('Growth rates in 818 AGORA gut microbe models on two diets')
%% Grow AGORA on a diet created with VMH Diet Designer
% Here, a diet provided by the Diet Designer tool at the Virtual Metabolic Human 
% website (https://www.vmh.life/, Noronha et al., "The Virtual Metabolic Human 
% database: integrating human and gut microbiome metabolism with nutrition and 
% disease", Nucleic Acids Research (2018) will be used. A number of pre-made diets 
% are available at https://www.vmh.life/#nutrition and in cobratoolbox/papers/2018_microbiomeModelingToolbox/resources. 
% The user can also generate a customized diet with the DietDesigner tool and 
% use it for simulations with AGORA. Note that the diets were designed for microbiome 
% simulations and the predicted growth rates may be very high for single AGORA 
% models.

dietConstraints=adaptVMHDietToAGORA('AverageEuropeanDiet','AGORA');
clear data
for i=1:size(inputModels,1)
    model=inputModels{i,1};
    model=changeObjective(model,model.rxns(find(strncmp(model.rxns,'biomass',7))));
    model=useDiet(model,dietConstraints);
    FBA=optimizeCbModel(model,'max');
    data(i,1)=FBA.f;
    % Enable uptake of oxygen
    model=changeRxnBounds(model,'EX_o2(e)',-10,'l');
    FBA=optimizeCbModel(model,'max');
    data(i,2)=FBA.f;
end
%% Plot the growth rates on the Average European diet.

dataAll=vertcat(data(:,1),data(:,2));
group=cell(size(data,1),2);
group(:,1)={'Average European diet, anoxic'};
group(:,2)={'Average European diet, oxic'};
groupAll=vertcat(group(:,1),group(:,2));
figure
boxplot(dataAll,groupAll,'PlotStyle','traditional','BoxStyle','outline')
h = findobj(gca,'Tag','Box');
% Change colors
for j=1:length(h)
    if j==1
        patch(get(h(j),'XData'),get(h(j),'YData'),'g','FaceAlpha',.5);
    end
    if j==2
        patch(get(h(j),'XData'),get(h(j),'YData'),'b','FaceAlpha',.5);
    end
end
set(gca, 'FontSize', 12)
title('Growth rates in 818 AGORA gut microbe models on an Average European diet')