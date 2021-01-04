% get all biomass components in at least one model

% set the input and output folders
inputFolder=[rootDir filesep 'Current_Version_AGORA2' filesep 'Output_Models' filesep];

dInfo = dir(inputFolder);
modelList={dInfo.name};
modelList=modelList';
modelList(~contains(modelList(:,1),'.mat'),:)=[];

biomassComponents={};

for i=1:length(modelList)
    i
    load([inputFolder modelList{i}]);
    biomassID=find(strncmp(model.rxns, 'bio', 3));
    [a,b]=printBiomass(model,biomassID);
    biomassComponents=union(biomassComponents,a);
    biomassComponents=unique(biomassComponents);
end

% get description of metabolites
metaboliteDatabase = readtable('MetaboliteDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
metaboliteDatabase=table2cell(metaboliteDatabase);

for i=1:length(biomassComponents)
    met=strrep(biomassComponents{i,1},'[c]','');
    biomassComponents{i,2}=metaboliteDatabase(find(strcmp(metaboliteDatabase(:,1),met)),2);
    biomassComponents{i,3}=[];
end

% get average factor

for i=1:length(modelList)
    i
    load([inputFolder modelList{i}]);
    biomassID=find(strncmp(model.rxns, 'bio', 3));
    [a,b]=printBiomass(model,biomassID);
    for j=1:length(a)
        getInd=find(strcmp(biomassComponents(:,1),a{j}));
        biomassComponents{getInd,3}(end+1)=abs(b(j));
    end
end

for i=1:length(biomassComponents)
    biomassComponents{i,4}=mean(biomassComponents{i,3});
end
