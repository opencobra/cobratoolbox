function [debuggingReport, failedModels]=runDebuggingTools(refinedFolder,testResultsFolder,reconVersion)
% This function runs a suite of debugging functions on a refined
% reconstruction produced by the DEMETER pipeline. Tests
% are performed whether or not the models can produce biomass aerobically
% and anaerobically, and whether or not unrealistically high ATP is
% produced on the Western diet.

% get all models that failed at least one test
failedModels = {};

if isfile([testResultsFolder filesep reconVersion '_refined' filesep 'notGrowing.mat'])
    load([testResultsFolder filesep reconVersion '_refined' filesep 'notGrowing.mat']);
    failedModels = union(failedModels,notGrowing);
end
if isfile([testResultsFolder filesep reconVersion '_refined' filesep 'tooHighATP.mat'])
    load([testResultsFolder filesep reconVersion '_refined' filesep 'tooHighATP.mat']);
    failedModels = union(failedModels,tooHighATP);
end
if isfile([testResultsFolder filesep reconVersion '_refined' filesep 'growsOnDefinedMedium_' reconVersion '_refined.txt'])
    FNlist = readtable([testResultsFolder filesep reconVersion '_refined' filesep 'growsOnDefinedMedium_' reconVersion '_refined.txt'], 'ReadVariableNames', false, 'Delimiter', 'tab');
    FNlist = table2cell(FNlist);
    failedModels=union(failedModels,FNlist(find(strcmp(FNlist(:,2),'0')),1));
end

currentDir(pwd);
% go to correct folder and load test results
cd([testResultsFolder filesep reconVersion '_refined'])

% load all test result files for experimental data
dInfo = dir(pwd);
fileList={dInfo.name};
fileList=fileList';
fileList(~(contains(fileList(:,1),{'.txt'})),:)=[];
fileList(~(contains(fileList(:,1),{'FalseNegatives'})),:)=[];

for i=1:size(fileList,1)
    FNlist = readtable([[testResultsFolder filesep reconVersion '_refined'] filesep fileList{i,1}], 'ReadVariableNames', false, 'Delimiter', 'tab');
    FNlist = table2cell(FNlist);
    % remove all rows with no cases
    FNlist(cellfun(@isempty, FNlist(:,2)),:)=[];
    failedModels=union(failedModels,FNlist(:,1));
end

% perform debugging tools for each model for which addiitonal curation is
% needed
for i=1:length(failedModels)
    model=readCbModel([refinedFolder filesep failedModels{i,1} '.mat']);
end

cd(currentDir);
end