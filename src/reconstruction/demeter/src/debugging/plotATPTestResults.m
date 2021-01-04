function plotATPTestResults(modelFolder,resultsFolder)

atp{1,1}='Model_ID';
atp{1,2}='WD_aerobic';
atp{1,3}='WD_anaerobic';

dInfo = dir(modelFolder);
modelList={dInfo.name};
modelList=modelList';
modelList(~contains(modelList(:,1),'.mat'),:)=[];
for i=1:length(modelList)
    i
    load([modelFolder filesep modelList{i}]);
    biomassID=find(strncmp(model.rxns,'bio',3));
    [atpFluxAerobic, atpFluxAnaerobic] = testATP(model);
    atp{i+1,1}=strrep(modelList{i},'.mat','');
    atp{i+1,2}=atpFluxAerobic(1,1);
    atp{i+1,3}=atpFluxAnaerobic(1,1);
end
save([resultsFolder filesep 'atp.mat'],'atp');

% report models that produce too much ATP
tooHigh=cell2mat(atp(2:end,2)) > 150;
if sum(tooHigh) > 0
warning([num2str(sum(tooHigh)) ' models produce too much ATP under aerobic conditions.'])
end

if sum(tooHigh) > 0
tooHigh=cell2mat(atp(2:end,3)) > 100;
warning([num2str(sum(tooHigh)) ' models produce too much ATP under anaerobic conditions.'])
end

data=cell2mat(atp(2:end,2:3));
figure;
hold on
violinplot(data, {'Aerobic','Anaerobic'});
set(gca, 'FontSize', 16)
box on
h=title('ATP production on Western diet');
set(h,'interpreter','none')
set(gca,'TickLabelInterpreter','none')
print([resultsFolder filesep 'ATP_Western_diet'],'-dpng','-r300')

end
