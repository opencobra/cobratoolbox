function plotBiomassTestResults(modelFolder,resultsFolder)

tol=0.0000001;

growth{1,1}='Model_ID';
growth{1,2}='Unlim_aerobic';
growth{1,3}='Unlim_anaerobic';
growth{1,4}='WD_aerobic';
growth{1,5}='WD_anaerobic';

dInfo = dir(modelFolder);
modelList={dInfo.name};
modelList=modelList';
modelList(~contains(modelList(:,1),'.mat'),:)=[];
for i=1:length(modelList)
    load([modelFolder filesep modelList{i}]);
    biomassID=find(strncmp(model.rxns,'bio',3));
    [AerobicGrowth, AnaerobicGrowth] = testGrowth(model, model.rxns(biomassID));
    growth{i+1,1}=strrep(modelList{i},'.mat','');
    growth{i+1,2}=AerobicGrowth(1,1);
    growth{i+1,3}=AnaerobicGrowth(1,1);
    growth{i+1,4}=AerobicGrowth(1,2);
    growth{i+1,5}=AnaerobicGrowth(1,2);
end
save([resultsFolder filesep 'growth.mat'],'growth');

% report models that are unable to grow
noGrowth=cell2mat(growth(2:end,2)) < tol;
if sum(noGrowth) > 0
warning([num2str(sum(noGrowth)) ' models are unable to produce biomass.'])
end

if sum(noGrowth) > 0
noGrowth=cell2mat(growth(2:end,3)) < tol;
warning([num2str(sum(noGrowth)) ' models are unable to produce biomass under anaerobic conditions.'])
end

if sum(noGrowth) > 0
noGrowth=cell2mat(growth(2:end,4)) < tol;
warning([num2str(sum(noGrowth)) ' models are unable to produce biomass on Western diet.'])
end

if sum(noGrowth) > 0
noGrowth=cell2mat(growth(2:end,5)) < tol;
warning([num2str(sum(noGrowth)) ' models are unable to produce biomass on Western diet under anaerobic conditions.'])
end

data=cell2mat(growth(2:end,2:3));
figure;
hold on
violinplot(data, {'Unlimited_aerobic','Unlimimited_anaerobic'});
set(gca, 'FontSize', 16)
box on
h=title('Growth rates');
set(h,'interpreter','none')
set(gca,'TickLabelInterpreter','none')
print([resultsFolder filesep 'Growth_rates_Unlimited_medium'],'-dpng','-r300')

data=cell2mat(growth(2:end,4:5));
figure;
hold on
violinplot(data, {'WD_aerobic','WD_anaerobic'});
set(gca, 'FontSize', 16)
box on
h=title('Growth rates');
set(h,'interpreter','none')
set(gca,'TickLabelInterpreter','none')
print([resultsFolder filesep 'Growth_rates_Western_diet'],'-dpng','-r300')

end
