function plotBiomassTestResults(translatedDraftsFolder,refinedFolder,testResultsFolder,numWorkers,reconVersion)

tol=0.0000001;

% initialize COBRA Toolbox and parallel pool
global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end
solver = CBT_LP_SOLVER;

if numWorkers > 0
    % with parallelization
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end
environment = getEnvironment();

% test draft and refined reconstructions
folders={
translatedDraftsFolder
refinedFolder
};

for f=1:length(folders)
    dInfo = dir(folders{f});
    modelList={dInfo.name};
    modelList=modelList';
    modelList(~contains(modelList(:,1),'.mat'),:)=[];
    
    parfor i=1:length(modelList)
        restoreEnvironment(environment);
        changeCobraSolver(solver, 'LP', 0, -1);
        
        model=readCbModel([folders{f} filesep modelList{i}]);
        biomassID=find(strncmp(model.rxns,'bio',3));
        [AerobicGrowth, AnaerobicGrowth] = testGrowth(model, model.rxns(biomassID));
        aerRes{i,f}=AerobicGrowth;
        anaerRes{i,f}=AnaerobicGrowth;
    end
    
    for i=1:length(modelList)
        growth{f}(i,1)=aerRes{i,f}(1,1);
        growth{f}(i,2)=anaerRes{i,f}(1,1);
        growth{f}(i,3)=aerRes{i,f}(1,2);
        growth{f}(i,4)=anaerRes{i,f}(1,2);
    end
end

data=[];
for f=1:length(folders)
    data(:,size(data,2)+1:size(data,2)+2)=growth{f}(:,1:2);
end

figure;
hold on
violinplot(data, {'Aerobic, Draft','Anaerobic, Draft','Aerobic, Refined','Anaerobic, Refined'});
set(gca, 'FontSize', 12)
box on
h=title(['Growth on rich medium, ' reconVersion]);
set(h,'interpreter','none')
set(gca,'TickLabelInterpreter','none')
print([testResultsFolder filesep 'Growth_rates_Rich_medium_' reconVersion],'-dpng','-r300')

data=[];
for f=1:length(folders)
    data(:,size(data,2)+1:size(data,2)+2)=growth{f}(:,3:4);
end

figure;
hold on
violinplot(data, {'Aerobic, Draft','Anaerobic, Draft','Aerobic, Refined','Anaerobic, Refined'});
set(gca, 'FontSize', 12)
box on
h=title(['Growth on Western diet, ' reconVersion]);
set(h,'interpreter','none')
set(gca,'TickLabelInterpreter','none')
print([testResultsFolder filesep 'Growth_rates_Western_diet_' reconVersion],'-dpng','-r300')

% report draft models that are unable to grow
fprintf('Report for draft models:\n')
noGrowth=growth{1}(:,1) < tol;
if sum(noGrowth) > 0
    fprintf([num2str(sum(noGrowth)) ' models are unable to produce biomass on rich medium.\n'])
else
    fprintf('All models are able to produce biomass on rich medium.\n')
end

noGrowth=growth{1}(:,2) < tol;
if sum(noGrowth) > 0
    fprintf([num2str(sum(noGrowth)) ' models are unable to produce biomass on rich medium under anaerobic conditions.\n'])
else
    fprintf('All models are able to produce biomass on rich medium under anaerobic conditions.\n')
end

noGrowth=growth{1}(:,3) < tol;
if sum(noGrowth) > 0
    fprintf([num2str(sum(noGrowth)) ' models are unable to produce biomass on Western diet.\n'])
else
    fprintf('All models are able to produce biomass on Western diet.\n')
end

noGrowth=growth{1}(:,4) < tol;
if sum(noGrowth) > 0
    fprintf([num2str(sum(noGrowth)) ' models are unable to produce biomass on Western diet under anaerobic conditions.\n'])
else
    fprintf('All models are able to produce biomass on Western diet under anaerobic conditions.\n')
end

% report refined models that are unable to grow
fprintf('Report for refined models:\n')
noGrowth=growth{2}(:,1) < tol;
if sum(noGrowth) > 0
    fprintf([num2str(sum(noGrowth)) ' models are unable to produce biomass on rich medium.\n'])
else
    fprintf('All models are able to produce biomass on rich medium.\n')
end

noGrowth=growth{2}(:,2) < tol;
if sum(noGrowth) > 0
    fprintf([num2str(sum(noGrowth)) ' models are unable to produce biomass on rich medium under anaerobic conditions.\n'])
else
    fprintf('All models are able to produce biomass on rich medium under anaerobic conditions.\n')
end

noGrowth=growth{2}(:,3) < tol;
if sum(noGrowth) > 0
    fprintf([num2str(sum(noGrowth)) ' models are unable to produce biomass on Western diet.\n'])
else
    fprintf('All models are able to produce biomass on Western diet.\n')
end

noGrowth=growth{2}(:,4) < tol;
if sum(noGrowth) > 0
    fprintf([num2str(sum(noGrowth)) ' models are unable to produce biomass on Western diet under anaerobic conditions.\n'])
else
    fprintf('All models are able to produce biomass on Western diet under anaerobic conditions.\n')
end

end
