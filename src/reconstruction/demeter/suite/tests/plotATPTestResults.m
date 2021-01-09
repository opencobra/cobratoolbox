function plotATPTestResults(translatedDraftsFolder,refinedFolder,testResultsFolder,numWorkers,reconVersion)

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
        [atpFluxAerobic, atpFluxAnaerobic] = testATP(model);
        aerRes{i,f}=atpFluxAerobic;
        anaerRes{i,f}=atpFluxAnaerobic;
    end
    
    for i=1:length(modelList)
        atp{f}(i,1)=aerRes{i,f};
        atp{f}(i,2)=anaerRes{i,f};
    end
end

data=[];
for f=1:length(folders)
    data(:,size(data,2)+1:size(data,2)+2)=atp{f}(:,1:2);
end



figure;
hold on
violinplot(data, {'Aerobic, Draft','Anaerobic, Draft','Aerobic, Refined','Anaerobic, Refined'});
set(gca, 'FontSize', 12)
box on
h=title(['ATP production on Western diet, ' reconVersion]);
set(h,'interpreter','none')
set(gca,'TickLabelInterpreter','none')
print([testResultsFolder filesep 'ATP_Western_diet_' reconVersion],'-dpng','-r300')

% report draft models that produce too much ATP
fprintf('Report for draft models:\n')
tooHigh=atp{1}(:,1) > 150;
if sum(tooHigh) > 0
    fprintf([num2str(sum(tooHigh)) '  models produce too much ATP under aerobic conditions.\n'])
else
    fprintf('All models produce reasonable amounts of ATP under aerobic conditions.\n')
end

tooHigh=atp{1}(:,2) > 100;
if sum(tooHigh) > 0
    fprintf([num2str(sum(tooHigh)) '  models produce too much ATP under anaerobic conditions.\n'])
else
    fprintf('All models produce reasonable amounts of ATP under anaerobic conditions.\n')
end

% report refined models that produce too much ATP
fprintf('Report for refined models:\n')
tooHigh=atp{2}(:,1) > 150;
if sum(tooHigh) > 0
    fprintf([num2str(sum(tooHigh)) '  models produce too much ATP under aerobic conditions.\n'])
else
    fprintf('All models produce reasonable amounts of ATP under aerobic conditions.\n')
end

tooHigh=atp{2}(:,2) > 100;
if sum(tooHigh) > 0
    fprintf([num2str(sum(tooHigh)) '  models produce too much ATP under anaerobic conditions.\n'])
else
    fprintf('All models produce reasonable amounts of ATP under anaerobic conditions.\n')
end

end
